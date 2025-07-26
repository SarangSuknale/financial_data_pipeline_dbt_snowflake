
{{
    config(
        unique_key = 'account_id',
        incremental_strategy='merge'

    )
}}

with accounts_deduplicate as (

      {{
            dbt_utils.deduplicate(
                  relation = ref('int_accounts'),
                  partition_by = 'account_id',
                  order_by = 'created_date'
            )
      }}

),

all_accounts as (
    select *
    from accounts_deduplicate

),

accounts as (
    select 
          account_id,
          account_name,
          concat(repeat('x', (len(account_number)-4)), right(account_number,4)) as account_number,
          account_type,
          available_balance,
          currency,
          created_date,
          current_balance,
          institute_id,
          institute_name,
          last_transaction_timestamp,
          days_since_last_transaction,
          last_updated_timestamp,
          days_since_last_update,
          status,
          user_id,
          account_age,
          balance_difference,
          is_overdrawn,
          account_source,
          copy_data_at
    from all_accounts
),

 final as (
    select *
    from accounts
    where 1 = 1 
    {% if is_incremental() %}
    and last_updated_timestamp >= dateadd('day', -5, current_timestamp())
    {% endif %}

    {% if target.name=='testing' %}
    and last_updated_timestamp >= dateadd('month', -1, current_timestamp())
    {% endif %}
)

select * from final
