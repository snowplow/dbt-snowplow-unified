{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

  select
    root_id,
    root_tstamp::timestamp as root_tstamp,
    'geolocation_context' as schema_name,
    latitude::float as latitude,
    longitude::float as longitude,
    latitude_longitude_accuracy::float as latitude_longitude_accuracy,
    altitude::float as altitude,
    altitude_accuracy::float as altitude_accuracy,
    bearing::float as bearing,
    speed::float as speed

from {{ ref('snowplow_unified_geolocation_context') }}
