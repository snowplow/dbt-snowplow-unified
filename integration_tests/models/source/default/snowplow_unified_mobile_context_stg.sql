{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

Select

    event_id as root_id,
    collector_tstamp::timestamp as root_tstamp,
    case when platform = 'web' then null else 'Samsung' end as device_manufacturer,
    case when platform = 'web' then null else 'SM-N960N Galaxy Note9 TD-LTE KR 128GB' end as device_model,
    case when platform = 'web' then null else 'Google Android 8.1 (Oreo)' end as os_type,
    case when platform = 'web' then null else '8.1' end as os_version,
    case when platform = 'web' then null else '00000000-0000-0000-0000-000000000000' end as android_idfa,
    case when platform = 'web' then null else 'na' end as apple_idfa,
    case when platform = 'web' then null else 'na' end as apple_idfv,
    case when platform = 'web' then null else 'Unknown' end as carrier,
    case when platform = 'web' then null else 'na' end as open_idfa,
    case when platform = 'web' then null else '2G' end as network_technology,
    case when platform = 'web' then null else 'wifi' end as network_type,
    case when platform = 'web' then null else cast(1 as {{ type_int() }}) end as physical_memory,
    case when platform = 'web' then null else cast(1 as {{ type_int() }}) end as system_available_memory,
    case when platform = 'web' then null else cast(1 as {{ type_int() }}) end as app_available_memory,
    case when platform = 'web' then null else cast(42 as {{ type_int() }}) end as battery_level,
    case when platform = 'web' then null else 'charging' end as battery_state,
    case when platform = 'web' then null else cast('true' as {{ type_boolean() }}) end as low_power_mode,
    case when platform = 'web' then null else cast(1 as {{ type_int() }}) end as available_storage,
    case when platform = 'web' then null else 128000000000 end as total_storage,
    case when platform = 'web' then null else cast('false' as {{ type_boolean() }}) end as is_portrait,
    case when platform = 'web' then null else '1440x2960' end as resolution,
    case when platform = 'web' then null else cast(1 as {{ type_float() }}) end as scale,
    case when platform = 'web' then null else 'na' end as language,
    case when platform = 'web' then null else 'na' end as app_set_id,
    case when platform = 'web' then null else 'na' end as app_set_id_scope,
    'mobile_context' as schema_name

from {{ ref('snowplow_unified_events') }}
