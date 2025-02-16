SELECT * From `CovidDeaths.Covid_Deaths`
;

SELECT * From `CovidDeaths.Covid_Deaths`
Order By 3, 4;

Select count(Distinct location) From `CovidDeaths.Covid_Deaths`; -- 219 Distinct locations

Select location, Date, total_cases, new_cases, total_deaths, population   -- Required Info for our analysis
From `CovidDeaths.Covid_Deaths`
order By 1,2;

-- Total_deaths Vs Total_cases

Select location, Date, total_cases, total_deaths, (total_deaths/ total_cases) As Death_Rate
From `CovidDeaths.Covid_Deaths`
order By 1,2;


Select location, Date, total_cases, total_deaths, (new_cases/ total_cases) As new_case_Rate
From `CovidDeaths.Covid_Deaths`
order By 1,2;

-- Covid Vaccins

Select * from `CovidVaccin.Covid_Vaccin`;

-- Total number of vaccines per country

Select continent, location, sum(total_vaccinations) As total_country_vaccin From `CovidVaccin.Covid_vaccin`
Where continent is not null
Group By continent, location
ORDER BY total_country_vaccin DESC;
--Limit 2;

--- Total Death percentage for every country

Select Continent, location, sum(total_deaths/ population)* 100 As Total_Death_Rate
From `CovidDeaths.Covid_Deaths`
Where continent is not null
--and location = "India"
Group By continent, location
ORDER By Total_Death_Rate DESC;

-- Let's create a table in one of the Datasets:

Drop Table if exists `CovidDeaths.Created_Table`;
Create TABLE `CovidDeaths.Created_Table`
(
  continent string,
  location string,
  total_Death_Rate FLOAT64
);

Insert into `CovidDeaths.Created_Table` (continent, location, total_Death_Rate)
Select Continent, location, sum(total_deaths/ population)* 100 As Total_Death_Rate
From `CovidDeaths.Covid_Deaths`
Where continent is not null
--and location = "India"
Group By continent, location
ORDER By Total_Death_Rate DESC;

-- Play with new Table:

Select * From `CovidDeaths.Created_Table`;

-- Avg Death rate continent wise:

select  Continent, AVG(total_Death_Rate) As Deaths_Contintntwise From `CovidDeaths.Created_Table`
Group By continent
Order By Deaths_Contintntwise DESC;


-- Combining 2 tables to create new table to perform visualization:

DROP TABLE IF EXISTS `CovidDeaths.visual_table`;

CREATE TABLE `CovidDeaths.visual_table` (
  continent STRING,
  location STRING,
  population FLOAT64,  
  total_Death_Rate FLOAT64,
  new_cases INT64,
  total_cases Float64,
  new_vaccinations INT64,
  total_vaccinations INT64
);

INSERT INTO `CovidDeaths.visual_table` (continent, location, population, total_Death_Rate, new_cases, total_cases, new_vaccinations, total_vaccinations)
SELECT 
  cd.continent, 
  cd.location, 
  cd.population,  
  SUM(cd.total_deaths / cd.population) * 100 AS total_Death_Rate,
  CAST(cd.new_cases AS INT64) AS new_cases,
  CAST(cd.total_cases AS INT64) AS total_cases,
  CAST(cv.new_vaccinations AS INT64) AS new_vaccinations,
  CAST(cv.total_vaccinations AS INT64) AS total_vaccinations
FROM `CovidDeaths.Covid_Deaths` cd 
JOIN `CovidVaccin.Covid_Vaccin` cv 
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
GROUP BY cd.continent, cd.location, cd.population, cd.new_cases, cd.total_cases, cv.new_vaccinations, cv.total_vaccinations
ORDER BY total_Death_Rate DESC;

Select * From `CovidDeaths.visual_table`;   -- Visualization Table is ready!

