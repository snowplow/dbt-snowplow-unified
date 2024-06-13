{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_deep_link_context_fields() %}
  {{ return(adapter.dispatch('get_deep_link_context_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_deep_link_context_fields() %}
  {% if var('snowplow__enable_deep_link_context', false) %}
  {% else %}
    , cast(null as {{ snowplow_utils.type_max_string() }}) as deep_link__url
    , cast(null as {{ snowplow_utils.type_max_string() }}) as deep_link__referrer
  {% endif %}
{% endmacro %}

{% macro bigquery__get_deep_link_context_fields() %}

  {% set bq_deep_link_context_fields = [
    {'field':('url', 'deep_link__url'), 'dtype':'string'},
    {'field':('referrer', 'deep_link__referrer'), 'dtype':'string'}
    ] %}

  {% if var('snowplow__enable_deep_link_context', false) %}
    ,{{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_deep_link_context', false),
          col_prefix='contexts_com_snowplowanalytics_mobile_deep_link_1',
          fields=bq_deep_link_context_fields,
          relation=ref('snowplow_unified_events_stg') if 'integration_tests' in project_name and 'snowplow' in project_name else source('atomic', 'events') ,
          relation_alias=none) }}
  {% else %}
    , cast(null as {{ dbt.type_string() }}) as deep_link__url
    , cast(null as {{ dbt.type_string() }}) as deep_link__referrer
  {% endif %}
{% endmacro %}

{% macro spark__get_deep_link_context_fields() %}
  {% if var('snowplow__enable_deep_link_context', false) %}
    , cast(contexts_com_snowplowanalytics_mobile_deep_link_1[0].url as STRING) AS deep_link__url
    , cast(contexts_com_snowplowanalytics_mobile_deep_link_1[0].referrer as STRING) AS deep_link__referrer

  {% else %}
    , cast(null as {{ dbt.type_string() }}) as deep_link__url
    , cast(null as {{ dbt.type_string() }}) as deep_link__referrer

  {% endif %}
{% endmacro %}

{% macro snowflake__get_deep_link_context_fields() %}
  {% if var('snowplow__enable_deep_link_context', false) %}
    , contexts_com_snowplowanalytics_mobile_deep_link_1[0]:url::varchar AS deep_link__url
    , contexts_com_snowplowanalytics_mobile_deep_link_1[0]:referrer::varchar AS deep_link__referrer
  {% else %}
    , cast(null as {{ dbt.type_string() }}) as deep_link__url
    , cast(null as {{ dbt.type_string() }}) as deep_link__referrer

  {% endif %}
{% endmacro %}
