
-- SPOTIFY ANALYSIS

-- DATA CREATED AND LOADED THROUGH IMPORT WIZARD

--SELECT * FROM dbo.cleaned_dataset;

--EXEC sp_help cleaned_dataset;

-- EDA

SELECT COUNT(*) FROM cleaned_dataset;
SELECT COUNT(DISTINCT artist) FROM cleaned_dataset;
SELECT DISTINCT album_type FROM cleaned_dataset;

SELECT MAX(duration_min)  FROM cleaned_dataset;
SELECT MIN(duration_min)  FROM cleaned_dataset;


DELETE 
  FROM cleaned_dataset
  WHERE duration_min= 0;

SELECT MIN(duration_min)  FROM cleaned_dataset;

SELECT DISTINCT channel FROM cleaned_dataset;

SELECT DISTINCT most_played_on FROM cleaned_dataset;

/*
--------------------------------------------------------
-- DATA ANALYSIS -- EASY CATEGORY
---------------------------------------------------------

1. Retrieve the names of all tracks that have more than 1 billion streams.
2. List all albums along with their respective artists.
3. Get the total number of comments for tracks where licensed = TRUE.
4. Find all tracks that belong to the album type single.
5. Count the total number of tracks by each artist.


*/

-- 1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT * FROM cleaned_dataset
WHERE stream > 1000000000;

-- 2. List all albums along with their respective artists.
SELECT DISTINCT album, artist
FROM cleaned_dataset
ORDER BY 1;

-- 3. Get the total number of comments for tracks where licensed = TRUE.
SELECT comments
FROM cleaned_dataset
WHERE licensed = 'TRUE';

SELECT SUM(comments) as 'total_comments'
FROM cleaned_dataset
WHERE licensed = 'TRUE';


-- 4. Find all tracks that belong to the album type single.
SELECT track
FROM cleaned_dataset
WHERE album_type = 'single';

-- 5. Count the total number of tracks by each artist.
SELECT *
FROM cleaned_dataset;

SELECT artist, COUNT(track) as t
FROM cleaned_dataset
GROUP BY artist ORDER BY 2;

-----------------------------------------------------------
-- Medium Level
-----------------------------------------------------------
/*
Calculate the average danceability of tracks in each album.
Find the top 5 tracks with the highest energy values.
List all tracks along with their views and likes where official_video = TRUE.
For each album, calculate the total views of all associated tracks.
Retrieve the track names that have been streamed on Spotify more than YouTube.
Advanced Level */

-- 1. Calculate the average danceability of tracks in each album.
SELECT * FROM cleaned_dataset;

SELECT album, AVG(danceability) 
FROM cleaned_dataset
GROUP BY album
ORDER BY 2 DESC;

--2. Find the top 5 tracks with the highest energy values.
SELECT * FROM cleaned_dataset;

SELECT track,MAX(energy)
FROM cleaned_dataset
GROUP BY track
ORDER BY MAX(energy) DESC
OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY; --Used instead of limit(mysql)

--3. List all tracks along with their views and likes where official_video = TRUE
SELECT * FROM cleaned_dataset;

SELECT  track, 
SUM(views) AS total_views, 
SUM(likes) AS total_likes
FROM cleaned_dataset
WHERE official_video = 'TRUE'
GROUP BY track ORDER BY 3 DESC
;

--4 For each album, calculate the total views of all associated tracks.
SELECT * FROM cleaned_dataset;

SELECT album, track, SUM(views) as total_views
FROM cleaned_dataset
GROUP BY album, track
ORDER BY 3 DESC;

-- 5 Retrieve the track names that have been streamed on Spotify more than YouTube.
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

----------------------------------------------------------
-- Advanced Level
----------------------------------------------------------
/*
1.Find the top 3 most-viewed tracks for each artist using window functions.
2.Write a query to find tracks where the liveness score is above the average.
3.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
4.Find tracks where the energy-to-liveness ratio is greater than 1.2.
5.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.*/

-- 1.Find the top 3 most-viewed tracks for each artist using window functions.
SELECT * FROM cleaned_dataset;

SELECT *
FROM
(
SELECT artist,track, SUM(views) AS total_views, DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC)AS ranking
FROM cleaned_dataset
GROUP BY artist,track) AS P
WHERE ranking BETWEEN 1 AND 3
;

-- 2.Write a query to find tracks where the liveness score is above the average.
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
-- 3.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album
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

-- 4.Find tracks where the energy-to-liveness ratio is greater than 1.2 
SELECT * FROM cleaned_dataset;

SELECT *
FROM
(
SELECT track, energy/liveness as e_to_l_ratio
FROM cleaned_dataset) as ratio
WHERE e_to_l_ratio > 1.2
ORDER BY e_to_l_ratio DESC
;

-- 5.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions
SELECT * FROM cleaned_dataset
ORDER BY 2;

SELECT track,views, likes, SUM(CAST(likes AS BIGINT)) OVER(ORDER BY views ) as cumulative_likes -- CAST SYNTAX --CAST(expression AS datatype(length))
FROM cleaned_dataset
;
