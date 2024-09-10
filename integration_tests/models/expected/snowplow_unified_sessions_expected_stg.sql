{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}


-- Removing model_tstamp

SELECT

    {% if target.type =='redshift' %}
    replace(event_counts, ' ', '') as event_counts
    {% else %}
    event_counts
    {% endif %}
    ,cv_view_page_volume
    {% if target.type in ['snowflake'] %}
        ,AS_ARRAY(parse_json(cv_view_page_events)) as cv_view_page_events
        ,AS_ARRAY(parse_json(cv_view_page_values)) as cv_view_page_values  
    {% elif target.type in ['bigquery'] %}
        {# BQ cannott compare array columns #}
        ,to_json_string(array(select replace(x, '"', '') from unnest(json_extract_array(cv_view_page_events,'$')) as x)) as cv_view_page_events
        ,to_json_string(array(select cast(x AS float64) from unnest(json_extract_array(cv_view_page_values,'$')) as x)) as cv_view_page_values
    {% elif target.type in ['spark', 'databricks'] %}
        {# thank you chatGPT #}
        ,filter(transform(split(regexp_replace(substring(cv_view_page_events, 3, length(cv_view_page_events)-3), '\\"+', ''), ','), x -> CAST(trim(x) AS string)), x -> x is not null and x != '')  as cv_view_page_events
        ,filter(transform(split(regexp_replace(substring(cv_view_page_values, 3, length(cv_view_page_values)-3), '\\"+', ''), ','), x -> CAST(trim(x) AS double)), x -> x is not null)  as cv_view_page_values
    {% elif target.type in ['postgres', 'redshift'] %}
        {% if target.type == 'redshift' %}
        ,nullif(split_to_array(translate(cv_view_page_events, '[]"]', ''),','), array()) as cv_view_page_events
        ,nullif(split_to_array(translate(cv_view_page_values, '[]"]', ''),','), array()) as cv_view_page_values
        {% else %}
        ,string_to_array(regexp_replace(cv_view_page_events, '[\[\]\"]', '', 'g'),',') as cv_view_page_events
        ,string_to_array(regexp_replace(cv_view_page_values, '[\[\]\"]', '', 'g'),',')::numeric[] as cv_view_page_values
        {% endif %}
    {% endif %}
    ,cv_view_page_total
    ,cv_view_page_first_conversion
    ,cv_view_page_converted
    ,cv__all_volume
    ,cv__all_total
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
    ,yauaa__device_brand
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

  -- hard-coding due to different rounding in Bigquery
{% if target.type == 'bigquery' -%}
  ,case when session_identifier in ('79831faefff0edc56d0d93ccf192b5bb58c07bec8dfff185f5cc4b104c2f0a08', '067bcc8ea082fcaf940893b64943edc6b718f0dd1bc1bd5d054a507c64048318', '37b340c11359852988ae9b4f77f0c4b283cf2d4e87e2b5e5bceda36a185b81ff', '4d34b56a2a474e7c5d7f125c9a0ed11b7e526bf99910d6d31afaf6a8cc25d7ae', '540b6c4f7c15de9093e0f4f6cf45a062fba7606ce64558a0b1c5a34d8bb33af5','6b379f3eea11eb4ead878125af9cb708f8a91c455d9405b0bc617fa78c2e4291', '6f19f1f4f43224f646d6fed6358c39152faa088f7ab2d90f0a791ea1210a4656', '7605342329f0b916a4c1bcd8bddad038988920fb24f74ca9e7ada5d96df32c60', 'cde5b90f34224b1a94351fa90fcb61d41b26a52a1a8381603cf538a11edd2bb2') then absolute_time_in_s - 1
   else absolute_time_in_s end as absolute_time_in_s
{% else %}
    ,absolute_time_in_s
{% endif %}

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
    ,ua__os_family
    ,ua__device_family
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

FROM {{ ref('snowplow_unified_sessions_expected') }}
