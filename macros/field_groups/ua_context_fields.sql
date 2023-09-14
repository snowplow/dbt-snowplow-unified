{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro ua_context_fields(table_prefix = none) %}
  {{ return(adapter.dispatch('ua_context_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro default__ua_context_fields(table_prefix = none) %}

      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__useragent_family
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__useragent_major
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__useragent_minor
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__useragent_patch
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__useragent_version
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__os_family
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__os_major
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__os_minor
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__os_patch
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__os_patch_minor
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__os_version
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}ua__device_family

{% endmacro %}
