{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_screen_view_event_fields() %}
  {{ return(adapter.dispatch('get_screen_view_event_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_screen_view_event_fields() %}
  {% if var('snowplow__enable_mobile', false) %}
  {% else %}
      , cast(null as {{ snowplow_utils.type_max_string() }}) as screen_view__id
      , cast(null as {{ snowplow_utils.type_max_string() }}) as screen_view__name
      , cast(null as {{ snowplow_utils.type_max_string() }}) as screen_view__previous_id
      , cast(null as {{ snowplow_utils.type_max_string() }}) as screen_view__previous_name
      , cast(null as {{ snowplow_utils.type_max_string() }}) as screen_view__previous_type
      , cast(null as {{ snowplow_utils.type_max_string() }}) as screen_view__transition_type
      , cast(null as {{ snowplow_utils.type_max_string() }}) as screen_view__type
  {% endif %}
{% endmacro %}

{% macro bigquery__get_screen_view_event_fields() %}

  {% set bq_screen_view_event_fields = [
    {'field':('id', 'screen_view__id'), 'dtype':'string'},
    {'field':('name', 'screen_view__name'), 'dtype':'string'},
    {'field':('previous_id', 'screen_view__previous_id'), 'dtype':'string'},
    {'field':('previous_name', 'screen_view__previous_name'), 'dtype':'string'},
    {'field':('previous_type', 'screen_view__previous_type'), 'dtype':'string'},
    {'field':('transition_type', 'screen_view__transition_type'), 'dtype':'string'},
    {'field':('type', 'screen_view__type'), 'dtype':'string'}
    ] %}

  {% if var('snowplow__enable_mobile', false) %}
    ,{{ snowplow_utils.get_optional_fields(
          enabled=true,
          col_prefix='unstruct_event_com_snowplowanalytics_mobile_screen_view_1',
          fields=bq_screen_view_event_fields,
          relation=ref('snowplow_unified_events_stg') if 'integration_tests' in project_name and 'snowplow' in project_name else source('atomic', 'events') ,
          relation_alias=none) }}
    {% else %}
      , cast(null as {{ dbt.type_string() }}) as screen_view__id
      , cast(null as {{ dbt.type_string() }}) as screen_view__name
      , cast(null as {{ dbt.type_string() }}) as screen_view__previous_id
      , cast(null as {{ dbt.type_string() }}) as screen_view__previous_name
      , cast(null as {{ dbt.type_string() }}) as screen_view__previous_type
      , cast(null as {{ dbt.type_string() }}) as screen_view__transition_type
      , cast(null as {{ dbt.type_string() }}) as screen_view__type
  {% endif %}
{% endmacro %}

{% macro spark__get_screen_view_event_fields() %}
  {% if var('snowplow__enable_mobile', false) %}
    , cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1.id as STRING) AS screen_view__id
    , cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1.name as STRING) AS screen_view__name
    , cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1.previous_id as STRING) AS screen_view__previous_id
    , cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1.previous_name as STRING) AS screen_view__previous_name
    , cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1.previous_type as STRING) AS screen_view__previous_type
    , cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1.transition_type as STRING) AS screen_view__transition_type
    , cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1.type as STRING) AS screen_view__type
    {% else %}
      , cast(null as {{ dbt.type_string() }}) as screen_view__id
      , cast(null as {{ dbt.type_string() }}) as screen_view__name
      , cast(null as {{ dbt.type_string() }}) as screen_view__previous_id
      , cast(null as {{ dbt.type_string() }}) as screen_view__previous_name
      , cast(null as {{ dbt.type_string() }}) as screen_view__previous_type
      , cast(null as {{ dbt.type_string() }}) as screen_view__transition_type
      , cast(null as {{ dbt.type_string() }}) as screen_view__type
  {% endif %}
{% endmacro %}

{% macro snowflake__get_screen_view_event_fields() %}
  {% if var('snowplow__enable_mobile', false) %}
    {% if var('snowplow__snowflake_lakeloader', false) %}
      , unstruct_event_com_snowplowanalytics_mobile_screen_view_1:id::varchar(36) AS screen_view__id
      , unstruct_event_com_snowplowanalytics_mobile_screen_view_1:name::varchar AS screen_view__name
      , unstruct_event_com_snowplowanalytics_mobile_screen_view_1:previous_id::varchar(36) AS screen_view__previous_id
      , unstruct_event_com_snowplowanalytics_mobile_screen_view_1:previous_name::varchar AS screen_view__previous_name
      , unstruct_event_com_snowplowanalytics_mobile_screen_view_1:previous_type::varchar AS screen_view__previous_type
      , unstruct_event_com_snowplowanalytics_mobile_screen_view_1:transition_type::varchar AS screen_view__transition_type
      , unstruct_event_com_snowplowanalytics_mobile_screen_view_1:type::varchar AS screen_view__type
    {% else %}
      , unstruct_event_com_snowplowanalytics_mobile_screen_view_1:id::varchar(36) AS screen_view__id
      , unstruct_event_com_snowplowanalytics_mobile_screen_view_1:name::varchar AS screen_view__name
      , unstruct_event_com_snowplowanalytics_mobile_screen_view_1:previousId::varchar(36) AS screen_view__previous_id
      , unstruct_event_com_snowplowanalytics_mobile_screen_view_1:previousName::varchar AS screen_view__previous_name
      , unstruct_event_com_snowplowanalytics_mobile_screen_view_1:previousType::varchar AS screen_view__previous_type
      , unstruct_event_com_snowplowanalytics_mobile_screen_view_1:transitionType::varchar AS screen_view__transition_type
      , unstruct_event_com_snowplowanalytics_mobile_screen_view_1:type::varchar AS screen_view__type
    {% endif %}
    {% else %}
      , cast(null as {{ dbt.type_string() }}) as screen_view__id
      , cast(null as {{ dbt.type_string() }}) as screen_view__name
      , cast(null as {{ dbt.type_string() }}) as screen_view__previous_id
      , cast(null as {{ dbt.type_string() }}) as screen_view__previous_name
      , cast(null as {{ dbt.type_string() }}) as screen_view__previous_type
      , cast(null as {{ dbt.type_string() }}) as screen_view__transition_type
      , cast(null as {{ dbt.type_string() }}) as screen_view__type
  {% endif %}
{% endmacro %}
