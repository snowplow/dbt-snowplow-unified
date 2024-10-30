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

  echo "Snowplow unified integration tests: Execute models (all contexts except for cwv) - run 1/4"
  eval "dbt run --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 243, snowplow__enable_cwv: false}' --target $db" || exit 1;

  for i in {2..4}
  do
    echo "Snowplow unified integration tests: Execute models (all contexts except for cwv) - run $i/4"
    eval "dbt run --vars '{snowplow__enable_cwv: false}' --target $db" || exit 1;
  done

  echo "Snowplow unified integration tests: Test models"
  eval "dbt test --exclude snowplow_unified_web_vital_measurements snowplow_unified_web_vital_measurements_actual snowplow_unified_web_vital_events_this_run snowplow_unified_views_mobile_screen_engagement_actual test_name:not_null --store-failures --target $db" || exit 1;

done