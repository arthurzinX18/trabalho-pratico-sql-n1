WITH filmes_criticos AS (
	SELECT
		film.film_id,
		film.title,
		film.replacement_cost,
		COUNT(rental.rental_id) AS qtd_alugado,
		COUNT(inventory.inventory_id) AS qtd_total,
		COUNT(inventory.inventory_id) - COUNT(rental.rental_id) AS qtd_disponivel
	FROM sakila.film
	INNER JOIN sakila.inventory
		ON inventory.film_id = film.film_id
	LEFT JOIN sakila.rental
		ON rental.inventory_id = inventory.inventory_id AND rental.return_date IS NULL
	GROUP BY film.film_id, film.title, film.replacement_cost
	HAVING qtd_alugado != 0 AND qtd_disponivel <= 2
)
SELECT
	*,
	ROW_NUMBER() OVER (
		ORDER BY filme.qtd_disponivel ASC, filme.replacement_cost ASC, filme.film_id ASC
	) AS ordem_prioridade
FROM filmes_criticos filme
ORDER BY ordem_prioridade ASC;
