
with users as (
      select
            raw_values:user_id::varchar(255) as user_id,
            raw_values:full_name::varchar(255) as full_name,
            raw_values:email::varchar(255) as email,
            raw_values:gender::varchar(255) as gender,
            raw_values:country::varchar(100) as country,
            raw_values:state::varchar(255) as state,
            raw_values:city::varchar(255) as city,
            raw_values:street::varchar(255) as street,
            raw_values:postal_code::varchar(255) as postal_code,
            raw_values:date_of_birth::varchar(255)  as date_of_birth,
            raw_values:phone_number::varchar as phone_number,
            raw_values:is_active::boolean as is_active,
            raw_values:sign_up_timestamp::varchar as sign_up_timestamp,
            raw_values:trail_start::varchar(100)  as trail_start,
            raw_values:trail_end::varchar(255)  as trail_end,
            raw_values:membership_start::varchar  as membership_start,
            raw_values:membership_end::varchar  as membership_end,
            raw_values:membership_plan::varchar as membership_plan,
      from {{ source('raw_data','users')}}
)

select * from users