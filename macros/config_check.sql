{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro config_check() %}
  {{ return(adapter.dispatch('config_check', 'snowplow_unified')()) }}
{% endmacro %}

{% macro default__config_check() %}

  {% if not var('snowplow__enable_web') and not var('snowplow__enable_mobile') %}
    {{ exceptions.raise_compiler_error(
      "Snowplow Error: No platform to process. Please set at least one of the variables `snowplow__enable_web` or `snowplow__enable_mobile` to true."
    ) }}
  {% endif %}

  {% if not var('snowplow__enable_web') %}
    {% if var('snowplow__enable_iab') %}
      {{ exceptions.raise_compiler_error(
      "Snowplow Error: Iab context is enabled but it cannot be processed as `snowplow__enable_web` is currently disabled."
      ) }}
    {% elif var('snowplow__enable_ua') %}
      {{ exceptions.raise_compiler_error(
      "Snowplow Error: Ua context is enabled but it cannot be processed as `snowplow__enable_web` is currently disabled."
      ) }}
    {% elif var('snowplow__enable_browser_context') or var('snowplow__enable_browser_context_2') %}
      {{ exceptions.raise_compiler_error(
      "Snowplow Error: Browser context is enabled but it cannot be processed as `snowplow__enable_web` is currently disabled."
      ) }}
    {% elif var('snowplow__enable_consent')  %}
      {{ exceptions.raise_compiler_error(
      "Snowplow Error: Consent module enabled but it cannot be processed as `snowplow__enable_web` is currently disabled."
      ) }}
    {% elif var('snowplow__enable_cwv') %}
      {{ exceptions.raise_compiler_error(
      "Snowplow Error: Core web vitals module is enabled but it cannot be processed as `snowplow__enable_web` is currently disabled."
      ) }}
    {% endif %}
  {% endif %}

  {% if not var('snowplow__enable_mobile') %}
    {% if var('snowplow__enable_mobile_context') %}
      {{ exceptions.raise_compiler_error(
      "Snowplow Error: Mobile context is enabled but it cannot be processed as `snowplow__enable_mobile` is currently disabled."
      ) }}
    {% elif var('snowplow__enable_geolocation_context')%}
      {{ exceptions.raise_compiler_error(
      "Snowplow Error: Geolocation context is enabled but it cannot be processed as `snowplow__enable_mobile` is currently disabled."
      ) }}
    {% elif var('snowplow__enable_application_context') %}
      {{ exceptions.raise_compiler_error(
      "Snowplow Error: App context is enabled but it cannot be processed as `snowplow__enable_mobile` is currently disabled."
      ) }}
    {% elif var('snowplow__enable_screen_context') %}
      {{ exceptions.raise_compiler_error(
      "Snowplow Error: Screen context is enabled but it cannot be processed as `snowplow__enable_mobile` is currently disabled."
      ) }}
    {% elif  var('snowplow__enable_app_errors') %}
      {{ exceptions.raise_compiler_error(
      "Snowplow Error: App error events are enabled but it cannot be processed as `snowplow__enable_mobile` is currently disabled."
      ) }}
    {% elif var('snowplow__enable_deep_link_context') %}
      {{ exceptions.raise_compiler_error(
      "Snowplow Error: Deep link context is enabled but it cannot be processed as `snowplow__enable_mobile` is currently disabled."
      ) }}
    {% elif var('snowplow__enable_screen_summary_context') %}
      {{ exceptions.raise_compiler_error(
      "Snowplow Error: Screen summary context is enabled but it cannot be processed as `snowplow__enable_mobile` is currently disabled."
      ) }}
    {% endif %}
  {% endif %}
  
  {% if var('snowplow__enable_conversions') and not var('snowplow__conversion_events') %}
   {{ exceptions.raise_compiler_error(
      "Snowplow Error: var('snowplow__conversion_events') is not configured but the conversions optional module is enabled. Please configure this variable before proceeding."
      ) }}
    {% endif %}

{% endmacro %}
