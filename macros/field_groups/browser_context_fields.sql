{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro browser_context_fields(table_prefix = none) %}
  {{ return(adapter.dispatch('browser_context_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro default__browser_context_fields(table_prefix = none) %}

    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__viewport
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__document_size
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__resolution
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__color_depth
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__device_pixel_ratio
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__cookies_enabled
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__online
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__browser_language
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__document_language
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__webdriver
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__device_memory
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__hardware_concurrency
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}browser__tab_id

{% endmacro %}
