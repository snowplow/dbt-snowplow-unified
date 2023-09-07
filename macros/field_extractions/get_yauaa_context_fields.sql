{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro get_yauaa_context_fields(table_prefix = none) %}
    {{ return(adapter.dispatch('get_yauaa_context_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro postgres__get_yauaa_context_fields(table_prefix = none) %}
{% endmacro %}

{% macro bigquery__get_yauaa_context_fields(table_prefix = none) %}
  {%- if var('snowplow__enable_yauaa', false) -%}
    {{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_yauaa', false),
          fields=yauaa_fields(),
          col_prefix='contexts_nl_basjes_yauaa_context_1_',
          relation=source('atomic', 'events') if project_name != 'snowplow_unified_integration_tests' else ref('snowplow_unified_events_stg'),
          relation_alias=table_prefix) }}
  {%- else -%}
    cast(null as {{ type_string() }}) as yauaa__device_class,
    cast(null as {{ type_string() }}) as yauaa__agent_class,
    cast(null as {{ type_string() }}) as yauaa__agent_name,
    cast(null as {{ type_string() }}) as yauaa__agent_name_version,
    cast(null as {{ type_string() }}) as yauaa__agent_name_version_major,
    cast(null as {{ type_string() }}) as yauaa__agent_version,
    cast(null as {{ type_string() }}) as yauaa__agent_version_major,
    cast(null as {{ type_string() }}) as yauaa__device_brand,
    cast(null as {{ type_string() }}) as yauaa__device_name,
    cast(null as {{ type_string() }}) as yauaa__device_version,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_class,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_name,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_name_version,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_name_version_major,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_version,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_version_major,
    cast(null as {{ type_string() }}) as yauaa__operating_system_class,
    cast(null as {{ type_string() }}) as yauaa__operating_system_name,
    cast(null as {{ type_string() }}) as yauaa__operating_system_name_version,
    cast(null as {{ type_string() }}) as yauaa__operating_system_version
  {%- endif -%}
{% endmacro %}

{% macro spark__get_yauaa_context_fields(table_prefix = none) %}
  {%- if var('snowplow__enable_yauaa', false) -%}
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].device_class::STRING as yauaa__device_class,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].agent_class::STRING as yauaa__agent_class,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].agent_name::STRING as yauaa__agent_name,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].agent_name_version::STRING as yauaa__agent_name_version,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].agent_name_version_major::STRING as yauaa__agent_name_version_major,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].agent_version::STRING as yauaa__agent_version,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].agent_version_major::STRING as yauaa__agent_version_major,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].device_brand::STRING as yauaa__device_brand,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].device_name::STRING as yauaa__device_name,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].device_version::STRING as yauaa__device_version,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].layout_engine_class::STRING as yauaa__layout_engine_class,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].layout_engine_name::STRING as yauaa__layout_engine_name,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].layout_engine_name_version::STRING as yauaa__layout_engine_name_version,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].layout_engine_name_version_major::STRING as yauaa__layout_engine_name_version_major,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].layout_engine_version::STRING as yauaa__layout_engine_version,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].layout_engine_version_major::STRING as yauaa__layout_engine_version_major,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].operating_system_class::STRING as yauaa__operating_system_class,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].operating_system_name::STRING as yauaa__operating_system_name,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].operating_system_name_version::STRING as yauaa__operating_system_name_version,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0].operating_system_version::STRING as yauaa__operating_system_version
  {%- else -%}
    cast(null as {{ type_string() }}) as yauaa__device_class,
    cast(null as {{ type_string() }}) as yauaa__agent_class,
    cast(null as {{ type_string() }}) as yauaa__agent_name,
    cast(null as {{ type_string() }}) as yauaa__agent_name_version,
    cast(null as {{ type_string() }}) as yauaa__agent_name_version_major,
    cast(null as {{ type_string() }}) as yauaa__agent_version,
    cast(null as {{ type_string() }}) as yauaa__agent_version_major,
    cast(null as {{ type_string() }}) as yauaa__device_brand,
    cast(null as {{ type_string() }}) as yauaa__device_name,
    cast(null as {{ type_string() }}) as yauaa__device_version,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_class,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_name,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_name_version,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_name_version_major,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_version,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_version_major,
    cast(null as {{ type_string() }}) as yauaa__operating_system_class,
    cast(null as {{ type_string() }}) as yauaa__operating_system_name,
    cast(null as {{ type_string() }}) as yauaa__operating_system_name_version,
    cast(null as {{ type_string() }}) as yauaa__operating_system_version
  {%- endif -%}
{% endmacro %}

{% macro snowflake__get_yauaa_context_fields(table_prefix = none) %}
{%- if var('snowplow__enable_yauaa', false) -%}
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:deviceClass::VARCHAR as yauaa__device_class,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:agentClass::VARCHAR as yauaa__agent_class,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:agentName::VARCHAR as yauaa__agent_name,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:agentNameVersion::VARCHAR as yauaa__agent_name_version,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:agentNameVersionMajor::VARCHAR as yauaa__agent_name_version_major,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:agentVersion::VARCHAR as yauaa__agent_version,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:agentVersionMajor::VARCHAR as yauaa__agent_version_major,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:deviceBrand::VARCHAR as yauaa__device_brand,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:deviceName::VARCHAR as yauaa__device_name,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:deviceVersion::VARCHAR as yauaa__device_version,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:layoutEngineClass::VARCHAR as yauaa__layout_engine_class,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:layoutEngineName::VARCHAR as yauaa__layout_engine_name,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:layoutEngineNameVersion::VARCHAR as yauaa__layout_engine_name_version,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:layoutEngineNameVersionMajor::VARCHAR as yauaa__layout_engine_name_version_major,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:layoutEngineVersion::VARCHAR as yauaa__layout_engine_version,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:layoutEngineVersionMajor::VARCHAR as yauaa__layout_engine_version_major,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:operatingSystemClass::VARCHAR as yauaa__operating_system_class,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:operatingSystemName::VARCHAR as yauaa__operating_system_name,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:operatingSystemNameVersion::VARCHAR as yauaa__operating_system_name_version,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_nl_basjes_yauaa_context_1[0]:operatingSystemVersion::VARCHAR as yauaa__operating_system_version
{%- else -%}
    cast(null as {{ type_string() }}) as yauaa__device_class,
    cast(null as {{ type_string() }}) as yauaa__agent_class,
    cast(null as {{ type_string() }}) as yauaa__agent_name,
    cast(null as {{ type_string() }}) as yauaa__agent_name_version,
    cast(null as {{ type_string() }}) as yauaa__agent_name_version_major,
    cast(null as {{ type_string() }}) as yauaa__agent_version,
    cast(null as {{ type_string() }}) as yauaa__agent_version_major,
    cast(null as {{ type_string() }}) as yauaa__device_brand,
    cast(null as {{ type_string() }}) as yauaa__device_name,
    cast(null as {{ type_string() }}) as yauaa__device_version,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_class,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_name,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_name_version,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_name_version_major,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_version,
    cast(null as {{ type_string() }}) as yauaa__layout_engine_version_major,
    cast(null as {{ type_string() }}) as yauaa__operating_system_class,
    cast(null as {{ type_string() }}) as yauaa__operating_system_name,
    cast(null as {{ type_string() }}) as yauaa__operating_system_name_version,
    cast(null as {{ type_string() }}) as yauaa__operating_system_version
{%- endif -%}
{% endmacro %}
