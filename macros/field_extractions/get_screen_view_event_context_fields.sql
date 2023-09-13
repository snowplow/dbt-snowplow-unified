{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro get_screen_view_event_fields(table_prefix = none) %}
  {{ return(adapter.dispatch('get_screen_view_event_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro postgres__get_screen_view_event_fields(table_prefix = none) %}
  {% if var('snowplow__enable_mobile', false) %}
  {% else %}
    ,cast(null as {{ type_string() }}) as screen_view__id,
    cast(null as {{ type_string() }}) as screen_view__name,
    cast(null as {{ type_string() }}) as screen_view__previous_id,
    cast(null as {{ type_string() }}) as screen_view__previous_name,
    cast(null as {{ type_string() }}) as screen_view__previous_type,
    cast(null as {{ type_string() }}) as screen_view__transition_type,
    cast(null as {{ type_string() }}) as screen_view__type
  {% endif %}
{% endmacro %}

{% macro bigquery__get_screen_view_event_fields(table_prefix = none) %}
  {% if var('snowplow__enable_mobile', false) %}
    ,{{ snowplow_utils.get_optional_fields(
          enabled=true,
          col_prefix='unstruct_event_com_snowplowanalytics_mobile_screen_view_1_',
          fields=screen_view_event_fields(),
          relation=source('atomic', 'events') if project_name != 'snowplow_unified_integration_tests' else ref('snowplow_unified_events_stg'),
          relation_alias=table_prefix) }}
    {% else %}
      ,cast(null as {{ type_string() }}) as screen_view__id,
      cast(null as {{ type_string() }}) as screen_view__name,
      cast(null as {{ type_string() }}) as screen_view__previous_id,
      cast(null as {{ type_string() }}) as screen_view__previous_name,
      cast(null as {{ type_string() }}) as screen_view__previous_type,
      cast(null as {{ type_string() }}) as screen_view__transition_type,
      cast(null as {{ type_string() }}) as screen_view__type
  {% endif %}
{% endmacro %}

{% macro spark__get_screen_view_event_fields(table_prefix = none) %}
  {% if var('snowplow__enable_mobile', false) %}
    ,{% if table_prefix %}{{ table_prefix~"." }}{% endif %}unstruct_event_com_snowplowanalytics_mobile_screen_view_1.id::STRING AS screen_view__id,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}unstruct_event_com_snowplowanalytics_mobile_screen_view_1.name::STRING AS screen_view__name,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}unstruct_event_com_snowplowanalytics_mobile_screen_view_1.previous_id::STRING AS screen_view__previous_id,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}unstruct_event_com_snowplowanalytics_mobile_screen_view_1.previous_name::STRING AS screen_view__previous_name,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}unstruct_event_com_snowplowanalytics_mobile_screen_view_1.previous_type::STRING AS screen_view__previous_type,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}unstruct_event_com_snowplowanalytics_mobile_screen_view_1.transition_type::STRING AS screen_view__transition_type,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}unstruct_event_com_snowplowanalytics_mobile_screen_view_1.type::STRING AS screen_view__type
    {% else %}
      ,cast(null as {{ type_string() }}) as screen_view__id,
      cast(null as {{ type_string() }}) as screen_view__name,
      cast(null as {{ type_string() }}) as screen_view__previous_id,
      cast(null as {{ type_string() }}) as screen_view__previous_name,
      cast(null as {{ type_string() }}) as screen_view__previous_type,
      cast(null as {{ type_string() }}) as screen_view__transition_type,
      cast(null as {{ type_string() }}) as screen_view__type
  {% endif %}
{% endmacro %}

{% macro snowflake__get_screen_view_event_fields(table_prefix = none) %}
  {% if var('snowplow__enable_mobile', false) %}
    ,{% if table_prefix %}{{ table_prefix~"." }}{% endif %}unstruct_event_com_snowplowanalytics_mobile_screen_view_1:id::varchar(36) AS screen_view__id,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}unstruct_event_com_snowplowanalytics_mobile_screen_view_1:name::varchar AS screen_view__name,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}unstruct_event_com_snowplowanalytics_mobile_screen_view_1:previousId::varchar(36) AS screen_view__previous_id,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}unstruct_event_com_snowplowanalytics_mobile_screen_view_1:previousName::varchar AS screen_view__previous_name,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}unstruct_event_com_snowplowanalytics_mobile_screen_view_1:previousType::varchar AS screen_view__previous_type,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}unstruct_event_com_snowplowanalytics_mobile_screen_view_1:transitionType::varchar AS screen_view__transition_type,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}unstruct_event_com_snowplowanalytics_mobile_screen_view_1:type::varchar AS screen_view__type
    {% else %}
      ,cast(null as {{ type_string() }}) as screen_view__id,
      cast(null as {{ type_string() }}) as screen_view__name,
      cast(null as {{ type_string() }}) as screen_view__previous_id,
      cast(null as {{ type_string() }}) as screen_view__previous_name,
      cast(null as {{ type_string() }}) as screen_view__previous_type,
      cast(null as {{ type_string() }}) as screen_view__transition_type,
      cast(null as {{ type_string() }}) as screen_view__type
  {% endif %}
{% endmacro %}
