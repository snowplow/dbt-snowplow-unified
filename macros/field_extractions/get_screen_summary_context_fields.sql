{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_screen_summary_context_fields() %}
  {{ return(adapter.dispatch('get_screen_summary_context_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_screen_summary_context_fields() %}
  {% if var('snowplow__enable_screen_summary_context', false) %}
  {% else %}
      , cast(null as {{ dbt.type_float() }}) as screen_summary__foreground_sec
      , cast(null as {{ dbt.type_float() }}) as screen_summary__background_sec
      , cast(null as {{ dbt.type_int() }}) as screen_summary__last_item_index
      , cast(null as {{ dbt.type_int() }}) as screen_summary__items_count
      , cast(null as {{ dbt.type_int() }}) as screen_summary__min_x_offset
      , cast(null as {{ dbt.type_int() }}) as screen_summary__min_y_offset
      , cast(null as {{ dbt.type_int() }}) as screen_summary__max_x_offset
      , cast(null as {{ dbt.type_int() }}) as screen_summary__max_y_offset
      , cast(null as {{ dbt.type_int() }}) as screen_summary__content_width
      , cast(null as {{ dbt.type_int() }}) as screen_summary__content_height
  {% endif %}
{% endmacro %}

{% macro bigquery__get_screen_summary_context_fields() %}

  {% set bq_screen_summary_context_fields = [
      {'field':('foreground_sec', 'screen_summary__foreground_sec'), 'dtype':'float'},
      {'field':('background_sec', 'screen_summary__background_sec'), 'dtype':'float'},
      {'field':('last_item_index', 'screen_summary__last_item_index'), 'dtype':'integer'},
      {'field':('items_count', 'screen_summary__items_count'), 'dtype':'integer'},
      {'field':('min_x_offset', 'screen_summary__min_x_offset'), 'dtype':'integer'},
      {'field':('min_y_offset', 'screen_summary__min_y_offset'), 'dtype':'integer'},
      {'field':('max_x_offset', 'screen_summary__max_x_offset'), 'dtype':'integer'},
      {'field':('max_y_offset', 'screen_summary__max_y_offset'), 'dtype':'integer'},
      {'field':('content_width', 'screen_summary__content_width'), 'dtype':'integer'},
      {'field':('content_height', 'screen_summary__content_height'), 'dtype':'integer'},
    ] %}

  {% if var('snowplow__enable_screen_summary_context', false) %}
    , {{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_screen_summary_context', false),
          col_prefix='contexts_com_snowplowanalytics_mobile_screen_summary_1',
          fields=bq_screen_summary_context_fields,
          relation=source('atomic', 'events') if project_name != 'snowplow_unified_integration_tests' else ref('snowplow_unified_events_stg'),
          relation_alias=none) }}
    {% else %}
      , cast(null as {{ dbt.type_float() }}) as screen_summary__foreground_sec
      , cast(null as {{ dbt.type_float() }}) as screen_summary__background_sec
      , cast(null as {{ dbt.type_int() }}) as screen_summary__last_item_index
      , cast(null as {{ dbt.type_int() }}) as screen_summary__items_count
      , cast(null as {{ dbt.type_int() }}) as screen_summary__min_x_offset
      , cast(null as {{ dbt.type_int() }}) as screen_summary__min_y_offset
      , cast(null as {{ dbt.type_int() }}) as screen_summary__max_x_offset
      , cast(null as {{ dbt.type_int() }}) as screen_summary__max_y_offset
      , cast(null as {{ dbt.type_int() }}) as screen_summary__content_width
      , cast(null as {{ dbt.type_int() }}) as screen_summary__content_height
  {% endif %}
{% endmacro %}

{% macro spark__get_screen_summary_context_fields() %}
  {% if var('snowplow__enable_screen_summary_context', false) %}
    , cast(contexts_com_snowplowanalytics_mobile_screen_summary_1[0].foreground_sec as FLOAT) AS screen_summary__foreground_sec
    , cast(contexts_com_snowplowanalytics_mobile_screen_summary_1[0].background_sec as FLOAT) AS screen_summary__background_sec
    , cast(contexts_com_snowplowanalytics_mobile_screen_summary_1[0].last_item_index as INT) AS screen_summary__last_item_index
    , cast(contexts_com_snowplowanalytics_mobile_screen_summary_1[0].items_count as INT) AS screen_summary__items_count
    , cast(contexts_com_snowplowanalytics_mobile_screen_summary_1[0].min_x_offset as INT) AS screen_summary__min_x_offset
    , cast(contexts_com_snowplowanalytics_mobile_screen_summary_1[0].min_y_offset as INT) AS screen_summary__min_y_offset
    , cast(contexts_com_snowplowanalytics_mobile_screen_summary_1[0].max_x_offset as INT) AS screen_summary__max_x_offset
    , cast(contexts_com_snowplowanalytics_mobile_screen_summary_1[0].max_y_offset as INT) AS screen_summary__max_y_offset
    , cast(contexts_com_snowplowanalytics_mobile_screen_summary_1[0].content_width as INT) AS screen_summary__content_width
    , cast(contexts_com_snowplowanalytics_mobile_screen_summary_1[0].content_height as INT) AS screen_summary__content_height
  {% else %}
    , cast(null as {{ dbt.type_float() }}) as screen_summary__foreground_sec
    , cast(null as {{ dbt.type_float() }}) as screen_summary__background_sec
    , cast(null as {{ dbt.type_int() }}) as screen_summary__last_item_index
    , cast(null as {{ dbt.type_int() }}) as screen_summary__items_count
    , cast(null as {{ dbt.type_int() }}) as screen_summary__min_x_offset
    , cast(null as {{ dbt.type_int() }}) as screen_summary__min_y_offset
    , cast(null as {{ dbt.type_int() }}) as screen_summary__max_x_offset
    , cast(null as {{ dbt.type_int() }}) as screen_summary__max_y_offset
    , cast(null as {{ dbt.type_int() }}) as screen_summary__content_width
    , cast(null as {{ dbt.type_int() }}) as screen_summary__content_height
  {% endif %}
{% endmacro %}

{% macro snowflake__get_screen_summary_context_fields() %}
  {% if var('snowplow__enable_screen_summary_context', false) %}
    , contexts_com_snowplowanalytics_mobile_screen_summary_1[0]:foreground_sec::FLOAT AS screen_summary__foreground_sec
    , contexts_com_snowplowanalytics_mobile_screen_summary_1[0]:background_sec::FLOAT AS screen_summary__background_sec
    , contexts_com_snowplowanalytics_mobile_screen_summary_1[0]:last_item_index::INT AS screen_summary__last_item_index
    , contexts_com_snowplowanalytics_mobile_screen_summary_1[0]:items_count::INT AS screen_summary__items_count
    , contexts_com_snowplowanalytics_mobile_screen_summary_1[0]:min_x_offset::INT AS screen_summary__min_x_offset
    , contexts_com_snowplowanalytics_mobile_screen_summary_1[0]:min_y_offset::INT AS screen_summary__min_y_offset
    , contexts_com_snowplowanalytics_mobile_screen_summary_1[0]:max_x_offset::INT AS screen_summary__max_x_offset
    , contexts_com_snowplowanalytics_mobile_screen_summary_1[0]:max_y_offset::INT AS screen_summary__max_y_offset
    , contexts_com_snowplowanalytics_mobile_screen_summary_1[0]:content_width::INT AS screen_summary__content_width
    , contexts_com_snowplowanalytics_mobile_screen_summary_1[0]:content_height::INT AS screen_summary__content_height
  {% else %}
    , cast(null as {{ dbt.type_float() }}) as screen_summary__foreground_sec
    , cast(null as {{ dbt.type_float() }}) as screen_summary__background_sec
    , cast(null as {{ dbt.type_int() }}) as screen_summary__last_item_index
    , cast(null as {{ dbt.type_int() }}) as screen_summary__items_count
    , cast(null as {{ dbt.type_int() }}) as screen_summary__min_x_offset
    , cast(null as {{ dbt.type_int() }}) as screen_summary__min_y_offset
    , cast(null as {{ dbt.type_int() }}) as screen_summary__max_x_offset
    , cast(null as {{ dbt.type_int() }}) as screen_summary__max_y_offset
    , cast(null as {{ dbt.type_int() }}) as screen_summary__content_width
    , cast(null as {{ dbt.type_int() }}) as screen_summary__content_height
  {% endif %}
{% endmacro %}
