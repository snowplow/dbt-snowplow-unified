{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro mobile_context_fields(table_prefix = none) %}
    {{ return(adapter.dispatch('mobile_context_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro default__mobile_context_fields(table_prefix = none) %}

    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__device_manufacturer
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__device_model
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__os_type
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__os_version
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__android_idfa
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__apple_idfa
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__apple_idfv
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__carrier
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__open_idfa
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__network_technology
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__network_type
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__physical_memory
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__system_available_memory
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__app_available_memory
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__battery_level
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__battery_state
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__low_power_mode
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__available_storage
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__total_storage
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__is_portrait
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__resolution
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__scale
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__language
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__app_set_id
    , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mobile__app_set_id_scope

{% endmacro %}
