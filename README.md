# Netflix_SQLproject

. Count the number of Movies vs TV Shows
```sql
SELECT type, COUNT(*) AS total
FROM netflix_titles
GROUP BY type;
```
