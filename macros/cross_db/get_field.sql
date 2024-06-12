{% macro spark__get_field(column_name, field_name, table_alias = none, type = none, array_index = none, relation = none) %}
{% if '*' in column_name %}
    {% do exceptions.raise_compiler_error('Wildcard schema versions are only supported for Bigquery, they are not supported for ' ~ target.type) %}
{% else %}
    cast({%- if table_alias -%}{{table_alias}}.{%- endif -%}{{column_name}}{%- if array_index is not none -%}[{{array_index}}]{%- endif -%}.{{field_name}}{%- if type %} as {{type}}{%- endif -%})
{% endif %}
{% endmacro %}
