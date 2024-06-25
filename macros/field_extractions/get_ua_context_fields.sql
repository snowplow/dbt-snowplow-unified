{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_ua_context_fields() %}
  {{ return(adapter.dispatch('get_ua_context_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_ua_context_fields() %}

  {%- if var('snowplow__enable_ua', false) -%}
  {%- else -%}
      , cast(null as {{ snowplow_utils.type_max_string() }}) as ua__useragent_family
      , cast(null as {{ snowplow_utils.type_max_string() }}) as ua__useragent_major
      , cast(null as {{ snowplow_utils.type_max_string() }}) as ua__useragent_minor
      , cast(null as {{ snowplow_utils.type_max_string() }}) as ua__useragent_patch
      , cast(null as {{ snowplow_utils.type_max_string() }}) as ua__useragent_version
      , cast(null as {{ snowplow_utils.type_max_string() }}) as ua__os_family
      , cast(null as {{ snowplow_utils.type_max_string() }}) as ua__os_major
      , cast(null as {{ snowplow_utils.type_max_string() }}) as ua__os_minor
      , cast(null as {{ snowplow_utils.type_max_string() }}) as ua__os_patch
      , cast(null as {{ snowplow_utils.type_max_string() }}) as ua__os_patch_minor
      , cast(null as {{ snowplow_utils.type_max_string() }}) as ua__os_version
      , cast(null as {{ snowplow_utils.type_max_string() }}) as ua__device_family
  {%- endif -%}
{% endmacro %}

{% macro bigquery__get_ua_context_fields() %}

  {% set bq_ua_fields = [
      {'field':('useragent_family', 'ua__useragent_family'), 'dtype': 'string'},
      {'field':('useragent_major', 'ua__useragent_major'), 'dtype': 'string'},
      {'field':('useragent_minor', 'ua__useragent_minor'), 'dtype': 'string'},
      {'field':('useragent_patch', 'ua__useragent_patch'), 'dtype': 'string'},
      {'field':('useragent_version', 'ua__useragent_version'), 'dtype': 'string'},
      {'field':('os_family', 'ua__os_family'), 'dtype': 'string'},
      {'field':('os_major', 'ua__os_major'), 'dtype': 'string'},
      {'field':('os_minor', 'ua__os_minor'), 'dtype': 'string'},
      {'field':('os_patch', 'ua__os_patch'), 'dtype': 'string'},
      {'field':('os_patch_minor', 'ua__os_patch_minor'), 'dtype': 'string'},
      {'field':('os_version', 'ua__os_version'), 'dtype': 'string'},
      {'field':('device_family', 'ua__device_family'), 'dtype': 'string'}
    ] %}

  {%- if var('snowplow__enable_ua', false) -%}
    ,{{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_ua', false),
          fields=bq_ua_fields,
          col_prefix='contexts_com_snowplowanalytics_snowplow_ua_parser_context_1',
          relation=ref('snowplow_unified_events_stg') if 'integration_tests' in project_name and 'snowplow' in project_name else source('atomic', 'events') ,
          relation_alias=none) }}
  {%- else -%}
    , cast(null as {{ dbt.type_string() }}) as ua__useragent_family
    , cast(null as {{ dbt.type_string() }}) as ua__useragent_major
    , cast(null as {{ dbt.type_string() }}) as ua__useragent_minor
    , cast(null as {{ dbt.type_string() }}) as ua__useragent_patch
    , cast(null as {{ dbt.type_string() }}) as ua__useragent_version
    , cast(null as {{ dbt.type_string() }}) as ua__os_family
    , cast(null as {{ dbt.type_string() }}) as ua__os_major
    , cast(null as {{ dbt.type_string() }}) as ua__os_minor
    , cast(null as {{ dbt.type_string() }}) as ua__os_patch
    , cast(null as {{ dbt.type_string() }}) as ua__os_patch_minor
    , cast(null as {{ dbt.type_string() }}) as ua__os_version
    , cast(null as {{ dbt.type_string() }}) as ua__device_family
  {%- endif -%}
{% endmacro %}

{% macro spark__get_ua_context_fields() %}
  {%- if var('snowplow__enable_ua', false) -%}
    , cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragent_family as STRING) as ua__useragent_family
    , cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragent_major as STRING) as ua__useragent_major
    , cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragent_minor as STRING) as ua__useragent_minor
    , cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragent_patch as STRING) as ua__useragent_patch
    , cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragent_version as STRING) as ua__useragent_version
    , cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].os_family as STRING) as ua__os_family
    , cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].os_major as STRING) as ua__os_major
    , cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].os_minor as STRING) as ua__os_minor
    , cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].os_patch as STRING) as ua__os_patch
    , cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].os_patch_minor as STRING) as ua__os_patch_minor
    , cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].os_version as STRING) as ua__os_version
    , cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].device_family as STRING) as ua__device_family
  {%- else -%}
    , cast(null as {{ dbt.type_string() }}) as ua__useragent_family
    , cast(null as {{ dbt.type_string() }}) as ua__useragent_major
    , cast(null as {{ dbt.type_string() }}) as ua__useragent_minor
    , cast(null as {{ dbt.type_string() }}) as ua__useragent_patch
    , cast(null as {{ dbt.type_string() }}) as ua__useragent_version
    , cast(null as {{ dbt.type_string() }}) as ua__os_family
    , cast(null as {{ dbt.type_string() }}) as ua__os_major
    , cast(null as {{ dbt.type_string() }}) as ua__os_minor
    , cast(null as {{ dbt.type_string() }}) as ua__os_patch
    , cast(null as {{ dbt.type_string() }}) as ua__os_patch_minor
    , cast(null as {{ dbt.type_string() }}) as ua__os_version
    , cast(null as {{ dbt.type_string() }}) as ua__device_family
  {%- endif -%}
{% endmacro %}

