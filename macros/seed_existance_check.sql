{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro seed_existance_check() %}
  {{ return(adapter.dispatch('seed_existance_check', 'snowplow_unified')()) }}
{% endmacro %}

{% macro default__seed_existance_check() %}
    {% if execute %}
        {# Ensure that this check is only performed during 'run' or 'build' commands #}
        {# Log the flags.WHICH#}
        {%- if flags.WHICH in ('run', 'run-operation') and var('snowplow__enable_initial_checks',false) -%}
            {% for node in graph.nodes.values() | selectattr("resource_type", "equalto", "seed") | selectattr("package_name", "equalto", "snowplow_unified") %}

                {% set schema = node.schema %}
                {% set table = node.alias %}

                {# Use dbt's method to get a list of relations matching the schema and table name pattern #}
                {% set relations = dbt_utils.get_relations_by_pattern(schema_pattern=schema, table_pattern=table) %}
                
                {# Check if the relation exists by assessing the length of the relations list #}
                {% if relations | length == 0 %}

                    {{ exceptions.raise_compiler_error(
                    "Snowplow Error: " ~ schema ~ "." ~ table ~ " does not exist. Please ensure that the seed data are available before running dbt."
                    ) }}

                {% endif %}
            {% endfor %}
        {%- endif %}
    {% endif %}
{% endmacro %}

{% macro spark__seed_existance_check() %}
    {% if execute %}
        {# Ensure that this check is only performed during 'run' or 'build' commands #}
        {%- if flags.WHICH in ('run', 'run-operation') and var('snowplow__enable_initial_checks',false) -%}
            {% for node in graph.nodes.values() | selectattr("resource_type", "equalto", "seed") | selectattr("package_name", "equalto", "snowplow_unified") %}
                
                {% set schema = node.schema %}
                {% set table = node.name %}

                {# Construct the SQL to check table existence in Spark #}
                {% set query = "SHOW TABLES IN `" ~ schema ~ "` LIKE '" ~ table ~ "'" %}
                {% set results = run_query(query) %}
                
                {% if results %}
                    {% set num_rows = results | length %}
                    {# Raise an error if the number of rows is zero #}
                    {% if num_rows == 0 %}
                        {{ exceptions.raise_compiler_error(
                    "Snowplow Error: " ~ table ~ " does not exist. Please ensure that the seed data are available before running dbt."
                    ) }}
                    {% endif %}
                {% else %}
                    {{ exceptions.raise_compiler_error(
                    "Snowplow Error: " ~ table ~ " does not exist. Please ensure that the seed data are available before running dbt."
                    ) }}
                {% endif %}

            {% endfor %}
        {%- endif %}
    {% endif %}
{% endmacro %}

