{% macro gender_cluster(column) %}
    CASE
        WHEN {{ column }} = 'men'                                          THEN 'Men'
        WHEN {{ column }} = 'women'                                        THEN 'Women'
        WHEN {{ column }} IN ('boys', 'girls', 'boys|girls', 'girls|boys') THEN 'Kids'
        WHEN {{ column }} = 'unknown'                                      THEN 'Unknown'
        ELSE                                                                    'Unisex'
    END
{% endmacro %}
