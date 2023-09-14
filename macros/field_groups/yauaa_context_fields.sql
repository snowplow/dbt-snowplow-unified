{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro yauaa_context_fields(table_prefix = none) %}
    {{ return(adapter.dispatch('yauaa_context_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro default__yauaa_context_fields(table_prefix = none) %}

    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__device_class
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__agent_class
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__agent_name
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__agent_name_version
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__agent_name_version_major
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__agent_version
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__agent_version_major
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__device_brand
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__device_name
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__device_version
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__layout_engine_class
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__layout_engine_name
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__layout_engine_name_version
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__layout_engine_name_version_major
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__layout_engine_version
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__layout_engine_version_major
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__operating_system_class
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__operating_system_name
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__operating_system_name_version
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__operating_system_version

{% endmacro %}
