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

select
  -- user fields
  a.user_id
  , a.user_identifier
  , a.network_userid
  {% if var('snowplow__session_stitching') %}
    -- updated with mapping as part of post hook on derived sessions table
    , cast(a.user_identifier as {{ snowplow_utils.type_max_string() }}) as stitched_user_id
  {% else %}
    , cast(null as {{ snowplow_utils.type_max_string() }}) as stitched_user_id
  {% endif %}

  -- timestamp fields
  , b.start_tstamp
  , b.end_tstamp
  , {{ snowplow_utils.current_timestamp_in_utc() }} as model_tstamp

  -- device fields
  , a.platform as first_platform
  , c.last_platform
  , cast(a.on_web as {{ dbt.type_boolean() }}) as on_web
  , cast(a.on_mobile as {{ dbt.type_boolean() }}) as on_mobile
  , c.last_screen_resolution
  , c.last_os_type
  , c.last_os_version

  {% if var('snowplow__enable_mobile_context') %}
    , a.mobile__device_manufacturer as first_mobile__device_manufacturer
    , a.mobile__device_model as first_mobile__device_model
    , a.mobile__carrier as first_mobile__carrier
    , c.last_mobile__device_manufacturer
    , c.last_mobile__device_model
    , c.last_mobile__carrier

    , a.mobile__os_type
    , a.mobile__os_version
    , a.mobile__android_idfa
    , a.mobile__apple_idfa
    , a.mobile__apple_idfv
    , a.mobile__open_idfa
    , a.mobile__network_technology
    , a.mobile__network_type
    , a.mobile__physical_memory
    , a.mobile__system_available_memory
    , a.mobile__app_available_memory
    , a.mobile__battery_level
    , a.mobile__battery_state
    , a.mobile__low_power_mode
    , a.mobile__available_storage
    , a.mobile__total_storage
    , a.mobile__is_portrait
    , a.mobile__resolution
    , a.mobile__scale
    , a.mobile__language
    , a.mobile__app_set_id
    , a.mobile__app_set_id_scope
    -- Derivative fields
    , a.mobile_language_name
  {% endif %}

  -- geo fields
  , a.first_geo_country
  , a.first_geo_country_name
  , a.first_geo_continent
  , a.first_geo_city
  , a.first_geo_region_name
  , c.last_geo_country
  , c.last_geo_country_name
  , c.last_geo_continent
  , c.last_geo_city
  , c.last_geo_region_name

  , a.geo_zipcode
  , a.geo_latitude
  , a.geo_longitude
  , a.geo_timezone

  -- engagement fields
  , b.views
  , b.sessions
  , b.active_days

  {% if var('snowplow__enable_web') or var('snowplow__enable_screen_summary_context', false) %}
    , b.engaged_time_in_s
  {% endif %}

  , b.absolute_time_in_s

  {% if var('snowplow__enable_mobile') %}
    , b.screen_names_viewed
  {% endif %}


  -- webpage / referer / browser fields
  , a.page_referrer
  , a.refr_medium
  , a.refr_source
  , a.refr_term

  {% if var('snowplow__enable_web') %}
    , a.first_page_title
    , a.first_page_url
    , a.first_page_urlscheme
    , a.first_page_urlhost
    , a.first_page_urlpath
    , a.first_page_urlquery
    , a.first_page_urlfragment
    , a.first_br_lang
    , a.first_br_lang_name
    , c.last_page_title
    , c.last_page_url
    , c.last_page_urlscheme
    , c.last_page_urlhost
    , c.last_page_urlpath
    , c.last_page_urlquery
    , c.last_page_urlfragment
    , c.last_br_lang
    , c.last_br_lang_name
    , a.refr_urlscheme
    , a.refr_urlhost
    , a.refr_urlpath
    , a.refr_urlquery
    , a.refr_urlfragment
  {%- endif %}

  {% if var('snowplow__enable_mobile') %}
    , a.first_screen_view__name
    , a.first_screen_view__type
    , c.last_screen_view__name
    , c.last_screen_view__transition_type
    , c.last_screen_view__type
  {%- endif %}

  -- marketing fields
  , a.mkt_medium
  , a.mkt_source
  , a.mkt_term
  , a.mkt_content
  , a.mkt_campaign
  , a.mkt_clickid
  , a.mkt_network
  , a.mkt_source_platform
  , a.default_channel_group

  {% if var('snowplow__enable_app_errors') %}
    , b.app_errors
    , b.fatal_app_errors
  {%- endif %}

  {%- if var('snowplow__user_first_passthroughs', []) -%}
    {%- for identifier in var('snowplow__user_first_passthroughs', []) %}
    {# Check if it is a simple column or a sql+alias #}
    {%- if identifier is mapping -%}
        ,{{identifier['sql']}} as {{identifier['alias']}}
    {%- else -%}
        ,a.{{identifier}} as first_{{identifier}}
    {%- endif -%}
    {% endfor -%}
  {%- endif %}
  {%- if var('snowplow__user_last_passthroughs', []) -%}
    {%- for identifier in var('snowplow__user_last_passthroughs', []) %}
    {# Check if it is a simple column or a sql+alias #}
    {%- if identifier is mapping -%}
        ,c.{{identifier['alias']}}
    {%- else -%}
        ,c.last_{{identifier}}
    {%- endif -%}
    {% endfor -%}
  {%- endif %}
  {% if var('snowplow__user_aggregations', []) %}
    {% for agg in var('snowplow__user_aggregations') %}
      , b.{{ agg.get('alias') }}
    {% endfor %}
  {% endif %}

from {{ ref('snowplow_unified_users_aggs') }} as b

inner join {{ ref('snowplow_unified_users_sessions_this_run') }} as a
on a.session_identifier = b.first_session_identifier

inner join {{ ref('snowplow_unified_users_lasts') }} c
on b.user_identifier = c.user_identifier
