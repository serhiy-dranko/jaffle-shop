select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.order_status,
    sum(p.amount) as total_amount

from {{ ref('stg_orders') }} as o
left join {{ ref('stg_payments') }} as p
    on o.order_id = p.order_id
group by 1, 2, 3, 4