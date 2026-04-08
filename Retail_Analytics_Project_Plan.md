# Global Retail Intelligence Pipeline

## Objective

End-to-end retail analytics project demonstrating the On Analytics tech stack: **DuckDB + dbt + Hex + AI Agent**. Built on a 1.4M-row Nike global catalog dataset across 45 markets.

---

## Dataset

Global_Nike.csv - 1.4M rows, 45 markets, 850mb size

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| snapshot_date | str/date | The specific date when the data record was captured from the Nike website. |
| country_code | str | "Two-letter ISO country code (e.g., US, FR, JP) representing the market." |
| product_name | str | The customer-facing display name of the product. |
| model_number | str | "The Nike style code or base model identifier (e.g., NIKGD001)." |
| currency | str | "The local currency code for the specific market (e.g., USD, EUR)." |
| price_local | float64 | The original list price in the local currency. |
| sale_price_local | float64 | The current discounted price in local currency (NaN if no sale is active). |
| gender_segment | str | "The target demographic for the product (e.g., MEN, WOMEN, KIDS)." |
| size_label | str | "The size label displayed on the storefront (e.g., XL, 10.5, 20L)." |
| category | str | "High-level product classification (e.g., APPAREL, FOOTWEAR)." |
| subcategory | str | "Detailed product description or sub-type (e.g., Tie-Dye Crew-Neck Sweatshirt)." |
| product_id | str | Unique internal UUID for the product entity. |
| sku | str | Unique Stock Keeping Unit (SKU) identifier for a specific style-color-size. |
| style_color | str | "The specific code combining style and colorway (e.g., NIKGD001-TYD)." |
| brand_name | str | "The primary brand under the Nike umbrella (e.g., Nike, Jordan, Converse)." |
| color_name | str | "The descriptive name of the product colorway (e.g., Multi-Color, Black/White)." |
| size_count | float64 | The total number of size options listed for this product. |
| available_size_count | float64 | The number of sizes currently available in stock. |
| available | bool | Boolean flag indicating if the specific SKU is currently available. |
| availability_level | str | "Status code for inventory (e.g., OOS for Out of Stock, LOW_STOCK)." |
| available_market | bool | Indicates if the product is generally active/available in that country's market. |
| in_stock | bool | Boolean flag indicating if the product is currently ready for shipment. |
| discount_pct | float64 | The percentage of discount applied (calculated from local and sale price). |
| employee_price | float64 | Special pricing available for Nike employees (often null in public data). |
| product_url | str | Direct web link to the product's landing page on Nike.com. |
| canonical_url | str | The master SEO-friendly URL for the product. |
| image_url | str | Direct link to the primary high-resolution product image hosted by Nike. |
| gtin | float64 | Global Trade Item Number (standardized barcode number). |
| stock_keeping_unit_id | float64 | Internal system ID for the SKU. |
| catalog_sku_id | str | Internal catalog mapping ID for the SKU. |
| nike_size | str | Standardized internal Nike size code. |
| localized_size | str | "Size label converted to local market standards (e.g., UK vs US vs EU sizes)." |
| size_conversion_id | str | ID used for mapping sizes across different regional standards. |
| sport_tags | str | "Labels identifying the sport or activity (e.g., Football, Running, Lifestyle)." |
| record_source | str | "Identifier for the origin of the data row (e.g., ""thread_exact"")." |

## Architecture

```
Global_Nike.csv (850MB, 1.4M rows)
        │
        ▼
┌──────────────────┐
│      DuckDB       │  ← Embedded Analytical Database
│   (retail.duckdb)  │     No server, no Docker
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│      dbt Core     │  ← Data Modeling & Transformation
│  staging → marts  │     (dbt-duckdb adapter)
└────────┬─────────┘
         │
         ▼
┌────────────────┐
│      Hex        │  ← Dashboard & Notebook
│   (free tier)   │     Native DuckDB support
└────────┬───────┘
         │
         ▼
┌──────────────────┐
│  AI Analyst Agent │  ← Python + Claude API
│  (NL → SQL → NL) │     Queries DuckDB directly
└──────────────────┘
```

