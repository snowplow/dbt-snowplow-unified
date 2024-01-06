{% docs table_views_this_run %}

This staging table contains all the page and screen views for the given run of the model. It possess all the same columns as `snowplow_unified_page_views`. If building a custom module that requires page/screen view events, this is the table you should reference.

{% enddocs %}


{% docs table_views %}

This derived incremental table contains all historic page/screen views and should be the end point for any analysis or BI tools.

{% enddocs %}


{% docs table_pv_engaged_time %}

This model calculates the time a visitor spent engaged on a given page view. This is calculated using the number of page ping events received for that page view.

{% enddocs %}

{% docs table_scroll_depth %}

This model calculates the horizontal and vertical scroll depth of the visitor on a given page view. Such metrics are useful when assessing engagement on a page view.

{% enddocs %}

{% docs table_screen_summary_metrics %}

This model calculates screen engagement statistics based on the screen summary context entity tracked on mobile apps.
It contains metrics related to the screen time and scroll depth.

{% enddocs %}

{% docs table_session_screen_summary_metrics %}

This model calculates screen time metrics per session based on the screen summary context entity tracked on mobile apps.

{% enddocs %}
