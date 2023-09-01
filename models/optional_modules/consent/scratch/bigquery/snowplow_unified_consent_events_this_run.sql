{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    tags=["this_run"],
    enabled=var("snowplow__enable_consent", false) and target.type == 'bigquery' | as_bool(),
  )
}}

with prep as (

  select
    e.event_id,
    e.domain_userid,
    e.original_domain_userid,
    e.user_id,
    e.geo_country,
    e.view_id,
    e.domain_sessionid,
    e.original_domain_sessionid,
    e.derived_tstamp,
    e.load_tstamp,
    e.event_name,
    {{ snowplow_utils.get_optional_fields(
        enabled= true,
        fields=consent_fields(),
        col_prefix='unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1',
        relation=ref('snowplow_unified_base_events_this_run'),
        relation_alias='e') }},
    {{ snowplow_utils.get_optional_fields(
        enabled= true,
        fields=[{'field': 'elapsed_time', 'dtype': 'string'}],
        col_prefix='unstruct_event_com_snowplowanalytics_snowplow_cmp_visible_1',
        relation=ref('snowplow_unified_base_events_this_run'),
        relation_alias='e') }}

    from {{ ref("snowplow_unified_base_events_this_run") }} as e

    where e.event_name in ('cmp_visible', 'consent_preferences')

    and {{ snowplow_utils.is_run_with_new_events('snowplow_unified') }} --returns false if run doesn't contain new events.

    {% if var("snowplow__ua_bot_filter", false) %}
        {{ filter_bots() }}
    {% endif %}
)

select
  p.event_id,
  p.domain_userid,
  p.original_domain_userid,
  p.user_id,
  p.geo_country,
  p.view_id,
  p.domain_sessionid,
  p.original_domain_sessionid,
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
  cast(p.elapsed_time as {{ dbt.type_float() }}) as cmp_load_time

  from prep p
