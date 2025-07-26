
with finicity_accounts as (

      {{
            dbt_utils.deduplicate(
                  relation = ref('stg_finicity_accounts'),
                  partition_by = 'account_id',
                  order_by = 'created_date'
            )
      }}

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
    from finicity_accounts
),

plaid_accounts as (
    {{
            dbt_utils.deduplicate(
                  relation = ref('stg_plaid_accounts'),
                  partition_by = 'account_id',
                  order_by = 'created_date'
            )
      }}
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
    from plaid_accounts
),

yodlee_accounts as (
    {{
            dbt_utils.deduplicate(
                  relation = ref('stg_yodlee_accounts'),
                  partition_by = 'account_id',
                  order_by = 'created_date'
            )
      }}

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
    from yodlee_accounts
),

acc_union as (

    select * from fin_accounts
    union all
    select * from p_accounts
    union all
    select * from y_accounts
),

add_src as (

    select *,
           case 
               when account_id in (select account_id from fin_accounts) then 'Finicity'
               when account_id in (select account_id from p_accounts) then 'Plaid'
               when account_id in (select account_id from y_accounts) then 'Yodlee'
               else null
               end as account_source
    from acc_union
)

select * from add_src




