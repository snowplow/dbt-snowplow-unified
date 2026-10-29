#!/usr/bin/env python3
"""Exercise the published Snowflake migration in an isolated CI dbt schema.

Run from Agent Analytics' integration_tests directory after `dbt deps`:
    MIGRATION_GUIDE=/path/to/migration-guide.md python /path/to/this_script.py

Authentication stays inside dbt's existing profile. This temporary diagnostic
does not belong to the package and does not change its fixtures or expectations.
"""

from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys


TARGET = "snowflake"
SOURCE_MODEL = "snowplow_agent_analytics_events_stg"
CONTEXT = "contexts_com_snowplowanalytics_snowplow_utm_referrer_1"
BASE_PLACEHOLDER = "ANALYTICS.AGENT_ANALYTICS.BASE_EVENTS"
RESULT_MARKER = "AGENT_MIGRATION_RESULT="
COLUMNS = [
    "event_id", "event_fingerprint", "app_id", "collector_tstamp",
    "derived_tstamp", "load_tstamp", "load_tstamp_date", "domain_sessionid",
    "page_urlhost", "page_urlpath", "refr_source", "refr_medium", "utm_source",
    "utm_medium", "is_bot", "raw_source_channel", "agent_name", "agent_operator",
    "agent_purpose",
]
NEW_COLUMNS = {"utm_source", "utm_medium", "load_tstamp_date"}
MACRO_PATH = Path("macros/ci_validate_documented_migration.sql")
MACROS = r"""
{% macro ci_migration_sql(sql, fetch=false) %}
  {% set result = run_query(sql) %}
  {% set rows = [] %}
  {% if fetch and result is not none %}
    {% for row in result.rows %}
      {% set record = {} %}
      {% for column in result.column_names %}
        {% set value = row[loop.index0] %}
        {% do record.update({column | lower: none if value is none else value | string}) %}
      {% endfor %}
      {% do rows.append(record) %}
    {% endfor %}
  {% endif %}
  {% do log('AGENT_MIGRATION_RESULT=' ~ (rows | tojson), info=true) %}
{% endmacro %}

{% macro ci_migration_relations() %}
  {% set relations = {
    'base': ref('base_events') | string,
    'source': ref('snowplow_agent_analytics_events_stg') | string,
    'manifest': ref('incremental_manifest') | string,
    'lookup': ref('int_agent_source_lookup') | string
  } %}
  {% do log('AGENT_MIGRATION_RESULT=' ~ (relations | tojson), info=true) %}
{% endmacro %}
"""


