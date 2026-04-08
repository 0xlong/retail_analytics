WITH source AS (
    SELECT * FROM {{ source('retail_raw', 'nike_catalog') }}
)

SELECT
    CAST(snapshot_date AS DATE)       AS snapshot_date,
    UPPER(TRIM(country_code))         AS country_code,
    TRIM(product_name)                AS product_name,
    model_number,
    currency,
    ROUND(price_local, 2)             AS full_price,
    ROUND(sale_price_local, 2)        AS sale_price,
    COALESCE(LOWER(TRIM(gender_segment)), 'unknown') AS gender,
    category,
    subcategory,
    product_id,
    sku,
    style_color,
    brand_name,
    TRIM(color_name)                  AS color_name,
    size_label,
    available,
    availability_level,
    available_market,
    in_stock,
    ROUND(discount_pct, 2)            AS discount_pct,
    {{ discount_tier('discount_pct') }} AS discount_tier,
    sport_tags
FROM source
WHERE price_local > 0
  AND sku IS NOT NULL
