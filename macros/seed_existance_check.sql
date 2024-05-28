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
        {%- if flags.WHICH in ('run', 'run-operation') -%}
            {% for node in graph.nodes.values() | selectattr("resource_type", "equalto", "seed") | selectattr("package_name", "equalto", "snowplow_unified") %}

                {# {{ log(node | tojson, info=True) }} #}

                {# Convert schema and table names to uppercase to prevent case sensitivity issues #}
                {% set schema = node.schema | upper %}
                {% set table = node.alias | upper %}
                
                {# Use dbt's method to get a list of relations matching the schema and table name pattern #}
                {% set relations = dbt_utils.get_relations_by_pattern(schema_pattern=schema, table_pattern=table) %}
                
                {# Check if the relation exists by assessing the length of the relations list #}
                {% if relations | length == 0 %}

                    {{ exceptions.raise_compiler_error(
                    "Snowplow Error: " ~ table ~ " does not exist. Please ensure that the seed data are available before running dbt."
                    ) }}

                {% endif %}
            {% endfor %}
        {%- endif %}
    {% endif %}
{% endmacro %}
