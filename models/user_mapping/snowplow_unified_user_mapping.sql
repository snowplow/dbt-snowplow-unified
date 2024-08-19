{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
  config(
    materialized='incremental',
    unique_key='user_identifier',
    sort='end_tstamp',
    dist='user_identifier',
    partition_by = snowplow_utils.get_value_by_target_type(bigquery_val={
      "field": "end_tstamp",
      "data_type": "timestamp"
    }),
    tags=["derived"],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}


select distinct
  user_identifier,
  last_value({{ var('snowplow__user_stitching_id', 'user_id') }}) over(
    partition by user_identifier
    order by collector_tstamp
    rows between unbounded preceding and unbounded following
  ) as user_id,
  max(collector_tstamp) over (partition by user_identifier) as end_tstamp

from {{ ref('snowplow_unified_events_this_run') }}

where {{ snowplow_utils.is_run_with_new_events('snowplow_unified') }} --returns false if run doesn't contain new events.
and {{ var('snowplow__user_stitching_id', 'user_id') }} is not null
and user_identifier is not null
