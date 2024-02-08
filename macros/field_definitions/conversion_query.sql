{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro conversion_query(conv_object = {}, names_only = false) %}
{{ return(adapter.dispatch('conversion_query', 'snowplow_unified')(conv_object, names_only)) }}
{% endmacro %}

{% macro default__conversion_query(conv_object, names_only = false) %}
{% if execute %}
{% do exceptions.raise_compiler_error('Macro get_field only supports Bigquery, Snowflake, Spark, Databricks, Postgres, and Redshift, it is not supported for ' ~ target.type) %}
{% endif %}
{% endmacro %}

{% macro snowflake__conversion_query(conv_object, names_only = false) %}

{% set when_condition = "cv_type = '"~ conv_object['name'] ~"'" if var('snowplow__enable_conversions', false) else conv_object['condition'] %}
{% set then_condition = "cv_value" if var('snowplow__enable_conversions', false) else conv_object['value'] %}
{% set tstamp_field = "cv_tstamp" if var('snowplow__enable_conversions', false) else "derived_tstamp" %}

{%- if not names_only %}
,COUNT(CASE WHEN {{ when_condition }} THEN 1 ELSE null END) AS cv_{{ conv_object['name'] }}_volume
{%- if conv_object.get('list_events', false) %}
,ARRAYAGG(CASE WHEN {{ when_condition }} THEN event_id ELSE null END) WITHIN GROUP (ORDER BY {{ tstamp_field }}, dvce_created_tstamp, event_id) AS cv_{{ conv_object['name'] }}_events
{%- endif -%}
{%- if conv_object.get('value', none) %}
,ARRAYAGG(CASE WHEN {{ when_condition }} THEN coalesce({{ then_condition }},{{ conv_object.get('default_value', 0) }}) ELSE null END) WITHIN GROUP (ORDER BY {{ tstamp_field }}, dvce_created_tstamp, event_id) AS cv_{{ conv_object['name'] }}_values
,SUM(CASE WHEN {{ when_condition }} THEN coalesce({{ then_condition }}, {{ conv_object.get('default_value', 0) }}) ELSE 0 END) AS cv_{{ conv_object['name'] }}_total
{%- endif %}
,MIN(CASE WHEN {{ when_condition }} THEN {{ tstamp_field }} ELSE null END) AS cv_{{ conv_object['name'] }}_first_conversion
,CAST(MAX(CASE WHEN {{ when_condition }} THEN 1 ELSE 0 END) AS {{ dbt.type_boolean() }}) AS cv_{{ conv_object['name'] }}_converted
{%- else -%}
,coalesce(cv_{{ conv_object['name'] }}_volume, 0) as cv_{{ conv_object['name'] }}_volume
{%- if conv_object.get('list_events', false) %}
,coalesce(cv_{{ conv_object['name'] }}_events, []) as cv_{{ conv_object['name'] }}_events
{%- endif %}
{%- if conv_object.get('value', none) %}
,coalesce(cv_{{ conv_object['name'] }}_values, []) as cv_{{ conv_object['name'] }}_values
,coalesce(cv_{{ conv_object['name'] }}_total, 0) as cv_{{ conv_object['name'] }}_total
{%- endif %}
,cv_{{ conv_object['name'] }}_first_conversion
,coalesce(cv_{{ conv_object['name'] }}_converted, false) as cv_{{ conv_object['name'] }}_converted
{%- endif %}
{% endmacro %}


{% macro bigquery__conversion_query(conv_object, names_only = false) %}

{% set when_condition = "cv_type = '"~ conv_object['name'] ~"'" if var('snowplow__enable_conversions', false) else conv_object['condition'] %}
{% set then_condition = "cv_value" if var('snowplow__enable_conversions', false) else conv_object['value'] %}
{% set tstamp_field = "cv_tstamp" if var('snowplow__enable_conversions', false) else "derived_tstamp" %}

