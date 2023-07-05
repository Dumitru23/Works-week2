--1.1 View names,address and phone of all clients
-- I used INNER JOINS of 3 tables. Find out address of all Customers. 
SELECT 	c.customer_id,
		c.first_name,
		c.last_name,
		a.address,
		ct.city,
		a.phone
From customer c
INNER JOIN Address a
ON c.customer_id=a.address_id
INNER JOIN City ct
ON a.city_id=ct.city_id
ORDER BY first_name;
		
--1.2 Left Join
--find out the rented period of DVD for each client 
SELECT  c.last_name,
		c.first_name,
		r.rental_date,
		r.return_date,
		r.rental_date - r.return_date AS rented_period,
		p.amount
From customer c
LEFT JOIN rental r ON c.customer_id=r.customer_id
LEFT JOIN payment p ON c.customer_id=p.customer_id
GROUP BY c.first_name, c.last_name, p.amount, r.rental_date,r.return_date
ORDER BY c.last_name ASC, p.amount DESC;


--1.3 Right Join
--Seeing total count and total amount for each genre of DVD movies
SELECT cg.category_id, cg.name AS category_name,
COUNT(f.film_id) AS film_count,
SUM(p.amount) AS total_amount
FROM category cg
RIGHT JOIN film_category fc ON cg.category_id = fc.category_id
RIGHT JOIN film f ON fc.film_id = f.film_id
RIGHT JOIN inventory i ON f.film_id = i.film_id
RIGHT JOIN rental r ON i.inventory_id = r.inventory_id
RIGHT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY cg.category_id, cg.name
ORDER BY total_amount DESC;

--1.4 Full Join of 4 tables to view a precise data of DVD movies
SELECT  f.title,
		ct.name AS category_name,
		f.release_year,
		f.rating,
		l.name AS language
FROM Category ct
FULL OUTER JOIN film_category fc ON ct.category_id = fc.category_id
FULL OUTER JOIN film f ON fc.film_id = f.film_id
FULL OUTER JOIN language l ON f.language_id=l.language_id
ORDER BY ct.name;

--1.5 Natural Join
WITH film AS(
SELECT film_id, title, release_year
FROM film
ORDER BY title
	),
			
language AS(
SELECT   name
FROM language
	)
			
SELECT *
FROM film
NATURAL JOIN language;




-- 1.6 Having Clause - specify a search condition for a group or an aggregate.
--Total amount of each customer who spent more than 100

SELECT 
	customer_id,
	SUM (amount)
FROM
	payment
GROUP BY customer_id
HAVING SUM (amount) > 100;

--1.7 Find movies ratings that has revenue between 10.000 and 13.000 
-- with Clause Having
SELECT 
	f.rating, 
	SUM(p.amount) AS SUM
FROM film f
	join inventory i ON f.film_id = i.film_id
	join rental r ON i.inventory_id = r.inventory_id
	join payment p ON r.rental_id = p.rental_id
GROUP BY f.rating
HAVING SUM(p.amount) <> 9000 and sum(p.amount)<13000
ORDER BY SUM ASC;


--1.8. Sub-Query in a SELECT CLAUSE
--find out how the total sum spendt on DVD movies for each customer
SELECT 	customer_id, 
		first_name, 
		last_name,
    (
		SELECT 	SUM(amount)	
		FROM payment 
		WHERE payment.customer_id = customer.customer_id) AS sum_payment
FROM customer
ORDER BY sum_payment DESC;

--1.9 Sub-Query in FROM CLAUSE
SELECT film_id, film_count
FROM (
    SELECT film_id, COUNT(*) AS film_count
    FROM inventory
    GROUP BY film_id
)AS film_counts;


--1.10 Sub-Query in WHERE CLAUSE
-- find customer who paid for rent more than 10
SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id IN ( 
	 SELECT customer_id
    	FROM payment
     WHERE amount > 10
);

--1.11 Window function
-- Find out Avg amount spent on renting DVD of each customer
Select customer_id, first_name, last_name,
		avg(amount) OVER (PARTITION BY last_name)
FROM payment
		INNER JOIN customer using(customer_id)
ORDER BY last_name desc;

--1.12 Case When
--Categorize movies on 3 groups based on duration (length) 
SELECT concat(a.first_name,' ',a.last_name) AS actor_Name, f.title, f.length,
CASE
	WHEN f.length <60  THEN 'less 60 min'
    WHEN f.length >60  AND f.length<120 THEN 'GR1'
    WHEN f.length >120 AND f.length<180 THEN 'Gr2'
    WHEN f.length >180 THEN 'BGr3'
END AS Film_Groups
FROM actor a
JOIN film_actor fa on a.actor_id=fa.actor_id
JOIN film f on f.film_id=fa.film_id;



--1.13 Using Case expresiion , add the rating description to the output
SELECT title,
       rating,
       CASE rating
           WHEN 'G' THEN 'General Audiences'
           WHEN 'PG' THEN 'Parental Guidance Suggested'
           WHEN 'PG-13' THEN 'Parents Strongly Cautioned'
           WHEN 'R' THEN 'Restricted'
           WHEN 'NC-17' THEN 'Adults Only'
       END rating_description
FROM film
ORDER BY title;

--1.14 Use case. FInd sum of each rating.
SELECT
       SUM(CASE rating
             WHEN 'G' THEN 1 
		     ELSE 0 
		   END) "General Audiences",
       SUM(CASE rating
             WHEN 'PG' THEN 1 
		     ELSE 0 
		   END) "Parental Guidance Suggested",
       SUM(CASE rating
             WHEN 'PG-13' THEN 1 
		     ELSE 0 
		   END) "Parents Strongly Cautioned",
       SUM(CASE rating
             WHEN 'R' THEN 1 
		     ELSE 0 
		   END) "Restricted",
       SUM(CASE rating
             WHEN 'NC-17' THEN 1 
		     ELSE 0 
		   END) "Adults Only"
FROM film;