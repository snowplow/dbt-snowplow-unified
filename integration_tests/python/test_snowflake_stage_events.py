"""Execute staged/original macro SQL on synthetic data without a warehouse.

DuckDB checks row semantics; these tests do not measure Snowflake pruning.
Run `dbt deps` in the package root before running pytest.
"""

from pathlib import Path
from types import SimpleNamespace

import duckdb
import pytest
import sqlglot
from jinja2 import Environment, StrictUndefined
from sqlglot import exp


ROOT = Path(__file__).resolve().parents[2]
UTILS = ROOT / "dbt_packages/snowplow_utils/macros"


def render_macros(connection, *, lake=False, columns=(), execute=True):
    env = Environment(undefined=StrictUndefined, extensions=["jinja2.ext.do"])
    env.filters["as_bool"] = bool

    def get_columns(relation):
        assert execute, "Parsing must not introspect the warehouse"
        return columns

    def limits(relation, lower_column, upper_column):
        lower, upper = connection.execute(
            f"select min({lower_column}), max({upper_column}) from {relation}"
        ).fetchone()
        # Same empty-run sentinels as Utils.return_limits_from_model.
        lower = lower or "9999-01-01 00:00:00"
        upper = upper or "9999-01-02 00:00:00"
        return f"timestamp '{lower}'", f"timestamp '{upper}'"

    context = {
        "return": lambda value: value,
        "execute": execute,
        "target": SimpleNamespace(type="snowflake"),
        "var": lambda name, default=None: lake if name == "snowplow__snowflake_lakeloader" else default,
        "ref": lambda name: name,
        "api": SimpleNamespace(Relation=SimpleNamespace(create=lambda **kwargs: kwargs["identifier"])),
        "adapter": SimpleNamespace(
            get_columns_in_relation=get_columns,
            quote=lambda name: '"' + name.replace('"', '""') + '"',
        ),
    }
    app_id_filter = env.from_string((UTILS / "utils/app_id_filter.sql").read_text()).make_module(context).app_id_filter
    context["snowplow_utils"] = SimpleNamespace(
        return_limits_from_model=limits,
        app_id_filter=app_id_filter,
        # DuckDB equivalent of the dispatched Snowflake DATEADD expression.
        timestamp_add=lambda unit, value, field: f"({field} + interval '{value} {unit}')",
    )
    stage = env.from_string((ROOT / "macros/snowflake_stage_events_query.sql").read_text()).make_module(context)
    base = env.from_string((UTILS / "base/base_create_snowplow_events_this_run.sql").read_text()).make_module(context)
    return stage.snowflake_stage_events_query, base.default__base_create_snowplow_events_this_run


@pytest.fixture
def connection():
    db = duckdb.connect()
    db.execute("""
        create table sessions(session_identifier varchar, user_identifier varchar,
                              start_tstamp timestamp, end_tstamp timestamp);
        insert into sessions values
            ('s1', 'u1', '2026-01-05', '2026-01-08'),
            ('s2', 'u2', '2026-01-07', '2026-01-10');
        create table events(event_id varchar, domain_sessionid varchar, app_id varchar,
                            collector_tstamp timestamp, load_tstamp timestamp,
                            dvce_created_tstamp timestamp, dvce_sent_tstamp timestamp);
    """)
    rows = [
        ("lower_boundary", "s1", "keep", "2026-01-05"),
        ("duplicate", "s1", "keep", "2026-01-06"),
        ("duplicate", "s1", "keep", "2026-01-07"),
        ("duplicate", "s1", "keep", "2026-01-04"),
        ("upper_boundary", "s2", "keep", "2026-01-10"),
        ("after_window", "s2", "keep", "2026-01-11"),
        ("before_session", "s2", "keep", "2026-01-06"),
        ("session_cap", "s1", "keep", "2026-01-09"),
        ("other_app", "s2", "other", "2026-01-08"),
        ("unknown_session", "unknown", "keep", "2026-01-08"),
        ("null_session", None, "keep", "2026-01-08"),
        ("null_timestamp", "s1", "keep", None),
    ]
    db.executemany("insert into events values (?, ?, ?, ?, ?, ?, ?)", [
        (event, session, app, timestamp, timestamp, "2026-01-01", "2026-01-01")
        for event, session, app, timestamp in rows
    ])
    db.execute("""
        insert into events values
        ('late_load', 's2', 'keep', '2025-12-01', '2026-01-08', '2025-12-01', '2025-12-01'),
        ('collector_only', 's2', 'keep', '2026-01-08', '2026-01-11', '2026-01-01', '2026-01-01'),
        ('late_device', 's2', 'keep', '2026-01-08', '2026-01-08', '2026-01-01', '2026-01-05'),
        ('null_device', 's2', 'keep', '2026-01-08', '2026-01-08', null, null);
    """)
    yield db
    db.close()


