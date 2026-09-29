-- TRABALHO PRÁTICO SQL N1 - QUESTÃO 4
-- Procedure Automação de relatório (stored procedure)
-- Relatório: locações e receita por categoria e loja, com ranking
-- Eduardo Tavares Lima

-- 1. Procedure

DROP PROCEDURE IF EXISTS sp_relatorio_receita_categoria;

DELIMITER $$

CREATE PROCEDURE sp_relatorio_receita_categoria(
    IN p_data_inicio DATE,
    IN p_data_fim DATE,
    IN p_categoria VARCHAR(25),
    IN p_loja TINYINT
)
BEGIN
    IF p_data_inicio IS NULL THEN
	SET p_data_inicio = (SELECT DATE(MIN(rental_date)) FROM rental);
    END IF;
	IF p_data_fim IS NULL THEN
        SET p_data_fim = (SELECT DATE(MAX(rental_date)) FROM rental);
    END IF;

    IF p_data_inicio > p_data_fim THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Data inicial não pode ser maior que a data final.';
    END IF;

    IF p_categoria IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM category WHERE name = p_categoria) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Categoria informada não existe.';
    END IF;

    IF p_loja IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM store WHERE store_id = p_loja) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loja informada não existe.';
    END IF;

-- 2. Relatório
    WITH base AS (
        SELECT c.name AS categoria, i.store_id AS loja, r.rental_id, p.amount 
	FROM rental r
        JOIN payment p
		ON p.rental_id = r.rental_id
        JOIN inventory i
		ON i.inventory_id = r.inventory_id
        JOIN film_category fc
		ON fc.film_id = i.film_id
        JOIN category c
		ON c.category_id = fc.category_id

        WHERE r.rental_date >= p_data_inicio
          AND r.rental_date < DATE_ADD(p_data_fim, INTERVAL 1 DAY)
          AND (p_categoria IS NULL OR c.name = p_categoria)
          AND (p_loja IS NULL OR i.store_id = p_loja)
    )

    SELECT  categoria AS Categoria,
            loja AS Loja,
            COUNT(DISTINCT rental_id) AS Total_Locacoes,
            SUM(amount) AS Receita_Total,
            ROUND(AVG(amount), 2) AS Ticket_Medio,
            RANK() OVER (PARTITION BY loja ORDER BY SUM(amount) DESC) AS Ranking_na_Loja
    FROM base
    GROUP BY categoria, loja
    ORDER BY loja, Ranking_na_Loja;
END$$

DELIMITER ;