---

## Repository Structure

```
retail-intelligence/
├── README.md
├── .gitignore
├── data/
│   └── Global_Nike_sample.csv           # 10K row sample for quick testing
│
├── load/
│   └── load_to_duckdb.py               # CSV → DuckDB (one command)
│
├── dbt_retail/
│   ├── dbt_project.yml
│   ├── profiles.yml.example
│   ├── models/
│   │   ├── staging/
│   │   │   ├── _sources.yml
│   │   │   ├── stg_nike_catalog.sql
│   │   │   └── schema.yml
│   │   ├── intermediate/
│   │   │   ├── int_product_metrics.sql
│   │   │   └── schema.yml
│   │   └── marts/
│   │       ├── mart_market_performance.sql
│   │       ├── mart_merchandising_mix.sql
│   │       └── schema.yml
│   ├── tests/
│   │   └── assert_positive_prices.sql
│   ├── macros/
│   │   └── discount_tier.sql
│   └── exposures/
│       └── exposures.yml
│
├── agent/
│   ├── retail_agent.py
│   ├── prompts.py
│   └── requirements.txt
│
└── sql/
    └── advanced_queries.sql              # Standalone showcase queries
```

---

## Tech Stack & Cost

| Component       | Tool                   | Cost    |
|-----------------|------------------------|---------|
| Warehouse       | DuckDB (embedded, local file) | Free |
| Transformation  | dbt Core (dbt-duckdb)  | Free    |
| Dashboard       | Hex (free tier)        | Free    |
| AI Agent        | Python + Claude API    | ~$1-2 for demo usage |
| Version Control | GitHub                 | Free    |

---

## Step-by-Step Build Guide

### Phase 1: DuckDB Setup (Day 1, ~30min)

No server, no Docker, no config. Just a file.

**1.1 — Install**
```bash
pip install duckdb
```

**1.2 — Load Data**

```python
# load/load_to_duckdb.py
import duckdb

con = duckdb.connect("retail.duckdb")

# DuckDB reads CSV natively — no chunking, no pandas needed
con.execute("""
    CREATE SCHEMA IF NOT EXISTS retail_raw;
    CREATE TABLE retail_raw.nike_catalog AS
    SELECT * FROM read_csv_auto('data/Global_Nike.csv');
""")

print(con.execute("SELECT COUNT(*) FROM retail_raw.nike_catalog").fetchone())
# Expected: (1447795,)
con.close()
```

That's it. 800MB CSV loaded in seconds, not minutes.

**1.3 — Validate**
```sql
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT country_code) AS markets,
       COUNT(DISTINCT product_id) AS products
FROM retail_raw.nike_catalog;
-- Expected: ~1,447,795 rows | 45 markets
```

---

### Phase 2: Advanced SQL Showcase

Write in `sql/advanced_queries.sql`. DuckDB supports both PostgreSQL and BigQuery-style syntax — window functions, CTEs, `FILTER`, `PERCENTILE_CONT` all work natively.

> **DuckDB SQL advantages:** supports `SAFE_DIVIDE`-like behavior via `NULLIF`, Postgres-style `FILTER (WHERE ...)`, and BigQuery-style `PERCENTILE_CONT`. Closest to BigQuery of any local DB.

**2.1 — Window Functions: Discount Ranking by Market**
```sql
WITH ranked AS (
  SELECT
    country_code,
    category,
    product_name,
    discount_pct,
    ROW_NUMBER() OVER (
      PARTITION BY country_code, category
      ORDER BY discount_pct DESC
    ) AS discount_rank,
    AVG(discount_pct) OVER (
      PARTITION BY country_code
    ) AS market_avg_discount
  FROM retail_raw.nike_catalog
  WHERE discount_pct > 0
)
SELECT *
FROM ranked
WHERE discount_rank <= 5
ORDER BY country_code, category, discount_rank;
```

