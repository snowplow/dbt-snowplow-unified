{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro geo_context_fields(table_prefix = none, column_prefix = none) %}
  {{ return(adapter.dispatch('geo_context_fields', 'snowplow_unified')(table_prefix, column_prefix)) }}
{%- endmacro -%}

{% macro default__geo_context_fields(table_prefix = none, column_prefix = none) %}

    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo__latitude{% if column_prefix %} as {{ column_prefix~"_" }}geo__latitude {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo__longitude{% if column_prefix %} as {{ column_prefix~"_" }}geo__longitude {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo__latitude_longitude_accuracy{% if column_prefix %} as {{ column_prefix~"_" }}geo__latitude_longitude_accuracy {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo__altitude{% if column_prefix %} as {{ column_prefix~"_" }}geo__altitude {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo__altitude_accuracy{% if column_prefix %} as {{ column_prefix~"_" }}geo__altitude_accuracy {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo__bearing{% if column_prefix %} as {{ column_prefix~"_" }}geo__bearing {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo__speed{% if column_prefix %} as {{ column_prefix~"_" }}geo__speed {% endif %}

{% endmacro %}
