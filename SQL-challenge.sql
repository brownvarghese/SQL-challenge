USE sakila;

--------------------------------------------------------------------------------------------
-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name,last_name from actor;

--------------------------------------------------------------------------------------------
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT upper(concat(first_name,' ',last_name)) as 'Actor Name' from actor;  

--------------------------------------------------------------------------------------------
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know 
-- only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = 'Joe';

--------------------------------------------------------------------------------------------
-- 2b. Find all actors whose last name contain the letters GEN:
SELECT first_name, last_name FROM actor WHERE last_name like '%GEN%';

--------------------------------------------------------------------------------------------
-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:

SELECT first_name, last_name FROM actor WHERE last_name like '%LI%'
ORDER BY last_name, first_name;

--------------------------------------------------------------------------------------------
-- 2d. Using IN, display the country_id and country columns of the following countries: 
--     Afghanistan, Bangladesh, and China:

SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

--------------------------------------------------------------------------------------------
-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and 
-- use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

Alter table actor
add column description BLOB;

--------------------------------------------------------------------------------------------
-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

ALTER TABLE actor
DROP COLUMN description; 

--------------------------------------------------------------------------------------------
-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, count(*)
FROM actor
group by 1
order by 2 ;

--------------------------------------------------------------------------------------------
-- 4b. List last names of actors and the number of actors who have that last name, 
--     but only for names that are shared by at least two actors

SELECT last_name, count(*)
FROM actor
group by last_name
having count(*) >= 2;

--------------------------------------------------------------------------------------------
-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS.
--     Write a query to fix the record.

select * from actor
WHERE first_name = 'GROUCHO'
and last_name = 'WILLIAMS';

UPDATE actor
   SET first_name = 'HARPO'
     , last_name = 'WILLIAMS'
 WHERE first_name = 'GROUCHO'
   AND last_name = 'WILLIAMS'; 

--------------------------------------------------------------------------------------------  
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all!
--     In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE actor
   SET first_name = 'GROUCHO'
 WHERE first_name = 'HARPO';
 
-------------------------------------------------------------------------------------------- 
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

SHOW CREATE TABLE address;

-- table DDL that is retrieved using the show.

CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
--     Use the tables staff and address:

--------------------------------------------------------------------------------------------
SELECT S.first_name, S.last_name, A.address, A.address2, A.district, A.city_id, A.postal_code
FROM staff S 
LEFT JOIN address A 
ON S.address_id = A.address_id;

--------------------------------------------------------------------------------------------
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
--     Use tables staff and payment.

SELECT S.first_name, S.last_name, sum(P.amount)
FROM payment P
LEFT JOIN staff S
ON S.staff_id = P.staff_id
where  year(P.payment_date) = '2005'
  and  month(P.payment_date) = '08'
group by 1, 2;

--------------------------------------------------------------------------------------------
-- 6c. List each film and the number of actors who are listed for that film. 
--     Use tables film_actor and film. Use inner join.

SELECT F.title, count(FA.actor_id)
FROM film F
INNER JOIN film_actor FA
ON F.film_id = FA.film_id
 group by F.title
;

--------------------------------------------------------------------------------------------
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT count(F.title)
FROM inventory I, film F 
WHERE I.film_id = F.film_id
AND F.title = 'Hunchback Impossible'
;

--------------------------------------------------------------------------------------------
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT C.first_name, C.last_name, sum(P.amount) as 'Total Payment'
FROM payment P
INNER JOIN customer C 
on P.customer_id = C.customer_id
group by C.first_name, C.last_name
order by 2;

--------------------------------------------------------------------------------------------
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title from film
where language_id =(
			select language_id 
			from language
			where name = 'English')
and (title like 'K%' or title like 'Q%');

--------------------------------------------------------------------------------------------
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name
FROM actor
WHERE actor_id in (
			SELECT actor_id
			FROM film_actor
			Where film_id = (
						SELECT film_id
						 FROM film
						 WHERE title = 'Alone Trip'));

--------------------------------------------------------------------------------------------                         
-- 7c. You want to run an email marketing campaign in Canada, 
--     for which you will need the names and email addresses of all Canadian customers. 
--     Use joins to retrieve this information.

SELECT CU.first_name, CU.last_name,CU.email
FROM customer CU
inner Join address A ON CU.address_id = A.address_id
inner Join city C ON A.city_id = C.city_id 
inner join country CO ON C.country_id = CO.country_id
WHERE CO.country = 'Canada';

--------------------------------------------------------------------------------------------
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as family films.

SELECT F.Title
FROM film F
LEFT JOIN film_category FC ON F.film_id = FC.film_id
LEFT JOIN category C ON FC.category_id = C.category_id
WHERE C.name = 'Family';


--------------------------------------------------------------------------------------------
-- 7e. Display the most frequently rented movies in descending order.

select F.title, count(*) AS 'rent_count'
from rental R
LEFT JOIN inventory I on R.inventory_id = I.inventory_id
LEFT JOIN film F ON F.film_id = I.film_id
group by 1
order by 2 desc 
limit 1

--------------------------------------------------------------------------------------------
-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT 
 I.store_id, SUM(P.amount) AS 'Total $'
from payment P
INNER JOIN rental R ON P.rental_id = R.rental_id
LEFT JOIN inventory I ON R.inventory_id = I.inventory_id
LEFT JOIN store S ON I.store_id = S.store_id
GROUP BY 1
ORDER BY I.store_id;

--------------------------------------------------------------------------------------------
-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT S.store_id, C.city, CO.country
FROM store S
inner Join address A ON S.address_id = A.address_id
inner Join city C ON A.city_id = C.city_id 
inner join country CO ON C.country_id = CO.country_id

--------------------------------------------------------------------------------------------
-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT C.name, SUM(P.amount) AS 'Gross Revenue'
FROM  payment P
INNER JOIN rental R ON P.rental_id = R.rental_id
INNER JOIN inventory I ON R.inventory_id = I.inventory_id
INNER JOIN film_category FC ON I.film_id = FC.film_id
INNER JOIN category C ON FC.category_id = C.category_id
GROUP by 1
ORDER BY 2 desc
limit 5;

--------------------------------------------------------------------------------------------
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres AS
SELECT C.name, SUM(P.amount) AS 'Gross Revenue'
FROM  payment P
INNER JOIN rental R ON P.rental_id = R.rental_id
INNER JOIN inventory I ON R.inventory_id = I.inventory_id
INNER JOIN film_category FC ON I.film_id = FC.film_id
INNER JOIN category C ON FC.category_id = C.category_id
GROUP by 1
ORDER BY 2 desc
limit 5;


--------------------------------------------------------------------------------------------
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;


--------------------------------------------------------------------------------------------
-- You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;































  



 
  
  



					   





