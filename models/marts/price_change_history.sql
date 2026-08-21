select
    product_id,
    product_name,
    previous_price,
    current_price,
    current_price - previous_price as price_change_amount,
    round(((current_price - previous_price) / nullif(previous_price, 0)) * 100, 2) as price_change_percentage,
    dbt_valid_from as changed_at,
    datediff('day', dbt_valid_from, coalesce(dbt_valid_to, current_timestamp())) as days_at_this_price
from {{ ref('int_price_changes') }}
where previous_price is not null
order by product_id, changed_at