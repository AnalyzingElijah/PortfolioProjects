
-- Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;


--Looking at Total Cases vs Total Deaths
--Shows the fatality rates of the COVID19 virus in Mexico
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%Mexico%'
AND continent is not null
ORDER BY 1,2;


--Looking at Total Cases vs Population
--Shows what percentage of the Mexican population got COVID
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS CovidPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%Mexico%'
AND continent is not null
ORDER BY 1,2;

--Looking at countries with Highest Infection rate compared to population
SELECT Location, population, MAX(total_cases) as HigestInfectionCount, MAX((total_cases/population))*100 AS CovidPercentage
FROM [Portfolio Project]..CovidDeaths
GROUP BY location, population
ORDER BY CovidPercentage desc;


--Showing Countries with Highest Death Count per Population
--Uses Cast to connect with data that does not properly align with database
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;


--Breaking things down by Continent
--Showing contintents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as ContinentDeaths
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY ContinentDeaths desc;



--Global numbers without using World row
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, Sum(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;


--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalPeopleVaccinated
--, (TotalPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3;


--Using a CTE

With PopvsVac(Continent, location, date, population, new_vaccinations, TotalPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
)
SELECT *, (TotalPeopleVaccinated/population)*100
FROM PopvsVac



--TEMP table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null

SELECT *, (TotalPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

CREATE view PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null


