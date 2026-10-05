{{ config(enabled=target.type == 'snowflake' and var('snowplow__snowflake_stage_events', false)) }}

{% if target.type == 'snowflake' and var('snowplow__snowflake_stage_events', false) %}
{# Compare the staged path with the unchanged Utils query against the test
   source. Include counts so a duplicate regression cannot pass set equality. #}
{% set events_source = ref('snowplow_unified_events_stg') %}
{# This test belongs to the integration project, so package-scoped variables
   and defaults are not visible here. Use the fixture's web/mobile identifiers
   and null-device setting explicitly, and resolve its source through ref. #}
with original as (
  {{ snowplow_utils.base_create_snowplow_events_this_run(
      sessions_this_run_table='snowplow_unified_base_sessions_this_run',
      session_identifiers=[
        {'schema': 'contexts_com_snowplowanalytics_snowplow_client_session_1', 'field': 'sessionId'},
        {'schema': 'atomic', 'field': 'domain_sessionid'}
      ],
      session_sql=var('snowplow__session_sql', none),
      session_timestamp=var('snowplow__session_timestamp', 'collector_tstamp'),
      days_late_allowed=var('snowplow__days_late_allowed', 3),
      max_session_days=var('snowplow__max_session_days', 3),
      app_ids=var('snowplow__app_id', []),
      snowplow_events_database=events_source.database,
      snowplow_events_schema=events_source.schema,
      snowplow_events_table=events_source.identifier,
      allow_null_dvce_tstamps=var('snowplow__allow_null_dvce_tstamps', true)
  ) }}
), original_counts as (
  select event_id, session_identifier, user_identifier, collector_tstamp, load_tstamp, count(*) as row_count
  from original
  group by 1, 2, 3, 4, 5
), staged_counts as (
  select event_id, session_identifier, user_identifier, collector_tstamp, load_tstamp, count(*) as row_count
  from {{ ref('snowplow_unified_base_events_this_run') }}
  group by 1, 2, 3, 4, 5
), missing as (
  select * from original_counts
  minus
  select * from staged_counts
), unexpected as (
  select * from staged_counts
  minus
  select * from original_counts
)
select 'Missing staged event' as failure_reason from missing
union all
select 'Unexpected staged event' as failure_reason from unexpected
union all
select 'No baseline events: comparison would be vacuous' as failure_reason
where not exists (select 1 from original_counts)
{% endif %}
