{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{# CWV tests run on a different source dataset, this is an easy way to hack them together. #}
{% if not var("snowplow__enable_cwv", false) and not var("snowplow__enable_screen_summary_context", false) %}

    -- page view context is given as json string in csv. Parse json
    with prep as (
        select
            *,
            from_json(contexts_com_snowplowanalytics_snowplow_web_page_1_0_0, 'array<struct<id:string>>') as contexts_com_snowplowanalytics_snowplow_web_page_1,
            from_json(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1_0_0, 'array<struct<basis_for_processing:string, consent_scopes:array<string>, consent_url:string, consent_version:string, domains_applied:array<string>, event_type:string, gdpr_applies:string>>') as unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1,
            from_json(unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1_0_0, 'array<struct<elapsed_time:string>>') as unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1,
            from_json(contexts_com_iab_snowplow_spiders_and_robots_1_0_0, 'array<struct<category:string,primaryImpact:string,reason:string,spiderOrRobot:boolean>>') as contexts_com_iab_snowplow_spiders_and_robots_1,
            from_json(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1_0_0, 'array<struct<deviceFamily:string,osFamily:string,osMajor:string,osMinor:string,osPatch:string,osPatchMinor:string,osVersion:string,useragentFamily:string,useragentMajor:string,useragentMinor:string,useragentPatch:string,useragentVersion:string>>') as contexts_com_snowplowanalytics_snowplow_ua_parser_context_1,
            from_json(contexts_nl_basjes_yauaa_context_1_0_0, 'array<struct<agentClass:string,agentInformationEmail:string,agentName:string,agentNameVersion:string,agentNameVersionMajor:string,agentVersion:string,agentVersionMajor:string,deviceBrand:string,deviceClass:string,deviceCpu:string,deviceCpuBits:string,deviceName:string,deviceVersion:string,layoutEngineClass:string,layoutEngineName:string,layoutEngineNameVersion:string,layoutEngineNameVersionMajor:string,layoutEngineVersion:string,layoutEngineVersionMajor:string,networkType:string,operatingSystemClass:string,operatingSystemName:string,operatingSystemNameVersion:string,operatingSystemNameVersionMajor:string,operatingSystemVersion:string,operatingSystemVersionBuild:string,operatingSystemVersionMajor:string,webviewAppName:string,webviewAppNameVersionMajor:string,webviewAppVersion:string,webviewAppVersionMajor:string>>') as contexts_nl_basjes_yauaa_context_1,
            from_json(unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0,'array<struct<id:string,name:string,previousId:string,previousName:string,previousType:string,transitionType:string,type:string>>') as unstruct_event_com_snowplowanalytics_mobile_screen_view_1,
            from_json(contexts_com_snowplowanalytics_snowplow_client_session_1_0_0,'array<struct<sessionId:string,userId:string,sessionIndex:string,firstEventId:string,previousSessionId:string,eventIndex:string,storageMechanism:string,firstEventTimestamp:timestamp>>') as contexts_com_snowplowanalytics_snowplow_client_session_1,
            from_json(contexts_com_snowplowanalytics_snowplow_geolocation_context_1_0_0,'array<struct<latitude:string,longitude:string,latitudeLongitudeAccuracy:string,altitude:string,altitudeAccuracy:string,bearing:string,speed:string,timestamp:timestamp>>') as contexts_com_snowplowanalytics_snowplow_geolocation_context_1,
            from_json(contexts_com_snowplowanalytics_mobile_application_1_0_0,'array<struct<version:string,build:string>>') as contexts_com_snowplowanalytics_mobile_application_1,
            from_json(contexts_com_snowplowanalytics_mobile_deep_link_1_0_0,'array<struct<url:string,referrer:string>>') as contexts_com_snowplowanalytics_mobile_deep_link_1,
            from_json(contexts_com_snowplowanalytics_snowplow_browser_context_1_0_0,'array<struct<viewport:string,documentSize:string,resolution:string,colorDepth:string,devicePixelRatio:string,cookiesEnabled:string,online:string,browserLanguage:string,documentLanguage:string,webdriver:string,deviceMemory:string,hardwareConcurrency:string,tabId:string>>') as contexts_com_snowplowanalytics_snowplow_browser_context_1,
            from_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1_0_0,'array<struct<deviceManufacturer:string,deviceModel:string,osType:string,osVersion:string,androidIdfa:string,appleIdfa:string,appleIdfv:string,carrier:string,openIdfa:string,networkTechnology:string,networkType:string,physicalMemory:string,systemAvailableMemory:string,appAvailableMemory:string,batteryLevel:string,batteryState:string,lowPowerMode:string,availableStorage:string,totalStorage:string,isPortrait:string,resolution:string,scale:string,language:string,appSetId:string,appSetIdScope:string>>') as contexts_com_snowplowanalytics_snowplow_mobile_context_1,
            from_json(contexts_com_snowplowanalytics_mobile_screen_1_0_0,'array<struct<id:string,name:string,activity:string,fragment:string,topViewController:string,type:string,viewController:string>>') as contexts_com_snowplowanalytics_mobile_screen_1,
            from_json(unstruct_event_com_snowplowanalytics_snowplow_application_error_1_0_0,'array<struct<message:string,programmingLanguage:string,className:string,exceptionName:string,isFatal:boolean,lineNumber:double,stackTrace:string, threadId:int, threadName:string>>') as unstruct_event_com_snowplowanalytics_snowplow_application_error_1
        from
            {{ ref('snowplow_unified_events') }}
    )

    select
        app_id,
        platform,
        etl_tstamp,
        collector_tstamp,
        dvce_created_tstamp,
        event,
        event_id,
        txn_id,
        name_tracker,
        v_tracker,
        v_collector,
        v_etl,
        user_id,
        user_ipaddress,
        user_fingerprint,
        domain_userid,
        domain_sessionidx,
        network_userid,
        geo_country,
        geo_region,
        geo_city,
        geo_zipcode,
        geo_latitude,
        geo_longitude,
        geo_region_name,
        ip_isp,
        ip_organization,
        ip_domain,
        ip_netspeed,
        page_url,
        page_title,
        page_referrer,
        page_urlscheme,
        page_urlhost,
        page_urlport,
        page_urlpath,
        page_urlquery,
        page_urlfragment,
        refr_urlscheme,
        refr_urlhost,
        refr_urlport,
        refr_urlpath,
        refr_urlquery,
        refr_urlfragment,
        refr_medium,
        refr_source,
        refr_term,
        mkt_medium,
        mkt_source,
        mkt_term,
        mkt_content,
        mkt_campaign,
        se_category,
        se_action,
        se_label,
        se_property,
        se_value,
        tr_orderid,
        tr_affiliation,
        tr_total,
        tr_tax,
        tr_shipping,
        tr_city,
        tr_state,
        tr_country,
        ti_orderid,
        ti_sku,
        ti_name,
        ti_category,
        ti_price,
        ti_quantity,
        pp_xoffset_min,
        pp_xoffset_max,
        pp_yoffset_min,
        pp_yoffset_max,
        useragent,
        br_name,
        br_family,
        br_version,
        br_type,
        br_renderengine,
        br_lang,
        br_features_pdf,
        br_features_flash,
        br_features_java,
        br_features_director,
        br_features_quicktime,
        br_features_realplayer,
        br_features_windowsmedia,
        br_features_gears,
        br_features_silverlight,
        br_cookies,
        br_colordepth,
        br_viewwidth,
        br_viewheight,
        os_name,
        os_family,
        os_manufacturer,
        os_timezone,
        dvce_type,
        dvce_ismobile,
        dvce_screenwidth,
        dvce_screenheight,
        doc_charset,
        doc_width,
        doc_height,
        tr_currency,
        tr_total_base,
        tr_tax_base,
        tr_shipping_base,
        ti_currency,
        ti_price_base,
        base_currency,
        geo_timezone,
        mkt_clickid,
        mkt_network,
        etl_tags,
        dvce_sent_tstamp,
        refr_domain_userid,
        refr_dvce_tstamp,
        domain_sessionid,
        derived_tstamp,
        event_vendor,
        event_name,
        event_format,
        event_version,
        event_fingerprint,
        true_tstamp,
        load_tstamp,
        contexts_com_snowplowanalytics_snowplow_web_page_1,
        struct(
            cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].basis_for_processing as STRING) as basis_for_processing,
            cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].consent_scopes as ARRAY<STRING>) as consent_scopes,
            cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].consent_url as STRING) as consent_url,
            cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].consent_version as STRING) as consent_version,
            cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].domains_applied as ARRAY<STRING>) as domains_applied,
            cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].event_type as STRING) as event_type,
            cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].gdpr_applies as BOOLEAN) as gdpr_applies
        ) as unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1,

        struct(
            cast(unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1[0].elapsed_time as FLOAT) as elapsed_time
        ) as unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1,

        array(
            struct(
                cast(contexts_com_iab_snowplow_spiders_and_robots_1[0].category as STRING) as category,
                cast(contexts_com_iab_snowplow_spiders_and_robots_1[0].primaryImpact as STRING) as primary_impact,
                cast(contexts_com_iab_snowplow_spiders_and_robots_1[0].reason as STRING) as reason,
                cast(contexts_com_iab_snowplow_spiders_and_robots_1[0].spiderOrRobot as BOOLEAN) as spider_or_robot
            )
        ) as contexts_com_iab_snowplow_spiders_and_robots_1,

        array(
            struct(
                cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].deviceFamily as STRING) as device_family,
                cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].osFamily as STRING) as os_family,
                cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].osMajor as STRING) as os_major,
                cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].osMinor as STRING) as os_minor,
                cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].osPatch as STRING) as os_patch,
                cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].osPatchMinor as STRING) as os_patch_minor,
                cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].osVersion as STRING) as os_version,
                cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragentFamily as STRING) as useragent_family,
                cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragentMajor as STRING) as useragent_major,
                cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragentMinor as STRING) as useragent_minor,
                cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragentPatch as STRING) as useragent_patch,
                cast(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragentVersion as STRING) as useragent_version
            )
        ) as contexts_com_snowplowanalytics_snowplow_ua_parser_context_1,

        array(
            struct(
                cast(contexts_nl_basjes_yauaa_context_1[0].agentClass as STRING) as agent_class,
                cast(contexts_nl_basjes_yauaa_context_1[0].agentInformationEmail as STRING) as agent_information_email,
                cast(contexts_nl_basjes_yauaa_context_1[0].agentName as STRING) as agent_name,
                cast(contexts_nl_basjes_yauaa_context_1[0].agentNameVersion as STRING) as agent_name_version,
                cast(contexts_nl_basjes_yauaa_context_1[0].agentNameVersionMajor as STRING) as agent_name_version_major,
                cast(contexts_nl_basjes_yauaa_context_1[0].agentVersion as STRING) as agent_version,
                cast(contexts_nl_basjes_yauaa_context_1[0].agentVersionMajor as STRING) as agent_version_major,
                cast(contexts_nl_basjes_yauaa_context_1[0].deviceBrand as STRING) as device_brand,
                cast(contexts_nl_basjes_yauaa_context_1[0].deviceClass as STRING) as device_class,
                cast(contexts_nl_basjes_yauaa_context_1[0].deviceCpu as STRING) as device_cpu,
                cast(contexts_nl_basjes_yauaa_context_1[0].deviceCpuBits as STRING) as device_cpu_bits,
                cast(contexts_nl_basjes_yauaa_context_1[0].deviceName as STRING) as device_name,
                cast(contexts_nl_basjes_yauaa_context_1[0].deviceVersion as STRING) as device_version,
                cast(contexts_nl_basjes_yauaa_context_1[0].layoutEngineClass as STRING) as layout_engine_class,
                cast(contexts_nl_basjes_yauaa_context_1[0].layoutEngineName as STRING) as layout_engine_name,
                cast(contexts_nl_basjes_yauaa_context_1[0].layoutEngineNameVersion as STRING) as layout_engine_name_version,
                cast(contexts_nl_basjes_yauaa_context_1[0].layoutEngineNameVersionMajor as STRING) as layout_engine_name_version_major,
                cast(contexts_nl_basjes_yauaa_context_1[0].layoutEngineVersion as STRING) as layout_engine_version,
                cast(contexts_nl_basjes_yauaa_context_1[0].layoutEngineVersionMajor as STRING) as layout_engine_version_major,
                cast(contexts_nl_basjes_yauaa_context_1[0].networkType as STRING) as network_type,
                cast(contexts_nl_basjes_yauaa_context_1[0].operatingSystemClass as STRING) as operating_system_class,
                cast(contexts_nl_basjes_yauaa_context_1[0].operatingSystemName as STRING) as operating_system_name,
                cast(contexts_nl_basjes_yauaa_context_1[0].operatingSystemNameVersion as STRING) as operating_system_name_version,
                cast(contexts_nl_basjes_yauaa_context_1[0].operatingSystemNameVersionMajor as STRING) as operating_system_name_version_major,
                cast(contexts_nl_basjes_yauaa_context_1[0].operatingSystemVersion as STRING) as operating_system_version,
                cast(contexts_nl_basjes_yauaa_context_1[0].operatingSystemVersionBuild as STRING) as operating_system_version_build,
                cast(contexts_nl_basjes_yauaa_context_1[0].operatingSystemVersionMajor as STRING) as operating_system_version_major,
                cast(contexts_nl_basjes_yauaa_context_1[0].webviewAppName as STRING) as webview_app_name,
                cast(contexts_nl_basjes_yauaa_context_1[0].webviewAppNameVersionMajor as STRING) as webview_app_name_version_major,
                cast(contexts_nl_basjes_yauaa_context_1[0].webviewAppVersion as STRING) as webview_app_version,
                cast(contexts_nl_basjes_yauaa_context_1[0].webviewAppVersionMajor as STRING) as webview_app_version_major
            )
        ) as contexts_nl_basjes_yauaa_context_1,

        struct(
            cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].id as STRING) AS id,
            cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].name as STRING) AS name,
            cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].previousId as STRING) AS previous_id,
            cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].previousName as STRING) AS previous_name,
            cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].previousType as STRING) AS previous_type,
            cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].transitionType as STRING) AS transition_type,
            cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].type as STRING) AS type
        ) as unstruct_event_com_snowplowanalytics_mobile_screen_view_1,

        array(
            struct(
                cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].firstEventId as STRING) AS first_event_id,
                cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].previousSessionId as STRING) AS previous_session_id,
                cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].sessionId as STRING) AS session_id,
                cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].sessionIndex as INT) AS session_index,
                cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].userId as STRING) AS user_id,
                cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].eventIndex as INT) AS event_index,
                cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].storageMechanism as STRING) AS storage_mechanism,
                cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].firstEventTimestamp as TIMESTAMP) AS first_event_timestamp
            )
        ) as contexts_com_snowplowanalytics_snowplow_client_session_1,

        array(
            struct(
                cast(contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].latitude as STRING) AS latitude,
                cast(contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].longitude as STRING) AS longitude,
                cast(contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].latitudeLongitudeAccuracy as STRING) AS latitude_longitude_accuracy,
                cast(contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].altitude as STRING) AS altitude,
                cast(contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].altitudeAccuracy as STRING) AS altitude_accuracy,
                cast(contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].bearing as STRING) AS bearing,
                cast(contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].speed as STRING) AS speed,
                cast(contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].timestamp as INT) AS timestamp
            )
        ) as contexts_com_snowplowanalytics_snowplow_geolocation_context_1,

        array(
            struct(
                cast(contexts_com_snowplowanalytics_mobile_application_1[0].version as STRING) AS version,
                cast(contexts_com_snowplowanalytics_mobile_application_1[0].build as STRING) AS build
            )
        ) as contexts_com_snowplowanalytics_mobile_application_1,

        array(
            struct(
                cast(contexts_com_snowplowanalytics_mobile_deep_link_1[0].referrer as STRING) AS referrer,
                cast(contexts_com_snowplowanalytics_mobile_deep_link_1[0].url as STRING) AS url
            )
        ) as contexts_com_snowplowanalytics_mobile_deep_link_1,

        array(
            struct(
                cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].viewport as STRING) AS viewport,
                cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].documentSize as STRING) AS document_size,
                cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].resolution as STRING) AS resolution,
                cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].colorDepth as INT) AS color_depth,
                cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].devicePixelRatio as DOUBLE) AS device_pixel_ratio,
                cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].cookiesEnabled as BOOLEAN) AS cookies_enabled,
                cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].online as BOOLEAN) AS online,
                cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].browserLanguage as STRING) AS browser_language,
                cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].documentLanguage as STRING) AS document_language,
                cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].webdriver as BOOLEAN) AS webdriver,
                cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].deviceMemory as INT) AS device_memory,
                cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].hardwareConcurrency as INT) AS hardware_concurrency,
                cast(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].tabId as STRING) AS tab_id
            )
        ) as contexts_com_snowplowanalytics_snowplow_browser_context_1,
        array(
            struct(
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].deviceManufacturer as STRING) AS device_manufacturer,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].deviceModel as STRING) AS device_model,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].osType as STRING) AS os_type,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].osVersion as STRING) AS os_version,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].androidIdfa as STRING) AS android_idfa,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appleIdfa as STRING) AS apple_idfa,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appleIdfv as STRING) AS apple_idfv,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].carrier as STRING) AS carrier,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].openIdfa as STRING) AS open_idfa,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].networkTechnology as STRING) AS network_technology,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].networkType as STRING) AS network_type,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].physicalMemory as INT) AS physical_memory,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].systemAvailableMemory as INT) AS system_available_memory,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appAvailableMemory as INT) AS app_available_memory,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].batteryLevel as INT) AS battery_level,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].batteryState as STRING) AS battery_state,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].lowPowerMode as BOOLEAN) AS low_power_mode,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].availableStorage as INT) AS available_storage,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].totalStorage as BIGINT) AS total_storage,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].isPortrait as STRING) AS is_portrait,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].resolution as STRING) AS resolution,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].scale as STRING) AS scale,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].language as STRING) AS language,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appSetId as STRING) AS app_set_id,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appSetIdScope as STRING) AS app_set_id_scope
            )
        ) as contexts_com_snowplowanalytics_snowplow_mobile_context_1,

        array(
            struct(
                cast(contexts_com_snowplowanalytics_mobile_screen_1[0].id as STRING) AS id,
                cast(contexts_com_snowplowanalytics_mobile_screen_1[0].name as STRING) AS name,
                cast(contexts_com_snowplowanalytics_mobile_screen_1[0].activity as STRING) AS activity,
                cast(contexts_com_snowplowanalytics_mobile_screen_1[0].fragment as STRING) AS fragment,
                cast(contexts_com_snowplowanalytics_mobile_screen_1[0].topViewController as STRING) AS top_view_controller,
                cast(contexts_com_snowplowanalytics_mobile_screen_1[0].type as STRING) AS type,
                cast(contexts_com_snowplowanalytics_mobile_screen_1[0].viewController as STRING) AS view_controller
            )
        ) as contexts_com_snowplowanalytics_mobile_screen_1,
        struct(
            cast(unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].message as STRING) AS message,
            cast(unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].programmingLanguage as STRING) AS programming_language,
            cast(unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].className as STRING) AS class_name,
            cast(unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].exceptionName as STRING) AS exception_name,
            cast(unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].isFatal as BOOLEAN) AS is_fatal,
            cast(unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].lineNumber as DOUBLE) AS line_number,
            cast(unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].stackTrace as STRING) AS stack_trace,
            cast(unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].threadId as STRING) AS thread_id,
            cast(unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].threadName as STRING) AS thread_name
        ) as unstruct_event_com_snowplowanalytics_snowplow_application_error_1

    from
        prep