{% macro snowflake__get_ua_context_fields() %}
{%- if var('snowplow__enable_ua', false) -%}
  {% if var('snowplow__snowflake_lakeloader', false) %}
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:useragent_family::VARCHAR as ua__useragent_family
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:useragent_major::VARCHAR as ua__useragent_major
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:useragent_minor::VARCHAR as ua__useragent_minor
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:useragent_patch::VARCHAR as ua__useragent_patch
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:useragent_version::VARCHAR as ua__useragent_version
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:os_family::VARCHAR as ua__os_family
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:os_major::VARCHAR as ua__os_major
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:os_minor::VARCHAR as ua__os_minor
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:os_patch::VARCHAR as ua__os_patch
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:os_patch_minor::VARCHAR as ua__os_patch_minor
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:os_version::VARCHAR as ua__os_version
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:device_family::VARCHAR as ua__device_family
  {% else %}
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:useragentFamily::VARCHAR as ua__useragent_family
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:useragentMajor::VARCHAR as ua__useragent_major
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:useragentMinor::VARCHAR as ua__useragent_minor
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:useragentPatch::VARCHAR as ua__useragent_patch
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:useragentVersion::VARCHAR as ua__useragent_version
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:osFamily::VARCHAR as ua__os_family
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:osMajor::VARCHAR as ua__os_major
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:osMinor::VARCHAR as ua__os_minor
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:osPatch::VARCHAR as ua__os_patch
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:osPatchMinor::VARCHAR as ua__os_patch_minor
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:osVersion::VARCHAR as ua__os_version
    , contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:deviceFamily::VARCHAR as ua__device_family
  {% endif %}
{%- else -%}
  , cast(null as {{ dbt.type_string() }}) as ua__useragent_family
  , cast(null as {{ dbt.type_string() }}) as ua__useragent_major
  , cast(null as {{ dbt.type_string() }}) as ua__useragent_minor
  , cast(null as {{ dbt.type_string() }}) as ua__useragent_patch
  , cast(null as {{ dbt.type_string() }}) as ua__useragent_version
  , cast(null as {{ dbt.type_string() }}) as ua__os_family
  , cast(null as {{ dbt.type_string() }}) as ua__os_major
  , cast(null as {{ dbt.type_string() }}) as ua__os_minor
  , cast(null as {{ dbt.type_string() }}) as ua__os_patch
  , cast(null as {{ dbt.type_string() }}) as ua__os_patch_minor
  , cast(null as {{ dbt.type_string() }}) as ua__os_version
  , cast(null as {{ dbt.type_string() }}) as ua__device_family
{% endif %}
{% endmacro %}
