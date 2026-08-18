
{% set min_order_amount = 1 %}
select
    ioj.order_id,
    so.customer_id,
    ioj.order_date,
    ioj.order_status,
    ioj.total_amount
from {{ ref('int_orders_joined') }} ioj
left join {{ ref('stg_orders') }} so
    on ioj.order_id = so.order_id
where ioj.total_amount >= {{ min_order_amount }}
{% if var('exclude_returned_orders', true) %}
and ioj.order_status not in ('returned', 'return_pending')
{% endif %}