{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
  config(
    tags=["this_run"],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

with prep as (
  select
    a.*,
    case when platform = 'web' then true else false end on_web_base,
    case when platform = 'mob' then true else false end on_mobile_base,
    min(a.start_tstamp) over(partition by a.user_identifier) as user_start_tstamp,
    max(a.end_tstamp) over(partition by a.user_identifier) as user_end_tstamp

  from {{ var('snowplow__sessions_table') }} a
  where exists (select 1 from {{ ref('snowplow_unified_base_sessions_this_run') }} b where a.user_identifier = b.user_identifier)

)

select *,
  cast(max(cast(on_web_base as {{ type_int() }}))  over(partition by user_identifier) as {{ type_boolean() }}) as on_web,
  cast(max(cast(on_mobile_base as {{ type_int() }})) over(partition by user_identifier) as {{ type_boolean() }}) as on_mobile

from prep
