select 
	location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths..CovidDeaths$
where continent is not null
order by 1,2


-- Looking at total cases vs total deaths

select 
	location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths..CovidDeaths$
where continent is not null
order by 1,2

-- Looking at total cases vs population
select 
	location, date, population, total_cases, (total_cases/population)*100 as percentPopulationInfected
from CovidDeaths..CovidDeaths$
where continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to population
select 
	continent, location, population, max(cast(total_cases as int)) as HighestInfectedCount, (max(total_cases/population)*100) as percentPopulationInfected
from CovidDeaths..CovidDeaths$
where continent is not null
group by continent, location, population
order by HighestInfectedCount desc

-- Continents Infection Counts
select 
	location population, max(cast(total_cases as int)) as InfectedCount
from CovidDeaths..CovidDeaths$
where location in ('Europe','Asia','North America', 'South America', 'Africa', 'Oceania')
group by continent,location, population
order by InfectedCount desc

--Continents Death Counts
select 
	location, population, max(cast(total_deaths as int)) as DeathCount
from CovidDeaths..CovidDeaths$
where location = 'world'
group by continent,location, population
order by DeathCount desc

-- Vaccination Numbers

select cd.location, max(cd.population) 'population', max(cv.total_vaccinations) 'Total Vaccinations' from CovidDeaths..CovidDeaths$ cd
join CovidDeaths..CovidVaccinations$ cv on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
group by cd.location


select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date) as rollingTotalVaccinated
from CovidDeaths..CovidDeaths$ cd
join CovidDeaths..CovidVaccinations$ cv on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
order by 2,3

create view Population_Vaccinated as (
select *,  100*rollingTotalVaccinated/population '% vaccinated' from (
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date) as rollingTotalVaccinated
from CovidDeaths..CovidDeaths$ cd
join CovidDeaths..CovidVaccinations$ cv on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
) PopulationVaccinated)

select * from CovidDeaths..Population_Vaccinated