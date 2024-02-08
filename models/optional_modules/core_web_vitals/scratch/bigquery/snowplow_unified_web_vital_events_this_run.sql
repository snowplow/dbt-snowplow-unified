{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
  config(
    tags=["this_run"],
    enabled=var("snowplow__enable_cwv", false) and target.type == 'bigquery' | as_bool(),
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

with prep as (

  select
    e.event_id
    , e.event_name
    , e.app_id
    , e.platform
    , e.user_identifier
    , e.user_id
    , e.view_id
    , e.session_identifier
    , e.collector_tstamp
    , e.derived_tstamp
    , e.dvce_created_tstamp
    , e.load_tstamp
    , e.geo_country
    , e.page_url
    , e.page_title
    , e.useragent
    , lower(e.yauaa__device_class) as device_class
    , e.yauaa__agent_class as agent_class
    , e.yauaa__agent_name as agent_name
    , e.yauaa__agent_name_version as agent_name_version
    , e.yauaa__agent_name_version_major as agent_name_version_major
    , e.yauaa__agent_version as agent_version
    , e.yauaa__agent_version_major agent_version_major
    , e.yauaa__device_brand as device_brand
    , e.yauaa__device_name as device_name
    , e.yauaa__device_version as device_version
    , e.yauaa__layout_engine_class as layout_engine_class
    , e.yauaa__layout_engine_name as layout_engine_name
    , e.yauaa__layout_engine_name_version as layout_engine_name_version
    , e.yauaa__layout_engine_name_version_major as layout_engine_name_version_major
    , e.yauaa__layout_engine_version as layout_engine_version
    , e.yauaa__layout_engine_version_major as layout_engine_version_major
    , e.yauaa__operating_system_class as operating_system_class
    , e.yauaa__operating_system_name as operating_system_name
    , e.yauaa__operating_system_name_version as operating_system_name_version
    , e.yauaa__operating_system_version as operating_system_version
    , ceil(cast(cwv__lcp as decimal)) /1000 as lcp
    , ceil(cast(cwv__fcp as decimal)) /1000 as fcp
    , ceil(safe_cast(cwv__fid as decimal) * 1000) /1000 as fid
    , ceil(cast(cwv__cls as decimal) * 1000) /1000 as cls
    , ceil(cast(cwv__inp as decimal) * 1000) /1000 as inp
    , ceil(cast(cwv__ttfb as decimal) * 1000) /1000 as ttfb
    , e.cwv__navigation_type as navigation_type

  from {{ ref("snowplow_unified_events_this_run") }} as e

  where {{ snowplow_utils.is_run_with_new_events('snowplow_unified') }} --returns false if run doesn't contain new events.

  and event_name = 'web_vitals'

  and view_id is not null

  -- exclude bot traffic

  {% if var('snowplow__enable_iab', false) %}
    and not {{ snowplow_utils.get_field(column_name = 'contexts_com_iab_snowplow_spiders_and_robots_1_0_0',
                              field_name = 'spider_or_robot',
                              table_alias = 'e',
                              type = 'boolean',
                              array_index = 0)}} = True
  {% endif %}

  {{ snowplow_unified.filter_bots() }}

)

select
*
from prep
