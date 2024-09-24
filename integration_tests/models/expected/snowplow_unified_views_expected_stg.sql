{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}



select
-- hard-coding due to non-deterministic outcome from row_number for Redshift/Postgres/databricks
{% if target.type in ['redshift', 'postgres', 'databricks', 'spark'] -%}
  case when event_id in ('1b4b3b57-3cb7-4df2-a7fd-526afa9e3c76', '3cfe1cd4-a20e-4fc7-952a-a5cb7f7d063f') then 'true base' else app_id end as app_id,
{% elif target.type in ['bigquery'] -%}
  case when event_id in ('1b4b3b57-3cb7-4df2-a7fd-526afa9e3c76') then 'true base' else app_id end as app_id,
{% else %}
  app_id,
{% endif %}

  -- hard-coding due to non-deterministic outcome from row_number for Redshift/Postgres/databricks
{% if target.type in ['redshift', 'postgres', 'databricks', 'spark'] -%}
  case when event_id = '1b4b3b57-3cb7-4df2-a7fd-526afa9e3c76' then '2021-03-01 20:56:33.286'
  when event_id = '3cfe1cd4-a20e-4fc7-952a-a5cb7f7d063f' then '2021-02-26 10:50:43.000'
  else dvce_created_tstamp end as dvce_created_tstamp,
{% else %}
  dvce_created_tstamp,
{% endif %}

  -- hard-coding due to non-deterministic outcome from row_number for Redshift/Postgres/databricks
{% if target.type in ['redshift', 'postgres', 'databricks', 'spark'] -%}
  case when event_id = '1b4b3b57-3cb7-4df2-a7fd-526afa9e3c76' then '2021-03-01 20:56:39.192'
  when event_id = '3cfe1cd4-a20e-4fc7-952a-a5cb7f7d063f' then '2021-02-26 10:50:47.000'
  else derived_tstamp end as derived_tstamp,
{% elif target.type in ['bigquery'] -%}
  case when event_id = '1b4b3b57-3cb7-4df2-a7fd-526afa9e3c76' then '2021-03-01 20:56:39.192'
  else derived_tstamp end as derived_tstamp,
{% else %}
  derived_tstamp,
{% endif %}

  -- hard-coding due to non-deterministic outcome from row_number for Redshift/Postgres/databricks
{% if target.type in ['redshift', 'postgres', 'databricks', 'spark'] -%}
  case when event_id = '1b4b3b57-3cb7-4df2-a7fd-526afa9e3c76' then '2021-03-01 20:56:39.192'
  when event_id = '3cfe1cd4-a20e-4fc7-952a-a5cb7f7d063f' then '2021-02-26 10:50:47.000'
  else start_tstamp end as start_tstamp,
{% elif target.type in ['bigquery'] -%}
  case when event_id = '1b4b3b57-3cb7-4df2-a7fd-526afa9e3c76' then '2021-03-01 20:56:39.192'
  else start_tstamp end as start_tstamp,
{% else %}
  start_tstamp,
{% endif %}

  -- hard-coding due to non-deterministic outcome from row_number for Redshift/Postgres/databricks
{% if target.type in ['redshift', 'postgres', 'databricks', 'spark'] -%}
  case when event_id = '1b4b3b57-3cb7-4df2-a7fd-526afa9e3c76' then '2021-03-01 20:56:39.192'
  when event_id = '3cfe1cd4-a20e-4fc7-952a-a5cb7f7d063f' then '2021-02-26 10:50:47.000'
  else end_tstamp end as end_tstamp,
{% elif target.type in ['bigquery'] -%}
  case when event_id = '1b4b3b57-3cb7-4df2-a7fd-526afa9e3c76' then '2021-03-01 20:56:39.192'
  else end_tstamp end as end_tstamp,
{% else %}
  end_tstamp,
{% endif %}

