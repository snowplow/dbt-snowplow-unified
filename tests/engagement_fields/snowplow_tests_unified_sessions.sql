{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

select *
from {{ ref('snowplow_unified_sessions') }}
where user_identifier is null --cannot be null from other tests
{% if var('snowplow__enable_web') or var('snowplow__enable_screen_summary_context', false) %}
      or engaged_time_in_s is null -- where there are no pings, engaged time is 0.
      or absolute_time_in_s is null 
{% endif %}