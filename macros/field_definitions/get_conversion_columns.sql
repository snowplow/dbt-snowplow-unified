{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_conversion_columns(conv_object = {}, names_only = false) %}
  {{ return(adapter.dispatch('get_conversion_columns', 'snowplow_unified')(conv_object, names_only)) }}
{% endmacro %}

{% macro default__get_conversion_columns(conv_object, names_only = false) %}
{% if execute %}
    {% do exceptions.raise_compiler_error('Macro get_field only supports Bigquery, Snowflake, Spark, Databricks, Postgres, and Redshift, it is not supported for ' ~ target.type) %}
{% endif %}
{% endmacro %}

{% macro snowflake__get_conversion_columns(conv_object, names_only = false) %}
  {%- if not names_only %}
    ,COUNT(CASE WHEN cv_type = '{{ conv_object['name'] }}' THEN 1 ELSE null END) AS cv_{{ conv_object['name'] }}_volume
    {%- if conv_object.get('list_events', false) %}
    ,ARRAYAGG(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN event_id ELSE null END) WITHIN GROUP (ORDER BY cv_tstamp, dvce_created_tstamp, event_id) AS cv_{{ conv_object['name'] }}_events
    {%- endif -%}
    {%- if conv_object.get('value', none) %}
    ,ARRAYAGG(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN coalesce(cv_value,{{ conv_object.get('default_value', 0) }})  ELSE null END) WITHIN GROUP (ORDER BY cv_tstamp, dvce_created_tstamp, event_id) AS cv_{{ conv_object['name'] }}_values
    ,SUM(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN coalesce(cv_value, {{ conv_object.get('default_value', 0) }}) ELSE 0 END) AS cv_{{ conv_object['name'] }}_total
    {%- endif %}
    ,MIN(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN cv_tstamp ELSE null END) AS cv_{{ conv_object['name'] }}_first_conversion
    ,CAST(MAX(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN 1 ELSE 0 END) AS {{ type_boolean() }}) AS cv_{{ conv_object['name'] }}_converted
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


{% macro bigquery__get_conversion_columns(conv_object, names_only = false) %}
  {%- if not names_only %}
    ,COUNT(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN 1 ELSE null END) AS cv_{{ conv_object['name'] }}_volume
    {%- if conv_object.get('list_events', false) %}
    ,ARRAY_AGG(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN event_id ELSE null END IGNORE NULLS ORDER BY cv_tstamp, dvce_created_tstamp, event_id) AS cv_{{ conv_object['name'] }}_events
    {%- endif -%}
    {%- if conv_object.get('value', none) %}
    ,ARRAY_AGG(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN coalesce(cv_value,{{ conv_object.get('default_value', 0) }})  ELSE null END IGNORE NULLS ORDER BY cv_tstamp, dvce_created_tstamp, event_id) AS cv_{{ conv_object['name'] }}_values
    ,SUM(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN coalesce(cv_value, {{ conv_object.get('default_value', 0) }})  ELSE 0 END) AS cv_{{ conv_object['name'] }}_total
    {%- endif -%}
    ,MIN(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN cv_tstamp ELSE null END) AS cv_{{ conv_object['name'] }}_first_conversion
    ,CAST(MAX(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN 1 ELSE 0 END) AS {{ type_boolean() }}) AS cv_{{ conv_object['name'] }}_converted
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


