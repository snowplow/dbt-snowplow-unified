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
        {{ snowplow_unified.platform_independent_fields('ev') }}
        , session_identifier

        {% if var('snowplow__enable_web') %}
          {{ snowplow_unified.web_only_fields('ev') }}
        {% endif %}

        {% if var('snowplow__enable_mobile') %}
          {{ snowplow_unified.mobile_only_fields('ev') }}
        {% endif %}

        {% if var('snowplow__session_stitching') %}
          -- updated with mapping as part of post hook on derived sessions table
          , cast(user_identifier as {{ snowplow_utils.type_max_string() }}) as stitched_user_id
        {% else %}
          , cast(null as {{ snowplow_utils.type_max_string() }}) as stitched_user_id
        {% endif %}

        {% if var('snowplow__enable_iab') %}
          {{ snowplow_unified.iab_context_fields('ev') }}
        {% endif %}

        {% if var('snowplow__enable_yauaa') %}
          {{ snowplow_unified.yauaa_context_fields('ev') }}
        {% endif %}

        {% if var('snowplow__enable_ua') %}
          {{ snowplow_unified.ua_context_fields('ev') }}
        {% endif %}

        {% if var('snowplow__enable_application_context') %}
          {{ snowplow_unified.app_context_fields('ev') }}
        {% endif %}

        {% if var('snowplow__enable_geolocation_context') %}
          {{ snowplow_unified.geo_context_fields('ev') }}
        {% endif %}

        , g.name as geo_country_name
        , g.region as geo_continent
        , l.name as br_lang_name

        {% if var('snowplow__enable_screen_context') %}
          {{ snowplow_unified.screen_context_fields('ev') }}
        {% endif %}

        {% if var('snowplow__enable_mobile_context') %}
          {{ snowplow_unified.mobile_context_fields('ev')}}
        {% endif %}

        {% if target.type in ['postgres','spark'] %}
          , row_number() over (partition by ev.session_identifier order by ev.derived_tstamp, ev.dvce_created_tstamp, ev.event_id) as session_dedupe_index
        {% endif %}

        , {{ snowplow_unified.mkt_source_platform_query() }} as mkt_source_platform

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
        {{ ref(var('snowplow__ga4_categories_seed')) }} c on 
        {% if var('snowplow__use_refr_if_mkt_null', false) %}
        lower(trim(coalesce(ev.mkt_source, ev.refr_source))) = lower(c.source)
        {% else %}
          lower(trim(ev.mkt_source)) = lower(c.source)
        {% endif %}
    left join
        {{ ref(var('snowplow__rfc_5646_seed')) }} l on lower(ev.br_lang) = lower(l.lang_tag)
    left join
        {{ ref(var('snowplow__geo_mapping_seed')) }} g on lower(ev.geo_country) = lower(g.alpha_2)
    where event_name in ('page_ping', 'page_view', 'screen_view')
    and view_id is not null

    {% if var("snowplow__ua_bot_filter", true) %}
      {{ snowplow_unified.filter_bots() }}
    {% endif %}

    {% if target.type not in ['postgres','spark'] %}
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

      {% if target.type in ['postgres','spark'] %}
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
            {{ snowplow_unified.filter_bots() }}
        {% endif %}

    {% if target.type not in ['postgres','spark'] %}
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
          , {{ snowplow_unified.event_counts_string_query() }} as event_counts_string
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
                            (count(distinct case when event_name = 'page_ping' and view_id is not null then view_id else null end) * {{ var("snowplow__min_visit_length", 5) }}) as engaged_time_in_s_web
      {% endif %}

      , {{ snowplow_utils.timestamp_diff('min(derived_tstamp)', 'max(derived_tstamp)', "second") }} as absolute_time_in_s

      {% if var("snowplow__enable_app_errors", false) %}
        , count(distinct case when event_name = 'application_error' then 1 end) as app_errors
        , count(distinct case when app_error__is_fatal then event_id end) as fatal_app_errors
      {% endif %}

      {% if var('snowplow__enable_mobile') %}
        , count(distinct screen_view__name) as screen_names_viewed
      {% endif %}

      {% if var('snowplow__session_aggregations', []) %}
        {% for agg in var('snowplow__session_aggregations') %}
          , {{ snowplow_utils.parse_agg_dict(agg)}}
        {% endfor %}
      {% endif %}

    from {{ ref('snowplow_unified_events_this_run') }}
    where 1 = 1

    {% if var("snowplow__ua_bot_filter", true) %}
        {{ snowplow_unified.filter_bots() }}
    {% endif %}

    group by session_identifier
)

, session_aggs_with_engaged_time as (
  {% if var('snowplow__enable_screen_summary_context', false) %}
    select a.*

      , coalesce(
        ss.foreground_sec,
        {% if var('snowplow__enable_web') %}a.engaged_time_in_s_web,{% endif %}
        null
      ) as engaged_time_in_s

    from session_aggs a

    left join {{ ref('snowplow_unified_session_screen_summary_metrics') }} ss
    on a.session_identifier = ss.session_identifier
  {% else %}
    select a.*

      {% if var('snowplow__enable_web') %}
      , a.engaged_time_in_s_web as engaged_time_in_s
      {% endif %}

    from session_aggs a
  {% endif %}
)

