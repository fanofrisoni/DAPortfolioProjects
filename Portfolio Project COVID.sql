--SELECT *
--FROM CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Probability of death if you get COVID per day and per country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE LOCATION LIKE '%xico'
ORDER BY 1,2

-- Loking at Total Cases vs Population
-- Percentage of population that got COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasesPercentage
FROM CovidDeaths
WHERE LOCATION LIKE '%xico'
ORDER BY 1,2

-- Looking at countries with highest infections rate

SELECT location, population, MAX(total_cases) AS HighestInfecCount, MAX((total_cases/population)*100) AS CasesPercentage
FROM CovidDeaths
GROUP BY location, population
ORDER BY CasesPercentage DESC

-- Looking at countries with highest death count and death rate

SELECT location, population, MAX(CAST(total_deaths as int)) AS Deaths, MAX((total_deaths/population)*100) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Deaths DESC

-- Deaths per continent

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC

-- Global

SELECT TOP 1 total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE 'World'
ORDER BY date DESC 


-- Looking at Total Population vs Vacccinations

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS TotalCurrentVacc

FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

-- CTE

WITH PopVSVacc (Continent, Location, Date, Population, NewVaccinations , TotalCurrentVacc)
AS 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS TotalCurrentVacc
FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *, (TotalCurrentVacc/Population)*100 AS VaccinationPercentage
FROM PopVSVacc


-- Creating View to store data for visualization

CREATE VIEW DeathsPercentage AS
SELECT location, population, MAX(CAST(total_deaths as int)) AS Deaths, MAX((total_deaths/population)*100) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population

SELECT *
FROM DeathsPercentage
ORDER BY DeathPercentage DESC