def base_sql(base, source, timestamp, app_ids, allow_null):
    return base(
        sessions_this_run_table="sessions", session_identifiers=[],
        session_sql="e.domain_sessionid", session_timestamp=timestamp,
        derived_tstamp_partitioned=True, days_late_allowed=3, max_session_days=3,
        app_ids=app_ids, snowplow_events_database=None, snowplow_events_schema="main",
        snowplow_events_table=source, entities_or_sdes=None, custom_sql=None,
        allow_null_dvce_tstamps=allow_null,
    )


@pytest.mark.parametrize("timestamp", ["collector_tstamp", "load_tstamp"])
@pytest.mark.parametrize("app_ids", [[], ["keep"]])
@pytest.mark.parametrize("allow_null", [False, True])
def test_staging_preserves_full_session_results(connection, timestamp, app_ids, allow_null):
    stage, base = render_macros(connection)
    original = base_sql(base, "events", timestamp, app_ids, allow_null)
    connection.execute("create table staged as " + stage("events", "sessions", timestamp, app_ids))
    staged = base_sql(base, "staged", timestamp, app_ids, allow_null)
    expected = connection.execute(original).fetchall()
    actual = connection.execute(staged).fetchall()
    assert set(actual) == set(expected)
    assert len(actual) == len(expected)
    ids = {row[1] for row in actual}
    required = {"lower_boundary", "upper_boundary", "duplicate"}
    required.add("late_load" if timestamp == "load_tstamp" else "collector_only")
    if not app_ids:
        required.add("other_app")
    if allow_null:
        required.add("null_device")
    assert ids == required
    # The stage is intentionally neither session-filtered nor deduplicated.
    assert connection.execute("select count(*) from staged where event_id = 'duplicate'").fetchone()[0] == 2
    assert connection.execute("select count(*) from staged where event_id = 'unknown_session'").fetchone()[0] == 1


def test_empty_run_produces_no_events(connection):
    connection.execute("delete from sessions")
    stage, base = render_macros(connection)
    connection.execute("create table staged as " + stage("events", "sessions", "load_tstamp"))
    assert connection.execute("select count(*) from staged").fetchone()[0] == 0
    assert connection.execute(base_sql(base, "staged", "load_tstamp", [], False)).fetchall() == []


def test_stage_has_literal_bounds_and_no_join_or_window(connection):
    stage, _ = render_macros(connection)
    query = sqlglot.parse_one(stage("events", "sessions", "load_tstamp", ["keep"]), read="snowflake")
    assert list(query.find_all(exp.Join)) == []
    assert list(query.find_all(exp.Window)) == []
    assert list(query.find_all(exp.Subquery)) == []
    predicates = list(query.find_all(exp.GTE)) + list(query.find_all(exp.LTE))
    assert len(predicates) == 2
    assert all(predicate.this.name == "load_tstamp" for predicate in predicates)
    assert all(isinstance(predicate.expression, exp.Cast) for predicate in predicates)


def test_lake_loader_projection_preserves_names_and_casts_entities(connection):
    columns = [SimpleNamespace(name=name) for name in [
        "EVENT_ID", "LOAD_TSTAMP", "CONTEXTS_EXAMPLE_1", "UNSTRUCT_EVENT_EXAMPLE_1", "custom_field",
    ]]
    stage, _ = render_macros(connection, lake=True, columns=columns)
    query = sqlglot.parse_one(stage("events", "sessions", "load_tstamp"), read="snowflake")
    assert [column.alias_or_name for column in query.expressions] == [column.name for column in columns]
    assert query.expressions[2].this.to.this == exp.DataType.Type.ARRAY
    assert query.expressions[3].this.to.this == exp.DataType.Type.OBJECT
    assert isinstance(query.expressions[1], exp.Column)  # Never cast the partition column.


def test_parse_does_not_introspect_lake_source(connection):
    stage, _ = render_macros(connection, lake=True, execute=False)
    assert "e.*" in stage("events", "sessions", "load_tstamp")


