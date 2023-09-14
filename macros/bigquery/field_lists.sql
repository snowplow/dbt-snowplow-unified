{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro bq_iab_fields() %}

  {% set iab_fields = [
      {'field':('category', 'iab__category'), 'dtype':'string'},
      {'field':('primary_impact', 'iab__primary_impact'), 'dtype':'string'},
      {'field':('reason', 'iab__reason'), 'dtype':'string'},
      {'field':('spider_or_robot', 'iab__spider_or_robot'), 'dtype':'boolean'}
    ] %}

  {{ return(iab_fields) }}

{% endmacro %}

{% macro bq_ua_fields() %}

  {% set ua_fields = [
      {'field':('useragent_family', 'ua__useragent_family'), 'dtype': 'string'},
      {'field':('useragent_major', 'ua__useragent_major'), 'dtype': 'string'},
      {'field':('useragent_minor', 'ua__useragent_minor'), 'dtype': 'string'},
      {'field':('useragent_patch', 'ua__useragent_patch'), 'dtype': 'string'},
      {'field':('useragent_version', 'ua__useragent_version'), 'dtype': 'string'},
      {'field':('os_family', 'ua__os_family'), 'dtype': 'string'},
      {'field':('os_major', 'ua__os_major'), 'dtype': 'string'},
      {'field':('os_minor', 'ua__os_minor'), 'dtype': 'string'},
      {'field':('os_patch', 'ua__os_patch'), 'dtype': 'string'},
      {'field':('os_patch_minor', 'ua__os_patch_minor'), 'dtype': 'string'},
      {'field':('os_version', 'ua__os_version'), 'dtype': 'string'},
      {'field':('device_family', 'ua__device_family'), 'dtype': 'string'}
    ] %}

  {{ return(ua_fields) }}

{% endmacro %}

{% macro bq_yauaa_fields() %}

  {% set yauaa_fields = [
      {'field':('device_class', 'yauaa__device_class'), 'dtype': 'string'},
      {'field':('agent_class', 'yauaa__agent_class'), 'dtype': 'string'},
      {'field':('agent_name', 'yauaa__agent_name'), 'dtype': 'string'},
      {'field':('agent_name_version', 'yauaa__agent_name_version'), 'dtype': 'string'},
      {'field':('agent_name_version_major', 'yauaa__agent_name_version_major'), 'dtype': 'string'},
      {'field':('agent_version', 'yauaa__agent_version'), 'dtype': 'string'},
      {'field':('agent_version_major', 'yauaa__agent_version_major'), 'dtype': 'string'},
      {'field':('device_brand', 'yauaa__device_brand'), 'dtype': 'string'},
      {'field':('device_name', 'yauaa__device_name'), 'dtype': 'string'},
      {'field':('device_version', 'yauaa__device_version'), 'dtype': 'string'},
      {'field':('layout_engine_class', 'yauaa__layout_engine_class'), 'dtype': 'string'},
      {'field':('layout_engine_name', 'yauaa__layout_engine_name'), 'dtype': 'string'},
      {'field':('layout_engine_name_version', 'yauaa__layout_engine_name_version'), 'dtype': 'string'},
      {'field':('layout_engine_name_version_major', 'yauaa__layout_engine_name_version_major'), 'dtype': 'string'},
      {'field':('layout_engine_version', 'yauaa__layout_engine_version'), 'dtype': 'string'},
      {'field':('layout_engine_version_major', 'yauaa__layout_engine_version_major'), 'dtype': 'string'},
      {'field':('operating_system_class', 'yauaa__operating_system_class'), 'dtype': 'string'},
      {'field':('operating_system_name', 'yauaa__operating_system_name'), 'dtype': 'string'},
      {'field':('operating_system_name_version', 'yauaa__operating_system_name_version'), 'dtype': 'string'},
      {'field':('operating_system_version', 'yauaa__operating_system_version'), 'dtype': 'string'}
    ] %}

  {{ return(yauaa_fields) }}

{% endmacro %}

{% macro bq_consent_fields() %}

  {% set consent_fields = [
      {'field':'event_type', 'dtype': 'string'},
      {'field':'basis_for_processing', 'dtype': 'string'},
      {'field':'consent_url', 'dtype': 'string'},
      {'field':'consent_version', 'dtype': 'string'},
      {'field':'consent_scopes', 'dtype': 'string'},
      {'field':'domains_applied', 'dtype': 'string'},
      {'field':'gdpr_applies', 'dtype': 'string'}
    ] %}

  {{ return(consent_fields) }}

