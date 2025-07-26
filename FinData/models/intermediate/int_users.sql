
with users as (
    {{
        dbt_utils.deduplicate(
            relation=ref('stg_users'),
            partition_by='user_id',
            order_by='sign_up_timestamp'
        )
    }}
),

users_2 as (
        select 
            user_id,
            split_part(full_name,' ', 1) as first_name,
            split_part(full_name,' ', 2) as last_name,
            email,
            gender,
            phone_number,
            country,
            state,
            city,
            street,
            postal_code,
            {{ convert_flexible_date('date_of_birth')}} as date_of_birth,
            is_active,
            {{ convert_flexible_timestamp('sign_up_timestamp') }} as sign_up_date,
            {{ convert_flexible_date('trail_start')}} as trail_start,
            {{ convert_flexible_date('trail_end')}} as trail_end,
            (case when membership_start='' then null else {{ convert_flexible_date('membership_start')}} end) as membership_start,
            (case when membership_end='' then null else {{ convert_flexible_date('membership_end')}} end) as membership_end,
            (case when membership_plan='' then null else membership_plan end) as membership_plan
        from users
),

users_info as (
            select 
                user_id,
                first_name,
                last_name,
                email,
                phone_number,
                gender,
                country,
                state,
                city,
                street,
                postal_code,
                date_of_birth,
                datediff('year', date_of_birth, current_date()) as age,
                is_active,
                sign_up_date,
                datediff('day', sign_up_date, current_timestamp()) as days_since_signup,
                trail_start,
                trail_end,
                membership_start, 
                membership_end,
                case
                    when membership_end >= current_date() then datediff('day', current_date(), membership_end)
                    when membership_end <= current_date() then 0
                    else null
                end as membership_remaining_days,
                membership_plan,
                case
                    when current_date() between membership_start and membership_end then 'active'
                    when current_date() between trail_start and trail_end then 'trail'
                    when current_date() > membership_end then 'cancelled'
                    else null
                end as membership_status,
                case
                    when membership_end is null then null 
                    when membership_end < current_date() then 'yes' 
                    else 'no'
                end as is_churn
            from users_2
),



fin_accounts as (
    select 
          account_id,
          account_name,
          account_number,
          account_type,
          available_balance,
          currency,
          created_date,
          current_balance,
          institute_id,
          institute_name,
          last_transaction_timestamp,
          last_updated_timestamp,
          status,
          user_id,
          datediff('day', created_date, current_timestamp()) as account_age,
          datediff('day', last_transaction_timestamp, current_timestamp()) as days_since_last_transaction,
          datediff('day', last_updated_timestamp, current_timestamp()) as days_since_last_update,
          (current_balance - available_balance) as balance_difference,
          (case when current_balance < 0 then 'Yes' else 'No' end) as is_overdrawn,
          copy_data_at
    from {{ ref('stg_finicity_accounts') }}
),

p_accounts as (
    select 
          account_id,
          account_name,
          account_number,
          account_type,
          available_balance,
          currency,
          created_date,
          current_balance,
          institute_id,
          institute_name,
          last_transaction_timestamp,
          last_updated_timestamp,
          status,
          user_id,
          datediff('day', created_date, current_timestamp()) as account_age,
          datediff('day', last_transaction_timestamp, current_timestamp()) as days_since_last_transaction,
          datediff('day', last_updated_timestamp, current_timestamp()) as days_since_last_update,
          (current_balance - available_balance) as balance_difference,
          (case when current_balance < 0 then 'Yes' else 'No' end) as is_overdrawn,
          copy_data_at
    from {{ ref('stg_plaid_accounts') }}
),

y_accounts as (
    select 
          account_id,
          account_name,
          account_number,
          account_type,
          available_balance,
          currency,
          created_date,
          current_balance,
          institute_id,
          institute_name,
          last_transaction_timestamp,
          last_updated_timestamp,
          status,
          user_id,
          datediff('day', created_date, current_timestamp()) as account_age,
          datediff('day', last_transaction_timestamp, current_timestamp()) as days_since_last_transaction,
          datediff('day', last_updated_timestamp, current_timestamp()) as days_since_last_update,
          (current_balance - available_balance) as balance_difference,
          (case when current_balance < 0 then 'Yes' else 'No' end) as is_overdrawn,
          copy_data_at
    from {{ ref('stg_yodlee_accounts') }}
),

all_accounts as (

    select * from fin_accounts
    union all
    select * from p_accounts
    union all
    select * from y_accounts
),


accounts as (
    select 
          *, 
          case
               when account_id in (select account_id from fin_accounts) then 'Finicity'
               when account_id in (select account_id from p_accounts) then 'Plaid'
               when account_id in (select account_id from y_accounts) then 'Yodlee'
               else null
               end as account_source
    from all_accounts
),

transactions as (
    {{
        dbt_utils.union_relations(
            relations = [
                ref('stg_finicity_transactions'),
                ref('stg_plaid_transactions'),
                ref('stg_yodlee_transactions')
            ]
        )
    }}
),



-- fin_transactions as (
--     select *
--     from {{ ref('stg_finicity_transactions') }}
-- ),

-- p_transactions as (
--     select * 
--     from {{ ref('stg_plaid_transactions') }}
-- ),

-- y_transactions as (
--     select *
--     from {{ ref('stg_yodlee_transactions') }}
-- ),

-- transactions as (
--     select * from fin_transactions
--     union all
--     select * from p_transactions
--     union all
--     select * from y_transactions
-- ),

user_txt as (
    select
          u.*,
          COUNT(DISTINCT CASE WHEN a.account_source = 'Finicity' THEN a.account_id END) AS finicity_accounts,
          COUNT(DISTINCT CASE WHEN a.account_source = 'Plaid' THEN a.account_id END) AS plaid_accounts,
          COUNT(DISTINCT CASE WHEN a.account_source = 'Yodlee' THEN a.account_id END) AS yodlee_accounts,
          COUNT(DISTINCT a.account_id) AS total_accounts,
          COUNT(DISTINCT t.transaction_id) AS total_transactions,
          sum(t.amount) as total_amount_spend,
          min(t.transaction_date) as oldest_transaction,
          max(t.transaction_date) as latest_transaction
    from users_info as u
    left join accounts a on a.user_id = u.user_id
    left join transactions t on t.account_id = a.account_id
    group by 
        u.user_id,
        u.first_name,
        u.last_name,
        u.email,
        u.phone_number,
        u.gender,
        u.country,
        u.state,
        u.city,
        u.street,
        u.postal_code,
        u.date_of_birth,
        u.age,
        u.is_active,
        u.sign_up_date,
        u.days_since_signup,
        u.trail_start,
        u.trail_end,
        u.membership_start, 
        u.membership_end,
        u.membership_remaining_days,
        u.membership_plan,
        u.membership_status,
        u.is_churn
)

select * from user_txt


