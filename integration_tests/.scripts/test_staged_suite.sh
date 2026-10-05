#!/bin/bash
set -euo pipefail

# The existing suite supplies --vars for each scenario. Set the package-scoped
# default in the test project so every scenario also exercises staging.
project_backup=$(mktemp)
cp dbt_project.yml "$project_backup"
restore_project() {
  cp "$project_backup" dbt_project.yml && rm -f "$project_backup"
}
trap restore_project EXIT

python3 - <<'PY'
from pathlib import Path
import yaml

path = Path('dbt_project.yml')
project = yaml.safe_load(path.read_text())
project['vars']['snowplow_unified']['snowplow__snowflake_stage_events'] = True
path.write_text(yaml.safe_dump(project, sort_keys=False))
PY

./.scripts/integration_test.sh -d snowflake
