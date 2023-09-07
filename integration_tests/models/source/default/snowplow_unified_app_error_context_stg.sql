  {#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

Select

    '6c33a6ad2bfdd4e3834eaa82587236422263213cb7c3a72c133c8c7546282d36' as root_id,
    cast('2021-03-03 08:14:01.599' as timestamp) as root_tstamp,
    'na' AS message,
    'na' AS programming_language,
    'na' AS class_name,
    'na' AS exception_name,
    true::BOOLEAN AS is_fatal,
    1::INT AS line_number,
    'na' AS stack_trace,
    1::INT AS thread_id,
    'na' AS thread_name,
    'app_error_context' as schema_name
