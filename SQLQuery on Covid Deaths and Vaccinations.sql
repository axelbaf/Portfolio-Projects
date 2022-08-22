Select location,date, population, new_cases, total_cases, total_deaths
FROM CovidDeaths$
where continent is not null
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- This shows the likelihood of dying of you contracted covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths$
where location like '%came%'
order by 1, 2

-- Looking at the Total Cases vs Population

Select location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidDeaths$
--where location like '%states%'
order by 1, 2

-- Loking at the population with the highest infection rate compared to the population

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 AS PercentagePopulationInfected
FROM CovidDeaths$
--where location like '%united states%'
where continent is not null
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc


-- Looking at the Countries with the Highest Death Count per Population

Select location, max(cast(total_deaths as int)) as TotalDeathsCount
FROM CovidDeaths$
--where location like '%united states%'
where continent is not null
GROUP BY location
ORDER BY TotalDeathsCount desc

-- Let's break it down to continent

Select continent, max(cast(total_deaths as int)) as TotalDeathsCount
FROM CovidDeaths$
--where location like '%united states%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount desc

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)* 100
as DeathPercentage
FROM CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2


-- Looking at total population vs vaccination

select dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations  as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null  and vac.new_vaccinations is not null
order by 2,3

-- Using CTE

With popvsVac (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations  as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null  and vac.new_vaccinations is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentagePopulationVaccinated
From popvsVac


-- TEMP TABLE

Drop Table if exists #PercentagePopulationVaccinated

Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated

select dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations  as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null  and vac.new_vaccinations is not null
--order by 2,3



-- Creating view to store data for furture visualisations

Create view PercentagePopulationVaccinated as

select dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations
From CovidDeaths
, SUM(CAST(vac.new_vaccinations  as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null  --and vac.new_vaccinations is not
--order by 2,3

select *
from PercentagePopulationVaccinated

