{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro web_only_fields(table_prefix = none, column_prefix = none) %}
  {{ return(adapter.dispatch('web_only_fields', 'snowplow_unified')(table_prefix, column_prefix)) }}
{%- endmacro -%}

{% macro default__web_only_fields(table_prefix = none, column_prefix = none) %}

      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}br_lang{% if column_prefix %} as {{ column_prefix~"_" }}br_lang {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}br_viewwidth{% if column_prefix %} as {{ column_prefix~"_" }}br_viewwidth {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}br_viewheight{% if column_prefix %} as {{ column_prefix~"_" }}br_viewheight {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}br_renderengine{% if column_prefix %} as {{ column_prefix~"_" }}br_renderengine {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}doc_width{% if column_prefix %} as {{ column_prefix~"_" }}doc_width {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}doc_height{% if column_prefix %} as {{ column_prefix~"_" }}doc_height {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}page_title{% if column_prefix %} as {{ column_prefix~"_" }}page_title {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}page_urlscheme{% if column_prefix %} as {{ column_prefix~"_" }}page_urlscheme {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}page_urlhost{% if column_prefix %} as {{ column_prefix~"_" }}page_urlhost {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}page_urlpath{% if column_prefix %} as {{ column_prefix~"_" }}page_urlpath {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}page_urlquery{% if column_prefix %} as {{ column_prefix~"_" }}page_urlquery {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}page_urlfragment{% if column_prefix %} as {{ column_prefix~"_" }}page_urlfragment{% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}refr_urlscheme{% if column_prefix %} as {{ column_prefix~"_" }}refr_urlscheme {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}refr_urlhost{% if column_prefix %} as {{ column_prefix~"_" }}refr_urlhost {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}refr_urlpath{% if column_prefix %} as {{ column_prefix~"_" }}refr_urlpath {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}refr_urlquery{% if column_prefix %} as {{ column_prefix~"_" }}refr_urlquery {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}refr_urlfragment{% if column_prefix %} as {{ column_prefix~"_" }}refr_urlfragment {% endif %}
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}os_timezone{% if column_prefix %} as {{ column_prefix~"_" }}os_timezone {% endif %}

{% endmacro %}
