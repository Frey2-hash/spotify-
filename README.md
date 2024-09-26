# Spotify Advanced SQL Project and Query Optimization Project
Project Category: Advanced
[Click Here to get Dataset](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset)

![Spotify Logo](https://github.com/Frey2-hash/spotify-/blob/main/spotify%20image.jpeg?raw=true)

## Overview
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **SQL**. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity (easy, medium, and advanced), and optimizing query performance. The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset.


## Project Steps

### 1. Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:
- `Artist`: The performer of the track.
- `Track`: The name of the song.
- `Album`: The album to which the track belongs.
- `Album_type`: The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

### 4. Querying the Data
After the data is inserted, various SQL queries were written to explore and analyze the data. Queries are categorized into **easy**, **medium**, and **advanced** levels to help progressively develop SQL proficiency.

#### Easy Queries
- Simple data retrieval, filtering, and basic aggregations.
  
#### Medium Queries
- More complex queries involving grouping, aggregation functions, and joins.
  
#### Advanced Queries
- Nested subqueries, window functions, CTEs, and performance optimization.

### 5. Query Optimization
In advanced stages, the focus shifts to improving query performance. Some optimization strategies include:
- **Indexing**: Adding indexes on frequently queried columns.
- **Query Execution Plan**: Using `SET STATISTICS TIME ON ` and `QUERY EXECUTION PLAN` to review and refine query performance.
  
---

## 15 Practice Questions

### Easy Level
1. Retrieve the names of all tracks that have more than 1 billion streams.

```sql
SELECT * FROM cleaned_dataset
WHERE stream > 1000000000;

```
2. List all albums along with their respective artists.
```sql
SELECT DISTINCT album, artist
FROM cleaned_dataset
ORDER BY 1;
```
3. Get the total number of comments for tracks where `licensed = TRUE`.

``` SQL

SELECT comments
FROM cleaned_dataset
WHERE licensed = 'TRUE';

SELECT SUM(comments) as 'total_comments'
FROM cleaned_dataset
WHERE licensed = 'TRUE';
```
4. Find all tracks that belong to the album type `single`.
``` sql
SELECT track
FROM cleaned_dataset
WHERE album_type = 'single';
```
   
5. Count the total number of tracks by each artist.
``` sql

SELECT *
FROM cleaned_dataset;

SELECT artist, COUNT(track) as t
FROM cleaned_dataset
GROUP BY artist ORDER BY 2;
```

### Medium Level
1. Calculate the average danceability of tracks in each album.

```sql
SELECT * FROM cleaned_dataset;

SELECT album, AVG(danceability) 
FROM cleaned_dataset
GROUP BY album
ORDER BY 2 DESC;
```
2. Find the top 5 tracks with the highest energy values.

```sql
SELECT * FROM cleaned_dataset;

SELECT track,MAX(energy)
FROM cleaned_dataset
GROUP BY track
ORDER BY MAX(energy) DESC
OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY; --Used instead of limit(MySQL)
```
3. List all tracks along with their views and likes where `official_video = TRUE`.

```sql
SELECT * FROM cleaned_dataset;

SELECT  track, 
SUM(views) AS total_views, 
SUM(likes) AS total_likes
FROM cleaned_dataset
WHERE official_video = 'TRUE'
GROUP BY track ORDER BY 3 DESC
;
```
4. For each album, calculate the total views of all associated tracks.

```sql

SELECT * FROM cleaned_dataset;

SELECT album, track, SUM(views) as total_views
FROM cleaned_dataset
GROUP BY album, track
ORDER BY 3 DESC;
```
5. Retrieve the track names that have been streamed on Spotify more than YouTube.

```sql

SELECT * FROM cleaned_dataset;


SELECT *
FROM
(
SELECT track,SUM(stream) as total_stream_s
FROM cleaned_dataset
WHERE most_played_on = 'spotify'
GROUP BY track) AS sp
INNER JOIN 
(
SELECT track,SUM(stream) as total_stream_y
FROM cleaned_dataset
WHERE most_played_on = 'Youtube'
GROUP BY track) AS yt

ON sp.track = yt.track
WHERE total_stream_s > total_stream_y
ORDER BY total_stream_s DESC;
```

### Advanced Level
1. Find the top 3 most-viewed tracks for each artist using window functions.

```sql
SELECT * FROM cleaned_dataset;

SELECT *
FROM
(
SELECT artist,track, SUM(views) AS total_views, DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC)AS ranking
FROM cleaned_dataset
GROUP BY artist,track) AS P
WHERE ranking BETWEEN 1 AND 3
;
```
2. Write a query to find tracks where the liveness score is above the average.

```sql
SELECT * FROM cleaned_dataset;

SELECT AVG(liveness)
FROM cleaned_dataset
;

SELECT *
FROM
(
SELECT track, liveness
FROM cleaned_dataset) AS lv
WHERE liveness > 0.193
ORDER BY liveness
;
```
3. **Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.**
```sql
SELECT * FROM cleaned_dataset;

WITH E_diff
AS(
SELECT album, MAX(energy) as t1, MIN(energy) as t2
FROM cleaned_dataset
GROUP BY album)
SELECT album, t2-t1 as energy_difference
FROM E_diff
ORDER BY 2 DESC
;
```
   
4. Find tracks where the energy-to-liveness ratio is greater than 1.2.

```sql
SELECT * FROM cleaned_dataset;

SELECT *
FROM
(
SELECT track, energy/liveness as e_to_l_ratio
FROM cleaned_dataset) as ratio
WHERE e_to_l_ratio > 1.2
ORDER BY e_to_l_ratio DESC
;

```
5. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

```sql
SELECT * FROM cleaned_dataset
ORDER BY 2;

SELECT track,views, likes, SUM(CAST(likes AS BIGINT)) OVER(ORDER BY views ) as cumulative_likes -- CAST SYNTAX --CAST(expression AS datatype(length))
FROM cleaned_dataset
;
```


 **Spotify Advanced SQL Project and Query Optimization** README, focusing on the query optimization task performed.

---

## Query Optimization Technique 

To improve query performance, I carried out the following optimization process:

- **Initial Query Performance Analysis Using the function `SET STATISTICS TIME ON`**
    - I began by analyzing the performance of a query using the `SET STATISTICS ON` function.
    - The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
        - Execution time (E.T.): **8 ms**
        - Parse time (P.T.): **3 ms**
    - Below is the **screenshot** of the `SET STATISTICS TIME ON` result before optimization:
      ![TIME Before Index](https://github.com/Frey2-hash/spotify-/blob/main/Time%20before%20index.png)

- **Index Creation on the `artist` Column**
    - To optimize the query performance, I created an index on the `artist` column. This ensures faster retrieval of rows where the artist is queried.
    - **SQL command** for creating the index:
      ```sql
      CREATE INDEX artist_index ON cleaned_dataset(artist);
      ```

- **Performance Analysis After Index Creation**
    - After creating the index, I ran the same query again and observed significant improvements in performance:
        - Execution time (E.T.): ** 1 ms**
        - Parse time (P.T.): ** 2 ms**
    - Below is the **screenshot** of the `SET STATISTICS TIME ON` result after index creation:
      ![TIME After Index](https://github.com/Frey2-hash/spotify-/blob/main/Time%20after%20Index.png)

- **Graphical Performance Comparison**
    - A graph illustrating the comparison between the initial query execution time and the optimized query execution time after index creation.
    - **Graph view** shows the significant drop in both execution and planning times:
      ![Performance Graph Before Index](https://github.com/Frey2-hash/spotify-/blob/main/Graph%20Before%20Index.png)
      ![Performance Graph After Index ](https://github.com/Frey2-hash/spotify-/blob/main/Graph%20After%20Index.png)

This optimization shows how indexing can drastically reduce query time, improving the overall performance of our database operations in the Spotify project.
---

## Technology Stack
- **Database**: Microsoft SQL
- **SQL Queries**: DDL, DML, Aggregations, Joins, Subqueries, Window Functions
- **Tools**:  Microsoft SQL (via SQL server management studio)
---



