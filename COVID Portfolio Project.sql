SELECT *
FROM PortfolioProjects ..CovidDeath
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProjects ..CovidVaccinations
--ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects ..CovidDeath
ORDER BY 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows the likelyhood of dying if you contract COVID

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects ..CovidDeath
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2


--Looking at Total Cases Vs Population
--Shows what percentage of population got COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
FROM PortfolioProjects ..CovidDeath
--WHERE location like '%states%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as HighestInfectionPercentage
FROM PortfolioProjects ..CovidDeath
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY HighestInfectionPercentage desc

-- Showing Countries with Highest Death per Population

SELECT location, population, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population))*100 as HighestDeathPercentage
FROM PortfolioProjects ..CovidDeath
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY HighestDeathPercentage desc

SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProjects ..CovidDeath
WHERE continent is not NULL
--WHERE location like '%states%'
GROUP BY location
ORDER BY TotalDeathCount desc


--Continent 

SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProjects ..CovidDeath
WHERE continent is  NULL
--WHERE location like '%states%'
GROUP BY location
ORDER BY TotalDeathCount desc




-- Showing Contintents with the Highest Death Count per Population

SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProjects ..CovidDeath
WHERE continent is not NULL
--WHERE location like '%states%'
GROUP BY continent
ORDER BY TotalDeathCount desc




-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as bigint)) as TotalDeaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as GlobalDeathPercentage
FROM PortfolioProjects ..CovidDeath
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Joining CovidDeath table with CovidVaccinations on location and date
-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinated
, (RollingVaccinated/dea.population)*100 as TotalVaccinated
FROM PortfolioProjects..CovidDeath dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	ORDER BY 2,3


--Using CTE to perform Calculation on Partition By in previous query

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinated
--(RollingVaccinated/dea.population)*100 as TotalVaccinated
FROM PortfolioProjects..CovidDeath dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER BY 2,3
	)

SELECT *, (RollingVaccinated/population)*100
FROM PopVsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccinated
--, (RollingVaccinated/dea.population)*100 as TotalVaccinated
FROM PortfolioProjects..CovidDeath dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER BY 2,3
	


Select *, (RollingVaccinated/population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccinated
--, (RollingVaccinated/population)*100
FROM PortfolioProjects..CovidDeath dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 

CREATE VIEW ContinentTotalDeathCount as 
SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProjects ..CovidDeath
WHERE continent is not NULL
--WHERE location like '%states%'
GROUP BY continent
--ORDER BY TotalDeathCount desc

CREATE VIEW HighestInfectionPercentage as
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as HighestInfectionPercentage
FROM PortfolioProjects ..CovidDeath
--WHERE location like '%states%'
GROUP BY location, population
--ORDER BY HighestInfectionPercentage desc

SELECT *
FROM HighestInfectionPercentage