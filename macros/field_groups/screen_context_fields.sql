{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro screen_context_fields(table_prefix = none, column_prefix = none) %}
  {{ return(adapter.dispatch('screen_context_fields', 'snowplow_unified')(table_prefix, column_prefix)) }}
{%- endmacro -%}

{% macro default__screen_context_fields(table_prefix = none, column_prefix = none) %}

      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen__id{% if column_prefix %} as {{ column_prefix~"_" }}screen__id {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen__name{% if column_prefix %} as {{ column_prefix~"_" }}screen__name {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen__activity{% if column_prefix %} as {{ column_prefix~"_" }}screen__activity {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen__fragment{% if column_prefix %} as {{ column_prefix~"_" }}screen__fragment {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen__top_view_controller{% if column_prefix %} as {{ column_prefix~"_" }}screen__top_view_controller {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen__type{% if column_prefix %} as {{ column_prefix~"_" }}screen__type {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen__view_controller{% if column_prefix %} as {{ column_prefix~"_" }}screen__view_controller {% endif %}

{% endmacro %}
