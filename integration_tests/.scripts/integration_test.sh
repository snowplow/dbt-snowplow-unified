#!/bin/bash

# Expected input:
# -d (database) target database for dbt

while getopts 'd:' opt
do
  case $opt in
    d) DATABASE=$OPTARG
  esac
done

declare -a SUPPORTED_DATABASES=("bigquery" "postgres" "databricks" "redshift" "snowflake", "spark_iceberg")

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

  echo "Snowplow unified integration tests: Try run without data"
  eval "dbt run --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 1, snowplow__enable_cwv: false, snowplow__start_date: 2010-01-01}' --target $db" || exit 1;

  echo "Snowplow unified integration tests: Try run without data for browser_context_2 only enabled"
  eval "dbt run --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__enable_browser_context: false, snowplow__enable_browser_context_2:true, snowplow__backfill_limit_days: 1, snowplow__enable_cwv: false, snowplow__start_date: 2010-01-01}' --target $db" || exit 1;

  echo "Snowplow unified integration tests: Try run without data for browser_context_2 and browser_context enabled"
  eval "dbt run --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__enable_browser_context:true, snowplow__enable_browser_context_2:true, snowplow__backfill_limit_days: 1, snowplow__enable_cwv: false, snowplow__start_date: 2010-01-01}' --target $db" || exit 1;

  echo "Snowplow unified integration tests: Conversions"
  eval "dbt run --full-refresh --select +snowplow_unified_conversions snowplow_unified_integration_tests.source --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 220, snowplow__enable_cwv: false, snowplow__enable_conversions: true}' --target $db" || exit 1;

  echo "Snowplow unified integration tests: App errors module"
  eval "dbt run --full-refresh --select +snowplow_unified_app_errors snowplow_unified_integration_tests.source --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 220, snowplow__enable_cwv: false, snowplow__enable_app_errors: true}' --target $db" || exit 1;

  echo "Snowplow unified integration tests: Late enabled contexts"
  eval "dbt run --full-refresh --select +test_late_enabled_contexts snowplow_unified_integration_tests.source --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 220, snowplow__enable_cwv: false, snowplow__enable_mobile_context: false, snowplow__enable_geolocation_context: false, snowplow__enable_application_context: false, snowplow__enable_screen_context: false, snowplow__enable_app_errors: false, snowplow__enable_deep_link_context: false, snowplow__enable_cwv: false, snowplow__enable_iab: false, snowplow__enable_ua: false, snowplow__enable_browser_context: false, snowplow__enable_browser_context_2: false, snowplow__enable_consent: false}' --target $db" || exit 1;

  eval "dbt run --select +test_late_enabled_contexts run --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 250, snowplow__enable_cwv: false}' --target $db"
  echo "Snowplow unified integration tests: Late enabled contexts test passed"

  echo "Snowplow unified integration tests: Execute models (all contexts except for cwv) - run 1/4"
  eval "dbt run --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 243, snowplow__enable_cwv: false}' --target $db" || exit 1;

  for i in {2..4}
  do
    echo "Snowplow unified integration tests: Execute models (all contexts except for cwv) - run $i/4"
    eval "dbt run --vars '{snowplow__enable_cwv: false}' --target $db" || exit 1;
  done

  echo "Snowplow unified integration tests: Test models"

  eval "dbt test --exclude snowplow_unified_web_vital_measurements snowplow_unified_web_vital_measurements_actual snowplow_unified_web_vital_events_this_run snowplow_unified_views_mobile_screen_engagement_actual test_name:not_null --store-failures --target $db" || exit 1;

  echo "Snowplow unified integration tests: All non-CWV tests passed"
  
  echo "Snowplow unified integration tests - Core Web Vitals: Execute models"
  eval "dbt run --select +snowplow_unified_web_vital_measurements_actual snowplow_unified_web_vital_measurements_expected_stg source  --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__start_date: '2023-03-01', snowplow__backfill_limit_days: 50, snowplow__cwv_days_to_measure: 999, snowplow__enable_mobile: false, snowplow__enable_mobile_context: false, snowplow__enable_geolocation_context: false, snowplow__enable_application_context: false, snowplow__enable_screen_context: false, snowplow__enable_app_errors: false, snowplow__enable_deep_link_context: false, snowplow__enable_ua: false, snowplow__enable_browser_context: false, snowplow__enable_browser_context_2: false, snowplow__enable_consent: false}' --target $db" || exit 1;
  eval "dbt test --select snowplow_unified_web_vital_measurements_actual --store-failures --target $db" || exit 1;

  echo "Snowplow unified integration tests: Execute web (all web contexts except for cwv)"
  eval "dbt run --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 9999, snowplow__enable_mobile: false, snowplow__enable_mobile_context: false, snowplow__enable_geolocation_context: false, snowplow__enable_application_context: false, snowplow__enable_screen_context: false, snowplow__enable_app_errors: false, snowplow__enable_deep_link_context: false, snowplow__enable_cwv: false}'  --select +snowplow_unified_users snowplow_unified_events_stg --target $db" || exit 1;

  echo "Snowplow unified integration tests: Execute mobile (all mobile contexts)"
  eval "dbt run --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 9999, snowplow__enable_web: false, snowplow__enable_iab: false, snowplow__enable_ua: false, snowplow__enable_browser_context: false, snowplow__enable_browser_context_2: false, snowplow__enable_consent: false, snowplow__enable_cwv: false}'  --select +snowplow_unified_users snowplow_unified_events_stg --target $db" || exit 1;

  echo "Snowplow unified integration tests: All CWV tests passed"

  echo "Snowplow unified integration tests: Test mobile screen engagement"

  eval "dbt run --select +snowplow_unified_views_mobile_screen_engagement_actual snowplow_unified_views_mobile_screen_engagement_expected_stg source --full-refresh --vars '{snowplow__allow_refresh: true, snowplow__start_date: '2023-12-19', snowplow__backfill_limit_days: 50, snowplow__enable_cwv: false, snowplow__enable_screen_summary_context: true, snowplow__enable_ua: false, snowplow__enable_iab: false, snowplow__enable_web: false, snowplow__enable_browser_context: false, snowplow__enable_browser_context_2: false, snowplow__enable_consent: false, snowplow__enable_yauaa: false, snowplow__enable_geolocation_context: false, snowplow__enable_deep_link_context: false, snowplow__enable_app_errors: false}' --target $db" || exit 1;

  eval "dbt test --select snowplow_unified_views_mobile_screen_engagement_actual --vars '{snowplow__enable_screen_summary_context: true, snowplow__enable_web: false, snowplow__enable_cwv: false, snowplow__enable_ua: false, snowplow__enable_iab: false, snowplow__enable_browser_context: false, snowplow__enable_browser_context_2: false, snowplow__enable_consent: false, snowplow__enable_yauaa: false, snowplow__enable_geolocation_context: false, snowplow__enable_deep_link_context: false, snowplow__enable_app_errors: false}' --store-failures --target $db" || exit 1;

  echo "Snowplow unified integration tests: Mobile screen engagement tests passed"

done
