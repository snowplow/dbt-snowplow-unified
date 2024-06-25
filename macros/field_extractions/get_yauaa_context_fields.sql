{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_yauaa_context_fields() %}
    {{ return(adapter.dispatch('get_yauaa_context_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_yauaa_context_fields() %}
  {%- if var('snowplow__enable_yauaa', false) -%}
  {%- else -%}
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__device_class
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__agent_class
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__agent_name
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__agent_name_version
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__agent_name_version_major
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__agent_version
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__agent_version_major
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__device_brand
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__device_name
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__device_version
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__layout_engine_class
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__layout_engine_name
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__layout_engine_name_version
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__layout_engine_name_version_major
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__layout_engine_version
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__layout_engine_version_major
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__operating_system_class
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__operating_system_name
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__operating_system_name_version
    , cast(null as {{ snowplow_utils.type_max_string() }}) as yauaa__operating_system_version
  {%- endif -%}
{% endmacro %}

{% macro bigquery__get_yauaa_context_fields() %}

  {% set bq_yauaa_fields = [
      {'field':('device_class', 'yauaa__device_class'), 'dtype': 'string'},
      {'field':('agent_class', 'yauaa__agent_class'), 'dtype': 'string'},
      {'field':('agent_name', 'yauaa__agent_name'), 'dtype': 'string'},
      {'field':('agent_name_version', 'yauaa__agent_name_version'), 'dtype': 'string'},
      {'field':('agent_name_version_major', 'yauaa__agent_name_version_major'), 'dtype': 'string'},
      {'field':('agent_version', 'yauaa__agent_version'), 'dtype': 'string'},
      {'field':('agent_version_major', 'yauaa__agent_version_major'), 'dtype': 'string'},
      {'field':('device_brand', 'yauaa__device_brand'), 'dtype': 'string'},
      {'field':('device_name', 'yauaa__device_name'), 'dtype': 'string'},
      {'field':('device_version', 'yauaa__device_version'), 'dtype': 'string'},
      {'field':('layout_engine_class', 'yauaa__layout_engine_class'), 'dtype': 'string'},
      {'field':('layout_engine_name', 'yauaa__layout_engine_name'), 'dtype': 'string'},
      {'field':('layout_engine_name_version', 'yauaa__layout_engine_name_version'), 'dtype': 'string'},
      {'field':('layout_engine_name_version_major', 'yauaa__layout_engine_name_version_major'), 'dtype': 'string'},
      {'field':('layout_engine_version', 'yauaa__layout_engine_version'), 'dtype': 'string'},
      {'field':('layout_engine_version_major', 'yauaa__layout_engine_version_major'), 'dtype': 'string'},
      {'field':('operating_system_class', 'yauaa__operating_system_class'), 'dtype': 'string'},
      {'field':('operating_system_name', 'yauaa__operating_system_name'), 'dtype': 'string'},
      {'field':('operating_system_name_version', 'yauaa__operating_system_name_version'), 'dtype': 'string'},
      {'field':('operating_system_version', 'yauaa__operating_system_version'), 'dtype': 'string'}
    ] %}

  {%- if var('snowplow__enable_yauaa', false) -%}
    ,{{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_yauaa', false),
          fields=bq_yauaa_fields,
          col_prefix='contexts_nl_basjes_yauaa_context_1',
          relation=ref('snowplow_unified_events_stg') if 'integration_tests' in project_name and 'snowplow' in project_name else source('atomic', 'events') ,
          relation_alias=none) }}
  {%- else -%}
    , cast(null as {{ dbt.type_string() }}) as yauaa__device_class
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_class
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_name
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_name_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_name_version_major
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_version_major
    , cast(null as {{ dbt.type_string() }}) as yauaa__device_brand
    , cast(null as {{ dbt.type_string() }}) as yauaa__device_name
    , cast(null as {{ dbt.type_string() }}) as yauaa__device_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_class
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_name
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_name_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_name_version_major
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_version_major
    , cast(null as {{ dbt.type_string() }}) as yauaa__operating_system_class
    , cast(null as {{ dbt.type_string() }}) as yauaa__operating_system_name
    , cast(null as {{ dbt.type_string() }}) as yauaa__operating_system_name_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__operating_system_version
  {%- endif -%}
{% endmacro %}

{% macro spark__get_yauaa_context_fields() %}
  {%- if var('snowplow__enable_yauaa', false) -%}
    , cast(contexts_nl_basjes_yauaa_context_1[0].device_class as STRING) as yauaa__device_class
    , cast(contexts_nl_basjes_yauaa_context_1[0].agent_class as STRING) as yauaa__agent_class
    , cast(contexts_nl_basjes_yauaa_context_1[0].agent_name as STRING) as yauaa__agent_name
    , cast(contexts_nl_basjes_yauaa_context_1[0].agent_name_version as STRING) as yauaa__agent_name_version
    , cast(contexts_nl_basjes_yauaa_context_1[0].agent_name_version_major as STRING) as yauaa__agent_name_version_major
    , cast(contexts_nl_basjes_yauaa_context_1[0].agent_version as STRING) as yauaa__agent_version
    , cast(contexts_nl_basjes_yauaa_context_1[0].agent_version_major as STRING) as yauaa__agent_version_major
    , cast(contexts_nl_basjes_yauaa_context_1[0].device_brand as STRING) as yauaa__device_brand
    , cast(contexts_nl_basjes_yauaa_context_1[0].device_name as STRING) as yauaa__device_name
    , cast(contexts_nl_basjes_yauaa_context_1[0].device_version as STRING) as yauaa__device_version
    , cast(contexts_nl_basjes_yauaa_context_1[0].layout_engine_class as STRING) as yauaa__layout_engine_class
    , cast(contexts_nl_basjes_yauaa_context_1[0].layout_engine_name as STRING) as yauaa__layout_engine_name
    , cast(contexts_nl_basjes_yauaa_context_1[0].layout_engine_name_version as STRING) as yauaa__layout_engine_name_version
    , cast(contexts_nl_basjes_yauaa_context_1[0].layout_engine_name_version_major as STRING) as yauaa__layout_engine_name_version_major
    , cast(contexts_nl_basjes_yauaa_context_1[0].layout_engine_version as STRING) as yauaa__layout_engine_version
    , cast(contexts_nl_basjes_yauaa_context_1[0].layout_engine_version_major as STRING) as yauaa__layout_engine_version_major
    , cast(contexts_nl_basjes_yauaa_context_1[0].operating_system_class as STRING) as yauaa__operating_system_class
    , cast(contexts_nl_basjes_yauaa_context_1[0].operating_system_name as STRING) as yauaa__operating_system_name
    , cast(contexts_nl_basjes_yauaa_context_1[0].operating_system_name_version as STRING) as yauaa__operating_system_name_version
    , cast(contexts_nl_basjes_yauaa_context_1[0].operating_system_version as STRING) as yauaa__operating_system_version
  {%- else -%}
    , cast(null as {{ dbt.type_string() }}) as yauaa__device_class
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_class
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_name
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_name_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_name_version_major
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_version_major
    , cast(null as {{ dbt.type_string() }}) as yauaa__device_brand
    , cast(null as {{ dbt.type_string() }}) as yauaa__device_name
    , cast(null as {{ dbt.type_string() }}) as yauaa__device_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_class
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_name
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_name_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_name_version_major
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_version_major
    , cast(null as {{ dbt.type_string() }}) as yauaa__operating_system_class
    , cast(null as {{ dbt.type_string() }}) as yauaa__operating_system_name
    , cast(null as {{ dbt.type_string() }}) as yauaa__operating_system_name_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__operating_system_version
  {%- endif -%}
{% endmacro %}

{% macro snowflake__get_yauaa_context_fields() %}
{%- if var('snowplow__enable_yauaa', false) -%}
  {% if var('snowplow__snowflake_lakeloader', false) %}
    , contexts_nl_basjes_yauaa_context_1[0]:device_class::VARCHAR as yauaa__device_class
    , contexts_nl_basjes_yauaa_context_1[0]:agent_class::VARCHAR as yauaa__agent_class
    , contexts_nl_basjes_yauaa_context_1[0]:agent_name::VARCHAR as yauaa__agent_name
    , contexts_nl_basjes_yauaa_context_1[0]:agent_name_version::VARCHAR as yauaa__agent_name_version
    , contexts_nl_basjes_yauaa_context_1[0]:agent_name_version_major::VARCHAR as yauaa__agent_name_version_major
    , contexts_nl_basjes_yauaa_context_1[0]:agent_version::VARCHAR as yauaa__agent_version
    , contexts_nl_basjes_yauaa_context_1[0]:agent_version_major::VARCHAR as yauaa__agent_version_major
    , contexts_nl_basjes_yauaa_context_1[0]:device_brand::VARCHAR as yauaa__device_brand
    , contexts_nl_basjes_yauaa_context_1[0]:device_name::VARCHAR as yauaa__device_name
    , contexts_nl_basjes_yauaa_context_1[0]:device_version::VARCHAR as yauaa__device_version
    , contexts_nl_basjes_yauaa_context_1[0]:layout_engine_class::VARCHAR as yauaa__layout_engine_class
    , contexts_nl_basjes_yauaa_context_1[0]:layout_engine_name::VARCHAR as yauaa__layout_engine_name
    , contexts_nl_basjes_yauaa_context_1[0]:layout_engine_name_version::VARCHAR as yauaa__layout_engine_name_version
    , contexts_nl_basjes_yauaa_context_1[0]:layout_engine_name_version_major::VARCHAR as yauaa__layout_engine_name_version_major
    , contexts_nl_basjes_yauaa_context_1[0]:layout_engine_version::VARCHAR as yauaa__layout_engine_version
    , contexts_nl_basjes_yauaa_context_1[0]:layout_engine_version_major::VARCHAR as yauaa__layout_engine_version_major
    , contexts_nl_basjes_yauaa_context_1[0]:operating_system_class::VARCHAR as yauaa__operating_system_class
    , contexts_nl_basjes_yauaa_context_1[0]:operating_system_name::VARCHAR as yauaa__operating_system_name
    , contexts_nl_basjes_yauaa_context_1[0]:operating_system_name_version::VARCHAR as yauaa__operating_system_name_version
    , contexts_nl_basjes_yauaa_context_1[0]:operating_system_version::VARCHAR as yauaa__operating_system_version
  {% else %}
    , contexts_nl_basjes_yauaa_context_1[0]:deviceClass::VARCHAR as yauaa__device_class
    , contexts_nl_basjes_yauaa_context_1[0]:agentClass::VARCHAR as yauaa__agent_class
    , contexts_nl_basjes_yauaa_context_1[0]:agentName::VARCHAR as yauaa__agent_name
    , contexts_nl_basjes_yauaa_context_1[0]:agentNameVersion::VARCHAR as yauaa__agent_name_version
    , contexts_nl_basjes_yauaa_context_1[0]:agentNameVersionMajor::VARCHAR as yauaa__agent_name_version_major
    , contexts_nl_basjes_yauaa_context_1[0]:agentVersion::VARCHAR as yauaa__agent_version
    , contexts_nl_basjes_yauaa_context_1[0]:agentVersionMajor::VARCHAR as yauaa__agent_version_major
    , contexts_nl_basjes_yauaa_context_1[0]:deviceBrand::VARCHAR as yauaa__device_brand
    , contexts_nl_basjes_yauaa_context_1[0]:deviceName::VARCHAR as yauaa__device_name
    , contexts_nl_basjes_yauaa_context_1[0]:deviceVersion::VARCHAR as yauaa__device_version
    , contexts_nl_basjes_yauaa_context_1[0]:layoutEngineClass::VARCHAR as yauaa__layout_engine_class
    , contexts_nl_basjes_yauaa_context_1[0]:layoutEngineName::VARCHAR as yauaa__layout_engine_name
    , contexts_nl_basjes_yauaa_context_1[0]:layoutEngineNameVersion::VARCHAR as yauaa__layout_engine_name_version
    , contexts_nl_basjes_yauaa_context_1[0]:layoutEngineNameVersionMajor::VARCHAR as yauaa__layout_engine_name_version_major
    , contexts_nl_basjes_yauaa_context_1[0]:layoutEngineVersion::VARCHAR as yauaa__layout_engine_version
    , contexts_nl_basjes_yauaa_context_1[0]:layoutEngineVersionMajor::VARCHAR as yauaa__layout_engine_version_major
    , contexts_nl_basjes_yauaa_context_1[0]:operatingSystemClass::VARCHAR as yauaa__operating_system_class
    , contexts_nl_basjes_yauaa_context_1[0]:operatingSystemName::VARCHAR as yauaa__operating_system_name
    , contexts_nl_basjes_yauaa_context_1[0]:operatingSystemNameVersion::VARCHAR as yauaa__operating_system_name_version
    , contexts_nl_basjes_yauaa_context_1[0]:operatingSystemVersion::VARCHAR as yauaa__operating_system_version
  {% endif %}
{%- else -%}
    , cast(null as {{ dbt.type_string() }}) as yauaa__device_class
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_class
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_name
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_name_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_name_version_major
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__agent_version_major
    , cast(null as {{ dbt.type_string() }}) as yauaa__device_brand
    , cast(null as {{ dbt.type_string() }}) as yauaa__device_name
    , cast(null as {{ dbt.type_string() }}) as yauaa__device_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_class
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_name
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_name_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_name_version_major
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__layout_engine_version_major
    , cast(null as {{ dbt.type_string() }}) as yauaa__operating_system_class
    , cast(null as {{ dbt.type_string() }}) as yauaa__operating_system_name
    , cast(null as {{ dbt.type_string() }}) as yauaa__operating_system_name_version
    , cast(null as {{ dbt.type_string() }}) as yauaa__operating_system_version
{%- endif -%}
{% endmacro %}
