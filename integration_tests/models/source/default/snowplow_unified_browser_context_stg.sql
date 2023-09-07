{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

Select

    '6c33a6ad2bfdd4e3834eaa82587236422263213cb7c3a72c133c8c7546282d36' as root_id,
    cast('2021-03-03 08:14:01.599' as timestamp) as root_tstamp,
    cast('na' as {{ type_string() }}) as viewport,
    cast('na' as {{ type_string() }}) as document_size,
    cast('na' as {{ type_string() }}) as resolution,
    cast('na' as {{ type_string() }}) as color_depth,
    cast('na' as {{ type_string() }}) as device_pixel_ratio,
    cast('na' as {{ type_string() }}) as cookies_enabled,
    cast('na' as {{ type_string() }}) as online,
    cast('na' as {{ type_string() }}) as browser_language,
    cast('na' as {{ type_string() }}) as document_language,
    cast('na' as {{ type_string() }}) as webdriver,
    cast('na' as {{ type_string() }}) as device_memory,
    cast('na' as {{ type_string() }}) as hardware_concurrency,
    cast('na' as {{ type_string() }}) as tab_id,
    'browser_context' as schema_name

