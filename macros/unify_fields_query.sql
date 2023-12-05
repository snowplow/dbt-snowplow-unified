{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro unify_fields_query() %}
  {{ return(adapter.dispatch('unify_fields_query', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro default__unify_fields_query() %}

  with base as (

    select
      *,

      cast(coalesce(
        {% if var('snowplow__enable_web') %}
          ev.page_view__id,
        {% endif %}
        {% if var('snowplow__enable_mobile') %}
          ev.screen_view__id,
        {% if var('snowplow__enable_screen_context') %}
          ev.screen__id,
        {% endif %}
        {% endif %}
        null, null) as {{ dbt.type_string()}} ) as view_id,

        cast(coalesce(
        {% if var('snowplow__enable_mobile') %}
          ev.session__session_index,
        {% endif %}
        {% if var('snowplow__enable_web') %}
          ev.domain_sessionidx,
        {% endif %}
        null, null) as {{ dbt.type_int()}} ) as device_session_index,

      cast(coalesce(
        {% if var('snowplow__enable_deep_link_context') %}
          ev.deep_link__referrer,
        {% else %}
          ev.page_referrer,
        {% endif %}
        null, null) as {{ dbt.type_string()}} ) as referrer,

      cast(coalesce(
        {% if var('snowplow__enable_deep_link_context') %}
          ev.deep_link__url,
        {% else %}
          ev.page_url,
        {% endif %}
        null, null) as {{ dbt.type_string()}} ) as url,

      cast(coalesce(
        {% if var('snowplow__enable_mobile_context') %}
          ev.mobile__resolution,
        {% else %}
          ev.dvce_screenwidth || 'x' || ev.dvce_screenheight,
        {% endif %}
        null, null) as {{ dbt.type_string()}} ) as screen_resolution,

      cast(coalesce(
        {% if var('snowplow__enable_mobile_context') %}
          ev.mobile__os_type,
        {% endif %}
        {% if var('snowplow__enable_yauaa') %}
          ev.yauaa__operating_system_name,
        {% endif %}
        {% if var('snowplow__enable_ua') %}
          ev.ua__os_family,
        {% endif %}
        null, null) as {{ dbt.type_string()}} ) as os_type,

      cast(coalesce(
        {% if var('snowplow__enable_yauaa') %}
          ev.yauaa__operating_system_version,
        {% endif %}
        {% if var('snowplow__enable_mobile_context') %}
          ev.mobile__os_version,
        {% endif %}
        {% if var('snowplow__enable_ua') %}
          ev.ua__os_version,
        {% endif %}
        null, null) as {{ dbt.type_string()}} ) as os_version,

      cast(coalesce(
        {% if var('snowplow__enable_web') %}
          ev.domain_userid,
        {% endif %}
        {% if var('snowplow__enable_mobile') %}
          ev.session__user_id,
        {% endif %}
        null, null) as {{ dbt.type_string()}} ) as device_identifier,

      case when platform = 'web' then 'Web' --includes mobile web
          when platform = 'mob' then 'Mobile/Tablet'
          when platform = 'pc' then 'Desktop/Laptop/Netbook'
          when platform = 'srv' then 'Server-Side App'
          when platform = 'app' then 'General App'
          when platform = 'tv' then 'Connected TV'
          when platform = 'cnsl' then 'Games Console'
          when platform = 'iot' then 'Internet of Things'
          when platform = 'headset' then 'AR/VR Headset' end as platform_name

    from {{ ref('snowplow_unified_base_events_this_run') }} as ev

  )

  select
    *,

    {% if var('snowplow__enable_yauaa') %}
      case when platform = 'web' then yauaa__device_class
          when yauaa__device_class = 'Phone' then 'Mobile'
          when yauaa__device_class = 'Tablet' then 'Tablet'
          else platform_name end as device_category
    {%- else -%}
      platform_name as device_category
    {%- endif %}

  from base

{% endmacro %}
