{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
  config(
    materialized='incremental',
    enabled=var("snowplow__enable_conversions", false),
    on_schema_change='append_new_columns',
    unique_key='cv_id',
    upsert_date_key='cv_tstamp',
    sort='cv_tstamp',
    dist='cv_id',
    partition_by = snowplow_utils.get_value_by_target_type(bigquery_val = {
      "field": "cv_tstamp",
      "data_type": "timestamp"
    }, databricks_val='cv_tstamp_date'),
    cluster_by=snowplow_unified.get_cluster_by_values('conversions'),
    tags=["derived"],
    post_hook="{{ snowplow_unified.stitch_user_identifiers(
      enabled=var('snowplow__conversion_stitching')
      ) }}",
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt')),
    tblproperties={
      'delta.autoOptimize.optimizeWrite' : 'true',
      'delta.autoOptimize.autoCompact' : 'true'
    },
    snowplow_optimize = true
  )
}}


select *
  {% if target.type in ['databricks', 'spark'] -%}
  , DATE(cv_tstamp) as cv_tstamp_date
  {%- endif %}
from {{ ref('snowplow_unified_conversions_this_run') }}
where {{ snowplow_utils.is_run_with_new_events('snowplow_unified') }} --returns false if run doesn't contain new events.
