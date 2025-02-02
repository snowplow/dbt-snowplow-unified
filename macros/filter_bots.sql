{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro filter_bots(table_alias = none) %}
  {{ return(adapter.dispatch('filter_bots', 'snowplow_unified')(table_alias)) }}
{%- endmacro -%}

{% macro default__filter_bots(table_alias = none) %}
  {% if var('snowplow__enable_iab', false) %}
    {# additional logic in case the result is null due to server anonymization #}
    and coalesce(iab__spider_or_robot, False ) = False
  {% endif %}
  and {% if table_alias %}{{table_alias~'.'}}{% endif %}useragent not similar to '%(bot|crawl|slurp|spider|archiv|spinn|sniff|seo|audit|survey|pingdom|worm|capture|(browser|screen)shots|analyz|index|thumb|check|facebook|PingdomBot|PhantomJS|YandexBot|Twitterbot|a_archiver|facebookexternalhit|Bingbot|BingPreview|Googlebot|Baiduspider|360(Spider|User-agent)|semalt)%'
{% endmacro %}

{% macro bigquery__filter_bots(table_alias = none) %}
  {% if var('snowplow__enable_iab', false) %}
    and coalesce(iab__spider_or_robot, False ) = False
  {% endif %}
  and not regexp_contains({% if table_alias %}{{table_alias~'.'}}{% endif %}useragent, '(bot|crawl|slurp|spider|archiv|spinn|sniff|seo|audit|survey|pingdom|worm|capture|(browser|screen)shots|analyz|index|thumb|check|facebook|PingdomBot|PhantomJS|YandexBot|Twitterbot|a_archiver|facebookexternalhit|Bingbot|BingPreview|Googlebot|Baiduspider|360(Spider|User-agent)|semalt)')
{% endmacro %}

{% macro spark__filter_bots(table_alias = none) %}
  {% if var('snowplow__enable_iab', false) %}
   {# had to add different syntax as the coalesce based one resulted in a Spark error #}
    and (not iab__spider_or_robot = True or iab__spider_or_robot is null)
  {% endif %}
  and not rlike({% if table_alias %}{{table_alias~'.'}}{% endif %}useragent, '.*(bot|crawl|slurp|spider|archiv|spinn|sniff|seo|audit|survey|pingdom|worm|capture|(browser|screen)shots|analyz|index|thumb|check|facebook|PingdomBot|PhantomJS|YandexBot|Twitterbot|a_archiver|facebookexternalhit|Bingbot|BingPreview|Googlebot|Baiduspider|360(Spider|User-agent)|semalt).*')
{% endmacro %}

{% macro snowflake__filter_bots(table_alias = none) %}
  {% if var('snowplow__enable_iab', false) %}
    and coalesce(iab__spider_or_robot, False ) = False
  {% endif %}
  and not rlike({% if table_alias %}{{table_alias~'.'}}{% endif %}useragent, '.*(bot|crawl|slurp|spider|archiv|spinn|sniff|seo|audit|survey|pingdom|worm|capture|(browser|screen)shots|analyz|index|thumb|check|facebook|PingdomBot|PhantomJS|YandexBot|Twitterbot|a_archiver|facebookexternalhit|Bingbot|BingPreview|Googlebot|Baiduspider|360(Spider|User-agent)|semalt).*')
{% endmacro %}
