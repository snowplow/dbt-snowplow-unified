{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}


-- Removing model_tstamp

select

    {%- if var('snowplow__list_event_counts', false) %}
    -- just compare the string version for simplicity...
    {% if target.type == 'bigquery' %}
    to_json_string(event_counts) as event_counts
    {% elif target.type =='redshift' %}
    json_serialize(event_counts) as event_counts
    {% else %}
    cast(event_counts as {{snowplow_utils.type_max_string() }}) as event_counts
    {% endif %}
    {%- endif %}

{% if var('snowplow__conversion_events', none) %}
    ,  cv_view_page_volume
    {% if target.type == 'bigquery' %}
    ,  to_json_string(cv_view_page_events) as cv_view_page_events
    ,  to_json_string(cv_view_page_values) as cv_view_page_values
    {% else %}
    ,  cv_view_page_events
    ,  cv_view_page_values
    {% endif %}
    ,  cv_view_page_total
    ,  cv_view_page_first_conversion
    ,  cv_view_page_converted
    {% if var('snowplow__total_all_conversions') %}
    ,  cv__all_volume
    ,  cv__all_total
    {% endif %}
{% endif %}

,first_event_name
,last_event_name
,session_identifier
,session__previous_session_id
,user_id
,user_identifier
,stitched_user_id
,network_userid
,start_tstamp
,end_tstamp

-- hard-coding due to non-deterministic outcome from row_number for Redshift/Postgres/databricks
{% if target.type in ['redshift', 'postgres', 'databricks'] -%}
, case when event_id = 'b3eca04e-d277-45e0-9c7c-76dc7e8c16ff' then 'true base' else app_id end as app_id
{% else %}
, app_id
{% endif %}
,platform
,device_identifier
,device_category
,device_session_index
,os_version
,os_type
,os_timezone
,screen_resolution
,yauaa__device_class
,yauaa__device_version
,yauaa__operating_system_version
,yauaa__operating_system_class
,yauaa__operating_system_name
,yauaa__operating_system_name_version
,mobile__device_manufacturer
,mobile__device_model
,mobile__os_type
,mobile__os_version
,mobile__android_idfa
,mobile__apple_idfa
,mobile__apple_idfv
,mobile__carrier
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
,first_geo_region_name
,first_geo_city
,first_geo_country_name
,first_geo_continent
,last_geo_country
,last_geo_region_name
,last_geo_city
,last_geo_country_name
,last_geo_continent
,geo_zipcode
,geo_latitude
,geo_longitude
,geo_timezone
,user_ipaddress
,views

,total_events
,is_engaged
,engaged_time_in_s
,absolute_time_in_s
,screen_names_viewed
,mkt_medium
,mkt_source
,mkt_term
,mkt_content
,mkt_campaign
,mkt_clickid
,mkt_network
,default_channel_group
,mkt_source_platform
,first_page_url
,last_page_url
,page_referrer
,refr_medium
,refr_source
,refr_term
,first_page_title
,first_page_urlscheme
,first_page_urlhost
,first_page_urlpath
,first_page_urlquery
,first_page_urlfragment
,last_page_title
,last_page_urlscheme
,last_page_urlhost
,last_page_urlpath
,last_page_urlquery
,last_page_urlfragment
,refr_urlscheme
,refr_urlhost
,refr_urlpath
,refr_urlquery
,refr_urlfragment
,br_renderengine
,first_br_lang
,first_br_lang_name
,last_br_lang
,last_br_lang_name
,iab__category
,iab__primary_impact
,iab__reason
,iab__spider_or_robot
,yauaa__device_name
,yauaa__agent_class
,yauaa__device_brand
,yauaa__agent_name
,yauaa__agent_name_version
,yauaa__agent_name_version_major
,yauaa__agent_version
,yauaa__agent_version_major
,yauaa__layout_engine_class
,yauaa__layout_engine_name
,yauaa__layout_engine_name_version
,yauaa__layout_engine_name_version_major
,yauaa__layout_engine_version
,yauaa__layout_engine_version_major
,ua__device_family
,ua__os_family
,ua__os_version
,ua__os_major
,ua__os_minor
,ua__os_patch
,ua__os_patch_minor
,ua__useragent_family
,ua__useragent_major
,ua__useragent_minor
,ua__useragent_patch
,ua__useragent_version
,first_screen_view__name
,first_screen_view__type
,last_screen_view__name
,last_screen_view__transition_type
,last_screen_view__type
,screen_view__previous_id
,screen_view__previous_name
,screen_view__previous_type
,first_app__build
,first_app__version
,first_geo__altitude
,first_geo__altitude_accuracy
,first_geo__bearing
,first_geo__latitude
,first_geo__latitude_longitude_accuracy
,first_geo__longitude
,first_geo__speed
,app_errors
,fatal_app_errors
,useragent

-- hard-coding due to non-deterministic outcome from row_number for Redshift/Postgres/databricks
{% if target.type in ['redshift', 'postgres', 'databricks'] -%}
  , case when event_id = 'b3eca04e-d277-45e0-9c7c-76dc7e8c16ff' then '3cfe1cd4-a20e-4fc7-952a-a5cb7f7d063f' else event_id end as event_id
  , case when event_id2 = 'b3eca04e-d277-45e0-9c7c-76dc7e8c16ff' then '3cfe1cd4-a20e-4fc7-952a-a5cb7f7d063f' else event_id2 end as event_id2
{% else %}
    ,event_id
    ,event_id2
{% endif %}
    ,agg_test

from {{ ref('snowplow_unified_sessions') }}