{%- if not names_only %}
,COUNT(CASE WHEN {{ when_condition }} THEN 1 ELSE null END) AS cv_{{ conv_object['name'] }}_volume
{%- if conv_object.get('list_events', false) %}
,ARRAY_AGG(CASE WHEN {{ when_condition }} THEN event_id ELSE null END IGNORE NULLS ORDER BY {{ tstamp_field }}, dvce_created_tstamp, event_id) AS cv_{{ conv_object['name'] }}_events
{%- endif -%}
{%- if conv_object.get('value', none) %}
,ARRAY_AGG(CASE WHEN {{ when_condition }} THEN coalesce({{ then_condition }},{{ conv_object.get('default_value', 0) }}) ELSE null END IGNORE NULLS ORDER BY {{ tstamp_field }}, dvce_created_tstamp, event_id) AS cv_{{ conv_object['name'] }}_values
,SUM(CASE WHEN {{ when_condition }} THEN coalesce({{ then_condition }}, {{ conv_object.get('default_value', 0) }}) ELSE 0 END) AS cv_{{ conv_object['name'] }}_total
{%- endif -%}
,MIN(CASE WHEN {{ when_condition }} THEN {{ tstamp_field }} ELSE null END) AS cv_{{ conv_object['name'] }}_first_conversion
,CAST(MAX(CASE WHEN {{ when_condition }} THEN 1 ELSE 0 END) AS {{ dbt.type_boolean() }}) AS cv_{{ conv_object['name'] }}_converted
{%- else -%}
,coalesce(cv_{{ conv_object['name'] }}_volume, 0) as cv_{{ conv_object['name'] }}_volume
{%- if conv_object.get('list_events', false) %}
,coalesce(cv_{{ conv_object['name'] }}_events, []) as cv_{{ conv_object['name'] }}_events
{%- endif %}
{%- if conv_object.get('value', none) %}
,coalesce(cv_{{ conv_object['name'] }}_values, []) as cv_{{ conv_object['name'] }}_values
,coalesce(cv_{{ conv_object['name'] }}_total, 0) as cv_{{ conv_object['name'] }}_total
{%- endif %}
,cv_{{ conv_object['name'] }}_first_conversion
,coalesce(cv_{{ conv_object['name'] }}_converted, false) as cv_{{ conv_object['name'] }}_converted
{%- endif %}
{% endmacro %}


{% macro spark__conversion_query(conv_object, names_only = false) %}

{% set when_condition = "cv_type = '"~ conv_object['name'] ~"'" if var('snowplow__enable_conversions', false) else conv_object['condition'] %}
{% set then_condition = "cv_value" if var('snowplow__enable_conversions', false) else conv_object['value'] %}
{% set tstamp_field = "cv_tstamp" if var('snowplow__enable_conversions', false) else "derived_tstamp" %}

