

with yodlee_accounts as (
              select 
                  raw_values:account_id::string as account_id, 
                  raw_values:account_name::string as account_name,
                  raw_values:account_number::string as account_number,
                  raw_values:account_type::string as account_type,
                  raw_values:available_balance_amount::number(10,2) as available_balance,
                  raw_values:available_balance_currency::string as currency,
                  to_timestamp(raw_values:created_timestamp::string) as created_date,
                  raw_values:current_balance::number(10,2) as current_balance,
                  raw_values:institute_id::string as institute_id,
                  raw_values:institute_name::string as institute_name,
                  to_timestamp(raw_values:last_transaction_timestamp::string) as last_transaction_timestamp,
                  to_timestamp(raw_values:last_updated_timestamp::string) as last_updated_timestamp,
                  raw_values:status::string as status,
                  raw_values:user_id::string as user_id,
                  copy_data_at    
              from {{ source('raw_data','yodlee_accounts')}}

)

select * from yodlee_accounts
