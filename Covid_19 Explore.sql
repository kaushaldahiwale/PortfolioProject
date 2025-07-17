--select data that we are going to be using
SELECT location,
       date,
       total_cases,
       new_cases,
       total_deaths,
       population
FROM   coviddeaths_19
WHERE  continent IS NOT NULL
ORDER  BY 1,
          2;

--Looking at Total Cases vs Total Deaths
-- show likelihood of dying in india
SELECT location,
       date,
       total_cases,
       total_deaths,
       ( total_deaths / total_cases ) * 100 AS DeathPercentage
FROM   coviddeaths_19
WHERE  location LIKE '%india%'
ORDER  BY 1,
          2;

--Looking at total Cases vs Total Population
SELECT location,
       date,
       total_cases,
       ( total_cases / population ) * 100 AS InfectionPercentage
FROM   coviddeaths_19
--where location like '%india%'
ORDER  BY 1,
          2;

--Looking at countries with highest infection rate compared to population
SELECT location,
       Max(total_cases)                        AS highestInfectionCount,
       Max(( total_cases / population )) * 100 AS InfectionPercentage
FROM   coviddeaths_19
--where location like '%india%'
GROUP  BY location,
          population
ORDER  BY infectionpercentage DESC;

--Showing countries with highest death count per population
SELECT location,
       Max(CONVERT(INT, total_deaths)) AS maxDeathCount
--where location like '%india%'
FROM   coviddeaths_19
WHERE  continent IS NOT NULL
GROUP  BY location
ORDER  BY maxdeathcount DESC;

-- by continent
SELECT location,
       Max(CONVERT(INT, total_deaths)) AS maxDeathCount
FROM   coviddeaths_19
WHERE  continent IS NULL
GROUP  BY location
ORDER  BY maxdeathcount DESC;

--global number
SELECT date,
       Sum(new_cases)                                        AS total_cases,
       Sum(CONVERT (INT, new_deaths))                        AS total_death,
       Sum(CONVERT (INT, new_deaths)) / Sum(new_cases) * 100 AS DeathPercentage
FROM   coviddeaths_19
WHERE  continent IS NOT NULL
GROUP  BY date
ORDER  BY 1,
          2;

--join
-- total population vs total vaccination
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       Sum(CONVERT(INT, vac.new_vaccinations))
         OVER (
           partition BY dea.location
           ORDER BY dea.date) AS RollingPeopleVaccinated
FROM   coviddeaths_19 dea
       JOIN covidvaccinations_19 vac
         ON dea.location = vac.location
            AND dea.date = vac.date
WHERE  dea.continent IS NOT NULL
ORDER  BY 2,
          3;

--use cte
WITH popvsvac (continent, location, date, population, new_vaccinations,
     rollingpeoplevaccinated)
     AS (SELECT dea.continent,
                dea.location,
                dea.date,
                dea.population,
                vac.new_vaccinations,
                Sum(CONVERT(INT, vac.new_vaccinations))
                  OVER (
                    partition BY dea.location
                    ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
         FROM   coviddeaths_19 dea
                JOIN covidvaccinations_19 vac
                  ON dea.location = vac.location
                     AND dea.date = vac.date
         WHERE  dea.continent IS NOT NULL
        --order by 2,3
        )
SELECT *,
       ( rollingpeoplevaccinated / population ) * 100
FROM   popvsvac

--Temp Table
CREATE TABLE #percentpopulationvaccinated
  (
     continent               NVARCHAR (255),
     location                NVARCHAR (255),
     date                    DATETIME,
     population              NUMERIC,
     new_vaccinations        NUMERIC,
     rollingpeoplevaccinated NUMERIC
  )

INSERT INTO #percentpopulationvaccinated
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       Sum(CONVERT(INT, vac.new_vaccinations))
         OVER (
           partition BY dea.location
           ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM   coviddeaths_19 dea
       JOIN covidvaccinations_19 vac
         ON dea.location = vac.location
            AND dea.date = vac.date
WHERE  dea.continent IS NOT NULL

--order by 2,3
SELECT *,
       ( rollingpeoplevaccinated / population ) * 100
FROM   #percentpopulationvaccinated

--create view
CREATE VIEW percentpopulationvaccinated
AS
  SELECT dea.continent,
         dea.location,
         dea.date,
         dea.population,
         vac.new_vaccinations,
         Sum(CONVERT(INT, vac.new_vaccinations))
           OVER (
             partition BY dea.location
             ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM   coviddeaths_19 dea
         JOIN covidvaccinations_19 vac
           ON dea.location = vac.location
              AND dea.date = vac.date
  WHERE  dea.continent IS NOT NULL
--order by 2,3
