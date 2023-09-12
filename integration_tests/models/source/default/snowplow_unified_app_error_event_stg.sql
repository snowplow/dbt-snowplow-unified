  {#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

Select
    event_id as root_id,
    collector_tstamp::timestamp as root_tstamp,
    case when platform = 'web' then null else 'na' end AS message,
    case when platform = 'web' then null else 'na' end AS programming_language,
    case when platform = 'web' then null else 'na' end AS class_name,
    case when platform = 'web' then null else 'na' end AS exception_name,
    case when platform = 'web' then null else false::BOOLEAN end AS is_fatal,
    case when platform = 'web' then null else 1::INT end AS line_number,
    case when platform = 'web' then null else 'na' end AS stack_trace,
    case when platform = 'web' then null else 1::INT end AS thread_id,
    case when platform = 'web' then null else 'na' end AS thread_name,
    'app_error_events' as schema_name

from {{ ref('snowplow_unified_events') }}
