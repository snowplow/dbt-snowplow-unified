{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_conversion_fields(conv_def = []) %}
  {{ return(adapter.dispatch('get_conversion_fields', 'snowplow_unified')(conv_def)) }}
{% endmacro %}

{% macro default__get_conversion_fields(conv_def) %}

  select
    {{ dbt_utils.generate_surrogate_key(['event_id', "'" ~ conv_def['name'] ~ "'"])}} as cv_id,
    event_id,
    session_identifier,
    user_identifier,
    user_id,
    
    {% if var('snowplow__conversion_stitching') %}
      -- updated with mapping as part of post hook on derived conversions table
      cast(user_identifier as {{ snowplow_utils.type_max_string() }}) as stitched_user_id,
    {% endif %}
    
    {%- if conv_def.get('value', none) %}
      coalesce({{ conv_def['value'] }},{{ conv_def.get('default_value', 0) }}) as cv_value,
    {% else %}
      0 as cv_value,
    {% endif %}
    
    derived_tstamp as cv_tstamp,
    dvce_created_tstamp,
    '{{ conv_def['name'] }}' as cv_type
    
    {%- if var('snowplow__conversion_passthroughs', []) -%}
      {%- for identifier in var('snowplow__conversion_passthroughs', []) %}
        {# Check if it is a simple column or a sql+alias #}
        {%- if identifier is mapping -%}
            ,{{identifier['sql']}} as {{identifier['alias']}}
        {%- else -%}
            ,ev.{{identifier}}
        {%- endif -%}
      {% endfor -%}
    {%- endif %}
        
  from {{ ref('snowplow_unified_events_this_run') }} as ev
  
  where {{ conv_def['condition'] }}
  
  {% if var("snowplow__ua_bot_filter", true) %}
      {{ snowplow_unified.filter_bots() }}
  {% endif %}


{% endmacro %}
