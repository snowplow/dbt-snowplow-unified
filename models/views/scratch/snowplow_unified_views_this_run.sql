{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    tags=["this_run"],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

with prep as (
  select
    -- event categorization fields
    ev.view_id,
    ev.view_type,
    ev.event_id,
    ev.session_identifier,
    {% if var('snowplow__enable_mobile') %}
      ev.session__previous_session_id,
    {% endif %}

    -- user id fields
    ev.user_id,
    ev.user_identifier,
    {% if var('snowplow__view_stitching') %}
      -- updated with mapping as part of post hook on derived page_views table
      cast(ev.user_identifier as {{ type_string() }}) as stitched_user_id,
    {% else %}
      cast(null as {{ type_string() }}) as stitched_user_id,
    {% endif %}
    ev.network_userid,

    -- timestamp fields
    ev.dvce_created_tstamp,
    ev.collector_tstamp,
    ev.derived_tstamp,
    ev.derived_tstamp as start_tstamp,

    -- geo fields
    ev.geo_country,
    ev.geo_region,
    ev.geo_region_name,
    ev.geo_city,
    ev.geo_zipcode,
    ev.geo_latitude,
    ev.geo_longitude,
    ev.geo_timezone ,
    ev.user_ipaddress,

    -- device fields
    ev.app_id,
    ev.platform,
    ev.device_identifier,
    ev.device_category,
    ev.device_session_index,
    ev.os_version,
    ev.os_type,
    {% if var('snowplow__enable_mobile_context') %}
      ev.mobile__device_manufacturer,
      ev.mobile__android_idfa,
      ev.mobile__apple_idfa,
      ev.mobile__apple_idfv,
      ev.mobile__open_idfa,
    {% endif %}
    {% if var('snowplow__enable_web') %}
      ev.os_timezone,
    {% endif %}
    ev.screen_resolution,
    {% if var('snowplow__enable_yauaa') %}
      ev.yauaa__device_class,
      ev.yauaa__device_brand,
      ev.yauaa__device_version,
      ev.yauaa__operating_system_class,
      ev.yauaa__operating_system_version,
      ev.yauaa__operating_system_name,
      ev.yauaa__operating_system_name_version,
    {% endif %}

    -- marketing fields
    ev.mkt_medium,
    ev.mkt_source,
    ev.mkt_term,
    ev.mkt_content,
    ev.mkt_campaign,
    ev.mkt_clickid,
    ev.mkt_network,
    {{ channel_group_query() }} as default_channel_group,

    -- webpage / referer / browser fields
    ev.page_url,
    ev.page_referrer,
    ev.refr_medium,
    ev.refr_source,
    ev.refr_term,


    {% if var('snowplow__enable_web') %}
      ev.br_lang,
      ev.br_viewwidth,
      ev.br_viewheight,
      coalesce(
      {% if var('snowplow__enable_browser_context') %}
        ev.browser__color_depth,
      {% else %}
        ev.br_colordepth,
      {% endif %}
      null) as br_color_depth,
      ev.br_renderengine,

      ev.doc_width,
      ev.doc_height,

      ev.page_title,
      {{ content_group_query() }} as content_group,
      ev.page_urlscheme,
      ev.page_urlhost,
      ev.page_urlpath,
      ev.page_urlquery,
      ev.page_urlfragment,

      ev.refr_urlscheme,
      ev.refr_urlhost,
      ev.refr_urlpath,
      ev.refr_urlquery,
      ev.refr_urlfragment,

    {% endif %}

    -- iab enrichment fields
    {% if var('snowplow__enable_iab') %}
      ev.iab__category,
      ev.iab__primary_impact,
      ev.iab__reason,
      ev.iab__spider_or_robot,
    {% endif %}

    -- yauaa enrichment fields
    {% if var('snowplow__enable_yauaa') %}
      ev.yauaa__device_name,
      ev.yauaa__agent_class,
      ev.yauaa__agent_name,
      ev.yauaa__agent_name_version,
      ev.yauaa__agent_name_version_major,
      ev.yauaa__agent_version,
      ev.yauaa__agent_version_major,
      ev.yauaa__layout_engine_class,
      ev.yauaa__layout_engine_name,
      ev.yauaa__layout_engine_name_version,
      ev.yauaa__layout_engine_name_version_major,
      ev.yauaa__layout_engine_version,
      ev.yauaa__layout_engine_version_major,
    {% endif %}

    -- ua parser enrichment fields
    {% if var('snowplow__enable_ua') %}
      ev.ua__device_family,
      ev.ua__os_version,
      ev.ua__os_major,
      ev.ua__os_minor,
      ev.ua__os_patch,
      ev.ua__os_patch_minor,
      ev.ua__useragent_family,
      ev.ua__useragent_major,
      ev.ua__useragent_minor,
      ev.ua__useragent_patch,
      ev.ua__useragent_version,
    {% endif %}

    -- mobile only
    {% if var('snowplow__enable_mobile') %}
      ev.screen_view__name,
      ev.screen_view__previous_id,
      ev.screen_view__previous_name,
      ev.screen_view__previous_type,
      ev.screen_view__transition_type,
      ev.screen_view__type,
    {% endif %}

    {% if var('snowplow__enable_application_context') %}
      ev.app__build,
      ev.app__version,
    {% endif %}

    {% if var('snowplow__enable_geolocation_context') %}
      ev.geo__altitude,
      ev.geo__altitude_accuracy,
      ev.geo__bearing,
      ev.geo__latitude,
      ev.geo__latitude_longitude_accuracy,
      ev.geo__longitude,
      ev.geo__speed,
    {% endif %}

    {% if var('snowplow__enable_screen_context') %}
      ev.screen__fragment,
      ev.screen__top_view_controller,
      ev.screen__view_controller,
    {% endif %}

    {% if var('snowplow__enable_mobile_context') %}
      ev.mobile__carrier,
      ev.mobile__device_model,
      ev.mobile__network_technology,
      ev.mobile__network_type,
    {% endif %}

    ev.useragent

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
    -- event categorization fields
    p.view_id,
    p.view_type,
    p.event_id,
    p.session_identifier,
    row_number() over (partition by p.session_identifier order by p.derived_tstamp, p.dvce_created_tstamp, p.event_id) AS view_in_session_index,
    {% if var('snowplow__enable_mobile') %}
      p.session__previous_session_id,
    {% endif %}

    -- user id fields
    p.user_id,
    p.user_identifier,
    p.stitched_user_id,
    p.network_userid,

    -- timestamp fields
    p.dvce_created_tstamp,
    p.collector_tstamp,
    p.derived_tstamp,
    p.derived_tstamp as start_tstamp,
    coalesce(t.end_tstamp, p.derived_tstamp) as end_tstamp, -- only page views with pings will have a row in table t
    {{ snowplow_utils.current_timestamp_in_utc() }} as model_tstamp,
    -- geo fields
    p.geo_country,
    p.geo_region,
    p.geo_region_name,
    p.geo_city,
    p.geo_zipcode,
    p.geo_latitude,
    p.geo_longitude,
    p.geo_timezone ,
    p.user_ipaddress,

    -- device fields
    p.app_id,
    p.platform,
    p.device_identifier,
    p.device_category,
    p.device_session_index,
    p.os_version,
    p.os_type,
    {% if var('snowplow__enable_mobile_context') %}
      p.mobile__android_idfa,
      p.mobile__apple_idfa,
      p.mobile__apple_idfv,
      p.mobile__open_idfa,
    {% endif %}
    {% if var('snowplow__enable_web') %}
      p.os_timezone,
    {% endif %}
    p.screen_resolution,
    {% if var('snowplow__enable_yauaa') %}
      p.yauaa__device_class,
      p.yauaa__device_brand,
      p.yauaa__device_version,
      p.yauaa__operating_system_version,
      p.yauaa__operating_system_class,
      p.yauaa__operating_system_name,
      p.yauaa__operating_system_name_version,
    {% endif %}

    -- engagement fields
    {% if var('snowplow__enable_web') %}
    coalesce(t.engaged_time_in_s, 0) as engaged_time_in_s, -- where there are no pings, engaged time is 0.
    {{ datediff('p.derived_tstamp', 'coalesce(t.end_tstamp, p.derived_tstamp)', 'second') }} as absolute_time_in_s,
    sd.hmax as horizontal_pixels_scrolled,
    sd.vmax as vertical_pixels_scrolled,
    sd.relative_hmax as horizontal_percentage_scrolled,
    sd.relative_vmax as vertical_percentage_scrolled,

    {% endif %}

    -- marketing fields
    p.mkt_medium,
    p.mkt_source,
    p.mkt_term,
    p.mkt_content,
    p.mkt_campaign,
    p.mkt_clickid,
    p.mkt_network,
    p.default_channel_group,


    -- webpage / referer / browser fields
    p.page_url,
    p.page_referrer,
    p.refr_medium,
    p.refr_source,
    p.refr_term,

    {% if var('snowplow__enable_web') %}
      p.br_lang,
      p.br_viewwidth,
      p.br_viewheight,
      p.br_color_depth,
      p.br_renderengine,

      p.doc_width,
      p.doc_height,

      p.page_title,
      p.content_group,
      p.page_urlscheme,
      p.page_urlhost,
      p.page_urlpath,
      p.page_urlquery,
      p.page_urlfragment,

      p.refr_urlscheme,
      p.refr_urlhost,
      p.refr_urlpath,
      p.refr_urlquery,
      p.refr_urlfragment,

    {% endif %}

    -- iab enrichment fields
    {% if var('snowplow__enable_iab') %}
      p.iab__category,
      p.iab__primary_impact,
      p.iab__reason,
      p.iab__spider_or_robot,
    {% endif %}

    -- yauaa enrichment fields
    {% if var('snowplow__enable_yauaa') %}
      p.yauaa__device_name,
      p.yauaa__agent_class,
      p.yauaa__agent_name,
      p.yauaa__agent_name_version,
      p.yauaa__agent_name_version_major,
      p.yauaa__agent_version,
      p.yauaa__agent_version_major,
      p.yauaa__layout_engine_class,
      p.yauaa__layout_engine_name,
      p.yauaa__layout_engine_name_version,
      p.yauaa__layout_engine_name_version_major,
      p.yauaa__layout_engine_version,
      p.yauaa__layout_engine_version_major,
    {% endif %}

    -- ua parser enrichment fields
    {% if var('snowplow__enable_ua') %}
      p.ua__device_family,
      p.ua__os_version,
      p.ua__os_major,
      p.ua__os_minor,
      p.ua__os_patch,
      p.ua__os_patch_minor,
      p.ua__useragent_family,
      p.ua__useragent_major,
      p.ua__useragent_minor,
      p.ua__useragent_patch,
      p.ua__useragent_version,
    {% endif %}

    -- mobile only
    {% if var('snowplow__enable_mobile') %}
      p.screen_view__name,
      p.screen_view__previous_id,
      p.screen_view__previous_name,
      p.screen_view__previous_type,
      p.screen_view__transition_type,
      p.screen_view__type,

    {% endif %}

    {% if var('snowplow__enable_application_context') %}
      p.app__build,
      p.app__version,
    {% endif %}

    {% if var('snowplow__enable_geolocation_context') %}
      p.geo__altitude,
      p.geo__altitude_accuracy,
      p.geo__bearing,
      p.geo__latitude,
      p.geo__latitude_longitude_accuracy,
      p.geo__longitude,
      p.geo__speed,
    {% endif %}

    {% if var('snowplow__enable_screen_context') %}
      p.screen__fragment,
      p.screen__top_view_controller,
      p.screen__view_controller,
    {% endif %}

    {% if var('snowplow__enable_mobile_context') %}
      p.mobile__carrier,
      p.mobile__device_model,
      p.mobile__network_technology,
      p.mobile__network_type,
    {% endif %}

    p.useragent

    {%- if var('snowplow__page_view_passthroughs', []) -%}
      {%- for col in passthrough_names %}
        , p.{{col}}
      {%- endfor -%}
    {%- endif %}

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
    pve.view_id,
    pve.view_type,
    pve.event_id,
    pve.session_identifier,
    pve.view_in_session_index,
    max(pve.view_in_session_index) over (partition by pve.session_identifier) as views_in_session,
    {% if var('snowplow__enable_mobile') %}
      pve.session__previous_session_id,
    {% endif %}

    -- user id fields
    pve.user_id,
    pve.user_identifier,
    pve.stitched_user_id,
    pve.network_userid,

    -- timestamp fields
    pve.dvce_created_tstamp,
    pve.collector_tstamp,
    pve.derived_tstamp,
    pve.derived_tstamp as start_tstamp,
    pve.end_tstamp, -- only page views with pings will have a row in table t
    pve.model_tstamp,

    -- device fields
    pve.app_id,
    pve.platform,
    pve.device_identifier,
    pve.device_category,
    pve.device_session_index,
    pve.os_version,
    pve.os_type,
    {% if var('snowplow__enable_mobile_context') %}
      pve.mobile__android_idfa,
      pve.mobile__apple_idfa,
      pve.mobile__apple_idfv,
      pve.mobile__open_idfa,
    {% endif %}
    {% if var('snowplow__enable_web') %}
      pve.os_timezone,
    {% endif %}
    pve.screen_resolution,
    {% if var('snowplow__enable_yauaa') %}
      pve.yauaa__device_class,
      pve.yauaa__device_version,
      pve.yauaa__operating_system_version,
      pve.yauaa__operating_system_class,
      pve.yauaa__operating_system_name,
      pve.yauaa__operating_system_name_version,
    {% endif %}

    -- geo fields
    pve.geo_country,
    pve.geo_region,
    pve.geo_region_name,
    pve.geo_city,
    pve.geo_zipcode,
    pve.geo_latitude,
    pve.geo_longitude,
    pve.geo_timezone ,
    pve.user_ipaddress,

    -- engagement fields
    {% if var('snowplow__enable_web') %}
    pve.engaged_time_in_s, -- where there are no pings, engaged time is 0.
    pve.absolute_time_in_s,
    pve.horizontal_pixels_scrolled,
    pve.vertical_pixels_scrolled,
    pve.horizontal_percentage_scrolled,
    pve.vertical_percentage_scrolled,
    {% endif %}

    -- marketing fields
    pve.mkt_medium,
    pve.mkt_source,
    pve.mkt_term,
    pve.mkt_content,
    pve.mkt_campaign,
    pve.mkt_clickid,
    pve.mkt_network,
    pve.default_channel_group,

    -- webpage / referer / browser fields
    pve.page_url,
    pve.page_referrer,
    pve.refr_medium,
    pve.refr_source,
    pve.refr_term,

    {% if var('snowplow__enable_web') %}

      pve.page_title,
      pve.content_group,

      pve.page_urlscheme,
      pve.page_urlhost,
      pve.page_urlpath,
      pve.page_urlquery,
      pve.page_urlfragment,

      pve.refr_urlscheme,
      pve.refr_urlhost,
      pve.refr_urlpath,
      pve.refr_urlquery,
      pve.refr_urlfragment,


      pve.br_lang,
      pve.br_viewwidth,
      pve.br_viewheight,
      pve.br_color_depth,
      pve.br_renderengine,

      pve.doc_width,
      pve.doc_height,

    {% endif %}

    -- iab enrichment fields
    {% if var('snowplow__enable_iab') %}
      pve.iab__category,
      pve.iab__primary_impact,
      pve.iab__reason,
      pve.iab__spider_or_robot,
    {% endif %}

    -- yauaa enrichment fields
    {% if var('snowplow__enable_yauaa') %}
      pve.yauaa__device_name,
      pve.yauaa__agent_class,
      pve.yauaa__agent_name,
      pve.yauaa__agent_name_version,
      pve.yauaa__agent_name_version_major,
      pve.yauaa__agent_version,
      pve.yauaa__agent_version_major,
      pve.yauaa__layout_engine_class,
      pve.yauaa__layout_engine_name,
      pve.yauaa__layout_engine_name_version,
      pve.yauaa__layout_engine_name_version_major,
      pve.yauaa__layout_engine_version,
      pve.yauaa__layout_engine_version_major,
    {% endif %}

    -- ua parser enrichment fields
    {% if var('snowplow__enable_ua') %}
      pve.ua__device_family,
      pve.ua__os_version,
      pve.ua__os_major,
      pve.ua__os_minor,
      pve.ua__os_patch,
      pve.ua__os_patch_minor,
      pve.ua__useragent_family,
      pve.ua__useragent_major,
      pve.ua__useragent_minor,
      pve.ua__useragent_patch,
      pve.ua__useragent_version,
    {% endif %}

    -- mobile only
    {% if var('snowplow__enable_mobile') %}
      pve.screen_view__name,
      pve.screen_view__previous_id,
      pve.screen_view__previous_name,
      pve.screen_view__previous_type,
      pve.screen_view__transition_type,
      pve.screen_view__type,
    {% endif %}

    {% if var('snowplow__enable_application_context') %}
      pve.app__build,
      pve.app__version,
    {% endif %}

    {% if var('snowplow__enable_geolocation_context') %}
      pve.geo__altitude,
      pve.geo__altitude_accuracy,
      pve.geo__bearing,
      pve.geo__latitude,
      pve.geo__latitude_longitude_accuracy,
      pve.geo__longitude,
      pve.geo__speed,
    {% endif %}

    {% if var('snowplow__enable_screen_context') %}
      pve.screen__fragment,
      pve.screen__top_view_controller,
      pve.screen__view_controller,
    {% endif %}

    {% if var('snowplow__enable_mobile_context') %}
      pve.mobile__carrier,
      pve.mobile__device_model,
      pve.mobile__network_technology,
      pve.mobile__network_type,
    {% endif %}

    pve.useragent

    {%- if var('snowplow__page_view_passthroughs', []) -%}
      {%- for col in passthrough_names %}
        , pve.{{col}}
      {%- endfor -%}
    {%- endif %}

from view_events pve
