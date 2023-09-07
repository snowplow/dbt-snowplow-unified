{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro get_deep_link_context_fields(table_prefix = none) %}
  {{ return(adapter.dispatch('get_deep_link_context_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro postgres__get_deep_link_context_fields(table_prefix = none) %}
{% endmacro %}

{% macro bigquery__get_deep_link_context_fields(table_prefix = none) %}
  {% if var('snowplow__enable_deep_link_context', false) %}
    {{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_deep_link_context', false),
          col_prefix='contexts_com_snowplowanalytics_mobile_deep_link_1_',
          fields=deep_link_context_fields(),
          relation=source('atomic', 'events') if project_name != 'snowplow_unified_integration_tests' else ref('snowplow_unified_events_stg'),
          relation_alias=table_prefix) }}
  {% else %}
    cast(null as {{ type_string() }}) as deep_link__url,
    cast(null as {{ type_string() }}) as deep_link__referrer
  {% endif %}
{% endmacro %}

{% macro spark__get_deep_link_context_fields(table_prefix = none) %}
  {% if var('snowplow__enable_deep_link_context', false) %}
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_mobile_deep_link_1[0].url::STRING AS deep_link__url,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_mobile_deep_link_1[0].referrer::STRING AS deep_link__referrer

  {% else %}
    cast(null as {{ type_string() }}) as deep_link__url,
    cast(null as {{ type_string() }}) as deep_link__referrer

  {% endif %}
{% endmacro %}

{% macro snowflake__get_deep_link_context_fields(table_prefix = none) %}
  {% if var('snowplow__enable_deep_link_context', false) %}
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_mobile_deep_link_1[0]:url::varchar AS deep_link__url,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_mobile_deep_link_1[0]:referrer::varchar AS deep_link__referrer
  {% else %}
    cast(null as {{ type_string() }}) as deep_link__url,
    cast(null as {{ type_string() }}) as deep_link__referrer

  {% endif %}
{% endmacro %}
