{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro stitch_user_identifiers(enabled, relation=this, user_mapping_relation='snowplow_unified_user_mapping') %}
    {{ return(adapter.dispatch('stitch_user_identifiers', 'snowplow_unified')(enabled, relation, user_mapping_relation)) }}
{%- endmacro -%}

{% macro default__stitch_user_identifiers(enabled, relation=this, user_mapping_relation='snowplow_unified_user_mapping') %}
    {% if enabled | as_bool() %}

      -- Update sessions / views table with mapping
      update {{ relation }} as s
      set stitched_user_id = um.user_id
      from {{ ref(user_mapping_relation) }} as um
      where s.user_identifier = um.user_identifier;

    {% endif %}
{%- endmacro -%}

{% macro spark__stitch_user_identifiers(enabled, relation=this, user_mapping_relation='snowplow_unified_user_mapping') %}
    {% if enabled | as_bool() %}

      -- Update sessions / views table with mapping
      merge into {{ relation }} as s
      using {{ ref(user_mapping_relation) }} as um
      on s.user_identifier = um.user_identifier

      when matched then
      update set s.stitched_user_id = um.user_id;

    {% endif %}
{%- endmacro -%}
