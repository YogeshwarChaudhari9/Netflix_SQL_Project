# Netflix Data Exploration & Analytics (MySQL)
![Netflix_logo](https://github.com/YogeshwarChaudhari9/Netflix_SQL_Project/blob/main/Nexflixlogo.jpeg)

# Netflix Movies and TV Shows Data Analysis using SQL

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
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
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
select type, count(*) as Number_Of_movies 
from Netflix group by 1;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
select * 
from netflix
where 
	type = 'Movie' 
	and 
	release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
select 
	substring_index(country, ',',1) as new_country,
    count(show_id) as total_content
from netflix 
where
    country IS NOT NULL AND TRIM(country) != ''
group by 1
order by 2 desc
limit 5 ;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
select * 
from netflix
where 
	type = 'Movie'
    and 
    duration = (select max(duration) from netflix);
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
select * 
from netflix
where director 
like  '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflix
WHERE duration LIKE '%Season%'
      and type = 'TV Show'
      and CONVERT(SUBSTRING_INDEX(duration, ' ', 1), UNSIGNED) > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
select 
	substring_index(listed_in,',',1) as genre,
    count(show_id) as total_content
from Netflix
group by 1;
```

**Objective:** Count the number of content items in each genre.

### 10. Find each year and the average number of content releases in India on Netflix. 
Return the top 5 years with highest average content release!

```sql
select
	year(str_to_date(date_added,'%M %d, %Y')) as year,
    count(*) as yewar_content,
    round(count(*) / (select count(*) from netflix where country = 'India') * 100 , 2)as avg_content_per_year
from netflix
where country = 'India'
group by 1;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
select * 
from netflix 
where listed_in like '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
select * 
from netflix
where director = "";
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
select *
from netflix
where
    casts like '%Salman Khan%'
    and release_year >  year(curdate()) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
with new_table as (
select *,
case 
	when 
    description like '%kill%' or description like '%violence%' then 'Bad_content'
    else 'Good_Content'
end category
    from Netflix)
select category,
count(*) as total_Content
from new_table
group by category;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Yogeshwar Chaudhari
This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. 


