
-- TRABALHO PRÁTICO SQL N1 - QUESTÃO 5
-- Views para Diferentes Perfis (Gerencial vs. Analítico)
-- Antonio Arthur


-- 1. VIEW GERENCIAL (Perfil Estratégico / Nível Macro)

CREATE VIEW vw_painel_filmes_gerencial AS
SELECT 
    DATE_FORMAT(r.rental_date, '%Y-%m') AS mes_referencia,
    cat.name AS categoria,
    COUNT(r.rental_id) AS total_locacoes,
    COUNT(DISTINCT r.customer_id) AS clientes_unicos,
    COUNT(DISTINCT f.film_id) AS filmes_distintos,
    ROUND(SUM(p.amount), 2) AS receita_total,
    ROUND(AVG(p.amount), 2) AS ticket_medio
FROM rental r
JOIN inventory i 
    ON r.inventory_id = i.inventory_id
JOIN film f 
    ON i.film_id = f.film_id
JOIN film_category fc 
    ON f.film_id = fc.film_id
JOIN category cat 
    ON fc.category_id = cat.category_id
LEFT JOIN payment p 
    ON r.rental_id = p.rental_id
GROUP BY 
    DATE_FORMAT(r.rental_date, '%Y-%m'), 
    cat.category_id, 
    cat.name;


-- 2. VIEW ANALÍTICA (Perfil Operacional / Acompanhamento Diário)
CREATE VIEW vw_painel_filmes_analitico AS
SELECT 
    r.rental_id AS id_locacao,
    r.rental_date AS data_locacao,
    r.return_date AS data_devolucao,
    f.title AS filme,
    cat.name AS categoria,
    CONCAT(c.first_name, ' ', c.last_name) AS cliente,
    c.email AS email_cliente,
    ci.city AS cidade,
    p.amount AS valor_pago
FROM rental r
JOIN inventory i 
    ON r.inventory_id = i.inventory_id
JOIN film f 
    ON i.film_id = f.film_id
JOIN film_category fc 
    ON f.film_id = fc.film_id
JOIN category cat 
    ON fc.category_id = cat.category_id
JOIN customer c 
    ON r.customer_id = c.customer_id
JOIN address a 
    ON c.address_id = a.address_id
JOIN city ci 
    ON a.city_id = ci.city_id
LEFT JOIN payment p 
    ON r.rental_id = p.rental_id;

-- CÓDIGOS PARA A DEMONSTRAÇÃO AO VIVO NO XAMPP


-- mostrar o Perfil Gerencial:
-- SELECT * FROM vw_painel_filmes_gerencial LIMIT 15;

-- mostrar o Perfil Analítico:
-- SELECT * FROM vw_painel_filmes_analitico LIMIT 15;
