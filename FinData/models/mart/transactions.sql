
{{
    config(
        incremental_strategy='merge',
        unique_key='transaction_id'
    )
}}

with deduplicated_transactions as (
    {{
        dbt_utils.deduplicate(
            relation=ref('int_transactions'),
            partition_by='transaction_id',
            order_by='transaction_date'
        )
    }}
),

all_transactions as (
    select *
    from deduplicated_transactions
),

accounts_deduplicate as (

      {{
            dbt_utils.deduplicate(
                  relation = ref('int_accounts'),
                  partition_by = 'account_id',
                  order_by = 'created_date'
            )
      }}

),

accounts as (
    select *
    from accounts_deduplicate
),

transactions as (
    select 
          t.transaction_id,
          t.account_id,
          t.category,
          t.merchant,
          t.amount,
          t.transaction_date,
          t.type,
          a.account_source as transaction_source,
          t.description,
          t.tag,
          t.memo,
          t.status,
          a.institute_name,
          t.copy_data_at
    from all_transactions as t
    left join accounts as a
    on a.account_id=t.account_id
    order by t.transaction_date desc
),

final as (

    select * from transactions
    where 1=1
    {% if is_incremental() %}
     and transaction_date >= dateadd('day', -2, current_date())
    {% endif %}
    {% if target.name=='testing' %}
    and transaction_date >= dateadd('month', -1, current_date())
    {% endif %}
)

select * from final






-- final_data as (

--     select * from transactions t1

--     {% if is_incremental() %}

--     left join {{ this }} t2
--         on t1.transaction_id=t2.transaction_id
--         and t2.transaction_date >= dateadd('day', -5, current_date())
--     where t2.transaction_id IS NULL and

--     {% endif %}

-- )

