SELECT *
FROM PortfolioProject..CovidDeaths$
Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- Select Data that we are going be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- This shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%cameroon%'
Order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%cameroon%'
Order by 1,2

-- Looking at total cases vs total deaths
-- Showing likelihood of dying if you contract covid in your country

Select location,  date, total_cases, total_deaths,  (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%china%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate Compared to Population

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$ --CovidDeaths$
--where location like '%united states%'
where continent is not null
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc

-- Loking at countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$ --CovidDeaths$
--where location like '%africa%'
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Let's break things down to continent
-- Showing continent with the highest death count

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$ --CovidDeaths$
--where location like '%africa%'
where continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int))as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100
 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%south america%'
where continent is not null
Group By date
Order By 1,2

convert(varchar, getdate(), 11)


Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int))as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100
 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
--Group By date
Order By 1,2

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ as dea
Join PortfolioProject..CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Order By 2,3


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
Select *, (RollingPeopleVaccinated/population)*100 as PercentagePopulationVaccinated
From #PercentagePopulationVaccinated

-- Creating view to store data for furture visualisations

Create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations
--From CovidDeaths
, SUM(CAST(vac.new_vaccinations  as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null  --and vac.new_vaccinations is not
--order by 2,3

 