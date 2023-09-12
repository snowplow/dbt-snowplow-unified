{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

select
  event_id as root_id,
  collector_tstamp::timestamp as root_tstamp,
  case when platform = 'web' then null else '4e8c2289-b1cd-4915-90de-2d87e1976a58' end as id,
  case when platform = 'web' then null else 'Add New Item' end as name,
  case when platform = 'web' then null else 'na' end as activity,
  case when platform = 'web' then null else 'na' end as type,
  case when platform = 'web' then null else 'na' end as fragment,
  case when platform = 'web' then null else 'na' end as top_view_controller,
  case when platform = 'web' then null else 'na' end as view_controller,
  'screen_context' as schema_name

from {{ ref('snowplow_unified_events') }}
