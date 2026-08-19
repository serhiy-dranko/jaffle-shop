-- Snapshot tracks price history for products
-- target_schema: where the snapshot table lives
-- unique_key: identifies a row across runs
-- strategy: timestamp comparison via updated_at
{% snapshot product_prices_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='product_id',
      strategy='timestamp',
      updated_at='valid_from'
    )
}}

select * from {{ ref('stg_product_prices') }}

{% endsnapshot %}