**2.2 — CTEs: Assortment & Availability KPIs**
```sql
WITH size_availability AS (
  SELECT
    country_code,
    product_id,
    product_name,
    category,
    available_size_count / NULLIF(size_count, 0) AS size_fill_rate
  FROM retail_raw.nike_catalog
  WHERE size_count > 0
),

product_scoring AS (
  SELECT
    country_code,
    category,
    COUNT(DISTINCT product_id) AS assortment_width,
    AVG(size_fill_rate) AS avg_fill_rate,
    COUNT(*) FILTER (WHERE size_fill_rate = 1.0) AS fully_stocked_products
  FROM size_availability
  GROUP BY country_code, category
)

SELECT
  country_code,
  category,
  assortment_width,
  ROUND(avg_fill_rate * 100, 1) AS fill_rate_pct,
  fully_stocked_products,
  ROUND(fully_stocked_products * 100.0 / NULLIF(assortment_width, 0), 1) AS full_stock_pct
FROM product_scoring
ORDER BY assortment_width DESC;
```

**2.3 — Price Architecture Analysis**
```sql
SELECT
  country_code,
  category,
  gender_segment,
  COUNT(DISTINCT product_id) AS products,
  ROUND(AVG(price_local), 2) AS avg_full_price,
  ROUND(AVG(sale_price_local), 2) AS avg_sale_price,
  ROUND(AVG(discount_pct), 1) AS avg_discount_pct,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_local) AS median_price,
  COUNT(*) FILTER (WHERE discount_pct > 0) AS on_sale_count,
  ROUND(
    COUNT(*) FILTER (WHERE discount_pct > 0) * 100.0 / NULLIF(COUNT(*), 0), 1
  ) AS promo_penetration_pct
FROM retail_raw.nike_catalog
GROUP BY country_code, category, gender_segment
ORDER BY products DESC;
```

---

### Phase 3: dbt Models (Day 2, ~3h)

**3.1 — Init Project**
```bash
pip install dbt-duckdb
dbt init dbt_retail
```

**profiles.yml.example:**
```yaml
dbt_retail:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: ../retail.duckdb    # Relative to dbt_retail/ dir
      schema: dbt_retail
      threads: 4
```

**3.2 — Sources**

```yaml
# models/staging/_sources.yml
version: 2

sources:
  - name: retail_raw
    schema: retail_raw
    freshness:
      warn_after: {count: 3, period: day}
      error_after: {count: 7, period: day}
    loaded_at_field: "CAST(snapshot_date AS TIMESTAMP)"
    tables:
      - name: nike_catalog
        description: "Raw Nike global catalog — 1.4M SKU-level rows across 45 markets"
```

Run `dbt source freshness` to check. This signals to On's team: *"I think about data quality and SLA monitoring, not just building models."*

**3.3 — Staging: Clean & Type**

```sql
-- models/staging/stg_nike_catalog.sql
WITH source AS (
    SELECT * FROM {{ source('retail_raw', 'nike_catalog') }}
)

SELECT
    CAST(snapshot_date AS DATE)                     AS snapshot_date,
    UPPER(TRIM(country_code))                       AS country_code,
    TRIM(product_name)                              AS product_name,
    model_number,
    currency,
    ROUND(price_local, 2)                           AS full_price,
    ROUND(sale_price_local, 2)                      AS sale_price,
    LOWER(TRIM(gender_segment))                     AS gender,
    category,
    subcategory,
    product_id,
    sku,
    brand_name,
    CAST(size_count AS INTEGER)                     AS total_sizes,
    CAST(available_size_count AS INTEGER)            AS available_sizes,
    available,
    in_stock,
    ROUND(discount_pct, 2)                          AS discount_pct,
    {{ discount_tier('discount_pct') }}              AS discount_tier,
    sport_tags
FROM source
WHERE price_local > 0
```

**3.4 — Macro: Discount Tier**

