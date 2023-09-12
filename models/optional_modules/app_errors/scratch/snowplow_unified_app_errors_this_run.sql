{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
  config(
    sort='derived_tstamp',
    dist='event_id',
    tags=["this_run"],
    enabled=(var("snowplow__enable_app_errors", false)),
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

select
  e.event_id,

  e.app_id,

  e.user_id,
  e.user_identifier,
  e.network_userid,

  e.session_identifier,
  e.session__session_index as session_index,
  e.session__previous_session_id as previous_session_id,
  e.session__first_event_id as session_first_event_id,

  e.dvce_created_tstamp,
  e.collector_tstamp,
  e.derived_tstamp,

  {% if target.type in ['redshift', 'postgres', 'databricks'] -%}
    CURRENT_TIMESTAMP as model_tstamp,
  {% else %}
     {{ snowplow_utils.current_timestamp_in_utc() }} as model_tstamp,
  {% endif %}

  e.platform,
  e.dvce_screenwidth,
  e.dvce_screenheight,
  e.mobile__device_manufacturer as device_manufacturer,
  e.mobile__device_model as device_model,
  e.mobile__os_type as os_type,
  e.mobile__os_version as os_version,
  e.mobile__android_idfa as android_idfa,
  e.mobile__apple_idfa as apple_idfa,
  e.mobile__apple_idfv as apple_idfv,
  e.mobile__open_idfa as open_idfa,

  e.screen__id as screen_id,
  e.screen__name as screen_name,
  e.screen__activity as screen_activity,
  e.screen__fragment as screen_fragment,
  e.screen__top_view_controller as screen_top_view_controller,
  e.screen__type as screen_type,
  e.screen__view_controller as screen_view_controller,

  e.geo__latitude as device_latitude,
  e.geo__longitude as device_longitude,
  e.geo__latitude_longitude_accuracy as device_latitude_longitude_accuracy,
  e.geo__altitude as device_altitude,
  e.geo__altitude_accuracy as device_altitude_accuracy,
  e.geo__bearing as device_bearing,
  e.geo__speed as device_speed,
  e.geo_country,
  e.geo_region,
  e.geo_city,
  e.geo_zipcode,
  e.geo__latitude as geo_latitude,
  e.geo__longitude as geo_longitude,
  e.geo_region_name as geo_region_name,
  e.geo_timezone as geo_timezone,

  e.user_ipaddress,
  e.useragent,

  e.mobile__carrier as carrier,
  e.mobile__network_technology as network_technology,
  e.mobile__network_type as network_type,

  e.app__build as build,
  e.app__build as version,
  row_number() over(partition by e.session_identifier order by e.derived_tstamp) as event_index_in_session,

  -- app error events
  e.app_error__message as message,
  e.app_error__programming_language as programming_language,
  e.app_error__class_name as class_name,
  e.app_error__exception_name as exception_name,
  e.app_error__is_fatal as is_fatal,
  e.app_error__line_number as line_number,
  e.app_error__stack_trace as stack_trace,
  e.app_error__thread_id as thread_id,
  e.app_error__thread_name as thread_name

from {{ ref('snowplow_unified_events_this_run') }} as e
where e.event_name = 'application_error'
