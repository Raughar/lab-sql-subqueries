use sakila;

-- Getting how many copies of the movie Hunchback Impossible are on the inventory
SELECT COUNT(*) AS Copies_Available
FROM film
JOIN inventory ON film.film_id = inventory.film_id
WHERE film.title = 'Hunchback Impossible';

-- Getting all films whose length is longer than the average of all the films
SELECT * -- , film_id, title as Film, lentgth as Length
FROM film
WHERE length > (SELECT AVG(length) FROM film);

-- Using subqueries to get all the actors who appear in the film Alone Trip:
SELECT actor.actor_id, actor.first_name, actor.last_name
FROM actor
WHERE actor.actor_id IN (
	SELECT film_actor.actor_id FROM film_actor
    JOIN film ON film_actor.film_id = film.film_id
    WHERE film.title = 'Alone Trip'
);

-- Getting all the films categorized as Family Films
SELECT film.film_id, film.title as Film, category.name AS Category
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
WHERE category.name = 'Family';

-- Getting all the names and emails of the customers from Canada using subqueries
SELECT first_name, last_name, email, (
    SELECT country
    FROM country
    WHERE country_id = (
        SELECT country_id
        FROM city
        WHERE city_id = (
            SELECT city_id
            FROM address
            WHERE address_id = customer.address_id
        )
    )
) AS country
FROM customer
WHERE customer.address_id IN (
    SELECT address_id
    FROM address
    WHERE city_id IN (
        SELECT city_id
        FROM city
        WHERE country_id IN (
            SELECT country_id
            FROM country
            WHERE country = 'Canada'
        )
    )
);

-- Now doing the same as above but with joins
SELECT customer.first_name, customer.last_name, customer.email, country.country
FROM customer
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
WHERE country.country = 'Canada';

-- Finding the most prolific actor and then finding the films in with he/she worked
	-- Finding the actor ID first (107)
    SELECT actor.actor_id, actor.first_name, actor.last_name, film_count
	FROM actor
	JOIN (
		SELECT actor_id, COUNT(film_id) AS film_count
		FROM film_actor
		GROUP BY actor_id
		ORDER BY film_count DESC
		LIMIT 1
	)  AS Most_Prolific_Actor ON actor.actor_id = Most_Prolific_Actor.actor_id;
	-- Finding the films:
    SELECT film.film_id, film.title
	FROM film
	JOIN film_actor ON film.film_id = film_actor.film_id
	WHERE film_actor.actor_id = 107;
    
-- Getting the films rented by the most profitable customer
SELECT rental.rental_id, film.title, customer.first_name, customer.last_name
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
JOIN (
    SELECT customer_id, SUM(amount) AS total_payments
    FROM payment
    GROUP BY customer_id
    ORDER BY total_payments DESC
    LIMIT 1
) AS most_profitable_customer ON rental.customer_id = most_profitable_customer.customer_id
JOIN customer ON rental.customer_id = customer.customer_id;

-- Getting the clients who spent more than the average spent
SELECT customer.customer_id AS client_id, SUM(payment.amount) AS Total_Amount_Spent
FROM customer
JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
HAVING total_amount_spent > (
    SELECT AVG(total_payments)
    FROM (
        SELECT customer_id, SUM(amount) AS total_payments
        FROM payment
        GROUP BY customer_id
    ) AS average_payments
);