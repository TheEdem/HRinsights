USE PortfolioProject2

--This data analysis project dives into multipe queries in SQL  to uncover important human resource insights from the dataset that can greatly benefit the company.


--Initial Exploration

SELECT * FROM HRData


--Format birthdate and hiredate columns
--Convert datatype from DATE/TIME TO DATE

ALTER TABLE HRData
ALTER COLUMN birthdate DATE
ALTER TABLE HRData
ALTER COLUMN hire_date DATE


-- Format "termdate" column by removing UTC Values
-- and Updating date/time to date

UPDATE HRData
SET termdate = FORMAT(CONVERT(DATETIME, LEFT(termdate, 19), 120), 'yyyy-MM-dd');

ALTER TABLE HRData
ADD new_termdate DATE;

-- Update the new date column with the converted values

UPDATE HRData
SET new_termdate = CASE
    WHEN termdate IS NOT NULL AND ISDATE(termdate) = 1
        THEN CAST(termdate AS DATETIME)
        ELSE NULL
    END;


-- create new column called "age"
ALTER TABLE HRData
ADD age nvarchar(30)


-- populate new age column with age data
UPDATE HRData
SET age = DATEDIFF(YEAR, birthdate, GETDATE());

SELECT birthdate, age
FROM HRData
ORDER BY age;


SELECT * FROM HRData


-- SOME QUESTIONS I WILL ANSWER USING THE DATA

-- 1) What's the age distribution in the company?

-- 2) What's the gender breakdown in the company?

-- 3) How does gender vary across departments and job titles?

-- 4) What's the race distribution in the company?

-- 5) What's the average length of employment in the company?

-- 6) Which department has the highest turnover rate?

-- 7) What is the tenure distribution for each department?

-- 8) How many employees work remotely for each department?

-- 9) What's the distribution of employees across different states?

-- 10) How are job titles distributed in the company?



--Q1. What's the age distribution in the company?

SELECT MIN(age) AS Youngest, MAX(AGE) AS Oldest
FROM HRData;

SELECT
  age_group,
  COUNT(*) AS count
FROM (
  SELECT
    CASE
      WHEN age >= 21 AND age <= 30 THEN '21 to 30'
      WHEN age >= 31 AND age <= 40 THEN '31 to 40'
      WHEN age >= 41 AND age <= 50 THEN '41-50'
      ELSE '50+'
    END AS age_group
  FROM HRData
  WHERE new_termdate IS NULL
) AS Subquery
GROUP BY age_group
ORDER BY age_group;

--Age group by gender

SELECT
  age_group, gender,
  COUNT(*) AS count
FROM (
  SELECT
    CASE
      WHEN age >= 21 AND age <= 30 THEN '21 to 30'
      WHEN age >= 31 AND age <= 40 THEN '31 to 40'
      WHEN age >= 41 AND age <= 50 THEN '41-50'
      ELSE '50+'
    END AS age_group,
	gender
  FROM HRData
  WHERE new_termdate IS NULL
) AS Subquery
GROUP BY age_group, gender
ORDER BY age_group, gender;


--Q2. What's the gender breakdown in the company?

SELECT
 gender,
 COUNT(gender) AS count
FROM HRData
WHERE new_termdate IS NULL
GROUP BY gender
ORDER BY gender ASC;


-- Q3. How does gender vary across departments and job titles?

SELECT department, gender, count(*) as count
FROM HRData
WHERE new_termdate IS NULL
GROUP BY department, gender
ORDER BY department;


-- job titles

SELECT 
department, jobtitle,
gender,
count(gender) AS count
FROM HRData
WHERE new_termdate IS NULL
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle, gender ASC;


-- Q4. What's the race distribution in the company?

SELECT race,
count(*) as count
FROM HRData
WHERE new_termdate IS NULL
GROUP BY race
ORDER BY count


-- Q5. What's the average length of employment in the company?

SELECT
 AVG(DATEDIFF(year, hire_date, new_termdate)) AS AverageYearsEmployed
 FROM HRData
 WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE();


-- Q6. Which department has the highest turnover rate?

-- find total count and then terminated count
-- terminated count/total count = turnover rate
--Using subquery to find turnover rate

SELECT
 department,
 total_count,
 terminated_count,
 round(CAST(terminated_count AS FLOAT)/total_count, 2) AS turnover_rate
FROM 
   (SELECT
   department,
   count(*) AS total_count,
   SUM(CASE
        WHEN new_termdate IS NOT NULL AND new_termdate <= getdate()
		THEN 1 ELSE 0
		END
   ) AS terminated_count
  FROM HRData
  GROUP BY department
  ) AS Subquery
ORDER BY turnover_rate DESC;

--Using a CTE instead of Subquery to find turnover rate

WITH TurnOverRate(department, total_count, terminated_count) as
 (SELECT
   department,
   count(*) AS total_count,
   SUM(CASE
        WHEN new_termdate IS NOT NULL AND new_termdate <= getdate()
		THEN 1 ELSE 0
		END
   ) AS terminated_count
  FROM HRData
  GROUP BY department
  )
SELECT *, round(CAST(terminated_count AS FLOAT)/total_count, 2) AS turnover_rate
FROM TurnOverRate
ORDER BY turnover_rate Desc


-- Q7. What is the tenure distribution for each department?

SELECT 
    department,
    AVG(DATEDIFF(year, hire_date, new_termdate)) AS AverageYearsEmployed
FROM 
    HRData
WHERE 
    new_termdate IS NOT NULL 
    AND new_termdate <= GETDATE()
GROUP BY 
    department;


SELECT 
 department, DATEDIFF(year, MIN(hire_date), MAX(new_termdate)) AS AverageYearsEmployed
FROM HRData
WHERE  new_termdate IS NOT NULL AND new_termdate <= GETDATE()
GROUP BY department
ORDER BY AverageYearsEmployed DESC;


-- Q8. How many employees work remotely and how many work remotely for each department?

SELECT location, count(*) AS count
 FROM HRData
 WHERE new_termdate IS NULL
 GROUP BY location;
 
 --by department

SELECT department, location, count(*) AS count
 FROM HRData
 WHERE new_termdate IS NULL
 GROUP BY department, location
 ORDER BY department;


 -- Q9. What's the distribution of employees across different states?

SELECT location_state, count(*) AS count
FROM HRData
WHERE new_termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;


-- Q10. How are job titles distributed in the company?

SELECT jobtitle, count(*) AS count
FROM HRData
WHERE new_termdate IS NULL
GROUP BY jobtitle
ORDER BY count DESC;

