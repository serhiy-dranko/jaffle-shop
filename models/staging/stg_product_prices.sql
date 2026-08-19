select
    product_id,
    product_name,
    price,
    cast(valid_from as timestamp) as valid_from
from {{ source('jaffle_shop', 'raw_product_prices_v2') }}