-- Redshift does not allow listagg and other aggregations in the same CTE
{%- if var('snowplow__conversion_events', none) %}
,session_convs as (
    select
        session_identifier
        {%- for conv_def in var('snowplow__conversion_events') %}
            {{ snowplow_unified.conversion_query(conv_def)}}
        {%- endfor %}
        {% if var('snowplow__enable_conversions', false) %}
          from {{ ref('snowplow_unified_conversions_this_run') }}
        {% else %}
          from {{ ref('snowplow_unified_events_this_run') }}
          where 1 = 1
          {% if var("snowplow__ua_bot_filter", true) %}
            {{ snowplow_unified.filter_bots() }}
          {% endif %}
        {% endif %}
        group by session_identifier
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


  {% if var('snowplow__enable_mobile_context')  %}
    {{ snowplow_unified.mobile_context_fields('f')}}
    , coalesce(iso_639_2t_2_char.name, iso_639_2t_3_char.name, iso_639_3.name, f.mobile__language) as mobile_language_name
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
    , {{ snowplow_unified.event_counts_query() }} as event_counts
  {%- endif %}
  , a.total_events
  , coalesce({{ snowplow_unified.engaged_session() }}, false) as is_engaged
  -- when the session starts with a ping we need to add the min visit length to get when the session actually started

  {% if var('snowplow__enable_web') or var('snowplow__enable_screen_summary_context', false) %}
    , a.engaged_time_in_s
  {%- endif %}

  , a.absolute_time_in_s + case when f.event_name = 'page_ping' then {{ var("snowplow__min_visit_length", 5) }} else 0 end as absolute_time_in_s

  {% if var('snowplow__enable_mobile') %}
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
    {{ snowplow_unified.iab_context_fields('f') }}
  {% endif %}

  -- yauaa enrichment fields
  {% if var('snowplow__enable_yauaa') %}
    {{ snowplow_unified.yauaa_context_fields('f') }}
  {% endif %}

  -- ua parser enrichment fields
  {% if var('snowplow__enable_ua') %}
    {{ snowplow_unified.ua_context_fields('f') }}
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
    {{ snowplow_unified.app_context_fields('f', 'first') }}
  {% endif %}

  {% if var('snowplow__enable_geolocation_context') %}
    {{ snowplow_unified.geo_context_fields('f', 'first') }}
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
      {{ snowplow_unified.conversion_query(conv_def, names_only = true)}}
    {%- endfor %}
    {% if var('snowplow__total_all_conversions', false) %}
      ,{%- for conv_def in var('snowplow__conversion_events') %} coalesce({{'cv_' ~ conv_def['name'] ~ '_volume'}},0) {%- if not loop.last %} + {% endif -%}{%- endfor %} as cv__all_volume
      {# Use 0 in case of no conversions having a value field #}
      ,0 {%- for conv_def in var('snowplow__conversion_events') %}{%- if conv_def.get('value') %} + coalesce({{'cv_' ~ conv_def['name'] ~ '_total'}}, 0){% endif -%}{%- endfor %} as cv__all_total
    {% endif %}
  {%- endif %}

  -- passthrough fields
  {%- if var('snowplow__session_passthroughs', []) -%}
      {%- for col in passthrough_names %}
          , f.{{col}}
      {%- endfor -%}
  {%- endif %}

  {% if var('snowplow__session_aggregations', []) %}
    {% for agg in var('snowplow__session_aggregations') %}
      , a.{{ agg.get('alias') }}
    {% endfor %}
  {% endif %}

from session_firsts f

left join session_lasts l
on f.session_identifier = l.session_identifier

{% if target.type in ['postgres','spark'] %}
  and l.session_dedupe_index = 1
{%- endif %}

left join session_aggs_with_engaged_time a
on f.session_identifier = a.session_identifier

{%- if var('snowplow__conversion_events', none) %}
left join session_convs d on f.session_identifier = d.session_identifier
{%- endif %}
{%- if var('snowplow__enable_mobile_context') %}

    -- if the language uses a two letter code we can match on that
  left join {{ ref(var('snowplow__iso_639_2t_seed')) }} iso_639_2t_2_char on lower(f.mobile__language) = lower(iso_639_2t_2_char.iso_639_1_code)
    -- if the language uses a three letter code we can match on that
  left join {{ ref(var('snowplow__iso_639_2t_seed')) }} iso_639_2t_3_char on lower(f.mobile__language) = lower(iso_639_2t_3_char.iso_639_2t_code)
  -- A fallback to the three letter code, with a more complete list, we first try to join on the other dataset the three letter code
  -- in order to get a language name that will match the mapping of the two letter code
  left join {{ ref(var('snowplow__iso_639_3_seed')) }} iso_639_3 on lower(f.mobile__language) = lower(iso_639_3.iso_639_3_code)
{%- endif %}
{% if target.type in ['postgres','spark'] %}
where f.session_dedupe_index = 1
{%- endif %}
