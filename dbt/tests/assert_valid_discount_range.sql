-- Discount percentages must be between 0 and 1 (raw decimal, not pre-scaled).
-- Values outside this range indicate upstream data issues or incorrect calculation.

SELECT *
FROM {{ ref('stg_nike_catalog') }}
WHERE discount_pct < 0 OR discount_pct > 1
