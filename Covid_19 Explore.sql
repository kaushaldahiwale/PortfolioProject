--select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from coviddeaths_19
where continent is not null
order by 1,2;

--Looking at Total Cases vs Total Deaths
-- show likelihood of dying in india
select location,date,total_cases,total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage 
from coviddeaths_19
where location like '%india%'
order by 1,2
;
--Looking at total Cases vs Total Population
select location,date,total_cases,(total_cases/population) * 100 as InfectionPercentage 
from coviddeaths_19
--where location like '%india%'
order by 1,2;

--Looking at countries with highest infection rate compared to population
select location,max(total_cases) as highestInfectionCount,Max((total_cases/population)) * 100 as InfectionPercentage 
from coviddeaths_19
--where location like '%india%'
group by location,population
order by InfectionPercentage desc;

--Showing countries with highest death count per population
select location,max(convert(int,total_deaths))  as maxDeathCount
--where location like '%india%'
from coviddeaths_19
where continent is not null
group by location
order by maxDeathCount desc;

-- by continent

select location,max(convert(int,total_deaths))  as maxDeathCount
from coviddeaths_19
where continent is  null
group by location
order by maxDeathCount desc;

--global number
select date,sum(new_cases) as total_cases, sum(convert (int,new_deaths)) as total_death
,sum(convert (int,new_deaths))/sum(new_cases) *100 as DeathPercentage
from CovidDeaths_19
where continent is not null 
group by date
order by 1,2;

--join
-- total population vs total vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
from CovidDeaths_19 dea
join CovidVaccinations_19 vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--use cte
with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths_19 dea
join CovidVaccinations_19 vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100 
from PopvsVac


--Temp Table
create table #percentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date dateTime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentPopulationVaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths_19 dea
join CovidVaccinations_19 vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100 
from #percentPopulationVaccinated

--create view
create view  percentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths_19 dea
join CovidVaccinations_19 vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

