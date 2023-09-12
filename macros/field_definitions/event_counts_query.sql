{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro event_counts_query() %}
  {{ return(adapter.dispatch('event_counts_query', 'snowplow_unified')()) }}
{% endmacro %}

{% macro default__event_counts_query() %}
  map_filter(event_counts_string, (k, v) -> v > 0)
{% endmacro %}

{% macro bigquery__event_counts_query() %}
  safe.parse_json(event_counts_string)
{% endmacro %}

{% macro redshift__event_counts_query() %}
  json_parse(event_counts_string)
{% endmacro %}

{% macro postgres__event_counts_query() %}
cast(event_counts_string as json)
{% endmacro %}

{% macro snowflake__event_counts_query() %}
  try_parse_json(event_counts_string)
{% endmacro %}
