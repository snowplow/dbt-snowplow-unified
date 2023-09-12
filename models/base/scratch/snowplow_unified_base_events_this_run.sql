{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
  config(
    sort='collector_tstamp',
    dist='event_id',
    tags=["this_run"]
  )
}}

{# Setting sdes or contexts for Postgres / Redshift. Dbt passes variables by reference so need to use copy to avoid altering the list multiple times #}
{% set contexts = var('snowplow__entities_or_sdes', []).copy() %}

{% if var('snowplow__enable_web') %}

  {% do contexts.append({'schema': var('snowplow__page_view_context'), 'prefix': 'page_view_', 'single_entity': True}) %}

  {% if var('snowplow__enable_iab', false) -%}
    {% do contexts.append({'schema': var('snowplow__iab_context'), 'prefix': 'iab_', 'single_entity': True}) %}
  {% endif -%}

  {% if var('snowplow__enable_ua', false) -%}
    {% do contexts.append({'schema': var('snowplow__ua_parser_context'), 'prefix': 'ua_', 'single_entity': True}) %}
  {% endif -%}

  {% if var('snowplow__enable_consent', false) -%}
    {% do contexts.append({'schema': var('snowplow__cmp_visible_events'), 'prefix': 'cmp_', 'single_entity': True}) %}
    {% do contexts.append({'schema': var('snowplow__consent_preferences_events'), 'prefix': 'consent_', 'single_entity': True}) %}
  {% endif -%}

  {% if var('snowplow__enable_cwv', false) -%}
    {% do contexts.append({'schema': var('snowplow__cwv_events'), 'prefix': 'cwv_', 'single_entity': True}) %}
  {% endif -%}

  {% if var('snowplow__enable_browser_context', false) -%}
    {% do contexts.append({'schema': var('snowplow__browser_context'), 'prefix': 'browser_', 'single_entity': True}) %}
  {% endif -%}

{% endif -%}

{% if var('snowplow__enable_mobile') %}

  {% do contexts.append({'schema': var('snowplow__screen_view_events'), 'prefix': 'screen_view_', 'single_entity': True}) %}
  {% do contexts.append({'schema': var('snowplow__session_context'), 'prefix': 'session_', 'single_entity': True}) %}

  {% if var('snowplow__enable_mobile_context', false) -%}
    {% do contexts.append({'schema': var('snowplow__mobile_context'), 'prefix': 'mobile_', 'single_entity': True}) %}
  {% endif -%}

  {% if var('snowplow__enable_geolocation_context', false) -%}
    {% do contexts.append({'schema': var('snowplow__geolocation_context'), 'prefix': 'geo_', 'single_entity': True}) %}
  {% endif -%}

  {% if var('snowplow__enable_application_context', false) -%}
    {% do contexts.append({'schema': var('snowplow__application_context'), 'prefix': 'app_', 'single_entity': True}) %}
  {% endif -%}

  {% if var('snowplow__enable_screen_context', false) -%}
    {% do contexts.append({'schema': var('snowplow__screen_context'), 'prefix': 'screen_', 'single_entity': True}) %}
  {% endif -%}

  {% if var('snowplow__enable_app_errors', false) -%}
    {% do contexts.append({'schema': var('snowplow__application_error_events'), 'prefix': 'app_error_', 'single_entity': True}) %}
  {% endif -%}

  {% if var('snowplow__enable_deep_link_context', false) -%}
    {% do contexts.append({'schema': var('snowplow__deep_link_context'), 'prefix': 'deep_link_', 'single_entity': True}) %}
  {% endif -%}

{% endif -%}

{% if var('snowplow__enable_yauaa', false) -%}
  {% do contexts.append({'schema': var('snowplow__yauaa_context'), 'prefix': 'yauaa_', 'single_entity': True}) %}
{% endif -%}

{% set base_events_query = snowplow_utils.base_create_snowplow_events_this_run(
                              sessions_this_run_table='snowplow_unified_base_sessions_this_run',
                              session_identifiers= session_identifiers(),
                              session_sql=var('snowplow__session_sql', none),
                              session_timestamp=var('snowplow__session_timestamp', 'collector_tstamp'),
                              derived_tstamp_partitioned=var('snowplow__derived_tstamp_partitioned', true),
                              days_late_allowed=var('snowplow__days_late_allowed', 3),
                              max_session_days=var('snowplow__max_session_days', 3),
                              app_ids=var('snowplow__app_id', []),
                              snowplow_events_database=var('snowplow__database', target.database) if target.type not in ['databricks', 'spark'] else var('snowplow__databricks_catalog', 'hive_metastore') if target.type in ['databricks'] else var('snowplow__atomic_schema', 'atomic'),
                              snowplow_events_schema=var('snowplow__atomic_schema', 'atomic'),
                              snowplow_events_table=var('snowplow__events_table', 'events'),
                              entities_or_sdes=contexts
                              ) %}


with base_query as (
  {{ base_events_query }}
)

select
  *
  -- extract commonly used contexts / sdes (prefixed)
  {{ get_web_page_context_fields() }}
  {{ get_iab_context_fields() }}
  {{ get_ua_context_fields() }}
  {{ get_yauaa_context_fields() }}
  {{ get_browser_context_fields() }}
  {{ get_screen_view_event_fields() }}
  {{ get_session_context_fields() }}
  {{ get_mobile_context_fields() }}
  {{ get_geo_context_fields() }}
  {{ get_app_context_fields() }}
  {{ get_screen_context_fields() }}
  {{ get_deep_link_context_fields() }}
  {{ get_app_error_event_fields() }}


{% if var('snowplow__enable_consent', false) -%}
  {{ get_consent_event_fields() }}
  {{ get_cmp_visible_event_fields() }}
{% endif -%}

{% if var('snowplow__enable_cwv', false) -%}
  {{ get_cwv_fields() }}
{% endif -%}
from base_query


