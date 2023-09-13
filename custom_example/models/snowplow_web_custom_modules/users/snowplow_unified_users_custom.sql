{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    materialized='incremental',
    unique_key='user_primary_key',
    upsert_date_key='start_tstamp',
    sort='start_tstamp',
    dist='user_primary_key',
    partition_by = snowplow_utils.get_value_by_target_type(bigquery_val = {
      "field": "start_tstamp",
      "data_type": "timestamp"
    }, databricks_val='start_tstamp_date'),
    cluster_by=snowplow_unified.unified_cluster_by_fields_users(),
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt')),
    snowplow_optimize=true
  )
}}


select distinct
  {{ dbt.concat(["u.user_identifier", "'-'", "s.user_ipaddress"]) }} as user_primary_key,
  u.*
  {% if target.type in ['databricks', 'spark'] -%}
  , DATE(start_tstamp) as start_tstamp_date
  {%- endif %}

from {{ ref('snowplow_unified_users_this_run') }} u -- join sessions_this_run to sessions_conversion_this_run to produce complete sessions table
left join {{ ref('snowplow_unified_sessions')}} s on u.user_identifier = s.user_identifier
where {{ snowplow_utils.is_run_with_new_events('snowplow_unified') }} --returns false if run doesn't contain new events.
