{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
  config(
    enabled=var("snowplow__enable_screen_summary_context", false) | as_bool()
    )
}}

select
  view_id,
  session_identifier,
  user_identifier,
  engaged_time_in_s,
  absolute_time_in_s,
  horizontal_pixels_scrolled,
  vertical_pixels_scrolled,
  horizontal_percentage_scrolled,
  vertical_percentage_scrolled,
  last_list_item_index,
  list_items_count,
  list_items_percentage_scrolled

from {{ ref('snowplow_unified_views') }}

union all

select
  null as view_id,
  session_identifier,
  user_identifier,
  engaged_time_in_s,
  absolute_time_in_s,
  null as horizontal_pixels_scrolled,
  null as vertical_pixels_scrolled,
  null as horizontal_percentage_scrolled,
  null as vertical_percentage_scrolled,
  null as last_list_item_index,
  null as list_items_count,
  null as list_items_percentage_scrolled


from {{ ref('snowplow_unified_sessions') }}

union all

select
  null as view_id,
  null as session_identifier,
  user_identifier,
  engaged_time_in_s,
  absolute_time_in_s,
  null as horizontal_pixels_scrolled,
  null as vertical_pixels_scrolled,
  null as horizontal_percentage_scrolled,
  null as vertical_percentage_scrolled,
  null as last_list_item_index,
  null as list_items_count,
  null as list_items_percentage_scrolled


from {{ ref('snowplow_unified_users') }}
