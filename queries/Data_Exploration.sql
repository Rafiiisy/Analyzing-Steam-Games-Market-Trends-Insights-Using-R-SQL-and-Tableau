/*
Steam Games Data Exploration

Skills Used: Aggregate Functions, Joins, CTEs, Temp Tables, Creating Views, Data Formatting
*/

-- 1. Selecting Data for Exploration
SELECT Name, `Release date`, Price, Genres, Publishers, Developers
FROM steam_games_cleaned
WHERE Price IS NOT NULL
ORDER BY `Release date` ASC;


-- 2. Counting Total Games
SELECT COUNT(*) AS TotalGames
FROM steam_games_cleaned;


-- 3. Analyzing Games by Genre
SELECT Genres, COUNT(*) AS TotalGames
FROM steam_games_cleaned
GROUP BY Genres
ORDER BY TotalGames DESC;


-- 4. Average Price by Genre
SELECT Genres, AVG(Price) AS AveragePrice
FROM steam_games_cleaned
WHERE Price IS NOT NULL
GROUP BY Genres
ORDER BY AveragePrice DESC;


-- 5. Most Prolific Developers
SELECT Developers, COUNT(*) AS TotalGames
FROM steam_games_cleaned
GROUP BY Developers
ORDER BY TotalGames DESC
LIMIT 10;


-- 6. Games with the Highest Prices
SELECT Name, Price, Genres, Publishers
FROM steam_games_cleaned
WHERE Price IS NOT NULL
ORDER BY Price DESC
LIMIT 5;


-- 7. Distribution of Games by Release Year
SELECT YEAR(`Release date`) AS ReleaseYear, COUNT(*) AS TotalGames
FROM steam_games_cleaned
WHERE `Release date` IS NOT NULL
GROUP BY ReleaseYear
ORDER BY ReleaseYear ASC;


-- 8. Average Price of Games by Publisher
SELECT Publishers, AVG(Price) AS AveragePrice
FROM steam_games_cleaned
WHERE Price IS NOT NULL
GROUP BY Publishers
ORDER BY AveragePrice DESC
LIMIT 10;


-- 9. Games Available on Multiple Platforms
SELECT 
  CASE 
    WHEN Windows = 1 AND Mac = 1 AND Linux = 1 THEN 'Windows/Mac/Linux'
    WHEN Windows = 1 AND Mac = 1 THEN 'Windows/Mac'
    WHEN Windows = 1 THEN 'Windows'
    WHEN Mac = 1 THEN 'Mac'
    WHEN Linux = 1 THEN 'Linux'
    ELSE 'Other'
  END AS Platform,
  COUNT(*) AS TotalGames
FROM steam_games_cleaned
GROUP BY Platform
ORDER BY TotalGames DESC;


-- 10. Creating a View for Popular Genres
CREATE VIEW GenrePopularity AS
SELECT Genres, COUNT(*) AS TotalGames
FROM steam_games_cleaned
GROUP BY Genres
ORDER BY TotalGames DESC;

-- Query the View
SELECT * FROM GenrePopularity;


-- 11. Using CTE to Find High-Value Publishers
WITH PublisherPrices AS (
  SELECT Publishers, AVG(Price) AS AveragePrice
  FROM steam_games_cleaned
  WHERE Price IS NOT NULL
  GROUP BY Publishers
)
SELECT *
FROM PublisherPrices
ORDER BY AveragePrice DESC
LIMIT 10;


-- 12. Using a Temp Table for Tag Analysis
DROP TEMPORARY TABLE IF EXISTS TagAnalysis;
CREATE TEMPORARY TABLE TagAnalysis AS
SELECT Name, LENGTH(Tags) - LENGTH(REPLACE(Tags, ',', '')) + 1 AS TagCount
FROM steam_games_cleaned;

-- Query the Temp Table
SELECT *
FROM TagAnalysis
ORDER BY TagCount DESC
LIMIT 10;

-- 13. Ranking Games by Price Using Window Functions
SELECT Name, Price, Genres, 
       RANK() OVER (ORDER BY Price DESC) AS PriceRank
FROM steam_games_cleaned
WHERE Price IS NOT NULL
LIMIT 10;


-- 14. Percentage of Games Per Platform
SELECT Platform, COUNT(*) AS TotalGames,
       ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER (), 2) AS PlatformPercentage
FROM (
    SELECT Name, 
           CASE 
               WHEN Windows = 1 AND Mac = 1 AND Linux = 1 THEN 'Windows/Mac/Linux'
               WHEN Windows = 1 AND Mac = 1 THEN 'Windows/Mac'
               WHEN Windows = 1 THEN 'Windows'
               WHEN Mac = 1 THEN 'Mac'
               WHEN Linux = 1 THEN 'Linux'
               ELSE 'Other'
           END AS Platform
    FROM steam_games_cleaned
) AS PlatformSummary
GROUP BY Platform
ORDER BY PlatformPercentage DESC;


-- 15. Exporting Release Year Data for Visualization
SELECT YEAR(`Release date`) AS ReleaseYear, COUNT(*) AS TotalGames
FROM steam_games_cleaned
WHERE `Release date` IS NOT NULL
GROUP BY ReleaseYear
ORDER BY ReleaseYear ASC
INTO OUTFILE '/var/lib/mysql-files/release_year_distribution.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n';

