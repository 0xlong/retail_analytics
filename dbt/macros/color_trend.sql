{% macro color_trend(column) %}
    CASE
        WHEN {{ column }} IS NULL OR TRIM({{ column }}) = ''
            THEN 'Unknown'
        WHEN LOWER(TRIM(SPLIT_PART({{ column }}, '/', 1))) IN (
            -- Black translations
            'black', 'schwarz', 'zwart', 'noir', 'negro', 'svart', 'nero',
            'preto', 'siyah', 'fekete', 'sort', 'musta', 'czarny',
            'crna', 'juoda', 'melns',
            -- White translations
            'white', 'weiß', 'weiss', 'wit', 'blanc', 'blanco', 'vit',
            'bianco', 'branco', 'beyaz', 'valkoinen', 'alb',
            'hvid', 'biela', 'valge',
            -- Grey/Gray translations
            'grey', 'gray', 'grau', 'grijs', 'gris', 'grigio', 'cinza',
            'gri', 'harmaa', 'sivá',
            -- Common compound core names
            'dark grey heather', 'light smoke grey', 'cool grey',
            'dark smoke grey', 'anthracite', 'off noir', 'off-noir',
            'sail', 'natural', 'bone'
        )
            THEN 'Core'
        ELSE 'Seasonal'
    END
{% endmacro %}
