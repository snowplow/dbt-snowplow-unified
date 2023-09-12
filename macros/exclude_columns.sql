{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro exclude_columns(columns) %}
  {{ return(adapter.dispatch('exclude_columns', 'snowplow_unified')(columns)) }}
{%- endmacro -%}

{% macro default__exclude_columns(columns) %}
  except({{columns}})
{% endmacro %}

{% macro bigquery__exclude_columns(columns) %}
  except({{columns}})
{% endmacro %}

{% macro spark__exclude_columns(columns) %}
  except({{columns}})
{% endmacro %}

{% macro snowflake__exclude_columns(columns) %}
  exclude({{columns}})
{% endmacro %}
