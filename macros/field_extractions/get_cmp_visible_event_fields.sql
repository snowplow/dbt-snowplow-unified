{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_cmp_visible_event_fields() %}
  {{ return(adapter.dispatch('get_cmp_visible_event_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_cmp_visible_event_fields() %}
  {% if var('snowplow__enable_consent', false) %}
  {% else %}
      , cast(null as {{ type_float() }}) as cmp__elapsed_time
  {% endif %}
{% endmacro %}

{% macro bigquery__get_cmp_visible_event_fields() %}

  {% set bq_cmp_visible_fields = [
      {'field':('elapsed_time', 'cmp__elapsed_time'), 'dtype':'float'}
    ] %}

  {% if var('snowplow__enable_consent', false) %}
  ,  {{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_consent', false),
          col_prefix='unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1',
          fields=bq_cmp_visible_fields,
          relation=source('atomic', 'events') if project_name != 'snowplow_unified_integration_tests' else ref('snowplow_unified_events_stg'),
          relation_alias=none) }}
  {% else %}
      , cast(null as {{ type_float() }}) as cmp__elapsed_time
  {% endif %}
{% endmacro %}

{% macro spark__get_cmp_visible_event_fields() %}
  {% if var('snowplow__enable_consent', false) %}
      , unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1.elapsed_time::float as cmp__elapsed_time

  {% else %}
      , cast(null as {{ type_float() }}) as cmp__elapsed_time

  {% endif %}
{% endmacro %}

{% macro snowflake__get_cmp_visible_event_fields() %}
    {% if var('snowplow__enable_consent', false) %}
    , unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1:elapsedTime::float as cmp__elapsed_time
    {% else %}
      , cast(null as {{ type_float() }}) as cmp__elapsed_time
    {% endif %}
{% endmacro %}
