{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro session_context_fields(table_prefix = none) %}
  {{ return(adapter.dispatch('session_context_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro default__session_context_fields(table_prefix = none) %}

    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__session_id
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__session_index
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__previous_session_id
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__user_id
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__first_event_id
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__event_index
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__storage_mechanism
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session__first_event_timestamp

{% endmacro %}
