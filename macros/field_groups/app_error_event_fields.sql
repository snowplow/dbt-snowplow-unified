{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro app_error_event_fields(table_prefix = none, column_prefix = none) %}
  {{ return(adapter.dispatch('app_error_event_fields', 'snowplow_unified')(table_prefix, column_prefix)) }}
{%- endmacro -%}

{% macro default__app_error_event_fields(table_prefix = none, column_prefix = none) %}

    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__message{% if column_prefix %} as {{ column_prefix~"_" }}app_error__message {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__programming_language{% if column_prefix %} as {{ column_prefix~"_" }}app_error__programming_language {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__class_name{% if column_prefix %} as {{ column_prefix~"_" }}app_error__class_name {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__exception_name{% if column_prefix %} as {{ column_prefix~"_" }}app_error__exception_name {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__is_fatal{% if column_prefix %} as {{ column_prefix~"_" }}app_error__is_fatal {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__line_number{% if column_prefix %} as {{ column_prefix~"_" }}app_error__line_number {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__stack_trace{% if column_prefix %} as {{ column_prefix~"_" }}app_error__stack_trace {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__thread_id{% if column_prefix %} as {{ column_prefix~"_" }}app_error__thread_id {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__thread_name{% if column_prefix %} as {{ column_prefix~"_" }}app_error__thread_name {% endif %}

{% endmacro %}
