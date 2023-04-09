 
-- B) Data Analysis 

USE spotify ;
SELECT * FROM spotify_tracks;
-- 1) group data by genres 
SELECT *
FROM spotify_tracks
GROUP BY track_genre,album_name ;

-- 2) Analyze the duration times 
-- create a track_genre duration Median temporary table 
DROP TABLE IF exists Median_table ;
CREATE temporary table Median_table 
WITH duration_rank AS (
SELECT * , 
row_number() over(partition by track_genre order by duration_ms ASC) as row_nbr ,
PERCENT_RANK() OVER (partition by track_genre ORDER BY duration_ms ASC) AS percentile
FROM spotify_tracks  
GROUP BY track_genre,track_id,album_name,track_name 
) 
SELECT track_genre , AVG(duration_ms) as median_duration 
from duration_rank
WHERE percentile BETWEEN 0.5 AND 0.51 
GROUP BY track_genre
ORDER BY 1 ASC ;

-- **calculate AVG , STD ,Median duration in ms 
SELECT st.track_genre, 
ROUND(AVG(st.duration_ms),2) AS mean_duration, 
ROUND(STDDEV(st.duration_ms),2) AS std_duration,
ROUND(md.median_duration,2) as median_duration
FROM spotify_tracks as st
INNER JOIN Median_table as md
ON md.track_genre =st.track_genre 
GROUP BY 1 ;

-- 3) Analyze the sound of each genre 
SELECT track_genre, AVG(danceability) AS avg_danceability, 
ROUND(AVG(energy),3) AS avg_energy, 
ROUND(AVG(speechiness),3) AS avg_speechiness, 
ROUND(AVG(acousticness),3) AS avg_acousticness, 
ROUND(AVG(instrumentalness),3) AS avg_instrumentalness, 
ROUND(AVG(liveness),3) AS avg_liveness, 
ROUND(AVG(valence),3) AS avg_valence
FROM spotify_tracks 
GROUP BY track_genre;

-- 4) do characteristics of popular songs vary across genres
SELECT track_genre, 
ROUND(AVG(popularity),2) AS avg_popularity, 
ROUND(AVG(danceability),3) AS avg_danceability, 
ROUND(AVG(energy),3) AS avg_energy, 
ROUND(AVG(speechiness),3) AS avg_speechiness, 
ROUND(AVG(acousticness),3) AS avg_acousticness, 
ROUND(AVG(instrumentalness),3) AS avg_instrumentalness, 
ROUND(AVG(liveness),3) AS avg_liveness, 
ROUND(AVG(valence),3) AS avg_valence
FROM spotify_tracks
GROUP BY track_genre
ORDER BY avg_popularity DESC;



