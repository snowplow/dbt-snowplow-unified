{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro session_context_fields(table_prefix = none, column_prefix = none) %}
  {{ return(adapter.dispatch('session_context_fields', 'snowplow_unified')(table_prefix, column_prefix)) }}
{%- endmacro -%}

{% macro default__session_context_fields(table_prefix = none, column_prefix = none) %}

    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__session_id{% if column_prefix %} as {{ column_prefix~"_" }}session__session_id {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__session_index{% if column_prefix %} as {{ column_prefix~"_" }}session__session_index {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__previous_session_id{% if column_prefix %} as {{ column_prefix~"_" }}session__previous_session_id {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__user_id{% if column_prefix %} as {{ column_prefix~"_" }}session__user_id {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__first_event_id{% if column_prefix %} as {{ column_prefix~"_" }}session__first_event_id {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__event_index{% if column_prefix %} as {{ column_prefix~"_" }}session__event_index {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__storage_mechanism{% if column_prefix %} as {{ column_prefix~"_" }}session__storage_mechanism {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__first_event_timestamp{% if column_prefix %} as {{ column_prefix~"_" }}session__first_event_timestamp {% endif %}

{% endmacro %}
