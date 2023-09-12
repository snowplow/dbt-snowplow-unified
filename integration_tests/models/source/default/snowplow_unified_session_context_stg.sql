{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

select
  root_id,
  root_tstamp::timestamp as root_tstamp,
  'session_context' as schema_name,
  session_index::int as session_index,
  session_id,
  previous_session_id,
  user_id,
  first_event_id,
  event_index::int as event_index,
  storage_mechanism,
  cast('2021-03-03 08:14:01.599' as timestamp) as first_event_timestamp

from {{ ref('snowplow_unified_session_context') }}
