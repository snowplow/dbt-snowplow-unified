{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro mobile_context_fields(table_prefix = none, column_prefix = none) %}
    {{ return(adapter.dispatch('mobile_context_fields', 'snowplow_unified')(table_prefix, column_prefix)) }}
{%- endmacro -%}

{% macro default__mobile_context_fields(table_prefix = none, column_prefix = none) %}

    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__device_manufacturer{% if column_prefix %} as {{ column_prefix~"_" }}mobile__device_manufacturer{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__device_model{% if column_prefix %} as {{ column_prefix~"_" }}mobile__device_model{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__os_type{% if column_prefix %} as {{ column_prefix~"_" }}mobile__os_type{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__os_version{% if column_prefix %} as {{ column_prefix~"_" }}mobile__os_version{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__android_idfa{% if column_prefix %} as {{ column_prefix~"_" }}mobile__android_idfa{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__apple_idfa{% if column_prefix %} as {{ column_prefix~"_" }}mobile__apple_idfa{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__apple_idfv{% if column_prefix %} as {{ column_prefix~"_" }}mobile__apple_idfv{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__carrier{% if column_prefix %} as {{ column_prefix~"_" }}mobile__carrier{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__open_idfa{% if column_prefix %} as {{ column_prefix~"_" }}mobile__open_idfa{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__network_technology{% if column_prefix %} as {{ column_prefix~"_" }}mobile__network_technology{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__network_type{% if column_prefix %} as {{ column_prefix~"_" }}mobile__network_type{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__physical_memory{% if column_prefix %} as {{ column_prefix~"_" }}mobile__physical_memory{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__system_available_memory{% if column_prefix %} as {{ column_prefix~"_" }}mobile__system_available_memory{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__app_available_memory{% if column_prefix %} as {{ column_prefix~"_" }}mobile__app_available_memory{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__battery_level{% if column_prefix %} as {{ column_prefix~"_" }}mobile__battery_level{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__battery_state{% if column_prefix %} as {{ column_prefix~"_" }}mobile__battery_state{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__low_power_mode{% if column_prefix %} as {{ column_prefix~"_" }}mobile__low_power_mode{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__available_storage{% if column_prefix %} as {{ column_prefix~"_" }}mobile__available_storage{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__total_storage{% if column_prefix %} as {{ column_prefix~"_" }}mobile__total_storage{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__is_portrait{% if column_prefix %} as {{ column_prefix~"_" }}mobile__is_portrait{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__resolution{% if column_prefix %} as {{ column_prefix~"_" }}mobile__resolution{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__scale{% if column_prefix %} as {{ column_prefix~"_" }}mobile__scale{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__language{% if column_prefix %} as {{ column_prefix~"_" }}mobile__language{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__app_set_id{% if column_prefix %} as {{ column_prefix~"_" }}mobile__app_set_id{% endif %}
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__app_set_id_scope{% if column_prefix %} as {{ column_prefix~"_" }}mobile__app_set_id_scope{% endif %}

{% endmacro %}
