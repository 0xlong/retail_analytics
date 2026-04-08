-- ============================================================
-- Advanced SQL Showcase — Nike Global Catalog
-- DuckDB (BigQuery-compatible syntax)
-- ============================================================


-- ------------------------------------------------------------
-- 1. WINDOW FUNCTIONS: Top 5 discounted products per market/category
-- ROW_NUMBER() ranks within each partition; AVG() adds market context
-- ------------------------------------------------------------

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


-- ------------------------------------------------------------
-- 2. MULTI-CTE PIPELINE: Assortment & Availability KPIs
-- CTE 1 aggregates at product level; CTE 2 rolls up to market/category
-- FILTER (WHERE ...) is DuckDB/BigQuery syntax — conditional aggregation
-- NULLIF prevents division by zero
-- ------------------------------------------------------------

WITH product_availability AS (
  SELECT
    country_code,
    product_id,
    product_name,
    category,
    COUNT(DISTINCT size_label)                                        AS size_depth,
    COUNT(*) FILTER (WHERE available)                                 AS available_skus,
    COUNT(*)                                                          AS total_skus,
    COUNT(*) FILTER (WHERE availability_level = 'OOS')               AS oos_skus
  FROM retail_raw.nike_catalog
  GROUP BY country_code, product_id, product_name, category
),

market_scoring AS (
  SELECT
    country_code,
    category,
    COUNT(DISTINCT product_id)                                          AS assortment_width,
    ROUND(AVG(size_depth), 1)                                           AS avg_size_depth,
    ROUND(SUM(available_skus) * 100.0 / NULLIF(SUM(total_skus), 0), 1) AS availability_rate_pct,
    ROUND(SUM(oos_skus) * 100.0 / NULLIF(SUM(total_skus), 0), 1)       AS oos_rate_pct,
    COUNT(*) FILTER (WHERE oos_skus = 0)                                AS fully_available_products
  FROM product_availability
  GROUP BY country_code, category
)

SELECT
  country_code,
  category,
  assortment_width,
  avg_size_depth,
  availability_rate_pct,
  oos_rate_pct,
  fully_available_products,
  ROUND(fully_available_products * 100.0 / NULLIF(assortment_width, 0), 1) AS full_availability_pct
FROM market_scoring
-- oos_rate_pct has inverted polarity — lower is better, so ASC surfaces healthiest markets first
ORDER BY oos_rate_pct ASC, assortment_width DESC;


-- ------------------------------------------------------------
-- 3. PRICE ARCHITECTURE: Median, promo penetration, discount depth
-- PERCENTILE_CONT is BigQuery/DuckDB native — not available in standard SQL
-- Shows price positioning across market × category × gender
-- ------------------------------------------------------------

SELECT
  country_code,
  category,
  gender_segment,
  COUNT(DISTINCT product_id)                                              AS products,
  ROUND(AVG(price_local), 2)                                             AS avg_full_price,
  ROUND(AVG(sale_price_local), 2)                                        AS avg_sale_price,
  ROUND(AVG(discount_pct), 1)                                            AS avg_discount_pct,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_local)               AS median_price,
  COUNT(*) FILTER (WHERE discount_pct > 0)                               AS on_sale_count,
  ROUND(
    COUNT(*) FILTER (WHERE discount_pct > 0) * 100.0 / NULLIF(COUNT(*), 0), 1
  )                                                                       AS promo_penetration_pct
FROM retail_raw.nike_catalog
GROUP BY country_code, category, gender_segment
ORDER BY products DESC;
