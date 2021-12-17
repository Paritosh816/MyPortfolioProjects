/*

Covid 19 Data Exploration
Skills used: Joins, CTE'S, Temp Tables, Windows Functions, Aggregate Functions, Creating View, Converting Data Types  

*/

select * 
from
MyPortfolioProject..CovidDeaths
order by 3,4

--select * 
--from
--MyPortfolioProject..CovidVaccinations
--order by 3,4

-- Select data that we are going to be used

Select Location, date, total_cases, new_cases, total_deaths, population
From MyPortfolioproject..CovidDeaths
order by 1,2

-- Looking at Total Cases VS Total Deaths
-- Shows the Likehood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From MyPortfolioproject..CovidDeaths
where location like '%india%' 
order by 1,2

-- Looking at Total cases VS Population
-- Shows what Percentage got in covid

Select Location, date, population, total_cases, (total_cases/population)*100 as CasesRatioWithPopulation
From MyPortfolioproject..CovidDeaths
--where location like '%india%'
order by 1,2

-- Looking at countries with Highest Total cases compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasesRatioWithPopulation
From MyPortfolioproject..CovidDeaths
--where location like '%india%'
group by Location, population
order by CasesRatioWithPopulation desc

-- Showing countries with the Highest death Count Per Population

Select Location, population, MAX(cast(total_deaths as int)) as Highestdeaths
From MyPortfolioproject..CovidDeaths
--where location like '%india%'
where continent is not null
group by Location, population
order by Highestdeaths desc

-- Let's Break Things Down By Continent 
-- Showing Continents By Highest Death Count Per Population

Select continent, MAX(cast(total_deaths as int)) as Highestdeaths
From MyPortfolioproject..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by Highestdeaths desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From MyPortfolioproject..CovidDeaths
--where location like '%india%' 
where continent is not null
--group by date
order by 1,2

--Showing the Data And Results from Table Covid Vaccination

Select *
From MyPortfolioProject..Covidvaccinations

-- Joining the Both Tables

Select *
From MyPortfolioProject..CovidDeaths deaths
Join MyPortfolioProject..Covidvaccinations vaccination
		on
		deaths.location = vaccination.location
		and deaths.date = vaccination.date

--Looking at Total Population vs Vaccinations(New Vaccinations per day)

Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations
, SUM(Convert(bigint,vaccination.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location,
 deaths.date) as RollingPeopleVaccinated
From MyPortfolioProject..CovidDeaths deaths
Join MyPortfolioProject..Covidvaccinations vaccination
		on
		deaths.location = vaccination.location
		and deaths.date = vaccination.date
where deaths.continent is not null
order by 2,3

--USE CTE(Common Table Expression)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations
, SUM(Convert(bigint,vaccination.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location,
 deaths.date) as RollingPeopleVaccinated
From MyPortfolioProject..CovidDeaths deaths
Join MyPortfolioProject..Covidvaccinations vaccination
		on
		deaths.location = vaccination.location
		and deaths.date = vaccination.date
where deaths.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_Vaccinations Numeric,
RollingPeopleVaccinated Numeric
)

Insert into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations
, SUM(Convert(bigint,vaccination.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location,
 deaths.date) as RollingPeopleVaccinated
From MyPortfolioProject..CovidDeaths deaths
Join MyPortfolioProject..Covidvaccinations vaccination
		on
		deaths.location = vaccination.location
		and deaths.date = vaccination.date
--where deaths.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations
, SUM(Convert(bigint,vaccination.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location,
 deaths.date) as RollingPeopleVaccinated
From MyPortfolioProject..CovidDeaths deaths
Join MyPortfolioProject..Covidvaccinations vaccination
		on
		deaths.location = vaccination.location
		and deaths.date = vaccination.date
where deaths.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated
