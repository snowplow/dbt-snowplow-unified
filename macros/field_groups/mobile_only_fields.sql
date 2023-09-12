{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro mobile_only_fields(table_prefix = none, column_prefix = none) %}
  {{ return(adapter.dispatch('mobile_only_fields', 'snowplow_unified')(table_prefix, column_prefix)) }}
{%- endmacro -%}

{% macro default__mobile_only_fields(table_prefix = none, column_prefix = none) %}

  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__previous_session_id{% if column_prefix %} as {{ column_prefix~"_" }}session__previous_session_id{% endif %}
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__name{% if column_prefix %} as {{ column_prefix~"_" }}screen_view__name{% endif %}
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__previous_id{% if column_prefix %} as {{ column_prefix~"_" }}screen_view__previous_id{% endif %}
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__previous_name{% if column_prefix %} as {{ column_prefix~"_" }}screen_view__previous_name{% endif %}
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__previous_type{% if column_prefix %} as {{ column_prefix~"_" }}screen_view__previous_type{% endif %}
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__transition_type{% if column_prefix %} as {{ column_prefix~"_" }}screen_view__transition_type{% endif %}
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__type{% if column_prefix %} as {{ column_prefix~"_" }}screen_view__type{% endif %}

{% endmacro %}
