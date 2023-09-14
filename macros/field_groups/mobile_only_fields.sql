{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro mobile_only_fields(table_prefix = none) %}
  {{ return(adapter.dispatch('mobile_only_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro default__mobile_only_fields(table_prefix = none) %}

  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__previous_session_id
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__name
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__previous_id
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__previous_name
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__previous_type
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__transition_type
  , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_view__type

{% endmacro %}
