-- Selecting all columns from CovidDeath where continent is not null and ordering by the 3rd and 4th columns
SELECT *
FROM Portfolio.CovidDeath
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- Selecting specific columns from CovidDeath where continent is not null and ordering by the 1st and 2nd columns
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio.CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Calculating death percentage based on total cases and total deaths for countries with 'states' in the name
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM Portfolio.CovidDeath
WHERE location LIKE '%states%'
  AND continent IS NOT NULL
ORDER BY 1, 2;

-- Calculating percentage of population infected with Covid based on total cases and population
SELECT Location, date, Population, total_cases, (total_cases / population) * 100 AS PercentPopulationInfected
FROM Portfolio.CovidDeath
ORDER BY 1, 2;

-- Countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population) * 100) AS PercentPopulationInfected
FROM Portfolio.CovidDeath
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

-- Countries with highest death count per population
SELECT Location, MAX(CAST(Total_deaths AS SIGNED)) AS TotalDeathCount
FROM Portfolio.CovidDeath
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- Breaking things down by continent and showing continents with the highest death count per population
SELECT continent, MAX(CAST(Total_deaths AS SIGNED)) AS TotalDeathCount
FROM Portfolio.CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global numbers for total cases, total deaths, and death percentage
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS SIGNED)) AS total_deaths, SUM(CAST(new_deaths AS SIGNED)) / SUM(New_Cases) * 100 AS DeathPercentage
FROM Portfolio.CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Total population vs vaccinations, showing the percentage of population that has received at least one Covid vaccine
Select dea.continent, dea.location, dea. date,
dea. population, vac. new_vaccinations
From Portfolio. coviddeath dea
Join Portfolio. covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date


-- Using CTE to perform calculation on PARTITION BY in the previous query
WITH PopvsVac AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
    FROM Portfolio.CovidDeath dea
    JOIN Portfolio.covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM PopvsVac;

-- Using Temp Table to perform calculation on PARTITION BY in the previous query
-- Drop the temporary table if it exists
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

-- Create the temporary table
CREATE TEMPORARY TABLE PercentPopulationVaccinated (
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

-- Now you can use the temporary table for your operations.


INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM Portfolio.CovidDeath dea
JOIN Portfolio.covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date;

SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM PercentPopulationVaccinated;

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM Portfolio.CovidDeath dea
JOIN Portfolio.covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


