{{ config(
        materialized='incremental', 
        unique_key='order_id'
) }}

with joined as (
    select
        ioj.order_id,
        so.customer_id,
        ioj.order_date,
        ioj.total_amount
    from {{ ref('int_orders_joined') }} ioj
    left join {{ ref('stg_orders') }} so
        on ioj.order_id = so.order_id
)

select
    {{ dbt_utils.generate_surrogate_key(['order_id', 'customer_id']) }} as surrogate_key,
    order_id,
    customer_id,
    order_date,
    total_amount
from joined

{% if is_incremental() %}
where order_date > (select max(order_date) from {{ this }})
{% endif %}