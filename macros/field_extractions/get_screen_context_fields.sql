{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_screen_context_fields() %}
  {{ return(adapter.dispatch('get_screen_context_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_screen_context_fields() %}
  {% if var('snowplow__enable_screen_context', false) %}
  {% else %}
      , cast(null as {{ snowplow_utils.type_max_string() }}) as screen__id
      , cast(null as {{ snowplow_utils.type_max_string() }}) as screen__name
      , cast(null as {{ snowplow_utils.type_max_string() }}) as screen__activity
      , cast(null as {{ snowplow_utils.type_max_string() }}) as screen__fragment
      , cast(null as {{ snowplow_utils.type_max_string() }}) as screen__top_view_controller
      , cast(null as {{ snowplow_utils.type_max_string() }}) as screen__type
      , cast(null as {{ snowplow_utils.type_max_string() }}) as screen__view_controller
  {% endif %}
{% endmacro %}

{% macro bigquery__get_screen_context_fields() %}

  {% set bq_screen_context_fields = [
      {'field':('id', 'screen__id'), 'dtype':'string'},
      {'field':('name', 'screen__name'), 'dtype':'string'},
      {'field':('activity', 'screen__activity'), 'dtype':'string'},
      {'field':('fragment', 'screen__fragment'), 'dtype':'string'},
      {'field':('top_view_controller', 'screen__top_view_controller'), 'dtype':'string'},
      {'field':('type', 'screen__type'), 'dtype':'string'},
      {'field':('view_controller', 'screen__view_controller'), 'dtype':'string'}
    ] %}

  {% if var('snowplow__enable_screen_context', false) %}
    , {{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_screen_context', false),
          col_prefix='contexts_com_snowplowanalytics_mobile_screen_1',
          fields=bq_screen_context_fields,
         relation=ref('snowplow_unified_events_stg') if 'integration_tests' in project_name and 'snowplow' in project_name else source('atomic', 'events') ,
          relation_alias=none) }}
    {% else %}
      , cast(null as {{ dbt.type_string() }}) as screen__id
      , cast(null as {{ dbt.type_string() }}) as screen__name
      , cast(null as {{ dbt.type_string() }}) as screen__activity
      , cast(null as {{ dbt.type_string() }}) as screen__fragment
      , cast(null as {{ dbt.type_string() }}) as screen__top_view_controller
      , cast(null as {{ dbt.type_string() }}) as screen__type
      , cast(null as {{ dbt.type_string() }}) as screen__view_controller
  {% endif %}
{% endmacro %}

{% macro spark__get_screen_context_fields() %}
  {% if var('snowplow__enable_screen_context', false) %}
    , cast(contexts_com_snowplowanalytics_mobile_screen_1[0].id as STRING) AS screen__id
    , cast(contexts_com_snowplowanalytics_mobile_screen_1[0].name as STRING) AS screen__name
    , cast(contexts_com_snowplowanalytics_mobile_screen_1[0].activity as STRING) AS screen__activity
    , cast(contexts_com_snowplowanalytics_mobile_screen_1[0].fragment as STRING) AS screen__fragment
    , cast(contexts_com_snowplowanalytics_mobile_screen_1[0].top_view_controller as STRING) AS screen__top_view_controller
    , cast(contexts_com_snowplowanalytics_mobile_screen_1[0].type as STRING) AS screen__type
    , cast(contexts_com_snowplowanalytics_mobile_screen_1[0].view_controller as STRING) AS screen__view_controller
  {% else %}
    , cast(null as {{ dbt.type_string() }}) as screen__id
    , cast(null as {{ dbt.type_string() }}) as screen__name
    , cast(null as {{ dbt.type_string() }}) as screen__activity
    , cast(null as {{ dbt.type_string() }}) as screen__fragment
    , cast(null as {{ dbt.type_string() }}) as screen__top_view_controller
    , cast(null as {{ dbt.type_string() }}) as screen__type
    , cast(null as {{ dbt.type_string() }}) as screen__view_controller
  {% endif %}
{% endmacro %}

{% macro snowflake__get_screen_context_fields() %}
  {% if var('snowplow__enable_screen_context', false) %}
    {% if var('snowplow__snowflake_lakeloader', false) %}
      , contexts_com_snowplowanalytics_mobile_screen_1[0]:id::varchar(36) AS screen__id
      , contexts_com_snowplowanalytics_mobile_screen_1[0]:name::varchar AS screen__name
      , contexts_com_snowplowanalytics_mobile_screen_1[0]:activity::varchar AS screen__activity
      , contexts_com_snowplowanalytics_mobile_screen_1[0]:fragment::varchar AS screen__fragment
      , contexts_com_snowplowanalytics_mobile_screen_1[0]:top_view_controller::varchar AS screen__top_view_controller
      , contexts_com_snowplowanalytics_mobile_screen_1[0]:type::varchar AS screen__type
      , contexts_com_snowplowanalytics_mobile_screen_1[0]:view_controller::varchar AS screen__view_controller
    {% else %}
      , contexts_com_snowplowanalytics_mobile_screen_1[0]:id::varchar(36) AS screen__id
      , contexts_com_snowplowanalytics_mobile_screen_1[0]:name::varchar AS screen__name
      , contexts_com_snowplowanalytics_mobile_screen_1[0]:activity::varchar AS screen__activity
      , contexts_com_snowplowanalytics_mobile_screen_1[0]:fragment::varchar AS screen__fragment
      , contexts_com_snowplowanalytics_mobile_screen_1[0]:topViewController::varchar AS screen__top_view_controller
      , contexts_com_snowplowanalytics_mobile_screen_1[0]:type::varchar AS screen__type
      , contexts_com_snowplowanalytics_mobile_screen_1[0]:viewController::varchar AS screen__view_controller
    {% endif %}
  {% else %}
    , cast(null as {{ dbt.type_string() }}) as screen__id
    , cast(null as {{ dbt.type_string() }}) as screen__name
    , cast(null as {{ dbt.type_string() }}) as screen__activity
    , cast(null as {{ dbt.type_string() }}) as screen__fragment
    , cast(null as {{ dbt.type_string() }}) as screen__top_view_controller
    , cast(null as {{ dbt.type_string() }}) as screen__type
    , cast(null as {{ dbt.type_string() }}) as screen__view_controller
  {% endif %}
{% endmacro %}
