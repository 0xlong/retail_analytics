-- Merchandising effectiveness by market × category × gender
-- Supports category planning, gender assortment analysis, and promo vs full-price strategy
WITH products AS (
    SELECT * FROM {{ ref('int_product_metrics') }}
)

SELECT
    country_code                                                                                      AS market,
    category,
    gender_cluster,

    -- Base counts (Additive - Use these in Looker for custom metrics)
    COUNT(*)                                                                                          AS total_items_count,
    COUNT(*) FILTER (WHERE available)                                                                 AS available_items_count,
    COUNT(*) FILTER (WHERE availability_level = 'OOS')                                                AS oos_items_count,
    SUM(discount_pct)                                                                                 AS sum_discount,
    SUM(full_price_usd)                                                                               AS sum_full_price_usd,

    -- Distinct metrics (Non-additive)
    COUNT(DISTINCT product_id)                                                                        AS sku_count,
    COUNT(DISTINCT size_label)                                                                        AS size_depth,
    
    -- Status counts
    COUNT(*) FILTER (WHERE discount_pct > 0)                                                          AS on_promo_count,
    COUNT(*) FILTER (WHERE discount_pct = 0)                                                          AS full_price_count,

    -- Pre-calculated rates & averages (Warning: NON-ADDITIVE, do not SUM in BI tools)
    ROUND(AVG(full_price_usd), 2)                                                                     AS avg_price_usd,
    ROUND(AVG(discount_pct), 4)                                                                       AS avg_markdown_pct,
    ROUND(COUNT(*) FILTER (WHERE available) * 1.0 / NULLIF(COUNT(*), 0), 4)                           AS availability_rate_pct,
    ROUND(COUNT(*) FILTER (WHERE availability_level = 'OOS') * 1.0 / NULLIF(COUNT(*), 0), 4)          AS oos_rate_pct,
    ROUND(
      COUNT(*) FILTER (WHERE discount_pct = 0) * 1.0 / NULLIF(COUNT(*), 0), 4
    )                                                                                                 AS full_price_sell_through_pct
FROM products
GROUP BY country_code, category, gender_cluster
