{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{# CWV tests run on a different source dataset, this is an easy way to hack them together. #}
{% if not var("snowplow__enable_cwv", false) and not var("snowplow__enable_screen_summary_context", false) %}

  -- page view context is given as json string in csv. Extract array from json
  with prep as (
  select
    *
    except(contexts_com_snowplowanalytics_snowplow_web_page_1_0_0,
            unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1_0_0,
            unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1_0_0,
            contexts_com_iab_snowplow_spiders_and_robots_1_0_0,
            contexts_com_snowplowanalytics_snowplow_ua_parser_context_1_0_0,
            contexts_nl_basjes_yauaa_context_1_0_0,
            unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0,
            contexts_com_snowplowanalytics_snowplow_client_session_1_0_0,
            contexts_com_snowplowanalytics_snowplow_geolocation_context_1_0_0,
            contexts_com_snowplowanalytics_mobile_application_1_0_0,
            contexts_com_snowplowanalytics_mobile_deep_link_1_0_0,
            contexts_com_snowplowanalytics_snowplow_browser_context_1_0_0,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1_0_0,
            contexts_com_snowplowanalytics_mobile_screen_1_0_0,
            unstruct_event_com_snowplowanalytics_snowplow_application_error_1_0_0),
    JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_snowplow_web_page_1_0_0) AS contexts_com_snowplowanalytics_snowplow_web_page_1_0_0,
    JSON_EXTRACT_ARRAY(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1_0_0) AS unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1_0_0,
    JSON_EXTRACT_ARRAY(unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1_0_0) AS unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1_0_0,
    JSON_EXTRACT_ARRAY(contexts_com_iab_snowplow_spiders_and_robots_1_0_0) as contexts_com_iab_snowplow_spiders_and_robots_1_0_0,
    JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1_0_0) as contexts_com_snowplowanalytics_snowplow_ua_parser_context_1_0_0,
    JSON_EXTRACT_ARRAY(contexts_nl_basjes_yauaa_context_1_0_0) as contexts_nl_basjes_yauaa_context_1_0_0,
    JSON_EXTRACT_ARRAY(unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0) as unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0,
    JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_snowplow_client_session_1_0_0) as contexts_com_snowplowanalytics_snowplow_client_session_1_0_0,
    JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_snowplow_geolocation_context_1_0_0) as contexts_com_snowplowanalytics_snowplow_geolocation_context_1_0_0,
    JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_mobile_application_1_0_0) as contexts_com_snowplowanalytics_mobile_application_1_0_0,
    JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_mobile_deep_link_1_0_0) as contexts_com_snowplowanalytics_mobile_deep_link_1_0_0,
    JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_snowplow_browser_context_1_0_0) as contexts_com_snowplowanalytics_snowplow_browser_context_1_0_0,
    JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_snowplow_mobile_context_1_0_0) as contexts_com_snowplowanalytics_snowplow_mobile_context_1_0_0,
    JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_mobile_screen_1_0_0) as contexts_com_snowplowanalytics_mobile_screen_1_0_0,
    JSON_EXTRACT_ARRAY(unstruct_event_com_snowplowanalytics_snowplow_application_error_1_0_0) as unstruct_event_com_snowplowanalytics_snowplow_application_error_1_0_0

  from {{ ref('snowplow_unified_events') }}
  )

  -- recreate repeated record field i.e. array of structs as is originally in BQ events table
  select
    *
    except(contexts_com_snowplowanalytics_snowplow_web_page_1_0_0,
            unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1_0_0,
            unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1_0_0,
            contexts_com_iab_snowplow_spiders_and_robots_1_0_0,
            contexts_com_snowplowanalytics_snowplow_ua_parser_context_1_0_0,
            contexts_nl_basjes_yauaa_context_1_0_0,
            unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0,
            contexts_com_snowplowanalytics_snowplow_client_session_1_0_0,
            contexts_com_snowplowanalytics_snowplow_geolocation_context_1_0_0,
            contexts_com_snowplowanalytics_mobile_application_1_0_0,
            contexts_com_snowplowanalytics_mobile_deep_link_1_0_0,
            contexts_com_snowplowanalytics_snowplow_browser_context_1_0_0,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1_0_0,
            contexts_com_snowplowanalytics_mobile_screen_1_0_0,
            unstruct_event_com_snowplowanalytics_snowplow_application_error_1_0_0),
    array(
      select as struct
        JSON_EXTRACT_scalar(json_array,'$.id') as id
      from unnest(contexts_com_snowplowanalytics_snowplow_web_page_1_0_0) as json_array
      ) as contexts_com_snowplowanalytics_snowplow_web_page_1_0_0,

    array(
      select as struct
        JSON_EXTRACT_scalar(json_array,'$.basis_for_processing') as basis_for_processing,
        JSON_EXTRACT_STRING_ARRAY(json_array,'$.consent_scopes') as consent_scopes,
        JSON_EXTRACT_scalar(json_array,'$.consent_url') as consent_url,
        JSON_EXTRACT_scalar(json_array,'$.consent_version') as consent_version,
        JSON_EXTRACT_STRING_ARRAY(json_array,'$.domains_applied') as domains_applied,
        JSON_EXTRACT_scalar(json_array,'$.event_type') as event_type,
        JSON_EXTRACT_scalar(json_array,'$.gdpr_applies') as gdpr_applies
        from unnest(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1_0_0) as json_array
          ) as unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1_0_0,

    array(
      select as struct
        JSON_EXTRACT_scalar(json_array,'$.elapsed_time') as elapsed_time
        from unnest(unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1_0_0) as json_array
              ) as unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1_0_0,

    array(
      select as struct
        JSON_EXTRACT_scalar(json_array,'$.category') as category,
        JSON_EXTRACT_scalar(json_array,'$.primaryImpact') as primary_impact,
        JSON_EXTRACT_scalar(json_array,'$.reason') as reason,
        cast(JSON_EXTRACT_scalar(json_array ,'$.spiderOrRobot') as boolean) as spider_or_robot
      from unnest(contexts_com_iab_snowplow_spiders_and_robots_1_0_0) as json_array
      ) as contexts_com_iab_snowplow_spiders_and_robots_1_0_0,

    array(
      select as struct
        JSON_EXTRACT_scalar(json_array,'$.deviceFamily') as device_family,
        JSON_EXTRACT_scalar(json_array,'$.osFamily') as os_family,
        JSON_EXTRACT_scalar(json_array,'$.osMajor') as os_major,
        JSON_EXTRACT_scalar(json_array,'$.osMinor') as os_minor,
        JSON_EXTRACT_scalar(json_array,'$.osPatch') as os_patch,
        JSON_EXTRACT_scalar(json_array,'$.osPatchMinor') as os_patch_minor,
        JSON_EXTRACT_scalar(json_array,'$.osVersion') as os_version,
        JSON_EXTRACT_scalar(json_array,'$.useragentFamily') as useragent_family,
        JSON_EXTRACT_scalar(json_array,'$.useragentMajor') as useragent_major,
        JSON_EXTRACT_scalar(json_array,'$.useragentMinor') as useragent_minor,
        JSON_EXTRACT_scalar(json_array,'$.useragentPatch') as useragent_patch,
        JSON_EXTRACT_scalar(json_array,'$.useragentVersion') as useragent_version
      from unnest(contexts_com_snowplowanalytics_snowplow_ua_parser_context_1_0_0) as json_array
      ) as contexts_com_snowplowanalytics_snowplow_ua_parser_context_1_0_0,

    array(
      select as struct
        JSON_EXTRACT_scalar(json_array,'$.agentClass') as agent_class,
        JSON_EXTRACT_scalar(json_array,'$.agentInformationEmail') as agent_information_email,
        JSON_EXTRACT_scalar(json_array,'$.agentName') as agent_name,
        JSON_EXTRACT_scalar(json_array,'$.agentNameVersion') as agent_name_version,
        JSON_EXTRACT_scalar(json_array,'$.agentNameVersionMajor') as agent_name_version_major,
        JSON_EXTRACT_scalar(json_array,'$.agentVersion') as agent_version,
        JSON_EXTRACT_scalar(json_array,'$.agentVersionMajor') as agent_version_major,
        JSON_EXTRACT_scalar(json_array,'$.deviceBrand') as device_brand,
        JSON_EXTRACT_scalar(json_array,'$.deviceClass') as device_class,
        JSON_EXTRACT_scalar(json_array,'$.deviceCpu') as device_cpu,
        JSON_EXTRACT_scalar(json_array,'$.deviceCpuBits') as device_cpu_bits,
        JSON_EXTRACT_scalar(json_array,'$.deviceName') as device_name,
        JSON_EXTRACT_scalar(json_array,'$.deviceVersion') as device_version,
        JSON_EXTRACT_scalar(json_array,'$.layoutEngineClass') as layout_engine_class,
        JSON_EXTRACT_scalar(json_array,'$.layoutEngineName') as layout_engine_name,
        JSON_EXTRACT_scalar(json_array,'$.layoutEngineNameVersion') as layout_engine_name_version,
        JSON_EXTRACT_scalar(json_array,'$.layoutEngineNameVersionMajor') as layout_engine_name_version_major,
        JSON_EXTRACT_scalar(json_array,'$.layoutEngineVersion') as layout_engine_version,
        JSON_EXTRACT_scalar(json_array,'$.layoutEngineVersionMajor') as layout_engine_version_major,
        JSON_EXTRACT_scalar(json_array,'$.networkType') as network_type,
        JSON_EXTRACT_scalar(json_array,'$.operatingSystemClass') as operating_system_class,
        JSON_EXTRACT_scalar(json_array,'$.operatingSystemName') as operating_system_name,
        JSON_EXTRACT_scalar(json_array,'$.operatingSystemNameVersion') as operating_system_name_version,
        JSON_EXTRACT_scalar(json_array,'$.operatingSystemNameVersionMajor') as operating_system_name_version_major,
        JSON_EXTRACT_scalar(json_array,'$.operatingSystemVersion') as operating_system_version,
        JSON_EXTRACT_scalar(json_array,'$.operatingSystemVersionBuild') as operating_system_version_build,
        JSON_EXTRACT_scalar(json_array,'$.operatingSystemVersionMajor') as operating_system_version_major,
        JSON_EXTRACT_scalar(json_array,'$.webviewAppName') as webview_app_name,
        JSON_EXTRACT_scalar(json_array,'$.webviewAppNameVersionMajor') as webview_app_name_version_major,
        JSON_EXTRACT_scalar(json_array,'$.webviewAppVersion') as webview_app_version,
        JSON_EXTRACT_scalar(json_array,'$.webviewAppVersionMajor') as webview_app_version_major
      from unnest(contexts_nl_basjes_yauaa_context_1_0_0) as json_array
      ) as contexts_nl_basjes_yauaa_context_1_0_0,

    array(
      select as struct
        JSON_EXTRACT_scalar(json_array,'$.id') as id,
        JSON_EXTRACT_scalar(json_array,'$.name') as name,
        JSON_EXTRACT_scalar(json_array,'$.previousId') as previous_id,
        JSON_EXTRACT_scalar(json_array,'$.previousName') as previous_name,
        JSON_EXTRACT_scalar(json_array,'$.previousType') as previous_type,
        JSON_EXTRACT_scalar(json_array,'$.transitionType') as transition_type,
        JSON_EXTRACT_scalar(json_array,'$.type') as type
         from unnest(unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0) as json_array
            ) as unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0,
  array(
    select as struct JSON_EXTRACT_scalar(json_array,'$.sessionId') as session_id,
                    JSON_EXTRACT_scalar(json_array,'$.userId') as user_id,
                    cast(JSON_EXTRACT_scalar(json_array,'$.sessionIndex') as integer) as session_index,
                    JSON_EXTRACT_scalar(json_array,'$.firstEventId') as first_event_id,
                    JSON_EXTRACT_scalar(json_array,'$.previousSessionId') as previous_session_id,
                    JSON_EXTRACT_scalar(json_array,'$.eventIndex') as event_index,
                    JSON_EXTRACT_scalar(json_array,'$.storageMechanism') as storage_mechanism,
                    JSON_EXTRACT_scalar(json_array,'$.firstEventTimestamp') as first_event_timestamp
    from unnest(contexts_com_snowplowanalytics_snowplow_client_session_1_0_0) as json_array
    ) as contexts_com_snowplowanalytics_snowplow_client_session_1_0_0,
  array(
    select as struct cast(JSON_EXTRACT_scalar(json_array,'$.latitude') as FLOAT64) as latitude,
                    cast(JSON_EXTRACT_scalar(json_array,'$.longitude') as FLOAT64) as longitude,
                    cast(JSON_EXTRACT_scalar(json_array,'$.latitudeLongitudeAccuracy') as FLOAT64) as latitude_longitude_accuracy,
                    cast(JSON_EXTRACT_scalar(json_array,'$.altitude') as FLOAT64) as altitude,
                    cast(JSON_EXTRACT_scalar(json_array,'$.altitudeAccuracy')  as FLOAT64)as altitude_accuracy,
                    cast(JSON_EXTRACT_scalar(json_array,'$.bearing')  as FLOAT64)as bearing,
                    cast(JSON_EXTRACT_scalar(json_array,'$.speed') as FLOAT64) as speed,
                    cast(JSON_EXTRACT_scalar(json_array,'$.timestamp') as integer) as timestamp
    from unnest(contexts_com_snowplowanalytics_snowplow_geolocation_context_1_0_0) as json_array
    ) as contexts_com_snowplowanalytics_snowplow_geolocation_context_1_0_0,

    array(
      select as struct
        JSON_EXTRACT_scalar(json_array,'$.viewport') as viewport,
        JSON_EXTRACT_scalar(json_array,'$.documentSize') as document_size,
        JSON_EXTRACT_scalar(json_array,'$.resolution') as resolution,
        cast(JSON_EXTRACT_scalar(json_array,'$.colorDepth') as integer) as color_depth,
        cast(JSON_EXTRACT_scalar(json_array,'$.devicePixelRatio') as FLOAT64) as device_pixel_ratio,
        cast(JSON_EXTRACT_scalar(json_array,'$.cookiesEnabled') as boolean) as cookies_enabled,
        cast(JSON_EXTRACT_scalar(json_array,'$.online') as boolean) as online,
        JSON_EXTRACT_scalar(json_array,'$.browserLanguage') as browser_language,
        JSON_EXTRACT_scalar(json_array,'$.documentLanguage') as document_language,
        cast(JSON_EXTRACT_scalar(json_array,'$.webdriver') as boolean) as webdriver,
        cast(JSON_EXTRACT_scalar(json_array,'$.deviceMemory') as integer) as device_memory,
        cast(JSON_EXTRACT_scalar(json_array,'$.hardwareConcurrency') as integer) as hardware_concurrency,
        JSON_EXTRACT_scalar(json_array,'$.tab_id') as tab_id
      from unnest(contexts_com_snowplowanalytics_snowplow_browser_context_1_0_0) as json_array
      ) as contexts_com_snowplowanalytics_snowplow_browser_context_1_0_0,


    array(
      select as struct
        JSON_EXTRACT_scalar(json_array,'$.viewport') as viewport,
        JSON_EXTRACT_scalar(json_array,'$.documentSize') as document_size,
        JSON_EXTRACT_scalar(json_array,'$.resolution') as resolution,
        cast(JSON_EXTRACT_scalar(json_array,'$.colorDepth') as integer) as color_depth,
        cast(JSON_EXTRACT_scalar(json_array,'$.devicePixelRatio') as FLOAT64) as device_pixel_ratio,
        cast(JSON_EXTRACT_scalar(json_array,'$.cookiesEnabled') as boolean) as cookies_enabled,
        cast(JSON_EXTRACT_scalar(json_array,'$.online') as boolean) as online,
        JSON_EXTRACT_scalar(json_array,'$.browserLanguage') as browser_language,
        JSON_EXTRACT_scalar(json_array,'$.documentLanguage') as document_language,
        cast(JSON_EXTRACT_scalar(json_array,'$.webdriver') as boolean) as webdriver,
        cast(JSON_EXTRACT_scalar(json_array,'$.deviceMemory') as integer) as device_memory,
        cast(JSON_EXTRACT_scalar(json_array,'$.hardwareConcurrency') as integer) as hardware_concurrency,
        JSON_EXTRACT_scalar(json_array,'$.tab_id') as tab_id
      from unnest(contexts_com_snowplowanalytics_snowplow_browser_context_1_0_0) as json_array
      ) as contexts_com_snowplowanalytics_snowplow_browser_context_2_0_0,

    array(
    select as struct JSON_EXTRACT_scalar(json_array,'$.version') as version,
                    JSON_EXTRACT_scalar(json_array,'$.build') as build
    from unnest(contexts_com_snowplowanalytics_mobile_application_1_0_0) as json_array
    ) as contexts_com_snowplowanalytics_mobile_application_1_0_0,

    array(
    select as struct JSON_EXTRACT_scalar(json_array,'$.url') as url,
                    JSON_EXTRACT_scalar(json_array,'$.referrer') as referrer
    from unnest(contexts_com_snowplowanalytics_mobile_deep_link_1_0_0) as json_array
    ) as contexts_com_snowplowanalytics_mobile_deep_link_1_0_0,

    array(
      select as struct
        JSON_EXTRACT_scalar(json_array,'$.deviceManufacturer') as device_manufacturer,
        JSON_EXTRACT_scalar(json_array,'$.deviceModel') as device_model,
        JSON_EXTRACT_scalar(json_array,'$.osType') as os_type,
        JSON_EXTRACT_scalar(json_array,'$.osVersion') as os_version,
        JSON_EXTRACT_scalar(json_array,'$.androidIdfa') as android_idfa,
        JSON_EXTRACT_scalar(json_array,'$.appleIdfa') as apple_idfa,
        JSON_EXTRACT_scalar(json_array,'$.appleIdfv') as apple_idfv,
        JSON_EXTRACT_scalar(json_array,'$.carrier') as carrier,
        JSON_EXTRACT_scalar(json_array,'$.openIdfa') as open_idfa,
        JSON_EXTRACT_scalar(json_array,'$.networkTechnology') as network_technology,
        JSON_EXTRACT_scalar(json_array,'$.networkType') as network_type,
        cast(JSON_EXTRACT_scalar(json_array,'$.physicalMemory') as integer) as physical_memory,
        cast(JSON_EXTRACT_scalar(json_array,'$.systemAvailableMemory') as integer) as system_available_memory,
        cast(JSON_EXTRACT_scalar(json_array,'$.appAvailableMemory') as integer) as app_available_memory,
        cast(JSON_EXTRACT_scalar(json_array,'$.batteryLevel') as integer) as battery_level,
        JSON_EXTRACT_scalar(json_array,'$.batteryState') as battery_state,
        cast(JSON_EXTRACT_scalar(json_array,'$.availableStorage') as integer) as available_storage,
        cast(JSON_EXTRACT_scalar(json_array,'$.totalStorage') as integer) as total_storage,
        cast(JSON_EXTRACT_scalar(json_array,'$.lowPowerMode') as boolean) as low_power_mode,
        cast(JSON_EXTRACT_scalar(json_array,'$.isPortrait') as boolean) as is_portrait,
        JSON_EXTRACT_scalar(json_array,'$.resolution') as resolution,
        cast(JSON_EXTRACT_scalar(json_array,'$.scale') as integer) as scale,
        JSON_EXTRACT_scalar(json_array,'$.language') as language,
        JSON_EXTRACT_scalar(json_array,'$.appSetId') as app_set_id,
        JSON_EXTRACT_scalar(json_array,'$.appSetIdScope') as app_set_id_scope

      from unnest(contexts_com_snowplowanalytics_snowplow_mobile_context_1_0_0) as json_array
      ) as contexts_com_snowplowanalytics_snowplow_mobile_context_1_0_0,

    array(
      select as struct JSON_EXTRACT_scalar(json_array,'$.id') as id,
                      JSON_EXTRACT_scalar(json_array,'$.name') as name,
                      JSON_EXTRACT_scalar(json_array,'$.activity') as activity,
                      JSON_EXTRACT_scalar(json_array,'$.fragment') as fragment,
                      JSON_EXTRACT_scalar(json_array,'$.topViewController') as top_view_controller,
                      JSON_EXTRACT_scalar(json_array,'$.type') as type,
                      JSON_EXTRACT_scalar(json_array,'$.viewController') as view_controller
      from unnest(contexts_com_snowplowanalytics_mobile_screen_1_0_0) as json_array
      ) as contexts_com_snowplowanalytics_mobile_screen_1_0_0,


    array(
      select as struct
        JSON_EXTRACT_scalar(json_array,'$.message') as message,
        JSON_EXTRACT_scalar(json_array,'$.programmingLanguage') as programming_language,
        JSON_EXTRACT_scalar(json_array,'$.className') as class_name,
        JSON_EXTRACT_scalar(json_array,'$.exceptionName') as exception_name,
        cast(JSON_EXTRACT_scalar(json_array,'$.isFatal') as boolean) as is_fatal,
        cast(JSON_EXTRACT_scalar(json_array,'$.lineNumber') as integer) as line_number,
        JSON_EXTRACT_scalar(json_array,'$.stackTrace') as stack_trace,
        cast(JSON_EXTRACT_scalar(json_array,'$.threadId') as integer) as thread_id,
        JSON_EXTRACT_scalar(json_array,'$.threadName') as thread_name
         from unnest(unstruct_event_com_snowplowanalytics_snowplow_application_error_1_0_0) as json_array
              ) as unstruct_event_com_snowplowanalytics_snowplow_application_error_1_0_0

  from prep

