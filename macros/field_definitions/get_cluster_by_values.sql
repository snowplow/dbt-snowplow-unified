{% macro get_cluster_by_values(model) %}
    {{ return(adapter.dispatch('get_cluster_by_values', 'snowplow_unified')(model)) }}
{% endmacro %}


{% macro default__get_cluster_by_values(model) %}
    {% if model == 'lifecycle_manifest' %}
        {{ return(snowplow_utils.get_value_by_target_type(bigquery_val=["session_identifier"], snowflake_val=["to_date(start_tstamp)"])) }}
    {% elif model == 'app_errors' %}
        {{ return(snowplow_utils.get_value_by_target_type(bigquery_val=["session_identifier"], snowflake_val=["to_date(derived_tstamp)"])) }}
    {% elif model == 'consent_log' %}
        {{ return(snowplow_utils.get_value_by_target_type(bigquery_val=["event_id","user_identifier"], snowflake_val=["to_date(load_tstamp)"])) }}
    {% elif model == 'conversions' %}
        {{ return(snowplow_utils.get_value_by_target_type(bigquery_val=["user_identifier","session_identifier"], snowflake_val=["to_date(cv_tstamp)"])) }}
    {% elif model == 'web_vitals' %}
        {{ return(snowplow_utils.get_value_by_target_type(bigquery_val=["view_id","user_identifier"], snowflake_val=["to_date(derived_tstamp)"])) }}
    {% elif model == 'sessions' %}
        {{ return(snowplow_utils.get_value_by_target_type(bigquery_val=["user_identifier"], snowflake_val=["to_date(start_tstamp)"])) }}
    {% elif model == 'users' %}
        {{ return(snowplow_utils.get_value_by_target_type(bigquery_val=["user_id","user_identifier"], snowflake_val=["to_date(start_tstamp)"])) }}
    {% elif model == 'users_aggs' %}
        {{ return(snowplow_utils.get_value_by_target_type(bigquery_val=["user_identifier"])) }}
    {% elif model == 'views' %}
        {{ return(snowplow_utils.get_value_by_target_type(bigquery_val=["user_identifier","session_identifier"], snowflake_val=["to_date(start_tstamp)"])) }}
    {% else %}
        {{ exceptions.raise_compiler_error(
      "Snowplow Error: Model "~model~" not defined for cluster by."
      ) }}
    {% endif %}
{% endmacro %}
