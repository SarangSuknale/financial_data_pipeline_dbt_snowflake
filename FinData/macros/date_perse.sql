{% macro convert_flexible_date(date_str_column) %}
        case
            when regexp_like(trim({{date_str_column}}), '^\\d{4}[-]\\d{2}[-]\\d{2}$') then
            try_to_date(trim({{date_str_column}}), 'YYYY-MM-DD')

            when regexp_like(trim({{date_str_column}}), '^\\d{2}[/]\\d{2}[/]\\d{4}$') then
            try_to_date(trim({{date_str_column}}), 'DD/MM/YYYY')

        else null
        end 
{% endmacro %}