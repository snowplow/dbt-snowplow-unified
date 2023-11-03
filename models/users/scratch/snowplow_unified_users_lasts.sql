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


select
  a.user_identifier
  , a.platform as last_platform
  , os_type as last_os_type
  , os_version as last_os_version
  , screen_resolution as last_screen_resolution
  , a.last_geo_country
  , a.last_geo_country_name
  , a.last_geo_continent
  , a.last_geo_city
  , a.last_geo_region_name
  , a.last_page_url

  {% if var('snowplow__enable_web') %}
    , a.last_page_title
    , a.last_page_urlscheme
    , a.last_page_urlhost
    , a.last_page_urlpath
    , a.last_page_urlquery
    , a.last_page_urlfragment

    , a.last_br_lang
    , a.last_br_lang_name
  {%- endif %}

  {% if var('snowplow__enable_mobile') %}
    , a.last_screen_view__name
    , a.last_screen_view__transition_type
    , a.last_screen_view__type
  {% endif %}

  {% if var('snowplow__enable_mobile_context') %}
    , a.mobile__carrier as last_mobile__carrier
    , a.mobile__device_manufacturer as last_mobile__device_manufacturer
    , a.mobile__device_model as last_mobile__device_model
  {% endif %}
    
  {%- if var('snowplow__user_last_passthroughs', []) -%}
    {%- for identifier in var('snowplow__user_last_passthroughs', []) %}
    {# Check if it is a simple column or a sql+alias #}
    {%- if identifier is mapping -%}
        , {{identifier['sql']}} as {{identifier['alias']}}
    {%- else -%}
        , a.{{identifier}} as last_{{identifier}}
    {%- endif -%}
    {% endfor -%}
  {%- endif %}

from {{ ref('snowplow_unified_users_sessions_this_run') }} a

inner join {{ ref('snowplow_unified_users_aggs') }} b
on a.session_identifier = b.last_session_identifier
