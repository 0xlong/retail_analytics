WITH products AS (
    SELECT * FROM {{ ref('stg_nike_catalog') }}
),
rates AS (
    SELECT * FROM {{ ref('fx_rates') }}
)

SELECT
    p.country_code,
    p.product_id,
    p.product_name,
    p.brand_name,
    p.subcategory,
    p.category,
    p.gender,
    p.full_price,
    ROUND(p.full_price / r.Rate_to_1_USD, 2) AS full_price_usd,
    p.sale_price,
    ROUND(p.sale_price / r.Rate_to_1_USD, 2) AS sale_price_usd,
    p.discount_pct,
    p.discount_tier,
    p.style_color,
    p.color_name,
    p.size_label,
    p.available,
    p.availability_level,
    p.available_market,
    p.in_stock,
    p.sport_tags,
    {{ sport_category('p.sport_tags') }}  AS sport_category,
    {{ color_trend('p.color_name') }}     AS color_trend,
    {{ gender_cluster('p.gender') }}      AS gender_cluster
FROM products p
LEFT JOIN rates r ON p.currency = r.Currency_Code
