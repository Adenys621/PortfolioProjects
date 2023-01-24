/* 
COVID-19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Function, Creating Views and Converting Data Types
*/

SELECT *
FROM PortfolioProject2..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

SELECT *
FROM PortfolioProject2..CovidVaccines
WHERE continent is not null
ORDER BY 1,2

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject2..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject2..CovidDeaths
WHERE location like '%states%'
AND continent is not null
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population got COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopultaionInfected
FROM PortfolioProject2..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2


-- Countries with highest infection rate compared to population

SELECT location, population, Max(total_cases) AS HighestInfectionCount
, MAX((total_cases/population))*100 AS PercentPopultaionInfected
FROM PortfolioProject2..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopultaionInfected DESC	

-- Countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject2..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC	

-- Continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject2..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths
, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject2..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY  date
ORDER BY 1,2

-- Global totals only

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths
, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject2..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
-- GROUP BY  date
ORDER BY 1,2

-- Ttotal population vs vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths AS dea
JOIN PortfolioProject2..CovidVaccines AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
	ORDER BY 2,3

-- Using CTE to perform calculation on partition by in previous query

WITH PopvsVac (continet, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths AS dea
JOIN PortfolioProject2..CovidVaccines AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Using Temp Table to perform Calculation on Parition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths AS dea
JOIN PortfolioProject2..CovidVaccines AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

-- View of total population vs vaccinations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths AS dea
JOIN PortfolioProject2..CovidVaccines AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

-- View of total cases vs population

CREATE VIEW PercentPopulationCases AS
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopultaionInfected
FROM PortfolioProject2..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
--ORDER BY 1,2

-- View of Continents with the highest death count per population

CREATE VIEW PopulationsHighestDeathCount AS
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject2..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
--ORDER BY TotalDeathCount DESC

-- View of Countries with highest infection rate compared to population

CREATE VIEW PopulationHighestInfectionRate AS
SELECT location, population, Max(total_cases) AS HighestInfectionCount
, MAX((total_cases/population))*100 AS PercentPopultaionInfected
FROM PortfolioProject2..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
-- ORDER BY PercentPopultaionInfected DESC	
