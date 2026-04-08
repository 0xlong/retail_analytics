-- Market-level retail KPIs
-- One row per country — supports geographic expansion, store health, and pricing strategy decisions
WITH products AS (
    SELECT * FROM {{ ref('int_product_metrics') }}
)

SELECT
    country_code                                                                                      AS market,
    COUNT(DISTINCT product_id)                                                                        AS assortment_width,
    COUNT(DISTINCT category)                                                                          AS category_depth,
    ROUND(AVG(full_price), 2)                                                                         AS avg_full_price,
    ROUND(AVG(discount_pct) * 100, 1)                                                                 AS avg_markdown_pct,
    ROUND(COUNT(*) FILTER (WHERE available) * 1.0 / NULLIF(COUNT(*), 0) * 100, 1)                    AS availability_rate_pct,
    ROUND(COUNT(*) FILTER (WHERE availability_level = 'OOS') * 1.0 / NULLIF(COUNT(*), 0) * 100, 1)  AS oos_rate_pct,
    ROUND(COUNT(*) FILTER (WHERE in_stock) * 1.0 / NULLIF(COUNT(*), 0) * 100, 1)                    AS in_stock_rate_pct,
    COUNT(DISTINCT size_label)                                                                        AS size_depth,
    ROUND(
      COUNT(*) FILTER (WHERE discount_tier = 'Deep (40%+)') * 1.0 / NULLIF(COUNT(*), 0) * 100, 1
    )                                                                                                 AS deep_markdown_share_pct,
    ROUND(
      COUNT(*) FILTER (WHERE discount_pct > 0) * 1.0 / NULLIF(COUNT(*), 0) * 100, 1
    )                                                                                                 AS promo_penetration_pct,
    COUNT(DISTINCT gender)                                                                            AS gender_segments_served
FROM products
GROUP BY country_code
