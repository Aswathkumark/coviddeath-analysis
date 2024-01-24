/*
COVID 19 Data Analysis
SKILLS USED : 	JOINS, WINDOWS FUNCTIONS,AGGREGATE FUNCTIONS , CREATING VIEWS, COMMON TABLE EXPRESSIONS, CONVERTING DATA TYPES
*/

-- Analysing deaths per cases!
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS Deaths_per_cases
FROM
    coviddeath
WHERE
    continent != ''
ORDER BY location , date;

-- Analysing Death Percentage per population
SELECT 
    location,
    date,
    population,
    total_deaths,
    (total_deaths / population) * 100 AS Death_Percentage
FROM
    coviddeath
WHERE
    continent != ''
ORDER BY location , date;

-- Analysing Countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS double)) AS TotalDeathCount
FROM coviddeath
WHERE continent != ''
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Analysing countries with highest number of cases per population
CREATE VIEW TotalCasesPerPopulation
AS
SELECT continent,location,population,date,MAX(CAST(total_cases AS double)) AS TotalCases, MAX((CAST(total_cases AS double)/ population))*100 AS TotalCasesPerPopulation
FROM coviddeath
WHERE continent != ''
GROUP BY continent,location,population,date
ORDER BY TotalCasesPerPopulation DESC;

-- Analysing things at Continent level
SELECT continent,SUM(CAST(new_deaths AS double)) AS TotalDeaths
FROM coviddeath
WHERE continent != ''
GROUP BY continent
ORDER BY TotalDeaths DESC;

-- Analysing deaths at Country level
-- TOP 10 COUNTRIES WITH MOST DEATHS 
SELECT location,SUM(CAST(new_deaths AS double)) AS TotalDeaths
FROM coviddeath
WHERE continent != ''
GROUP BY location
ORDER BY TotalDeaths DESC
LIMIT 10;

-- Global Figures 
SELECT SUM(CAST(new_cases as double)) AS TotalCases, SUM(CAST(new_deaths as double)) AS TotalDeaths, SUM(CAST(new_deaths as double))/SUM(CAST(new_cases as double))*100 AS DeathPercentage
FROM coviddeath
WHERE continent != ''
ORDER BY 1,2;

-- Analysing Vaccinations 
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM
    coviddeath dea
JOIN
    covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent != ''
ORDER BY
    dea.location, dea.date;


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopulationVaccinated (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS double)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM coviddeath dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent  != ''
)
SELECT *,RollingPeopleVaccinated/population*100 AS PercentPeopleVaccinated
FROM PopulationVaccinated;


-- Creating View which can be used later for visualization

CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS double)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM coviddeath dea
JOIN covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent  != '';













SELECT *, (RollingPeopleVaccinated / Population) * 100 FROM (     SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,           SUM(vac.new_vaccinations + 0) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated   FROM Portfolio.CovidDeath dea     JOIN Portfolio.covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date     WHERE dea.continent IS NOT NULL ) AS PopvsVac
SELECT *, (RollingPeopleVaccinated / Population) * 100 FROM (     SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,           SUM(vac.new_vaccinations + 0) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated   FROM Portfolio.CovidDeath dea     JOIN Portfolio.covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date     WHERE dea.continent IS NOT NULL ) AS PopvsVac
