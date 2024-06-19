{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}


{% macro context_existance_check() %}

  {% set contexts = {
      "snowplow__enable_mobile_context": [
          'contexts_com_snowplowanalytics_snowplow_mobile_context_1' if target.type not in ['redshift', 'postgres'] else var('snowplow__mobile_context')
      ],
      "snowplow__enable_iab": [
          'contexts_com_iab_snowplow_spiders_and_robots_1' if target.type not in ['redshift', 'postgres'] else var('snowplow__iab_context')
      ],
      "snowplow__enable_yauaa": [
          'contexts_nl_basjes_yauaa_context_1' if target.type not in ['redshift', 'postgres'] else var('snowplow__yauaa_context')
      ],
      "snowplow__enable_ua": [
          'contexts_com_snowplowanalytics_snowplow_ua_parser_context_1' if target.type not in ['redshift', 'postgres'] else var('snowplow__ua_parser_context')
      ],
      "snowplow__enable_application_context": [
          'contexts_com_snowplowanalytics_mobile_application_1' if target.type not in ['redshift', 'postgres'] else var('snowplow__application_context')
      ],
      "snowplow__enable_browser_context": [
          'contexts_com_snowplowanalytics_snowplow_web_page_1' if target.type not in ['redshift', 'postgres'] else var('snowplow__browser_context')
      ],
      "snowplow__enable_geolocation_context": [
          'contexts_com_snowplowanalytics_snowplow_geolocation_context_1' if target.type not in ['redshift', 'postgres'] else var('snowplow__geolocation_context')
      ],
      "snowplow__enable_screen_context": [
          'contexts_com_snowplowanalytics_mobile_screen_1' if target.type not in ['redshift', 'postgres'] else var('snowplow__screen_context')
      ],
      "snowplow__enable_deep_link_context": [
          'contexts_com_snowplowanalytics_mobile_deep_link_1' if target.type not in ['redshift', 'postgres'] else var('snowplow__deep_link_context')
      ],
      "snowplow__enable_screen_summary_context": [
          'contexts_com_snowplowanalytics_mobile_screen_summary_1' if target.type not in ['redshift', 'postgres'] else var('snowplow__screen_summary_context')
      ],
      "snowplow__enable_consent": [
          'unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1' if target.type not in ['redshift', 'postgres'] else var('snowplow__cmp_visible_events'),
          'unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1' if target.type not in ['redshift', 'postgres'] else var('snowplow__consent_preferences_events')
      ],
      "snowplow__enable_cwv": [
          'unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1' if target.type not in ['redshift', 'postgres'] else var('snowplow__cwv_events')
      ],
      "snowplow__enable_app_errors": [
          'unstruct_event_com_snowplowanalytics_snowplow_application_error_1' if target.type not in ['redshift', 'postgres'] else var('snowplow__application_error_events')
      ]
  }

  %}
  
  {{ return(adapter.dispatch('context_existance_check', 'snowplow_unified')(contexts)) }}

{% endmacro %}

{% macro default__context_existance_check(contexts) %}

  {% if execute %}
    {%- if flags.WHICH in ('run', 'run-operation') and var('snowplow__enable_initial_checks',false) -%}

      {% set relation = adapter.get_relation(
          database= var('snowplow__database', target.database) if target.type not in ['databricks', 'spark'] else var('snowplow__databricks_catalog', 'hive_metastore') if target.type in ['databricks'] else var('snowplow__atomic_schema', 'atomic'),
          schema=var('snowplow__atomic_schema', 'atomic'),
          identifier=var('snowplow__events_table', 'events'))
      %}
      {% if relation %}
        {% set available_contexts = dbt_utils.get_filtered_columns_in_relation(relation) %}
        {% set available_contexts = available_contexts | map("lower") | list %}

        {# Loop through contexts dictionary keys #}
        {% for context_key, context_value in contexts.items() %}

          {# Check if the context flag is true and if we should check the existance of the columns #}
          {% if var(context_key, false) | as_bool() %}

            {# In case we have multiple (e.g consent loop through all the fields needed )#}
            {% for context_value_i in context_value %}      

              {% set flags = [0] %}

              {# Looping through all available contexts #}
              {% for available_context in available_contexts %}
                  {# we split by the column we want, if its a perfect match it will have a result of ["",""] other wise if its a suffix it will result in {"", "XXXXX"} #}
                  {% if available_context.split(context_value_i)[0] | length == 0 %}
                      {% if flags[0] == 0 %}
                          {% set _ = flags.append(1) %}
                          {% set _ = flags.pop(0) %}
                      {% endif %}
                  {% endif %}
              {% endfor %}

              {% if flags[0] == 0 %}
                  {{ log(relation, info = true)}}
                  {{ log(available_contexts, info=true) }}
                  {{ exceptions.raise_compiler_error(
                      "Snowplow Error: " ~ context_value_i ~ " column not found in " ~ relation ~". Please ensure the column is present when " ~ context_key ~ " is enabled."
                  )}}
              {% endif %}

            {% endfor %}
          {% endif %}
        {% endfor %}
      {% endif %}
    {% endif %}
  {% endif %}

{% endmacro %}

{% macro postgres__context_existance_check(contexts) %}

  {% if execute %}
    {%- if flags.WHICH in ('run', 'run-operation') and var('snowplow__enable_initial_checks',false) -%}
      {% set relation = adapter.get_relation(
          database= var('snowplow__database', target.database) if target.type not in ['databricks', 'spark'] else var('snowplow__databricks_catalog', 'hive_metastore') if target.type in ['databricks'] else var('snowplow__atomic_schema', 'atomic'),
          schema=var('snowplow__atomic_schema', 'atomic'),
          identifier=var('snowplow__events_table', 'events'))
      %}
      {% if relation %}

        {# Loop through contexts dictionary keys #}
        {% for context_key, context_value in contexts.items() %}

          {# Check if the context flag is true and if we should check the existance of the columns #}
          {% if var(context_key, false) | as_bool() %}

            {# In case we have multiple (e.g consent loop through all the fields needed )#}
            {% for context_value_i in context_value %}      

              {% set flags = [0] %}

              {# Looping through all available contexts #}
                  {# we split by the column we want, if its a perfect match it will have a result of ["",""] other wise if its a suffix it will result in {"", "XXXXX"} #}
                  
              {% set relations = dbt_utils.get_relations_by_pattern(schema_pattern=var('snowplow__atomic_schema', 'atomic'), table_pattern= context_value_i) %}

                {# Check if the relation exists by assessing the length of the relations list #}
              {% if relations | length > 0 %}
                {% if flags[0] == 0 %}
                    {% set _ = flags.append(1) %}
                    {% set _ = flags.pop(0) %}
                {% endif %}
              {% endif %}

              {% if flags[0] == 0 %}
                  {{ log("Relations : " ~ relations, info = true) }}
                  {{ exceptions.raise_compiler_error(
                      "Snowplow Error: " ~ context_value_i ~ " table not found. Please ensure the table is present when " ~ context_key ~ " is enabled."
                  )}}
              {% endif %}

            {% endfor %}
          {% endif %}
        {% endfor %}
      {% endif %}
    {% endif %}
  {% endif %}

{% endmacro %}