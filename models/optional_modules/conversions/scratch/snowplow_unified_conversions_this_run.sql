{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
  config(
    tags=["this_run"],
    enabled=var("snowplow__enable_conversions", false),
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

with prep as (
  
 {%- for conv_def in var('snowplow__conversion_events', []) %}
 
    {{ snowplow_unified.get_conversion_fields(conv_def)}}
    {% if not loop.last %}union all{% endif %}
    
 {%- endfor %}
 
)

select * from prep