```sql
-- macros/discount_tier.sql
{% macro discount_tier(column) %}
    CASE
        WHEN {{ column }} = 0                        THEN 'Full Price'
        WHEN {{ column }} BETWEEN 0.01 AND 0.20      THEN 'Light (1-20%)'
        WHEN {{ column }} BETWEEN 0.21 AND 0.40      THEN 'Medium (21-40%)'
        WHEN {{ column }} > 0.40                     THEN 'Deep (40%+)'
    END
{% endmacro %}
```

**3.5 — Intermediate: Product Metrics**

```sql
-- models/intermediate/int_product_metrics.sql
SELECT
    country_code,
    product_id,
    product_name,
    category,
    gender,
    full_price,
    sale_price,
    discount_pct,
    discount_tier,
    total_sizes,
    available_sizes,
    available_sizes * 1.0 / NULLIF(total_sizes, 0)  AS size_fill_rate,
    in_stock,
    sport_tags
FROM {{ ref('stg_nike_catalog') }}
```

**3.6 — Marts: Market Performance (Store-level framing)**

This mart answers the questions On's retail team actually asks: *"How is this market performing? Should we expand? Where is the assortment thin? Where are we discounting too aggressively?"*

```sql
-- models/marts/mart_market_performance.sql
-- Framed as market-level store performance: each country_code = a retail market
-- Supports decisions on geographic expansion, store health, and pricing strategy
WITH products AS (
    SELECT * FROM {{ ref('int_product_metrics') }}
)

SELECT
    country_code                                                     AS market,
    COUNT(DISTINCT product_id)                                       AS assortment_width,
    COUNT(DISTINCT category)                                         AS category_depth,
    ROUND(AVG(full_price), 2)                                        AS avg_full_price,
    ROUND(AVG(discount_pct) * 100, 1)                                AS avg_markdown_pct,
    ROUND(AVG(size_fill_rate) * 100, 1)                              AS size_availability_pct,
    ROUND(COUNT(*) FILTER (WHERE in_stock) * 1.0 / NULLIF(COUNT(*), 0) * 100, 1)
                                                                     AS in_stock_rate_pct,
    ROUND(
      COUNT(*) FILTER (WHERE discount_tier = 'Deep (40%+)') * 1.0
      / NULLIF(COUNT(*), 0) * 100, 1
    )                                                                AS deep_markdown_share_pct,
    ROUND(
      COUNT(*) FILTER (WHERE discount_pct > 0) * 1.0
      / NULLIF(COUNT(*), 0) * 100, 1
    )                                                                AS promo_penetration_pct,
    COUNT(DISTINCT gender)                                           AS gender_segments_served
FROM products
GROUP BY country_code
```

**3.7 — Marts: Merchandising Mix**

Answers: *"What are we selling in each market? How does category/gender mix differ? Where is merchandising effectiveness strongest?"*

```sql
-- models/marts/mart_merchandising_mix.sql
-- Supports merchandising effectiveness analysis and category planning
WITH products AS (
    SELECT * FROM {{ ref('int_product_metrics') }}
)

SELECT
    country_code                                          AS market,
    category,
    gender,
    COUNT(DISTINCT product_id)                            AS sku_count,
    ROUND(AVG(full_price), 2)                             AS avg_price,
    ROUND(AVG(discount_pct) * 100, 1)                     AS avg_markdown_pct,
    ROUND(AVG(size_fill_rate) * 100, 1)                   AS size_availability_pct,
    COUNT(*) FILTER (WHERE discount_pct > 0)              AS on_promo_count,
    COUNT(*) FILTER (WHERE discount_pct = 0)              AS full_price_count,
    ROUND(
      COUNT(*) FILTER (WHERE discount_pct = 0) * 1.0
      / NULLIF(COUNT(*), 0) * 100, 1
    )                                                     AS full_price_sell_through_pct
FROM products
GROUP BY country_code, category, gender
```

**3.8 — Schema & Tests**

