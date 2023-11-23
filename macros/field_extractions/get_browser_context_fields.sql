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
  {% if var('snowplow__enable_browser_context', false) %}
  {% else %}
    , cast(null as {{ snowplow_utils.type_max_string() }}) as browser__viewport
    , cast(null as {{ snowplow_utils.type_max_string() }}) as browser__document_size
    , cast(null as {{ snowplow_utils.type_max_string() }}) as browser__resolution
    , cast(null as {{ type_int() }}) as browser__color_depth
    , cast(null as {{ snowplow_utils.type_max_string() }}) as browser__device_pixel_ratio
    , cast(null as {{ type_boolean() }}) as browser__cookies_enabled
    , cast(null as {{ type_boolean() }}) as browser__online
    , cast(null as {{ snowplow_utils.type_max_string() }}) as browser__browser_language
    , cast(null as {{ snowplow_utils.type_max_string() }}) as browser__document_language
    , cast(null as {{ type_boolean() }}) as browser__webdriver
    , cast(null as {{ type_int() }}) as browser__device_memory
    , cast(null as {{ type_int() }}) as browser__hardware_concurrency
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

  {% if var('snowplow__enable_browser_context', false) %}
    ,{{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_browser_context', false),
          col_prefix='contexts_com_snowplowanalytics_snowplow_browser_context_1',
          fields=bq_browser_context_fields,
          relation=source('atomic', 'events') if project_name != 'snowplow_unified_integration_tests' else ref('snowplow_unified_events_stg'),
          relation_alias=none) }}
  {% else %}
    , cast(null as {{ type_string() }}) as browser__viewport
    , cast(null as {{ type_string() }}) as browser__document_size
    , cast(null as {{ type_string() }}) as browser__resolution
    , cast(null as {{ type_int() }}) as browser__color_depth
    , cast(null as {{ type_float() }}) as browser__device_pixel_ratio
    , cast(null as {{ type_boolean() }}) as browser__cookies_enabled
    , cast(null as {{ type_boolean() }}) as browser__online
    , cast(null as {{ type_string() }}) as browser__browser_language
    , cast(null as {{ type_string() }}) as browser__document_language
    , cast(null as {{ type_boolean() }}) as browser__webdriver
    , cast(null as {{ type_int() }}) as browser__device_memory
    , cast(null as {{ type_int() }}) as browser__hardware_concurrency
    , cast(null as {{ type_string() }}) as browser__tab_id
  {% endif %}
{% endmacro %}

{% macro spark__get_browser_context_fields() %}
  {% if var('snowplow__enable_browser_context', false) %}
    , contexts_com_snowplowanalytics_snowplow_browser_context_1[0].viewport::STRING AS browser__viewport
    , contexts_com_snowplowanalytics_snowplow_browser_context_1[0].document_size::STRING AS browser__document_size
    , contexts_com_snowplowanalytics_snowplow_browser_context_1[0].resolution::STRING AS browser__resolution
    , contexts_com_snowplowanalytics_snowplow_browser_context_1[0].color_depth::INT AS browser__color_depth
    , contexts_com_snowplowanalytics_snowplow_browser_context_1[0].device_pixel_ratio::FLOAT AS browser__device_pixel_ratio
    , contexts_com_snowplowanalytics_snowplow_browser_context_1[0].cookies_enabled::BOOLEAN AS browser__cookies_enabled
    , contexts_com_snowplowanalytics_snowplow_browser_context_1[0].online::BOOLEAN AS browser__online
    , contexts_com_snowplowanalytics_snowplow_browser_context_1[0].browser_language::STRING AS browser__browser_language
    , contexts_com_snowplowanalytics_snowplow_browser_context_1[0].document_language::STRING AS browser__document_language
    , contexts_com_snowplowanalytics_snowplow_browser_context_1[0].webdriver::BOOLEAN AS browser__webdriver
    , contexts_com_snowplowanalytics_snowplow_browser_context_1[0].device_memory::INT AS browser__device_memory
    , contexts_com_snowplowanalytics_snowplow_browser_context_1[0].hardware_concurrency::INT AS browser__hardware_concurrency
    , contexts_com_snowplowanalytics_snowplow_browser_context_1[0].tab_id::STRING AS browser__tab_id
  {% else %}
    , cast(null as {{ type_string() }}) as browser__viewport
    , cast(null as {{ type_string() }}) as browser__document_size
    , cast(null as {{ type_string() }}) as browser__resolution
    , cast(null as {{ type_int() }}) as browser__color_depth
    , cast(null as {{ type_float() }}) as browser__device_pixel_ratio
    , cast(null as {{ type_boolean() }}) as browser__cookies_enabled
    , cast(null as {{ type_boolean() }}) as browser__online
    , cast(null as {{ type_string() }}) as browser__browser_language
    , cast(null as {{ type_string() }}) as browser__document_language
    , cast(null as {{ type_boolean() }}) as browser__webdriver
    , cast(null as {{ type_int() }}) as browser__device_memory
    , cast(null as {{ type_int() }}) as browser__hardware_concurrency
    , cast(null as {{ type_string() }}) as browser__tab_id

  {% endif %}
{% endmacro %}

{% macro snowflake__get_browser_context_fields() %}
  {% if var('snowplow__enable_browser_context', false) %}
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
  {% else %}
    , cast(null as {{ type_string() }}) as browser__viewport
    , cast(null as {{ type_string() }}) as browser__document_size
    , cast(null as {{ type_string() }}) as browser__resolution
    , cast(null as {{ type_int() }}) as browser__color_depth
    , cast(null as {{ type_float() }}) as browser__device_pixel_ratio
    , cast(null as {{ type_boolean() }}) as browser__cookies_enabled
    , cast(null as {{ type_boolean() }}) as browser__online
    , cast(null as {{ type_string() }}) as browser__browser_language
    , cast(null as {{ type_string() }}) as browser__document_language
    , cast(null as {{ type_boolean() }}) as browser__webdriver
    , cast(null as {{ type_int() }}) as browser__device_memory
    , cast(null as {{ type_int() }}) as browser__hardware_concurrency
    , cast(null as {{ type_string() }}) as browser__tab_id
  {% endif %}
{% endmacro %}
