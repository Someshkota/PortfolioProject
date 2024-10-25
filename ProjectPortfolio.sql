SELECT * 
FROM PortfolioProject..CovidDeaths
order by 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
order by 1,2

--Total cases vs Total deaths-- 

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE total_cases<>0 AND location = 'India'
order by 1,2

-- Total cases vs population -- 

SELECT location,date,total_cases,population,(total_cases/population)*100 as InfectedPopulation
FROM PortfolioProject..CovidDeaths
WHERE total_cases<>0 AND location = 'India'
order by 1,2

--Total Deaths vs population--

SELECT location,date,total_deaths,total_cases,(total_deaths/total_cases)*100 as Deaths
FROM PortfolioProject..CovidDeaths
WHERE total_cases<>0 AND location = 'India' and continent is not null
order by 1,2

--Highest infection rate compared to population--

SELECT location,population,MAX(total_cases) as HighestInfectedCases,MAX((total_cases/population))*100 as InfectedPercent
FROM PortfolioProject..CovidDeaths
WHERE total_cases<>0 
group by location,population
order by InfectedPercent Desc


--Highest death rate --

SELECT location,MAX(total_deaths) as HighestDeaths
FROM PortfolioProject..CovidDeaths
WHERE total_cases<>0 and continent is not null
group by location
order by HighestDeaths Desc

--Global numbers--

SELECT sum(new_cases)as total_cases,sum(new_deaths) as total_deaths,sum(new_deaths/new_cases)*100 as totalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and new_cases<>0 and date='2021-04-25'
--group by CAST(date AS date)
order by 1,2 
 

-- joining table vaccination and deaths--
select * 
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location 
	and cast(dea.date as date)=cast(vac.date as date)
	order by 3,4


--New vaccinations per day--

select dea.continent,dea.location,cast(dea.date as date),dea.population,vac.new_vaccinations
,sum(cast (vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,cast(dea.date as date)) as newvaccinationsPerDay
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location 
	and cast(dea.date as date)=cast(vac.date as date)
where dea.continent is not null 
order by 2,3


--vaccination vs population percentage--
--using CTE--
with PopvsVac (continent ,location ,date,population,new_vaccinations,newvaccinationsPerDay)
as
(
select dea.continent,dea.location,cast(dea.date as date),dea.population,vac.new_vaccinations
,sum(cast (vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,cast(dea.date as date)) as newvaccinationsPerDay
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location 
	and cast(dea.date as date)=cast(vac.date as date)
where dea.continent is not null 
--order by 2,3
)
select*,(newvaccinationsPerDay/population)*100 as VaccinationPercent
from PopvsVac
order by 2,3


--using temp table
drop table if exists #PercentPopulationvaccinated
create table #PercentPopulationvaccinated
(
Continent nvarchar(255),
Location  nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
newvaccinationsPerDay numeric
)

insert into #PercentPopulationvaccinated
select dea.continent,dea.location,cast(dea.date as date),dea.population,vac.new_vaccinations
,sum(cast (vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,cast(dea.date as date)) as newvaccinationsPerDay
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location 
	and cast(dea.date as date)=cast(vac.date as date)
where dea.continent is not null 
--order by 2,3

select*,(newvaccinationsPerDay/population)*100 as VaccinationPercent
from #PercentPopulationvaccinated
order by Location,cast(Date as date)


--creating a view for visualization--

CREATE VIEW PercentPopulationvaccinated AS
select dea.continent,dea.location,cast(dea.date as date)as date,dea.population,vac.new_vaccinations
,sum(cast (vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,cast(dea.date as date)) as newvaccinationsPerDay
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location 
	and cast(dea.date as date)=cast(vac.date as date)
where dea.continent is not null 
--order by 2,3

--drop view and view the view

SELECT * 
FROM PercentPopulationVaccinated
ORDER BY location, date;

DROP VIEW PercentPopulationVaccinated;
SELECT * FROM sys.views WHERE name = 'PercentPopulationVaccinated';




 