{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro app_context_fields(table_prefix = none) %}
  {{ return(adapter.dispatch('app_context_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro default__app_context_fields(table_prefix = none) %}

    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app__build
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app__version

{% endmacro %}
