{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}


select
  root_id,
  root_tstamp::timestamp as root_tstamp,
  basis_for_processing,
  consent_version,
  {#- Simulates a table created by an RDB Loader version that stores array properties as SUPER rather than as JSON text in a VARCHAR -#}
  {% if var('snowplow__test_super_columns', false) and target.type == 'redshift' %}
  json_parse(consent_scopes) as consent_scopes,
  json_parse(domains_applied) as domains_applied,
  {% else %}
  consent_scopes,
  domains_applied,
  {% endif %}
  consent_url,
  event_type,
  gdpr_applies::boolean as gdpr_applies,
  'consent_preferences' as schema_name

from {{ ref('snowplow_unified_consent_preferences') }}
