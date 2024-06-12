{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_app_context_fields() %}
  {{ return(adapter.dispatch('get_app_context_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_app_context_fields() %}
  {% if var('snowplow__enable_application_context', false) %}
  {% else %}
    , cast(null as {{ snowplow_utils.type_max_string() }}) as app__build
    , cast(null as {{ snowplow_utils.type_max_string() }}) as app__version
  {% endif %}
{% endmacro %}

{% macro bigquery__get_app_context_fields() %}

  {% set bq_app_context_fields = [
    {'field':('build', 'app__build'), 'dtype':'string'},
    {'field':('version', 'app__version'), 'dtype':'string'}
    ] %}

  {% if var('snowplow__enable_application_context', false) %}
  ,  {{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_application_context', false),
          col_prefix='contexts_com_snowplowanalytics_mobile_application_1',
          fields=bq_app_context_fields,
          relation=ref('snowplow_unified_events_stg') if 'integration_tests' in project_name and 'snowplow' in project_name else source('atomic', 'events') ,
          relation_alias=none) }}
  {% else %}
    , cast(null as {{ dbt.type_string() }}) as app__build
    , cast(null as {{ dbt.type_string() }}) as app__version
  {% endif %}
{% endmacro %}

{% macro spark__get_app_context_fields() %}
  {% if var('snowplow__enable_application_context', false) %}
      , cast(contexts_com_snowplowanalytics_mobile_application_1[0].build as STRING) AS app__build
      , cast(contexts_com_snowplowanalytics_mobile_application_1[0].version as STRING) AS app__version
  {% else %}
      , cast(null as {{ dbt.type_string() }}) as app__build
      , cast(null as {{ dbt.type_string() }}) as app__version
  {% endif %}
{% endmacro %}

{% macro snowflake__get_app_context_fields() %}
    {% if var('snowplow__enable_application_context', false) %}
      , contexts_com_snowplowanalytics_mobile_application_1[0]:build::varchar(255) AS app__build
      , contexts_com_snowplowanalytics_mobile_application_1[0]:version::varchar(255) AS app__version
    {% else %}
      , cast(null as {{ dbt.type_string() }}) as app__build
      , cast(null as {{ dbt.type_string() }}) as app__version
    {% endif %}
{% endmacro %}
