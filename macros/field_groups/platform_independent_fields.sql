{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro platform_independent_fields(table_prefix = none) %}
  {{ return(adapter.dispatch('platform_independent_fields', 'snowplow_unified')(table_prefix)) }}
{%- endmacro -%}

{% macro default__platform_independent_fields(table_prefix = none) %}

    -- event categorization fields
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}view_id,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}view_type,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}event_id,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}session_identifier,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}user_id,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}user_identifier,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}network_userid,

    -- timestamp fields
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}dvce_created_tstamp,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}collector_tstamp,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}derived_tstamp,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}derived_tstamp as start_tstamp,

    -- geo fields
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo_country,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo_region,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo_region_name,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo_city,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo_zipcode,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo_latitude,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo_longitude,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo_timezone,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}user_ipaddress,

    -- device fields
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}app_id,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}platform,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}device_identifier,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}device_category,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}device_session_index,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}os_version,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}os_type,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}screen_resolution,

    -- marketing fields
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mkt_medium,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mkt_source,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mkt_term,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mkt_content,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mkt_campaign,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mkt_clickid,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}mkt_network,

    -- webpage / referer / browser fields
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}page_url,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}page_referrer,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}refr_medium,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}refr_source,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}refr_term,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}useragent

{% endmacro %}