{% endmacro %}

{% macro bq_screen_context_fields() %}

  {% set screen_context_fields = [
      {'field':('id', 'screen__id'), 'dtype':'string'},
      {'field':('name', 'screen__name'), 'dtype':'string'},
      {'field':('activity', 'screen__activity'), 'dtype':'string'},
      {'field':('fragment', 'screen__fragment'), 'dtype':'string'},
      {'field':('top_view_controller', 'screen__top_view_controller'), 'dtype':'string'},
      {'field':('type', 'screen__type'), 'dtype':'string'},
      {'field':('view_controller', 'screen__view_controller'), 'dtype':'string'}
    ] %}

  {{ return(screen_context_fields) }}

{% endmacro %}

{% macro bq_mobile_context_fields() %}

  {% set mobile_context_fields = [
    {'field':('device_manufacturer', 'mobile__device_manufacturer'), 'dtype':'string'},
    {'field':('device_model', 'mobile__device_model'), 'dtype':'string'},
    {'field':('os_type', 'mobile__os_type'), 'dtype':'string'},
    {'field':('os_version', 'mobile__os_version'), 'dtype':'string'},
    {'field':('android_idfa', 'mobile__android_idfa'), 'dtype':'string'},
    {'field':('apple_idfa', 'mobile__apple_idfa'), 'dtype':'string'},
    {'field':('apple_idfv', 'mobile__apple_idfv'), 'dtype':'string'},
    {'field':('carrier', 'mobile__carrier'), 'dtype':'string'},
    {'field':('open_idfa', 'mobile__open_idfa'), 'dtype':'string'},
    {'field':('network_technology', 'mobile__network_technology'), 'dtype':'string'},
    {'field':('network_type', 'mobile__network_type'), 'dtype':'string'},
    {'field':('physical_memory', 'mobile__physical_memory'), 'dtype':'string'},
    {'field':('system_available_memory', 'mobile__system_available_memory'), 'dtype':'string'},
    {'field':('app_available_memory', 'mobile__app_available_memory'), 'dtype':'string'},
    {'field':('battery_level', 'mobile__battery_level'), 'dtype':'string'},
    {'field':('battery_state', 'mobile__battery_state'), 'dtype':'string'},
    {'field':('low_power_mode', 'mobile__low_power_mode'), 'dtype':'string'},
    {'field':('available_storage', 'mobile__available_storage'), 'dtype':'string'},
    {'field':('total_storage', 'mobile__total_storage'), 'dtype':'string'},
    {'field':('is_portrait', 'mobile__is_portrait'), 'dtype':'string'},
    {'field':('resolution', 'mobile__resolution'), 'dtype':'string'},
    {'field':('scale', 'mobile__scale'), 'dtype':'string'},
    {'field':('language', 'mobile__language'), 'dtype':'string'},
    {'field':('app_set_id', 'mobile__app_set_id'), 'dtype':'string'},
    {'field':('app_set_id_scope', 'mobile__app_set_id_scope'), 'dtype':'string'}
    ] %}

  {{ return(mobile_context_fields) }}

{% endmacro %}

{% macro bq_app_error_context_fields() %}

  {% set app_error_context_fields = [
    {'field':('message', 'app_error__message'), 'dtype':'string'},
    {'field':('programming_language', 'app_error__programming_language'), 'dtype':'string'},
    {'field':('class_name', 'app_error__class_name'), 'dtype':'string'},
    {'field':('exception_name', 'app_error__exception_name'), 'dtype':'string'},
    {'field':('file_name', 'app_error__file_name'), 'dtype':'string'},
    {'field':('is_fatal', 'app_error__is_fatal'), 'dtype':'boolean'},
    {'field':('line_column', 'app_error__line_column'), 'dtype':'integer'},
    {'field':('line_number', 'app_error__line_number'), 'dtype':'integer'},
    {'field':('stack_trace', 'app_error__stack_trace'), 'dtype':'string'},
    {'field':('thread_id', 'app_error__thread_id'), 'dtype':'integer'},
    {'field':('thread_name', 'app_error__thread_name'), 'dtype':'string'}
    ] %}

  {{ return(app_error_context_fields) }}

