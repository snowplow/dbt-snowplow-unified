{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro app_error_context_fields(table_prefix = none) %}
  {{ return(adapter.dispatch('app_error_context_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro default__app_error_context_fields(table_prefix = none) %}

    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__message
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__programming_language
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__class_name
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__exception_name
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__is_fatal
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__line_number
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__stack_trace
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__thread_id
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_error__thread_name

{% endmacro %}
