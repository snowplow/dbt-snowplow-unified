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
        struct(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].basis_for_processing::STRING as basis_for_processing,
            unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].consent_scopes::ARRAY<string> as consent_scopes,
            unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].consent_url::STRING as consent_url,
            unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].consent_version::STRING as consent_version,
            unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].domains_applied::ARRAY<string> as domains_applied,
            unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].event_type::STRING as event_type,
            unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].gdpr_applies::BOOLEAN as gdpr_applies) as unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1,
        struct(unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1[0].elapsed_time::FLOAT as elapsed_time) as unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1,
        array(struct(contexts_com_iab_snowplow_spiders_and_robots_1[0].category as category,
            contexts_com_iab_snowplow_spiders_and_robots_1[0].primaryImpact as primary_impact,
            contexts_com_iab_snowplow_spiders_and_robots_1[0].reason as reason,
            contexts_com_iab_snowplow_spiders_and_robots_1[0].spiderOrRobot as spider_or_robot)) as contexts_com_iab_snowplow_spiders_and_robots_1,
        array(struct(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].deviceFamily as device_family,
            contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].osFamily as os_family,
            contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].osMajor as os_major,
            contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].osMinor as os_minor,
            contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].osPatch as os_patch,
            contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].osPatchMinor as os_patch_minor,
            contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].osVersion as os_version,
            contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragentFamily as useragent_family,
            contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragentMajor as useragent_major,
            contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragentMinor as useragent_minor,
            contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragentPatch as useragent_patch,
            contexts_com_snowplowanalytics_snowplow_ua_parser_context_1[0].useragentVersion as useragent_version)) as contexts_com_snowplowanalytics_snowplow_ua_parser_context_1,
        array(struct(contexts_nl_basjes_yauaa_context_1[0].agentClass as agent_class,
            contexts_nl_basjes_yauaa_context_1[0].agentInformationEmail as agent_information_email,
            contexts_nl_basjes_yauaa_context_1[0].agentName as agent_name,
            contexts_nl_basjes_yauaa_context_1[0].agentNameVersion as agent_name_version,
            contexts_nl_basjes_yauaa_context_1[0].agentNameVersionMajor as agent_name_version_major,
            contexts_nl_basjes_yauaa_context_1[0].agentVersion as agent_version,
            contexts_nl_basjes_yauaa_context_1[0].agentVersionMajor as agent_version_major,
            contexts_nl_basjes_yauaa_context_1[0].deviceBrand as device_brand,
            contexts_nl_basjes_yauaa_context_1[0].deviceClass as device_class,
            contexts_nl_basjes_yauaa_context_1[0].deviceCpu as device_cpu,
            contexts_nl_basjes_yauaa_context_1[0].deviceCpuBits as device_cpu_bits,
            contexts_nl_basjes_yauaa_context_1[0].deviceName as device_name,
            contexts_nl_basjes_yauaa_context_1[0].deviceVersion as device_version,
            contexts_nl_basjes_yauaa_context_1[0].layoutEngineClass as layout_engine_class,
            contexts_nl_basjes_yauaa_context_1[0].layoutEngineName as layout_engine_name,
            contexts_nl_basjes_yauaa_context_1[0].layoutEngineNameVersion as layout_engine_name_version,
            contexts_nl_basjes_yauaa_context_1[0].layoutEngineNameVersionMajor as layout_engine_name_version_major,
            contexts_nl_basjes_yauaa_context_1[0].layoutEngineVersion as layout_engine_version,
            contexts_nl_basjes_yauaa_context_1[0].layoutEngineVersionMajor as layout_engine_version_major,
            contexts_nl_basjes_yauaa_context_1[0].networkType as network_type,
            contexts_nl_basjes_yauaa_context_1[0].operatingSystemClass as operating_system_class,
            contexts_nl_basjes_yauaa_context_1[0].operatingSystemName as operating_system_name,
            contexts_nl_basjes_yauaa_context_1[0].operatingSystemNameVersion as operating_system_name_version,
            contexts_nl_basjes_yauaa_context_1[0].operatingSystemNameVersionMajor as operating_system_name_version_major,
            contexts_nl_basjes_yauaa_context_1[0].operatingSystemVersion as operating_system_version,
            contexts_nl_basjes_yauaa_context_1[0].operatingSystemVersionBuild as operating_system_version_build,
            contexts_nl_basjes_yauaa_context_1[0].operatingSystemVersionMajor as operating_system_version_major,
            contexts_nl_basjes_yauaa_context_1[0].webviewAppName as webview_app_name,
            contexts_nl_basjes_yauaa_context_1[0].webviewAppNameVersionMajor as webview_app_name_version_major,
            contexts_nl_basjes_yauaa_context_1[0].webviewAppVersion as webview_app_version,
            contexts_nl_basjes_yauaa_context_1[0].webviewAppVersionMajor as webview_app_version_major)) as contexts_nl_basjes_yauaa_context_1,
        struct(unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].id::string AS id,
            unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].name::string AS name,
            unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].previousId::string AS previous_id,
            unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].previousName::string AS previous_name,
            unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].previousType::string AS previous_type,
            unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].transitionType::string AS transition_type,
            unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].type::string AS type) as unstruct_event_com_snowplowanalytics_mobile_screen_view_1,
        array(struct(contexts_com_snowplowanalytics_snowplow_client_session_1[0].firstEventId::string AS first_event_id,
            contexts_com_snowplowanalytics_snowplow_client_session_1[0].previousSessionId::string AS previous_session_id,
            contexts_com_snowplowanalytics_snowplow_client_session_1[0].sessionId::string AS session_id,
            contexts_com_snowplowanalytics_snowplow_client_session_1[0].sessionIndex::int AS session_index,
            contexts_com_snowplowanalytics_snowplow_client_session_1[0].userId::string AS user_id,
            contexts_com_snowplowanalytics_snowplow_client_session_1[0].eventIndex::int AS event_index,
            contexts_com_snowplowanalytics_snowplow_client_session_1[0].storageMechanism::string AS storage_mechanism,
            contexts_com_snowplowanalytics_snowplow_client_session_1[0].firstEventTimestamp::timestamp AS first_event_timestamp)) as contexts_com_snowplowanalytics_snowplow_client_session_1,
        array(struct(contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].latitude::string AS latitude,
            contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].longitude::string AS longitude,
            contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].latitudeLongitudeAccuracy::string AS latitude_longitude_accuracy,
            contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].altitude::string AS altitude,
            contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].altitudeAccuracy::string AS altitude_accuracy,
            contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].bearing::string AS bearing,
            contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].speed::string AS speed,
            contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].timestamp::int AS timestamp)) as contexts_com_snowplowanalytics_snowplow_geolocation_context_1,
        array(struct(contexts_com_snowplowanalytics_mobile_application_1[0].version::string AS version,
            contexts_com_snowplowanalytics_mobile_application_1[0].build::string AS build)) as contexts_com_snowplowanalytics_mobile_application_1,
        array(struct(contexts_com_snowplowanalytics_mobile_deep_link_1[0].referrer::string AS referrer,
            contexts_com_snowplowanalytics_mobile_deep_link_1[0].url::string AS url)) as contexts_com_snowplowanalytics_mobile_deep_link_1,
        array(struct(contexts_com_snowplowanalytics_snowplow_browser_context_1[0].viewport::string AS viewport,
            contexts_com_snowplowanalytics_snowplow_browser_context_1[0].documentSize::string AS document_size,
            contexts_com_snowplowanalytics_snowplow_browser_context_1[0].resolution::string AS resolution,
            contexts_com_snowplowanalytics_snowplow_browser_context_1[0].colorDepth::int AS color_depth,
            contexts_com_snowplowanalytics_snowplow_browser_context_1[0].devicePixelRatio::double AS device_pixel_ratio,
            contexts_com_snowplowanalytics_snowplow_browser_context_1[0].cookiesEnabled::boolean AS cookies_enabled,
            contexts_com_snowplowanalytics_snowplow_browser_context_1[0].online::boolean AS online,
            contexts_com_snowplowanalytics_snowplow_browser_context_1[0].browserLanguage::string AS browser_language,
            contexts_com_snowplowanalytics_snowplow_browser_context_1[0].documentLanguage::string AS document_language,
            contexts_com_snowplowanalytics_snowplow_browser_context_1[0].webdriver::boolean AS webdriver,
            contexts_com_snowplowanalytics_snowplow_browser_context_1[0].deviceMemory::int AS device_memory,
            contexts_com_snowplowanalytics_snowplow_browser_context_1[0].hardwareConcurrency::int AS hardware_concurrency,
            contexts_com_snowplowanalytics_snowplow_browser_context_1[0].tabId::string AS tab_id)) as contexts_com_snowplowanalytics_snowplow_browser_context_1,
        array(struct(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].deviceManufacturer::string AS device_manufacturer,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].deviceModel::string AS device_model,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].osType::string AS os_type,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].osVersion::string AS os_version,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].androidIdfa::string AS android_idfa,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appleIdfa::string AS apple_idfa,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appleIdfv::string AS apple_idfv,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].carrier::string AS carrier,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].openIdfa::string AS open_idfa,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].networkTechnology::string AS network_technology,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].networkType::string AS network_type,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].physicalMemory::int AS physical_memory,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].systemAvailableMemory::int AS system_available_memory,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appAvailableMemory::int AS app_available_memory,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].batteryLevel::int AS battery_level,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].batteryState::string AS battery_state,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].lowPowerMode::boolean AS low_power_mode,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].availableStorage::int AS available_storage,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].totalStorage::long AS total_storage,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].isPortrait::string AS is_portrait,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].resolution::string AS resolution,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].scale::string AS scale,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].language::string AS language,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appSetId::string AS app_set_id,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appSetIdScope::string AS app_set_id_scope)) as contexts_com_snowplowanalytics_snowplow_mobile_context_1,
        array(struct(contexts_com_snowplowanalytics_mobile_screen_1[0].id::string AS id,
            contexts_com_snowplowanalytics_mobile_screen_1[0].name::string AS name,
            contexts_com_snowplowanalytics_mobile_screen_1[0].activity::string AS activity,
            contexts_com_snowplowanalytics_mobile_screen_1[0].fragment::string AS fragment,
            contexts_com_snowplowanalytics_mobile_screen_1[0].topViewController::string AS top_view_controller,
            contexts_com_snowplowanalytics_mobile_screen_1[0].type::string AS type,
            contexts_com_snowplowanalytics_mobile_screen_1[0].viewController::string AS view_controller)) as contexts_com_snowplowanalytics_mobile_screen_1,

        struct(unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].message::string AS message,
            unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].programmingLanguage::string AS programming_language,
            unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].className::string AS class_name,
            unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].exceptionName::string AS exception_name,
            unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].isFatal::boolean AS is_fatal,
            unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].lineNumber::double AS line_number,
            unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].stackTrace::string AS stack_trace,
            unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].threadId::string AS thread_id,
            unstruct_event_com_snowplowanalytics_snowplow_application_error_1[0].threadName::string AS thread_name) as unstruct_event_com_snowplowanalytics_snowplow_application_error_1

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

        struct(unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].id::string AS id,
            unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].name::string AS name,
            unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].previousId::string AS previous_id,
            unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].previousName::string AS previous_name,
            unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].previousType::string AS previous_type,
            unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].transitionType::string AS transition_type,
            unstruct_event_com_snowplowanalytics_mobile_screen_view_1[0].type::string AS type) as unstruct_event_com_snowplowanalytics_mobile_screen_view_1,
        array(struct(contexts_com_snowplowanalytics_snowplow_client_session_1[0].firstEventId::string AS first_event_id,
            contexts_com_snowplowanalytics_snowplow_client_session_1[0].previousSessionId::string AS previous_session_id,
            contexts_com_snowplowanalytics_snowplow_client_session_1[0].sessionId::string AS session_id,
            contexts_com_snowplowanalytics_snowplow_client_session_1[0].sessionIndex::int AS session_index,
            contexts_com_snowplowanalytics_snowplow_client_session_1[0].userId::string AS user_id,
            contexts_com_snowplowanalytics_snowplow_client_session_1[0].eventIndex::int AS event_index,
            contexts_com_snowplowanalytics_snowplow_client_session_1[0].storageMechanism::string AS storage_mechanism,
            contexts_com_snowplowanalytics_snowplow_client_session_1[0].firstEventTimestamp::timestamp AS first_event_timestamp)) as contexts_com_snowplowanalytics_snowplow_client_session_1,
        array(struct(contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].deviceManufacturer::string AS device_manufacturer,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].deviceModel::string AS device_model,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].osType::string AS os_type,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].osVersion::string AS os_version,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].androidIdfa::string AS android_idfa,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appleIdfa::string AS apple_idfa,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appleIdfv::string AS apple_idfv,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].carrier::string AS carrier,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].openIdfa::string AS open_idfa,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].networkTechnology::string AS network_technology,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].networkType::string AS network_type,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].physicalMemory::int AS physical_memory,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].systemAvailableMemory::int AS system_available_memory,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appAvailableMemory::int AS app_available_memory,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].batteryLevel::int AS battery_level,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].batteryState::string AS battery_state,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].lowPowerMode::boolean AS low_power_mode,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].availableStorage::int AS available_storage,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].totalStorage::long AS total_storage,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].isPortrait::string AS is_portrait,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].resolution::string AS resolution,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].scale::string AS scale,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].language::string AS language,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appSetId::string AS app_set_id,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].appSetIdScope::string AS app_set_id_scope)) as contexts_com_snowplowanalytics_snowplow_mobile_context_1,
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
  struct(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].basis_for_processing::STRING as basis_for_processing,
        unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].consent_scopes::ARRAY<string> as consent_scopes,
        unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].consent_url::STRING as consent_url,
        unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].consent_version::STRING as consent_version,
        unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].domains_applied::ARRAY<string> as domains_applied,
        unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].event_type::STRING as event_type,
        unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1[0].gdpr_applies::BOOLEAN as gdpr_applies) as unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1,
  struct(unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1[0].elapsed_time::FLOAT as elapsed_time) as unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1,
  struct(unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1[0].lcp::FLOAT as lcp,
        unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1[0].fcp::FLOAT as fcp,
        unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1[0].fid::FLOAT as fid,
        unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1[0].cls::FLOAT as cls,
        unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1[0].inp::FLOAT as inp,
        unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1[0].ttfb::FLOAT as ttfb,
        unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1[0].navigation_type::STRING as navigation_type) as unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1,
  contexts_nl_basjes_yauaa_context_1,
  contexts_com_iab_snowplow_spiders_and_robots_1,
  struct(''::STRING as basis_for_processing, ''::STRING as id, ''::STRING as name, ''::STRING as previous_id, ''::STRING as transition_type, '' as type) as unstruct_event_com_snowplowanalytics_mobile_screen_view_1,
    NULL as contexts_com_snowplowanalytics_snowplow_ua_parser_context_1,
    NULL as unstruct_event_com_snowplowanalytics_mobile_screen_view_1,
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