{% elif var("snowplow__enable_screen_summary_context", false) %}

    with prep as (
        select
            *,

            from_json(unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0,'array<struct<id:string,name:string,previousId:string,previousName:string,previousType:string,transitionType:string,type:string>>') as unstruct_event_com_snowplowanalytics_mobile_screen_view_1,
            from_json(contexts_com_snowplowanalytics_snowplow_client_session_1_0_2,'array<struct<sessionId:string,userId:string,sessionIndex:string,firstEventId:string,previousSessionId:string,eventIndex:string,storageMechanism:string,firstEventTimestamp:timestamp>>') as contexts_com_snowplowanalytics_snowplow_client_session_1,
            from_json(contexts_com_snowplowanalytics_snowplow_mobile_context_1_0_3,'array<struct<deviceManufacturer:string,deviceModel:string,osType:string,osVersion:string,androidIdfa:string,appleIdfa:string,appleIdfv:string,carrier:string,openIdfa:string,networkTechnology:string,networkType:string,physicalMemory:string,systemAvailableMemory:string,appAvailableMemory:string,batteryLevel:string,batteryState:string,lowPowerMode:string,availableStorage:string,totalStorage:string,isPortrait:string,resolution:string,scale:string,language:string,appSetId:string,appSetIdScope:string>>') as contexts_com_snowplowanalytics_snowplow_mobile_context_1,
            from_json(contexts_com_snowplowanalytics_mobile_application_1_0_0,'array<struct<version:string,build:string>>') as contexts_com_snowplowanalytics_mobile_application_1,
            from_json(contexts_com_snowplowanalytics_mobile_screen_1_0_0,'array<struct<id:string,name:string,activity:string,fragment:string,topViewController:string,type:string,viewController:string>>') as contexts_com_snowplowanalytics_mobile_screen_1,
            from_json(contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0,'array<struct<foreground_sec:double,background_sec:double,last_item_index:int,items_count:int,min_x_offset:int,max_x_offset:int,min_y_offset:int,max_y_offset:int,content_width:int,content_height:int>>') as contexts_com_snowplowanalytics_mobile_screen_summary_1

        from {{ ref('snowplow_unified_screen_engagement_events') }}
    )

    select
        * except (
            unstruct_event_com_snowplowanalytics_mobile_screen_view_1,
            contexts_com_snowplowanalytics_snowplow_client_session_1,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1,
            contexts_com_snowplowanalytics_mobile_application_1,
            contexts_com_snowplowanalytics_mobile_screen_1
        ),

        struct(
            cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].id as STRING) AS id,
            cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].name as STRING) AS name,
            cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].previousId as STRING) AS previous_id,
            cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].previousName as STRING) AS previous_name,
            cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].previousType as STRING) AS previous_type,
            cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].transitionType as STRING) AS transition_type,
            cast(unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].type as STRING) AS type
        ) as unstruct_event_com_snowplowanalytics_mobile_screen_view_1,

        array(
            struct(
                cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].firstEventId as STRING) AS first_event_id,
                cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].previousSessionId as STRING) AS previous_session_id,
                cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].sessionId as STRING) AS session_id,
                cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].sessionIndex as INT) AS session_index,
                cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].userId as STRING) AS user_id,
                cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].eventIndex as INT) AS event_index,
                cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].storageMechanism as STRING) AS storage_mechanism,
                cast(contexts_com_snowplowanalytics_snowplow_client_session_1[0].firstEventTimestamp as TIMESTAMP) AS first_event_timestamp
            )
        ) as contexts_com_snowplowanalytics_snowplow_client_session_1,

        array(
            struct(
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].deviceManufacturer as STRING) AS device_manufacturer,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].deviceModel as STRING) AS device_model,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].osType as STRING) AS os_type,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].osVersion as STRING) AS os_version,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].androidIdfa as STRING) AS android_idfa,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appleIdfa as STRING) AS apple_idfa,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appleIdfv as STRING) AS apple_idfv,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].carrier as STRING) AS carrier,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].openIdfa as STRING) AS open_idfa,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].networkTechnology as STRING) AS network_technology,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].networkType as STRING) AS network_type,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].physicalMemory as INT) AS physical_memory,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].systemAvailableMemory as INT) AS system_available_memory,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appAvailableMemory as INT) AS app_available_memory,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].batteryLevel as INT) AS battery_level,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].batteryState as STRING) AS battery_state,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].lowPowerMode as BOOLEAN) AS low_power_mode,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].availableStorage as INT) AS available_storage,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].totalStorage as BIGINT) AS total_storage,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].isPortrait as STRING) AS is_portrait,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].resolution as STRING) AS resolution,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].scale as STRING) AS scale,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].language as STRING) AS language,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appSetId as STRING) AS app_set_id,
                cast(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appSetIdScope as STRING) AS app_set_id_scope
            )
        ) as contexts_com_snowplowanalytics_snowplow_mobile_context_1,



        array(struct(contexts_com_snowplowanalytics_mobile_application_1[0].version::string AS version,
            contexts_com_snowplowanalytics_mobile_application_1[0].build::string AS build)) as contexts_com_snowplowanalytics_mobile_application_1,
        array(struct(contexts_com_snowplowanalytics_mobile_screen_1[0].id::string AS id,
            contexts_com_snowplowanalytics_mobile_screen_1[0].name::string AS name,
            contexts_com_snowplowanalytics_mobile_screen_1[0].activity::string AS activity,
            contexts_com_snowplowanalytics_mobile_screen_1[0].fragment::string AS fragment,
            contexts_com_snowplowanalytics_mobile_screen_1[0].topViewController::string AS top_view_controller,
            contexts_com_snowplowanalytics_mobile_screen_1[0].type::string AS type,
            contexts_com_snowplowanalytics_mobile_screen_1[0].viewController::string AS view_controller)) as contexts_com_snowplowanalytics_mobile_screen_1

    from prep