{% elif var("snowplow__enable_screen_summary_context", false) %}

  with prep as (
  select
    *
    except(unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0,
            contexts_com_snowplowanalytics_snowplow_client_session_1_0_2,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1_0_3,
            contexts_com_snowplowanalytics_mobile_application_1_0_0,
            contexts_com_snowplowanalytics_mobile_screen_1_0_0,
            contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0),

    JSON_EXTRACT_ARRAY(unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0) as unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0,
    JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_snowplow_client_session_1_0_2) as contexts_com_snowplowanalytics_snowplow_client_session_1_0_2,
    JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_snowplow_mobile_context_1_0_3) as contexts_com_snowplowanalytics_snowplow_mobile_context_1_0_3,
    JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_mobile_application_1_0_0) as contexts_com_snowplowanalytics_mobile_application_1_0_0,
    JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_mobile_screen_1_0_0) as contexts_com_snowplowanalytics_mobile_screen_1_0_0,
    JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0) as contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0

  from {{ ref('snowplow_unified_screen_engagement_events') }}
  )

  -- recreate repeated record field i.e. array of structs as is originally in BQ events table
  select
    *
    except(unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0,
            contexts_com_snowplowanalytics_snowplow_client_session_1_0_2,
            contexts_com_snowplowanalytics_snowplow_mobile_context_1_0_3,
            contexts_com_snowplowanalytics_mobile_application_1_0_0,
            contexts_com_snowplowanalytics_mobile_screen_1_0_0,
            contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0),

    array(
      select as struct
        JSON_EXTRACT_scalar(json_array,'$.id') as id,
        JSON_EXTRACT_scalar(json_array,'$.name') as name,
        JSON_EXTRACT_scalar(json_array,'$.previousId') as previous_id,
        JSON_EXTRACT_scalar(json_array,'$.previousName') as previous_name,
        JSON_EXTRACT_scalar(json_array,'$.previousType') as previous_type,
        JSON_EXTRACT_scalar(json_array,'$.transitionType') as transition_type,
        JSON_EXTRACT_scalar(json_array,'$.type') as type
         from unnest(unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0) as json_array
            ) as unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0,

    array(
      select as struct JSON_EXTRACT_scalar(json_array,'$.sessionId') as session_id,
                      JSON_EXTRACT_scalar(json_array,'$.userId') as user_id,
                      cast(JSON_EXTRACT_scalar(json_array,'$.sessionIndex') as integer) as session_index,
                      JSON_EXTRACT_scalar(json_array,'$.firstEventId') as first_event_id,
                      JSON_EXTRACT_scalar(json_array,'$.previousSessionId') as previous_session_id,
                      JSON_EXTRACT_scalar(json_array,'$.eventIndex') as event_index,
                      JSON_EXTRACT_scalar(json_array,'$.storageMechanism') as storage_mechanism,
                      JSON_EXTRACT_scalar(json_array,'$.firstEventTimestamp') as first_event_timestamp
      from unnest(contexts_com_snowplowanalytics_snowplow_client_session_1_0_2) as json_array
      ) as contexts_com_snowplowanalytics_snowplow_client_session_1_0_2,

    array(
      select as struct JSON_EXTRACT_scalar(json_array,'$.version') as version,
                      JSON_EXTRACT_scalar(json_array,'$.build') as build
      from unnest(contexts_com_snowplowanalytics_mobile_application_1_0_0) as json_array
    ) as contexts_com_snowplowanalytics_mobile_application_1_0_0,

    array(
      select as struct
        JSON_EXTRACT_scalar(json_array,'$.deviceManufacturer') as device_manufacturer,
        JSON_EXTRACT_scalar(json_array,'$.deviceModel') as device_model,
        JSON_EXTRACT_scalar(json_array,'$.osType') as os_type,
        JSON_EXTRACT_scalar(json_array,'$.osVersion') as os_version,
        JSON_EXTRACT_scalar(json_array,'$.androidIdfa') as android_idfa,
        JSON_EXTRACT_scalar(json_array,'$.appleIdfa') as apple_idfa,
        JSON_EXTRACT_scalar(json_array,'$.appleIdfv') as apple_idfv,
        JSON_EXTRACT_scalar(json_array,'$.carrier') as carrier,
        JSON_EXTRACT_scalar(json_array,'$.openIdfa') as open_idfa,
        JSON_EXTRACT_scalar(json_array,'$.networkTechnology') as network_technology,
        JSON_EXTRACT_scalar(json_array,'$.networkType') as network_type,
        cast(JSON_EXTRACT_scalar(json_array,'$.physicalMemory') as integer) as physical_memory,
        cast(JSON_EXTRACT_scalar(json_array,'$.systemAvailableMemory') as integer) as system_available_memory,
        cast(JSON_EXTRACT_scalar(json_array,'$.appAvailableMemory') as integer) as app_available_memory,
        cast(JSON_EXTRACT_scalar(json_array,'$.batteryLevel') as integer) as battery_level,
        JSON_EXTRACT_scalar(json_array,'$.batteryState') as battery_state,
        cast(JSON_EXTRACT_scalar(json_array,'$.availableStorage') as integer) as available_storage,
        cast(JSON_EXTRACT_scalar(json_array,'$.totalStorage') as integer) as total_storage,
        cast(JSON_EXTRACT_scalar(json_array,'$.lowPowerMode') as boolean) as low_power_mode,
        cast(JSON_EXTRACT_scalar(json_array,'$.isPortrait') as boolean) as is_portrait,
        JSON_EXTRACT_scalar(json_array,'$.resolution') as resolution,
        cast(JSON_EXTRACT_scalar(json_array,'$.scale') as integer) as scale,
        JSON_EXTRACT_scalar(json_array,'$.language') as language,
        JSON_EXTRACT_scalar(json_array,'$.appSetId') as app_set_id,
        JSON_EXTRACT_scalar(json_array,'$.appSetIdScope') as app_set_id_scope

      from unnest(contexts_com_snowplowanalytics_snowplow_mobile_context_1_0_3) as json_array
      ) as contexts_com_snowplowanalytics_snowplow_mobile_context_1_0_3,

    array(
      select as struct JSON_EXTRACT_scalar(json_array,'$.id') as id,
                      JSON_EXTRACT_scalar(json_array,'$.name') as name,
                      JSON_EXTRACT_scalar(json_array,'$.activity') as activity,
                      JSON_EXTRACT_scalar(json_array,'$.fragment') as fragment,
                      JSON_EXTRACT_scalar(json_array,'$.topViewController') as top_view_controller,
                      JSON_EXTRACT_scalar(json_array,'$.type') as type,
                      JSON_EXTRACT_scalar(json_array,'$.viewController') as view_controller
      from unnest(contexts_com_snowplowanalytics_mobile_screen_1_0_0) as json_array
      ) as contexts_com_snowplowanalytics_mobile_screen_1_0_0,

    array(
      select as struct cast(JSON_EXTRACT_scalar(json_array,'$.foreground_sec') as FLOAT64) as foreground_sec,
                      cast(JSON_EXTRACT_scalar(json_array,'$.background_sec') as FLOAT64) as background_sec,
                      cast(JSON_EXTRACT_scalar(json_array,'$.last_item_index') as integer) as last_item_index,
                      cast(JSON_EXTRACT_scalar(json_array,'$.items_count') as integer) as items_count,
                      cast(JSON_EXTRACT_scalar(json_array,'$.min_x_offset') as integer) as min_x_offset,
                      cast(JSON_EXTRACT_scalar(json_array,'$.max_x_offset') as integer) as max_x_offset,
                      cast(JSON_EXTRACT_scalar(json_array,'$.min_y_offset') as integer) as min_y_offset,
                      cast(JSON_EXTRACT_scalar(json_array,'$.max_y_offset') as integer) as max_y_offset,
                      cast(JSON_EXTRACT_scalar(json_array,'$.content_width') as integer) as content_width,
                      cast(JSON_EXTRACT_scalar(json_array,'$.content_height') as integer) as content_height
      from unnest(contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0) as json_array
    ) as contexts_com_snowplowanalytics_mobile_screen_summary_1_0_0

  from prep

