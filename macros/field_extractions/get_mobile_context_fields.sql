{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro get_mobile_context_fields(table_prefix = none) %}
    {{ return(adapter.dispatch('get_mobile_context_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro postgres__get_mobile_context_fields(table_prefix = none) %}
{% endmacro %}

{% macro bigquery__get_mobile_context_fields(table_prefix = none) %}
  {% if var('snowplow__enable_mobile_context', false) %}
    {{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_mobile_context', false),
          col_prefix='contexts_com_snowplowanalytics_snowplow_mobile_context_1_',
          fields=mobile_context_fields(),
          relation=source('atomic', 'events') if project_name != 'snowplow_unified_integration_tests' else ref('snowplow_unified_events_stg'),
          relation_alias=table_prefix) }}
    {% else %}
      cast(null as {{ type_string() }}) as mobile__device_manufacturer,
      cast(null as {{ type_string() }}) as mobile__device_model,
      cast(null as {{ type_string() }}) as mobile__os_type,
      cast(null as {{ type_string() }}) as mobile__os_version,
      cast(null as {{ type_string() }}) as mobile__android_idfa,
      cast(null as {{ type_string() }}) as mobile__apple_idfa,
      cast(null as {{ type_string() }}) as mobile__apple_idfv,
      cast(null as {{ type_string() }}) as mobile__carrier,
      cast(null as {{ type_string() }}) as mobile__open_idfa,
      cast(null as {{ type_string() }}) as mobile__network_technology,
      cast(null as {{ type_string() }}) as mobile__network_type,
      cast(null as {{ type_int() }}) as mobile__physical_memory,
      cast(null as {{ type_int() }}) as mobile__system_available_memory,
      cast(null as {{ type_int() }}) as mobile__app_available_memory,
      cast(null as {{ type_int() }}) as mobile__battery_level,
      cast(null as {{ type_string() }}) as mobile__battery_state,
      cast(null as {{ type_boolean() }}) as mobile__low_power_mode,
      cast(null as {{ type_string() }}) as mobile__available_storage,
      cast(null as {{ type_int() }}) as mobile__total_storage,
      cast(null as {{ type_boolean() }}) as mobile__is_portrait,
      cast(null as {{ type_string() }}) as mobile__resolution,
      cast(null as {{ type_float() }}) as mobile__scale,
      cast(null as {{ type_string() }}) as mobile__language,
      cast(null as {{ type_string() }}) as mobile__app_set_id,
      cast(null as {{ type_string() }}) as mobile__app_set_id_scope
  {% endif %}
{% endmacro %}

{% macro spark__get_mobile_context_fields(table_prefix = none) %}
  {% if var('snowplow__enable_mobile_context', false) %}
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].device_manufacturer::STRING AS mobile__device_manufacturer,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].device_model::STRING AS mobile__device_model,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].os_type::STRING AS mobile__os_type,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].os_version::STRING AS mobile__os_version,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].android_idfa::STRING AS mobile__android_idfa,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].apple_idfa::STRING AS mobile__apple_idfa,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].apple_idfv::STRING AS mobile__apple_idfv,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].carrier::STRING AS mobile__carrier,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].open_idfa::STRING AS mobile__open_idfa,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].network_technology::STRING AS mobile__network_technology,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].network_type::STRING AS mobile__network_type,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].physical_memory::INT AS mobile__physical_memory,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].system_available_memory::INT AS mobile__system_available_memory,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].app_available_memory::INT AS mobile__app_available_memory,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].battery_level::INT AS mobile__battery_level,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].battery_state::STRING AS mobile__battery_state,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].low_power_mode::BOOLEAN AS mobile__low_power_mode,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].available_storage::INT AS mobile__available_storage,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].total_storage::INT AS mobile__total_storage,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].is_portrait::BOOLEAN AS mobile__is_portrait,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].resolution::STRING AS mobile__resolution,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].scale::float AS mobile__scale,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].language::STRING AS mobile__language,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].app_set_id::STRING AS mobile__app_set_id,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].app_set_id_scope::STRING AS mobile__app_set_id_scope
  {% else %}
    cast(null as {{ type_string() }}) as mobile__device_manufacturer,
    cast(null as {{ type_string() }}) as mobile__device_model,
    cast(null as {{ type_string() }}) as mobile__os_type,
    cast(null as {{ type_string() }}) as mobile__os_version,
    cast(null as {{ type_string() }}) as mobile__android_idfa,
    cast(null as {{ type_string() }}) as mobile__apple_idfa,
    cast(null as {{ type_string() }}) as mobile__apple_idfv,
    cast(null as {{ type_string() }}) as mobile__carrier,
    cast(null as {{ type_string() }}) as mobile__open_idfa,
    cast(null as {{ type_string() }}) as mobile__network_technology,
    cast(null as {{ type_string() }}) as mobile__network_type,
    cast(null as {{ type_int() }}) as mobile__physical_memory,
    cast(null as {{ type_int() }}) as mobile__system_available_memory,
    cast(null as {{ type_int() }}) as mobile__app_available_memory,
    cast(null as {{ type_int() }}) as mobile__battery_level,
    cast(null as {{ type_string() }}) as mobile__battery_state,
    cast(null as {{ type_boolean() }}) as mobile__low_power_mode,
    cast(null as {{ type_string() }}) as mobile__available_storage,
    cast(null as {{ type_int() }}) as mobile__total_storage,
    cast(null as {{ type_boolean() }}) as mobile__is_portrait,
    cast(null as {{ type_string() }}) as mobile__resolution,
    cast(null as {{ type_float() }}) as mobile__scale,
    cast(null as {{ type_string() }}) as mobile__language,
    cast(null as {{ type_string() }}) as mobile__app_set_id,
    cast(null as {{ type_string() }}) as mobile__app_set_id_scope
  {% endif %}
{% endmacro %}

