{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_iab_context_fields() %}
  {{ return(adapter.dispatch('get_iab_context_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_iab_context_fields() %}
  {%- if var('snowplow__enable_iab', false) -%}
  {%- else -%}
    , cast(null as {{ snowplow_utils.type_max_string() }}) as iab__category
    , cast(null as {{ snowplow_utils.type_max_string() }}) as iab__primary_impact
    , cast(null as {{ snowplow_utils.type_max_string() }}) as iab__reason
    , cast(null as boolean) as iab__spider_or_robot
  {%- endif -%}
{% endmacro %}

{% macro bigquery__get_iab_context_fields() %}

  {% set bq_iab_fields = [
      {'field':('category', 'iab__category'), 'dtype':'string'},
      {'field':('primary_impact', 'iab__primary_impact'), 'dtype':'string'},
      {'field':('reason', 'iab__reason'), 'dtype':'string'},
      {'field':('spider_or_robot', 'iab__spider_or_robot'), 'dtype':'boolean'}
    ] %}

  {%- if var('snowplow__enable_iab', false) -%}
    ,{{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_iab', false),
          fields=bq_iab_fields,
          col_prefix='contexts_com_iab_snowplow_spiders_and_robots_1',
          relation=source('atomic', 'events') if project_name != 'snowplow_unified_integration_tests' else ref('snowplow_unified_events_stg'),
          relation_alias=none) }}
  {%- else -%}
    , cast(null as {{ type_string() }}) as iab__category
    , cast(null as {{ type_string() }}) as iab__primary_impact
    , cast(null as {{ type_string() }}) as iab__reason
    , cast(null as boolean) as iab__spider_or_robot
  {%- endif -%}
{% endmacro %}

{% macro spark__get_iab_context_fields() %}
  {%- if var('snowplow__enable_iab', false) -%}
    , contexts_com_iab_snowplow_spiders_and_robots_1[0].category::STRING as iab__category
    , contexts_com_iab_snowplow_spiders_and_robots_1[0].primary_impact::STRING as iab__primary_impact
    , contexts_com_iab_snowplow_spiders_and_robots_1[0].reason::STRING as iab__reason
    , contexts_com_iab_snowplow_spiders_and_robots_1[0].spider_or_robot::BOOLEAN as iab__spider_or_robot
  {%- else -%}
    , cast(null as {{ type_string() }}) as iab__category
    , cast(null as {{ type_string() }}) as iab__primary_impact
    , cast(null as {{ type_string() }}) as iab__reason
    , cast(null as boolean) as iab__spider_or_robot
  {%- endif -%}
{% endmacro %}

{% macro snowflake__get_iab_context_fields() %}
  {%- if var('snowplow__enable_iab', false) %}
    , contexts_com_iab_snowplow_spiders_and_robots_1[0]:category::VARCHAR as iab__category
    , contexts_com_iab_snowplow_spiders_and_robots_1[0]:primaryImpact::VARCHAR as iab__primary_impact
    , contexts_com_iab_snowplow_spiders_and_robots_1[0]:reason::VARCHAR as iab__reason
    , contexts_com_iab_snowplow_spiders_and_robots_1[0]:spiderOrRobot::BOOLEAN as iab__spider_or_robot
  {%- else -%}
    , cast(null as {{ type_string() }}) as iab__category
    , cast(null as {{ type_string() }}) as iab__primary_impact
    , cast(null as {{ type_string() }}) as iab__reason
    , cast(null as boolean) as iab__spider_or_robot
  {%- endif -%}
{% endmacro %}
