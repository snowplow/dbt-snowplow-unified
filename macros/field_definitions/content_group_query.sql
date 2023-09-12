{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro content_group_query() %}
  {{ return(adapter.dispatch('content_group_query', 'snowplow_unified')()) }}
{% endmacro %}


{% macro default__content_group_query() %}
  case when ev.page_url like '%/product%' then 'PDP'
      when ev.page_url like '%/list%' then 'PLP'
      when ev.page_url like '%/checkout%' then 'checkout'
      when ev.page_url like '%/home%' then 'homepage'
      else 'other'
  end

{% endmacro %}
