{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_geo_context_fields() %}
  {{ return(adapter.dispatch('get_geo_context_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_geo_context_fields() %}
  {% if var('snowplow__enable_geolocation_context', false) %}
  {% else %}
    , cast(null as {{ type_float() }}) as geo__latitude
    , cast(null as {{ type_float() }}) as geo__longitude
    , cast(null as {{ type_float() }}) as geo__latitude_longitude_accuracy
    , cast(null as {{ type_float() }}) as geo__altitude
    , cast(null as {{ type_float() }}) as geo__altitude_accuracy
    , cast(null as {{ type_float() }}) as geo__bearing
    , cast(null as {{ type_float() }}) as geo__speed
  {% endif %}
{% endmacro %}

{% macro bigquery__get_geo_context_fields() %}

  {% set bq_geo_context_fields = [
    {'field':('latitude', 'geo__latitude'), 'dtype':'float64'},
    {'field':('longitude', 'geo__longitude'), 'dtype':'float64'},
    {'field':('latitude_longitude_accuracy', 'geo__latitude_longitude_accuracy'), 'dtype':'float64'},
    {'field':('altitude', 'geo__altitude'), 'dtype':'float64'},
    {'field':('altitude_accuracy', 'geo__altitude_accuracy'), 'dtype':'float64'},
    {'field':('bearing', 'geo__bearing'), 'dtype':'float64'},
    {'field':('speed', 'geo__speed'), 'dtype':'float64'}
    ] %}

  {% if var('snowplow__enable_geolocation_context', false) %}
    ,{{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_geolocation_context', false),
          col_prefix='contexts_com_snowplowanalytics_snowplow_geolocation_context_1',
          fields=bq_geo_context_fields,
          relation=source('atomic', 'events') if project_name != 'snowplow_unified_integration_tests' else ref('snowplow_unified_events_stg'),
          relation_alias=none) }}
  {% else %}
    , cast(null as {{ type_float() }}) as geo__latitude
    , cast(null as {{ type_float() }}) as geo__longitude
    , cast(null as {{ type_float() }}) as geo__latitude_longitude_accuracy
    , cast(null as {{ type_float() }}) as geo__altitude
    , cast(null as {{ type_float() }}) as geo__altitude_accuracy
    , cast(null as {{ type_float() }}) as geo__bearing
    , cast(null as {{ type_float() }}) as geo__speed
  {% endif %}
{% endmacro %}

{% macro spark__get_geo_context_fields() %}
  {% if var('snowplow__enable_geolocation_context', false) %}
    , contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].latitude::double AS geo__latitude
    , contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].longitude::double AS geo__longitude
    , contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].latitude_longitude_accuracy::double AS geo__latitude_longitude_accuracy
    , contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].altitude::double AS geo__altitude
    , contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].altitude_accuracy::double AS geo__altitude_accuracy
    , contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].bearing::double AS geo__bearing
    , contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].speed::double AS geo__speed
  {% else %}
    , cast(null as double) as geo__latitude
    , cast(null as double) as geo__longitude
    , cast(null as double) as geo__latitude_longitude_accuracy
    , cast(null as double) as geo__altitude
    , cast(null as double) as geo__altitude_accuracy
    , cast(null as double) as geo__bearing
    , cast(null as double) as geo__speed
  {% endif %}
{% endmacro %}

{% macro snowflake__get_geo_context_fields() %}
  {% if var('snowplow__enable_geolocation_context', false) %}
    , contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:latitude::float AS geo__latitude
    , contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:longitude::float AS geo__longitude
    , contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:latitudeLongitudeAccuracy::float AS geo__latitude_longitude_accuracy
    , contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:altitude::float AS geo__altitude
    , contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:altitudeAccuracy::float AS geo__altitude_accuracy
    , contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:bearing::float AS geo__bearing
    , contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:speed::float AS geo__speed
  {% else %}
    , cast(null as {{ type_float() }}) as geo__latitude
    , cast(null as {{ type_float() }}) as geo__longitude
    , cast(null as {{ type_float() }}) as geo__latitude_longitude_accuracy
    , cast(null as {{ type_float() }}) as geo__altitude
    , cast(null as {{ type_float() }}) as geo__altitude_accuracy
    , cast(null as {{ type_float() }}) as geo__bearing
    , cast(null as {{ type_float() }}) as geo__speed
  {% endif %}
{% endmacro %}
