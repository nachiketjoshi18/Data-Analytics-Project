/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT * 
FROM Data_analysis_project..covid_deaths
ORDER BY 3,4

SELECT * 
FROM Data_analysis_project..covid_VACCINATIONS
ORDER BY 3,4

-- Select Data that we are going to be starting with

SELECT LOCATION, DATE , POPULATION , TOTAL_CASES , NEW_CASES , TOTAL_DEATHS
FROM  Data_analysis_project..covid_deaths
ORDER BY 1,2

-- Total Cases vs Total Deaths

SELECT LOCATION, DATE , POPULATION , TOTAL_CASES , TOTAL_DEATHS , (total_deaths/total_cases)*100 AS DEATH_PERSENTAGE
FROM  Data_analysis_project..covid_deaths
ORDER BY 1,2

SELECT LOCATION, DATE , POPULATION , TOTAL_CASES , TOTAL_DEATHS , (total_deaths/total_cases)*100 AS DEATH_PERSENTAGE
FROM  Data_analysis_project..covid_deaths
WHERE location = 'INDIA'
ORDER BY 1,2

-- Total Cases vs Population

SELECT LOCATION, DATE , POPULATION , TOTAL_CASES , TOTAL_DEATHS , (total_cases/population)*100 AS POSITIVITY_RATE
FROM  Data_analysis_project..covid_deaths
WHERE location = 'INDIA'
ORDER BY 1,2

SELECT LOCATION, DATE , POPULATION , TOTAL_CASES , TOTAL_DEATHS , (total_cases/population)*100 AS POSITIVITY_RATE , (total_deaths/total_cases)*100 AS DEATH_PERSENTAGE
FROM  Data_analysis_project..covid_deaths
WHERE location LIKE '%STATES%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population


SELECT LOCATION , POPULATION , MAX(TOTAL_CASES) AS max_casesss, max((total_cases/population))*100 AS POSITIVITY_RATE 
FROM  Data_analysis_project..covid_deaths
where continent is not null
GROUP BY LOCATION,population
ORDER BY 3 desc

-- Countries with Highest Death Count per Population

SELECT LOCATION , POPULATION , MAX(cast(total_deaths as int)) AS max_deathss ,total_cases, (total_deaths/total_cases)*100 AS DEATH_PERSENTAGE
FROM  Data_analysis_project..covid_deaths
where continent is not null
GROUP BY LOCATION,population,(total_deaths/total_cases)*100,total_cases
ORDER BY 5 desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent , MAX(cast(total_deaths as int)) AS max_deathss 
FROM  Data_analysis_project..covid_deaths
where continent is  not null
GROUP BY continent
ORDER BY 2 desc

-- GLOBAL NUMBERS

SELECT date ,sum(new_cases) as sum_new_case , sum(cast (new_deaths as int)) as SUm_new_death , (sum(cast (new_deaths as int))/sum(new_cases))*100 as persentage_death_today
FROM  Data_analysis_project..covid_deaths
where continent is  not null
GROUP BY date
ORDER BY 1 desc

SELECT sum(new_cases) as sum_new_case , sum(cast (new_deaths as int)) as SUm_new_death , (sum(cast (new_deaths as int))/sum(new_cases))*100 as persentage_death_today
FROM  Data_analysis_project..covid_deaths
where continent is  not null
ORDER BY 1 desc

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
from Data_analysis_project..covid_deaths as dea
    join Data_analysis_project..covid_vaccinations vac
         on dea.location = vac.location and dea.date = vac.date
		 where dea.continent is not null 
		 order by 1, 2,3


select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location , dea.date) as cdf_columns
from Data_analysis_project..covid_deaths as dea
    join Data_analysis_project..covid_vaccinations vac
         on dea.location = vac.location and dea.date = vac.date
		 where dea.continent is not null 
		 order by 1, 2,3

		 -- Using CTE to perform Calculation on Partition By in previous query

with popvsvac(continent , location , date , population , new_vaccinations,cdf_columns)
as
(
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location , dea.date) as cdf_columns
from Data_analysis_project..covid_deaths as dea
    join Data_analysis_project..covid_vaccinations vac
         on dea.location = vac.location and dea.date = vac.date
		 where dea.continent is not null 
		)
select * , (cdf_columns/population)*100
from popvsvac

-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #temptable
create table #temptable
(continent nvarchar(250),location nvarchar(200) , date datetime , population numeric , new_vaccinations numeric , cdf_columns numeric)
insert into #temptable
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location , dea.date) as cdf_columns
from Data_analysis_project..covid_deaths as dea
    join Data_analysis_project..covid_vaccinations vac
         on dea.location = vac.location and dea.date = vac.date
		 where dea.continent is not null
select * , (cdf_columns/population)*100
from #temptable

-- Creating View to store data for later visualizations

create View persentpopulationvaccinated as 
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location , dea.date) as cdf_columns
from Data_analysis_project..covid_deaths as dea
    join Data_analysis_project..covid_vaccinations vac
         on dea.location = vac.location and dea.date = vac.date
		 where dea.continent is not null
