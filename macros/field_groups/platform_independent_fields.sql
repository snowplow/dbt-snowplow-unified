{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro platform_independent_fields(table_prefix = none, column_prefix = none) %}
  {{ return(adapter.dispatch('platform_independent_fields', 'snowplow_unified')(table_prefix, column_prefix)) }}
{%- endmacro -%}

{% macro default__platform_independent_fields(table_prefix = none, column_prefix = none) %}

    -- event categorization fields
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}event_name{% if column_prefix %} as {{ column_prefix~"_" }}event_name{% endif %},
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}user_id,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}user_identifier,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}network_userid,

    -- timestamp fields
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}dvce_created_tstamp,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}collector_tstamp,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}derived_tstamp,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}derived_tstamp as start_tstamp,

    -- geo fields
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo_country{% if column_prefix %} as {{ column_prefix~"_" }}geo_country{% endif %},
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo_region{% if column_prefix %} as {{ column_prefix~"_" }}geo_region{% endif %},
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo_region_name{% if column_prefix %} as {{ column_prefix~"_" }}geo_region_name{% endif %},
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo_city{% if column_prefix %} as {{ column_prefix~"_" }}geo_city{% endif %},
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo_zipcode{% if column_prefix %} as {{ column_prefix~"_" }}geo_zipcode {% endif %},
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo_latitude{% if column_prefix %} as {{ column_prefix~"_" }}geo_latitude {% endif %},
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo_longitude{% if column_prefix %} as {{ column_prefix~"_" }}geo_longitude {% endif %},
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}geo_timezone{% if column_prefix %} as {{ column_prefix~"_" }}geo_timezone {% endif %},
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}user_ipaddress{% if column_prefix %} as {{ column_prefix~"_" }}user_ipaddress {% endif %},

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
    {{ channel_group_query() }} as default_channel_group,

    -- webpage / referer / browser fields
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}page_url{% if column_prefix %} as {{ column_prefix~"_" }}page_url{% endif %},
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}page_referrer,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}refr_medium,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}refr_source,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}refr_term,
    {% if table_prefix %}{{ table_prefix~"." }}{% endif %}useragent

{% endmacro %}
