{#
Copyright (c) 2026-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{#
  Returns an array or object property of a shredded table as JSON text.
#}
{% macro json_text(column) %}
  {{ return(adapter.dispatch('json_text', 'snowplow_unified')(column)) }}
{% endmacro %}

{% macro default__json_text(column) %}
  {{ column }}
{% endmacro %}

{#
  On Redshift the column is either VARCHAR holding JSON text or SUPER, depending on the RDB Loader version that
  created the table. Casting to SUPER leaves a SUPER value as it is and makes a VARCHAR a string scalar, so the
  same SQL works for both. A NULL, or a JSON null in a SUPER column, gives NULL.
#}
{% macro redshift__json_text(column) %}
  case
    when is_array(cast({{ column }} as super)) or is_object(cast({{ column }} as super))
      then json_serialize(cast({{ column }} as super))
    else cast(cast({{ column }} as super) as {{ snowplow_utils.type_max_string() }})
  end
{% endmacro %}
