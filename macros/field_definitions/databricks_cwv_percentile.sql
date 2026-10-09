{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{% macro databricks_cwv_percentile(field, percentile=none) %}
  {% set percentile = var('snowplow__cwv_percentile') if percentile is none else percentile %}
  {# The upstream CWV model normalizes measurements to three decimal places.
     Interpolation adds at most the number of fractional digits in 0.<percentile>.
     Restore that exact decimal scale before classification and ceiling: the
     DOUBLE returned by percentile_cont can sit just above an exact boundary. #}
  {% set scale = 3 + (percentile | string | length) %}
  cast(
    percentile_cont(0.{{ percentile }}) within group (order by {{ field }})
    as decimal(38, {{ scale }})
  )
{% endmacro %}
