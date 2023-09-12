{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro mkt_source_platform_query() %}
  {{ return(adapter.dispatch('mkt_source_platform_query', 'snowplow_unified')()) }}
{% endmacro %}

{% macro default__mkt_source_platform_query() %}
  nullif(regexp_extract(page_urlquery ,r'utm_source_platform=([^?&#]*)'), '')
{% endmacro %}

{% macro bigquery__mkt_source_platform_query() %}
  regexp_extract(page_urlquery ,r'utm_source_platform=([^?&#]*)')
{% endmacro %}

{% macro redshift__mkt_source_platform_query() %}
  nullif(regexp_substr(page_urlquery, 'utm_source_platform=([^?&#]*)', 1, 1, 'e'), '')
{% endmacro %}

{% macro postgres__mkt_source_platform_query() %}
  (regexp_match(page_urlquery, 'utm_source_platform=([^?&#]*)'))[1]
{% endmacro %}

{% macro snowflake__mkt_source_platform_query() %}
  regexp_substr(page_urlquery, 'utm_source_platform=([^?&#]*)', 1, 1, 'e')
{% endmacro %}
