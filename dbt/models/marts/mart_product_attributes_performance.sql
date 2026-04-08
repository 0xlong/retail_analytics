-- Product attributes performance: brand, sport, color, and subcategory analysis
-- Supports brand equity, lifestyle vs performance, and subcategory OOS deep-dives
WITH products AS (
    SELECT * FROM {{ ref('int_product_metrics') }}
)

SELECT
    country_code                                                                              AS market,
    brand_name,
    category,
    subcategory,
    gender,
    sport_category,
    color_trend,
    COUNT(DISTINCT product_id)                                                                AS sku_count,
    ROUND(AVG(full_price), 2)                                                                 AS avg_price,
    ROUND(AVG(discount_pct) / 100, 4)                                                         AS avg_markdown_pct,
    ROUND(COUNT(*) FILTER (WHERE discount_pct > 0) * 1.0 / NULLIF(COUNT(*), 0), 4)            AS promo_penetration_pct,
    ROUND(COUNT(*) FILTER (WHERE availability_level = 'OOS') * 1.0 / NULLIF(COUNT(*), 0), 4)  AS oos_rate_pct,
    ROUND(COUNT(*) FILTER (WHERE discount_pct = 0) * 1.0 / NULLIF(COUNT(*), 0), 4)            AS full_price_sell_through_pct
FROM products
GROUP BY country_code, brand_name, category, subcategory, gender, sport_category, color_trend
