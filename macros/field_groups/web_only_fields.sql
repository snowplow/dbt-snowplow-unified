{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro web_only_fields(table_prefix = none) %}
  {{ return(adapter.dispatch('web_only_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro default__web_only_fields(table_prefix = none) %}

      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}br_lang
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}br_viewwidth
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}br_viewheight
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}br_renderengine
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}doc_width
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}doc_height
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}page_title
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}page_urlscheme
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}page_urlhost
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}page_urlpath
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}page_urlquery
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}page_urlfragment
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}refr_urlscheme
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}refr_urlhost
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}refr_urlpath
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}refr_urlquery
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}refr_urlfragment
      , {% if table_prefix %}{{ table_prefix~"." }}{% endif %}os_timezone

{% endmacro %}
