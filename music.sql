create database music;

use music;

create table album
	(	album_id int primary key,	
        title varchar(110),	
        artist_id	int
        );
        
drop table album;

select * from album;

-- Q1. Who is the senior most employee based on job title?

select * from employee
order by levels desc
limit 1;

-- Q2. Which countries have the most invoices?

select count(*)as c, billing_country 
from invoice
group by billing_country
order by c desc
limit 1;


-- Q3. What are top 3 values of total invoice.

select total from invoice
order by total desc
limit 3;

-- Q4. Which city has the best customers? We would like to throw a promotoional Music Festival in the city we made the most money.
--  write a query that reurns one city that has the higest sum of invoice totas. return both the city name & sum of all invoice totals.alter

select sum(total) as invoice_total, billing_city 
from invoice 
group by billing_city
order by invoice_total desc
limit 1;


-- Q5. Who is the best customer ? the customer who has spent the most money will be declared the best customer
-- Write a query that returns the person who has spent the most money.

SELECT customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total)as total
FROM customer
JOIN invoice 
on customer.customer_id = invoice.customer_id
group by 1,2,3
order by total desc
limit 1;

-- MODERATE QUESTIONS

-- Q1. Write query to return the email, first name, last name, & Genre of all rock music listeners. 
-- Return your list ordered alphabetically by email starting with A. 
use music;
select * from genre;
 
select  distinct c.email, c.first_name, c.last_name
from customer as c
join invoice as i
on c.customer_id = i.customer_id		
join invoice_line
on i.invoice_id = invoice_line.invoice_id

where track_id in (
					select track_id from track
                    join genre
                    on track.genre_id = genre.genre_id
                    where genre.name like 'rock'
                    )
order by email;
			
-- Q.2 - let's invite the artist who have written the most rock music in our dataset.
-- write a query that returns the artist name and total track count of the top 10 rock bands.

select * from track;
use music;

select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track
join album2
on album2.album_id = track.album_id
join artist
on artist.artist_id = album2.artist_id
join genre
on genre.genre_id = track.genre_id
where genre.name like 'rock'
group by artist.artist_id, artist.name
order by number_of_songs desc
limit 10;


-- Q.4- return all the track names that have a song length longer than the avg song length.
-- return the name and miliseconds for each track. Order by the song length with the longest songs listed first

select * from track;

select name, milliseconds 
from track 
where milliseconds > 
					(
					select avg(milliseconds) as avg_track_length
					from track
					)
order by milliseconds desc;

-- Advanced Questions

-- Q.1 - Find how much amount spent by each customer on artists.  write a query to return
-- customer name, artist name and total spent.

with best_artists as
(select artist.artist_id as artist_id, artist.name as artist_name, sum(invoice_line.unit_price*invoice_line.quantity)  as total_sales
from invoice_line
join track
on track.track_id = invoice_line.track_id
join album2
on album2.album_id = track.album_id 
join artist
on artist.artist_id = album2.artist_id  
group by 1,2
order by 3 desc
limit 1
)
select customer.customer_id, customer.first_name, customer.last_name, best_artists.artist_name, sum(invoice_line.unit_price*invoice_line.quantity) as amnt_spent
from invoice
join customer
on customer.customer_id = invoice.customer_id
join invoice_line
on invoice_line.invoice_id = invoice.invoice_id
join track
on track.track_id = invoice_line.track_id 
join album2
on album2.album_id = track.album_id
join best_artists
on best_artists.artist_id = album2.artist_id
group by 1,2,3,4
order by 5 desc;


-- Q.2 - We want to find out most popular genre for each country . we determine the most popular genre as the 
-- genre with the highest amuont of purchases. write a query that returns each country along wth the top genre.
-- for countries where the maximum number of purchases is shared return all genre.



select * from invoice_line;


select c.country, genre.name, count(invoice_line.quantity) as purchases
from invoice_line
join track
on track.track_id = invoice_line.track_id
join invoice
on invoice.invoice_id = invoice_line.invoice_id
join customer as c
on c.customer_id = invoice.customer_id
join genre 
on genre.genre_id = track.genre_id
group by 1,2
order by count(invoice_line.quantity) desc;


-- Q.3 - Write a query that determines the customer that has spent the most on music for each country.
-- write a query that returns the country along with the top customer and how much they spent. For ountries 
-- where the top amount spent is shared, provide all customers who spent this amount

select * from invoice;

WITH RECURSIVE customer_with_country AS(
		SELECT customer.customer_id,first_name,last_name, invoice.billing_country, sum(total) as total_spending
        from invoice
        join customer
        on customer.customer_id = invoice.customer.id
        group by 1,2,3,4
		order by 2,3 desc),
        country_max_spending as(
		select billing_country, max(total_spending) as max_spending
        from customer_with_country
        group by billing_country)
        
select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name
from customer_with_country cc
join country_max_sepnding
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1;


















