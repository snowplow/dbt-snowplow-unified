{% docs macro_filter_bots %}
{% raw %}
This macro is used to generate a warehouse specific filter for the `useragent` field to remove bots from processing, or to overwrite for custom filtering. The filter excludes any of the following in the string:
- bot
- crawl
- slurp
- spider
- archiv
- spinn
- sniff
- seo
- audit
- survey
- pingdom
- worm
- capture
- (browser|screen)shots
- analyz
- index
- thumb
- check
- facebook
- PingdomBot
- PhantomJS
- YandexBot
- Twitterbot
- a_archiver
- facebookexternalhit
- Bingbot
- BingPreview
- Googlebot
- Baiduspider
- 360(Spider|User-agent)
- semalt

#### Returns

A filter on `useragent` to exclude those with strings matching the above list.

#### Usage

```sql
select
...
from
...
where 1=1
filter_bots()

-- returns (snowflake)
select
...
from
...
where 1=1
and not rlike(useragent, '.*(bot|crawl|slurp|spider|archiv|spinn|sniff|seo|audit|survey|pingdom|worm|capture|(browser|screen)shots|analyz|index|thumb|check|facebook|PingdomBot|PhantomJS|YandexBot|Twitterbot|a_archiver|facebookexternalhit|Bingbot|BingPreview|Googlebot|Baiduspider|360(Spider|User-agent)|semalt).*')
```
{% endraw %}
{% enddocs %}

{% docs macro_stitch_user_identifiers %}
{% raw %}
This macro is used as a post-hook on the sessions table to stitch user identities using the user_mapping table provided.

#### Returns

The update/merge statement to update the `stitched_user_id` column, if enabled.
{% endraw %}
{% enddocs %}

{% docs macro_get_iab_context_fields %}
{% raw %}
This macro is used to extract the fields from the iab enrichment context for each warehouse.

#### Returns

The sql to extract the columns from the iab context, or these columns as nulls.
{% endraw %}
{% enddocs %}

{% docs macro_get_ua_context_fields %}
{% raw %}
This macro is used to extract the fields from the ua enrichment context for each warehouse.

#### Returns

The sql to extract the columns from the ua context, or these columns as nulls.
{% endraw %}
{% enddocs %}

{% docs macro_get_yauaa_context_fields %}
{% raw %}
This macro is used to extract the fields from the yauaa enrichment context for each warehouse.

#### Returns

The sql to extract the columns from the yauaa context, or these columns as nulls.
{% endraw %}
{% enddocs %}

{% docs macro_allow_refresh %}
{% raw %}
This macro is used to determine if a full-refresh is allowed (depending on the environment), using the `snowplow__allow_refresh` variable.

#### Returns
`snowplow__allow_refresh` if environment is not `dev`, `none` otherwise. Returns `none` if the `--full-refresh` flag is not present.

{% endraw %}
{% enddocs %}

{% docs macro_channel_group_query %}
{% raw %}
This macro returns the sql to identify the marketing channel from a url based on the `mkt_source`, `mkt_medium`, and `mkt_campaign` fields. It can be overwritten to use a different logic.

#### Returns
The sql to provide the classification (expected in the form of case when statements).

{% endraw %}
{% enddocs %}

{% docs macro_engaged_session %}
{% raw %}
This macro returns the sql to identify if a session is classed as engaged or not. It can be overwritten to use a different logic. By default any session that has 2 or more page views, more than 2 heartbeats worth of engaged time, or has any conversion events is classed as engaged.

Note that if you are overwriting this macro you have may not have immediate access to all fields in the derived sessions table, and may have to use a table alias to specify the column you wish to use, please see the definition of `snowplow_unified_sessions_this_run` to identify which fields are available at the time of the macro call.

#### Returns
The sql defining an engaged session (true/false).

{% endraw %}
{% enddocs %}

{% docs macro_core_web_vital_results_query %}
{% raw %}
This macro is used to let the user classify the tresholds to be applied for the measurements. Please make sure you set the results you would like the measurements to pass to **`good`** or align it with the `macro_core_web_vital_pass_query` macro.

#### Returns
The sql to provide the logic for the evaluation based on user defined tresholds (expected in the form of case when statements).

{% endraw %}
{% enddocs %}

{% docs macro_core_web_vital_page_groups %}
{% raw %}
This macro is used to let the user classify page urls into page groups.

#### Returns
The sql to provide the classification (expected in the form of case when statements).

{% endraw %}
{% enddocs %}

{% docs macro_content_group_query %}
{% raw %}
This macro is used to let the user classify page urls into content groups.

#### Returns
The sql to provide the classification (expected in the form of case when statements).

{% endraw %}
{% enddocs %}

{% docs macro_core_web_vital_pass_query %}
{% raw %}
This macro is used to let the user define what counts as the overall pass condition for the core web vital measurements.

#### Returns
The sql to provide the logic for the evaluation based on user defined tresholds (expected in the form of case when statements).

{% endraw %}
{% enddocs %}


{% docs macro_field_extractions %}
{% raw %}

This macro is used in the `base_events_this_run` table to extract all the individual fields when the relevant context / sde is enabled, otherwise it returns null values.
#### Returns
The sql to extract the list of fields specified in the context/sde.

{% endraw %}
{% enddocs %}

{% docs macro_config_check %}
{% raw %}

A macro that checks if at least one of the platform enabling variables is valid before the run starts and alerts users in case it happens. It also checks and warns if there are contexts enabled for a platform that will not be used.

{% endraw %}
{% enddocs %}

{% docs macro_unify_fields_query %}
{% raw %}

A macro to produce the sql to create the `unified_events_this_run` table. It's purpose is to add a set of coalesces in case there is a common field to be used both for mobile and web events and it needs to be taken from different sdes / contexts.
#### Returns
The sql to create the `unified_events_this_run` table.

{% endraw %}
{% enddocs %}

{% docs macro_fields %}
{% raw %}

A macro to list all the fields that are extracted from a specific sde /context. Takes table_prefix and column_prefix as an optional argument.

#### Returns
A string of list of fields to be used in a sql statement.

{% endraw %}
{% enddocs %}

{% docs macro_event_counts_string_query %}
{% raw %}

A macro to keep the different ways of calculating event counts per warehouse abstracted away for the sessions table. It loops over every event_name in the run, create a json string / map of the name and counts ONLY if there are events with that name in the session (otherwise retrieves an empty string).
#### Returns
The specific sql to be used for the relevant warehouse to calculate the count of events.

{% endraw %}
{% enddocs %}

{% docs macro_event_counts_query %}
{% raw %}

A macro to keep the different ways of calculating event counts per warehouse abstracted away for the sessions table. It handles the remaining sql transformation that needs to happen in the subsequent cte after the `macro_event_counts_string_query()` is used.

#### Returns
The specific sql to be used for the relevant warehouse to calculate the count of events.

{% endraw %}
{% enddocs %}

{% docs macro_conversion_query %}
{% raw %}

A macro to keep the different ways of calculating conversion fields per warehouse abstracted away for the sessions table.

#### Returns

The sql needed to make the warehosue specific transformations to retrieve the conversion fields.

{% endraw %}
{% enddocs %}

{% docs macro_get_cluster_by_values %}
{% raw %}

A macro to manage the cluster by fields for various models in the package.

#### Returns

The field to cluster by based on model name and target type.

{% endraw %}
{% enddocs %}