```yaml
# models/marts/schema.yml
version: 2

models:
  - name: mart_market_performance
    description: "Market-level retail KPIs — store health, geographic expansion readiness, pricing strategy"
    columns:
      - name: market
        tests:
          - unique
          - not_null
      - name: avg_markdown_pct
        tests:
          - not_null

  - name: mart_merchandising_mix
    description: "Category × gender breakdown per market — merchandising effectiveness and assortment planning"
    columns:
      - name: market
        tests:
          - not_null
      - name: category
        tests:
          - not_null
```

**3.9 — Exposures (documents dashboard dependency)**

```yaml
# exposures/exposures.yml
version: 2

exposures:
  - name: global_retail_health_dashboard
    type: dashboard
    description: "Hex dashboard — Global Retail Health. Used by Retail Strategy team for weekly market reviews."
    depends_on:
      - ref('mart_market_performance')
      - ref('mart_merchandising_mix')
    owner:
      name: "Retail Analytics"
      email: "retail-analytics@on.com"
```

This shows up in `dbt docs` as a lineage node — proves you think about *who consumes your models and what breaks if you change them*.

**3.10 — Run & Validate**
```bash
dbt run
dbt test
dbt source freshness   # Checks snapshot_date against warn/error thresholds
dbt docs generate
dbt docs serve          # DAG visualization — includes exposures lineage
```

---

### Phase 4: Dashboard in Hex

Hex has native DuckDB support — upload the `.duckdb` file directly or connect via the DuckDB connector.

**4.1 — Setup**
- Create free account at hex.tech
- Add data connection: DuckDB → upload `retail.duckdb` file
- Or: use SQL cells with `FROM read_csv_auto()` if uploading CSVs of the marts

**4.2 — Dashboard: "Global Retail Health"**

| Panel | Chart Type | Source Table | Metric |
|-------|-----------|-------------|--------|
| Market Overview | Scorecards (4x) | mart_market_performance | Assortment width, Avg markdown, Size availability, Markets |
| Markdown Heatmap | Choropleth map | mart_market_performance | avg_markdown_pct by market |
| Store Readiness | Bar chart (horizontal) | mart_market_performance | in_stock_rate_pct + size_availability_pct, sorted desc |
| Merchandising Mix | Stacked bar | mart_merchandising_mix | sku_count by category, stacked by gender |
| Promo vs Full Price | Donut chart | mart_merchandising_mix | on_promo_count vs full_price_count |
| Price Architecture | Scatter plot | mart_merchandising_mix | avg_price (x) vs avg_markdown_pct (y), sized by sku_count |

**Filters:** Country dropdown, Category dropdown, Gender toggle.

**4.3 — Additional metrics - we can use maybe**
+ Pricing Strategy & Price Architecture
Implied Discounting: Since you have price_local (full price) and sale_price_local, you can calculate the effective discount percentage globally.
Global Price Dispersions: You can analyze how much the full price of the exact same model (model_number or product_name) varies across different country_codes (when converted to a common currency, or just by index).
Promotional Penetration: Calculate what percentage of the catalog is currently on sale in a given market versus another. Do some countries run deeper sales than others?
+ Assortment & Inventory Health (The "Fill Rate")
Size Availability (Fill Rate Metrics): You have size_count (total sizes that exist for the shoe) and available_size_count (how many are currently available). You can calculate "Size Fill Rate" globally. A high fill rate means healthy inventory; a low fill rate means broken sizes and lost sales.
Assortment Width vs. Depth: Count distinct product_ids by country_code and category. Who has the largest running catalog? Who has the smallest lifestyle catalog?
Product Availability: The available boolean lets you track what percentage of the listed catalog is actually orderable vs. just a placeholder or out of stock.
+ Merchandising & Product Mix
Category Dominance: Break down the percentage of SKUs dedicated to different category and subcategory segments per market.
Gender Split Analysis: Analyze the ratio of Mens vs. Womens vs. Unisex products (gender_segment) globally. Do certain markets index higher on women's products?
Colorway Diversity: Using color_name and style_color, you can look at the average number of colorways offered per base model_number. Which shoes are given the most color treatments?
+ Color & Trend Analysis
Core vs. Seasonal Colors: Analyze the prevalence of core colors (Black/White) versus trend colors. Are discounts steeper on wild colorways compared to core black/white colorways?
How This Fits Into Your Plan

