{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}


--Removing model_tstamp

select
  user_id
  ,user_identifier
  ,network_userid
  ,stitched_user_id
  ,start_tstamp
  ,end_tstamp

  ,first_platform
  ,last_platform
  ,on_web
  ,on_mobile
  ,last_screen_resolution
  ,last_os_type
  ,last_os_version
  ,first_mobile__device_manufacturer
  ,first_mobile__device_model
  ,first_mobile__carrier
  ,last_mobile__device_manufacturer
  ,last_mobile__device_model
  ,last_mobile__carrier
  ,mobile__os_type
  ,mobile__os_version
  ,mobile__android_idfa
  ,mobile__apple_idfa
  ,mobile__apple_idfv
  ,mobile__open_idfa
  ,mobile__network_technology
  ,mobile__network_type
  ,mobile__physical_memory
  ,mobile__system_available_memory
  ,mobile__app_available_memory
  ,mobile__battery_level
  ,mobile__battery_state
  ,mobile__low_power_mode
  ,mobile__available_storage
  ,mobile__total_storage
  ,mobile__is_portrait
  ,mobile__resolution
  ,mobile__scale
  ,mobile__language
  ,mobile__app_set_id
  ,mobile__app_set_id_scope
  ,first_geo_country
  ,first_geo_country_name
  ,first_geo_continent
  ,first_geo_city
  ,first_geo_region_name
  ,last_geo_country
  ,last_geo_country_name
  ,last_geo_continent
  ,last_geo_city
  ,last_geo_region_name
  ,geo_zipcode
  ,geo_latitude
  ,geo_longitude
  ,geo_timezone
  ,views
  ,sessions
  ,active_days
  ,engaged_time_in_s
  ,screen_names_viewed
  ,absolute_time_in_s
  ,page_referrer
  ,refr_medium
  ,refr_source
  ,refr_term
  ,first_page_title
  ,first_page_url
  ,first_page_urlscheme
  ,first_page_urlhost
  ,first_page_urlpath
  ,first_page_urlquery
  ,first_page_urlfragment
  ,first_br_lang
  ,first_br_lang_name
  ,last_page_title
  ,last_page_url
  ,last_page_urlscheme
  ,last_page_urlhost
  ,last_page_urlpath
  ,last_page_urlquery
  ,last_page_urlfragment
  ,last_br_lang
  ,last_br_lang_name
  ,refr_urlscheme
  ,refr_urlhost
  ,refr_urlpath
  ,refr_urlquery
  ,refr_urlfragment
  ,first_screen_view__name
  ,first_screen_view__type
  ,last_screen_view__name
  ,last_screen_view__transition_type
  ,last_screen_view__type
  ,mkt_medium
  ,mkt_source
  ,mkt_term
  ,mkt_content
  ,mkt_campaign
  ,mkt_clickid
  ,mkt_network
  ,mkt_source_platform
  ,default_channel_group
  ,app_errors
  ,fatal_app_errors

-- hard-coding due to non-deterministic outcome from row_number for Redshift/Postgres/databricks
{% if target.type in ['redshift', 'postgres', 'databricks'] -%}
  , case when first_event_id = 'b3eca04e-d277-45e0-9c7c-76dc7e8c16ff' then '3cfe1cd4-a20e-4fc7-952a-a5cb7f7d063f' else first_event_id end as first_event_id
  , case when first_event_id2 = 'b3eca04e-d277-45e0-9c7c-76dc7e8c16ff-first' then '3cfe1cd4-a20e-4fc7-952a-a5cb7f7d063f-first' else first_event_id2 end as first_event_id2
  , case when last_event_id = 'b3eca04e-d277-45e0-9c7c-76dc7e8c16ff' then '3cfe1cd4-a20e-4fc7-952a-a5cb7f7d063f' else last_event_id end as last_event_id
  , case when last_event_id2 = 'b3eca04e-d277-45e0-9c7c-76dc7e8c16ff-last' then '3cfe1cd4-a20e-4fc7-952a-a5cb7f7d063f-last' else last_event_id2 end as last_event_id2
{% else %}
  ,first_event_id
  ,first_event_id2
  ,last_event_id
  ,last_event_id2
{% endif %}
  ,agg_test
from {{ ref('snowplow_unified_users') }}
