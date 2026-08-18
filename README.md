# Jaffle Shop — dbt + Snowflake
 
A learning project that builds a full analytics pipeline on top of the classic **Jaffle Shop** dataset, using **dbt** for transformation and **Snowflake** as the data warehouse.
 
Raw CSVs are seeded into Snowflake, then progressively transformed through staging → intermediate → mart layers, following dbt's standard project structure.
 
---
 
## Tech stack
 
- **Warehouse:** Snowflake
- **Transformation:** dbt (`dbt-snowflake` adapter, v1.12)
- **Language:** SQL + Jinja
---
 
## Pipeline overview

<img width="1413" height="706" alt="Screenshot 2026-08-18 140337" src="https://github.com/user-attachments/assets/4726d4ab-8b47-4a1d-b439-37d47e75d478" />

## Lineage graph

<img width="1354" height="480" alt="Screenshot 2026-08-18 140842" src="https://github.com/user-attachments/assets/848c8573-4922-41aa-8131-ac69c3ecc88d" />

## Progress log
 
### Day 1 — Foundation
- Connected dbt to Snowflake (`dbt debug` passing)
- Seeded 4 raw tables (`dbt seed`)
- Declared sources with descriptions and a freshness check
- Built 3 staging models, verified in Snowflake
### Day 2 — Intermediate & mart layers
- Built `int_orders_joined` (orders + payments, aggregated)
- Configured folder-level materializations in `dbt_project.yml` (`view` / `ephemeral` / `table`)
- Built `dim_customers` and `fct_orders`
- Practiced Jinja: `{% set %}` variables, `{% if %}` blocks driven by `var()`
- Verified DAG via `dbt docs generate` / `dbt docs serve`

