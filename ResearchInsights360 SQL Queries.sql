
CREATE DATABASE ResearchInsightDB;
GO

USE ResearchInsightDB;
GO

SELECT COUNT(*) AS Total_Records
FROM dbo.ResearchInsight360

-- Project Name: Market Research Analytics & Customer Insights using SQL Server
-- ResearchInsight 360 – Interview-Level SQL Queries
-- Level 1: SQL Fundamentals

-- 1. SELECT – Display records

SELECT TOP 10 * 
FROM DBO.ResearchInsight360

-- 2. WHERE – Filter data
-- Find Healthcare industry records.

SELECT *
FROM dbo.ResearchInsight360
WHERE Industry = 'Healthcare'

-- 3. DISTINCT – Find unique industries

SELECT DISTINCT Industry
FROM DBO.ResearchInsight360

-- 4.ORDER BY – Top 10 project budgets

SELECT DISTINCT
	Project_ID,
	Project_Name,
	Project_Budget_USD
FROM DBO.ResearchInsight360
ORDER BY Project_Budget_USD DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY

-- 5. BETWEEN – Budget range

SELECT DISTINCT
	Project_ID,
	Project_Name,
	Project_Budget_USD
FROM DBO.ResearchInsight360
WHERE Project_Budget_USD BETWEEN 50000 AND 100000

-- Level 2: Aggregate Functions
-- 6. COUNT – Total survey responses

SELECT COUNT(*) AS Total_Responses
FROM DBO.ResearchInsight360

-- 7. SUM – Total survey incentives

SELECT SUM(Incentive_USD) AS Total_Incentives
FROM DBO.ResearchInsight360

-- 8. AVG – Average satisfaction rating

SELECT
    AVG(CAST(Satisfaction_Rating AS DECIMAL(10,2)))
        AS Average_Rating
FROM dbo.ResearchInsight360

-- 9. GROUP BY – Responses by industry

SELECT
	Industry,
	COUNT(*) AS Total_Responses
FROM DBO.ResearchInsight360
GROUP BY Industry
ORDER BY Total_Responses DESC

-- 10. HAVING – Industries with more than 20,000 responses

SELECT
	Industry,
	COUNT(*) AS Total_Responses
FROM DBO.ResearchInsight360
GROUP BY Industry
HAVING COUNT(*) > 20000

-- Level 3: Interview SQL Queries
-- 11. CASE WHEN – Rating category

SELECT
	Response_ID,
	Satisfaction_Rating,

	CASE
		WHEN Satisfaction_Rating >= 4 THEN 'Satisfied'
		WHEN Satisfaction_Rating = 3 THEN 'Neutral'
		ELSE 'Dissatisfied'
	END AS Customer_Category

FROM DBO.ResearchInsight360

-- 12. Find duplicate Response IDs

SELECT
    Response_ID,
    COUNT(*) AS Duplicate_Count
FROM dbo.ResearchInsight360
GROUP BY Response_ID
HAVING COUNT(*) > 1

-- 13. Find average rating by industry

SELECT
	Industry,
	AVG(CAST(Satisfaction_Rating AS decimal(10,2)))
		AS Average_Rating
FROM DBO.ResearchInsight360
GROUP BY Industry
ORDER BY Average_Rating DESC

-- 14. Find the highest revenue project
-- Important: Use DISTINCT because revenue repeats for each response.

SELECT TOP 1
	Project_ID,
	Project_Name,
	Contract_Revenue_USD
FROM DBO.ResearchInsight360
ORDER BY Contract_Revenue_USD DESC

-- 15. Find projects above average budget

SELECT DISTINCT
    Project_ID,
    Project_Name,
    Project_Budget_USD
FROM dbo.ResearchInsight360
WHERE Project_Budget_USD >
(
    SELECT AVG(Project_Budget_USD)
    FROM dbo.ResearchInsight360
);

-- Level 4: Advanced SQL – Most Important
-- 16. ROW_NUMBER – Rank projects by revenue

WITH ProjectData AS
(
	SELECT DISTINCT
		Project_ID,
		Project_Name,
		Contract_Revenue_USD
	FROM DBO.ResearchInsight360
)
SELECT
	Project_ID,
	Project_Name,
	Contract_Revenue_USD,

	ROW_NUMBER() OVER
	(
		ORDER BY Contract_Revenue_USD DESC
	) AS Revenue_Rank

FROM ProjectData

-- 17. RANK – Rank projects by budget

WITH ProjectData AS
(
	SELECT DISTINCT
		Project_ID,
		Project_Name,
		Project_Budget_USD
	FROM DBO.ResearchInsight360
)
SELECT
	Project_ID,
	Project_Name,
	Project_Budget_USD,

	RANK() OVER
	(
		ORDER BY Project_Budget_USD DESC
	) AS Budget_Rank

FROM ProjectData;


-- 18. LAG – Compare monthly responses

WITH MonthlyData AS
(
    SELECT
        YEAR(Response_Date) AS Response_Year,
        MONTH(Response_Date) AS Response_Month,
        COUNT(*) AS Total_Responses
    FROM dbo.ResearchInsight360
    GROUP BY
        YEAR(Response_Date),
        MONTH(Response_Date)
)
SELECT
    Response_Year,
    Response_Month,
    Total_Responses,

    LAG(Total_Responses) OVER
    (
        ORDER BY Response_Year, Response_Month
    ) AS Previous_Month_Responses

FROM MonthlyData;

-- 19. CTE – Top 5 industries by responses

WITH IndustryData AS
(
	SELECT
		Industry,
		COUNT(*) AS Total_Responses
	FROM DBO.ResearchInsight360
	GROUP BY Industry
)
SELECT TOP 5 *
FROM IndustryData
ORDER BY Total_Responses DESC

-- 20. NPS – Net Promoter Score

SELECT
    COUNT(*) AS Total_Responses,

    SUM(CASE WHEN Net_Promoter_Score >= 9
        THEN 1 ELSE 0 END) AS Promoters,

    SUM(CASE WHEN Net_Promoter_Score <= 6
        THEN 1 ELSE 0 END) AS Detractors,

    CAST(
        100.0 *
        (
            SUM(CASE WHEN Net_Promoter_Score >= 9
                THEN 1 ELSE 0 END)
            -
            SUM(CASE WHEN Net_Promoter_Score <= 6
                THEN 1 ELSE 0 END)
        )
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS NPS

FROM dbo.ResearchInsight360
WHERE Response_Status = 'Completed';

