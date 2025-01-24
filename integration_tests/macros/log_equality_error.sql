{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Personal and Academic License Version 1.0,
and you may not use this file except in compliance with the Snowplow Personal and Academic License Version 1.0.
You may obtain a copy of the Snowplow Personal and Academic License Version 1.0 at https://docs.snowplow.io/personal-and-academic-license-1.0/
#}

/* example how to use it: 
  
  echo "Debugging help:"
  eval "dbt run-operation log_equality_error --args '{"table_to_check": "web_vital_measurements"}' --target $db" || exit 1;

*/

{% macro log_equality_error(table_to_check) %}

    {% if target.type == "redshift" %}
        {% set diff_query %}
        
            {% if table_to_check == "web_vital_measurements" %}

                with a as (
                    select * from {{ ref('snowplow_unified_web_vital_measurements_actual') }}
                ),

                b as (
                    select * from {{ ref('snowplow_unified_web_vital_measurements_expected_stg') }}
                ),

                a_minus_b as (

                    select "compound_key", "measurement_type", "page_url", "device_class", "geo_country", "country", "time_period", "view_count", round(cast("lcp_75p" as numeric(28,6)),3) as "lcp_75p", round(cast("fid_75p" as numeric(28,6)),3) as "fid_75p", round(cast("cls_75p" as numeric(28,6)),3) as "cls_75p", round(cast("ttfb_75p" as numeric(28,6)),3) as "ttfb_75p", round(cast("inp_75p" as numeric(28,6)),3) as "inp_75p", "lcp_result", "fid_result", "cls_result", "ttfb_result", "inp_result", "passed" from a
                    except
                    select "compound_key", "measurement_type", "page_url", "device_class", "geo_country", "country", "time_period", "view_count", round(cast("lcp_75p" as numeric(28,6)),3) as "lcp_75p", round(cast("fid_75p" as numeric(28,6)),3) as "fid_75p", round(cast("cls_75p" as numeric(28,6)),3) as "cls_75p", round(cast("ttfb_75p" as numeric(28,6)),3) as "ttfb_75p", round(cast("inp_75p" as numeric(28,6)),3) as "inp_75p", "lcp_result", "fid_result", "cls_result", "ttfb_result", "inp_result", "passed" from b

                ),

                b_minus_a as (

                    select "compound_key", "measurement_type", "page_url", "device_class", "geo_country", "country", "time_period", "view_count", round(cast("lcp_75p" as numeric(28,6)),3) as "lcp_75p", round(cast("fid_75p" as numeric(28,6)),3) as "fid_75p", round(cast("cls_75p" as numeric(28,6)),3) as "cls_75p", round(cast("ttfb_75p" as numeric(28,6)),3) as "ttfb_75p", round(cast("inp_75p" as numeric(28,6)),3) as "inp_75p", "lcp_result", "fid_result", "cls_result", "ttfb_result", "inp_result", "passed" from b
                    except
                    select "compound_key", "measurement_type", "page_url", "device_class", "geo_country", "country", "time_period", "view_count", round(cast("lcp_75p" as numeric(28,6)),3) as "lcp_75p", round(cast("fid_75p" as numeric(28,6)),3) as "fid_75p", round(cast("cls_75p" as numeric(28,6)),3) as "cls_75p", round(cast("ttfb_75p" as numeric(28,6)),3) as "ttfb_75p", round(cast("inp_75p" as numeric(28,6)),3) as "inp_75p", "lcp_result", "fid_result", "cls_result", "ttfb_result", "inp_result", "passed" from a

                ),

                unioned as (

                    select 'a_minus_b' as which_diff, a_minus_b.* from a_minus_b
                    union all
                    select 'b_minus_a' as which_diff, b_minus_a.* from b_minus_a

                )

                select * from unioned
            
            {% else %}
            
                {{ exceptions.raise_compiler_error("Not a valid table to check.") }}

            {% endif %}

        {% endset %}

        {% set result = run_query(diff_query) %}
        

        {% if execute %}
            {% for row in result %}
                {% set row_dict = dict(zip(row.keys(), row.values())) %}
                {% for key, value in row_dict.items() %}
                    {% do log(key ~ ': ' ~ value, info=True) %}
                {% endfor %}
                {% do log('---', info=True) %}
            {% endfor %}
        
        {% endif %}
        
    {% endif %}

{% endmacro %}







