{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
  config(
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt')),
    enabled=var("snowplow__enable_screen_summary_context", false)
  )
}}

with by_views as (
  select
    ev.view_id
    , ev.session_identifier
    , max(ev.screen_summary__foreground_sec) as foreground_sec

  from {{ ref('snowplow_unified_events_this_run') }} as ev

  where ev.view_id is not null
    and ev.platform <> 'web'
    and ev.event_name in ('screen_end', 'application_background', 'application_foreground')

  group by 1, 2
)

, by_sessions as (
  select
    session_identifier
    , cast(round(sum(foreground_sec)) as {{ dbt.type_int() }}) as foreground_sec

  from by_views

  group by 1
)

select *

from by_sessions