---

### Phase 5: AI Analyst Agent

A lightweight agent that takes natural language questions, converts to SQL, runs on DuckDB, returns narrative answers.

```python
# agent/retail_agent.py
import anthropic
import duckdb
import pandas as pd

DB = duckdb.connect("retail.duckdb", read_only=True)
CLAUDE = anthropic.Anthropic()

SYSTEM = """You are a retail analytics agent. You have access to these DuckDB tables:

- dbt_retail.mart_market_performance: columns: market, assortment_width,
  category_depth, avg_full_price, avg_markdown_pct, size_availability_pct,
  in_stock_rate_pct, deep_markdown_share_pct, promo_penetration_pct,
  gender_segments_served

- dbt_retail.mart_merchandising_mix: columns: market, category, gender,
  sku_count, avg_price, avg_markdown_pct, size_availability_pct,
  on_promo_count, full_price_count, full_price_sell_through_pct

Given a question, return ONLY a valid SQL query. No explanation."""


def ask(question: str) -> str:
    # Step 1: Generate SQL
    sql_response = CLAUDE.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=500,
        system=SYSTEM,
        messages=[{"role": "user", "content": question}],
    )
    sql = sql_response.content[0].text.strip().strip("```sql").strip("```")

    # Step 2: Execute on DuckDB
    rows = DB.execute(sql).fetchdf()

    # Step 3: Narrate results
    narration = CLAUDE.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=300,
        messages=[{
            "role": "user",
            "content": (
                f"Question: {question}\nSQL: {sql}\n"
                f"Results:\n{rows.to_string()}\n\n"
                f"Give a concise retail analyst answer in 2-3 sentences."
            ),
        }],
    )
    return narration.content[0].text


if __name__ == "__main__":
    print(ask("Which 5 countries have the deepest average discounting?"))
    print(ask("What's the gender split in the Running category across all markets?"))
```

```txt
# agent/requirements.txt
anthropic
duckdb
pandas
```

---

## Git Workflow (Demonstrates Governance)

```bash
git init
git checkout -b feature/staging-models
# ... build staging layer ...
git add dbt_retail/models/staging/
git commit -m "feat: add staging model with type casting and discount tier macro"
# Create PR, self-review, merge to main

git checkout -b feature/mart-models
# ... build marts ...
# Repeat PR workflow

git checkout -b feature/ai-agent
# ... build agent ...
```

This shows the version-controlled analytics workflow they explicitly call out as a differentiator.

---

## What This Proves to On's Hiring Team

| Job Requirement | Where It Shows |
|----------------|---------------|
| Advanced SQL (window functions, CTEs, optimization) | `sql/advanced_queries.sql` |
| Cloud warehouse experience | DuckDB locally (README note: "portable to BigQuery — same SQL dialect") |
| Dashboard ecosystems, not just reports | Hex dashboard with filters + KPI framework |
| dbt and data modeling | 3-layer dbt project with tests, docs, macros, freshness, exposures |
| Store performance & geographic expansion | `mart_market_performance` — market health, store readiness, expansion signals |
| Merchandising effectiveness | `mart_merchandising_mix` — category/gender assortment, promo vs full-price |
| AI-forward, analytical agents | `agent/retail_agent.py` — NL→SQL→narrative |
| Data governance, PRs, version control | Git branching strategy, PR-based workflow |
| Ongoing maintenance mindset | Source freshness checks, exposures documenting downstream consumers |
| Retail / consumer-facing domain | Nike global retail dataset, retail-specific KPIs |
| Translates data into stories | Dashboard design + agent narrative output |
