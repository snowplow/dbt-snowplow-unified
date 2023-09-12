{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro ua_context_fields(table_prefix = none, column_prefix = none) %}
  {{ return(adapter.dispatch('ua_context_fields', 'snowplow_unified')(table_prefix, column_prefix)) }}
{%- endmacro -%}

{% macro default__ua_context_fields(table_prefix = none, column_prefix = none) %}

      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__useragent_family{% if column_prefix %} as {{ column_prefix~"_" }}ua__useragent_family {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__useragent_major{% if column_prefix %} as {{ column_prefix~"_" }}ua__useragent_major {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__useragent_minor{% if column_prefix %} as {{ column_prefix~"_" }}ua__useragent_minor {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__useragent_patch{% if column_prefix %} as {{ column_prefix~"_" }}ua__useragent_patch {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__useragent_version{% if column_prefix %} as {{ column_prefix~"_" }}ua__useragent_version {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__os_family{% if column_prefix %} as {{ column_prefix~"_" }}ua__os_family {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__os_major{% if column_prefix %} as {{ column_prefix~"_" }}ua__os_major {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__os_minor{% if column_prefix %} as {{ column_prefix~"_" }}ua__os_minor {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__os_patch{% if column_prefix %} as {{ column_prefix~"_" }}ua__os_patch {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__os_patch_minor{% if column_prefix %} as {{ column_prefix~"_" }}ua__os_patch_minor {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__os_version{% if column_prefix %} as {{ column_prefix~"_" }}ua__os_version {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__device_family{% if column_prefix %} as {{ column_prefix~"_" }}ua__device_family {% endif %}

{% endmacro %}
