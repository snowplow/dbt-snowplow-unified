{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

Select
    event_id as root_id,
    collector_tstamp::timestamp as root_tstamp,
    case when platform = 'web' then null else cast('na' as {{ type_string() }}) end as build,
    case when platform = 'web' then null else cast('na' as {{ type_string() }}) end as version,
    'app_context' as schema_name

from {{ ref('snowplow_unified_events') }}
