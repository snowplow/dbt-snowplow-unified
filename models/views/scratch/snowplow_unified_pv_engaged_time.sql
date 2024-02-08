{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
  config(
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

-- the first page ping fires after the minimum visit length (n seconds), every subsequent page ping fires after every heartbeat length (n seconds)
-- there may be imperfectly timed pings and odd duplicates therefore the safest is to do a special calculation:
-- each pings' epoch timestamp is taken (n seconds) which are then divided by the heartbeat length, floored (to get precise heartbeat length separated intervals)
-- each distinct value means the user spent that * the heartbeat length on the website (minus the first, which needed the minimum visit lenght to fire)

{% set heartbeat_length = var("snowplow__heartbeat", 10) %}
{% set min_visit_length = var("snowplow__min_visit_length", 5) %}
{% set n_unique_pings = "count(distinct(floor(" ~ snowplow_utils.to_unixtstamp('ev.dvce_created_tstamp') ~ "/" ~ heartbeat_length ~ ")))" %}

select
  ev.view_id,
  ev.session_identifier,
  max(ev.derived_tstamp) as end_tstamp,
  ({{ heartbeat_length }} * ({{ n_unique_pings }} - 1)) + {{ min_visit_length }} as engaged_time_in_s,
  cast(null as {{ dbt.type_float() }}) as absolute_time_in_s

from {{ ref('snowplow_unified_events_this_run') }} as ev

where ev.event_name = 'page_ping'
and ev.view_id is not null

group by 1, 2

{% if var('snowplow__enable_screen_summary_context', false) %}
union all

select
  t.view_id,
  t.session_identifier,
  cast(null as {{ dbt.type_timestamp() }}) as end_tstamp,
  t.foreground_sec as engaged_time_in_s,
  t.foreground_sec + coalesce(t.background_sec, 0) as absolute_time_in_s

from {{ ref('snowplow_unified_screen_summary_metrics') }} as t
{% endif %}
