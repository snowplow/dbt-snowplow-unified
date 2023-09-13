{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro get_session_context_fields(table_prefix = none) %}
  {{ return(adapter.dispatch('get_session_context_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro postgres__get_session_context_fields(table_prefix = none) %}
  {% if var('snowplow__enable_mobile', false) %}
  {% else %}
    , cast(null as {{ type_string() }}) as session__session_id
    , cast(null as {{ type_numeric() }}) as session__session_index
    , cast(null as {{ type_string() }}) as session__previous_session_id
    , cast(null as {{ type_string() }}) as session__user_id
    , cast(null as {{ type_string() }}) as session__first_event_id
    , cast(null as {{ type_numeric() }}) as session__event_index
    , cast(null as {{ type_string() }}) as session__storage_mechanism
    , cast(null as {{ type_string() }}) as session__first_event_timestamp
  {% endif %}
{% endmacro %}

{% macro bigquery__get_session_context_fields(table_prefix = none) %}
  {% if var('snowplow__enable_mobile', false) %}
    ,{{ snowplow_utils.get_optional_fields(
          enabled=true,
          col_prefix='contexts_com_snowplowanalytics_snowplow_client_session_1_',
          fields=session_context_fields(),
          relation=source('atomic', 'events') if project_name != 'snowplow_unified_integration_tests' else ref('snowplow_unified_events_stg'),
          relation_alias=table_prefix) }}
    {% else %}
      , cast(null as {{ type_string() }}) as session__session_id
      , cast(null as {{ type_numeric() }}) as session__session_index
      , cast(null as {{ type_string() }}) as session__previous_session_id
      , cast(null as {{ type_string() }}) as session__user_id
      , cast(null as {{ type_string() }}) as session__first_event_id
      , cast(null as {{ type_numeric() }}) as session__event_index
      , cast(null as {{ type_string() }}) as session__storage_mechanism
      , cast(null as {{ type_string() }}) as session__first_event_timestamp
  {% endif %}
{% endmacro %}

{% macro spark__get_session_context_fields(table_prefix = none) %}
  {% if var('snowplow__enable_mobile', false) %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_client_session_1[0].session_id::STRING AS session__session_id
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_client_session_1[0].session_index::INT AS session__session_index
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_client_session_1[0].previous_session_id::STRING AS session__previous_session_id
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_client_session_1[0].user_id::STRING AS session__user_id
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_client_session_1[0].first_event_id::STRING AS session__first_event_id
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_client_session_1[0].event_index::INT AS session__event_index
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_client_session_1[0].storage_mechanism::STRING AS session__storage_mechanism
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_client_session_1[0].first_event_timestamp::STRING AS session__first_event_timestamp
  {% else %}
    , cast(null as {{ type_string() }}) as session__session_id
    , cast(null as {{ type_numeric() }}) as session__session_index
    , cast(null as {{ type_string() }}) as session__previous_session_id
    , cast(null as {{ type_string() }}) as session__user_id
    , cast(null as {{ type_string() }}) as session__first_event_id
    , cast(null as {{ type_numeric() }}) as session__event_index
    , cast(null as {{ type_string() }}) as session__storage_mechanism
    , cast(null as {{ type_string() }}) as session__first_event_timestamp
{% endif %}
{% endmacro %}

{% macro snowflake__get_session_context_fields(table_prefix = none) %}
  {% if var('snowplow__enable_mobile', false) %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_client_session_1[0]:sessionId::varchar(36) AS session__session_id
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_client_session_1[0]:sessionIndex::int AS session__session_index
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_client_session_1[0]:previousSessionId::varchar(36) AS session__previous_session_id
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_client_session_1[0]:userId::varchar(36) AS session__user_id
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_client_session_1[0]:firstEventId::varchar(36) AS session__first_event_id
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_client_session_1[0]:eventIndex::int AS session__event_index
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_client_session_1[0]:storageMechanism::varchar(36) AS session__storage_mechanism
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_client_session_1[0]:firstEventTimestamp::varchar(36) AS session__first_event_timestamp
    {% else %}
      , cast(null as {{ type_string() }}) as session__session_id
      , cast(null as {{ type_numeric() }}) as session__session_index
      , cast(null as {{ type_string() }}) as session__previous_session_id
      , cast(null as {{ type_string() }}) as session__user_id
      , cast(null as {{ type_string() }}) as session__first_event_id
      , cast(null as {{ type_numeric() }}) as session__event_index
      , cast(null as {{ type_string() }}) as session__storage_mechanism
      , cast(null as {{ type_string() }}) as session__first_event_timestamp
  {% endif %}
{% endmacro %}
