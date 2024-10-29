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

  echo "Snowplow unified integration tests: Try run without data"
  eval "dbt run --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 1, snowplow__enable_cwv: false, snowplow__start_date: 2010-01-01}' --target $db" || exit 1;

  echo "Snowplow unified integration tests: Conversions"
  eval "dbt run --full-refresh --select +snowplow_unified_conversions snowplow_unified_integration_tests.source --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 220, snowplow__enable_cwv: false, snowplow__enable_conversions: true}' --target $db" || exit 1;

  echo "Snowplow unified integration tests: App errors module"
  eval "dbt run --full-refresh --select +snowplow_unified_app_errors snowplow_unified_integration_tests.source --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 220, snowplow__enable_cwv: false, snowplow__enable_app_errors: true}' --target $db" || exit 1;

done