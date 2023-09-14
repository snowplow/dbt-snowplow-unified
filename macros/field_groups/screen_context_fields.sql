{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro screen_context_fields(table_prefix = none) %}
  {{ return(adapter.dispatch('screen_context_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro default__screen_context_fields(table_prefix = none) %}

      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen__id
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen__name
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen__activity
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen__fragment
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen__top_view_controller
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen__type
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen__view_controller

{% endmacro %}
