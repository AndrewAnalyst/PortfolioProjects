SELECT *
FROM PortfolioProject.dbo.CovidDeaths

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

-- Looking at total cases vs total deaths

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location = 'Australia' 
ORDER BY 1,2

-- Looking at total cases vs population

SELECT Location, Date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location = 'Australia'
ORDER BY 1,2

-- Looking at countries with highest infection rate of population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

SELECT Location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population, date
ORDER BY PercentPopulationInfected DESC

-- Showing the countries with highest death count by location

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Showing the continents with the highest death count by continent

SELECT Continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

-- Global numbers
 
SELECT Date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Date
ORDER BY 1,2

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at total population vs Vaccination

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition BY Dea.Location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS Dea
INNER JOIN PortfolioProject.dbo.CovidVaccinations AS Vac
ON Dea.Location = Vac.Location
AND Dea.Date = Vac.Date
WHERE Dea.continent IS NOT NULL
ORDER BY 2,3

-- CTE option for % calc

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS Dea
JOIN PortfolioProject.dbo.CovidVaccinations AS Vac
	ON Dea.Location = Vac.Location
	AND Dea.Date = Vac.Date
WHERE dea.continent IS NOT NULL)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP table option for % calc

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar (255),
Location nvarchar(250),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)
INSERT INTO  #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations,
SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS Dea
JOIN PortfolioProject.dbo.CovidVaccinations AS Vac
	ON Dea.Location = Vac.Location
	AND Dea.Date = Vac.Date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating views to store data for visualisations

CREATE VIEW PecentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations,
SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS Dea
JOIN PortfolioProject.dbo.CovidVaccinations AS Vac
	ON Dea.Location = Vac.Location
	AND Dea.Date = Vac.Date
WHERE dea.continent IS NOT NULL



