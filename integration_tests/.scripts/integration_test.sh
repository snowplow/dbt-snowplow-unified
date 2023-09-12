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

  echo "Snowplow unified integration tests 1: Execute models (all contexts except for cwv)"

  eval "dbt run --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 9999, snowplow__enable_cwv: false}' --target $db" || exit 1;

  echo "Snowplow unified integration tests 2: Execute web (all web contexts except for cwv)"

  eval "dbt run --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 9999, snowplow__enable_mobile: false, snowplow__enable_mobile_context: false, snowplow__enable_geolocation_context: false, snowplow__enable_app_context: false, snowplow__enable_screen_context: false, snowplow__enable_app_error_event: false, snowplow__enable_deep_link_context: false, snowplow__enable_cwv: false}' --target $db" || exit 1;

  echo "Snowplow unified integration tests 3: Execute mobile (all mobile contexts)"

  eval "dbt run --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 9999, snowplow__enable_web: false, snowplow__enable_iab: false, snowplow__enable_ua: false, snowplow__enable_browser_context: false, snowplow__enable_consent: false, snowplow__enable_cwv: false}' --target $db" || exit 1;

done
