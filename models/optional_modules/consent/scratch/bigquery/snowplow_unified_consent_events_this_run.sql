{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
  config(
    tags=["this_run"],
    enabled=var("snowplow__enable_consent", false) and target.type == 'bigquery' | as_bool(),
  )
}}

with prep as (

  select
    e.event_id
    , e.user_identifier
    , e.user_id
    , e.geo_country
    , e.view_id
    , e.session_identifier
    , e.derived_tstamp
    , e.load_tstamp
    , e.event_name
    , e.consent__event_type as event_type
    , e.consent__basis_for_processing as basis_for_processing
    , e.consent__consent_url as consent_url
    , e.consent__consent_version as consent_version
    , e.consent__consent_scopes as consent_scopes
    , e.consent__domains_applied as domains_applied
    , e.consent__gdpr_applies as gdpr_applies
    , e.cmp__elapsed_time as cmp_load_time

    from {{ ref("snowplow_unified_events_this_run") }} as e

    where e.event_name in ('cmp_visible', 'consent_preferences')

    and {{ snowplow_utils.is_run_with_new_events('snowplow_unified') }} --returns false if run doesn't contain new events.

    {% if var("snowplow__ua_bot_filter", false) %}
        {{ snowplow_unified.filter_bots() }}
    {% endif %}
)

select
  p.event_id,
  p.user_identifier,
  p.user_id,
  p.geo_country,
  p.view_id,
  p.session_identifier,
  p.derived_tstamp,
  p.load_tstamp,
  p.event_name,
  p.event_type,
  p.basis_for_processing,
  p.consent_url,
  p.consent_version,
  {{ snowplow_utils.get_array_to_string('consent_scopes', 'p', ', ') }} as consent_scopes,
  {{ snowplow_utils.get_array_to_string('domains_applied', 'p', ', ') }} as domains_applied,
  coalesce(safe_cast(p.gdpr_applies as boolean), false) gdpr_applies,
  cast(p.cmp_load_time as {{ dbt.type_float() }}) as cmp_load_time

  from prep p
