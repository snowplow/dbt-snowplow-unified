{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

Select
  root_id as root_id,
  root_tstamp::timestamp as root_tstamp,
  id,
  'na' as name,
  'na' as previous_id,
  'na' as previous_name,
  'na' as previous_type,
  'na' as transition_type,
  'na' as type,
  'screen_view_events' as schema_name

from {{ ref('snowplow_unified_screen_view_event') }}
