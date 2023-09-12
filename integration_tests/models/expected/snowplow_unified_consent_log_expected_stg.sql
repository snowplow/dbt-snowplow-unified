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
  cast(view_id as {{ dbt.type_string() }}) as view_id,
  session_identifier,
  cast(derived_tstamp as {{ dbt.type_timestamp() }}) as derived_tstamp,
  cast(load_tstamp as {{ dbt.type_timestamp() }}) as load_tstamp,
  event_name,
  event_type,
  basis_for_processing,
  consent_url,
  replace(cast(consent_version as {{ dbt.type_string() }}), '.0', '') ||'.0' as consent_version,
  consent_scopes,
  domains_applied,
  gdpr_applies,
  cmp_load_time

from {{ ref('snowplow_unified_consent_log_expected') }}
