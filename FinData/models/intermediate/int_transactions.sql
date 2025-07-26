

with union_txt as (

    {{
        dbt_utils.union_relations(
            relations=[
                ref('stg_finicity_transactions'),
                ref('stg_plaid_transactions'),
                ref('stg_yodlee_transactions')
            ]
        )
    }}
),

transactions as (
    select 
          transaction_id,
          account_id,
          category,
          merchant,
          amount,
          {{ convert_flexible_date('transaction_date')}} as transaction_date,
          type,
          description,
          tag,
          memo,
          status,
          copy_data_at
    from union_txt

)

select * from transactions