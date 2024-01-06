{#
Copyright (c) 2023-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

{# CWV tests run on a different source dataset, this is an easy way to hack them together. #}
{% if not var("snowplow__enable_cwv", false) and not var("snowplow__enable_screen_summary_context", false) %}

select
  *

from {{ ref('snowplow_unified_events') }}

{% elif var("snowplow__enable_screen_summary_context", false) %}

select
  *

from {{ ref('snowplow_unified_screen_engagement_events') }}

{% else %}

select
 *

from {{ ref('snowplow_unified_web_vital_events') }}


{% endif %}