{% macro spark__get_conversion_columns(conv_object, names_only = false) %}
  {%- if not names_only %}
    ,COUNT(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN 1 ELSE null END) AS cv_{{ conv_object['name'] }}_volume
    {%- if conv_object.get('list_events', false) %}
    {# make an struct of the thing we want to put in an array, then the things we want to order by, collect THOSE into an array, filter out where the thing we want is null, sort those based on the other columns, then select just the thing we care about #}
    ,transform(array_sort(FILTER(collect_list(struct(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN event_id ELSE null END, cv_tstamp, dvce_created_tstamp, event_id)), x -> x['col1'] is not null), (left, right) -> CASE WHEN left['cv_tstamp']  < right['cv_tstamp'] THEN -1 WHEN left['cv_tstamp']  > right['cv_tstamp'] THEN 1 WHEN left['dvce_created_tstamp']  < right['dvce_created_tstamp'] THEN -1 WHEN left['dvce_created_tstamp']  > right['dvce_created_tstamp'] THEN 1 WHEN left['event_id']  < right['event_id'] THEN -1 WHEN left['event_id']  > right['event_id'] THEN 1 ELSE 0 END), x -> x['col1'])  AS cv_{{ conv_object['name'] }}_events
    {%- endif -%}
    {%- if conv_object.get('value', none) %}
    {# make an struct of the thing we want to put in an array, then the things we want to order by, collect THOSE into an array, filter out where the thing we want is null, sort those based on the other columns, then select just the thing we care about #}
    ,transform(array_sort(FILTER(collect_list(struct(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN coalesce(cv_value,{{ conv_object.get('default_value', 0) }})  ELSE null END, cv_tstamp, dvce_created_tstamp, event_id)), x -> x['col1'] is not null), (left, right) -> CASE WHEN left['cv_tstamp']  < right['cv_tstamp'] THEN -1 WHEN left['cv_tstamp']  > right['cv_tstamp'] THEN 1 WHEN left['dvce_created_tstamp']  < right['dvce_created_tstamp'] THEN -1 WHEN left['dvce_created_tstamp']  > right['dvce_created_tstamp'] THEN 1 WHEN left['event_id']  < right['event_id'] THEN -1 WHEN left['event_id']  > right['event_id'] THEN 1 ELSE 0 END), x -> x['col1'])  AS cv_{{ conv_object['name'] }}_values
    ,SUM(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN coalesce(cv_value, {{ conv_object.get('default_value', 0) }})  ELSE 0 END) AS cv_{{ conv_object['name'] }}_total
    {%- endif -%}
    ,MIN(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN cv_tstamp ELSE null END) AS cv_{{ conv_object['name'] }}_first_conversion
    ,CAST(MAX(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN 1 ELSE 0 END) AS {{ type_boolean() }}) AS cv_{{ conv_object['name'] }}_converted
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

{% macro postgres__get_conversion_columns(conv_object = {}, names_only = false) %}
  {%- if not names_only %}
    ,COUNT(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN 1 ELSE null END) AS cv_{{ conv_object['name'] }}_volume
    {%- if conv_object.get('list_events', false) %}
    ,ARRAY_REMOVE(ARRAY_AGG(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN event_id ELSE null END ORDER BY cv_tstamp, dvce_created_tstamp, event_id), null) AS cv_{{ conv_object['name'] }}_events
    {%- endif -%}
    {%- if conv_object.get('value', none) %}
    ,ARRAY_REMOVE(ARRAY_AGG(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN coalesce(cv_value,{{ conv_object.get('default_value', 0) }})  ELSE null END ORDER BY cv_tstamp, dvce_created_tstamp, event_id), null) AS cv_{{ conv_object['name'] }}_values
    ,SUM(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN coalesce(cv_value, {{ conv_object.get('default_value', 0) }})  ELSE 0 END) AS cv_{{ conv_object['name'] }}_total
    {%- endif -%}
    ,MIN(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN cv_tstamp ELSE null END) AS cv_{{ conv_object['name'] }}_first_conversion
    ,CAST(MAX(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN 1 ELSE 0 END) AS {{ type_boolean() }}) AS cv_{{ conv_object['name'] }}_converted
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

{% macro redshift__get_conversion_columns(conv_object, names_only = false) %}
  {%- if not names_only %}
    ,COUNT(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN 1 ELSE null END) AS cv_{{ conv_object['name'] }}_volume
    {%- if conv_object.get('list_events', false) %}
    ,SPLIT_TO_ARRAY(LISTAGG(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN event_id ELSE null END, ',') WITHIN GROUP (ORDER BY cv_tstamp, dvce_created_tstamp, event_id), ',') AS cv_{{ conv_object['name'] }}_events
    {%- endif -%}
    {%- if conv_object.get('value', none) %}
    {# Want to try and use a symbol that is unlikely to be in the values due to redshift not having a single array_agg function, hence ~ not , #}
    ,SPLIT_TO_ARRAY(LISTAGG(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN coalesce(cv_value,{{ conv_object.get('default_value', 0) }})  ELSE null END, '~') WITHIN GROUP (ORDER BY cv_tstamp, dvce_created_tstamp, event_id), '~') AS cv_{{ conv_object['name'] }}_values
    ,SUM(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN coalesce(cv_value, {{ conv_object.get('default_value', 0) }})  ELSE 0 END) AS cv_{{ conv_object['name'] }}_total
    {%- endif -%}
    ,MIN(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN cv_tstamp ELSE null END) AS cv_{{ conv_object['name'] }}_first_conversion
    ,CAST(MAX(CASE WHEN cv_type = '{{ conv_object['name'] }}'  THEN 1 ELSE 0 END) AS {{ type_boolean() }}) AS cv_{{ conv_object['name'] }}_converted
  {%- else -%}
    ,coalesce(cv_{{ conv_object['name'] }}_volume, 0) as cv_{{ conv_object['name'] }}_volume
    {%- if conv_object.get('list_events', false) %}
    ,coalesce(cv_{{ conv_object['name'] }}_events, nullif(split_to_array(translate('[]', '[]"]', ''),','), array())) as cv_{{ conv_object['name'] }}_events
    {%- endif %}
    {%- if conv_object.get('value', none) %}
    ,coalesce(cv_{{ conv_object['name'] }}_values, nullif(split_to_array(translate('[]', '[]"]', ''),','), array())) as cv_{{ conv_object['name'] }}_values
    ,coalesce(cv_{{ conv_object['name'] }}_total, 0) as cv_{{ conv_object['name'] }}_total
    {%- endif %}
    ,cv_{{ conv_object['name'] }}_first_conversion
    ,coalesce(cv_{{ conv_object['name'] }}_converted, false) as cv_{{ conv_object['name'] }}_converted
  {%- endif %}
{% endmacro %}