{% else %}
-- page view context is given as json string in csv. Parse json

  with prep as (
    select
    *,
    from_json(contexts_com_snowplowanalytics_snowplow_web_page_1_0_0, 'array<struct<id:string>>') as contexts_com_snowplowanalytics_snowplow_web_page_1,
    from_json(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1_0_0, 'array<struct<basis_for_processing:string, consent_scopes:array<string>, consent_url:string, consent_version:string, domains_applied:array<string>, event_type:string, gdpr_applies:string>>') as unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1,
    from_json(unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1_0_0, 'array<struct<elapsed_time:string>>') as unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1,
    from_json(unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1_0_0, 'array<struct<cls:string, fcp:string, fid:string, inp:string, lcp:string, navigation_type:string, ttfb:string>>') as unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1,
    from_json(contexts_nl_basjes_yauaa_context_1_0_0, 'array<struct<device_class:string, agent_class:string, agent_name:string, agent_name_version:string, agent_name_version_major:string, agent_version:string, agent_version_major:string, device_brand:string, device_name:string, device_version:string, layout_engine_class:string, layout_engine_name:string, layout_engine_name_version:string, layout_engine_name_version_major:string, layout_engine_version:string, layout_engine_version_major:string, operating_system_class:string, operating_system_name:string, operating_system_name_version:string, operating_system_version:string>>') as contexts_nl_basjes_yauaa_context_1,
    from_json(contexts_com_iab_snowplow_spiders_and_robots_1_0_0, 'array<struct<category:string, primary_impact:string, reason:string, spider_or_robot:string>>') as contexts_com_iab_snowplow_spiders_and_robots_1

  from {{ ref('snowplow_unified_web_vital_events') }}

  )

