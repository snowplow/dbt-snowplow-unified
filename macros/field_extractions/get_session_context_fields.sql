{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_session_context_fields() %}
  {{ return(adapter.dispatch('get_session_context_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_session_context_fields() %}
  {% if var('snowplow__enable_mobile', false) %}
  {% else %}
    , cast(null as {{ snowplow_utils.type_max_string() }}) as session__session_id
    , cast(null as {{ dbt.type_numeric() }}) as session__session_index
    , cast(null as {{ snowplow_utils.type_max_string() }}) as session__previous_session_id
    , cast(null as {{ snowplow_utils.type_max_string() }}) as session__user_id
    , cast(null as {{ snowplow_utils.type_max_string() }}) as session__first_event_id
    , cast(null as {{ dbt.type_numeric() }}) as session__event_index
    , cast(null as {{ snowplow_utils.type_max_string() }}) as session__storage_mechanism
    , cast(null as {{ snowplow_utils.type_max_string() }}) as session__first_event_timestamp
  {% endif %}
{% endmacro %}

{% macro bigquery__get_session_context_fields() %}

  {% set bq_session_context_fields = [
    {'field':('session_id', 'session__session_id'), 'dtype':'string'},
    {'field':('session_index', 'session__session_index'), 'dtype':'integer'},
    {'field':('previous_session_id', 'session__previous_session_id'), 'dtype':'string'},
    {'field':('user_id', 'session__user_id'), 'dtype':'string'},
    {'field':('first_event_id', 'session__first_event_id'), 'dtype':'string'}
    ] %}

  {% if var('snowplow__enable_mobile', false) %}
    ,{{ snowplow_utils.get_optional_fields(
          enabled=true,
          col_prefix='contexts_com_snowplowanalytics_snowplow_client_session_1',
          fields=bq_session_context_fields,
          relation=ref('snowplow_unified_events_stg') if 'integration_tests' in project_name and 'snowplow' in project_name else source('atomic', 'events') ,
          relation_alias=none) }}
    {% else %}
      , cast(null as {{ dbt.type_string() }}) as session__session_id
      , cast(null as {{ dbt.type_numeric() }}) as session__session_index
      , cast(null as {{ dbt.type_string() }}) as session__previous_session_id
      , cast(null as {{ dbt.type_string() }}) as session__user_id
      , cast(null as {{ dbt.type_string() }}) as session__first_event_id
      , cast(null as {{ dbt.type_numeric() }}) as session__event_index
      , cast(null as {{ dbt.type_string() }}) as session__storage_mechanism
      , cast(null as {{ dbt.type_string() }}) as session__first_event_timestamp
  {% endif %}
{% endmacro %}

{% macro spark__get_session_context_fields() %}
  {% if var('snowplow__enable_mobile', false) %}
    , cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].session_id as STRING) AS session__session_id
    , cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].session_index as INT) AS session__session_index
    , cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].previous_session_id as STRING) AS session__previous_session_id
    , cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].user_id as STRING) AS session__user_id
    , cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].first_event_id as STRING) AS session__first_event_id
    , cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].event_index as INT) AS session__event_index
    , cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].storage_mechanism as STRING) AS session__storage_mechanism
    , cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].first_event_timestamp as STRING) AS session__first_event_timestamp
  {% else %}
    , cast(null as {{ dbt.type_string() }}) as session__session_id
    , cast(null as {{ dbt.type_numeric() }}) as session__session_index
    , cast(null as {{ dbt.type_string() }}) as session__previous_session_id
    , cast(null as {{ dbt.type_string() }}) as session__user_id
    , cast(null as {{ dbt.type_string() }}) as session__first_event_id
    , cast(null as {{ dbt.type_numeric() }}) as session__event_index
    , cast(null as {{ dbt.type_string() }}) as session__storage_mechanism
    , cast(null as {{ dbt.type_string() }}) as session__first_event_timestamp
{% endif %}
{% endmacro %}

{% macro snowflake__get_session_context_fields() %}
  {% if var('snowplow__enable_mobile', false) %}
    {% if var('snowplow__snowflake_lakeloader', false) %}
      , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:session_id::varchar(36) AS session__session_id
      , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:session_index::int AS session__session_index
      , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:previous_session_id::varchar(36) AS session__previous_session_id
      , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:user_id::varchar(36) AS session__user_id
      , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:first_event_id::varchar(36) AS session__first_event_id
      , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:event_index::int AS session__event_index
      , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:storage_mechanism::varchar(36) AS session__storage_mechanism
      , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:first_event_timestamp::varchar(36) AS session__first_event_timestamp
    {% else %}
      , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:sessionId::varchar(36) AS session__session_id
      , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:sessionIndex::int AS session__session_index
      , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:previousSessionId::varchar(36) AS session__previous_session_id
      , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:userId::varchar(36) AS session__user_id
      , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:firstEventId::varchar(36) AS session__first_event_id
      , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:eventIndex::int AS session__event_index
      , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:storageMechanism::varchar(36) AS session__storage_mechanism
      , contexts_com_snowplowanalytics_snowplow_client_session_1[0]:firstEventTimestamp::varchar(36) AS session__first_event_timestamp
    {% endif %}
  {% else %}
    , cast(null as {{ dbt.type_string() }}) as session__session_id
    , cast(null as {{ dbt.type_numeric() }}) as session__session_index
    , cast(null as {{ dbt.type_string() }}) as session__previous_session_id
    , cast(null as {{ dbt.type_string() }}) as session__user_id
    , cast(null as {{ dbt.type_string() }}) as session__first_event_id
    , cast(null as {{ dbt.type_numeric() }}) as session__event_index
    , cast(null as {{ dbt.type_string() }}) as session__storage_mechanism
    , cast(null as {{ dbt.type_string() }}) as session__first_event_timestamp
  {% endif %}
{% endmacro %}
