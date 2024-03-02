
--1. What range of years for baseball games played does the provided database cover?


SELECT MIN(yearid) as starting_year,
		MAX (yearid) as latest_year
FROM teams
MAX yearid - MIN yearid

--answer: 1871; 2016




--2.Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?


SELECT playerid, namefirst, namelast, height
FROM people
ORDER BY height ASC
LIMIT 1;

SELECT g_all, teamid
FROM appearances
WHERE playerid = 'gaedeed01'


-- another way 
SELECT p.namefirst,
	p.namelast,
	MIN(p.height) height_in_inches,
	a.g_all AS games_played,
	teams.name
FROM people as p
LEFT JOIN appearances as a
ON p.playerid = a.playerid
LEFT JOIN teams
ON a.teamid = teams.teamid
GROUP BY p.namefirst, p.namelast, p.height, a.g_all, teams.name
ORDER BY p.height ASC
LIMIT 1;


--3.Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

(SELECT DISTINCT playerid
FROM public.collegeplaying
WHERE schoolid = 'vandy')

SELECT namefirst, namelast,SUM (s.salary) 
FROM people
	INNER JOIN salaries as s
	USING (playerid)
WHERE playerid IN (SELECT DISTINCT playerid
				   FROM public.collegeplaying
				   WHERE schoolid = 'vandy')
GROUP BY namefirst, namelast



SELECT *
FROM public.schools
WHERE schoolname = 'Vanderbilt University'

--answer: "David Price"; 245553888

--4.Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT
	SUM(po),
	CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
	ELSE 'Infield' END AS defensive_position
FROM fielding
WHERE yearid = 2016 AND pos IS NOT NULL
GROUP BY defensive_position;


--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT *
FROM public.pitching

SELECT (FLOOR(yearid / 10) * 10) AS decade,
		ROUND (avg (so / g),2) as avg_so
FROM public.pitching
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade

SELECT (FLOOR(yearid / 10) * 10) AS decade,
		ROUND (avg (hr / g),2) as avg_hr
FROM public.pitching
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade

--answer: the avg runs go up and down as the number of strikers go up or down



--6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.

SELECT *
FROM batting
SELECT *
FROM people


SELECT
	   p.namefirst,
	   p.namelast,
	   ROUND(CAST(b.sb AS DECIMAL) / CAST((b.sb + b.cs) AS DECIMAL), 2) as attempt
FROM batting as b
INNER JOIN people as p
USING (playerid)
WHERE (b.sb + b.cs) >= 20 AND
	  yearid = 2016
ORDER BY attempt DESC
LIMIT 1





7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT *
FROM teams


SELECT name, w 
FROM teams
WHERE wswin = 'N'
ORDER BY w DESC 
LIMIT 1


SELECT name, w 
FROM teams
WHERE wswin = 'Y'
ORDER BY w ASC
LIMIT 1

--answer:"Seattle Mariners" 116
--answer:"Los Angeles Dodgers"63
-- BELOW: Previous Answers with Year
SELECT name, w 
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 
	  AND wswin = 'N'
ORDER BY w DESC 
LIMIT 1

SELECT name, w 
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 
	  AND wswin = 'Y'
ORDER BY w ASC
LIMIT 1




--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). 
--   Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT *
FROM homegames

SELECT sum (attendance)/ sum(games) AS average_attendance, team, park
FROM homegames
WHERE year = 2016 AND games >= 10
GROUP BY team, park
ORDER BY average_attendance DESC


--9.Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
SELECT * 
FROM managers
SELECT * 
FROM awardsmanagers


SELECT DISTINCT(playerid), namefirst, namelast, teamid
FROM awardsmanagers as a
INNER JOIN people
USING (playerid)
INNER JOIN managers
USING (playerid)
WHERE awardid = 'TSN Manager of the Year' AND a.lgid = 'AL' AND playerid IN (
    SELECT playerid
    FROM awardsmanagers as a
    INNER JOIN people
	USING (playerid)
	INNER JOIN managers
	USING (playerid)
	WHERE awardid = 'TSN Manager of the Year' AND a.lgid = 'NL'
)


--10.Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

SELECT * 
FROM batting

SELECT playerid, namefirst, namelast, hr
FROM batting 
INNER JOIN people
USING (playerid)
INNER JOIN (
  SELECT playerid, count (yearid) as yearsplayed
  FROM batting
  INNER JOIN people as p
  USING (playerid)
  GROUP BY playerid
  HAVING count (yearid)  >= 10
) years
USING (playerid)
WHERE yearid= 2016 AND hr > 0
ORDER BY hr DESC





SELECT namefirst, namelast, count (yearid) as yearsplayed, hr
FROM batting
INNER JOIN people as p
USING (playerid)
GROUP BY p.namefirst, p.namelast, hr
HAVING count (yearid)  >= 10 AND hr IN (
	SELECT hr
	FROM batting
	INNER JOIN people
	USING (playerid)
WHERE yearid= 2016)