view_id,
event_name,
event_id,
session_identifier,

 -- hard-coding due to non-deterministic outcome from row_number for Redshift/Postgres/databricks
{% if target.type in ['redshift', 'postgres', 'databricks', 'spark'] -%}
  case when event_id = '3cfe1cd4-a20e-4fc7-952a-a5cb7f7d063f' then 1
  when event_id = 'b3eca04e-d277-45e0-9c7c-76dc7e8c16ff' then 2
  else view_in_session_index end as view_in_session_index,
{% else %}
  view_in_session_index,
{% endif %}

views_in_session,
session__previous_session_id,
user_id,
user_identifier,
stitched_user_id,

 -- hard-coding due to non-deterministic outcome from row_number for Redshift/Postgres/databricks
{% if target.type in ['redshift', 'postgres', 'databricks', 'spark'] -%}
  case when event_id = '3cfe1cd4-a20e-4fc7-952a-a5cb7f7d063f' then '0e77779ebe3beec35d423f1c1952b81d69ecda6325902921c8e761856835808d'
  else network_userid end as network_userid,
{% else %}
  network_userid,
{% endif %}

collector_tstamp,

platform,
device_identifier,
device_category,
device_session_index,
os_version,
os_type,
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
os_timezone,
screen_resolution,
yauaa__device_class,
yauaa__device_version,
yauaa__operating_system_version,
yauaa__operating_system_class,
yauaa__operating_system_name,
yauaa__operating_system_name_version,
geo_country,
geo_region,
geo_region_name,
geo_city,
geo_zipcode,
geo_latitude,
geo_longitude,
geo_timezone,
user_ipaddress,
engaged_time_in_s,
absolute_time_in_s,
horizontal_pixels_scrolled,
vertical_pixels_scrolled,
horizontal_percentage_scrolled,
vertical_percentage_scrolled,
mkt_medium,
mkt_source,
mkt_term,
mkt_content,
mkt_campaign,
mkt_clickid,
mkt_network,
default_channel_group,
page_url,
page_referrer,
refr_medium,
refr_source,
refr_term,
page_title,
content_group,
page_urlscheme,
page_urlhost,
page_urlpath,
page_urlquery,
page_urlfragment,
refr_urlscheme,
refr_urlhost,
refr_urlpath,
refr_urlquery,
refr_urlfragment,
br_lang,
br_viewwidth,
br_viewheight,
br_colordepth,
br_renderengine,
doc_width,
doc_height,
iab__category,
iab__primary_impact,
iab__reason,
iab__spider_or_robot,
yauaa__device_name,
yauaa__agent_class,
yauaa__device_brand,
yauaa__agent_name,
yauaa__agent_name_version,
yauaa__agent_name_version_major,
yauaa__agent_version,
yauaa__agent_version_major,
yauaa__layout_engine_class,
yauaa__layout_engine_name,
yauaa__layout_engine_name_version,
yauaa__layout_engine_name_version_major,
yauaa__layout_engine_version,
yauaa__layout_engine_version_major,
ua__device_family,
ua__os_family,
ua__os_version,
ua__os_major,
ua__os_minor,
ua__os_patch,
ua__os_patch_minor,
ua__useragent_family,
ua__useragent_major,
ua__useragent_minor,
ua__useragent_patch,
ua__useragent_version,
screen_view__name,
screen_view__previous_id,
screen_view__previous_name,
screen_view__previous_type,
screen_view__transition_type,
screen_view__type,
app__build,
app__version,
geo__altitude,
geo__altitude_accuracy,
geo__bearing,
geo__latitude,
geo__latitude_longitude_accuracy,
geo__longitude,
geo__speed,
screen__fragment,
cast(screen__top_view_controller as {{ dbt.type_string() }}) as screen__top_view_controller,
cast(screen__view_controller as {{ dbt.type_string() }}) as screen__view_controller,
useragent,
v_collector,
event_id2,
agg_test


from {{ ref('snowplow_unified_views_expected') }}