select
  app_id,
  platform,
  etl_tstamp,
  collector_tstamp,
  dvce_created_tstamp,
  event,
  event_id,
  txn_id,
  name_tracker,
  v_tracker,
  v_collector,
  v_etl,
  user_id,
  user_ipaddress,
  user_fingerprint,
  domain_userid,
  domain_sessionidx,
  network_userid,
  geo_country,
  geo_region,
  geo_city,
  geo_zipcode,
  geo_latitude,
  geo_longitude,
  geo_region_name,
  ip_isp,
  ip_organization,
  ip_domain,
  ip_netspeed,
  page_url,
  page_title,
  page_referrer,
  page_urlscheme,
  page_urlhost,
  page_urlport,
  page_urlpath,
  page_urlquery,
  page_urlfragment,
  refr_urlscheme,
  refr_urlhost,
  refr_urlport,
  refr_urlpath,
  refr_urlquery,
  refr_urlfragment,
  refr_medium,
  refr_source,
  refr_term,
  mkt_medium,
  mkt_source,
  mkt_term,
  mkt_content,
  mkt_campaign,
  se_category,
  se_action,
  se_label,
  se_property,
  se_value,
  tr_orderid,
  tr_affiliation,
  tr_total,
  tr_tax,
  tr_shipping,
  tr_city,
  tr_state,
  tr_country,
  ti_orderid,
  ti_sku,
  ti_name,
  ti_category,
  ti_price,
  ti_quantity,
  pp_xoffset_min,
  pp_xoffset_max,
  pp_yoffset_min,
  pp_yoffset_max,
  useragent,
  br_name,
  br_family,
  br_version,
  br_type,
  br_renderengine,
  br_lang,
  br_features_pdf,
  br_features_flash,
  br_features_java,
  br_features_director,
  br_features_quicktime,
  br_features_realplayer,
  br_features_windowsmedia,
  br_features_gears,
  br_features_silverlight,
  br_cookies,
  br_colordepth,
  br_viewwidth,
  br_viewheight,
  os_name,
  os_family,
  os_manufacturer,
  os_timezone,
  dvce_type,
  dvce_ismobile,
  dvce_screenwidth,
  dvce_screenheight,
  doc_charset,
  doc_width,
  doc_height,
  tr_currency,
  tr_total_base,
  tr_tax_base,
  tr_shipping_base,
  ti_currency,
  ti_price_base,
  base_currency,
  geo_timezone,
  mkt_clickid,
  mkt_network,
  etl_tags,
  dvce_sent_tstamp,
  refr_domain_userid,
  refr_dvce_tstamp,
  domain_sessionid,
  derived_tstamp,
  event_vendor,
  event_name,
  event_format,
  event_version,
  event_fingerprint,
  true_tstamp,
  load_tstamp,
  contexts_com_snowplowanalytics_snowplow_web_page_1,
    struct(
        cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].basis_for_processing as STRING) as basis_for_processing,
        cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].consent_scopes as ARRAY<STRING>) as consent_scopes,
        cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].consent_url as STRING) as consent_url,
        cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].consent_version as STRING) as consent_version,
        cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].domains_applied as ARRAY<STRING>) as domains_applied,
        cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].event_type as STRING) as event_type,
        cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].gdpr_applies as BOOLEAN) as gdpr_applies
    ) as unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1,

    struct(
        cast(unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1[0].elapsed_time as FLOAT) as elapsed_time
    ) as unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1,

    struct(
        cast(unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1[0].lcp as FLOAT) as lcp,
        cast(unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1[0].fcp as FLOAT) as fcp,
        cast(unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1[0].fid as FLOAT) as fid,
        cast(unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1[0].cls as FLOAT) as cls,
        cast(unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1[0].inp as FLOAT) as inp,
        cast(unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1[0].ttfb as FLOAT) as ttfb,
        cast(unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1[0].navigation_type as STRING) as navigation_type
    ) as unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1,

    contexts_nl_basjes_yauaa_context_1,
    contexts_com_iab_snowplow_spiders_and_robots_1,

    struct(
        cast('' as STRING) as basis_for_processing,
        cast('' as STRING) as id,
        cast('' as STRING) as name,
        cast('' as STRING) as previous_id,
        cast('' as STRING) as transition_type,
        cast('' as STRING) as type
    ) as unstruct_event_com_snowplowanalytics_mobile_screen_view_1,
    NULL as contexts_com_snowplowanalytics_snowplow_ua_parser_context_1,
    NULL as contexts_com_snowplowanalytics_snowplow_client_session_1,
    NULL as contexts_com_snowplowanalytics_snowplow_geolocation_context_1,
    NULL as contexts_com_snowplowanalytics_mobile_application_1,
    NULL as contexts_com_snowplowanalytics_mobile_deep_link_1,
    NULL as contexts_com_snowplowanalytics_snowplow_browser_context_1,
    NULL as contexts_com_snowplowanalytics_snowplow_mobile_context_1,
    NULL as contexts_com_snowplowanalytics_mobile_screen_1,
    NULL as unstruct_event_com_snowplowanalytics_snowplow_application_error_1

from prep
{% endif %}
