select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

select * from PortfolioProject..CovidVaccinations

--looking at total cases vs total deaths
select Location, date, total_cases, total_deaths, round(total_deaths*100/total_cases, 2) as DeathPercentage
from PortfolioProject..CovidDeaths
where Location like '%Poland%' and total_deaths is not null
order by 5 desc

--total cases vs population
select Location, date, Population, total_cases, round(total_cases*100/Population, 2) as CasesPercentage
from PortfolioProject..CovidDeaths
where Location like '%Poland%' and total_cases is not null
order by 5 desc

--looking at countries with highest infection rate compared to population
select Location, Population, max(total_cases), max(round(total_cases*100/Population, 2)) as CasesPercentage
from PortfolioProject..CovidDeaths
group by Location, Population
order by 4 desc

--showing countries with highest death count per population
select Location, Population, max(convert(int, total_deaths)) as total_death_count, max(round(convert(int, total_deaths)*100/Population, 2)) as max_death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by Location, Population
order by 3 desc


--showing continents with highest death count per population
select continent, max(convert(int, total_deaths)) as total_death_count, max(round(convert(int, total_deaths)*100/Population, 2)) as max_death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 3 desc

--global numbers (across the world) 

--for individual date
select date, sum(new_cases) as cases, sum(cast(new_deaths as int)) as deaths, 
round(sum(cast(new_deaths as int)) * 100 / sum(new_cases),2) as deaths_percentage
from PortfolioProject..CovidDeaths
where continent is not null and new_cases is not null
group by date
order by 4 desc

--total deaths percentage
select sum(new_cases) as cases, sum(cast(new_deaths as int)) as deaths, 
round(sum(cast(new_deaths as int)) * 100 / sum(new_cases),2) as deaths_percentage
from PortfolioProject..CovidDeaths
where continent is not null and new_cases is not null



