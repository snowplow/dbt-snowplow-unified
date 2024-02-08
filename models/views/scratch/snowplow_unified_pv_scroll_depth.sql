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

with prep as (
  select
    ev.view_id,
    ev.session_identifier,

    max(ev.doc_width) as doc_width,
    max(ev.doc_height) as doc_height,

    max(ev.br_viewwidth) as br_viewwidth,
    max(ev.br_viewheight) as br_viewheight,

    -- coalesce replaces null with 0 (because the page view event does send an offset)
    -- greatest prevents outliers (negative offsets)
    -- least also prevents outliers (offsets greater than the docwidth or docheight)

    {# coalesce with max value from the screen_summary event – hmin – min_x_offset, hmax – max_x_offset #}
    least(greatest(min(coalesce(ev.pp_xoffset_min, 0)), 0), max(ev.doc_width)) as hmin, -- should be zero
    least(greatest(max(coalesce(ev.pp_xoffset_max, 0)), 0), max(ev.doc_width)) as hmax,

    {# coalesce with max value from the screen_summary event – vmin – min_y_offset, vmax – max_y_offset #}
    least(greatest(min(coalesce(ev.pp_yoffset_min, 0)), 0), max(ev.doc_height)) as vmin, -- should be zero (edge case: not zero because the pv event is missing)
    least(greatest(max(coalesce(ev.pp_yoffset_max, 0)), 0), max(ev.doc_height)) as vmax

  from {{ ref('snowplow_unified_events_this_run') }} as ev

  where ev.event_name in ('page_view', 'page_ping')
    and ev.view_id is not null
    and ev.doc_height > 0 -- exclude problematic (but rare) edge case
    and ev.doc_width > 0 -- exclude problematic (but rare) edge case

  group by 1, 2
)

select
  view_id,
  session_identifier,

  doc_width,
  doc_height,

  br_viewwidth,
  br_viewheight,

  hmin,
  hmax,
  vmin,
  vmax,

  cast(round(100*(greatest(hmin, 0)/cast(doc_width as {{ dbt.type_float() }}))) as {{ dbt.type_float() }}) as relative_hmin, -- brackets matter: because hmin is of type int, we need to divide before we multiply by 100 or we risk an overflow
  cast(round(100*(least(hmax + br_viewwidth, doc_width)/cast(doc_width as {{ dbt.type_float() }}))) as {{ dbt.type_float() }}) as relative_hmax,
  cast(round(100*(greatest(vmin, 0)/cast(doc_height as {{ dbt.type_float() }}))) as {{ dbt.type_float() }}) as relative_vmin,
  cast(round(100*(least(vmax + br_viewheight, doc_height)/cast(doc_height as {{ dbt.type_float() }}))) as {{ dbt.type_float() }}) as relative_vmax, -- not zero when a user hasn't scrolled because it includes the non-zero viewheight

  cast(null as {{ dbt.type_int() }}) as last_list_item_index,
  cast(null as {{ dbt.type_int() }}) as list_items_count,
  cast(null as {{ dbt.type_int() }}) as list_items_percentage_scrolled

from prep

{% if var('snowplow__enable_screen_summary_context', false) %}
union all

select
  t.view_id,
  t.session_identifier,

  t.content_width as doc_width,
  t.content_height as doc_height,

  cast(null as {{ dbt.type_int() }}) as br_viewwidth,
  cast(null as {{ dbt.type_int() }}) as br_viewheight,

  t.min_x_offset as hmin,
  t.max_x_offset as hmax,
  t.min_y_offset as vmin,
  t.max_y_offset as vmax,

  cast(null as {{ dbt.type_float() }}) as relative_hmin,
  t.horizontal_percentage_scrolled as relative_hmax,
  cast(null as {{ dbt.type_float() }}) as relative_vmin,
  t.vertical_percentage_scrolled as relative_vmax,

  t.last_item_index as last_list_item_index,
  t.items_count as list_items_count,
  t.list_items_percentage_scrolled

from {{ ref('snowplow_unified_screen_summary_metrics') }} as t

{% endif %}
