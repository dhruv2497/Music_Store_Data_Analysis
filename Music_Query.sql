--							/-Question Set 1 - Easy-/

-- Q1.) Who is the senior most employee based on Job Title?
SELECT employee_id,
		first_name,
		last_name
From employee
WHERE reports_to IS NULL;

-- Q2.) Which Countries have most Invoices?
SELECT billing_country, 
		COUNT(*) as invoice_counts 
FROM invoice
GROUP BY billing_country
ORDER BY invoice_counts DESC
LIMIT 1;

-- Q3.) What are top 3 values of total invoice? 
SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Q4.) Which city has the best customers? We would like to throw a promotional Music
-- Festival in the city we made the most money. Write a query that returns one city that
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice
-- totals?
SELECT billing_city as city_name,
		ROUND(SUM(total)::numeric, 2) as invoice_totals 
FROM invoice
GROUP BY billing_city
ORDER BY invoice_totals DESC
LIMIT 1;

-- Q5.) Who is the best customer? The customer who has spent the most money will be
-- declared the best customer. Write a query that returns the person who has spent the
-- most money?
SELECT cus.customer_id,
		cus.first_name || ' ' || cus.last_name as full_name,
		ROUND(SUM(inv.total::numeric),2) as totals 
FROM customer as cus
INNER JOIN invoice as inv ON inv.customer_id = cus.customer_id
GROUP BY cus.customer_id
ORDER BY totals DESC
LIMIT 1;



--							/-Question Set 2 – Moderate-/

-- Q1.) Write query to return the email, first name, last name, & Genre of all Rock Music
-- listeners. Return your list ordered alphabetically by email starting with A?

SELECT DISTINCT cus.email,
				cus.first_name, 
				cus.last_name, 
				ge.name 
FROM track as tr
INNER JOIN genre as ge ON ge.genre_id = tr.genre_id
INNER JOIN invoice_line as invl ON invl.track_id = tr.track_id
INNER JOIN invoice as inv ON inv.invoice_id = invl.invoice_id
INNER JOIN customer as cus ON inv.customer_id = cus.customer_id
WHERE ge.name ILIKE 'Rock'
ORDER BY cus.email;

-- Q2.) Let's invite the artists who have written the most rock music in our dataset. Write a
-- query that returns the Artist name and total track count of the top 10 rock bands?
SELECT ar.artist_id,
		ar.name,
		COUNT(track_id) as track_count
FROM artist as ar
INNER JOIN album as al ON al.artist_id = ar.artist_id
INNER JOIN track as tr ON tr.album_id = al.album_id
INNER JOIN genre as ge ON tr.genre_id = ge.genre_id
WHERE ge.name ILIKE 'Rock'
GROUP BY ar.artist_id
ORDER BY track_count DESC
LIMIT 10;

-- Q3.) Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length with the
-- longest songs listed first?
SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds)
					  FROM track
					  )
ORDER BY milliseconds DESC;



-- 							/-Question Set 3 – Advance-/

-- Q1. Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent?
SELECT cus.customer_id, 
		cus.first_name || ' ' || cus.last_name as name,
		ar.name, ROUND(SUM(inv.total)::numeric, 2) as total_spent
FROM artist as ar
INNER JOIN album as al ON al.artist_id = ar.artist_id
INNER JOIN track as tr ON tr.album_id = al.album_id
INNER JOIN invoice_line as invl ON invl.track_id = tr.track_id
INNER JOIN invoice as inv ON inv.invoice_id = invl.invoice_id
INNER JOIN customer as cus ON cus.customer_id = inv.customer_id
GROUP BY cus.customer_id, ar.name
ORDER BY cus.customer_id, ar.name;

-- Q2.) We want to find out the most popular music Genre for each country. We determine the
-- most popular genre as the genre with the highest amount of purchases. Write a query
-- that returns each country along with the top Genre. For countries where the maximum
-- number of purchases is shared return all Genres?
WITH country_genre as
		(SELECT inv.billing_country as country,
		ge.name as genre,
		COUNT(*) as total_purchase,
		DENSE_RANK() OVER (PARTITION BY inv.billing_country ORDER BY COUNT(*) DESC) as ranking
FROM invoice as inv
INNER JOIN invoice_line as invl 
ON inv.invoice_id = invl.invoice_id
INNER JOIN track as tr
ON tr.track_id = invl.track_id
INNER JOIN genre as ge
ON ge.genre_id = tr.genre_id
GROUP BY inv.billing_country, ge.name
)
SELECT country,
		genre,
		total_purchase
FROM country_genre
WHERE ranking = 1;

-- Q3.) Write a query that determines the customer that has spent the most on music for each
-- country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shared, provide all
-- customers who spent this amount?
WITH country_top_customer as 
	(SELECT inv.billing_country as country,
		cus.customer_id,
		cus.first_name || ' ' || cus.last_name as Full_Name,
		ROUND(SUM(inv.total)::numeric, 2) as totals,
		DENSE_RANK() OVER (PARTITION BY inv.billing_country ORDER BY SUM(inv.total) DESC) as ranking
FROM invoice as inv
INNER JOIN customer as cus
ON cus.customer_id = inv.customer_id
GROUP BY inv.billing_country, cus.customer_id
)

SELECT country,
		customer_id,
		full_name,
		totals
FROM country_top_customer
WHERE ranking = 1
