{% macro discount_tier(column) %}
    CASE
        WHEN {{ column }} = 0                   THEN 'Full Price'
        WHEN {{ column }} BETWEEN 0.01 AND 0.20 THEN 'Light (1-20%)'
        WHEN {{ column }} BETWEEN 0.21 AND 0.40 THEN 'Medium (21-40%)'
        WHEN {{ column }} > 0.40                THEN 'Deep (40%+)'
    END
{% endmacro %}
