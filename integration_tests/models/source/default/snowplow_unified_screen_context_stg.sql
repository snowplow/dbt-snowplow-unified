{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

with events as (
  select event_id, collector_tstamp, platform, contexts_com_snowplowanalytics_mobile_screen_1_0_0
  from {{ ref('snowplow_unified_events') }}
  union all
  select event_id, collector_tstamp, platform, contexts_com_snowplowanalytics_mobile_screen_1_0_0
  from {{ ref('snowplow_unified_screen_engagement_events') }}
)

select
  ev.event_id as root_id,
  ev.collector_tstamp::timestamp as root_tstamp,
  case when ev.platform = 'web' then null else
    {% if target.type == 'postgres' -%}
    (ev.contexts_com_snowplowanalytics_mobile_screen_1_0_0::json->0 ->>'id')
    {%- else -%}
    JSON_EXTRACT_PATH_TEXT(JSON_EXTRACT_ARRAY_ELEMENT_TEXT(contexts_com_snowplowanalytics_mobile_screen_1_0_0, 0), 'id')
    {%- endif %}
  end as id,
  case when ev.platform = 'web' then null else 'Add New Item' end as name,
  case when ev.platform = 'web' then null else 'na' end as activity,
  case when ev.platform = 'web' then null else 'na' end as type,
  case when ev.platform = 'web' then null else 'na' end as fragment,
  case when ev.platform = 'web' then null else 'na' end as top_view_controller,
  case when ev.platform = 'web' then null else 'na' end as view_controller,
  'screen_context' as schema_name

from events as ev
