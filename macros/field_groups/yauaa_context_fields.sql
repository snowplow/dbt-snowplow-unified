{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro yauaa_context_fields(table_prefix = none, column_prefix = none) %}
    {{ return(adapter.dispatch('yauaa_context_fields', 'snowplow_unified')(table_prefix, column_prefix)) }}
{%- endmacro -%}

{% macro default__yauaa_context_fields(table_prefix = none, column_prefix = none) %}

    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__device_class{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__device_class {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__agent_class{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__agent_class {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__agent_name{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__agent_name {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__agent_name_version{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__agent_name_version {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__agent_name_version_major{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__agent_name_version_major {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__agent_version{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__agent_version {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__agent_version_major{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__agent_version_major {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__device_brand{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__device_brand {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__device_name{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__device_name {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__device_version{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__device_version {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__layout_engine_class{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__layout_engine_class {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__layout_engine_name{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__layout_engine_name {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__layout_engine_name_version{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__layout_engine_name_version {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__layout_engine_name_version_major{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__layout_engine_name_version_major {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__layout_engine_version{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__layout_engine_version {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__layout_engine_version_major{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__layout_engine_version_major {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__operating_system_class{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__operating_system_class {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__operating_system_name{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__operating_system_name {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__operating_system_name_version{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__operating_system_name_version {% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}yauaa__operating_system_version{% if column_prefix %} as {{ column_prefix~"_" }}yauaa__operating_system_version {% endif %}

{% endmacro %}
