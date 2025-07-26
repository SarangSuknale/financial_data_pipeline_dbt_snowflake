{% snapshot institutes_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='institute_id',
        strategy='check',
        check_cols=['institute_id','institute_name']
    )
}}

select
      institute_id,
      institute_name
from {{ ref('institutes') }}

{% endsnapshot %}