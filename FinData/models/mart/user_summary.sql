with users as (
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
            is_active,
            sign_up_date,
            days_since_signup,
            trail_start,
            trail_end,
            membership_start, 
            membership_end,
            membership_remaining_days,
            membership_plan,
            membership_status,
            is_churn,
            finicity_accounts,
            plaid_accounts,
            yodlee_accounts,
            total_accounts,
            total_transactions,
            oldest_transaction,
            latest_transaction,
            total_amount_spend
      from {{ ref('int_users') }}
)

select * from users