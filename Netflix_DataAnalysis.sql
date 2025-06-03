-- Netflix Shows Analysis

CREATE TABLE netflix (
    show_id VARCHAR(10),
    type VARCHAR(20),
    title VARCHAR(200),
    director VARCHAR(250),
    casts VARCHAR(1000),
    country VARCHAR(200),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(20),
    listed_in VARCHAR(200),
    description VARCHAR(250)
);


SELECT * FROM netflix;

SELECT COUNT(*) AS total FROM netflix;

SELECT DISTINCT TYPE FROM netflix;

-- 20 Problems

-- 1. Count the number of Movies vs TV Shows

SELECT type, COUNT(*) AS total
FROM netflix
GROUP BY type;


-- 2. Find the most common rating for movies and TV shows

SELECT type, rating, COUNT(*) AS count
FROM netflix
GROUP BY type, rating
ORDER BY type, count DESC;


-- 3. List all movies released in 2020

SELECT title, release_year
FROM netflix
WHERE release_year = 2020 AND type = 'Movie';


-- 4. Find the top 5 countries with the most content

SELECT country, COUNT(*) AS total
FROM netflix
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total DESC
LIMIT 5;


-- 5. Identify the top 10 actors who have appeared in the highest number of movies in Netflix

WITH actor_table AS (
  SELECT TRIM(actor_name) AS actor
  FROM netflix,
       UNNEST(string_to_array("casts", ',')) AS actor_name
  WHERE "casts" IS NOT NULL
)
SELECT actor, COUNT(*) AS appearances
FROM actor_table
GROUP BY actor
ORDER BY appearances DESC
LIMIT 10;


-- 6. Find content added in the last 5 years

SELECT title, date_added
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


-- 7. Find all movies/TV shows by director 'Toshiya Shinohara'

SELECT title, type
FROM netflix
WHERE director = 'Toshiya Shinohara';


-- 8. List all TV shows with more than 5 seasons

SELECT title, duration
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5;
  

-- 9. Count the number of content items in each genre

SELECT listed_in AS genre_combination, COUNT(*) AS total
FROM netflix
GROUP BY listed_in
ORDER BY total DESC;


-- 10. Find all movies that have the same rating as the most common TV Show rating

SELECT title, rating
FROM netflix
WHERE type = 'Movie'
  AND rating = (
    SELECT rating
    FROM netflix
    WHERE type = 'TV Show'
    GROUP BY rating
    ORDER BY COUNT(*) DESC
    LIMIT 1
  );


-- 11. Find the month with the highest number of new content

SELECT EXTRACT(MONTH FROM TO_DATE(date_added, 'Month DD, YYYY')) AS month,
       COUNT(*) AS count
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY month
ORDER BY count DESC
LIMIT 1;


-- 12. List content released before 2000 but added after 2015

SELECT title, release_year, date_added
FROM netflix
WHERE release_year < 2000
  AND TO_DATE(date_added, 'Month DD, YYYY') > DATE '2015-01-01';


-- 13. Find the average delay (in years) between release and addition

SELECT AVG(EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) - release_year) AS avg_delay_years
FROM netflix
WHERE date_added IS NOT NULL;


-- 14. List all content where the title starts and ends with the same letter

SELECT title
FROM netflix
WHERE LOWER(LEFT(title, 1)) = LOWER(SUBSTRING(title FROM LENGTH(title) FOR 1));


-- 15. List movies with more than one director

SELECT title, director
FROM netflix
WHERE director LIKE '%,%';


-- 16. Find countries where TV Shows > 75% of total content

SELECT country,
       COUNT(*) FILTER (WHERE type = 'TV Show') * 1.0 / COUNT(*) AS tv_ratio
FROM netflix
WHERE country IS NOT NULL
GROUP BY country
HAVING COUNT(*) FILTER (WHERE type = 'TV Show') * 1.0 / COUNT(*) > 0.75;


-- 17. Find the genre combination with the longest average movie duration

SELECT listed_in, AVG(CAST(REPLACE(duration, ' min', '') AS INTEGER)) AS avg_duration
FROM netflix
WHERE type = 'Movie' AND duration LIKE '%min'
GROUP BY listed_in
ORDER BY avg_duration DESC
LIMIT 1;


--18. List all content available in both India and United States

SELECT title, country
FROM netflix
WHERE country LIKE '%India%' AND country LIKE '%United States%';


--19. Categorize content as 'Good' or 'Bad' based on rating

SELECT title, rating,
       CASE
           WHEN rating IN ('G', 'PG', 'PG-13', 'TV-G', 'TV-PG', 'TV-Y', 'TV-Y7') THEN 'Good'
           ELSE 'Bad'
       END AS content_quality
FROM netflix
WHERE rating IS NOT NULL;


-- 20. Find directors who released content every year for at least 3 consecutive years

WITH director_years AS (
  SELECT DISTINCT director, release_year
  FROM netflix
  WHERE director IS NOT NULL
),
ranked_directors AS (
  SELECT director, release_year,
         release_year - ROW_NUMBER() OVER (PARTITION BY director ORDER BY release_year) AS grp
  FROM director_years
),
grouped_directors AS (
  SELECT director, COUNT(*) AS consecutive_years
  FROM ranked_directors
  GROUP BY director, grp
)
SELECT director
FROM grouped_directors
WHERE consecutive_years >= 3;









