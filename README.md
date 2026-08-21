# Jaffle Shop: dbt + Snowflake
 
A learning project that builds a full analytics pipeline on top of the classic **Jaffle Shop** dataset, using **dbt** for transformation and **Snowflake** as the data warehouse.
 
Raw CSVs are seeded into Snowflake, then progressively transformed through staging → intermediate → mart layers, following dbt's standard project structure.
 
 
## Tools used
 
- **Warehouse:** Snowflake
- **Transformation:** dbt (`dbt-snowflake` adapter, v1.12)
- **Language:** SQL + Jinja

 
## Pipeline overview

![dbt orders pipeline](https://github.com/serhiy-dranko/jaffle-shop/raw/main/screenshots/pipeline_detailed.png)

- **staging** — standardizes column names from raw sources. Materialized as `view`.
- **intermediate** — reusable join/aggregation logic that doesn't belong in a single mart. Materialized as `ephemeral` (inlined as a CTE, never built as a standalone object).
- **marts** — final, business-facing tables queried by analysts/BI tools. `dim_customers` is a `table`; `fct_orders` is `incremental` — only new/changed rows are processed on each run after the first.
- **snapshots** — tracks history of slowly changing data (SCD Type 2), separate from the main model DAG.
Every model is covered by data tests (uniqueness, not-null, referential integrity, accepted values, custom business-rule checks, `dbt_utils` generic tests) and the full project is documented and browsable via the dbt docs site.

## Lineage graph

![dbt lineage graph](https://github.com/serhiy-dranko/jaffle-shop/raw/main/screenshots/dbt_linage_graph.png)

## Project structure
 
```
models/
├── staging/
│   ├── sources.yml          # source declarations + freshness config
│   ├── schema.yml           # descriptions + generic tests
│   ├── stg_customers.sql
│   ├── stg_orders.sql
│   ├── stg_payments.sql
│   └── stg_product_prices.sql
├── intermediate/
│   ├── schema.yml
│   └── int_orders_joined.sql
└── marts/
    ├── schema.yml
    ├── dim_customers.sql
    ├── practice_jinja.sql    # file with practice in Jinja
    └── fct_orders.sql        # incremental, uses dbt_utils surrogate key
macros/
└── custom_macros.sql          # clean_string() — trims + title-cases text
snapshots/
└── product_prices_snapshot.sql
tests/
├── assert_total_amount_not_negative.sql
└── assert_no_future_order_dates.sql
seeds/
├── raw_customers.csv
├── raw_orders.csv
├── raw_payments.csv
└── raw_product_prices_v2.csv
screenshots/
├── dbt_build.png
├── dbt_orders_linage_graph.png
├── fct_orders_linage_graph.png
└── dbt_orders_pipeline.png
presentation/
├── building_dbt_pipeline_in_snowflake.pdf
├── building_dbt_pipeline_in_snowflake.ppx


packages.yml                   # dbt_utils dependency
dbt_project.yml                # Main file for dbt
powershell_log.txt             # Log of whole project
README.md
```
 

## Data quality & documentation
 
**Generic tests** (defined in `schema.yml` files) cover:
- `unique` / `not_null` on primary keys across staging and mart models
- `accepted_values` on order status columns
- `relationships` - referential integrity between `fct_orders.customer_id` and `dim_customers.customer_id`
 
**Custom singular tests** (in `tests/`) enforce business rules the generic tests can't express:
- `assert_total_amount_not_negative` - order totals must never be negative
- `assert_no_future_order_dates` - orders can't be dated in the future

```bash
dbt test
```

**Documentation** - every model and key column has a `description`, browsable via the interactive docs site.

```bash
dbt docs generate
dbt docs serve
```
 
## Snapshots with tracking price history
 
`product_prices_snapshot` captures changes to product prices over time using dbt's SCD Type 2 pattern (`strategy='timestamp'`, keyed on `product_id`). Each run compares current source data against the last snapshot; changed rows get their old version closed (`dbt_valid_to` set) and a new version opened (`dbt_valid_to = null`).
 
```bash
dbt snapshot
```

## Incremental models
 
`fct_orders` is materialized as `incremental`. On the first run it builds the full table. Every run after, `is_incremental()` filters on the source query to only rows newer than what's already in the table and `unique_key='order_id'` ensures matching rows are merged rather than duplicated.
 
```sql
{% if is_incremental() %}
where order_date > (select max(order_date) from {{ this }})
{% endif %}
```
 
Use `--full-refresh` to force a complete rebuild — necessary after changing the model's logic, since incremental runs never recompute rows that are already in the table.
 
```bash
dbt run --select fct_orders --full-refresh
```
 
## Macros
 
`macros/custom_macros.sql` defines `clean_string()` it's a reusable Jinja macro witch trims whitespace and title-cases text:
 
```sql
{{ clean_string('raw_full_name') }} as full_name
```
 
## Packages
 
The project depends on [`dbt_utils`](https://github.com/dbt-labs/dbt-utils) (see `packages.yml`), used for:
- `generate_surrogate_key()` — builds a hashed surrogate key on `fct_orders` from `order_id` + `customer_id`
- `not_constant` / `expression_is_true` — generic tests enforcing that `total_amount` varies across rows and is never negative

```bash
dbt deps
```
 
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
### Day 4 - Incremental models, macros, packages (project complete)
- Converted `fct_orders` to `incremental`, verified two-run behavior (merge vs. full rebuild) and `--full-refresh`
- Wrote a custom macro (`clean_string`) and used it across staging and mart models
- Installed `dbt_utils`; used `generate_surrogate_key()` plus `not_constant` and `expression_is_true` generic tests
- Ran a full `dbt build` (seeds → snapshots → models → tests) clean from an empty schema.
### Day 5 - Presentation day
- Fresh clean run-through
- Re-generate and screenshot docs/DAG
- Finalize README
- Create presentation

### Useful variants
 
```bash
# rebuild everything from scratch
dbt run --full-refresh
 
# run one model + everything downstream of it
dbt run --select stg_orders+
 
# force a full rebuild of the incremental model
dbt run --select fct_orders --full-refresh
 
# explore the lineage graph
dbt docs generate
dbt docs serve
```