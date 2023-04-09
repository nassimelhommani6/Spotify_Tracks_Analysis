
CREATE TABLE spotify_tracks (
  track_id VARCHAR(255),
  artists VARCHAR(255),
  album_name VARCHAR(255),
  track_name VARCHAR(255),
  popularity INT,
  duration_ms INT,
  explicit VARCHAR(255),
  danceability FLOAT,
  energy FLOAT,
  key_ INT,
  loudness FLOAT,
  mode INT,
  speechiness FLOAT,
  acousticness FLOAT,
  instrumentalness FLOAT,
  liveness FLOAT,
  valence FLOAT,
  tempo FLOAT,
  time_signature INT,
  track_genre VARCHAR(255)
);
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'C:/Users/Nassim/Desktop/Data_ Analytics_Certificate/Nassim Portfolio project/Spotify Tracks project/dataset.csv'
INTO TABLE spotify_tracks
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS ;

-- A) Data Cleaning--

Select * FROM spotify_tracks ; 
-- 1) checking for nulls 
SELECT 
   SUM(CASE WHEN track_id IS NULL THEN 1 ELSE 0 END) AS track_id_null_count,
   SUM(CASE WHEN artists IS NULL THEN 1 ELSE 0 END) AS artists_null_count,
    SUM(CASE WHEN album_name IS NULL THEN 1 ELSE 0 END) AS albumname_null_count,
    SUM(CASE WHEN track_name IS NULL THEN 1 ELSE 0 END) AS trackname_null_count
FROM spotify_tracks ;

-- 2) remove inconsistent character from title ,director , cast and description--

SELECT track_id , CONVERT(CAST(CONVERT(track_id USING latin1) AS BINARY) USING utf8mb4) COLLATE utf8mb4_general_ci
from spotify_tracks ;
SELECT artists , CONVERT(CAST(CONVERT(artists USING latin1) AS BINARY) USING utf8mb4) COLLATE utf8mb4_general_ci AS artists_correction
from spotify_tracks ;
SELECT album_name , CONVERT(CAST(CONVERT(album_name USING latin1) AS BINARY) USING utf8mb4) COLLATE utf8mb4_general_ci
from spotify_tracks ;
SELECT track_name , CONVERT(CAST(CONVERT(track_name USING latin1) AS BINARY) USING utf8mb4) COLLATE utf8mb4_general_ci
from spotify_tracks ;

-- update table --
UPDATE spotify_tracks
SET track_id = CONVERT(CAST(CONVERT(track_id USING latin1) AS BINARY) USING utf8mb4) COLLATE utf8mb4_general_ci;
UPDATE spotify_tracks
SET artists = CONVERT(CAST(CONVERT(artists USING latin1) AS BINARY) USING utf8mb4) COLLATE utf8mb4_general_ci;
UPDATE spotify_tracks
SET album_name = CONVERT(CAST(CONVERT(album_name USING latin1) AS BINARY) USING utf8mb4) COLLATE utf8mb4_general_ci;
UPDATE spotify_tracks
SET  track_name = CONVERT(CAST(CONVERT( track_name USING latin1) AS BINARY) USING utf8mb4) COLLATE utf8mb4_general_ci;


-- 3) checking and removal of  duplicates
SELECT
  COUNT(*) - COUNT(DISTINCT track_id ) AS track_id_duplicates,
  COUNT(*) - COUNT(DISTINCT artists) AS artists_duplicates,
  COUNT(*) - COUNT(DISTINCT album_name) AS albumname_duplicates,
  COUNT(*) - COUNT(DISTINCT track_name) AS track_name_duplicates,
  COUNT(*)-COUNT(DISTINCT track_genre) AS track_genre_duplicates
  FROM spotify_tracks ;     -- even if we have that duplicates in other column , the track id is different 

-- checking for duplicates record in all previous columns

SELECT track_id, artists, album_name, track_name, track_genre  ,count(*)
FROM spotify_tracks
GROUP BY track_id, artists, album_name, track_name, track_genre 
HAVING COUNT(*) > 1;

/* This query groups the records by the selected columns and then counts the number of records in each group. 
The HAVING COUNT(*) > 1 clause filters out groups that only have one record, leaving only the groups that have duplicates. 
The SELECT statement then returns the selected columns for the duplicate records. */

-- delete duplicated records 

DELETE FROM spotify_tracks
WHERE track_id IN (
    SELECT track_id FROM (
        SELECT track_id, artists, album_name, track_name, track_genre
        FROM spotify_tracks
        GROUP BY track_id, artists, album_name, track_name, track_genre
        HAVING COUNT(*) > 1
    ) AS duplicates
);
/* This query first creates a subquery that selects the duplicate records based on the combination 
of track_id, artists, album_name, track_name, and track_genre. 
It then creates a temporary table using this subquery, and selects only the track_id column from the temporary table. 
Finally, it deletes all records from the spotify_tracks table where the track_id is in the list of duplicate track_id values. 
This way, the subquery does not reference the same table as the outer query, and the error is avoided. */
 
