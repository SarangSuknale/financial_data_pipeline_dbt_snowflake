select
      date_trunc('month', sign_up_date) as signup_month,
      count(*) as user_count
from {{ ref('user_summary')}}
group by 1
order by 1
