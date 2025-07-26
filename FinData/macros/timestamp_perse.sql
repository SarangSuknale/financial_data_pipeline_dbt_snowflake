{% macro convert_flexible_timestamp(timestamp_str_column) %}
    case
        when regexp_like(sign_up_timestamp, '^\\d{4}[-/]\\d{2}[-/]\\d{2} \\d{2}:\\d{2}:\\d{2}$') then
            try_to_timestamp(sign_up_timestamp, 'YYYY-MM-DD HH24:MI:SS')

        when regexp_like(sign_up_timestamp, '^\\d{2}[-/]\\d{2}[-/]\\d{4} \\d{2}:\\d{2}$') then
            try_to_timestamp(sign_up_timestamp, 'DD/MM/YYYY HH24:MI')

        when regexp_like(sign_up_timestamp, '^\\d{2}[-/]\\d{2}[-/]\\d{4} \\d{1}:\\d{2}$') then
            try_to_timestamp(sign_up_timestamp, 'DD/MM/YYYY HH24:MI')

        else null
    end
{% endmacro %}
