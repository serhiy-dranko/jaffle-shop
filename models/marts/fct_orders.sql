{{ config(materialized='table') }}

select
    ioj.order_id,
    so.customer_id,
    ioj.order_date,
    ioj.total_amount
from {{ ref('int_orders_joined') }} ioj
left join {{ ref('stg_orders') }} so
    on ioj.order_id = so.order_id
