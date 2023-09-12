{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    tags=["this_run"],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

{% set base_events_query = snowplow_utils.base_create_snowplow_events_this_run(
                                sessions_this_run_table='snowplow_unified_base_sessions_this_run',
                                session_identifiers= session_identifiers(),
                                session_sql=var('snowplow__session_sql', none),
                                session_timestamp=var('snowplow__session_timestamp', 'collector_tstamp'),
                                derived_tstamp_partitioned=var('snowplow__derived_tstamp_partitioned', true),
                                days_late_allowed=var('snowplow__days_late_allowed', 3),
                                max_session_days=var('snowplow__max_session_days', 3),
                                app_ids=var('snowplow__app_ids', []),
                                snowplow_events_database=var('snowplow__database', target.database) if target.type not in ['databricks', 'spark'] else var('snowplow__databricks_catalog', 'hive_metastore') if target.type in ['databricks'] else var('snowplow__atomic_schema', 'atomic'),
                                snowplow_events_schema=var('snowplow__atomic_schema', 'atomic'),
                                snowplow_events_table=var('snowplow__events_table', 'events')) %}

with base_query as (
  {{ base_events_query }}
)

select
  *,

  -- extract commonly used contexts / sdes (prefixed)
  {{ get_web_page_context_fields() }},
  {{ get_iab_context_fields() }},
  {{ get_ua_context_fields() }},
  {{ get_yauaa_context_fields() }},
  {{ get_browser_context_fields() }},
  {{ get_screen_view_event_fields() }},
  {{ get_session_context_fields() }},
  {{ get_mobile_context_fields() }},
  {{ get_geo_context_fields() }},
  {{ get_app_context_fields() }},
  {{ get_screen_context_fields() }},
  {{ get_deep_link_context_fields() }}

from base_query a
