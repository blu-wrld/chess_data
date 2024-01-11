SELECT 
	*
FROM 
	chess_data
;


-- Win & Loss Rate
WITH outcome_count AS
	(SELECT
		CAST(SUM(CASE WHEN "wonBy" IS NOT NULL THEN 1
			ELSE 0 END)AS NUMERIC) AS win,
		CAST(COUNT(*) AS NUMERIC) AS games_played
	FROM	
		public.chess_data
	)
SELECT	
	ROUND(win/(games_played), 4) AS win_rate,
	ROUND((games_played - win)/games_played, 4) AS lose_rate
FROM 
	outcome_count;
	
-- Rate when playing with black
WITH black_outcome_count AS
	(SELECT
		CAST(SUM(CASE WHEN "wonBy" IS NOT NULL THEN 1
			ELSE 0 END)AS NUMERIC) AS win,
		CAST(COUNT(*) AS NUMERIC) AS games_played
	FROM	
		public.chess_data as c
	 WHERE
	 	c."userColor" = 'black'
	)
SELECT	
	ROUND(win/(games_played), 4) AS win_rate,
	ROUND((games_played - win)/games_played, 4) AS lose_rate
FROM 
	black_outcome_count;
	
-- Rate when playing with white
WITH white_outcome_count AS
	(SELECT
		CAST(SUM(CASE WHEN "wonBy" IS NOT NULL THEN 1
			ELSE 0 END)AS NUMERIC) AS win,
		CAST(COUNT(*) AS NUMERIC) AS games_played
	FROM	
		public.chess_data as c
	 WHERE
	 	c."userColor" = 'white'
	)
SELECT	
	ROUND(win/(games_played), 4) AS win_rate,
	ROUND((games_played - win)/games_played, 4) AS lose_rate
FROM 
	white_outcome_count;
	
	
-- Highest Elo opponent I beat by year-month
SELECT	
	EXTRACT (YEAR FROM date) AS year,
	EXTRACT (MONTH FROM date) AS month,
	MAX("opponentRating") as max_opp_elo_by_month
FROM 
	public.chess_data
WHERE
	"wonBy" IS NOT NULL
GROUP BY 
	year, month
ORDER BY 
	1, 2
;

-- Percentage of winning method
SELECT 
	DISTINCT "wonBy" as win_method,
	COUNT(*) as win_count,
	SUM(COUNT(*)) OVER() as total_wins,
	ROUND((COUNT(*)/SUM(COUNT(*)) OVER()), 4) as percentage
FROM 
	public.chess_data
WHERE 
	"wonBy" IS NOT NULL
GROUP BY 
	1
;

-- Percentage of losing method
SELECT 
	DISTINCT "result" as lose_method,
	COUNT(*) as lose_count,
	SUM(COUNT(*)) OVER() as total_loss,
	ROUND((COUNT(*)/SUM(COUNT(*)) OVER()), 4) as percentage
FROM 
	public.chess_data
WHERE 
	"wonBy" IS NULL
GROUP BY 
	1
;

-- Fastest I checkmated an opp
DELETE FROM chess_data WHERE ("endTime") < ("startTime");

SELECT 
	*,
	(("endTime") - ("startTime")) as time_diff
FROM 
	public.chess_data as c 
WHERE 
	c."wonBy" = 'checkmated'
ORDER BY 
	time_diff
LIMIT 1
;


-- Frequency of played openings (only show openings played 5 time or above)
SELECT 
	opening,
	COUNT(*) count
FROM 
	public.chess_data
GROUP BY 
	1
HAVING
	COUNT(*) >= 5
ORDER BY 
	2 DESC
;

-- Win rate of each opening (played 5 times or above)

SELECT
	opening,
	ROUND(CAST(SUM(CASE WHEN chess_data."wonBy" is not null then 1 else 0 end)AS NUMERIC)/
	CAST(COUNT(*)AS NUMERIC), 4) AS win_rate,
	COUNT(*) AS times_played
FROM
	public.chess_data
WHERE chess_data.opening IN
		(SELECT 
		opening
	FROM 
		public.chess_data
	GROUP BY 
		1
	HAVING
		COUNT(*) >= 5
		) 
GROUP BY 
	1
ORDER BY 
	2 DESC
;


-- My elo growth
SELECT 
	date,
	"userRating",
	"gameUrl"
FROM 
	chess_data
WHERE 
	"timeClass" = 'rapid'
ORDER BY 
	1 
;












