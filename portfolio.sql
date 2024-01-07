SELECT * FROM portfolio.coviddeath
order by 3,4;

select location,date,total_cases,new_cases,total_deaths,population
from portfolio.coviddeath
order by total_cases,2;

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercent
from portfolio.coviddeath
where location like '%states%'
order by 1,2 ;


Select Location, Population, MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as 
PercentPopulationInfected
From portfolio Coviddeath
Group by Location, Population
order by PercentPopulationInfected desc;

SELECT continent, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM portfolio.coviddeath
WHERE location LIKE '%states%' AND continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

SELECT *
FROM portfolio.coviddeath AS dea
JOIN portfolio.covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date;

