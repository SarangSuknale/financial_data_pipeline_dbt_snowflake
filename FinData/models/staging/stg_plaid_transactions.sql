
with plaid_transactions as (
                  select
                        raw_values:account_id::string as account_id,
                        raw_values:amount::number(10,2) as amount,
                        raw_values:category::string as category,
                        raw_values:description::string as description,
                        raw_values:id::string as transaction_id,
                        raw_values:memo::string as memo,
                        raw_values:merchant::string as merchant,
                        raw_values:status::string as status,
                        raw_values:tag::string as tag,
                        to_date(raw_values:transaction_date::string, 'DD/MM/YYYY') as transaction_date,
                        raw_values:type::string as type,
                        copy_data_at
                  from {{ source('raw_data','plaid_transactions')}}
)

select * from plaid_transactions


