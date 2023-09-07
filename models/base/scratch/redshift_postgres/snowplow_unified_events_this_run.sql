with base as (

  select
    session_identifier,
    app_id,
    platform,
    etl_tstamp,
    collector_tstamp,
    dvce_created_tstamp,
    event,
    event_id,
    txn_id,
    name_tracker,
    v_tracker,
    v_collector,
    v_etl,
    user_id,
    user_ipaddress,
    user_fingerprint,
    domain_userid,
    domain_sessionidx,
    network_userid,
    geo_country,
    geo_region,
    geo_city,
    geo_zipcode,
    geo_latitude,
    geo_longitude,
    geo_region_name,
    ip_isp,
    ip_organization,
    ip_domain,
    ip_netspeed,
    page_title,
    page_urlscheme,
    page_urlhost,
    page_urlport,
    page_urlpath,
    page_urlquery,
    page_urlfragment,
    refr_urlscheme,
    refr_urlhost,
    refr_urlport,
    refr_urlpath,
    refr_urlquery,
    refr_urlfragment,
    refr_medium,
    refr_source,
    refr_term,
    mkt_medium,
    mkt_source,
    mkt_term,
    mkt_content,
    mkt_campaign,
    se_category,
    se_action,
    se_label,
    se_property,
    se_value,
    tr_orderid,
    tr_affiliation,
    tr_total,
    tr_tax,
    tr_shipping,
    tr_city,
    tr_state,
    tr_country,
    ti_orderid,
    ti_sku,
    ti_name,
    ti_category,
    ti_price,
    ti_quantity,
    pp_xoffset_min,
    pp_xoffset_max,
    pp_yoffset_min,
    pp_yoffset_max,
    useragent,
    br_name,
    br_family,
    br_version,
    br_type,
    br_renderengine,
    br_lang,
    br_features_pdf,
    br_features_flash,
    br_features_java,
    br_features_director,
    br_features_quicktime,
    br_features_realplayer,
    br_features_windowsmedia,
    br_features_gears,
    br_features_silverlight,
    br_cookies,
    br_colordepth,
    br_viewwidth,
    br_viewheight,
    os_name,
    os_family,
    os_manufacturer,
    os_timezone,
    dvce_type,
    dvce_ismobile,
    dvce_screenwidth,
    dvce_screenheight,
    doc_charset,
    doc_width,
    doc_height,
    tr_currency,
    tr_total_base,
    tr_tax_base,
    tr_shipping_base,
    ti_currency,
    ti_price_base,
    base_currency,
    geo_timezone,
    mkt_clickid,
    mkt_network,
    etl_tags,
    dvce_sent_tstamp,
    refr_domain_userid,
    refr_dvce_tstamp,
    domain_sessionid,
    derived_tstamp,
    event_vendor,
    event_name,
    event_format,
    event_version,
    event_fingerprint,
    true_tstamp,
    load_tstamp,
    user_identifier,

{% if var('snowplow__enable_web') %}
    page_view__id,
    page_view___tstamp,
    page_view___id,
{% endif %}

{% if var('snowplow__enable_iab', false) -%}
    iab__category,
    iab__primary_impact,
    iab__reason,
    iab__spider_or_robot,
    iab___tstamp,
    iab___id,
{% endif %}

{% if var('snowplow__enable_ua', false) -%}
    ua__device_family,
    ua__os_family,
    ua__os_major,
    ua__os_minor,
    ua__os_patch,
    ua__os_patch_minor,
    ua__os_version,
    ua__useragent_family,
    ua__useragent_major,
    ua__useragent_minor,
    ua__useragent_patch,
    ua__useragent_version,
    ua___tstamp,
    ua___id,
{% endif %}

{% if var('snowplow__enable_yauaa', false) -%}
    yauaa__agent_class,
    yauaa__agent_information_email,
    yauaa__agent_name,
    yauaa__agent_name_version,
    yauaa__agent_name_version_major,
    yauaa__agent_version,
    yauaa__agent_version_major,
    yauaa__device_brand,
    yauaa__device_class,
    yauaa__device_cpu,
    yauaa__device_cpu_bits,
    yauaa__device_name,
    yauaa__device_version,
    yauaa__layout_engine_class,
    yauaa__layout_engine_name,
    yauaa__layout_engine_name_version,
    yauaa__layout_engine_name_version_major,
    yauaa__layout_engine_version,
    yauaa__layout_engine_version_major,
    yauaa__network_type,
    yauaa__operating_system_class,
    yauaa__operating_system_name,
    yauaa__operating_system_name_version,
    yauaa__operating_system_name_version_major,
    yauaa__operating_system_version,
    yauaa__operating_system_version_build,
    yauaa__operating_system_version_major,
    yauaa__webview_app_name,
    yauaa__webview_app_name_version_major,
    yauaa__webview_app_version,
    yauaa__webview_app_version_major,
    yauaa___tstamp,
    yauaa___id,
{% endif %}

{% if var('snowplow__enable_consent', false) -%}
    cmp_visible_elapsed_time,
    cmp_visible__tstamp,
    cmp_visible__id,
    consent_pref_basis_for_processing,
    consent_pref_consent_version,
    consent_pref_consent_scopes,
    consent_pref_domains_applied,
    consent_pref_consent_url,
    consent_pref_event_type,
    consent_pref_gdpr_applies,
    consent_pref__tstamp,
    consent_pref__id,
{% endif %}

{% if var('snowplow__enable_mobile') %}
    screen_view__id,
    screen_view__name,
    screen_view__previous_id,
    screen_view__previous_name,
    screen_view__previous_type,
    screen_view__transition_type,
    screen_view__type,
    screen_view___tstamp,
    screen_view___id,
    session__session_id,
    session__session_index,
    session__previous_session_id,
    session__user_id,
    session__first_event_id,
    session___tstamp,
    session___id,
{% endif %}

{% if var('snowplow__enable_mobile_context', false) -%}
    mobile__device_manufacturer,
    mobile__device_model,
    mobile__os_type,
    mobile__os_version,
    mobile__android_idfa,
    mobile__apple_idfa,
    mobile__apple_idfv,
    mobile__carrier,
    mobile__open_idfa,
    mobile__network_technology,
    mobile__network_type,
    mobile__physical_memory,
    mobile__system_available_memory,
    mobile__app_available_memory,
    mobile__battery_level,
    mobile__battery_state,
    mobile__low_power_mode,
    mobile__available_storage,
    mobile__total_storage,
    mobile__is_portrait,
    mobile__resolution,
    mobile__scale,
    mobile__language,
    mobile__app_set_id,
    mobile__app_set_id_scope,
    mobile___tstamp,
    mobile___id,
{% endif %}

{% if var('snowplow__enable_geolocation_context', false) -%}
    geo__latitude,
    geo__longitude,
    geo__latitude_longitude_accuracy,
    geo__altitude,
    geo__altitude_accuracy,
    geo__bearing,
    geo__speed,
    geo__timestamp,
    geo___tstamp,
    geo___id,
{% endif %}

{% if var('snowplow__enable_application_context', false) -%}
    app__build,
    app__version,
    app___tstamp,
    app___id,
{% endif %}

{% if var('snowplow__enable_screen_context', false) -%}
    screen__id,
    screen__name,
    screen__activity,
    screen__type,
    screen__fragment,
    screen__top_view_controller,
    screen__view_controller,
{% endif %}

{% if var('snowplow__enable_application_errors_module', false) -%}
    app_err__message,
    app_err__programming_language,
    app_err__class_name,
    app_err__exception_name,
    app_err__is_fatal,
    app_err__line_number,
    app_err__stack_trace,
    app_err__thread_id,
    app_err__thread_name,
    app_err___tstamp,
    app_err___id,
{% endif %}

{% if var('snowplow__enable_deep_link_context', false) -%}
    deep_link__url,
    deep_link__referrer,
    deep_link___tstamp,
    deep_link___id,
  {% endif %}

{% if var('snowplow__enable_browser_context', false) -%}
    browser__viewport,
    browser__document_size,
    browser__resolution,
    browser__color_depth,
    browser__device_pixel_ratio,
    browser__cookies_enabled,
    browser__online,
    browser__browser_language,
    browser__document_language,
    browser__webdriver,
    browser__device_memory,
    browser__hardware_concurrency,
    browser__tab_id,
    browser___tstamp,
    browser___id,
{% endif %}

    coalesce(
      {% if var('snowplow__enable_web') %}
        ev.page_view__id,
      {% endif %}
      {% if var('snowplow__enable_mobile') %}
        ev.screen_view__id,
      {% endif %}
      null) as view_id,

      coalesce(
      {% if var('snowplow__enable_web') %}
        case when ev.page_view__id is not null then 'page_view' end,
      {% endif %}
      {% if var('snowplow__enable_mobile') %}
        case when ev.screen_view__id is not null then 'screen_view' end,
      {% endif %}
      null) as view_type,

      coalesce(
      {% if var('snowplow__enable_web') %}
        ev.domain_sessionidx,
      {% endif %}
      {% if var('snowplow__enable_mobile') %}
        ev.session__session_index,
      {% endif %}
      null) as session_index,

    coalesce(
      {% if var('snowplow__enable_deep_link_context') %}
        ev.deep_link__referrer,
      {% else %}
        ev.page_referrer,
      {% endif %}
      null) as page_referrer,

    coalesce(
      {% if var('snowplow__enable_deep_link_context') %}
        ev.deep_link__url,
      {% else %}
        ev.page_url,
      {% endif %}
      null) as page_url,

    coalesce(
      {% if var('snowplow__enable_mobile_context') %}
        ev.mobile__resolution,
      {% else %}
        ev.dvce_screenwidth || 'x' || ev.dvce_screenheight,
      {% endif %}
      null) as screen_resolution,

    coalesce(
      {% if var('snowplow__enable_yauaa') %}
        ev.yauaa__operating_system_name,
      {% endif %}
      {% if var('snowplow__enable_mobile_context') %}
        ev.mobile__os_type,
      {% endif %}
      {% if var('snowplow__enable_ua') %}
        ev.ua__os_family,
      {% endif %}
      null, null) as os_type,

    coalesce(
      {% if var('snowplow__enable_yauaa') %}
        ev.yauaa__operating_system_version,
      {% endif %}
      {% if var('snowplow__enable_mobile_context') %}
        ev.mobile__os_version,
      {% endif %}
      {% if var('snowplow__enable_ua') %}
        ev.ua__os_version,
      {% endif %}
      null) as os_version


  from {{ ref('snowplow_unified_base_events_this_run') }} as ev

)

select
  *,
  {% if var('snowplow__enable_yauaa') %}
    {% if var('snowplow__enable_mobile') %}
      case when view_type = 'mobile' then 'Mobile'
      when yauaa__device_class  = 'Desktop' then 'Desktop'
      when yauaa__device_class = 'Phone' then 'Mobile'
      when yauaa__device_class = 'Tablet' then 'Tablet'
      else 'Other' end as device_category
    {%- else -%}
      case when yauaa__device_class = 'Desktop' then 'Desktop'
      when yauaa__device_class = 'Phone' then 'Mobile'
      when yauaa__device_class = 'Tablet' then 'Tablet'
      else 'Other' end as device_category
    {%- endif %}
  {%- endif %}

from base
