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


select
  a.*,
  min(a.start_tstamp) over(partition by a.user_identifier) as user_start_tstamp,
  max(a.end_tstamp) over(partition by a.user_identifier) as user_end_tstamp,
  
{% if target.type in ['redshift', 'postgres'] %}
  max(cast(case when platform = 'web' then true else false end as {{ dbt.type_int() }})) over(partition by user_identifier) as on_web,
  max(cast(case when platform <> 'web' then true else false end as {{ dbt.type_int() }})) over(partition by user_identifier) as on_mobile

{% else %}
  max(case when platform = 'web' then true else false end) over(partition by user_identifier) as on_web,
  max(case when platform <> 'web' then true else false end) over(partition by user_identifier) as on_mobile
{% endif %}

from {{ var('snowplow__sessions_table') }} a
where exists (select 1 from {{ ref('snowplow_unified_base_sessions_this_run') }} b where a.user_identifier = b.user_identifier)
