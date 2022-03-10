-- Looking at CovidDeaths Table

Select *
FROM [Portfolio Project]..CovidDeaths
WHERE 
continent is NOT NULL
ORDER BY 3,4

-- Extracting the useful data for our exploration

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths in India 
-- Gives you the likely % of you dying if you are infected with Covid in India

SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 
AS DeathPercent
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
AND location = 'India'
ORDER BY 1,2

-- Total Cases Vs Total Population in India
-- Gives you the infected people out of the total population in India

SELECT location, date, population, total_cases, (total_cases/population)*100 
AS InfectedPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
AND location = 'India'
ORDER BY 1,2


-- Countries with highest infection rate compared with their population

SELECT location, population, MAX(total_cases) AS InfectionCount, MAX((total_cases/population))*100 AS InfectionRate
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectionRate DESC

-- Countries with highest death count 

SELECT location, MAX(CONVERT(int,total_deaths)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Breaking down by Continent

SELECT continent, MAX(CONVERT(int,total_deaths)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT SUM(new_cases) AS TotalCases, SUM(CONVERT(int,total_deaths)) AS TotalDeaths, (SUM(CONVERT(int,total_deaths))/SUM(new_cases)) AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 

-- Total population Vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
INNER JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Use of CTE to calculate %

WITH PopVsVac (continent, location, date, population, new_vaccinatios, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
INNER JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinatedPeople
FROM PopVsVac

-- Creating View to see vaccinated %

CREATE VIEW PercentPopulationVaccnated 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
INNER JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

-- Calling out the Created VIEW
SELECT * FROM PercentPopulationVaccnated
