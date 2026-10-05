{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{ config(
    enabled=target.type == 'snowflake' and var('snowplow__snowflake_stage_events', false),
    materialized='table',
    transient=true,
    tags=['this_run'],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
) }}

-- depends_on: {{ var('snowplow__events') }}

{% set events_source = api.Relation.create(
    database=var('snowplow__database', target.database),
    schema=var('snowplow__atomic_schema', 'atomic'),
    identifier=var('snowplow__events_table', 'events')
) %}

{{ snowplow_unified.snowflake_stage_events_query(
    events_source,
    ref('snowplow_unified_base_sessions_this_run'),
    var('snowplow__session_timestamp', 'collector_tstamp'),
    var('snowplow__app_id', [])
) }}
