{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro channel_group_query() %}
  {{ return(adapter.dispatch('channel_group_query', 'snowplow_unified')()) }}
{% endmacro %}


{% macro bigquery__channel_group_query() %}
{% set src_field %}
   {% if var('snowplow__use_refr_if_mkt_null', false) %}
      coalesce(mkt_source, refr_source)
   {% else %}
      mkt_source
   {% endif %}
{% endset %}
{% set medium_field %}
   {% if var('snowplow__use_refr_if_mkt_null', false) %}
      coalesce(mkt_medium, refr_medium)
   {% else %}
      mkt_medium
   {% endif %}
{% endset %}
{# Note that campaign has no equivalent in refer #}

case
   when lower(trim({{ src_field }})) = 'direct' and lower(trim({{ medium_field }})) in ('not set', 'none') then 'Direct'
   when lower(trim({{ medium_field }})) like '%cross-network%' then 'Cross-network'
   when regexp_contains(trim({{ medium_field }}), r'(?i)^(.*cp.*|ppc|retargeting|paid.*)$') then
      case
         when upper(source_category) = 'SOURCE_CATEGORY_SHOPPING'
            or regexp_contains(trim(mkt_campaign), r'(?i)^(.*(([^a-df-z]|^)shop|shopping).*)$') then 'Paid Shopping'
         when upper(source_category) = 'SOURCE_CATEGORY_SEARCH' then 'Paid Search'
         when upper(source_category) = 'SOURCE_CATEGORY_SOCIAL' then 'Paid Social'
         when upper(source_category) = 'SOURCE_CATEGORY_VIDEO' then 'Paid Video'
         else 'Paid Other'
      end
   when lower(trim({{ medium_field }})) in ('display', 'banner', 'expandable', 'interstitial', 'cpm') then 'Display'
   when upper(source_category) = 'SOURCE_CATEGORY_SHOPPING'
      or regexp_contains(trim(mkt_campaign), r'(?i)^(.*(([^a-df-z]|^)shop|shopping).*)$') then 'Organic Shopping'
   when upper(source_category) = 'SOURCE_CATEGORY_SOCIAL' or lower(trim({{ medium_field }})) in ('social', 'social-network', 'sm', 'social network', 'social media') then 'Organic Social'
   when upper(source_category) = 'SOURCE_CATEGORY_VIDEO'
      or regexp_contains(trim({{ medium_field }}), r'(?i)^(.*video.*)$') then 'Organic Video'
   when upper(source_category) = 'SOURCE_CATEGORY_SEARCH' or lower(trim({{ medium_field }})) = 'organic' then 'Organic Search'
   when lower(trim({{ medium_field }})) in ('referral', 'app', 'link') then 'Referral'
   when lower(trim({{ src_field }})) in ('email', 'e-mail', 'e_mail', 'e mail') or lower(trim({{ medium_field }})) in ('email', 'e-mail', 'e_mail', 'e mail') then 'Email'
   when lower(trim({{ medium_field }})) = 'affiliate' then 'Affiliates'
   when lower(trim({{ medium_field }})) = 'audio' then 'Audio'
   when lower(trim({{ src_field }})) = 'sms' or lower(trim({{ medium_field }})) = 'sms' then 'SMS'
   when lower(trim({{ medium_field }})) like '%push' or regexp_contains(trim({{ medium_field }}), r'(?i).*(mobile|notification).*') or lower(trim({{ src_field }})) = 'firebase' then 'Mobile Push Notifications'
   else 'Unassigned'
end
{% endmacro %}

{% macro default__channel_group_query() %}
{% set src_field %}
   {% if var('snowplow__use_refr_if_mkt_null', false) %}
      coalesce(mkt_source, refr_source)
   {% else %}
      mkt_source
   {% endif %}
{% endset %}
{% set medium_field %}
   {% if var('snowplow__use_refr_if_mkt_null', false) %}
      coalesce(mkt_medium, refr_medium)
   {% else %}
      mkt_medium
   {% endif %}
{% endset %}
{# Note that campaign has no equivalent in refer #}

case
   when lower(trim({{ src_field }})) = 'direct' and lower(trim({{ medium_field }})) in ('not set', 'none') then 'Direct'
   when lower(trim({{ medium_field }})) like '%cross-network%' then 'Cross-network'
   when regexp_like(lower(trim({{ medium_field }})), '^(.*cp.*|ppc|retargeting|paid.*)$') then
      case
         when upper(source_category) = 'SOURCE_CATEGORY_SHOPPING'
            or regexp_like(lower(trim(mkt_campaign)), '^(.*(([^a-df-z]|^)shop|shopping).*)$') then 'Paid Shopping'
         when upper(source_category) = 'SOURCE_CATEGORY_SEARCH' then 'Paid Search'
         when upper(source_category) = 'SOURCE_CATEGORY_SOCIAL' then 'Paid Social'
         when upper(source_category) = 'SOURCE_CATEGORY_VIDEO' then 'Paid Video'
         else 'Paid Other'
      end
   when lower(trim({{ medium_field }})) in ('display', 'banner', 'expandable', 'intersitial', 'cpm') then 'Display'
   when upper(source_category) = 'SOURCE_CATEGORY_SHOPPING'
      or regexp_like(lower(trim(mkt_campaign)), '^(.*(([^a-df-z]|^)shop|shopping).*)$') then 'Organic Shopping'
   when upper(source_category) = 'SOURCE_CATEGORY_SOCIAL' or lower(trim({{ medium_field }})) in ('social', 'social-network', 'sm', 'social network', 'social media') then 'Organic Social'
   when upper(source_category) = 'SOURCE_CATEGORY_VIDEO'
      or regexp_like(lower(trim({{ medium_field }})), '^(.*video.*)$') then 'Organic Video'
   when upper(source_category) = 'SOURCE_CATEGORY_SEARCH' or lower(trim({{ medium_field }})) = 'organic' then 'Organic Search'
   when lower(trim({{ medium_field }})) in ('referral', 'app', 'link') then 'Referral'
   when lower(trim({{ src_field }})) in ('email', 'e-mail', 'e_mail', 'e mail') or lower(trim({{ medium_field }})) in ('email', 'e-mail', 'e_mail', 'e mail') then 'Email'
   when lower(trim({{ medium_field }})) = 'affiliate' then 'Affiliates'
   when lower(trim({{ medium_field }})) = 'audio' then 'Audio'
   when lower(trim({{ src_field }})) = 'sms' or lower(trim({{ medium_field }})) = 'sms' then 'SMS'
   when lower(trim({{ medium_field }})) like '%push' or regexp_like(lower(trim({{ medium_field }})), '.*(mobile|notification).*') or lower(trim({{ src_field }})) = 'firebase' then 'Mobile Push Notifications'
   else 'Unassigned'
end
{% endmacro %}

{% macro redshift__channel_group_query() %}
{% set src_field %}
   {% if var('snowplow__use_refr_if_mkt_null', false) %}
      coalesce(mkt_source, refr_source)
   {% else %}
      mkt_source
   {% endif %}
{% endset %}
{% set medium_field %}
   {% if var('snowplow__use_refr_if_mkt_null', false) %}
      coalesce(mkt_medium, refr_medium)
   {% else %}
      mkt_medium
   {% endif %}
{% endset %}
{# Note that campaign has no equivalent in refer #}

case
   when lower(trim({{ src_field }})) = 'direct' and lower(trim({{ medium_field }})) in ('not set', 'none') then 'Direct'
   when lower(trim({{ medium_field }})) like '%cross-network%' then 'Cross-network'
   when regexp_instr(lower(trim({{ medium_field }})), '^(.*cp.*|ppc|retargeting|paid.*)$') then
      case
         when upper(source_category) = 'SOURCE_CATEGORY_SHOPPING'
            or regexp_instr(lower(trim(mkt_campaign)), '^(.*(([^a-df-z]|^)shop|shopping).*)$') then 'Paid Shopping'
         when upper(source_category) = 'SOURCE_CATEGORY_SEARCH' then 'Paid Search'
         when upper(source_category) = 'SOURCE_CATEGORY_SOCIAL' then 'Paid Social'
         when upper(source_category) = 'SOURCE_CATEGORY_VIDEO' then 'Paid Video'
         else 'Paid Other'
      end
   when lower(trim({{ medium_field }})) in ('display', 'banner', 'expandable', 'intersitial', 'cpm') then 'Display'
   when upper(source_category) = 'SOURCE_CATEGORY_SHOPPING'
      or regexp_instr(lower(trim(mkt_campaign)), '^(.*(([^a-df-z]|^)shop|shopping).*)$') then 'Organic Shopping'
   when upper(source_category) = 'SOURCE_CATEGORY_SOCIAL' or lower(trim({{ medium_field }})) in ('social', 'social-network', 'sm', 'social network', 'social media') then 'Organic Social'
   when upper(source_category) = 'SOURCE_CATEGORY_VIDEO'
      or regexp_instr(lower(trim({{ medium_field }})), '^(.*video.*)$') then 'Organic Video'
   when upper(source_category) = 'SOURCE_CATEGORY_SEARCH' or lower(trim({{ medium_field }})) = 'organic' then 'Organic Search'
   when lower(trim({{ medium_field }})) in ('referral', 'app', 'link') then 'Referral'
   when lower(trim({{ src_field }})) in ('email', 'e-mail', 'e_mail', 'e mail') or lower(trim({{ medium_field }})) in ('email', 'e-mail', 'e_mail', 'e mail') then 'Email'
   when lower(trim({{ medium_field }})) = 'affiliate' then 'Affiliates'
   when lower(trim({{ medium_field }})) = 'audio' then 'Audio'
   when lower(trim({{ src_field }})) = 'sms' or lower(trim({{ medium_field }})) = 'sms' then 'SMS'
   when lower(trim({{ medium_field }})) like '%push' or regexp_instr(lower(trim({{ medium_field }})), '.*(mobile|notification).*') or lower(trim({{ src_field }})) = 'firebase' then 'Mobile Push Notifications'
   else 'Unassigned'
end
{% endmacro %}
