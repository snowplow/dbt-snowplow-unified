{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro get_screen_context_fields() %}
  {{ return(adapter.dispatch('get_screen_context_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_screen_context_fields() %}
  {% if var('snowplow__enable_screen_context', false) %}
  {% else %}
      , cast(null as {{ type_string() }}) as screen__id
      , cast(null as {{ type_string() }}) as screen__name
      , cast(null as {{ type_string() }}) as screen__activity
      , cast(null as {{ type_string() }}) as screen__fragment
      , cast(null as {{ type_string() }}) as screen__top_view_controller
      , cast(null as {{ type_string() }}) as screen__type
      , cast(null as {{ type_string() }}) as screen__view_controller
  {% endif %}
{% endmacro %}

{% macro bigquery__get_screen_context_fields() %}
  {% if var('snowplow__enable_screen_context', false) %}
    , {{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_screen_context', false),
          col_prefix='contexts_com_snowplowanalytics_mobile_screen_1_*',
          fields=bq_screen_context_fields(),
          relation=source('atomic', 'events') if project_name != 'snowplow_unified_integration_tests' else ref('snowplow_unified_events_stg'),
          relation_alias=none) }}
    {% else %}
      , cast(null as {{ type_string() }}) as screen__id
      , cast(null as {{ type_string() }}) as screen__name
      , cast(null as {{ type_string() }}) as screen__activity
      , cast(null as {{ type_string() }}) as screen__fragment
      , cast(null as {{ type_string() }}) as screen__top_view_controller
      , cast(null as {{ type_string() }}) as screen__type
      , cast(null as {{ type_string() }}) as screen__view_controller
  {% endif %}
{% endmacro %}

{% macro spark__get_screen_context_fields() %}
  {% if var('snowplow__enable_screen_context', false) %}
    , contexts_com_snowplowanalytics_mobile_screen_1[0].id::STRING AS screen__id
    , contexts_com_snowplowanalytics_mobile_screen_1[0].name::STRING AS screen__name
    , contexts_com_snowplowanalytics_mobile_screen_1[0].activity::STRING AS screen__activity
    , contexts_com_snowplowanalytics_mobile_screen_1[0].fragment::STRING AS screen__fragment
    , contexts_com_snowplowanalytics_mobile_screen_1[0].top_view_controller::STRING AS screen__top_view_controller
    , contexts_com_snowplowanalytics_mobile_screen_1[0].type::STRING AS screen__type
    , contexts_com_snowplowanalytics_mobile_screen_1[0].view_controller::STRING AS screen__view_controller
  {% else %}
    , cast(null as {{ type_string() }}) as screen__id,
    , cast(null as {{ type_string() }}) as screen__name,
    , cast(null as {{ type_string() }}) as screen__activity,
    , cast(null as {{ type_string() }}) as screen__fragment,
    , cast(null as {{ type_string() }}) as screen__top_view_controller,
    , cast(null as {{ type_string() }}) as screen__type,
    , cast(null as {{ type_string() }}) as screen__view_controller
  {% endif %}
{% endmacro %}

{% macro snowflake__get_screen_context_fields() %}
  {% if var('snowplow__enable_screen_context', false) %}
    , contexts_com_snowplowanalytics_mobile_screen_1[0]:id::varchar(36) AS screen__id
    , contexts_com_snowplowanalytics_mobile_screen_1[0]:name::varchar AS screen__name
    , contexts_com_snowplowanalytics_mobile_screen_1[0]:activity::varchar AS screen__activity
    , contexts_com_snowplowanalytics_mobile_screen_1[0]:fragment::varchar AS screen__fragment
    , contexts_com_snowplowanalytics_mobile_screen_1[0]:topViewController::varchar AS screen__top_view_controller
    , contexts_com_snowplowanalytics_mobile_screen_1[0]:type::varchar AS screen__type
    , contexts_com_snowplowanalytics_mobile_screen_1[0]:viewController::varchar AS screen__view_controller
  {% else %}
    , cast(null as {{ type_string() }}) as screen__id
    , cast(null as {{ type_string() }}) as screen__name
    , cast(null as {{ type_string() }}) as screen__activity
    , cast(null as {{ type_string() }}) as screen__fragment
    , cast(null as {{ type_string() }}) as screen__top_view_controller
    , cast(null as {{ type_string() }}) as screen__type
    , cast(null as {{ type_string() }}) as screen__view_controller
  {% endif %}
{% endmacro %}
