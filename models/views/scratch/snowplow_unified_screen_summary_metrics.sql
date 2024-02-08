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

with prep as (
  select
    ev.view_id
    , ev.session_identifier

    , round(cast(max(ev.screen_summary__foreground_sec) as {{ dbt.type_numeric() }}), 2) as foreground_sec
    , round(cast(max(ev.screen_summary__background_sec) as {{ dbt.type_numeric() }}), 2) as background_sec

    , max(ev.screen_summary__last_item_index) as last_item_index
    , max(ev.screen_summary__items_count) as items_count

    , min(ev.screen_summary__min_x_offset) as min_x_offset
    , min(ev.screen_summary__min_y_offset) as min_y_offset

    , max(ev.screen_summary__max_x_offset) as max_x_offset
    , max(ev.screen_summary__max_y_offset) as max_y_offset

    , max(ev.screen_summary__content_width) as content_width
    , max(ev.screen_summary__content_height) as content_height

  from {{ ref('snowplow_unified_events_this_run') }} as ev

  where ev.view_id is not null
    and ev.platform <> 'web'
    and ev.event_name in ('screen_end', 'application_background', 'application_foreground')

  group by 1, 2
)

select *

  , case
    when max_x_offset is not null and content_width is not null and content_width > 0 then
      cast(round(100.0 * cast(max_x_offset as {{ dbt.type_float() }}) / cast(content_width as {{ dbt.type_float() }})) as {{ dbt.type_float() }})
    else null
  end as horizontal_percentage_scrolled

  , case
    when max_y_offset is not null and content_height is not null and content_height > 0 then
      cast(round(100.0 * cast(max_y_offset as {{ dbt.type_float() }}) / cast(content_height as {{ dbt.type_float() }})) as {{ dbt.type_float() }})
    else null
  end as vertical_percentage_scrolled

  , case
    when last_item_index is not null and items_count is not null and items_count > 0 then
      cast(round(100.0 * (cast(last_item_index as {{ dbt.type_float() }}) + 1) / cast(items_count as {{ dbt.type_float() }})) as {{ dbt.type_float() }})
    else null
  end as list_items_percentage_scrolled

from prep
