{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}



select
    view_id,
    session_identifier,
    user_identifier,
    engaged_time_in_s,
    {% if target.type in ['bigquery'] %}
    -- BiqQuery calculates timestamp difference slightly differently
    coalesce(absolute_time_in_s_bigquery, absolute_time_in_s) as absolute_time_in_s,
    {% else %}
    absolute_time_in_s,
    {% endif %}
    horizontal_pixels_scrolled,
    vertical_pixels_scrolled,
    horizontal_percentage_scrolled,
    vertical_percentage_scrolled,
    last_list_item_index,
    list_items_count,
    list_items_percentage_scrolled

from {{ ref('snowplow_unified_views_mobile_screen_engagement_expected') }}
