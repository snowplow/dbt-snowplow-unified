{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro snowflake_stage_events_query(events_relation, sessions_relation, session_timestamp, app_ids=[]) %}
  {# Use the same limits as base_create_snowplow_events_this_run. The new-event
     window alone would discard earlier events in sessions being reprocessed. #}
  {% set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(
      sessions_relation, 'start_tstamp', 'end_tstamp') %}

  {% if execute and var('snowplow__snowflake_lakeloader', false) %}
    {% set columns = adapter.get_columns_in_relation(events_relation) %}
  {% else %}
    {% set columns = [] %}
  {% endif %}

  select
    {% if columns %}
      {# Match the existing base-events conversion for Lake Loader structured
         entities before writing them to a regular Snowflake scratch table. #}
      {% for col in columns %}
        {% set column_name = adapter.quote(col.name) %}
        {% if col.name.upper().startswith('CONTEXTS_') %}
          cast(e.{{ column_name }} as array) as {{ column_name }}
        {% elif col.name.upper().startswith('UNSTRUCT_') %}
          cast(e.{{ column_name }} as object) as {{ column_name }}
        {% else %}
          e.{{ column_name }}
        {% endif %}
        {% if not loop.last %},{% endif %}
      {% endfor %}
    {% else %}
      e.*
    {% endif %}
  from {{ events_relation }} e
  where e.{{ session_timestamp }} >= {{ lower_limit }}
    and e.{{ session_timestamp }} <= {{ upper_limit }}
    and {{ snowplow_utils.app_id_filter(app_ids) }}
{% endmacro %}
