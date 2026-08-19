# Jaffle Shop - dbt + Snowflake
 
A learning project that builds a full analytics pipeline on top of the classic **Jaffle Shop** dataset, using **dbt** for transformation and **Snowflake** as the data warehouse.
 
Raw CSVs are seeded into Snowflake, then progressively transformed through staging → intermediate → mart layers, following dbt's standard project structure.
 
---
 
## Tech stack
 
- **Warehouse:** Snowflake
- **Transformation:** dbt (`dbt-snowflake` adapter, v1.12)
- **Language:** SQL + Jinja
---
 
## Pipeline overview

![dbt orders pipeline](https://github.com/serhiy-dranko/jaffle-shop/raw/main/screenshots/dbt_orders_pipeline.png)

## Lineage graph

![dbt lineage graph](https://github.com/serhiy-dranko/jaffle-shop/raw/main/screenshots/dbt_orders_linage_graph.png)

## Data quality & documentation
 
**Generic tests** (defined in `schema.yml` files) cover:
- `unique` / `not_null` on primary keys across staging and mart models
- `accepted_values` on order status columns
- `relationships` - referential integrity between `fct_orders.customer_id` and `dim_customers.customer_id`
 
**Custom singular tests** (in `tests/`) enforce business rules the generic tests can't express:
- `assert_total_amount_not_negative` - order totals must never be negative
- `assert_no_future_order_dates` - orders can't be dated in the future

**Documentation** - every model and key column has a `description`, browsable via the interactive docs site.

## Progress log
 
### Day 1 - Foundation
- Connected dbt to Snowflake (`dbt debug` passing)
- Seeded 4 raw tables (`dbt seed`)
- Declared sources with descriptions and a freshness check
- Built 3 staging models, verified in Snowflake
### Day 2 - Intermediate & mart layers
- Built `int_orders_joined` (orders + payments, aggregated)
- Configured folder-level materializations in `dbt_project.yml` (`view` / `ephemeral` / `table`)
- Built `dim_customers` and `fct_orders`
- Practiced Jinja: `{% set %}` variables, `{% if %}` blocks driven by `var()`
- Verified DAG via `dbt docs generate` / `dbt docs serve`
### Day 3 - Tests, docs, and snapshots
- Added generic tests (unique, not_null, accepted_values, relationships) across staging and mart models
- Wrote 2 custom singular tests for business rules not covered by generic tests
- Added descriptions to models and columns; generated and reviewed the docs lineage graph
- Built product_prices_snapshot, an SCD Type 2 snapshot tracking product price history over time
- Verified snapshot history: changing a price and re-running produces a closed old row (dbt_valid_to set) and a new open row
