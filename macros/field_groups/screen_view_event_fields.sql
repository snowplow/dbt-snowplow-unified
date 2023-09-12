{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro screen_view_event_fields(table_prefix = none, column_prefix = none) %}
  {{ return(adapter.dispatch('screen_view_event_fields', 'snowplow_unified')(table_prefix, column_prefix)) }}
{%- endmacro -%}

{% macro default__screen_view_event_fields(table_prefix = none, column_prefix = none) %}

  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__id{% if column_prefix %} as {{ column_prefix~"_" }}screen_view__id {% endif %}
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__name{% if column_prefix %} as {{ column_prefix~"_" }}screen_view__name{% endif %}
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__previous_id{% if column_prefix %} as {{ column_prefix~"_" }}session__session_id {% endif %}
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__previous_name{% if column_prefix %} as {{ column_prefix~"_" }}screen_view__previous_name {% endif %}
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__previous_type{% if column_prefix %} as {{ column_prefix~"_" }}screen_view__previous_type {% endif %}
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__transition_type{% if column_prefix %} as {{ column_prefix~"_" }}screen_view__transition_type{% endif %}
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__type{% if column_prefix %} as {{ column_prefix~"_" }}screen_view__type{% endif %}

{% endmacro %}