{% else %}
  -- page view context is given as json string in csv. Parse json
  with prep as (
    select
      *
      except(contexts_com_snowplowanalytics_snowplow_web_page_1_0_0, unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1_0_0, unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1_0_0,  unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1_0_0, contexts_nl_basjes_yauaa_context_1_0_0, contexts_com_iab_snowplow_spiders_and_robots_1_0_0),
      JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_snowplow_web_page_1_0_0) AS contexts_com_snowplowanalytics_snowplow_web_page_1_0_0,
      JSON_EXTRACT_ARRAY(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1_0_0) AS unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1_0_0,
      JSON_EXTRACT_ARRAY(unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1_0_0) AS unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1_0_0,
      JSON_EXTRACT_ARRAY(unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1_0_0) AS unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1_0_0,
      JSON_EXTRACT_ARRAY(contexts_nl_basjes_yauaa_context_1_0_0) AS contexts_nl_basjes_yauaa_context_1_0_0,
      JSON_EXTRACT_ARRAY(contexts_com_iab_snowplow_spiders_and_robots_1_0_0) AS contexts_com_iab_snowplow_spiders_and_robots_1_0_0

    from {{ ref('snowplow_unified_web_vital_events') }}
  )
  -- recreate repeated record field i.e. array of structs as is originally in BQ events table
  select
    *
    except(contexts_com_snowplowanalytics_snowplow_web_page_1_0_0, unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1_0_0, unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1_0_0, unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1_0_0, contexts_nl_basjes_yauaa_context_1_0_0, contexts_com_iab_snowplow_spiders_and_robots_1_0_0),
    array(
      select as struct JSON_EXTRACT_scalar(json_array,'$.id') as id
      from unnest(contexts_com_snowplowanalytics_snowplow_web_page_1_0_0) as json_array
      ) as contexts_com_snowplowanalytics_snowplow_web_page_1_0_0,

    array(
      select as struct
        JSON_EXTRACT_scalar(json_array,'$.basis_for_processing') as basis_for_processing,
        JSON_EXTRACT_STRING_ARRAY(json_array,'$.consent_scopes') as consent_scopes,
        JSON_EXTRACT_scalar(json_array,'$.consent_url') as consent_url,
        JSON_EXTRACT_scalar(json_array,'$.consent_version') as consent_version,
        JSON_EXTRACT_STRING_ARRAY(json_array,'$.domains_applied') as domains_applied,
        JSON_EXTRACT_scalar(json_array,'$.event_type') as event_type,
        JSON_EXTRACT_scalar(json_array,'$.gdpr_applies') as gdpr_applies
        from unnest(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1_0_0) as json_array
              ) as unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1_0_0,

    array(
      select as struct
        JSON_EXTRACT_scalar(json_array,'$.elapsed_time') as elapsed_time
        from unnest(unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1_0_0) as json_array
              ) as unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1_0_0,
    array(
      select as struct
        JSON_EXTRACT_scalar(json_array,'$.cls') as cls,
        JSON_EXTRACT_scalar(json_array,'$.fcp') as fcp,
        JSON_EXTRACT_scalar(json_array,'$.fid') as fid,
        JSON_EXTRACT_scalar(json_array,'$.inp') as inp,
        JSON_EXTRACT_scalar(json_array,'$.lcp') as lcp,
        JSON_EXTRACT_scalar(json_array,'$.navigation_type') as navigation_type,
        JSON_EXTRACT_scalar(json_array,'$.ttfb') as ttfb
        from unnest(unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1_0_0) as json_array
              ) as unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1_0_0,

    array(
      select as struct JSON_EXTRACT_scalar(json_array,'$.device_class') as device_class,
      JSON_EXTRACT_scalar(json_array,'$.agent_class') as agent_class,
      JSON_EXTRACT_scalar(json_array,'$.agent_name') as agent_name,
      JSON_EXTRACT_scalar(json_array,'$.agent_name_version') as agent_name_version,
      JSON_EXTRACT_scalar(json_array,'$.agent_name_version_major') as agent_name_version_major,
      JSON_EXTRACT_scalar(json_array,'$.agent_version') as agent_version,
      JSON_EXTRACT_scalar(json_array,'$.agent_version_major') as agent_version_major,
      JSON_EXTRACT_scalar(json_array,'$.device_brand') as device_brand,
      JSON_EXTRACT_scalar(json_array,'$.device_name') as device_name,
      JSON_EXTRACT_scalar(json_array,'$.device_version') as device_version,
      JSON_EXTRACT_scalar(json_array,'$.layout_engine_class') as layout_engine_class,
      JSON_EXTRACT_scalar(json_array,'$.layout_engine_name') as layout_engine_name,
      JSON_EXTRACT_scalar(json_array,'$.layout_engine_name_version') as layout_engine_name_version,
      JSON_EXTRACT_scalar(json_array,'$.layout_engine_name_version_major') as layout_engine_name_version_major,
      JSON_EXTRACT_scalar(json_array,'$.layout_engine_version') as layout_engine_version,
      JSON_EXTRACT_scalar(json_array,'$.layout_engine_version_major') as layout_engine_version_major,
      JSON_EXTRACT_scalar(json_array,'$.operating_system_class') as operating_system_class,
      JSON_EXTRACT_scalar(json_array,'$.operating_system_name') as operating_system_name,
      JSON_EXTRACT_scalar(json_array,'$.operating_system_name_version') as operating_system_name_version,
      JSON_EXTRACT_scalar(json_array,'$.operating_system_version') as operating_system_version

      from unnest(contexts_nl_basjes_yauaa_context_1_0_0) as json_array
      ) as contexts_nl_basjes_yauaa_context_1_0_0,

    array(
      select as struct JSON_EXTRACT_scalar(json_array,'$.category') as category,
                    JSON_EXTRACT_scalar(json_array,'$.primary_impact') as primary_impact,
                    JSON_EXTRACT_scalar(json_array,'$.reason') as reason,
                    JSON_EXTRACT_scalar(json_array,'$.spider_or_robot') as spider_or_robot

      from unnest(contexts_com_iab_snowplow_spiders_and_robots_1_0_0) as json_array
      ) as contexts_com_iab_snowplow_spiders_and_robots_1_0_0
  from prep

{% endif %}
