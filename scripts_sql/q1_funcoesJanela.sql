-- script referente ao Panorama temporal e ranking do banco

WITH dados_mensais AS (
    SELECT 
        DATE_FORMAT(r.rental_date, '%Y-%m') AS mes,
        c.name AS categoria,
        COUNT(DISTINCT r.rental_id) AS qtd_locacoes,
        SUM(p.amount) AS receita
    FROM rental r
    INNER JOIN inventory i ON r.inventory_id = i.inventory_id
    INNER JOIN film f ON i.film_id = f.film_id
    INNER JOIN film_category fc ON f.film_id = fc.film_id
    INNER JOIN category c ON fc.category_id = c.category_id
    INNER JOIN payment p ON r.rental_id = p.rental_id
    GROUP BY 
        DATE_FORMAT(r.rental_date, '%Y-%m'),
        c.name
),
ranking_mensal AS (
    SELECT 
        mes,
        categoria,
        qtd_locacoes,
        receita,
        RANK() OVER (
            PARTITION BY mes
            ORDER BY receita DESC
        ) AS ranking_no_mes
    FROM dados_mensais
),
resultado AS (
    SELECT 
        mes,
        categoria,
        qtd_locacoes,
        receita,
        ranking_no_mes,
        SUM(receita) OVER (
            PARTITION BY categoria
            ORDER BY mes 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS receita_acumulada
    FROM ranking_mensal
)
SELECT 
    mes AS Mes,
    categoria AS Categoria,
    qtd_locacoes AS Qtd. locacoes,
    ROUND(receita, 2) AS Receita,
    ranking_no_mes AS Ranking no mes,
    ROUND(receita_acumulada, 2) AS Receita acumulada
FROM resultado
WHERE ranking_no_mes <= 3
ORDER BY 
    mes,
    ranking_no_mes;
