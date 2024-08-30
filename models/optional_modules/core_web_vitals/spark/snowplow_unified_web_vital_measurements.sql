{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
  config(
    materialized='table',
    enabled=var("snowplow__enable_cwv", false) and target.type in ('spark') | as_bool()
  )
}}

WITH measurements AS (
  SELECT
    page_url,
    device_class,
    geo_country,
    cast( {{ dbt.date_trunc('day', 'derived_tstamp') }} as {{ dbt.type_string() }}) as time_period,
    COUNT(*) AS view_count,
    GROUPING_ID() AS grouping_ids,
    PERCENTILE(lcp, 0.{{var('snowplow__cwv_percentile')}}) AS lcp_{{var('snowplow__cwv_percentile')}}p,
    PERCENTILE(fid, 0.{{var('snowplow__cwv_percentile')}}) AS fid_{{var('snowplow__cwv_percentile')}}p,
    PERCENTILE(cls, 0.{{var('snowplow__cwv_percentile')}})  AS cls_{{var('snowplow__cwv_percentile')}}p,
    PERCENTILE(ttfb, 0.{{var('snowplow__cwv_percentile')}})  AS ttfb_{{var('snowplow__cwv_percentile')}}p,
    PERCENTILE(inp, 0.{{var('snowplow__cwv_percentile')}})  AS inp_{{var('snowplow__cwv_percentile')}}p
  FROM {{ref('snowplow_unified_web_vitals')}}
  where cast(derived_tstamp as date) >= {{ dbt.dateadd('day', '-'+var('snowplow__cwv_days_to_measure')|string, dbt.date_trunc('day', snowplow_utils.current_timestamp_in_utc())) }}
  group by cube(page_url, device_class,cast( {{ dbt.date_trunc('day', 'derived_tstamp') }} as {{ dbt.type_string() }}), geo_country)

),

measurement_type AS (
  SELECT
    *,
    CASE 
      WHEN grouping_ids = 15 THEN 'overall'
      WHEN grouping_ids = 3 THEN 'by_url_and_device'
      WHEN grouping_ids = 9 THEN 'by_day_and_device'
      WHEN grouping_ids = 10 THEN 'by_country_and_device'
      WHEN grouping_ids = 14 THEN 'by_country'
      WHEN grouping_ids = 11 THEN 'by_device'
      WHEN grouping_ids = 13 THEN 'by_day'
    END AS measurement_type,
    {{ snowplow_unified.core_web_vital_results_query('_' + var('snowplow__cwv_percentile') | string + 'p') }}
  FROM measurements
),

coalesce AS (
  SELECT
    m.measurement_type,
    COALESCE(m.page_url, 'all') AS page_url,
    COALESCE(m.device_class, 'all') AS device_class,
    COALESCE(m.geo_country, 'all') AS geo_country,
    COALESCE(g.name, 'all') AS country,
    COALESCE(m.time_period, 'last {{var("snowplow__cwv_days_to_measure")}} days') AS time_period,
    m.view_count,
    CAST(ceil(m.lcp_{{ var('snowplow__cwv_percentile') }}p, 3) AS DECIMAL(24,3)) as lcp_{{ var('snowplow__cwv_percentile') }}p,
    CAST(ceil(m.fid_{{ var('snowplow__cwv_percentile') }}p, 3) AS DECIMAL(24,3)) as fid_{{ var('snowplow__cwv_percentile') }}p,
    CAST(ceil(m.cls_{{ var('snowplow__cwv_percentile') }}p, 3) AS DECIMAL(24,3)) as cls_{{ var('snowplow__cwv_percentile') }}p,
    CAST(ceil(m.ttfb_{{ var('snowplow__cwv_percentile')}}p, 3) AS DECIMAL(24,3)) as ttfb_{{ var('snowplow__cwv_percentile') }}p,
    CAST(ceil(m.inp_{{ var('snowplow__cwv_percentile')}}p, 3) AS DECIMAL(24,3)) as inp_{{ var('snowplow__cwv_percentile') }}p,
    m.lcp_result,
    m.fid_result,
    m.cls_result,
    m.ttfb_result,
    m.inp_result,
    {{snowplow_unified.core_web_vital_pass_query()}} AS passed
  FROM measurement_type m
  LEFT JOIN {{ref(var('snowplow__geo_mapping_seed'))}} g ON LOWER(m.geo_country) = LOWER(g.alpha_2)
  WHERE measurement_type IS NOT NULL
  ORDER BY 1
)

select
  {{ dbt.concat(['page_url', "'-'" , 'device_class', "'-'" , 'geo_country', "'-'" , 'time_period' ]) }} compound_key,
  *
from coalesce