#!/bin/bash

# Expected input:
# -d (database) target database for dbt

while getopts 'd:' opt
do
  case $opt in
    d) DATABASE=$OPTARG
  esac
done

declare -a SUPPORTED_DATABASES=("bigquery" "postgres" "databricks" "redshift" "snowflake")

# set to lower case
DATABASE="$(echo $DATABASE | tr '[:upper:]' '[:lower:]')"

if [[ $DATABASE == "all" ]]; then
  DATABASES=( "${SUPPORTED_DATABASES[@]}" )
else
  DATABASES=$DATABASE
fi

for db in ${DATABASES[@]}; do

  echo "Snowplow unified integration tests: Seeding data"

  eval "dbt seed --full-refresh --target $db" || exit 1;

  echo "Snowplow unified integration tests: Execute models (no contexts, no conversions)"

  eval "dbt run --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 9999, snowplow__enable_cwv: false}' --select +snowplow_unified_views  snowplow_unified_integration_tests.source --target $db" || exit 1;

done
