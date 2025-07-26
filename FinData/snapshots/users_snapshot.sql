{%  snapshot users_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='user_id',
        strategy='check',
        check_cols=['first_name','last_name','email','phone_number','country','state','city',
                   'street','postal_code','date_of_birth']
    )
}}

    select
            user_id,
            first_name,
            last_name,
            email,
            concat(repeat('x', len(phone_number)-4), right(phone_number, 4)) as phone_number,
            gender,
            country,
            state,
            city,
            street,
            postal_code,
            date_of_birth,
            age,
            is_active
      from {{ ref('int_users') }}

{% endsnapshot %}