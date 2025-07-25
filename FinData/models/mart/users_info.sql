
{{
    config(
        unique_key = 'user_id',
        incremental_strategy='merge'

    )
}}

with users as (
      select
            user_id,
            first_name,
            last_name,
            email,
            concat(repeat('x', len(phone_number)-4), right(phone_number, 4)) as phone_number,
            gender,
            sign_up_date,
            country,
            state,
            city,
            street,
            postal_code,
            date_of_birth,
            age,
            is_active
      from {{ ref('int_users') }}
)

select * from users
{% if is_incremental() and target.name=='testing' %}
where sign_up_date >= dateadd('month', -1, current_date())
{% endif %}