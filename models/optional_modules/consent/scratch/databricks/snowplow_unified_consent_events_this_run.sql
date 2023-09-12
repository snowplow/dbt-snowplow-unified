{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    tags=["this_run"],
    enabled=var("snowplow__enable_consent", false) and target.type in ['databricks', 'spark'] | as_bool(),
  )
}}

with prep as (

  select
    e.event_id,
    e.user_identifier,
    e.user_id,
    e.geo_country,
    e.view_id,
    e.session_identifier,
    e.derived_tstamp,
    e.load_tstamp,
    e.event_name,
    e.unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1.event_type::STRING as event_type,
    e.unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1.basis_for_processing::STRING as basis_for_processing,
    e.unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1.consent_url::STRING as consent_url,
    e.unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1.consent_version::STRING as consent_version,
    e.unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1.consent_scopes::ARRAY<STRING> as consent_scopes,
    e.unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1.domains_applied::ARRAY<STRING> as domains_applied,
    e.unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1.gdpr_applies::boolean as gdpr_applies,
    e.unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1.elapsed_time::float as cmp_load_time

  from {{ ref("snowplow_unified_events_this_run") }} as e

  where event_name in ('cmp_visible', 'consent_preferences')

  and {{ snowplow_utils.is_run_with_new_events('snowplow_unified') }} --returns false if run doesn't contain new events.

  {% if var("snowplow__ua_bot_filter", false) %}
      {{ filter_bots() }}
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
  coalesce(p.gdpr_applies, false) as gdpr_applies,
  p.cmp_load_time

from prep p
