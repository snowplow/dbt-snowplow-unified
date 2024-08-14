{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_mobile_context_fields() %}
    {{ return(adapter.dispatch('get_mobile_context_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_mobile_context_fields() %}
  {% if var('snowplow__enable_mobile_context', false) %}
  {% else %}
    , cast(null as {{ snowplow_utils.type_max_string() }}) as mobile__device_manufacturer
    , cast(null as {{ snowplow_utils.type_max_string() }}) as mobile__device_model
    , cast(null as {{ snowplow_utils.type_max_string() }}) as mobile__os_type
    , cast(null as {{ snowplow_utils.type_max_string() }}) as mobile__os_version
    , cast(null as {{ snowplow_utils.type_max_string() }}) as mobile__android_idfa
    , cast(null as {{ snowplow_utils.type_max_string() }}) as mobile__apple_idfa
    , cast(null as {{ snowplow_utils.type_max_string() }}) as mobile__apple_idfv
    , cast(null as {{ snowplow_utils.type_max_string() }}) as mobile__carrier
    , cast(null as {{ snowplow_utils.type_max_string() }}) as mobile__open_idfa
    , cast(null as {{ snowplow_utils.type_max_string() }}) as mobile__network_technology
    , cast(null as {{ snowplow_utils.type_max_string() }}) as mobile__network_type
    , cast(null as {{ dbt.type_int() }}) as mobile__physical_memory
    , cast(null as {{ dbt.type_int() }}) as mobile__system_available_memory
    , cast(null as {{ dbt.type_int() }}) as mobile__app_available_memory
    , cast(null as {{ dbt.type_int() }}) as mobile__battery_level
    , cast(null as {{ snowplow_utils.type_max_string() }}) as mobile__battery_state
    , cast(null as {{ dbt.type_boolean() }}) as mobile__low_power_mode
    , cast(null as bigint) as mobile__available_storage
    , cast(null as bigint) as mobile__total_storage
    , cast(null as {{ dbt.type_boolean() }}) as mobile__is_portrait
    , cast(null as {{ snowplow_utils.type_max_string() }}) as mobile__resolution
    , cast(null as {{ dbt.type_float() }}) as mobile__scale
    , cast(null as {{ snowplow_utils.type_max_string() }}) as mobile__language
    , cast(null as {{ snowplow_utils.type_max_string() }}) as mobile__app_set_id
    , cast(null as {{ snowplow_utils.type_max_string() }}) as mobile__app_set_id_scope
  {% endif %}
{% endmacro %}

{% macro bigquery__get_mobile_context_fields() %}

  {% set bq_mobile_context_fields = [
    {'field':('device_manufacturer', 'mobile__device_manufacturer'), 'dtype':'string'},
    {'field':('device_model', 'mobile__device_model'), 'dtype':'string'},
    {'field':('os_type', 'mobile__os_type'), 'dtype':'string'},
    {'field':('os_version', 'mobile__os_version'), 'dtype':'string'},
    {'field':('android_idfa', 'mobile__android_idfa'), 'dtype':'string'},
    {'field':('apple_idfa', 'mobile__apple_idfa'), 'dtype':'string'},
    {'field':('apple_idfv', 'mobile__apple_idfv'), 'dtype':'string'},
    {'field':('carrier', 'mobile__carrier'), 'dtype':'string'},
    {'field':('open_idfa', 'mobile__open_idfa'), 'dtype':'string'},
    {'field':('network_technology', 'mobile__network_technology'), 'dtype':'string'},
    {'field':('network_type', 'mobile__network_type'), 'dtype':'string'},
    {'field':('physical_memory', 'mobile__physical_memory'), 'dtype':'integer'},
    {'field':('system_available_memory', 'mobile__system_available_memory'), 'dtype':'integer'},
    {'field':('app_available_memory', 'mobile__app_available_memory'), 'dtype':'integer'},
    {'field':('battery_level', 'mobile__battery_level'), 'dtype':'integer'},
    {'field':('battery_state', 'mobile__battery_state'), 'dtype':'string'},
    {'field':('low_power_mode', 'mobile__low_power_mode'), 'dtype':'boolean'},
    {'field':('available_storage', 'mobile__available_storage'), 'dtype':'integer'},
    {'field':('total_storage', 'mobile__total_storage'), 'dtype':'integer'},
    {'field':('is_portrait', 'mobile__is_portrait'), 'dtype':'boolean'},
    {'field':('resolution', 'mobile__resolution'), 'dtype':'string'},
    {'field':('scale', 'mobile__scale'), 'dtype':'integer'},
    {'field':('language', 'mobile__language'), 'dtype':'string'},
    {'field':('app_set_id', 'mobile__app_set_id'), 'dtype':'string'},
    {'field':('app_set_id_scope', 'mobile__app_set_id_scope'), 'dtype':'string'}
    ] %}

  {% if var('snowplow__enable_mobile_context', false) %}
    ,{{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_mobile_context', false),
          col_prefix='contexts_com_snowplowanalytics_snowplow_mobile_context_1',
          fields=bq_mobile_context_fields,
          relation=ref('snowplow_unified_events_stg') if 'integration_tests' in project_name and 'snowplow' in project_name else source('atomic', 'events') ,
          relation_alias=none) }}
    {% else %}
    , cast(null as {{ dbt.type_string() }}) as mobile__device_manufacturer
    , cast(null as {{ dbt.type_string() }}) as mobile__device_model
    , cast(null as {{ dbt.type_string() }}) as mobile__os_type
    , cast(null as {{ dbt.type_string() }}) as mobile__os_version
    , cast(null as {{ dbt.type_string() }}) as mobile__android_idfa
    , cast(null as {{ dbt.type_string() }}) as mobile__apple_idfa
    , cast(null as {{ dbt.type_string() }}) as mobile__apple_idfv
    , cast(null as {{ dbt.type_string() }}) as mobile__carrier
    , cast(null as {{ dbt.type_string() }}) as mobile__open_idfa
    , cast(null as {{ dbt.type_string() }}) as mobile__network_technology
    , cast(null as {{ dbt.type_string() }}) as mobile__network_type
    , cast(null as {{ dbt.type_int() }}) as mobile__physical_memory
    , cast(null as {{ dbt.type_int() }}) as mobile__system_available_memory
    , cast(null as {{ dbt.type_int() }}) as mobile__app_available_memory
    , cast(null as {{ dbt.type_int() }}) as mobile__battery_level
    , cast(null as {{ dbt.type_string() }}) as mobile__battery_state
    , cast(null as {{ dbt.type_boolean() }}) as mobile__low_power_mode
    , cast(null as {{ dbt.type_int() }}) as mobile__available_storage
    , cast(null as {{ dbt.type_int() }}) as mobile__total_storage
    , cast(null as {{ dbt.type_boolean() }}) as mobile__is_portrait
    , cast(null as {{ dbt.type_string() }}) as mobile__resolution
    , cast(null as {{ dbt.type_float() }}) as mobile__scale
    , cast(null as {{ dbt.type_string() }}) as mobile__language
    , cast(null as {{ dbt.type_string() }}) as mobile__app_set_id
    , cast(null as {{ dbt.type_string() }}) as mobile__app_set_id_scope
  {% endif %}
{% endmacro %} 

{% macro spark__get_mobile_context_fields() %}
  {% if var('snowplow__enable_mobile_context', false) %}
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.device_manufacturer') AS STRING) AS mobile__device_manufacturer
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.device_model') AS STRING) AS mobile__device_model
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.os_type') AS STRING) AS mobile__os_type
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.os_version') AS STRING) AS mobile__os_version
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.android_idfa') AS STRING) AS mobile__android_idfa
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.apple_idfa') AS STRING) AS mobile__apple_idfa
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.apple_idfv') AS STRING) AS mobile__apple_idfv
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.carrier') AS STRING) AS mobile__carrier
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.open_idfa') AS STRING) AS mobile__open_idfa
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.network_technology') AS STRING) AS mobile__network_technology
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.network_type') AS STRING) AS mobile__network_type
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.physical_memory') AS INT) AS mobile__physical_memory
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.system_available_memory') AS INT) AS mobile__system_available_memory
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.app_available_memory') AS INT) AS mobile__app_available_memory
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.battery_level') AS INT) AS mobile__battery_level
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.battery_state') AS STRING) AS mobile__battery_state
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.low_power_mode') AS BOOLEAN) AS mobile__low_power_mode
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.available_storage') AS BIGINT) AS mobile__available_storage
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.total_storage') AS BIGINT) AS mobile__total_storage
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.is_portrait') AS BOOLEAN) AS mobile__is_portrait
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.resolution') AS STRING) AS mobile__resolution
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.scale') AS FLOAT) AS mobile__scale
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.language') AS STRING) AS mobile__language
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.app_set_id') AS STRING) AS mobile__app_set_id
    , cast(get_json_object(to_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]),'$.app_set_id_scope') AS STRING) AS mobile__app_set_id_scope
  {% else %}
    , cast(null as {{ dbt.type_string() }}) as mobile__device_manufacturer
    , cast(null as {{ dbt.type_string() }}) as mobile__device_model
    , cast(null as {{ dbt.type_string() }}) as mobile__os_type
    , cast(null as {{ dbt.type_string() }}) as mobile__os_version
    , cast(null as {{ dbt.type_string() }}) as mobile__android_idfa
    , cast(null as {{ dbt.type_string() }}) as mobile__apple_idfa
    , cast(null as {{ dbt.type_string() }}) as mobile__apple_idfv
    , cast(null as {{ dbt.type_string() }}) as mobile__carrier
    , cast(null as {{ dbt.type_string() }}) as mobile__open_idfa
    , cast(null as {{ dbt.type_string() }}) as mobile__network_technology
    , cast(null as {{ dbt.type_string() }}) as mobile__network_type
    , cast(null as {{ dbt.type_int() }}) as mobile__physical_memory
    , cast(null as {{ dbt.type_int() }}) as mobile__system_available_memory
    , cast(null as {{ dbt.type_int() }}) as mobile__app_available_memory
    , cast(null as {{ dbt.type_int() }}) as mobile__battery_level
    , cast(null as {{ dbt.type_string() }}) as mobile__battery_state
    , cast(null as {{ dbt.type_boolean() }}) as mobile__low_power_mode
    , cast(null as bigint) as mobile__available_storage
    , cast(null as bigint) as mobile__total_storage
    , cast(null as {{ dbt.type_boolean() }}) as mobile__is_portrait
    , cast(null as {{ dbt.type_string() }}) as mobile__resolution
    , cast(null as {{ dbt.type_float() }}) as mobile__scale
    , cast(null as {{ dbt.type_string() }}) as mobile__language
    , cast(null as {{ dbt.type_string() }}) as mobile__app_set_id
    , cast(null as {{ dbt.type_string() }}) as mobile__app_set_id_scope
  {% endif %}
{% endmacro %}

{% macro snowflake__get_mobile_context_fields() %}
  {% if var('snowplow__enable_mobile_context', false) %}
    {% if var('snowplow__snowflake_lakeloader', false) %}
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:device_manufacturer::varchar AS mobile__device_manufacturer
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:device_model::varchar AS mobile__device_model
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:os_type::varchar AS mobile__os_type
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:os_version::varchar AS mobile__os_version
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:android_idfa::varchar AS mobile__android_idfa
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:apple_idfa::varchar AS mobile__apple_idfa
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:apple_idfv::varchar AS mobile__apple_idfv
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:carrier::varchar AS mobile__carrier
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:open_idfa::varchar AS mobile__open_idfa
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:network_technology::varchar AS mobile__network_technology
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:network_type::varchar(255) AS mobile__network_type
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:physical_memory::int AS mobile__physical_memory
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:system_available_memory::int AS mobile__system_available_memory
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:app_available_memory::int AS mobile__app_available_memory
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:battery_level::int AS mobile__battery_level
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:battery_state::varchar AS mobile__battery_state
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:low_power_mode::boolean AS mobile__low_power_mode
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:available_storage::int AS mobile__available_storage
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:total_storage::int AS mobile__total_storage
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:is_portrait::boolean AS mobile__is_portrait
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:resolution::varchar AS mobile__resolution
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:scale::float AS mobile__scale
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:language::varchar AS mobile__language
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:app_set_id::varchar AS mobile__app_set_id
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:app_set_id_scope::varchar AS mobile__app_set_id_scope
    {% else %}
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:deviceManufacturer::varchar AS mobile__device_manufacturer
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:deviceModel::varchar AS mobile__device_model
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:osType::varchar AS mobile__os_type
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:osVersion::varchar AS mobile__os_version
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:androidIdfa::varchar AS mobile__android_idfa
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:appleIdfa::varchar AS mobile__apple_idfa
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:appleIdfv::varchar AS mobile__apple_idfv
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:carrier::varchar AS mobile__carrier
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:openIdfa::varchar AS mobile__open_idfa
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:networkTechnology::varchar AS mobile__network_technology
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:networkType::varchar(255) AS mobile__network_type
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:physicalMemory::int AS mobile__physical_memory
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:systemAvailableMemory::int AS mobile__system_available_memory
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:appAvailableMemory::int AS mobile__app_available_memory
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:batteryLevel::int AS mobile__battery_level
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:batteryState::varchar AS mobile__battery_state
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:lowPowerMode::boolean AS mobile__low_power_mode
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:availableStorage::int AS mobile__available_storage
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:totalStorage::int AS mobile__total_storage
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:isPortrait::boolean AS mobile__is_portrait
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:resolution::varchar AS mobile__resolution
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:scale::float AS mobile__scale
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:language::varchar AS mobile__language
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:appSetId::varchar AS mobile__app_set_id
      , contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:appSetIdScope::varchar AS mobile__app_set_id_scope
    {% endif %}
  {% else %}
    , cast(null as {{ dbt.type_string() }}) as mobile__device_manufacturer
    , cast(null as {{ dbt.type_string() }}) as mobile__device_model
    , cast(null as {{ dbt.type_string() }}) as mobile__os_type
    , cast(null as {{ dbt.type_string() }}) as mobile__os_version
    , cast(null as {{ dbt.type_string() }}) as mobile__android_idfa
    , cast(null as {{ dbt.type_string() }}) as mobile__apple_idfa
    , cast(null as {{ dbt.type_string() }}) as mobile__apple_idfv
    , cast(null as {{ dbt.type_string() }}) as mobile__carrier
    , cast(null as {{ dbt.type_string() }}) as mobile__open_idfa
    , cast(null as {{ dbt.type_string() }}) as mobile__network_technology
    , cast(null as {{ dbt.type_string() }}) as mobile__network_type
    , cast(null as {{ dbt.type_int() }}) as mobile__physical_memory
    , cast(null as {{ dbt.type_int() }}) as mobile__system_available_memory
    , cast(null as {{ dbt.type_int() }}) as mobile__app_available_memory
    , cast(null as {{ dbt.type_int() }}) as mobile__battery_level
    , cast(null as {{ dbt.type_string() }}) as mobile__battery_state
    , cast(null as {{ dbt.type_boolean() }}) as mobile__low_power_mode
    , cast(null as {{ dbt.type_int() }}) as mobile__available_storage
    , cast(null as {{ dbt.type_int() }}) as mobile__total_storage
    , cast(null as {{ dbt.type_boolean() }}) as mobile__is_portrait
    , cast(null as {{ dbt.type_string() }}) as mobile__resolution
    , cast(null as {{ dbt.type_float() }}) as mobile__scale
    , cast(null as {{ dbt.type_string() }}) as mobile__language
    , cast(null as {{ dbt.type_string() }}) as mobile__app_set_id
    , cast(null as {{ dbt.type_string() }}) as mobile__app_set_id_scope
  {% endif %}
{% endmacro %}
