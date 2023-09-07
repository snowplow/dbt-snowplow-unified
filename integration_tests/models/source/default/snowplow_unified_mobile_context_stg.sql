{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

Select

    '6c33a6ad2bfdd4e3834eaa82587236422263213cb7c3a72c133c8c7546282d36' as root_id,
    cast('2021-03-03 08:14:01.599' as timestamp) as root_tstamp,
    'na' as device_manufacturer,
    'na' as device_model,
    'na' as os_type,
    'na' as os_version,
    'na' as android_idfa,
    'na' as apple_idfa,
    'na' as apple_idfv,
    'na' as carrier,
    'na' as open_idfa,
    'na' as network_technology,
    'na' as network_type,
    cast(1 as {{ type_int() }}) as physical_memory,
    cast(1 as {{ type_int() }}) as system_available_memory,
    cast(1 as {{ type_int() }}) as app_available_memory,
    cast(1 as {{ type_int() }}) as battery_level,
    'na' as battery_state,
    cast('true' as {{ type_boolean() }}) as low_power_mode,
    'na' as available_storage,
    cast(1 as {{ type_int() }}) as total_storage,
    cast('true' as {{ type_boolean() }}) as is_portrait,
    'na' as resolution,
    cast(1 as {{ type_float() }}) as scale,
    'na' as language,
    'na' as app_set_id,
    'na' as app_set_id_scope,
    'mobile_context' as schema_name
