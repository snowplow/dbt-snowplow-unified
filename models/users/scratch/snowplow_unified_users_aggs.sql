{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
  config(
    partition_by = snowplow_utils.get_value_by_target_type(bigquery_val={
      "field": "start_tstamp",
      "data_type": "timestamp"
    }),
    cluster_by=snowplow_unified.get_cluster_by_values('users_aggs'),
    sort='user_identifier',
    dist='user_identifier',
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

select
  user_identifier
  -- time
  , user_start_tstamp as start_tstamp
  , user_end_tstamp as end_tstamp
  -- first/last session. Max to resolve edge case with multiple sessions with the same start/end tstamp
  , max(case when start_tstamp = user_start_tstamp then session_identifier end) as first_session_identifier
  , max(case when end_tstamp = user_end_tstamp then session_identifier end) as last_session_identifier
  -- engagement
  , sum(views) as views
  , count(distinct session_identifier) as sessions
  , count(distinct {{ dbt.date_trunc('day', 'start_tstamp') }}) as active_days

  {% if var('snowplow__enable_web') or var('snowplow__enable_screen_summary_context', false) %}
    , sum(engaged_time_in_s) as engaged_time_in_s
  {% endif %}

  , sum(absolute_time_in_s) as absolute_time_in_s

  {% if var('snowplow__enable_mobile') %}
    , sum(screen_names_viewed) as screen_names_viewed
  {% endif %}

  {% if var('snowplow__enable_app_errors') %}
    , sum(app_errors) as app_errors
    , sum(fatal_app_errors) as fatal_app_errors
  {% endif %}

  {% if var('snowplow__user_aggregations', []) %}
    {% for agg in var('snowplow__user_aggregations') %}
      , {{ snowplow_utils.parse_agg_dict(agg)}}
    {% endfor %}
  {% endif %}

  

from {{ ref('snowplow_unified_users_sessions_this_run') }}

group by 1,2,3
