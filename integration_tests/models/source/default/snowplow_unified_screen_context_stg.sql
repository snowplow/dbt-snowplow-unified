{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

select
  '6c33a6ad2bfdd4e3834eaa82587236422263213cb7c3a72c133c8c7546282d36' as root_id,
  cast('2021-03-03 08:14:01.599' as timestamp) as root_tstamp,
  'na' as id,
  'na' as name,
  'na' as activity,
  'na' as type,
  'na' as fragment,
  'na' as top_view_controller,
  'na' as view_controller,
  'screen_context' as schema_name
