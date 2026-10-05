#!/bin/bash
set -euo pipefail

# Run after the standard integration suite has seeded the source data.
for timestamp in collector_tstamp load_tstamp; do
  test_vars="{snowplow__snowflake_stage_events: true, snowplow__session_timestamp: $timestamp, snowplow__allow_refresh: true, snowplow__enable_cwv: false, snowplow__enable_screen_summary_context: false, snowplow__backfill_limit_days: 9999}"
  dbt run --target snowflake --full-refresh --vars "$test_vars"
  dbt test --target snowflake --select test_snowflake_staged_events --vars "$test_vars"
  dbt run --target snowflake --vars "$test_vars"
  dbt test --target snowflake --select test_snowflake_staged_events --vars "$test_vars"
done
