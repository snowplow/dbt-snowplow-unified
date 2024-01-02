  {#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

Select
  ev.event_id as root_id,
  ev.collector_tstamp::timestamp as root_tstamp,

  (ev.contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0::json->0 ->>'foreground_sec')::float as foreground_sec,
  (ev.contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0::json->0 ->>'background_sec')::float as background_sec,

  (ev.contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0::json->0 ->>'last_item_index')::int as last_item_index,
  (ev.contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0::json->0 ->>'items_count')::int as items_count,

  (ev.contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0::json->0 ->>'max_x_offset')::int as max_x_offset,
  (ev.contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0::json->0 ->>'min_x_offset')::int as min_x_offset,

  (ev.contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0::json->0 ->>'max_y_offset')::int as max_y_offset,
  (ev.contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0::json->0 ->>'min_y_offset')::int as min_y_offset,

  (ev.contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0::json->0 ->>'content_height')::int as content_height,
  (ev.contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0::json->0 ->>'content_width')::int as content_width,

  'screen_summary' as schema_name

from {{ ref('snowplow_unified_screen_engagement_events') }} as ev
