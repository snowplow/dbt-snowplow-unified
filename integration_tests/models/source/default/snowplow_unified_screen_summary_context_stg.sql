{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% set col = 'ev.contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0' %}

Select
  ev.event_id as root_id,
  ev.collector_tstamp::timestamp as root_tstamp,

  {% for (att, type) in [
    ('foreground_sec', 'float'),
    ('background_sec', 'float'),
    ('last_item_index', 'int'),
    ('items_count', 'int'),
    ('max_x_offset', 'int'),
    ('min_x_offset', 'int'),
    ('max_y_offset', 'int'),
    ('min_y_offset', 'int'),
    ('content_height', 'int'),
    ('content_width', 'int'),
  ] %}
    {% if target.type == 'postgres' -%}
      (
        {{ col }}::json->0 ->>'{{ att }}'
      )::{{ type}} as {{ att }},
    {%- else -%}
      case when {{ col }} like '%{{ att }}%' then
        JSON_EXTRACT_PATH_TEXT(
          JSON_EXTRACT_ARRAY_ELEMENT_TEXT(
            {{ col }},
            0
          ),
          '{{ att }}'
        )::{{ type }}
      end as {{ att }},
    {%- endif %}
  {% endfor %}

  'screen_summary' as schema_name

from {{ ref('snowplow_unified_screen_engagement_events') }} as ev
