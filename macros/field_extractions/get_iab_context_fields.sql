{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro get_iab_context_fields(table_prefix = none) %}
  {{ return(adapter.dispatch('get_iab_context_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro postgres__get_iab_context_fields(table_prefix = none) %}
  {%- if var('snowplow__enable_iab', false) -%}
  {%- else -%}
    , cast(null as {{ type_string() }}) as iab__category
    , cast(null as {{ type_string() }}) as iab__primary_impact
    , cast(null as {{ type_string() }}) as iab__reason
    , cast(null as boolean) as iab__spider_or_robot
  {%- endif -%}
{% endmacro %}

{% macro bigquery__get_iab_context_fields(table_prefix = none) %}
  {%- if var('snowplow__enable_iab', false) -%}
    ,{{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_iab', false),
          fields=iab_fields(),
          col_prefix='contexts_com_iab_snowplow_spiders_and_robots_1_',
          relation=source('atomic', 'events') if project_name != 'snowplow_unified_integration_tests' else ref('snowplow_unified_events_stg'),
          relation_alias=table_prefix) }}
  {%- else -%}
    , cast(null as {{ type_string() }}) as iab__category
    , cast(null as {{ type_string() }}) as iab__primary_impact
    , cast(null as {{ type_string() }}) as iab__reason
    , cast(null as boolean) as iab__spider_or_robot
  {%- endif -%}
{% endmacro %}

{% macro spark__get_iab_context_fields(table_prefix = none) %}
  {%- if var('snowplow__enable_iab', false) -%}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_iab_snowplow_spiders_and_robots_1[0].category::STRING as iab__category
   , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_iab_snowplow_spiders_and_robots_1[0].primary_impact::STRING as iab__primary_impact
   , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_iab_snowplow_spiders_and_robots_1[0].reason::STRING as iab__reason
   , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_iab_snowplow_spiders_and_robots_1[0].spider_or_robot::BOOLEAN as iab__spider_or_robot
  {%- else -%}
    , cast(null as {{ type_string() }}) as iab__category
    , cast(null as {{ type_string() }}) as iab__primary_impact
    , cast(null as {{ type_string() }}) as iab__reason
    , cast(null as boolean) as iab__spider_or_robot
  {%- endif -%}
{% endmacro %}

{% macro snowflake__get_iab_context_fields(table_prefix = none) %}
  {%- if var('snowplow__enable_iab', false) %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_iab_snowplow_spiders_and_robots_1[0]:category::VARCHAR as iab__category
   , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_iab_snowplow_spiders_and_robots_1[0]:primaryImpact::VARCHAR as iab__primary_impact
   , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_iab_snowplow_spiders_and_robots_1[0]:reason::VARCHAR as iab__reason
   , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_iab_snowplow_spiders_and_robots_1[0]:spiderOrRobot::BOOLEAN as iab__spider_or_robot
  {%- else -%}
    , cast(null as {{ type_string() }}) as iab__category
    , cast(null as {{ type_string() }}) as iab__primary_impact
    , cast(null as {{ type_string() }}) as iab__reason
    , cast(null as boolean) as iab__spider_or_robot
  {%- endif -%}
{% endmacro %}
