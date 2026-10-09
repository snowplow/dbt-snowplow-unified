"""Read-only boundary regression for fix 2267a2e, without dbt installed."""
import json
import os
from pathlib import Path
from databricks import sql

statement = Path(__file__).with_suffix('.sql').read_text()
with sql.connect(server_hostname=os.environ['DATABRICKS_TEST_HOST'],
                 http_path=os.environ['DATABRICKS_TEST_HTTP_PATH'],
                 access_token=os.environ['DATABRICKS_TEST_TOKEN']) as conn:
    with conn.cursor() as cursor:
        cursor.execute(statement)
        columns = [c[0] for c in cursor.description]
        rows = [dict(zip(columns, row)) for row in cursor.fetchall()]
payload = json.dumps({'sql': statement, 'results': rows}, default=str, indent=2)
Path('cwv-numeric-probe.json').write_text(payload)
print(payload)

if rows:
    raise SystemExit(f"Native percentile regression failed: {len(rows)} mismatched cases")
print("All 11 native percentile boundary cases pass at p75 and p95.")
