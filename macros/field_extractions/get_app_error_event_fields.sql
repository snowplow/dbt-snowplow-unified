{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_app_error_event_fields() %}
  {{ return(adapter.dispatch('get_app_error_event_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_app_error_event_fields() %}
  {% if var('snowplow__enable_app_errors', false) %}
  {% else %}
    , cast(null as {{ snowplow_utils.type_max_string() }}) as app_error__message
    , cast(null as {{ snowplow_utils.type_max_string() }}) as app_error__programming_language
    , cast(null as {{ snowplow_utils.type_max_string() }}) as app_error__class_name
    , cast(null as {{ snowplow_utils.type_max_string() }}) as app_error__exception_name
    , cast(null as {{ type_boolean() }}) as app_error__is_fatal
    , cast(null as {{ type_int() }}) as app_error__line_number
    , cast(null as {{ snowplow_utils.type_max_string() }}) as app_error__stack_trace
    , cast(null as {{ type_int() }}) as app_error__thread_id
    , cast(null as {{ snowplow_utils.type_max_string() }}) as app_error__thread_name
  {% endif %}
{% endmacro %}

{% macro bigquery__get_app_error_event_fields() %}

  {% set bq_app_error_event_fields = [
    {'field':('message', 'app_error__message'), 'dtype':'string'},
    {'field':('programming_language', 'app_error__programming_language'), 'dtype':'string'},
    {'field':('class_name', 'app_error__class_name'), 'dtype':'string'},
    {'field':('exception_name', 'app_error__exception_name'), 'dtype':'string'},
    {'field':('is_fatal', 'app_error__is_fatal'), 'dtype':'boolean'},
    {'field':('line_number', 'app_error__line_number'), 'dtype':'integer'},
    {'field':('stack_trace', 'app_error__stack_trace'), 'dtype':'string'},
    {'field':('thread_id', 'app_error__thread_id'), 'dtype':'integer'},
    {'field':('thread_name', 'app_error__thread_name'), 'dtype':'string'}
    ] %}

  {% if var('snowplow__enable_app_errors', false) %}
    ,{{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_app_errors', false),
          col_prefix='unstruct_event_com_snowplowanalytics_snowplow_application_error_1',
          fields=bq_app_error_event_fields,
          relation=source('atomic', 'events') if project_name != 'snowplow_unified_integration_tests' else ref('snowplow_unified_events_stg'),
          relation_alias=none) }}
  {% else %}
    , cast(null as {{ type_string() }}) as app_error__message
    , cast(null as {{ type_string() }}) as app_error__programming_language
    , cast(null as {{ type_string() }}) as app_error__class_name
    , cast(null as {{ type_string() }}) as app_error__exception_name
    , cast(null as {{ type_boolean() }}) as app_error__is_fatal
    , cast(null as {{ type_int() }}) as app_error__line_number
    , cast(null as {{ type_string() }}) as app_error__stack_trace
    , cast(null as {{ type_int() }}) as app_error__thread_id
    , cast(null as {{ type_string() }}) as app_error__thread_name
  {% endif %}
{% endmacro %}

{% macro spark__get_app_error_event_fields() %}
  {% if var('snowplow__enable_app_errors', false) %}
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1.message::STRING AS app_error__message
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1.programming_language::STRING AS app_error__programming_language
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1.class_name::STRING AS app_error__class_name
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1.exception_name::STRING AS app_error__exception_name
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1.is_fatal::BOOLEAN AS app_error__is_fatal
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1.line_number::INT AS app_error__line_number
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1.stack_trace::STRING AS app_error__stack_trace
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1.thread_id::INT AS app_error__thread_id
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1.thread_name::STRING AS app_error__thread_name
  {% else %}
    , cast(null as {{ type_string() }}) as app_error__message
    , cast(null as {{ type_string() }}) as app_error__programming_language
    , cast(null as {{ type_string() }}) as app_error__class_name
    , cast(null as {{ type_string() }}) as app_error__exception_name
    , cast(null as {{ type_boolean() }}) as app_error__is_fatal
    , cast(null as {{ type_int() }}) as app_error__line_number
    , cast(null as {{ type_string() }}) as app_error__stack_trace
    , cast(null as {{ type_int() }}) as app_error__thread_id
    , cast(null as {{ type_string() }}) as app_error__thread_name
  {% endif %}
{% endmacro %}

{% macro snowflake__get_app_error_event_fields() %}
  {% if var('snowplow__enable_app_errors', false) %}
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1:message::VARCHAR() AS app_error__message
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1:programmingLanguage::VARCHAR() AS app_error__programming_language
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1:className::VARCHAR() AS app_error__class_name
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1:exceptionName::VARCHAR() AS app_error__exception_name
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1:isFatal::BOOLEAN AS app_error__is_fatal
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1:lineNumber::INT AS app_error__line_number
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1:stackTrace::VARCHAR() AS app_error__stack_trace
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1:threadId::INT AS app_error__thread_id
    , unstruct_event_com_snowplowanalytics_snowplow_application_error_1:threadName::VARCHAR() AS app_error__thread_name
  {% else %}
    , cast(null as {{ type_string() }}) as app_error__message
    , cast(null as {{ type_string() }}) as app_error__programming_language
    , cast(null as {{ type_string() }}) as app_error__class_name
    , cast(null as {{ type_string() }}) as app_error__exception_name
    , cast(null as {{ type_boolean() }}) as app_error__is_fatal
    , cast(null as {{ type_int() }}) as app_error__line_number
    , cast(null as {{ type_string() }}) as app_error__stack_trace
    , cast(null as {{ type_int() }}) as app_error__thread_id
    , cast(null as {{ type_string() }}) as app_error__thread_name
  {% endif %}
{% endmacro %}
