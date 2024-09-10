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

  {% if var('snowplow__enable_browser_context', false) and not var('snowplow__enable_browser_context_2', false) %}
    {% do contexts.append({'schema': var('snowplow__browser_context'), 'prefix': 'browser_', 'single_entity': True}) %}
  {% elif not var('snowplow__enable_browser_context', false) and var('snowplow__enable_browser_context_2', false) %}
    {% do contexts.append({'schema': var('snowplow__browser_context_2'), 'prefix': 'browser_', 'single_entity': True}) %}
  {% elif var('snowplow__enable_browser_context', false) and var('snowplow__enable_browser_context_2', false) %}
    {% do contexts.append({'schema': var('snowplow__browser_context'), 'prefix': 'browser1_', 'single_entity': True}) %}
    {% do contexts.append({'schema': var('snowplow__browser_context_2'), 'prefix': 'browser2_', 'single_entity': True}) %}
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

  {% if var('snowplow__enable_screen_summary_context', false) -%}
    {% do contexts.append({'schema': var('snowplow__screen_summary_context'), 'prefix': 'screen_summary_', 'single_entity': True}) %}
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
                              entities_or_sdes=contexts,
                              custom_sql=var('snowplow__custom_sql', none),
                              allow_null_dvce_tstamps=var('snowplow__allow_null_dvce_tstamps', false)
                              ) %}


with base_query as (
  {{ base_events_query }}
),

{# NOTE: This lakeloader workaround should be removed when Snowflake support structured types in regular tables https://docs.snowflake.com/en/sql-reference/data-types-structured #}

{% if var('snowplow__snowflake_lakeloader', false) -%}
  {% set base_query_cols = get_column_schema_from_query( 'select * from (' + base_events_query +') a') %}
{%- endif -%}

base_query_2 AS (
select
  {% if var('snowplow__snowflake_lakeloader', false) and target.type == 'snowflake' -%}
    {% for col in base_query_cols | map(attribute='name') | list -%}
      {% if col.startswith('CONTEXTS_')%}
        cast({{col}} as array) as {{col}}
      {% elif col.startswith('UNSTRUCT_')%}
        cast({{col}} as object) as {{col}}
      {%- else -%}
        {{col}}
      {%- endif -%}
      {%- if not loop.last -%},{%- endif %}
    {% endfor %}
  {% else %}
  *
  {%- endif -%}

  -- extract commonly used contexts / sdes (prefixed)
  {{ snowplow_unified.get_web_page_context_fields() }}
  {{ snowplow_unified.get_iab_context_fields() }}
  {{ snowplow_unified.get_ua_context_fields() }}
  {{ snowplow_unified.get_yauaa_context_fields() }}
  {{ snowplow_unified.get_browser_context_fields() }}
  {{ snowplow_unified.get_screen_view_event_fields() }}
  {{ snowplow_unified.get_session_context_fields() }}
  {{ snowplow_unified.get_mobile_context_fields() }}
  {{ snowplow_unified.get_geo_context_fields() }}
  {{ snowplow_unified.get_app_context_fields() }}
  {{ snowplow_unified.get_screen_context_fields() }}
  {{ snowplow_unified.get_deep_link_context_fields() }}
  {{ snowplow_unified.get_app_error_event_fields() }}
  {{ snowplow_unified.get_screen_summary_context_fields() }}

{% if var('snowplow__enable_consent', false) -%}
  {{ snowplow_unified.get_consent_event_fields() }}
  {{ snowplow_unified.get_cmp_visible_event_fields() }}
{% endif -%}

{% if var('snowplow__enable_cwv', false) -%}
  {{ snowplow_unified.get_cwv_fields() }}
{% endif -%}
from base_query
)

SELECT *
{% if target.type in ['bigquery','postgres', 'redshift'] and var('snowplow__enable_browser_context', false) and var('snowplow__enable_browser_context_2', false) %}

  , coalesce(browser1__viewport, browser2__viewport) AS browser__viewport
  , coalesce(browser1__document_size, browser2__document_size ) AS browser__document_size
  , coalesce(browser1__resolution, browser2__resolution) AS browser__resolution
  , coalesce(browser1__color_depth, browser2__color_depth) AS browser__color_depth
  , coalesce(browser1__device_pixel_ratio, browser2__device_pixel_ratio) AS browser__device_pixel_ratio
  , coalesce(browser1__cookies_enabled, browser2__cookies_enabled) AS browser__cookies_enabled
  , coalesce(browser1__online, browser2__online) AS browser__online
  , coalesce(browser1__browser_language, browser2__browser_language) AS browser__browser_language
  , coalesce(browser1__document_language, browser2__document_language) AS browser__document_language
  , coalesce(browser1__webdriver, browser2__webdriver) AS browser__webdriver
  , coalesce(browser1__device_memory, browser2__device_memory) AS browser__device_memory
  , coalesce(browser1__hardware_concurrency, browser2__hardware_concurrency) AS browser__hardware_concurrency
  , coalesce(browser1__tab_id, browser2__tab_id) AS browser__tab_id

{% endif -%}
FROM base_query_2