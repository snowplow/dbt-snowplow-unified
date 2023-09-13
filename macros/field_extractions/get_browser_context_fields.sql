{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro get_browser_context_fields(table_prefix = none) %}
  {{ return(adapter.dispatch('get_browser_context_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro postgres__get_browser_context_fields(table_prefix = none) %}
  {% if var('snowplow__enable_browser_context', false) %}
  {% else %}
    , cast(null as {{ type_string() }}) as browser__viewport
    , cast(null as {{ type_string() }}) as browser__document_size
    , cast(null as {{ type_string() }}) as browser__resolution
    , cast(null as {{ type_string() }}) as browser__color_depth
    , cast(null as {{ type_string() }}) as browser__device_pixel_ratio
    , cast(null as {{ type_string() }}) as browser__cookies_enabled
    , cast(null as {{ type_string() }}) as browser__online
    , cast(null as {{ type_string() }}) as browser__browser_language
    , cast(null as {{ type_string() }}) as browser__document_language
    , cast(null as {{ type_string() }}) as browser__webdriver
    , cast(null as {{ type_string() }}) as browser__device_memory
    , cast(null as {{ type_string() }}) as browser__hardware_concurrency
    , cast(null as {{ type_string() }}) as browser__tab_id
  {% endif %}
{% endmacro %}

{% macro bigquery__get_browser_context_fields(table_prefix = none) %}
  {% if var('snowplow__enable_browser_context', false) %}
    ,{{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_browser_context', false),
          col_prefix='com_snowplowanalytics_snowplow_browser_context_1_',
          fields=browser_context_fields(),
          relation=source('atomic', 'events') if project_name != 'snowplow_unified_integration_tests' else ref('snowplow_unified_events_stg'),
          relation_alias=table_prefix) }}
  {% else %}
    , cast(null as {{ type_string() }}) as browser__viewport
    , cast(null as {{ type_string() }}) as browser__document_size
    , cast(null as {{ type_string() }}) as browser__resolution
    , cast(null as {{ type_string() }}) as browser__color_depth
    , cast(null as {{ type_string() }}) as browser__device_pixel_ratio
    , cast(null as {{ type_string() }}) as browser__cookies_enabled
    , cast(null as {{ type_string() }}) as browser__online
    , cast(null as {{ type_string() }}) as browser__browser_language
    , cast(null as {{ type_string() }}) as browser__document_language
    , cast(null as {{ type_string() }}) as browser__webdriver
    , cast(null as {{ type_string() }}) as browser__device_memory
    , cast(null as {{ type_string() }}) as browser__hardware_concurrency
    , cast(null as {{ type_string() }}) as browser__tab_id
  {% endif %}
{% endmacro %}

{% macro spark__get_browser_context_fields(table_prefix = none) %}
  {% if var('snowplow__enable_browser_context', false) %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0].viewport::STRING AS browser__viewport
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0].document_size::STRING AS browser__document_size
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0].resolution::STRING AS browser__resolution
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0].color_depth::INT AS browser__color_depth
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0].device_pixel_ratio::FLOAT AS browser__device_pixel_ratio
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0].cookies_enabled::BOOLEAN AS browser__cookies_enabled
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0].online::BOOLEAN AS browser__online
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0].browser_language::STRING AS browser__browser_language
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0].document_language::STRING AS browser__document_language
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0].webdriver::BOOLEAN AS browser__webdriver
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0].device_memory::INT AS browser__device_memory
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0].hardware_concurrency::INT AS browser__hardware_concurrency
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0].tab_id::STRING AS browser__tab_id
  {% else %}
    , cast(null as {{ type_string() }}) as browser__viewport
    , cast(null as {{ type_string() }}) as browser__document_size
    , cast(null as {{ type_string() }}) as browser__resolution
    , cast(null as {{ type_string() }}) as browser__color_depth
    , cast(null as {{ type_string() }}) as browser__device_pixel_ratio
    , cast(null as {{ type_string() }}) as browser__cookies_enabled
    , cast(null as {{ type_boolean() }}) as browser__online
    , cast(null as {{ type_string() }}) as browser__browser_language
    , cast(null as {{ type_string() }}) as browser__document_language
    , cast(null as {{ type_boolean() }}) as browser__webdriver
    , cast(null as {{ type_int() }}) as browser__device_memory
    , cast(null as {{ type_int() }}) as browser__hardware_concurrency
    , cast(null as {{ type_string() }}) as browser__tab_id

  {% endif %}
{% endmacro %}

{% macro snowflake__get_browser_context_fields(table_prefix = none) %}
  {% if var('snowplow__enable_browser_context', false) %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0]:viewport::varchar AS browser__viewport
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0]:documentSize::varchar AS browser__document_size
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0]:resolution::varchar AS browser__resolution
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0]:colorDepth::int AS browser__color_depth
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0]:devicePixelRatio::float AS browser__device_pixel_ratio
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0]:cookiesEnabled::boolean AS browser__cookies_enabled
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0]:online::boolean AS browser__online
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0]:browserLanguage::varchar AS browser__browser_language
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0]:documentLanguage::varchar AS browser__document_language
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0]:webdriver::boolean AS browser__webdriver
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0]:deviceMemory::int AS browser__device_memory
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0]:hardwareConcurrency::int AS browser__hardware_concurrency
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}com_snowplowanalytics_snowplow_browser_context_1[0]:tabId::varchar AS browser__tab_id
  {% else %}
    , cast(null as {{ type_string() }}) as browser__viewport
    , cast(null as {{ type_string() }}) as browser__document_size
    , cast(null as {{ type_string() }}) as browser__resolution
    , cast(null as {{ type_string() }}) as browser__color_depth
    , cast(null as {{ type_string() }}) as browser__device_pixel_ratio
    , cast(null as {{ type_string() }}) as browser__cookies_enabled
    , cast(null as {{ type_string() }}) as browser__online
    , cast(null as {{ type_string() }}) as browser__browser_language
    , cast(null as {{ type_string() }}) as browser__document_language
    , cast(null as {{ type_string() }}) as browser__webdriver
    , cast(null as {{ type_string() }}) as browser__device_memory
    , cast(null as {{ type_string() }}) as browser__hardware_concurrency
    , cast(null as {{ type_string() }}) as browser__tab_id
  {% endif %}
{% endmacro %}
