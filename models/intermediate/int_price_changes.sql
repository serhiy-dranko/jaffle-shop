select
    product_id,
    product_name,
    price as current_price,
    lag(price) over (
        partition by product_id
        order by dbt_valid_from
    ) as previous_price,
    dbt_valid_from,
    dbt_valid_to
from {{ ref('product_prices_snapshot') }}