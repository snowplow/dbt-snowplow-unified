{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro get_consent_event_fields() %}
  {{ return(adapter.dispatch('get_consent_event_fields', 'snowplow_unified')()) }}
{%- endmacro -%}

{% macro postgres__get_consent_event_fields() %}
  {% if var('snowplow__enable_consent', false) %}
  {% else %}
      , cast(null as {{ snowplow_utils.type_max_string() }}) as consent__event_type
      , cast(null as {{ snowplow_utils.type_max_string() }}) as consent__basis_for_processing
      , cast(null as {{ snowplow_utils.type_max_string() }}) as consent__consent_url
      , cast(null as {{ snowplow_utils.type_max_string() }}) as consent__consent_version
      , cast(null as {{ snowplow_utils.type_max_string() }}) as consent__consent_scopes
      , cast(null as {{ snowplow_utils.type_max_string() }}) as consent__domains_applied
      , cast(null as {{ dbt.type_boolean() }}) as consent__gdpr_applies
  {% endif %}
{% endmacro %}

{% macro bigquery__get_consent_event_fields() %}

  {% set bq_consent_fields = [
      {'field':('event_type','consent__event_type'), 'dtype': 'string'},
      {'field':('basis_for_processing','consent__basis_for_processing'), 'dtype': 'string'},
      {'field':('consent_url','consent__consent_url'), 'dtype': 'string'},
      {'field':('consent_version','consent__consent_version'), 'dtype': 'string'},
      {'field':('consent_scopes','consent__consent_scopes'), 'dtype': 'string'},
      {'field':('domains_applied','consent__domains_applied'), 'dtype': 'string'},
      {'field':('gdpr_applies','consent__gdpr_applies'), 'dtype': 'string'}
    ] %}

  {% if var('snowplow__enable_consent', false) %}
  ,  {{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_consent', false),
          col_prefix='unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1',
          fields=bq_consent_fields,
         relation=ref('snowplow_unified_events_stg') if 'integration_tests' in project_name and 'snowplow' in project_name else source('atomic', 'events') ,
          relation_alias=none) }}
  {% else %}
      , cast(null as {{ dbt.type_string() }}) as consent__event_type
      , cast(null as {{ dbt.type_string() }}) as consent__basis_for_processing
      , cast(null as {{ dbt.type_string() }}) as consent__consent_url
      , cast(null as {{ dbt.type_string() }}) as consent__consent_version
      , cast(null as array) as consent__consent_scopes
      , cast(null as array) as consent__domains_applied
      , cast(null as {{ dbt.type_boolean() }}) as consent__gdpr_applies
  {% endif %}
{% endmacro %}

{% macro spark__get_consent_event_fields() %}
  {% if var('snowplow__enable_consent', false) %}
    , cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1.event_type as STRING) as consent__event_type
    , cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1.basis_for_processing as STRING) as consent__basis_for_processing
    , cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1.consent_url as STRING) as consent__consent_url
    , cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1.consent_version as STRING) as consent__consent_version
    , cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1.consent_scopes as ARRAY<STRING>) as consent__consent_scopes
    , cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1.domains_applied as ARRAY<STRING>) as consent__domains_applied
    , cast(unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1.gdpr_applies as boolean) as consent__gdpr_applies
  {% else %}
      , cast(null as {{ dbt.type_string() }}) as consent__event_type
      , cast(null as {{ dbt.type_string() }}) as consent__basis_for_processing
      , cast(null as {{ dbt.type_string() }}) as consent__consent_url
      , cast(null as {{ dbt.type_string() }}) as consent__consent_version
      , cast(null as ARRAY<STRING>) as consent__consent_scopes
      , cast(null as ARRAY<STRING>) as consent__domains_applied
      , cast(null as {{ dbt.type_boolean() }}) as consent__gdpr_applies

  {% endif %}
{% endmacro %}

{% macro snowflake__get_consent_event_fields() %}
  {% if var('snowplow__enable_consent', false) %}
    {% if var('snowplow__snowflake_lakeloader', false) %}
      , unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1:event_type::varchar as consent__event_type
      , unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1:basis_for_processing::varchar as consent__basis_for_processing
      , unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1:consent_url::varchar as consent__consent_url
      , unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1:consent_version::varchar as consent__consent_version
      , unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1:consent_scopes::array as consent__consent_scopes
      , unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1:domains_applied::array as consent__domains_applied
      , unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1:gdpr_applies::boolean as consent__gdpr_applies
    {% else %}
      , unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1:eventType::varchar as consent__event_type
      , unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1:basisForProcessing::varchar as consent__basis_for_processing
      , unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1:consentUrl::varchar as consent__consent_url
      , unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1:consentVersion::varchar as consent__consent_version
      , unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1:consentScopes::array as consent__consent_scopes
      , unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1:domainsApplied::array as consent__domains_applied
      , unstruct_event_com_snowplowanalytics_snowplow_consent_preferences_1:gdprApplies::boolean as consent__gdpr_applies
    {% endif %}

  {% else %}
    , cast(null as {{ dbt.type_string() }}) as consent__event_type
    , cast(null as {{ dbt.type_string() }}) as consent__basis_for_processing
    , cast(null as {{ dbt.type_string() }}) as consent__consent_url
    , cast(null as {{ dbt.type_string() }}) as consent__consent_version
    , cast(null as array) as consent__consent_scopes
    , cast(null as array) as consent__domains_applied
    , cast(null as {{ dbt.type_boolean() }}) as consent__gdpr_applies
  {% endif %}
{% endmacro %}
