{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
  config(
    tags=["this_run"],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

with prep as (
  select

    {{ platform_independent_fields('ev') }}
    , view_id
    , session_identifier
    , event_id


    {% if var('snowplow__enable_web') %}
      {{ web_only_fields('ev') }}
      , {{ content_group_query() }} as content_group
      , coalesce(
      {% if var('snowplow__enable_browser_context') %}
        cast(ev.browser__color_depth as {{ type_string() }}),
      {% else %}
        ev.br_colordepth,
      {% endif %}
      null) as br_colordepth
    {% endif %}

    {% if var('snowplow__enable_mobile') %}
     {{ mobile_only_fields('ev') }}
    {% endif %}

    {% if var('snowplow__view_stitching') %}
      -- updated with mapping as part of post hook on derived page_views table
      , cast(ev.user_identifier as {{ snowplow_utils.type_max_string() }}) as stitched_user_id
    {% else %}
      , cast(null as {{ snowplow_utils.type_max_string() }}) as stitched_user_id
    {% endif %}

    {% if var('snowplow__enable_iab') %}
      {{ iab_context_fields('ev') }}
    {% endif %}

    {% if var('snowplow__enable_yauaa') %}
      {{ yauaa_context_fields('ev') }}
    {% endif %}

    {% if var('snowplow__enable_ua') %}
      {{ ua_context_fields('ev') }}
    {% endif %}

    {% if var('snowplow__enable_application_context') %}
      {{ app_context_fields('ev') }}
    {% endif %}

    {% if var('snowplow__enable_geolocation_context') %}
      {{ geo_context_fields('ev') }}
    {% endif %}

    {% if var('snowplow__enable_screen_context') %}
      {{ screen_context_fields('ev') }}
    {% endif %}

    {% if var('snowplow__enable_mobile_context') %}
      {{ mobile_context_fields('ev')}}
    {% endif %}

    {% if target.type == 'postgres' %}
    ,row_number() over (partition by ev.view_id order by ev.derived_tstamp, ev.dvce_created_tstamp) as view_id_dedupe_index
    {% endif %}

    {%- if var('snowplow__page_view_passthroughs', []) -%}
      {%- set passthrough_names = [] -%}
      {%- for identifier in var('snowplow__page_view_passthroughs', []) %}
      {# Check if it is a simple column or a sql+alias #}
        {%- if identifier is mapping -%}
          ,{{identifier['sql']}} as {{identifier['alias']}}
          {%- do passthrough_names.append(identifier['alias']) -%}
        {%- else -%}
          ,ev.{{identifier}}
          {%- do passthrough_names.append(identifier) -%}
        {%- endif -%}
      {% endfor -%}
    {%- endif %}

    from {{ ref('snowplow_unified_events_this_run') }} as ev

    left join {{ ref(var('snowplow__ga4_categories_seed')) }} c on lower(trim(ev.mkt_source)) = lower(c.source)

    where ev.event_name in ('page_view', 'screen_view')
    and ev.view_id is not null

    {% if var("snowplow__ua_bot_filter", true) %}
      {{ filter_bots('ev') }}
    {% endif %}

    {% if target.type not in ['postgres'] %}
      qualify row_number() over (partition by ev.view_id order by ev.derived_tstamp, ev.dvce_created_tstamp) = 1
    {% endif %}
)

, view_events as (
  select

    p.*

    , row_number() over (partition by p.session_identifier order by p.derived_tstamp, p.dvce_created_tstamp, p.event_id) AS view_in_session_index

    , coalesce(t.end_tstamp, p.derived_tstamp) as end_tstamp -- only page views with pings will have a row in table t

    {% if var('snowplow__enable_web') %}
      , coalesce(t.engaged_time_in_s, 0) as engaged_time_in_s -- where there are no pings, engaged time is 0.
      , {{ datediff('p.derived_tstamp', 'coalesce(t.end_tstamp, p.derived_tstamp)', 'second') }} as absolute_time_in_s
      , sd.hmax as horizontal_pixels_scrolled
      , sd.vmax as vertical_pixels_scrolled
      , sd.relative_hmax as horizontal_percentage_scrolled
      , sd.relative_vmax as vertical_percentage_scrolled
    {% endif %}

    , {{ snowplow_utils.current_timestamp_in_utc() }} as model_tstamp

  from prep p

  left join {{ ref('snowplow_unified_pv_engaged_time') }} t
  on p.view_id = t.view_id and p.session_identifier = t.session_identifier

  left join {{ ref('snowplow_unified_pv_scroll_depth') }} sd
  on p.view_id = sd.view_id and p.session_identifier = sd.session_identifier

  {% if target.type == 'postgres' %}
    where view_id_dedupe_index = 1
  {% endif %}

)

select

    -- event categorization fields
    pve.view_id
    , pve.event_name
    , pve.event_id
    , pve.session_identifier
    , pve.view_in_session_index
    , max(pve.view_in_session_index) over (partition by pve.session_identifier) as views_in_session
    {% if var('snowplow__enable_mobile') %}
      , pve.session__previous_session_id
    {% endif %}

    -- user id fields
    , pve.user_id
    , pve.user_identifier
    , pve.stitched_user_id
    , pve.network_userid

    -- timestamp fields
    , pve.dvce_created_tstamp
    , pve.collector_tstamp
    , pve.derived_tstamp
    , pve.derived_tstamp as start_tstamp
    , pve.end_tstamp -- only page views with pings will have a row in table t
    , pve.model_tstamp

    -- device fields
    , pve.app_id
    , pve.platform
    , pve.device_identifier
    , pve.device_category
    , pve.device_session_index
    , pve.os_version
    , pve.os_type
    {% if var('snowplow__enable_mobile_context') %}
      {{ mobile_context_fields('pve')}}
    {% endif %}
    {% if var('snowplow__enable_web') %}
      , pve.os_timezone
    {% endif %}
    , pve.screen_resolution
    {% if var('snowplow__enable_yauaa') %}
      , pve.yauaa__device_class
      , pve.yauaa__device_version
      , pve.yauaa__operating_system_version
      , pve.yauaa__operating_system_class
      , pve.yauaa__operating_system_name
      , pve.yauaa__operating_system_name_version
    {% endif %}

    -- geo fields
    , pve.geo_country
    , pve.geo_region
    , pve.geo_region_name
    , pve.geo_city
    , pve.geo_zipcode
    , pve.geo_latitude
    , pve.geo_longitude
    , pve.geo_timezone
    , pve.user_ipaddress

    -- engagement fields
    {% if var('snowplow__enable_web') %}
      , pve.engaged_time_in_s -- where there are no pings, engaged time is 0.
      , pve.absolute_time_in_s
      , pve.horizontal_pixels_scrolled
      , pve.vertical_pixels_scrolled
      , pve.horizontal_percentage_scrolled
      , pve.vertical_percentage_scrolled
    {% endif %}

    -- marketing fields
    , pve.mkt_medium
    , pve.mkt_source
    , pve.mkt_term
    , pve.mkt_content
    , pve.mkt_campaign
    , pve.mkt_clickid
    , pve.mkt_network
    , pve.default_channel_group

    -- webpage / referer / browser fields
    , pve.page_url
    , pve.page_referrer
    , pve.refr_medium
    , pve.refr_source
    , pve.refr_term

    {% if var('snowplow__enable_web') %}

      , pve.page_title
      , pve.content_group

      , pve.page_urlscheme
      , pve.page_urlhost
      , pve.page_urlpath
      , pve.page_urlquery
      , pve.page_urlfragment

      , pve.refr_urlscheme
      , pve.refr_urlhost
      , pve.refr_urlpath
      , pve.refr_urlquery
      , pve.refr_urlfragment


      , pve.br_lang
      , pve.br_viewwidth
      , pve.br_viewheight
      , pve.br_colordepth
      , pve.br_renderengine

      , pve.doc_width
      , pve.doc_height

    {% endif %}

    -- iab enrichment fields
    {% if var('snowplow__enable_iab') %}
      , pve.iab__category
      , pve.iab__primary_impact
      , pve.iab__reason
      , pve.iab__spider_or_robot
    {% endif %}

    -- yauaa enrichment fields
    {% if var('snowplow__enable_yauaa') %}
      , pve.yauaa__device_name
      , pve.yauaa__agent_class
      , pve.yauaa__agent_name
      , pve.yauaa__agent_name_version
      , pve.yauaa__agent_name_version_major
      , pve.yauaa__agent_version
      , pve.yauaa__agent_version_major
      , pve.yauaa__layout_engine_class
      , pve.yauaa__layout_engine_name
      , pve.yauaa__layout_engine_name_version
      , pve.yauaa__layout_engine_name_version_major
      , pve.yauaa__layout_engine_version
      , pve.yauaa__layout_engine_version_major
    {% endif %}

    -- ua parser enrichment fields
    {% if var('snowplow__enable_ua') %}
      , pve.ua__device_family
      , pve.ua__os_version
      , pve.ua__os_major
      , pve.ua__os_minor
      , pve.ua__os_patch
      , pve.ua__os_patch_minor
      , pve.ua__useragent_family
      , pve.ua__useragent_major
      , pve.ua__useragent_minor
      , pve.ua__useragent_patch
      , pve.ua__useragent_version
    {% endif %}

    -- mobile only
    {% if var('snowplow__enable_mobile') %}
      , pve.screen_view__name
      , pve.screen_view__previous_id
      , pve.screen_view__previous_name
      , pve.screen_view__previous_type
      , pve.screen_view__transition_type
      , pve.screen_view__type
    {% endif %}

    {% if var('snowplow__enable_application_context') %}
      , pve.app__build
      , pve.app__version
    {% endif %}

    {% if var('snowplow__enable_geolocation_context') %}
      , pve.geo__altitude
      , pve.geo__altitude_accuracy
      , pve.geo__bearing
      , pve.geo__latitude
      , pve.geo__latitude_longitude_accuracy
      , pve.geo__longitude
      , pve.geo__speed
    {% endif %}

    {% if var('snowplow__enable_screen_context') %}
      , pve.screen__fragment
      , pve.screen__top_view_controller
      , pve.screen__view_controller
    {% endif %}

    , pve.useragent

    {%- if var('snowplow__page_view_passthroughs', []) -%}
      {%- for col in passthrough_names %}
        , pve.{{col}}
      {%- endfor -%}
    {%- endif %}

from view_events pve
