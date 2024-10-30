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

  echo "Snowplow unified integration tests: Late enabled contexts"
  eval "dbt run --full-refresh --select +test_late_enabled_contexts snowplow_unified_integration_tests.source --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 220, snowplow__enable_cwv: false, snowplow__enable_mobile_context: false, snowplow__enable_geolocation_context: false, snowplow__enable_application_context: false, snowplow__enable_screen_context: false, snowplow__enable_app_errors: false, snowplow__enable_deep_link_context: false, snowplow__enable_cwv: false, snowplow__enable_iab: false, snowplow__enable_ua: false, snowplow__enable_browser_context: false, snowplow__enable_consent: false}' --target $db" || exit 1;

  echo "Snowplow unified integration tests: Late enabled contexts test passed"
  eval "dbt run --select +test_late_enabled_contexts run --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 250, snowplow__enable_cwv: false}' --target $db" || exit 1;

done