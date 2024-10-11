{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_browser_context_fields() %}
  {{ return(adapter.dispatch('get_browser_context_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_browser_context_fields() %}
  {% if var('snowplow__enable_browser_context', false) or var('snowplow__enable_browser_context_2', false)  %}
  {% else %}
    , cast(null as {{ snowplow_utils.type_max_string() }}) as browser__viewport
    , cast(null as {{ snowplow_utils.type_max_string() }}) as browser__document_size
    , cast(null as {{ snowplow_utils.type_max_string() }}) as browser__resolution
    , cast(null as {{ dbt.type_int() }}) as browser__color_depth
    , cast(null as {{ snowplow_utils.type_max_string() }}) as browser__device_pixel_ratio
    , cast(null as {{ dbt.type_boolean() }}) as browser__cookies_enabled
    , cast(null as {{ dbt.type_boolean() }}) as browser__online
    , cast(null as {{ snowplow_utils.type_max_string() }}) as browser__browser_language
    , cast(null as {{ snowplow_utils.type_max_string() }}) as browser__document_language
    , cast(null as {{ dbt.type_boolean() }}) as browser__webdriver
    , cast(null as {{ dbt.type_int() }}) as browser__device_memory
    , cast(null as {{ dbt.type_int() }}) as browser__hardware_concurrency
    , cast(null as {{ snowplow_utils.type_max_string() }}) as browser__tab_id
  {% endif %}
{% endmacro %}

{% macro bigquery__get_browser_context_fields() %}

  {% set bq_browser_context_fields = [
    {'field':('viewport', 'browser__viewport'), 'dtype':'string'},
    {'field':('document_size', 'browser__document_size'), 'dtype':'string'},
    {'field':('resolution', 'browser__resolution'), 'dtype':'string'},
    {'field':('color_depth', 'browser__color_depth'), 'dtype':'integer'},
    {'field':('device_pixel_ratio', 'browser__device_pixel_ratio'), 'dtype':'float64'},
    {'field':('cookies_enabled', 'browser__cookies_enabled'), 'dtype':'boolean'},
    {'field':('online', 'browser__online'), 'dtype':'boolean'},
    {'field':('browser_language', 'browser__browser_language'), 'dtype':'string'},
    {'field':('document_language', 'browser__document_language'), 'dtype':'string'},
    {'field':('webdriver', 'browser__webdriver'), 'dtype':'boolean'},
    {'field':('device_memory', 'browser__device_memory'), 'dtype':'integer'},
    {'field':('hardware_concurrency', 'browser__hardware_concurrency'), 'dtype':'integer'},
    {'field':('tab_id', 'browser__tab_id'), 'dtype':'string'}
    ] %}

  {% set bq_browser_context_fields_1 = [
    {'field':('viewport', 'browser1__viewport'), 'dtype':'string'},
    {'field':('document_size', 'browser1__document_size'), 'dtype':'string'},
    {'field':('resolution', 'browser1__resolution'), 'dtype':'string'},
    {'field':('color_depth', 'browser1__color_depth'), 'dtype':'integer'},
    {'field':('device_pixel_ratio', 'browser1__device_pixel_ratio'), 'dtype':'float64'},
    {'field':('cookies_enabled', 'browser1__cookies_enabled'), 'dtype':'boolean'},
    {'field':('online', 'browser1__online'), 'dtype':'boolean'},
    {'field':('browser_language', 'browser1__browser_language'), 'dtype':'string'},
    {'field':('document_language', 'browser1__document_language'), 'dtype':'string'},
    {'field':('webdriver', 'browser1__webdriver'), 'dtype':'boolean'},
    {'field':('device_memory', 'browser1__device_memory'), 'dtype':'integer'},
    {'field':('hardware_concurrency', 'browser1__hardware_concurrency'), 'dtype':'integer'},
    {'field':('tab_id', 'browser1__tab_id'), 'dtype':'string'}
    ] %}

  {% set bq_browser_context_fields_2 = [
    {'field':('viewport', 'browser2__viewport'), 'dtype':'string'},
    {'field':('document_size', 'browser2__document_size'), 'dtype':'string'},
    {'field':('resolution', 'browser2__resolution'), 'dtype':'string'},
    {'field':('color_depth', 'browser2__color_depth'), 'dtype':'integer'},
    {'field':('device_pixel_ratio', 'browser2__device_pixel_ratio'), 'dtype':'float64'},
    {'field':('cookies_enabled', 'browser2__cookies_enabled'), 'dtype':'boolean'},
    {'field':('online', 'browser2__online'), 'dtype':'boolean'},
    {'field':('browser_language', 'browser2__browser_language'), 'dtype':'string'},
    {'field':('document_language', 'browser2__document_language'), 'dtype':'string'},
    {'field':('webdriver', 'browser2__webdriver'), 'dtype':'boolean'},
    {'field':('device_memory', 'browser2__device_memory'), 'dtype':'integer'},
    {'field':('hardware_concurrency', 'browser2__hardware_concurrency'), 'dtype':'integer'},
    {'field':('tab_id', 'browser2__tab_id'), 'dtype':'string'}
    ] %}

  {% if var('snowplow__enable_browser_context', false) and not var('snowplow__enable_browser_context_2', false) %}
    ,{{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_browser_context', false),
          col_prefix='contexts_com_snowplowanalytics_snowplow_browser_context_1',
          fields=bq_browser_context_fields,
          relation=ref('snowplow_unified_events_stg') if 'integration_tests' in project_name and 'snowplow' in project_name else source('atomic', 'events') ,
          relation_alias=none)
    }}
  {% elif not var('snowplow__enable_browser_context', false) and var('snowplow__enable_browser_context_2', false) %}
    ,{{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_browser_context_2', false),
          col_prefix='contexts_com_snowplowanalytics_snowplow_browser_context_2',
          fields=bq_browser_context_fields,
          relation=ref('snowplow_unified_events_stg') if 'integration_tests' in project_name and 'snowplow' in project_name else source('atomic', 'events') ,
          relation_alias=none)
    }}
  {% elif var('snowplow__enable_browser_context', false) and var('snowplow__enable_browser_context_2', false) %}
    ,{{ snowplow_utils.get_optional_fields(
      enabled=var('snowplow__enable_browser_context', false),
      col_prefix='contexts_com_snowplowanalytics_snowplow_browser_context_1',
      fields=bq_browser_context_fields_1,
      relation=ref('snowplow_unified_events_stg') if 'integration_tests' in project_name and 'snowplow' in project_name else source('atomic', 'events') ,
      relation_alias=none) }}
    ,{{ snowplow_utils.get_optional_fields(
      enabled=var('snowplow__enable_browser_context_2', false),
      col_prefix='contexts_com_snowplowanalytics_snowplow_browser_context_2',
      fields=bq_browser_context_fields_2,
      relation=ref('snowplow_unified_events_stg') if 'integration_tests' in project_name and 'snowplow' in project_name else source('atomic', 'events') ,
      relation_alias=none) }}

  {% else %}
    , cast(null as {{ dbt.type_string() }}) as browser__viewport
    , cast(null as {{ dbt.type_string() }}) as browser__document_size
    , cast(null as {{ dbt.type_string() }}) as browser__resolution
    , cast(null as {{ dbt.type_int() }}) as browser__color_depth
    , cast(null as {{ dbt.type_float() }}) as browser__device_pixel_ratio
    , cast(null as {{ dbt.type_boolean() }}) as browser__cookies_enabled
    , cast(null as {{ dbt.type_boolean() }}) as browser__online
    , cast(null as {{ dbt.type_string() }}) as browser__browser_language
    , cast(null as {{ dbt.type_string() }}) as browser__document_language
    , cast(null as {{ dbt.type_boolean() }}) as browser__webdriver
    , cast(null as {{ dbt.type_int() }}) as browser__device_memory
    , cast(null as {{ dbt.type_int() }}) as browser__hardware_concurrency
    , cast(null as {{ dbt.type_string() }}) as browser__tab_id
  {% endif %}
{% endmacro %}

{% macro spark__get_browser_context_fields() %}
  {% if var('snowplow__enable_browser_context', false) and not var('snowplow__enable_browser_context_2', false) %}
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].viewport as STRING) AS browser__viewport
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].document_size as STRING) AS browser__document_size
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].resolution as STRING) AS browser__resolution
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].color_depth as INT) AS browser__color_depth
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].device_pixel_ratio as FLOAT) AS browser__device_pixel_ratio
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].cookies_enabled as BOOLEAN) AS browser__cookies_enabled
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].online as BOOLEAN) AS browser__online
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].browser_language as STRING) AS browser__browser_language
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].document_language as STRING) AS browser__document_language
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].webdriver as BOOLEAN) AS browser__webdriver
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].device_memory as INT) AS browser__device_memory
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].hardware_concurrency as INT) AS browser__hardware_concurrency
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].tab_id as STRING) AS browser__tab_id
  {% elif not var('snowplow__enable_browser_context', false) and var('snowplow__enable_browser_context_2', false) %}
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].viewport as STRING) AS browser__viewport
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].document_size as STRING) AS browser__document_size
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].resolution as STRING) AS browser__resolution
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].color_depth as INT) AS browser__color_depth
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].device_pixel_ratio as FLOAT) AS browser__device_pixel_ratio
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].cookies_enabled as BOOLEAN) AS browser__cookies_enabled
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].online as BOOLEAN) AS browser__online
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].browser_language as STRING) AS browser__browser_language
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].document_language as STRING) AS browser__document_language
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].webdriver as BOOLEAN) AS browser__webdriver
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].device_memory as INT) AS browser__device_memory
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].hardware_concurrency as INT) AS browser__hardware_concurrency
    , cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].tab_id as STRING) AS browser__tab_id
  {% elif var('snowplow__enable_browser_context', false) and var('snowplow__enable_browser_context_2', false) %}
    , coalesce(
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].viewport as STRING),
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].viewport as STRING)
      ) AS browser__viewport
    , coalesce(
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].document_size as STRING),
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].document_size as STRING)
      ) AS browser__document_size
    , coalesce(
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].resolution as STRING),
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].resolution as STRING)
      ) AS browser__resolution
    , coalesce(
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].color_depth as INT),
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].color_depth as INT)
      ) AS browser__color_depth
    , coalesce(
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].device_pixel_ratio as FLOAT),
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].device_pixel_ratio as FLOAT)
      ) AS browser__device_pixel_ratio
    , coalesce(
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].cookies_enabled as BOOLEAN),
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].cookies_enabled as BOOLEAN)
      ) AS browser__cookies_enabled
    , coalesce(
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].online as BOOLEAN),
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].online as BOOLEAN)
      ) AS browser__online
    , coalesce(
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].browser_language as STRING),
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].browser_language as STRING)
      ) AS browser__browser_language
    , coalesce(
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].document_language as STRING),
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].document_language as STRING)
      ) AS browser__document_language
    , coalesce(
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].webdriver as BOOLEAN),
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].webdriver as BOOLEAN)
      ) AS browser__webdriver
    , coalesce(
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].device_memory as INT),
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].device_memory as INT)
      ) AS browser__device_memory
    , coalesce(
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].hardware_concurrency as INT),
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].hardware_concurrency as INT)
      ) AS browser__hardware_concurrency
    , coalesce(
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_2[0].tab_id as STRING),
        cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].tab_id as STRING)
      ) AS browser__tab_id
  {% else %}
    , cast(null as {{ dbt.type_string() }}) as browser__viewport
    , cast(null as {{ dbt.type_string() }}) as browser__document_size
    , cast(null as {{ dbt.type_string() }}) as browser__resolution
    , cast(null as {{ dbt.type_int() }}) as browser__color_depth
    , cast(null as {{ dbt.type_float() }}) as browser__device_pixel_ratio
    , cast(null as {{ dbt.type_boolean() }}) as browser__cookies_enabled
    , cast(null as {{ dbt.type_boolean() }}) as browser__online
    , cast(null as {{ dbt.type_string() }}) as browser__browser_language
    , cast(null as {{ dbt.type_string() }}) as browser__document_language
    , cast(null as {{ dbt.type_boolean() }}) as browser__webdriver
    , cast(null as {{ dbt.type_int() }}) as browser__device_memory
    , cast(null as {{ dbt.type_int() }}) as browser__hardware_concurrency
    , cast(null as {{ dbt.type_string() }}) as browser__tab_id

  {% endif %}
{% endmacro %}

