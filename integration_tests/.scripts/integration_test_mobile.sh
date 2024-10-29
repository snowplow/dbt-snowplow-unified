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

  echo "Snowplow unified integration tests: Execute mobile (all mobile contexts)"
  eval "dbt run --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 9999, snowplow__enable_web: false, snowplow__enable_iab: false, snowplow__enable_ua: false, snowplow__enable_browser_context: false, snowplow__enable_consent: false, snowplow__enable_cwv: false}'  --select +snowplow_unified_users snowplow_unified_events_stg --target $db" || exit 1;

  echo "Snowplow unified integration tests: Test mobile screen engagement"
  eval "dbt run --select +snowplow_unified_views_mobile_screen_engagement_actual snowplow_unified_views_mobile_screen_engagement_expected_stg source --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__start_date: '2023-12-19', snowplow__backfill_limit_days: 50, snowplow__enable_cwv: false, snowplow__enable_screen_summary_context: true, snowplow__enable_ua: false, snowplow__enable_iab: false, snowplow__enable_web: false, snowplow__enable_browser_context: false, snowplow__enable_consent: false, snowplow__enable_yauaa: false, snowplow__enable_geolocation_context: false, snowplow__enable_deep_link_context: false, snowplow__enable_app_errors: false}' --target $db" || exit 1;

  eval "dbt test --select snowplow_unified_views_mobile_screen_engagement_actual --vars '{snowplow__enable_screen_summary_context: true, snowplow__enable_web: false, snowplow__enable_cwv: false, snowplow__enable_ua: false, snowplow__enable_iab: false, snowplow__enable_web: false, snowplow__enable_browser_context: false, snowplow__enable_consent: false, snowplow__enable_yauaa: false, snowplow__enable_geolocation_context: false, snowplow__enable_deep_link_context: false, snowplow__enable_app_errors: false}' --store-failures --target $db" || exit 1;
  echo "Snowplow unified integration tests: Mobile screen engagement tests passed"

done