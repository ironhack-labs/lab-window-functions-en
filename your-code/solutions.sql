use sakila;
-- 1. Calculate the average rental duration (in days) for each film:
select 
	title,
    avg(rental_duration) over () as avg_duration
from film;

-- 2. Calculate the average payment amount for each staff member:
select distinct
	staff_id,
    avg(amount) over() as avg_payment
from payment;

-- 3. Calculate the total revenue for each customer, showing the running total within each customer's rental history:
select distinct
    payment.customer_id,
    sum(payment.amount) over (partition by payment.customer_id) as total_amount
from payment
	inner join rental on rental.customer_id = payment.customer_id;
    
-- 4. Determine the quartile for the rental rates of films:
select
	title,
	ntile(4) over(order by rental_rate) as quartile
from film;

-- 5. Determine the first and last rental date for each customer:
select distinct
	customer_id,
    min(rental_date) over(partition by customer_id) as first_rental_date,
    max(rental_date) over(partition by customer_id) as last_rental_date
from rental;

-- 6. Calculate the rank of customers based on their rental counts:
with rental_count as (
	select distinct 
		customer_id,
		count(rental_id) as total_rents
    from rental
    group by customer_id
)

select
	customer_id,
    total_rents,
    rank() over (order by total_rents desc) as rank_rents
from rental_count;

-- 7. Calculate the running total of revenue per day for the 'Family' film category:
with daily_revenue as (
	select
		film.title,
        rental.rental_date,
        payment.amount
    from film
		left join film_category on film_category.film_id = film.film_id
        left join category on category.category_id = film_category.category_id
        left join inventory on inventory.film_id = film.film_id
        left join rental on rental.inventory_id = inventory.inventory_id
        left join payment on payment.rental_id = rental.rental_id
	where category.name = 'Family'
)

select
	title,
    rental_date,
    sum(amount) over(partition by rental_date order by rental_date) as daily_revenue
from daily_revenue;


-- 8. Assign a unique ID to each payment within each customer's payment history:
select
	customer_id,
    payment_id,
    row_number() over(partition by customer_id order by payment_date) as unique_payment_id_per_customer
from payment;


-- 9. Calculate the difference in days between each rental and the previous rental for each customer
select
	customer_id,
    rental_id,
    rental_date,
    lag(rental_date) over (partition by customer_id order by rental_date) as previous_rental_date,
    datediff (rental_date, lag(rental_date) over (partition by customer_id order by rental_date)) as days_between_rentals
from rental
order by customer_id, rental_date
	