{% macro snowflake__get_browser_context_fields() %}
  {% if var('snowplow__enable_browser_context', false) and not var('snowplow__enable_browser_context_2', false) %}
    {% if var('snowplow__snowflake_lakeloader', false) %}
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:viewport::varchar AS browser__viewport
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:document_size::varchar AS browser__document_size
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:resolution::varchar AS browser__resolution
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:color_depth::int AS browser__color_depth
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:device_pixel_ratio::float AS browser__device_pixel_ratio
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:cookies_enabled::boolean AS browser__cookies_enabled
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:online::boolean AS browser__online
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:browser_language::varchar AS browser__browser_language
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:document_language::varchar AS browser__document_language
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:webdriver::boolean AS browser__webdriver
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:device_memory::int AS browser__device_memory
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:hardware_concurrency::int AS browser__hardware_concurrency
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:tab_id::varchar AS browser__tab_id
    {% else %}
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:viewport::varchar AS browser__viewport
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:documentSize::varchar AS browser__document_size
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:resolution::varchar AS browser__resolution
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:colorDepth::int AS browser__color_depth
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:devicePixelRatio::float AS browser__device_pixel_ratio
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:cookiesEnabled::boolean AS browser__cookies_enabled
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:online::boolean AS browser__online
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:browserLanguage::varchar AS browser__browser_language
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:documentLanguage::varchar AS browser__document_language
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:webdriver::boolean AS browser__webdriver
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:deviceMemory::int AS browser__device_memory
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:hardwareConcurrency::int AS browser__hardware_concurrency
      , contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:tabId::varchar AS browser__tab_id
    {% endif %}
  {% elif not var('snowplow__enable_browser_context', false) and var('snowplow__enable_browser_context_2', false) %}
    {% if var('snowplow__snowflake_lakeloader', false) %}
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:viewport::varchar AS browser__viewport
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:document_size::varchar AS browser__document_size
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:resolution::varchar AS browser__resolution
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:color_depth::int AS browser__color_depth
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:device_pixel_ratio::float AS browser__device_pixel_ratio
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:cookies_enabled::boolean AS browser__cookies_enabled
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:online::boolean AS browser__online
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:browser_language::varchar AS browser__browser_language
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:document_language::varchar AS browser__document_language
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:webdriver::boolean AS browser__webdriver
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:device_memory::int AS browser__device_memory
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:hardware_concurrency::int AS browser__hardware_concurrency
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:tab_id::varchar AS browser__tab_id
    {% else %}
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:viewport::varchar AS browser__viewport
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:documentSize::varchar AS browser__document_size
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:resolution::varchar AS browser__resolution
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:colorDepth::int AS browser__color_depth
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:devicePixelRatio::float AS browser__device_pixel_ratio
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:cookiesEnabled::boolean AS browser__cookies_enabled
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:online::boolean AS browser__online
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:browserLanguage::varchar AS browser__browser_language
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:documentLanguage::varchar AS browser__document_language
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:webdriver::boolean AS browser__webdriver
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:deviceMemory::int AS browser__device_memory
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:hardwareConcurrency::int AS browser__hardware_concurrency
      , contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:tabId::varchar AS browser__tab_id
    {% endif %}
  {% elif var('snowplow__enable_browser_context', false) and var('snowplow__enable_browser_context_2', false) %}
    {% if var('snowplow__snowflake_lakeloader', false) %}
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:viewport::varchar, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:viewport::varchar) AS browser__viewport
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:document_size::varchar, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:document_size::varchar) AS browser__document_size
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:resolution::varchar, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:resolution::varchar) AS browser__resolution
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:color_depth::int, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:color_depth::int) AS browser__color_depth
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:device_pixel_ratio::float, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:device_pixel_ratio::float) AS browser__device_pixel_ratio
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:cookies_enabled::boolean, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:cookies_enabled::boolean) AS browser__cookies_enabled
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:online::boolean, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:online::boolean) AS browser__online
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:browser_language::varchar, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:browser_language::varchar) AS browser__browser_language
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:document_language::varchar, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:document_language::varchar) AS browser__document_language
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:webdriver::boolean, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:webdriver::boolean) AS browser__webdriver
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:device_memory::int, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:device_memory::int) AS browser__device_memory
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:hardware_concurrency::int, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:hardware_concurrency::int) AS browser__hardware_concurrency
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:tab_id::varchar, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:tab_id::varchar) AS browser__tab_id
    {% else %}
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:viewport::varchar, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:viewport::varchar) AS browser__viewport
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:documentSize::varchar, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:documentSize::varchar) AS browser__document_size
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:resolution::varchar, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:resolution::varchar) AS browser__resolution
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:colorDepth::int, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:colorDepth::int) AS browser__color_depth
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:devicePixelRatio::float, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:devicePixelRatio::float) AS browser__device_pixel_ratio
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:cookiesEnabled::boolean, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:cookiesEnabled::boolean) AS browser__cookies_enabled
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:online::boolean, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:online::boolean) AS browser__online
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:browserLanguage::varchar, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:browserLanguage::varchar) AS browser__browser_language
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:documentLanguage::varchar, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:documentLanguage::varchar) AS browser__document_language
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:webdriver::boolean, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:webdriver::boolean) AS browser__webdriver
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:deviceMemory::int, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:deviceMemory::int) AS browser__device_memory
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:hardwareConcurrency::int, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:hardwareConcurrency::int) AS browser__hardware_concurrency
      , coalesce(contexts_com_snowplowanalytics_snowplow_browser_context_2[0]:tabId::varchar, contexts_com_snowplowanalytics_snowplow_browser_context_1[0]:tabId::varchar) AS browser__tab_id
    {% endif %}
  {% else %}
    , cast(null as {{ dbt.type_string() }}) as browser__viewport
    , cast(null as {{ dbt.type_string() }}) as browser__document_size
    , cast(null as {{ dbt.type_string() }}) as browser__resolution
    , cast(null as {{ dbt.type_int() }}) as browser__color_depth
    , cast(null as {{ dbt.type_float() }}) as browser__device_pixel_ratio
    , cast(null as {{ dbt.type_boolean() }}) as browser__cookies_enabled
    , cast(null as {{ dbt.type_boolean() }}) as browser__online
    , cast(null as {{ dbt.type_string() }}) as browser__browser_language
    , cast(null as {{ dbt.type_string() }}) as browser__document_language
    , cast(null as {{ dbt.type_boolean() }}) as browser__webdriver
    , cast(null as {{ dbt.type_int() }}) as browser__device_memory
    , cast(null as {{ dbt.type_int() }}) as browser__hardware_concurrency
    , cast(null as {{ dbt.type_string() }}) as browser__tab_id
  {% endif %}
{% endmacro %}
