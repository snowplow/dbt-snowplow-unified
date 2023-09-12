{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{{
    config(
        tags=["this_run"],
        sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
    )
}}

with session_firsts as (
    select
        {{ platform_independent_fields('ev') }}
        , session_identifier

        {% if var('snowplow__enable_web') %}
          {{ web_only_fields('ev') }}
        {% endif %}

        {% if var('snowplow__enable_mobile') %}
          {{ mobile_only_fields('ev') }}
        {% endif %}

        {% if var('snowplow__session_stitching') %}
          -- updated with mapping as part of post hook on derived sessions table
          , cast(user_identifier as {{ snowplow_utils.type_max_string() }}) as stitched_user_id
        {% else %}
          , cast(null as {{ snowplow_utils.type_max_string() }}) as stitched_user_id
        {% endif %}

        {% if var('snowplow__enable_iab') %}
          {{ iab_context_fields('ev') }}
        {% endif %}

        {% if var('snowplow__enable_yauaa') %}
          {{ yauaa_context_fields('ev') }}
        {% endif %}

        {% if var('snowplow__enable_ua') %}
          {{ ua_context_fields('ev') }}
        {% endif %}

        {% if var('snowplow__enable_application_context') %}
          {{ app_context_fields('ev') }}
        {% endif %}

        {% if var('snowplow__enable_geolocation_context') %}
          {{ geo_context_fields('ev') }}
        {% endif %}

        , g.name as geo_country_name
        , g.region as geo_continent
        , l.name as br_lang_name

        {% if var('snowplow__enable_screen_context') %}
          {{ screen_context_fields('ev') }}
        {% endif %}

        {% if var('snowplow__enable_mobile_context') %}
          {{ mobile_context_fields('ev')}}
        {% endif %}

        {% if target.type == 'postgres' %}
          , row_number() over (partition by ev.session_identifier order by ev.derived_tstamp, ev.dvce_created_tstamp, ev.event_id) as session_dedupe_index
        {% endif %}

        , {{ mkt_source_platform_query() }} as mkt_source_platform

        {%- if var('snowplow__session_passthroughs', []) -%}
            {%- set passthrough_names = [] -%}
            {%- for identifier in var('snowplow__session_passthroughs', []) %}
            {# Check if it is a simple column or a sql+alias #}
            {%- if identifier is mapping -%}
                ,{{identifier['sql']}} as {{identifier['alias']}}
                {%- do passthrough_names.append(identifier['alias']) -%}
            {%- else -%}
                ,ev.{{identifier}}
                {%- do passthrough_names.append(identifier) -%}
            {%- endif -%}
            {% endfor -%}
        {%- endif %}

    from {{ ref('snowplow_unified_events_this_run') }} ev
    left join
        {{ ref(var('snowplow__ga4_categories_seed')) }} c on lower(trim(ev.mkt_source)) = lower(c.source)
    left join
        {{ ref(var('snowplow__rfc_5646_seed')) }} l on lower(ev.br_lang) = lower(l.lang_tag)
    left join
        {{ ref(var('snowplow__geo_mapping_seed')) }} g on lower(ev.geo_country) = lower(g.alpha_2)
    where event_name in ('page_ping', 'page_view', 'screen_view')
    and view_id is not null

    {% if var("snowplow__ua_bot_filter", true) %}
      {{ filter_bots() }}
    {% endif %}

    {% if target.type not in ['postgres'] %}
      qualify row_number() over (partition by session_identifier order by derived_tstamp, dvce_created_tstamp, event_id) = 1
    {% endif %}
)

, session_lasts as (
    select

      ev.event_name as last_event_name,
      ev.geo_country as last_geo_country,
      ev.geo_city as last_geo_city,
      ev.geo_region_name as last_geo_region_name,
      g.name as last_geo_country_name,
      g.region as last_geo_continent,
      ev.page_url as last_page_url,

      {% if var('snowplow__enable_web') %}
        ev.page_title as last_page_title,
        ev.page_urlscheme as last_page_urlscheme,
        ev.page_urlhost as last_page_urlhost,
        ev.page_urlpath as last_page_urlpath,
        ev.page_urlquery as last_page_urlquery,
        ev.page_urlfragment as last_page_urlfragment,
        br_lang as last_br_lang,
        l.name as last_br_lang_name,
      {% endif %}

      {% if var('snowplow__enable_mobile') %}
        ev.screen_view__name as last_screen_view__name,
        ev.screen_view__transition_type as last_screen_view__transition_type,
        ev.screen_view__type as last_screen_view__type,
      {% endif %}

      {% if target.type == 'postgres' %}
        row_number() over (partition by ev.session_identifier order by ev.derived_tstamp desc, ev.dvce_created_tstamp desc, ev.event_id) AS session_dedupe_index,
      {% endif %}

      session_identifier

    from {{ ref('snowplow_unified_events_this_run') }} ev
    left join
        {{ ref(var('snowplow__rfc_5646_seed')) }} l on lower(ev.br_lang) = lower(l.lang_tag)
    left join
        {{ ref(var('snowplow__geo_mapping_seed')) }} g on lower(ev.geo_country) = lower(g.alpha_2)
    where
        event_name in ('page_view', 'screen_view')
        and view_id is not null
        {% if var("snowplow__ua_bot_filter", true) %}
            {{ filter_bots() }}
        {% endif %}

    {% if target.type not in ['postgres'] %}
      qualify row_number() over (partition by session_identifier order by derived_tstamp desc, dvce_created_tstamp desc, event_id) = 1
    {% endif %}
)

, session_aggs as (
    select
      session_identifier
      , min(derived_tstamp) as start_tstamp
      , max(derived_tstamp) as end_tstamp
      , count(*) as total_events
      , count(distinct view_id) as views

      {%- if var('snowplow__list_event_counts', false) %}
          , {{ event_counts_string_query() }} as event_counts_string
      {%- endif %}

      {% if var('snowplow__enable_web') %}

            -- (hb * (#page pings - # distinct page view ids ON page pings)) + (# distinct page view ids ON page pings * min visit length)
        , ({{ var("snowplow__heartbeat", 10) }} * (
              -- number of (unqiue in heartbeat increment) pages pings following a page ping (gap of heartbeat)
              count(distinct case when event_name = 'page_ping' and view_id is not null then
                          -- need to get a unique list of floored time PER page view, so create a dummy surrogate key...
                          {{ dbt.concat(['view_id', "cast(floor("~snowplow_utils.to_unixtstamp('dvce_created_tstamp')~"/"~var('snowplow__heartbeat', 10)~") as "~dbt.type_string()~")" ]) }}
                      else null end) - count(distinct case when event_name = 'page_ping' and view_id is not null then view_id else null end)
                            ))  +
                            -- number of page pings following a page view (or no event) (gap of min visit length)
                            (count(distinct case when event_name = 'page_ping' and view_id is not null then view_id else null end) * {{ var("snowplow__min_visit_length", 5) }}) as engaged_time_in_s
        , {{ snowplow_utils.timestamp_diff('min(derived_tstamp)', 'max(derived_tstamp)', 'second') }} as absolute_time_in_s
      {% endif %}

      {% if var("snowplow__enable_app_errors", false) %}
        , count(distinct case when event_name = 'application_error' then 1 end) as app_errors
        , count(distinct case when app_error__is_fatal then event_id end) as fatal_app_errors
      {% endif %}

      {% if var('snowplow__enable_mobile') %}
        , count(distinct screen_view__name) as screen_names_viewed
      {% endif %}

    from {{ ref('snowplow_unified_events_this_run') }}
    where 1 = 1

    {% if var("snowplow__ua_bot_filter", true) %}
        {{ filter_bots() }}
    {% endif %}

    group by session_identifier
)

-- Redshift does not allow listagg and other aggregations in the same CTE
{%- if var('snowplow__conversion_events', none) %}
,session_convs as (
    select
        session_identifier
        {%- for conv_def in var('snowplow__conversion_events') %}
            {{ snowplow_unified.get_conversion_columns(conv_def)}}
        {%- endfor %}
    from {{ ref('snowplow_unified_events_this_run') }}
    where
        1 = 1
        {% if var("snowplow__ua_bot_filter", true) %}
            {{ filter_bots() }}
        {% endif %}
    group by
        session_identifier
)
{%- endif %}

select

  -- event categorization fields
  f.event_name as first_event_name
  , l.last_event_name
  , f.session_identifier
  {% if var('snowplow__enable_mobile') %}
    , f.session__previous_session_id
  {% endif %}

  -- user id fields
  , f.user_id
  , f.user_identifier
  , f.stitched_user_id
  , f.network_userid

  -- timestamp fields
  -- when the session starts with a ping we need to add the min visit length to get when the session actually started
  , case when f.event_name = 'page_ping' then {{ snowplow_utils.timestamp_add(datepart="second", interval=-var("snowplow__min_visit_length", 5), tstamp="a.start_tstamp") }} else a.start_tstamp end as start_tstamp
  , a.end_tstamp -- only page views with pings will have a row in table t
  , {{ snowplow_utils.current_timestamp_in_utc() }} as model_tstamp

  -- device fields
  , f.app_id
  , f.platform
  , f.device_identifier
  , f.device_category
  , f.device_session_index
  , f.os_version
  , f.os_type

  {% if var('snowplow__enable_web') %}
    , f.os_timezone
  {% endif %}

  , f.screen_resolution

  {% if var('snowplow__enable_yauaa') %}
    , f.yauaa__device_class
    , f.yauaa__device_version
    , f.yauaa__operating_system_version
    , f.yauaa__operating_system_class
    , f.yauaa__operating_system_name
    , f.yauaa__operating_system_name_version
  {% endif %}

  {% if var('snowplow__enable_mobile_context') %}
    {{ mobile_context_fields('f')}}
  {% endif %}

  -- geo fields
  , f.geo_country as first_geo_country
  , f.geo_region_name as first_geo_region_name
  , f.geo_city as first_geo_city
  , f.geo_country_name as first_geo_country_name
  , f.geo_continent as first_geo_continent

  , case when l.last_geo_country is null then coalesce(l.last_geo_country, f.geo_country) else l.last_geo_country end as last_geo_country
  , case when l.last_geo_country is null then coalesce(l.last_geo_region_name, f.geo_region_name) else l.last_geo_region_name end as last_geo_region_name
  , case when l.last_geo_country is null then coalesce(l.last_geo_city, f.geo_city) else l.last_geo_city end as last_geo_city
  , case when l.last_geo_country is null then coalesce(l.last_geo_country_name,f.geo_country_name) else l.last_geo_country_name end as last_geo_country_name
  , case when l.last_geo_country is null then coalesce(l.last_geo_continent, f.geo_continent) else l.last_geo_continent end as last_geo_continent

  , f.geo_zipcode
  , f.geo_latitude
  , f.geo_longitude
  , f.geo_timezone
  , f.user_ipaddress

  -- engagement fields
  , a.views
  {%- if var('snowplow__list_event_counts', false) %}
    , {{ event_counts_query() }} as event_counts
  {%- endif %}
  , a.total_events
  , {{ engaged_session() }} as is_engaged
  -- when the session starts with a ping we need to add the min visit length to get when the session actually started

  {% if var('snowplow__enable_web') %}
    , a.engaged_time_in_s
    , a.absolute_time_in_s + case when f.event_name = 'page_ping' then {{ var("snowplow__min_visit_length", 5) }} else 0 end as absolute_time_in_s
  {%- endif %}

  {% if var('snowplow__enable_mobile') %}
    , {{ snowplow_utils.timestamp_diff('a.start_tstamp', 'a.end_tstamp', 'second') }} as session_duration_s
    , a.screen_names_viewed
  {%- endif %}

  -- marketing fields
  , f.mkt_medium
  , f.mkt_source
  , f.mkt_term
  , f.mkt_content
  , f.mkt_campaign
  , f.mkt_clickid
  , f.mkt_network
  , f.default_channel_group
  , mkt_source_platform

  -- webpage / referrer / browser fields
  , f.page_url as first_page_url
  , case when l.last_page_url is null then coalesce(l.last_page_url, f.page_url) else l.last_page_url end as last_page_url
  , f.page_referrer
  , f.refr_medium
  , f.refr_source
  , f.refr_term

  {% if var('snowplow__enable_web') %}
    , f.page_title as first_page_title
    , f.page_urlscheme as first_page_urlscheme
    , f.page_urlhost as first_page_urlhost
    , f.page_urlpath as first_page_urlpath
    , f.page_urlquery as first_page_urlquery
    , f.page_urlfragment as first_page_urlfragment
    -- only take the first value when the last is genuinely missing (base on url as has to always be populated)
    , case when l.last_page_url is null then coalesce(l.last_page_title, f.page_title) else l.last_page_title end as last_page_title
    , case when l.last_page_url is null then coalesce(l.last_page_urlscheme, f.page_urlscheme) else l.last_page_urlscheme end as last_page_urlscheme
    , case when l.last_page_url is null then coalesce(l.last_page_urlhost, f.page_urlhost) else l.last_page_urlhost end as last_page_urlhost
    , case when l.last_page_url is null then coalesce(l.last_page_urlpath, f.page_urlpath) else l.last_page_urlpath end as last_page_urlpath
    , case when l.last_page_url is null then coalesce(l.last_page_urlquery, f.page_urlquery) else l.last_page_urlquery end as last_page_urlquery
    , case when l.last_page_url is null then coalesce(l.last_page_urlfragment, f.page_urlfragment) else l.last_page_urlfragment end as last_page_urlfragment
    , f.refr_urlscheme
    , f.refr_urlhost
    , f.refr_urlpath
    , f.refr_urlquery
    , f.refr_urlfragment
    , f.br_renderengine
    , f.br_lang as first_br_lang
    , f.br_lang_name as first_br_lang_name
    , case when l.last_br_lang is null then coalesce(l.last_br_lang, f.br_lang) else l.last_br_lang end as last_br_lang
    , case when l.last_br_lang is null then coalesce(l.last_br_lang_name, f.br_lang_name) else l.last_br_lang_name end as last_br_lang_name
  {% endif %}

  -- iab enrichment fields
  {% if var('snowplow__enable_iab') %}
    , f.iab__category
    , f.iab__primary_impact
    , f.iab__reason
    , f.iab__spider_or_robot
  {% endif %}

  -- yauaa enrichment fields
  {% if var('snowplow__enable_yauaa') %}
    , f.yauaa__device_name
    , f.yauaa__agent_class
    , f.yauaa__agent_name
    , f.yauaa__agent_name_version
    , f.yauaa__agent_name_version_major
    , f.yauaa__agent_version
    , f.yauaa__agent_version_major
    , f.yauaa__layout_engine_class
    , f.yauaa__layout_engine_name
    , f.yauaa__layout_engine_name_version
    , f.yauaa__layout_engine_name_version_major
    , f.yauaa__layout_engine_version
    , f.yauaa__layout_engine_version_major
  {% endif %}

  -- ua parser enrichment fields
  {% if var('snowplow__enable_ua') %}
    , f.ua__device_family
    , f.ua__os_version
    , f.ua__os_major
    , f.ua__os_minor
    , f.ua__os_patch
    , f.ua__os_patch_minor
    , f.ua__useragent_family
    , f.ua__useragent_major
    , f.ua__useragent_minor
    , f.ua__useragent_patch
    , f.ua__useragent_version
  {% endif %}

  -- mobile only
  {% if var('snowplow__enable_mobile') %}
    , f.screen_view__name as first_screen_view__name
    , f.screen_view__type as first_screen_view__type
    , case when l.last_screen_view__name is null then coalesce(l.last_screen_view__name, f.screen_view__name) else l.last_screen_view__name end as last_screen_view__name
    , case when l.last_screen_view__transition_type is null then coalesce(l.last_screen_view__transition_type, f.screen_view__transition_type) else l.last_screen_view__transition_type end as last_screen_view__transition_type
    , case when l.last_screen_view__type is null then coalesce(l.last_screen_view__type, f.screen_view__type) else l.last_screen_view__type end as last_screen_view__type
    , f.screen_view__previous_id
    , f.screen_view__previous_name
    , f.screen_view__previous_type

  {% endif %}

  {% if var('snowplow__enable_application_context') %}
    , f.app__build as first_app__build
    , f.app__version as first_app__version
  {% endif %}

  {% if var('snowplow__enable_geolocation_context') %}
    , f.geo__altitude as first_geo__altitude
    , f.geo__altitude_accuracy as first_geo__altitude_accuracy
    , f.geo__bearing as first_geo__bearing
    , f.geo__latitude as first_geo__latitude
    , f.geo__latitude_longitude_accuracy as first_geo__latitude_longitude_accuracy
    , f.geo__longitude as first_geo__longitude
    , f.geo__speed as first_geo__speed
  {% endif %}

  {% if var('snowplow__enable_screen_context') %}
    , f.screen__fragment
    , f.screen__top_view_controller
    , f.screen__view_controller
  {% endif %}

  {% if var("snowplow__enable_app_errors", false) %}
    , a.app_errors
    , a.fatal_app_errors
  {% endif %}

  , f.useragent

  -- conversion fields
  {%- if var('snowplow__conversion_events', none) %}
    {%- for conv_def in var('snowplow__conversion_events') %}
      {{ snowplow_unified.get_conversion_columns(conv_def, names_only = true)}}
    {%- endfor %}
    {% if var('snowplow__total_all_conversions', false) %}
      ,{%- for conv_def in var('snowplow__conversion_events') %}{{'cv_' ~ conv_def['name'] ~ '_volume'}}{%- if not loop.last %} + {% endif -%}{%- endfor %} as cv__all_volume
      {# Use 0 in case of no conversions having a value field #}
      ,0 {%- for conv_def in var('snowplow__conversion_events') %}{%- if conv_def.get('value') %} + {{'cv_' ~ conv_def['name'] ~ '_total'}}{% endif -%}{%- endfor %} as cv__all_total
    {% endif %}
  {%- endif %}

  -- passthrough fields
  {%- if var('snowplow__session_passthroughs', []) -%}
      {%- for col in passthrough_names %}
          , f.{{col}}
      {%- endfor -%}
  {%- endif %}

from session_firsts f

left join session_lasts l
on f.session_identifier = l.session_identifier

{% if target.type == 'postgres' %}
  and l.session_dedupe_index = 1
{%- endif %}

left join session_aggs a
on f.session_identifier = a.session_identifier

{%- if var('snowplow__conversion_events', none) %}
left join session_convs d on f.session_identifier = d.session_identifier
{%- endif %}

{% if target.type == 'postgres' %}
   where f.session_dedupe_index = 1
{%- endif %}
