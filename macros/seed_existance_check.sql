{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro seed_existance_check() %}
    {% if execute %}
        {# Ensure that this check is only performed during 'run' or 'build' commands #}
        {%- if flags.WHICH in ('run') -%}
            {% for node in graph.nodes.values() | selectattr("resource_type", "equalto", "seed") %}

                {# Convert schema and table names to uppercase to prevent case sensitivity issues #}
                {% set schema = node.schema | upper %}
                {% set table = node.alias | upper %}
                
                {# Construct a SQL query to check if the seed table exists in the information schema #}
                {% set check_table_exists_query = """SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '" ~ schema ~ "' AND table_name = '" ~ table ~ "'" %}
                
                {% set results = run_query(check_table_exists_query) %}
                {% set table_exists = results.columns[0][0] if results and results.columns[0] else 0 %}
                
                {# Log an error and fail the run if the table does not exist #}
                {% if table_exists | int == 0 %}
                    {% do log(node.unique_id ~ " does not exist.", info=true) %}

                    {# This is a bad way to handle this, but it's the only way to fail a dbt macro
                    running in the on-run-start hook while in execution mode. We do this until the update #}
                    
                    {{ 0/0 }}

                {% endif %}
            {% endfor %}
        {%- endif %}
    {% endif %}
{% endmacro %}
 