{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro browser_context_fields(table_prefix = none, column_prefix = none) %}
  {{ return(adapter.dispatch('browser_context_fields', 'snowplow_unified')(table_prefix, column_prefix)) }}
{%- endmacro -%}

{% macro default__browser_context_fields(table_prefix = none, column_prefix = none) %}

    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__viewport{% if column_prefix %} as {{ column_prefix~"_" }}browser__viewport {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__document_size{% if column_prefix %} as {{ column_prefix~"_" }}browser__document_size {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__resolution{% if column_prefix %} as {{ column_prefix~"_" }}browser__resolution {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__color_depth{% if column_prefix %} as {{ column_prefix~"_" }}browser__color_depth {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__device_pixel_ratio{% if column_prefix %} as {{ column_prefix~"_" }}browser__device_pixel_ratio {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__cookies_enabled{% if column_prefix %} as {{ column_prefix~"_" }}browser__cookies_enabled {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__online{% if column_prefix %} as {{ column_prefix~"_" }}browser__online {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__browser_language{% if column_prefix %} as {{ column_prefix~"_" }}browser__browser_language {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__document_language{% if column_prefix %} as {{ column_prefix~"_" }}browser__document_language {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__webdriver{% if column_prefix %} as {{ column_prefix~"_" }}browser__webdriver {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__device_memory{% if column_prefix %} as {{ column_prefix~"_" }}browser__device_memory {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__hardware_concurrency{% if column_prefix %} as {{ column_prefix~"_" }}browser__hardware_concurrency {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__tab_id{% if column_prefix %} as {{ column_prefix~"_" }}browser__tab_id {% endif %}

{% endmacro %}
