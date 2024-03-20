{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_web_page_context_fields() %}
  {{ return(adapter.dispatch('get_web_page_context_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_web_page_context_fields() %}
  {% if var('snowplow__enable_web', false) %}
  {% else %}
    , cast(null as {{ snowplow_utils.type_max_string() }}) as page_view__id
  {% endif %}
{% endmacro %}

{% macro bigquery__get_web_page_context_fields() %}

  {% set bq_web_page_fields = [
    {'field':('id', 'page_view__id'), 'dtype':'string'},
    ] %}

  {% if var('snowplow__enable_web', false) %}
      ,{{ snowplow_utils.get_optional_fields(
        enabled=true,
        fields=bq_web_page_fields,
        col_prefix='contexts_com_snowplowanalytics_snowplow_web_page_1',
        relation=ref('snowplow_unified_events_stg') if 'integration_tests' in project_name and 'snowplow' in project_name else source('atomic', 'events') ,
        relation_alias=none) }}
  {% else %}
    , cast(null as {{ dbt.type_string() }}) as page_view__id
  {% endif %}
{% endmacro %}

{% macro spark__get_web_page_context_fields() %}
  {% if var('snowplow__enable_web', false) %}
      , contexts_com_snowplowanalytics_snowplow_web_page_1[0].id as page_view__id
  {% else %}
      , cast(null as {{ dbt.type_string() }}) as page_view__id
  {% endif %}
{% endmacro %}

{% macro snowflake__get_web_page_context_fields() %}
    {% if var('snowplow__enable_web', false) %}
      , contexts_com_snowplowanalytics_snowplow_web_page_1[0]:id::varchar as page_view__id
    {% else %}
      , cast(null as {{ dbt.type_string() }}) as page_view__id
    {% endif %}
{% endmacro %}
