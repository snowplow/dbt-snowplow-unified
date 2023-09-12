{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}


{{
  config(
    enabled=var("snowplow__enable_consent", false)
    )
}}

select

  event_id,
  user_identifier,
  user_id,
  geo_country,
  view_id,
  session_identifier,
  derived_tstamp,
  load_tstamp,
  event_name,
  event_type,
  basis_for_processing,
  consent_url,
  consent_version,
  case when consent_scopes = '' then null else consent_scopes end as consent_scopes,
  case when domains_applied = '' then null else domains_applied end as domains_applied,
  gdpr_applies,
  cmp_load_time

from {{ ref('snowplow_unified_consent_log') }}