{% endmacro %}

{% macro bq_geo_context_fields() %}

  {% set geo_context_fields = [
    {'field':('latitude', 'geo__latitude'), 'dtype':'float64'},
    {'field':('longitude', 'geo__longitude'), 'dtype':'float64'},
    {'field':('latitude_longitude_accuracy', 'geo__latitude_longitude_accuracy'), 'dtype':'float64'},
    {'field':('altitude', 'geo__altitude'), 'dtype':'float64'},
    {'field':('altitude_accuracy', 'geo__altitude_accuracy'), 'dtype':'float64'},
    {'field':('bearing', 'geo__bearing'), 'dtype':'float64'},
    {'field':('speed', 'geo__speed'), 'dtype':'float64'}
    ] %}

  {{ return(geo_context_fields) }}

{% endmacro %}

{% macro bq_app_context_fields() %}

  {% set app_context_fields = [
    {'field':('build', 'app__build'), 'dtype':'string'},
    {'field':('version', 'app__version'), 'dtype':'string'}
    ] %}

  {{ return(app_context_fields) }}

{% endmacro %}

{% macro bq_session_context_fields() %}

  {% set session_context_fields = [
    {'field':('session_id', 'session__session_id'), 'dtype':'string'},
    {'field':('session_index', 'session__session_index'), 'dtype':'integer'},
    {'field':('previous_session_id', 'session__previous_session_id'), 'dtype':'string'},
    {'field':('user_id', 'session__user_id'), 'dtype':'string'},
    {'field':('first_event_id', 'session__first_event_id'), 'dtype':'string'}
    ] %}

  {{ return(session_context_fields) }}

{% endmacro %}

{% macro bq_screen_view_event_fields() %}

  {% set screen_view_event_fields = [
    {'field':('id', 'screen_view__id'), 'dtype':'string'},
    {'field':('name', 'screen_view__name'), 'dtype':'string'},
    {'field':('previous_id', 'screen_view__previous_id'), 'dtype':'string'},
    {'field':('previous_name', 'screen_view__previous_name'), 'dtype':'string'},
    {'field':('previous_type', 'screen_view__previous_type'), 'dtype':'string'},
    {'field':('transition_type', 'screen_view__transition_type'), 'dtype':'string'},
    {'field':('type', 'screen_view__type'), 'dtype':'string'}
    ] %}

  {{ return(screen_view_event_fields) }}

{% endmacro %}

{% macro bq_browser_context_fields() %}

  {% set browser_context_fields = [
    {'field':('viewport', 'browser__viewport'), 'dtype':'string'},
    {'field':('ocument_size', 'browser__document_size'), 'dtype':'string'},
    {'field':('resolution', 'browser__resolution'), 'dtype':'string'},
    {'field':('color_depth', 'browser__color_depth'), 'dtype':'string'},
    {'field':('device_pixel_ratio', 'browser__device_pixel_ratio'), 'dtype':'string'},
    {'field':('cookies_enabled', 'browser__cookies_enabled'), 'dtype':'string'},
    {'field':('online', 'browser__online'), 'dtype':'string'},
    {'field':('browser_language', 'browser__browser_language'), 'dtype':'string'},
    {'field':('document_language', 'browser__document_language'), 'dtype':'string'},
    {'field':('webdriver', 'browser__webdriver'), 'dtype':'string'},
    {'field':('device_memory', 'browser__device_memory'), 'dtype':'string'},
    {'field':('hardware_concurrency', 'browser__hardware_concurrency'), 'dtype':'string'},
    {'field':('tab_id', 'browser__tab_id'), 'dtype':'string'}
    ] %}

  {{ return(browser_context_fields) }}

{% endmacro %}

{% macro bq_deep_link_context_fields() %}

  {% set deep_link_context_fields = [
    {'field':('url', 'deep_link__url'), 'dtype':'string'},
    {'field':('referrer', 'deep_link__referrer'), 'dtype':'string'}
    ] %}

  {{ return(deep_link_context_fields) }}

{% endmacro %}

{% macro bq_web_page_fields() %}

  {% set web_page_fields = [
    {'field':('id', 'page_view__id'), 'dtype':'string'},
    ] %}

  {{ return(web_page_fields) }}

{% endmacro %}
