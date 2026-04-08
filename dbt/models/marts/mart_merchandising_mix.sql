-- Merchandising effectiveness by market × category × gender
-- Supports category planning, gender assortment analysis, and promo vs full-price strategy
WITH products AS (
    SELECT * FROM {{ ref('int_product_metrics') }}
)

SELECT
    country_code                                                                                      AS market,
    category,
    gender,
    COUNT(DISTINCT product_id)                                                                        AS sku_count,
    ROUND(AVG(full_price), 2)                                                                         AS avg_price,
    ROUND(AVG(discount_pct) / 100, 4)                                                                 AS avg_markdown_pct,
    ROUND(COUNT(*) FILTER (WHERE available) * 1.0 / NULLIF(COUNT(*), 0), 4)                           AS availability_rate_pct,
    ROUND(COUNT(*) FILTER (WHERE availability_level = 'OOS') * 1.0 / NULLIF(COUNT(*), 0), 4)          AS oos_rate_pct,
    COUNT(DISTINCT size_label)                                                                        AS size_depth,
    COUNT(*) FILTER (WHERE discount_pct > 0)                                                         AS on_promo_count,
    COUNT(*) FILTER (WHERE discount_pct = 0)                                                         AS full_price_count,
    ROUND(
      COUNT(*) FILTER (WHERE discount_pct = 0) * 1.0 / NULLIF(COUNT(*), 0), 4
    )                                                                                                 AS full_price_sell_through_pct
FROM products
GROUP BY country_code, category, gender
