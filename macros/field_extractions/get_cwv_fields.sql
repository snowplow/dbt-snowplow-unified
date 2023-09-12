{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_cwv_fields() %}
  {{ return(adapter.dispatch('get_cwv_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_cwv_fields() %}
  {% if var('snowplow__enable_cwv', false) %}
  {% else %}
    , cast(null as decimal(14,4)) as cwv__lcp,
    , cast(null as decimal(14,4)) as cwv__fcp,
    , cast(null as decimal(14,4)) as cwv__fid,
    , cast(null as decimal(14,4)) as cwv__cls,
    , cast(null as decimal(14,4)) as cwv__inp,
    , cast(null as decimal(14,4)) as cwv__ttfb,
    , cast(null as {{ type_string() }}) as cwv__navigation_type
  {% endif %}
{% endmacro %}

{% macro bigquery__get_cwv_fields() %}

  {% set bq_cwv_fields = [
    {'field':('lcp','cwv__lcp'), 'dtype': 'decimal'},
    {'field':('fcp','cwv__fcp'), 'dtype': 'decimal'},
    {'field':('fid','cwv__fid'), 'dtype': 'decimal'},
    {'field':('cls','cwv__cls'), 'dtype': 'decimal'},
    {'field':('inp','cwv__inp'), 'dtype': 'decimal'},
    {'field':('ttfb','cwv__ttfb'), 'dtype': 'decimal'},
    {'field':('navigation_type','cwv__navigation_type'), 'dtype': 'string'}
    ] %}

  {% if var('snowplow__enable_cwv', false) %}
  ,  {{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_cwv', false),
          col_prefix='unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1',
          fields=bq_cwv_fields,
          relation=source('atomic', 'events') if project_name != 'snowplow_unified_integration_tests' else ref('snowplow_unified_events_stg'),
          relation_alias=none) }}
  {% else %}
    , cast(null as decimal) as cwv__lcp,
    , cast(null as decimal) as cwv__fcp,
    , cast(null as decimal) as cwv__fid,
    , cast(null as decimal) as cwv__cls,
    , cast(null as decimal) as cwv__inp,
    , cast(null as decimal) as cwv__ttfb,
    , cast(null as {{ type_string() }}) as cwv__navigation_type
  {% endif %}
{% endmacro %}

{% macro spark__get_cwv_fields() %}
  {% if var('snowplow__enable_cwv', false) %}
    , unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1.lcp::decimal(14,4) as cwv__lcp
    , unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1.fcp::decimal(14,4) as cwv__fcp
    , unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1.fid::decimal(14,4) as cwv__fid
    , unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1.cls::decimal(14,4) as cwv__cls
    , unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1.inp::decimal(14,4) as cwv__inp
    , unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1.ttfb::decimal(14,4) as cwv__ttfb
    , unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1.navigation_type::varchar(128) as cwv__navigation_type
  {% else %}
    , cast(null as decimal(14,4)) as cwv__lcp,
    , cast(null as decimal(14,4)) as cwv__fcp,
    , cast(null as decimal(14,4)) as cwv__fid,
    , cast(null as decimal(14,4)) as cwv__cls,
    , cast(null as decimal(14,4)) as cwv__inp,
    , cast(null as decimal(14,4)) as cwv__ttfb,
    , cast(null as {{ type_string() }}) as cwv__navigation_type
  {% endif %}
{% endmacro %}

{% macro snowflake__get_cwv_fields() %}
    {% if var('snowplow__enable_cwv', false) %}
    , unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1:lcp::decimal(14,4) as cwv__lcp
    , unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1:fcp::decimal(14,4) as cwv__fcp
    , unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1:fid::decimal(14,4) as cwv__fid
    , unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1:cls::decimal(14,4) as cwv__cls
    , unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1:inp::decimal(14,4) as cwv__inp
    , unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1:ttfb::decimal(14,4) as cwv__ttfb
    , unstruct_event_com_snowplowanalytics_snowplow_web_vitals_1:navigationType::varchar as cwv__navigation_type
    {% else %}
    , cast(null as decimal(14,4)) as cwv__lcp,
    , cast(null as decimal(14,4)) as cwv__fcp,
    , cast(null as decimal(14,4)) as cwv__fid,
    , cast(null as decimal(14,4)) as cwv__cls,
    , cast(null as decimal(14,4)) as cwv__inp,
    , cast(null as decimal(14,4)) as cwv__ttfb,
    , cast(null as {{ type_string() }}) as cwv__navigation_type
    {% endif %}
{% endmacro %}
