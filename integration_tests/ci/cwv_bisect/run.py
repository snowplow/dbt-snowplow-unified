"""Temporary reduced CWV reproduction; only repository fixture data is exported."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess

OUT = Path('cwv_diagnostics')
SCHEMA = os.environ['CWV_SCHEMA']
if not re.fullmatch(r'cwv_bisect_[0-9]+_[0-9]+_[a-z0-9_]+', SCHEMA):
    raise ValueError('Expected an isolated diagnostic schema')

CWV_VARS = {
    'snowplow__allow_refresh': True,
    'snowplow__start_date': '2023-03-01',
    'snowplow__backfill_limit_days': 50,
    'snowplow__cwv_days_to_measure': 99999,
    **{f'snowplow__enable_{flag}': False for flag in (
        'mobile', 'mobile_context', 'geolocation_context', 'application_context',
        'screen_context', 'app_errors', 'deep_link_context', 'ua',
        'browser_context', 'browser_context_2', 'consent',
    )},
}


def run_dbt(*args):
    subprocess.run(['dbt', *args, '--target', 'databricks'], check=True)


def run():
    # Match the package versions resolved by both historical CI runs.
    Path('../packages.yml').write_text('packages:\n  - package: snowplow/snowplow_utils\n    version: 1.0.1\n')
    Path('packages.yml').write_text('packages:\n  - local: ../\n  - package: dbt-labs/dbt_utils\n    version: 1.4.1\n')
    subprocess.run(['dbt', 'deps'], check=True)
    OUT.mkdir(exist_ok=True)
    (OUT / 'pip-freeze.txt').write_text(subprocess.check_output(['python', '-m', 'pip', 'freeze'], text=True))
    run_dbt('seed', '--full-refresh')
    # Preserve the pre-CWV manifest transition used in the reduced reproduction.
    run_dbt('run', '--full-refresh', '--vars', json.dumps({
        'snowplow__allow_refresh': True,
        'snowplow__backfill_limit_days': 243,
        'snowplow__enable_cwv': False,
    }))
    run_dbt('run', '--select', '+snowplow_unified_web_vital_measurements_actual',
            'snowplow_unified_web_vital_measurements_expected_stg', 'source',
            '--full-refresh', '--vars', json.dumps(CWV_VARS))
    run_dbt('test', '--select', 'snowplow_unified_web_vital_measurements_actual',
            '--vars', json.dumps({'store_failures': True}))


def connect():
    from databricks import sql
    return sql.connect(server_hostname=os.environ['DATABRICKS_TEST_HOST'],
                       http_path=os.environ['DATABRICKS_TEST_HTTP_PATH'],
                       access_token=os.environ['DATABRICKS_TEST_TOKEN'])


def collect():
    OUT.mkdir(exist_ok=True)
    # Export compiled SQL and compact results, never profiles or connection logs.
    manifest_path = Path('target/manifest.json')
    manifest = json.loads(manifest_path.read_text()) if manifest_path.exists() else {'nodes': {}}
    results_path = Path('target/run_results.json')
    if results_path.exists():
        results = json.loads(results_path.read_text())
        (OUT / 'results.json').write_text(json.dumps([
            {k: r.get(k) for k in ('unique_id', 'status', 'failures', 'execution_time')}
            for r in results['results']
        ], indent=2))
    for node in manifest['nodes'].values():
        if node.get('compiled_code') and 'web_vital' in node.get('name', ''):
            (OUT / (node['unique_id'] + '.sql')).write_text(node['compiled_code'])
    captured = {}
    with connect() as conn, conn.cursor() as cursor:
        def query(label, statement):
            try:
                cursor.execute(statement)
                columns = [c[0] for c in cursor.description]
                captured[label] = [dict(zip(columns, row)) for row in cursor.fetchall()]
            except Exception as error:
                captured[label] = {'error_type': type(error).__name__}

        query('engine', 'select version() as engine_version')
        query('runtime', 'select current_version() as runtime_version')
        for name in ('snowplow_unified_web_vital_measurements_actual',
                     'snowplow_unified_web_vital_measurements_expected_stg'):
            relation = f'`hive_metastore`.`{SCHEMA}_snplw_unified_int_tests`.`{name}`'
            query(name + '_types', f'describe {relation}')
        for node in manifest['nodes'].values():
            if (node.get('resource_type') == 'test'
                    and 'equality' in node.get('name', '')
                    and 'web_vital_measurements_actual' in node.get('name', '')):
                relation = node.get('relation_name')
                if relation and SCHEMA in relation:
                    query('mismatches', f'select * from {relation} limit 100')
    (OUT / 'values.json').write_text(json.dumps(captured, default=str, indent=2))
    print(json.dumps(captured, default=str, indent=2))


def cleanup():
    # Exact run-owned names only; never use the repository-wide CI cleanup macro.
    with connect() as conn, conn.cursor() as cursor:
        for suffix in ('', '_snplw_unified_int_tests', '_snowplow_manifest',
                       '_scratch', '_derived', '_dbt_test__audit'):
            cursor.execute(f'drop schema if exists `hive_metastore`.`{SCHEMA}{suffix}` cascade')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('action', choices=('run', 'collect', 'cleanup'))
    globals()[parser.parse_args().action]()
