{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro unify_fields_query() %}
  {{ return(adapter.dispatch('unify_fields_query', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro default__unify_fields_query() %}

  with base as (

    select
      *,

      coalesce(
        {% if var('snowplow__enable_web') %}
          ev.page_view__id,
        {% endif %}
        {% if var('snowplow__enable_mobile') %}
          ev.screen_view__id,
        {% endif %}
        null) as view_id,

        coalesce(
        {% if var('snowplow__enable_web') %}
          case when ev.page_view__id is not null then 'page_view' end,
        {% endif %}
        {% if var('snowplow__enable_mobile') %}
          case when ev.screen_view__id is not null then 'screen_view' end,
        {% endif %}
        null) as view_type,

        coalesce(
        {% if var('snowplow__enable_web') %}
          ev.domain_sessionidx,
        {% endif %}
        {% if var('snowplow__enable_mobile') %}
          ev.session__session_index,
        {% endif %}
        null) as session_index,

      coalesce(
        {% if var('snowplow__enable_deep_link_context') %}
          ev.deep_link__referrer,
        {% else %}
          ev.page_referrer,
        {% endif %}
        null) as referrer,

      coalesce(
        {% if var('snowplow__enable_deep_link_context') %}
          ev.deep_link__url,
        {% else %}
          ev.page_url,
        {% endif %}
        null) as url,

      coalesce(
        {% if var('snowplow__enable_mobile_context') %}
          ev.mobile__resolution,
        {% else %}
          ev.dvce_screenwidth || 'x' || ev.dvce_screenheight,
        {% endif %}
        null) as screen_resolution,

      coalesce(
        {% if var('snowplow__enable_yauaa') %}
          ev.yauaa__operating_system_name,
        {% endif %}
        {% if var('snowplow__enable_mobile_context') %}
          ev.mobile__os_type,
        {% endif %}
        {% if var('snowplow__enable_ua') %}
          ev.ua__os_family,
        {% endif %}
        null, null) as os_type,

      coalesce(
        {% if var('snowplow__enable_yauaa') %}
          ev.yauaa__operating_system_version,
        {% endif %}
        {% if var('snowplow__enable_mobile_context') %}
          ev.mobile__os_version,
        {% endif %}
        {% if var('snowplow__enable_ua') %}
          ev.ua__os_version,
        {% endif %}
        null) as os_version,

      case when platform = 'web' then 'Web' --includes mobile web
           when platform = 'mob' then 'Mobile/Tablet'
           when platform = 'pc' then 'Desktop/Laptop/Netbook'
           when platform = 'srv' then 'Server-Side App'
           when platform = 'app' then 'General App'
           when platform = 'tv' then 'Connected TV'
           when platform = 'cnsl' then 'Games Console'
           when platform = 'iot' then 'Internet of Things' end as platform_name

    from {{ ref('snowplow_unified_base_events_this_run') }} as ev

  )

  select
    *,

    {% if var('snowplow__enable_yauaa') %}
      case when platform = 'web' then yauaa__device_class
           when yauaa__device_class = 'Phone' then 'Mobile'
           when yauaa__device_class = 'Tablet' then 'Tablet'
           when view_type = 'screen_view' then 'Mobile'
           else platform_name end as device_category
    {%- else -%}
      case when view_type = 'screen_view' then 'Mobile'
        else platform_name end as device_category
    {%- endif %}

  from base

{% endmacro %}
