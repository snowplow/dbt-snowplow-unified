{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro event_counts_string_query() %}
  {{ return(adapter.dispatch('event_counts_string_query', 'snowplow_unified')()) }}
{% endmacro %}

{% macro default__event_counts_string_query() %}
  {% set event_names =  dbt_utils.get_column_values(ref('snowplow_unified_events_this_run'), 'event_name', order_by = 'event_name', default = []) %}
  {# Loop over every event_name in this run, create a json string of the name and count ONLY if there are events with that name in the session (otherwise empty string),
  then trim off the last comma (cannot use loop.first/last because first/last entry may not have any events for that session)
  #}

  '{' || rtrim(
  {%- for event_name in event_names %}
      case when sum(case when event_name = '{{event_name}}' then 1 else 0 end) > 0 then '"{{event_name}}" :' || sum(case when event_name = '{{event_name}}' then 1 else 0 end) || ', ' else '' end ||
  {%- endfor -%}
  '', ', ') || '}'

{% endmacro %}

{% macro bigquery__event_counts_string_query() %}
  {% set event_names =  dbt_utils.get_column_values(ref('snowplow_unified_events_this_run'), 'event_name', order_by = 'event_name', default = []) %}
  {# Loop over every event_name in this run, create a json string of the name and count ONLY if there are events with that name in the session (otherwise empty string),
  then trim off the last comma (cannot use loop.first/last because first/last entry may not have any events for that session)
  #}

  '{' || RTRIM(
  {%- for event_name in event_names %}
      case when sum(case when event_name = '{{event_name}}' then 1 else 0 end) > 0 then '"{{event_name}}" :' || sum(case when event_name = '{{event_name}}' then 1 else 0 end) || ', ' else '' end ||
  {%- endfor -%}
  '', ', ') || '}'

{% endmacro %}

{% macro spark__event_counts_string_query() %}

  {% set event_names =  dbt_utils.get_column_values(ref('snowplow_unified_base_events_this_run'), 'event_name', order_by = 'event_name', default = []) %}
  {# Loop over every event_name in this run, create a map of the name and count, later filter for only events with that name in the session #}
  {% if event_names %}
    map(
    {%- for event_name in event_names %}
        '{{event_name}}',  sum(case when event_name = '{{event_name}}' then 1 else 0 end){% if not loop.last %},{% endif %}
    {%- endfor -%}
    )
  {% else %}
    cast(null as map<string, int>)
  {% endif %}

{% endmacro %}

{% macro postgres__event_counts_string_query() %}
  {% set event_names =  dbt_utils.get_column_values(ref('snowplow_unified_events_this_run'), 'event_name', order_by = 'event_name', default = []) %}
  {# Loop over every event_name in this run, create a json string of the name and count ONLY if there are events with that name in the session (otherwise empty string),
  then trim off the last comma (cannot use loop.first/last because first/last entry may not have any events for that session)
  #}

  '{' || rtrim(
  {%- for event_name in event_names %}
      case when sum(case when event_name = '{{event_name}}' then 1 else 0 end) > 0 then '"{{event_name}}" :' || sum(case when event_name = '{{event_name}}' then 1 else 0 end) || ', ' else '' end ||
  {%- endfor -%}
  '', ', ') || '}'

{% endmacro %}
