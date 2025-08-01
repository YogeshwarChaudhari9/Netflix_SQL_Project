create database Netfilx;
use Netfilx;
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/netflix_titles.csv"
INTO TABLE netflix
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SHOW VARIABLES LIKE 'secure_file_priv';

select * from netflix;

/* -- Business Problems and Solutions
1. Count the Number of Movies vs TV Shows */

select type, count(*) as Number_Of_movies 
from netflix group by 1;

/*2. Find the Most Common Rating for Movies and TV Shows*/
select 
	type,
    rating
from 
	(select 
		type,
		rating,
		count(*),
		rank() over(partition by type order by count(*) Desc) as ranking
	from netflix
	group by 1,2
) as t1
where ranking = 1;

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank_n
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank_n = 1;

/*3. List All Movies Released in a Specific Year (e.g., 2020)*/
select * 
from netflix
where 
	type = 'Movie' 
	and 
	release_year = 2020;

/* 4. Find the Top 5 Countries with the Most Content on Netflix */

select 
	substring_index(country, ',',1) as new_country,
    count(show_id) as total_content
from netflix 
where country IS NOT NULL AND TRIM(country) != ''
group by 1
order by 2 desc
limit 5 ;

/*5. Identify the Longest Movie*/

select * 
from netflix
where 
	type = 'Movie'
    and 
    duration = (select max(duration) from netflix);
    
/* 6. Find Content Added in the Last 5 Years */

SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

/*7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'*/

select * 
from netflix
where director 
like  '%Rajiv Chilaka';

/*8. List All TV Shows with More Than 5 Seasons*/

SELECT *
FROM netflix
WHERE duration LIKE '%Season%' and type = 'TV Show'
  AND CONVERT(SUBSTRING_INDEX(duration, ' ', 1), UNSIGNED) > 5;

/* 9. Count the Number of Content Items in Each Genre*/
-- listed in is genre col
/* SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;*/ -- for POSTSQL
select 
	substring_index(listed_in,',',1) as genre,
    count(show_id) as total_content
    -- substring_index(listed_in,',',1),
    -- substring_index(listed_in,',',2),
    -- substring_index(listed_in,',',3)
from Netfilx.netflix
group by 1; 

/* 10.Find each year and the average numbers of content release in India on netflix.*/

select
	year(str_to_date(date_added,'%M %d, %Y')) as year,
    count(*) as yewar_content,
    round(count(*) / (select count(*) from netflix where country = 'India') * 100 , 2)as avg_content_per_year
from netflix
where country = 'India'
group by 1;

/*11. List All Movies that are Documentaries*/

select * 
from netflix 
where listed_in like '%Documentaries%';

/* find all centent without a director */
select * 
from netflix
where director = "";

/* 13. find how many movies actor 'Salman Khan' appeared in last 10 year*/

select * from netflix
where casts like '%Salman Khan%'
and release_year >  year(curdate()) - 10;

/*14. find top 10 actors who have appeared in the highest number of movies produced in india*/

WITH RECURSIVE actor_split AS (
  SELECT 
    show_id,
    TRIM(SUBSTRING_INDEX(casts, ',', 1)) AS actor,
    SUBSTRING(casts, LENGTH(SUBSTRING_INDEX(casts, ',', 1)) + 2) AS remaining
  FROM netflix
  WHERE country like '%India%'
  and casts != ''
  
  UNION ALL
  
  SELECT 
    show_id,
    TRIM(SUBSTRING_INDEX(remaining, ',', 1)),
    SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
  FROM actor_split
  WHERE remaining != ''
)

SELECT actor, COUNT(*) AS appearances
FROM actor_split
where actor != ''
GROUP BY actor
ORDER BY appearances DESC
LIMIT 10;

/*15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in
the description field. Label content containing these keywords as 'Bad' and all other
content as 'Good'. Count how many items fall into each category.
*/


with new_table as (
select *,
case 
	when 
    description like '%kill%' or description like '%violence%' then 'Bad_content'
    else 'Good_Content'
end category
    from netflix)
select category,
count(*) as total_Content
from new_table
group by category;