{%- if not names_only %}
,COUNT(CASE WHEN {{ when_condition }} THEN 1 ELSE null END) AS cv_{{ conv_object['name'] }}_volume
{%- if conv_object.get('list_events', false) %}
{# make an struct of the thing we want to put in an array, then the things we want to order by, collect THOSE into an array, filter out where the thing we want is null, sort those based on the other columns, then select just the thing we care about #}
,transform(array_sort(FILTER(collect_list(struct(CASE WHEN {{ when_condition }} THEN event_id ELSE null END, {{ tstamp_field }}, dvce_created_tstamp, event_id)), x -> x['col1'] is not null), (left, right) -> CASE WHEN left['{{ tstamp_field }}'] < right['{{ tstamp_field }}'] THEN -1 WHEN left['{{ tstamp_field }}'] > right['{{ tstamp_field }}'] THEN 1 WHEN left['dvce_created_tstamp'] < right['dvce_created_tstamp'] THEN -1 WHEN left['dvce_created_tstamp'] > right['dvce_created_tstamp'] THEN 1 WHEN left['event_id'] < right['event_id'] THEN -1 WHEN left['event_id'] > right['event_id'] THEN 1 ELSE 0 END), x -> x['col1']) AS cv_{{ conv_object['name'] }}_events
{%- endif -%}
{%- if conv_object.get('value', none) %}
{# make an struct of the thing we want to put in an array, then the things we want to order by, collect THOSE into an array, filter out where the thing we want is null, sort those based on the other columns, then select just the thing we care about #}
,transform(array_sort(FILTER(collect_list(struct(CASE WHEN {{ when_condition }} THEN coalesce({{ then_condition }},{{ conv_object.get('default_value', 0) }}) ELSE null END, {{ tstamp_field }}, dvce_created_tstamp, event_id)), x -> x['col1'] is not null), (left, right) -> CASE WHEN left['{{ tstamp_field }}'] < right['{{ tstamp_field }}'] THEN -1 WHEN left['{{ tstamp_field }}'] > right['{{ tstamp_field }}'] THEN 1 WHEN left['dvce_created_tstamp'] < right['dvce_created_tstamp'] THEN -1 WHEN left['dvce_created_tstamp'] > right['dvce_created_tstamp'] THEN 1 WHEN left['event_id'] < right['event_id'] THEN -1 WHEN left['event_id'] > right['event_id'] THEN 1 ELSE 0 END), x -> x['col1']) AS cv_{{ conv_object['name'] }}_values
,SUM(CASE WHEN {{ when_condition }} THEN coalesce({{ then_condition }}, {{ conv_object.get('default_value', 0) }}) ELSE 0 END) AS cv_{{ conv_object['name'] }}_total
{%- endif -%}
,MIN(CASE WHEN {{ when_condition }} THEN {{ tstamp_field }} ELSE null END) AS cv_{{ conv_object['name'] }}_first_conversion
,CAST(MAX(CASE WHEN {{ when_condition }} THEN 1 ELSE 0 END) AS {{ dbt.type_boolean() }}) AS cv_{{ conv_object['name'] }}_converted
{%- else -%}
,coalesce(cv_{{ conv_object['name'] }}_volume, 0) as cv_{{ conv_object['name'] }}_volume
{%- if conv_object.get('list_events', false) %}
,coalesce(cv_{{ conv_object['name'] }}_events, from_json("[]", "array<string>")) as cv_{{ conv_object['name'] }}_events
{%- endif %}
{%- if conv_object.get('value', none) %}
,coalesce(cv_{{ conv_object['name'] }}_values, from_json("[]", "array<string>")) as cv_{{ conv_object['name'] }}_values
,coalesce(cv_{{ conv_object['name'] }}_total, 0) as cv_{{ conv_object['name'] }}_total
{%- endif %}
,cv_{{ conv_object['name'] }}_first_conversion
,coalesce(cv_{{ conv_object['name'] }}_converted, false) as cv_{{ conv_object['name'] }}_converted
{%- endif %}
{% endmacro %}

{% macro postgres__conversion_query(conv_object = {}, names_only = false) %}

{% set when_condition = "cv_type = '"~ conv_object['name'] ~"'" if var('snowplow__enable_conversions', false) else conv_object['condition'] %}
{% set then_condition = "cv_value" if var('snowplow__enable_conversions', false) else conv_object['value'] %}
{% set tstamp_field = "cv_tstamp" if var('snowplow__enable_conversions', false) else "derived_tstamp" %}

{%- if not names_only %}
,COUNT(CASE WHEN {{ when_condition }} THEN 1 ELSE null END) AS cv_{{ conv_object['name'] }}_volume
{%- if conv_object.get('list_events', false) %}
,ARRAY_REMOVE(ARRAY_AGG(CASE WHEN {{ when_condition }} THEN event_id ELSE null END ORDER BY {{ tstamp_field }}, dvce_created_tstamp, event_id), null) AS cv_{{ conv_object['name'] }}_events
{%- endif -%}
{%- if conv_object.get('value', none) %}
,ARRAY_REMOVE(ARRAY_AGG(CASE WHEN {{ when_condition }} THEN coalesce({{ then_condition }},{{ conv_object.get('default_value', 0) }}) ELSE null END ORDER BY {{ tstamp_field }}, dvce_created_tstamp, event_id), null) AS cv_{{ conv_object['name'] }}_values
,SUM(CASE WHEN {{ when_condition }} THEN coalesce({{ then_condition }}, {{ conv_object.get('default_value', 0) }}) ELSE 0 END) AS cv_{{ conv_object['name'] }}_total
{%- endif -%}
,MIN(CASE WHEN {{ when_condition }} THEN {{ tstamp_field }} ELSE null END) AS cv_{{ conv_object['name'] }}_first_conversion
,CAST(MAX(CASE WHEN {{ when_condition }} THEN 1 ELSE 0 END) AS {{ dbt.type_boolean() }}) AS cv_{{ conv_object['name'] }}_converted
{%- else -%}
,coalesce(cv_{{ conv_object['name'] }}_volume, 0) as cv_{{ conv_object['name'] }}_volume
{%- if conv_object.get('list_events', false) %}
,coalesce(cv_{{ conv_object['name'] }}_events, string_to_array(regexp_replace('[]', '[\[\]\"]', '', 'g'),',')) as cv_{{ conv_object['name'] }}_events
{%- endif %}
{%- if conv_object.get('value', none) %}
,coalesce(cv_{{ conv_object['name'] }}_values, string_to_array(regexp_replace('[]', '[\[\]\"]', '', 'g'),',')::numeric[]) as cv_{{ conv_object['name'] }}_values
,coalesce(cv_{{ conv_object['name'] }}_total, 0) as cv_{{ conv_object['name'] }}_total
{%- endif %}
,cv_{{ conv_object['name'] }}_first_conversion
,coalesce(cv_{{ conv_object['name'] }}_converted, false) as cv_{{ conv_object['name'] }}_converted
{%- endif %}
{% endmacro %}

{% macro redshift__conversion_query(conv_object, names_only = false) %}

{% set when_condition = "cv_type = '"~ conv_object['name'] ~"'" if var('snowplow__enable_conversions', false) else conv_object['condition'] %}
{% set then_condition = "cv_value" if var('snowplow__enable_conversions', false) else conv_object['value'] %}
{% set tstamp_field = "cv_tstamp" if var('snowplow__enable_conversions', false) else "derived_tstamp" %}

{%- if not names_only %}
,COUNT(CASE WHEN {{ when_condition }} THEN 1 ELSE null END) AS cv_{{ conv_object['name'] }}_volume
{%- if conv_object.get('list_events', false) %}
,SPLIT_TO_ARRAY(LISTAGG(CASE WHEN {{ when_condition }} THEN event_id ELSE null END, ',') WITHIN GROUP (ORDER BY {{ tstamp_field }}, dvce_created_tstamp, event_id), ',') AS cv_{{ conv_object['name'] }}_events
{%- endif -%}
{%- if conv_object.get('value', none) %}
{# Want to try and use a symbol that is unlikely to be in the values due to redshift not having a single array_agg function, hence ~ not , #}
,SPLIT_TO_ARRAY(LISTAGG(CASE WHEN {{ when_condition }} THEN coalesce({{ then_condition }} ,{{ conv_object.get('default_value', 0) }}) ELSE null END, '~') WITHIN GROUP (ORDER BY {{ tstamp_field }}, dvce_created_tstamp, event_id), '~') AS cv_{{ conv_object['name'] }}_values
,SUM(CASE WHEN {{ when_condition }} THEN coalesce({{ then_condition }}, {{ conv_object.get('default_value', 0) }}) ELSE 0 END) AS cv_{{ conv_object['name'] }}_total
{%- endif -%}
,MIN(CASE WHEN {{ when_condition }} THEN {{ tstamp_field }} ELSE null END) AS cv_{{ conv_object['name'] }}_first_conversion
,CAST(MAX(CASE WHEN {{ when_condition }} THEN 1 ELSE 0 END) AS {{ dbt.type_boolean() }}) AS cv_{{ conv_object['name'] }}_converted
{%- else -%}
,coalesce(cv_{{ conv_object['name'] }}_volume, 0) as cv_{{ conv_object['name'] }}_volume
{%- if conv_object.get('list_events', false) %}
,coalesce(cv_{{ conv_object['name'] }}_events, cast(null as super)) as cv_{{ conv_object['name'] }}_events
{%- endif %}
{%- if conv_object.get('value', none) %}
,coalesce(cv_{{ conv_object['name'] }}_values, cast(null as super)) as cv_{{ conv_object['name'] }}_values
,coalesce(cv_{{ conv_object['name'] }}_total, 0) as cv_{{ conv_object['name'] }}_total
{%- endif %}
,cv_{{ conv_object['name'] }}_first_conversion
,coalesce(cv_{{ conv_object['name'] }}_converted, false) as cv_{{ conv_object['name'] }}_converted
{%- endif %}
{% endmacro %}
