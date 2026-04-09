-- All SKUs must have a positive full price after staging filters.
-- Fails if any row with full_price <= 0 reaches the intermediate layer.

SELECT *
FROM {{ ref('int_product_metrics') }}
WHERE full_price <= 0