def check(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def dbt(*args: str, capture: bool = False, expect_failure: str | None = None):
    command = ["dbt", "--no-use-colors", *args, "--target", TARGET]
    if capture or expect_failure:
        result = subprocess.run(command, text=True, stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, check=False)
        if expect_failure:
            check(result.returncode != 0, "Legacy schema unexpectedly passed compilation")
            check(expect_failure in result.stdout,
                  "Legacy compilation failed for a reason other than the migration guard")
            return result.stdout
        # SQL results stay private to the runner; only aggregate assertions are logged.
        if result.returncode:
            # dbt's normal error output contains the failing query, never profile secrets.
            sys.stderr.write(result.stdout)
            raise RuntimeError(f"dbt {args[0]} failed with exit code {result.returncode}")
        for line in reversed(result.stdout.splitlines()):
            if RESULT_MARKER in line:
                return json.loads(line.split(RESULT_MARKER, 1)[1])
        raise RuntimeError(f"dbt {args[0]} did not return the diagnostic result")
    subprocess.run(command, check=True)


def sql(query: str, *, fetch: bool = False):
    return dbt("run-operation", "ci_migration_sql", "--args",
               json.dumps({"sql": query, "fetch": fetch}), capture=True)


def scalar(query: str, key: str) -> int:
    rows = sql(query, fetch=True)
    check(len(rows) == 1 and key in rows[0], f"Missing aggregate {key}")
    return int(rows[0][key])


def quote(identifier: str) -> str:
    return '"' + identifier.replace('"', '""') + '"'


def sibling(relation: str, identifier: str) -> str:
    return relation.rsplit(".", 1)[0] + "." + quote(identifier)


def equal_rows(actual: str, expected: str, columns: str = "*") -> None:
    result = sql(f"""
        select
          (select count(*) from (
            select {columns} from {actual}
            minus select {columns} from {expected}
          )) as unexpected,
          (select count(*) from (
            select {columns} from {expected}
            minus select {columns} from {actual}
          )) as missing,
          (select count(*) from {actual}) as actual_count,
          (select count(*) from {expected}) as expected_count
    """, fetch=True)[0]
    check(int(result["unexpected"]) == int(result["missing"]) == 0,
          "Bidirectional row comparison failed")
    check(result["actual_count"] == result["expected_count"], "Row counts changed")


def grants(relation: str):
    return sorted(
        (row["privilege"], row["granted_to"], row["grantee_name"], row["grant_option"])
        for row in sql(f"show grants on table {relation}", fetch=True)
    )


def assert_schema(relation: str) -> None:
    description = sql(f"describe table {relation}", fetch=True)
    columns = [row for row in description if row.get("kind", "COLUMN") == "COLUMN"]
    check([row["name"].lower() for row in columns] == COLUMNS,
          "Migrated schema does not have exactly the 19 projected columns in order")
    types = {row["name"].lower(): row["type"].upper() for row in columns}
    check(types["load_tstamp_date"] == "DATE", "Load date is not DATE")
    for name in ("utm_source", "utm_medium"):
        check(types[name].startswith(("VARCHAR", "TEXT")), f"{name} is not a string")


class Guide:
    """Fail closed if the document changes structure instead of silently skipping SQL."""

    def __init__(self, path: Path):
        source = path.read_text()
        self.sha256 = hashlib.sha256(source.encode()).hexdigest()
        blocks = re.findall(r"```sql\s*\n(.*?)```", source, re.DOTALL)
        checks = {
            "preflight": lambda text: "get_ddl(" in text.lower(),
            "backup": lambda text: text.lower().startswith("create transient table "),
            "migrate": lambda text: "copy grants as" in text.lower(),
            "counts": lambda text: "as table_version" in text.lower(),
            "values": lambda text: "missing_migrated_events" in text.lower(),
            "inspect": lambda text: text.lower().startswith("describe table "),
            "rollback": lambda text: text.lower().startswith("create or replace")
            and "\nclone " in text.lower(),
        }
        self.blocks = {}
        for name, predicate in checks.items():
            matches = [block.strip() for block in blocks if predicate(block.strip())]
            check(len(matches) == 1, f"Expected exactly one guide SQL block: {name}")
            self.blocks[name] = matches[0]
        check(len(blocks) == len(checks), "An untested SQL block was added to the guide")
        names = set(re.findall(re.escape(BASE_PLACEHOLDER) + r"_BACKUP_[0-9_]+", source))
        check(len(names) == 1, "Guide must use one consistent backup placeholder")
        self.backup_placeholder = names.pop()

    def run(self, name: str, relation: str, backup: str):
        text = self.blocks[name].replace(self.backup_placeholder, backup)
        text = text.replace(BASE_PLACEHOLDER, relation)
        # These reviewed SQL blocks contain no semicolons inside literals.
        statements = [part.strip() for part in re.split(r";\s*(?:\n|$)", text) if part.strip()]
        results = [sql(statement, fetch=name in {"counts", "values"}) for statement in statements]
        if name == "counts":
            check(len(results) == 1 and len(results[0]) == 2, "Unexpected count query shape")
            counts = results[0]
            check(counts[0]["row_count"] == counts[1]["row_count"], "Guide row counts differ")
            check(all(row["row_count"] == row["distinct_event_ids"] for row in counts),
                  "Migration changed event ID uniqueness")
        elif name == "values":
            check(len(results) == 1 and len(results[0]) == 1, "Unexpected value query shape")
            check(all(int(value) == 0 for value in results[0][0].values()),
                  "The guide's value comparisons reported mismatches")


def edge_cases(guide: Guide, legacy_backup: str, base: str) -> None:
    scratch = sibling(base, "CI_MIGRATION_ENTITY_CASES")
    backup = sibling(base, "CI_MIGRATION_ENTITY_CASES_BACKUP")
    expected = sibling(base, "CI_MIGRATION_ENTITY_CASES_EXPECTED")
    sql(f"""
      create transient table {scratch} as
      select b.* exclude(event_id, {CONTEXT}),
             'migration_case_' || cases.case_name as event_id,
             parse_json(cases.entity_json) as {CONTEXT}
      from (select * from {legacy_backup} order by event_id limit 1) b
      cross join (
        select column1::varchar as case_name, column2::varchar as entity_json
        from values
          ('sql_null', null),
          ('empty_array', '[]'),
          ('missing_fields', '[{{}}]'),
          ('multi_element', '[{{"source":"first_source","medium":"first_medium"}},{{"source":"second_source","medium":"second_medium"}}]')
      ) cases
    """)
    check(scalar(f"select count(*) as n from {scratch}", "n") == 4,
          "Entity edge-case fixture is empty or incomplete")
    role = sql("select current_role() as role", fetch=True)[0]["role"]
    check(role.upper() != "PUBLIC", "Do not grant test access to PUBLIC")
    # The same test role receives SELECT on its isolated scratch table only.
    sql(f"grant select on table {scratch} to role {quote(role)}")
    original_grants = grants(scratch)
    check(any(row[0] == "SELECT" for row in original_grants), "COPY GRANTS test lacks SELECT")
    guide.run("backup", scratch, backup)
    expressions = []
    for column in COLUMNS:
        if column == "load_tstamp_date":
            expressions.append("cast(load_tstamp as date) as load_tstamp_date")
        elif column in {"utm_source", "utm_medium"}:
            value = "first_source" if column == "utm_source" else "first_medium"
            expressions.append(
                f"case when event_id = 'migration_case_multi_element' "
                f"then '{value}' else null end::varchar as {column}"
            )
        else:
            expressions.append(column)
    sql(f"create transient table {expected} as select {', '.join(expressions)} from {backup}")
    guide.run("migrate", scratch, backup)
    guide.run("counts", scratch, backup)
    guide.run("values", scratch, backup)
    assert_schema(scratch)
    equal_rows(scratch, expected, ", ".join(COLUMNS))
    check(grants(scratch) == original_grants, "COPY GRANTS lost scratch-table privileges")
    guide.run("rollback", scratch, backup)
    equal_rows(scratch, backup)
    check(grants(scratch) == original_grants, "Rollback lost scratch-table privileges")
    guide.run("migrate", scratch, backup)
    equal_rows(scratch, expected, ", ".join(COLUMNS))
    print("PASS: NULL/empty/missing/multiple entities, explicit grants, rollback and retry", flush=True)


def main() -> None:
    check(Path("dbt_project.yml").is_file() and Path("models/source/snowflake").is_dir(),
          "Run this script from Agent Analytics integration_tests")
    suffix = os.environ.get("SCHEMA_SUFFIX", "")
    check(suffix.startswith("migration_"), "SCHEMA_SUFFIX must identify an isolated migration_ CI schema")
    guide = Guide(Path(os.environ["MIGRATION_GUIDE"]))
    check(not MACRO_PATH.exists(), "Refusing to overwrite an existing integration macro")
    MACRO_PATH.write_text(MACROS)
    try:
        print(f"Validating exact migration guide SHA256 {guide.sha256}", flush=True)
        dbt("seed", "--full-refresh")
        dbt("run", "--select", SOURCE_MODEL)
        dbt("run", "--full-refresh", "--exclude", SOURCE_MODEL)
        relations = dbt("run-operation", "ci_migration_relations", capture=True)
        check(all(suffix.lower() in relation.lower() for relation in relations.values()),
              "dbt resolved a relation outside the isolated test schema")
        base, source = relations["base"], relations["source"]
        manifest, lookup = relations["manifest"], relations["lookup"]
        expected = sibling(base, "CI_MIGRATION_SCALAR_EXPECTED")
        manifest_before = sibling(base, "CI_MIGRATION_MANIFEST_BEFORE")
        lookup_before = sibling(base, "CI_MIGRATION_LOOKUP_BEFORE")
        backup = sibling(base, "CI_MIGRATION_LEGACY_BACKUP")
        for clone, original in ((expected, base), (manifest_before, manifest), (lookup_before, lookup)):
            sql(f"create transient table {clone} clone {original}")
        first_count = scalar(f"select count(*) as n from {base}", "n")
        check(first_count > 0, "First-batch fixture is empty")
        check(scalar(f"select count(*) as n from {manifest}", "n") > 0, "Manifest fixture is empty")
        check(scalar(f"select count(*) as n from {lookup}", "n") > 0, "Lookup fixture is empty")
        original_grants = grants(base)
        # The source deliberately contains repeated event IDs at different load times.
        # Match the specific retained raw row instead of multiplying those duplicates.
        sql(f"""
          create or replace transient table {base} copy grants as
          select b.* exclude(utm_source, utm_medium, load_tstamp_date), s.{CONTEXT}
          from {expected} b
          join (
            select event_id, load_tstamp, {CONTEXT}
            from {source}
            qualify row_number() over (
              partition by event_id, load_tstamp order by collector_tstamp
            ) = 1
          ) s on b.event_id = s.event_id and b.load_tstamp = s.load_tstamp
        """)
        equal_rows(base, expected, ", ".join(column for column in COLUMNS if column not in NEW_COLUMNS))
        dbt("compile", "--select", "base_events", "--no-partial-parse",
            expect_failure="Agent Analytics base_events needs an upgrade")
        print("PASS: legacy schema is rejected by the migration guard", flush=True)
        for operation in ("preflight", "backup", "migrate", "counts", "values", "inspect"):
            guide.run(operation, base, backup)
        assert_schema(base)
        equal_rows(base, expected, ", ".join(COLUMNS))
        equal_rows(manifest, manifest_before)
        equal_rows(lookup, lookup_before)
        check(grants(base) == original_grants, "Base-table grants changed")
        print(f"PASS: exact guide preserves {first_count} first-batch rows, all 19 values, grants and state", flush=True)
        edge_cases(guide, backup, base)
        for batch in range(2, 5):
            print(f"Continuing incremental batch {batch}/4 without full refresh", flush=True)
            dbt("run", "--exclude", SOURCE_MODEL)
        dbt("test")
        tests = json.loads(Path("target/run_results.json").read_text())["results"]
        data_tests = [test for test in tests if test["unique_id"].startswith("test.")]
        check(len(data_tests) == 49, f"Expected 49 existing data tests, got {len(data_tests)}")
        check(all(test["status"] == "pass" for test in data_tests), "An existing data test did not pass")
        final_count = scalar(f"select count(*) as n from {base}", "n")
        check(final_count > first_count, "Incremental continuation added no events")
        advancement = scalar(f"""
          select case when (select min(last_success) from {manifest}) >
                           (select max(last_success) from {manifest_before})
                      then 1 else 0 end as advanced
        """, "advanced")
        check(advancement == 1, "Manifest did not advance beyond the pre-migration state")
        print(f"PASS: manifest advanced; base grew {first_count} -> {final_count}; all 49 data tests passed", flush=True)
        report = {
            "guide_sha256": guide.sha256, "first_batch_rows": first_count,
            "final_rows": final_count, "data_tests_passed": len(data_tests),
            "checks": ["legacy guard", "exact documented SQL", "19-column equality",
                       "null and empty entities", "first entity precedence", "grants",
                       "rollback and retry", "manifest and lookup retained",
                       "incremental continuation"],
        }
        Path("target/migration-validation.json").write_text(json.dumps(report, indent=2) + "\n")
    finally:
        MACRO_PATH.unlink(missing_ok=True)


if __name__ == "__main__":
    main()
