{% macro spark__base_create_snowplow_events_this_run(sessions_this_run_table, session_identifiers, session_sql, session_timestamp, derived_tstamp_partitioned, days_late_allowed, max_session_days, app_ids, snowplow_events_database, snowplow_events_schema, snowplow_events_table, entities_or_sdes, custom_sql) %}
    {%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(ref(sessions_this_run_table),
                                                                            'start_tstamp',
                                                                            'end_tstamp') %}
    {% set sessions_this_run = ref(sessions_this_run_table) %}
    {% set snowplow_events = api.Relation.create(database=snowplow_events_database, schema=snowplow_events_schema, identifier=snowplow_events_table) %}

    {% set events_this_run_query %}
        with identified_events AS (
            select
                {% if session_sql %}
                    {{ session_sql }} as session_identifier,
                {% else -%}
                    COALESCE(
                        {% for identifier in session_identifiers %}
                            {%- if identifier['schema']|lower != 'atomic' -%}
                                {{ snowplow_utils.get_field(identifier['schema'], identifier['field'], 'e', dbt.type_string(), 0, snowplow_events) }}
                            {%- else -%}
                                e.{{identifier['field']}}
                            {%- endif -%}
                            ,
                        {%- endfor -%}
                        NULL
                    ) as session_identifier,
                {%- endif %}
                e.*,
                row_number() over (partition by event_id order by {{ session_timestamp }}, dvce_created_tstamp) as event_id_dedupe_index

            from {{ snowplow_events }} e

        )

        select
            a.*
            ,b.user_identifier -- take user_identifier from manifest. This ensures only 1 domain_userid per session.
            {% if custom_sql %}
                , {{ custom_sql }}
            {% endif %}

        from identified_events as a
        inner join {{ sessions_this_run }} as b
        on a.session_identifier = b.session_identifier

        where a.{{ session_timestamp }} <= {{ snowplow_utils.timestamp_add('day', max_session_days, 'b.start_tstamp') }}
        and a.dvce_sent_tstamp <= {{ snowplow_utils.timestamp_add('day', days_late_allowed, 'a.dvce_created_tstamp') }}
        and a.{{ session_timestamp }} >= {{ lower_limit }}
        and a.{{ session_timestamp }} <= {{ upper_limit }}
        and a.{{ session_timestamp }} >= b.start_tstamp -- deal with late loading events

        {% if derived_tstamp_partitioned and target.type == 'bigquery' | as_bool() %}
            and a.derived_tstamp >= {{ snowplow_utils.timestamp_add('hour', -1, lower_limit) }}
            and a.derived_tstamp <= {{ upper_limit }}
        {% endif %}

        and {{ snowplow_utils.app_id_filter(app_ids) }}

        and a.event_id_dedupe_index = 1
    {% endset %}

    {{ return(events_this_run_query) }}

{% endmacro %}