def test_other_warehouses_reject_staging():
    def compiler_error(message):
        raise ValueError(message)

    env = Environment(undefined=StrictUndefined, extensions=["jinja2.ext.do"])
    module = env.from_string((ROOT / "macros/config_check.sql").read_text()).make_module({
        "var": lambda name, default=None: name == "snowplow__snowflake_stage_events",
        "target": SimpleNamespace(type="postgres"),
        "exceptions": SimpleNamespace(raise_compiler_error=compiler_error),
    })
    with pytest.raises(ValueError, match="only supported on Snowflake"):
        module.default__config_check()


def test_native_comparison_resolves_fixture_without_package_scoped_vars():
    captured = {}

    def original_query(**kwargs):
        captured.update(kwargs)
        return "select * from fixture_events"

    fixture = SimpleNamespace(database="test_db", schema="fixture_schema", identifier="fixture_events")
    env = Environment(undefined=StrictUndefined)
    env.from_string((ROOT / "integration_tests/tests/test_snowflake_staged_events.sql").read_text()).render(
        config=lambda **kwargs: "",
        target=SimpleNamespace(type="snowflake"),
        var=lambda name, default=None: {
            "snowplow__snowflake_stage_events": True,
            "snowplow__session_timestamp": "load_tstamp",
        }.get(name, default),
        ref=lambda name: fixture if name == "snowplow_unified_events_stg" else name,
        snowplow_utils=SimpleNamespace(base_create_snowplow_events_this_run=original_query),
    )
    assert captured["snowplow_events_database"] == fixture.database
    assert captured["snowplow_events_schema"] == fixture.schema
    assert captured["snowplow_events_table"] == fixture.identifier
    assert captured["session_timestamp"] == "load_tstamp"
    assert captured["allow_null_dvce_tstamps"] is True
    assert [identifier["field"] for identifier in captured["session_identifiers"]] == ["sessionId", "domain_sessionid"]


@pytest.mark.parametrize("warehouse", ["snowflake", "postgres", "redshift", "bigquery", "databricks", "spark"])
@pytest.mark.parametrize("custom_source", [False, True])
@pytest.mark.parametrize("stage_enabled", [False, True])
def test_base_source_routing_is_snowflake_opt_in_only(warehouse, custom_source, stage_enabled):
    """Render the real model up to its Utils call without any warehouse APIs.

    Other targets must retain their original source arguments even before the
    config hook rejects an unsupported staging flag. Disabled staging must not
    require a relation lookup or introduce a dependency on the staged model.
    """
    class CapturedQuery(Exception):
        pass

    captured, refs = {}, []
    staged_source = SimpleNamespace(database="stage_db", schema="scratch", identifier="staged_events")

    def capture_query(**kwargs):
        captured.update(kwargs)
        raise CapturedQuery

    def ref(name):
        refs.append(name)
        return staged_source

    variables = {
        "snowplow__snowflake_stage_events": stage_enabled,
        "snowplow__enable_web": False,
        "snowplow__enable_mobile": False,
    }
    if custom_source:
        variables.update({
            "snowplow__database": "raw_db",
            "snowplow__atomic_schema": "custom_atomic",
            "snowplow__events_table": "custom_events",
            "snowplow__databricks_catalog": "custom_catalog",
        })
    env = Environment(undefined=StrictUndefined, extensions=["jinja2.ext.do"])
    with pytest.raises(CapturedQuery):
        env.from_string((ROOT / "models/base/scratch/snowplow_unified_base_events_this_run.sql").read_text()).render(
            config=lambda **kwargs: "",
            var=lambda name, default=None: variables.get(name, default),
            target=SimpleNamespace(type=warehouse, database="target_db"),
            ref=ref,
            session_identifiers=lambda: [],
            snowplow_utils=SimpleNamespace(base_create_snowplow_events_this_run=capture_query),
        )
    actual = tuple(captured[key] for key in ["snowplow_events_database", "snowplow_events_schema", "snowplow_events_table"])
    if warehouse == "snowflake" and stage_enabled:
        assert actual == ("stage_db", "scratch", "staged_events")
        assert refs == ["snowplow_unified_base_events_staged"]
    else:
        schema = "custom_atomic" if custom_source else "atomic"
        database = "raw_db" if custom_source else "target_db"
        if warehouse == "databricks":
            database = "custom_catalog" if custom_source else "hive_metastore"
        elif warehouse == "spark":
            database = schema
        assert actual == (database, schema, "custom_events" if custom_source else "events")
        assert refs == []
