select
    id as Order_id,
    user_id as customer_id,
    order_date,
    status as order_status
from {{ source('jaffle_shop', 'raw_orders') }}