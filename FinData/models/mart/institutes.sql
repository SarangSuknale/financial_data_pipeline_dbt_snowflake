
{{
    config(
        unique_key = 'institute_id',
        incremental_strategy='merge'

    )
}}


with accounts as (
    select
          account_id,  
          institute_id,
          institute_name,
          user_id,
          account_source
    from {{ ref('int_accounts') }}
),

grouped as (
    select 
          institute_id,
          count(distinct user_id) as total_users
    from accounts
    group by institute_id
),

pivoted as (
    select
        institute_id,
        institute_name,
        {% set cols = ['Finicity', 'Yodlee', 'Plaid'] %}

        {% for col in cols %}
            sum(case when account_source = '{{ col }}' then 1 else 0 end) as {{ col|lower }}_accounts_added
            {% if not loop.last %}, {% endif %}
        {% endfor %}

    from accounts
    group by institute_id, institute_name
),

transactions as (
    
    select 
        transaction_id,
        account_id
    from {{ ref('int_transactions') }}

),

acc_txt as (
    select t.transaction_id,
           a.account_id,
           a.institute_id
    from transactions t 
    left join accounts a 
    on a.account_id=t.account_id
),

grouped_acc_txt as (
    select institute_id,
           count(*) as total_transactions
    from acc_txt
    group by institute_id
),

final as (

    select p.institute_id,
        p.institute_name,
        total_users,
        Finicity_accounts_added,
        plaid_accounts_added,
        yodlee_accounts_added,
        (Finicity_accounts_added + plaid_accounts_added + yodlee_accounts_added) as total_accounts_added,
        total_transactions
    from pivoted p
    inner join grouped g
    on p.institute_id=g.institute_id
    inner join grouped_acc_txt gat 
    on p.institute_id=gat.institute_id 
)

select * from final


-- not using is_incremental() because we don't have last_updated column 