{% macro snowflake__get_mobile_context_fields(table_prefix = none) %}
  {% if var('snowplow__enable_mobile_context', false) %}
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:deviceManufacturer::varchar AS mobile__device_manufacturer,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:deviceModel::varchar AS mobile__device_model,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:osType::varchar AS mobile__os_type,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:osVersion::varchar AS mobile__os_version,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:androidIdfa::varchar AS mobile__android_idfa,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:appleIdfa::varchar AS mobile__apple_idfa,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:appleIdfv::varchar AS mobile__apple_idfv,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:carrier::varchar AS mobile__carrier,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:openIdfa::varchar AS mobile__open_idfa,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:networkTechnology::varchar AS mobile__network_technology,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:networkType::varchar(255) AS mobile__network_type,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:physicalMemory::int AS mobile__physical_memory,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:systemAvailableMemory::int AS mobile__system_available_memory,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:appAvailableMemory::int AS mobile__app_available_memory,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:batteryLevel::int AS mobile__battery_level,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:batteryState::varchar AS mobile__battery_state,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:lowPowerMode::boolean AS mobile__low_power_mode,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:availableStorage::int AS mobile__available_storage,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:totalStorage::int AS mobile__total_storage,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:isPortrait::boolean AS mobile__is_portrait,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:resolution::varchar AS mobile__resolution,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:scale::float AS mobile__scale,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:language::varchar AS mobile__language,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:appSetId::varchar AS mobile__app_set_id,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:appSetIdScope::varchar AS mobile__app_set_id_scope
  {% else %}
    cast(null as {{ type_string() }}) as mobile__device_manufacturer,
    cast(null as {{ type_string() }}) as mobile__device_model,
    cast(null as {{ type_string() }}) as mobile__os_type,
    cast(null as {{ type_string() }}) as mobile__os_version,
    cast(null as {{ type_string() }}) as mobile__android_idfa,
    cast(null as {{ type_string() }}) as mobile__apple_idfa,
    cast(null as {{ type_string() }}) as mobile__apple_idfv,
    cast(null as {{ type_string() }}) as mobile__carrier,
    cast(null as {{ type_string() }}) as mobile__open_idfa,
    cast(null as {{ type_string() }}) as mobile__network_technology,
    cast(null as {{ type_string() }}) as mobile__network_type,
    cast(null as {{ type_int() }}) as mobile__physical_memory,
    cast(null as {{ type_int() }}) as mobile__system_available_memory,
    cast(null as {{ type_int() }}) as mobile__app_available_memory,
    cast(null as {{ type_int() }}) as mobile__battery_level,
    cast(null as {{ type_string() }}) as mobile__battery_state,
    cast(null as {{ type_boolean() }}) as mobile__low_power_mode,
    cast(null as {{ type_string() }}) as mobile__available_storage,
    cast(null as {{ type_int() }}) as mobile__total_storage,
    cast(null as {{ type_boolean() }}) as mobile__is_portrait,
    cast(null as {{ type_string() }}) as mobile__resolution,
    cast(null as {{ type_float() }}) as mobile__scale,
    cast(null as {{ type_string() }}) as mobile__language,
    cast(null as {{ type_string() }}) as mobile__app_set_id,
    cast(null as {{ type_string() }}) as mobile__app_set_id_scope
  {% endif %}
{% endmacro %}
