{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}


{% macro context_existance_check() %}
  {% set contexts = [
    ['snowplow__enable_mobile_context','contexts_com_snowplowanalytics_snowplow_mobile_context_1', 'snowplow__mobile_context'],
    ['snowplow__enable_iab', 'contexts_com_iab_snowplow_spiders_and_robots_1','snowplow__iab_context', 'snowplow__iab_context'],
    ['snowplow__enable_yauaa', 'contexts_nl_basjes_yauaa_context_1','snowplow__yauaa_context'],
    ['snowplow__enable_ua', 'contexts_com_snowplowanalytics_snowplow_ua_parser_context_1','snowplow__ua_parser_context'],
    ['snowplow__enable_application_context', 'contexts_com_snowplowanalytics_mobile_application_1','snowplow__application_context'],
    ['snowplow__enable_browser_context', 'contexts_com_snowplowanalytics_snowplow_web_page_1','snowplow__browser_context'],
    ['snowplow__enable_mobile_context', 'contexts_com_snowplowanalytics_snowplow_mobile_context_1','snowplow__mobile_context'],
    ['snowplow__enable_geolocation_context', 'contexts_com_snowplowanalytics_snowplow_geolocation_context_1','snowplow__geolocation_context'],
    ['snowplow__enable_screen_context', 'contexts_com_snowplowanalytics_mobile_screen_1','snowplow__screen_context'],
    ['snowplow__enable_deep_link_context', 'contexts_com_snowplowanalytics_mobile_deep_link_1','snowplow__deep_link_context'],
    ['snowplow__enable_screen_summary_context', 'contexts_com_snowplowanalytics_mobile_screen_summary_1','snowplow__screen_summary_context'],
    ['snowplow__enable_consent', 'unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1', '@!@!@!@!@!@!@!21'],
    ['snowplow__enable_cwv', 'unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1','snowplow__cwv_events'],
    ['snowplow__enable_app_errors', 'unstruct_event_com_snowplowanalytics_snowplow_application_error_1','@!@!@!@!@!@!@!21']
  ] %}
  {{ return(adapter.dispatch('context_existance_check', 'snowplow_unified')(contexts)) }}
{% endmacro %}

{% macro default__context_existance_check(contexts) %}

  {% if execute %} 
    {% set relation = adapter.get_relation(
        database=target.database,
        schema=var('snowplow__atomic_schema', 'atomic'),
        identifier=var('snowplow__events_table', 'events'))
    %}

    {% set column_names = dbt_utils.get_filtered_columns_in_relation(relation) %}

    {% set column_names = column_names | map("lower") | list %}

    {# {{log(contexts, info = True)}}   #}

    {% for context in contexts %}

      {% if var(context[0]) | as_bool() and context[1] | lower not in column_names %}
        {# {{ log("Issue with : "~context[0], info=True)}} #}
        {{ exceptions.raise_compiler_error(
          "Snowplow Error: "~context[1]~" column not found. Please ensure the column is present when "~context[0]~" is enabled."
        )}}
      {% endif %}
      {# {{log("All Good with "~context[0], info=True)}} #}

    {% endfor %}
  {% endif %}
{% endmacro %}

{% macro postgress__context_existance_check(contexts) %}

  {% set relation = adapter.get_relation(
      database=target.database,
      schema=var('snowplow__atomic_schema', 'atomic'),
      identifier=var('snowplow__events_table', 'events'))
  %}

  {% for context in contexts %}
    
    {% set context_flag = context[0] %}
    {% set context_source = context[1] %}
    {% set post_redshift_table = context[2] %}
    {% if var(context_flag) %}
      {% if relation %}
        {% set query %}
          SELECT DISTINCT table_name
          FROM `{{ target.database }}.{{ relation.schema }}.INFORMATION_SCHEMA.COLUMNS`
          WHERE table_name = '{{ post_redshift_table }}'
        {% endset %}

        {% set results = run_query(query) %}
        {% if execute %}
          {% set data = results.columns[0].values() %}
          {% if var(context_flag) | as_bool() and data|length == 0 %}
            {# {{ log("Issue with : "~context[0], info=True)}} #}
            {{ exceptions.raise_compiler_error(
              "Snowplow Error: "~post_redshift_table~" table not found. Please ensure the column is present when "~context_flag~" is enabled."
            )}}        {% endif %}
        {% endif %}
      {% endif %}
    {% endif %}
    {# {{log("All Good with " ~ context_flag, info=True)}} #}
  {% endfor %}
{% endmacro %}

{% macro bigquery__context_existance_check(contexts) %}

  {% set relation = adapter.get_relation(
      database=target.database,
      schema=var('snowplow__atomic_schema', 'atomic'),
      identifier=var('snowplow__events_table', 'events'))
  %}

  {% for context in contexts %}
    
    {% set context_flag = context[0] %}
    {% set context_source = context[1] %}
    {% if var(context_flag) %}
      {% if relation %}
        {% set query %}
          SELECT column_name
          FROM `{{ target.database }}.{{ relation.schema }}.INFORMATION_SCHEMA.COLUMNS`
          WHERE table_name = '{{ relation.name }}'
          AND column_name LIKE LOWER('{{ context_source }}%')
        {% endset %}

        {% set results = run_query(query) %}
        {% if execute %}
          {% set data = results.columns[0].values() %}
          {% if var(context_flag) | as_bool() and data|length == 0 %}
            {# {{ log("Issue with : "~context[0], info=True)}} #}
            {{ exceptions.raise_compiler_error(
              "Snowplow Error: "~context[1]~" column not found. Please ensure the column is present when "~context[0]~" is enabled."
            )}} 
          {% endif %}
        {% endif %}
      {% endif %}
    {% endif %}

    {# {{log("All Good with " ~ context[0], info=True)}} #}
  {% endfor %}
{% endmacro %}