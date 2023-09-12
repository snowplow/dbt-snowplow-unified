{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro get_ua_context_fields(table_prefix = none) %}
  {{ return(adapter.dispatch('get_ua_context_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro postgres__get_ua_context_fields(table_prefix = none) %}
{% endmacro %}

{% macro bigquery__get_ua_context_fields(table_prefix = none) %}
  {%- if var('snowplow__enable_ua', false) -%}
    {{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_ua', false),
          fields=ua_fields(),
          col_prefix='contexts_com_snowplowanalytics_snowplow_ua_parser_context_1_',
          relation=source('atomic', 'events') if project_name != 'snowplow_unified_integration_tests' else ref('snowplow_unified_events_stg'),
          relation_alias=table_prefix) }}
  {%- else -%}
      cast(null as {{ type_string() }}) as ua__useragent_family,
      cast(null as {{ type_string() }}) as ua__useragent_major,
      cast(null as {{ type_string() }}) as ua__useragent_minor,
      cast(null as {{ type_string() }}) as ua__useragent_patch,
      cast(null as {{ type_string() }}) as ua__useragent_version,
      cast(null as {{ type_string() }}) as ua__ua_os_family,
      cast(null as {{ type_string() }}) as ua__os_major,
      cast(null as {{ type_string() }}) as ua__os_minor,
      cast(null as {{ type_string() }}) as ua__os_patch,
      cast(null as {{ type_string() }}) as ua__os_patch_minor,
      cast(null as {{ type_string() }}) as ua__os_version,
      cast(null as {{ type_string() }}) as ua__device_family
  {%- endif -%}
{% endmacro %}

{% macro spark__get_ua_context_fields(table_prefix = none) %}
  {%- if var('snowplow__enable_ua', false) -%}
      {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragent_family::STRING as ua__useragent_family,
      {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragent_major::STRING as ua__useragent_major,
      {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragent_minor::STRING as ua__useragent_minor,
      {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragent_patch::STRING as ua__useragent_patch,
      {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragent_version::STRING as ua__useragent_version,
      {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].os_family::STRING as ua__os_family,
      {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].os_major::STRING as ua__os_major,
      {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].os_minor::STRING as ua__os_minor,
      {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].os_patch::STRING as ua__os_patch,
      {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].os_patch_minor::STRING as ua__os_patch_minor,
      {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].os_version::STRING as ua__os_version,
      {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].device_family::STRING as ua__device_family
  {%- else -%}
      cast(null as {{ type_string() }}) as ua__useragent_family,
      cast(null as {{ type_string() }}) as ua__useragent_major,
      cast(null as {{ type_string() }}) as ua__useragent_minor,
      cast(null as {{ type_string() }}) as ua__useragent_patch,
      cast(null as {{ type_string() }}) as ua__useragent_version,
      cast(null as {{ type_string() }}) as ua__ua_os_family,
      cast(null as {{ type_string() }}) as ua__os_major,
      cast(null as {{ type_string() }}) as ua__os_minor,
      cast(null as {{ type_string() }}) as ua__os_patch,
      cast(null as {{ type_string() }}) as ua__os_patch_minor,
      cast(null as {{ type_string() }}) as ua__os_version,
      cast(null as {{ type_string() }}) as ua__device_family
  {%- endif -%}
{% endmacro %}

{% macro snowflake__get_ua_context_fields(table_prefix = none) %}
{%- if var('snowplow__enable_ua', false) -%}
  {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:useragentFamily::VARCHAR as ua__useragent_family,
  {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:useragentMajor::VARCHAR as ua__useragent_major,
  {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:useragentMinor::VARCHAR as ua__useragent_minor,
  {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:useragentPatch::VARCHAR as ua__useragent_patch,
  {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:useragentVersion::VARCHAR as ua__useragent_version,
  {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:osFamily::VARCHAR as ua__os_family,
  {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:osMajor::VARCHAR as ua__os_major,
  {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:osMinor::VARCHAR as ua__os_minor,
  {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:osPatch::VARCHAR as ua__os_patch,
  {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:osPatchMinor::VARCHAR as ua__os_patch_minor,
  {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:osVersion::VARCHAR as ua__os_version,
  {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0]:deviceFamily::VARCHAR as ua__device_family
{%- else -%}
  cast(null as {{ type_string() }}) as ua__useragent_family,
  cast(null as {{ type_string() }}) as ua__useragent_major,
  cast(null as {{ type_string() }}) as ua__useragent_minor,
  cast(null as {{ type_string() }}) as ua__useragent_patch,
  cast(null as {{ type_string() }}) as ua__useragent_version,
  cast(null as {{ type_string() }}) as ua__os_family,
  cast(null as {{ type_string() }}) as ua__os_major,
  cast(null as {{ type_string() }}) as ua__os_minor,
  cast(null as {{ type_string() }}) as ua__os_patch,
  cast(null as {{ type_string() }}) as ua__os_patch_minor,
  cast(null as {{ type_string() }}) as ua__os_version,
  cast(null as {{ type_string() }}) as ua__device_family
{% endif %}
{% endmacro %}
