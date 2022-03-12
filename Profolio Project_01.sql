SELECT *
FROM ProfolioProject..CovidDeath
WHERE continent is not NULL
ORDER BY 3,4

SELECT *
FROM ProfolioProject..CovidVaccination
ORDER BY 3,4

--Select Data
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProfolioProject..CovidDeath
WHERE continent is not NULL
ORDER BY 1,2

-- Total deaths in Total cases in TW are (~4.2%)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM ProfolioProject..CovidDeath
WHERE location = 'taiwan'
ORDER BY 1,2

-- Total cases in Total population in TW are (~0.085%)
SELECT location, date, population, total_cases, (total_cases/population)*100 AS covidpercentage
FROM ProfolioProject..CovidDeath
WHERE location = 'taiwan'
ORDER BY 1,2

-- Countries with the Highest infection rate compared with Population (eg.Denmark ~47%)
SELECT location, population, MAX(total_cases) AS MaxInfection, MAX((total_cases/population))*100 AS covidpercentage
FROM ProfolioProject..CovidDeath
WHERE continent is not NULL
GROUP BY location, population
ORDER BY covidpercentage DESC

-- Countries with the Highest Death counts
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCounts
FROM ProfolioProject..CovidDeath
WHERE continent is not NULL
GROUP BY location, population
ORDER BY TotalDeathCounts DESC

-- Break down with continents
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCounts
FROM ProfolioProject..CovidDeath
WHERE continent is NULL
GROUP BY location, population
ORDER BY TotalDeathCounts DESC

-- Global Numbers
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, 
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM ProfolioProject..CovidDeath
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1

--Vaccination rate over Population by Creating CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (CAST (vac.new_vaccinations AS bigint))OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM ProfolioProject..CovidDeath AS dea
JOIN ProfolioProject..CovidVaccination AS vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *, (RollingPeopleVaccinated/ Population)*100 AS VaccinationRate
FROM PopvsVac

--Vaccination rate over Population by Creating Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar (255),
 Location nvarchar (255),
 Date datetime,
 Population numeric,
 New_vaccination numeric,
 RollingPeopleVaccinated numeric
 )
 
 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (CAST (vac.new_vaccinations AS bigint))OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM ProfolioProject..CovidDeath AS dea
JOIN ProfolioProject..CovidVaccination AS vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *, (RollingPeopleVaccinated/ Population)*100 AS VaccinationRate
FROM #PercentPopulationVaccinated

-- Creating Views
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (CAST (vac.new_vaccinations AS bigint))OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM ProfolioProject..CovidDeath AS dea
JOIN ProfolioProject..CovidVaccination AS vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *
FROM PercentPopulationVaccinated

