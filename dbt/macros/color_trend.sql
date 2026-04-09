{% macro color_trend(column) %}
    CASE
        WHEN {{ column }} IS NULL OR TRIM({{ column }}) = ''
            THEN 'Unknown (No data)'

        -- 1. Blacks
        WHEN regexp_matches(LOWER(TRIM(SPLIT_PART({{ column }}, '/', 1))), 'black|negro|preto|noir|nero|obsidian|anthracite|off.noir')
            THEN 'Blacks'

        -- 2. Whites
        WHEN regexp_matches(LOWER(TRIM(SPLIT_PART({{ column }}, '/', 1))), 'white|blanco|blanc|branco|weiß|sail|bone|phantom|summit.white|ivory')
            THEN 'Whites'

        -- 3. Greys & Silvers
        WHEN regexp_matches(LOWER(TRIM(SPLIT_PART({{ column }}, '/', 1))), 'grey|gray|gris|cinza|silver|plata|platinum|wolf|cool.grey|smoke.grey')
            THEN 'Greys & Silvers'

        -- 4. Reds & Pinks
        WHEN regexp_matches(LOWER(TRIM(SPLIT_PART({{ column }}, '/', 1))), 'red|rojo|rouge|vermelho|crimson|pink|rosa|rose|fuchsia|berry|burgundy')
            THEN 'Reds & Pinks'

        -- 5. Blues & Purples
        WHEN regexp_matches(LOWER(TRIM(SPLIT_PART({{ column }}, '/', 1))), 'blue|azul|bleu|navy|royal|sky|purple|violet|indigo|morado|roxo')
            THEN 'Blues & Purples'

        -- 6. Greens
        WHEN regexp_matches(LOWER(TRIM(SPLIT_PART({{ column }}, '/', 1))), 'green|verde|vert|olive|oliva|mint|spruce|pine|sequoia|chlorophyll')
            THEN 'Greens'

        -- 7. Yellows, Oranges & Volts
        WHEN regexp_matches(LOWER(TRIM(SPLIT_PART({{ column }}, '/', 1))), 'yellow|amarillo|amarelo|orange|naranja|gold|oro|volt|citron|amber')
            THEN 'Yellows & Oranges'

        -- 8. Browns & Earth Tones
        WHEN regexp_matches(LOWER(TRIM(SPLIT_PART({{ column }}, '/', 1))), 'brown|marron|marrón|tan|beige|khaki|sand|wheat|bronze|fossil|desert')
            THEN 'Browns & Earth Tones'

        ELSE 'Other/Multicolor'
    END
{% endmacro %}
