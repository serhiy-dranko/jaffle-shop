select
    customer_id,
    first_name,
    last_name,
    {{ clean_string('first_name') }} || ' ' || {{ clean_string('last_name') }} as full_name
from {{ ref('stg_customers') }}  