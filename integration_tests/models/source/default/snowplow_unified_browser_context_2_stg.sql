{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

Select

    event_id as root_id,
    collector_tstamp::timestamp as root_tstamp,
    case when platform = 'web' then cast('na' as {{ type_string() }}) else null end as viewport,
    case when platform = 'web' then cast('na' as {{ type_string() }}) else null end as document_size,
    case when platform = 'web' then cast('na' as {{ type_string() }}) else null end  as resolution,
    case when platform = 'web' then cast(1 as {{ type_int() }}) else null end  as color_depth,
    case when platform = 'web' then cast(1 as {{ type_int() }}) else null end as device_pixel_ratio,
    case when platform = 'web' then cast(1 as {{ type_boolean() }}) else null end  as cookies_enabled,
    case when platform = 'web' then cast(1 as {{ type_boolean() }})  else null end as online,
    case when platform = 'web' then cast('na' as {{ type_string() }}) else null end  as browser_language,
    case when platform = 'web' then cast('na' as {{ type_string() }}) else null end  as document_language,
    case when platform = 'web' then cast(1 as {{ type_boolean() }}) else null end  as webdriver,
    case when platform = 'web' then cast(1 as {{ type_int() }}) else null end  as device_memory,
    case when platform = 'web' then cast(1 as {{ type_int() }}) else null end  as hardware_concurrency,
    case when platform = 'web' then cast('na' as {{ type_string() }}) else null end  as tab_id,
    'browser_context' as schema_name

from {{ ref('snowplow_unified_events') }}
