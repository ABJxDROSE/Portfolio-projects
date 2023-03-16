select * from 
CovidDeaths$	

select * from 
CovidVaccinations$

-- Total cases vs Total deaths

SELECT Location , date , total_cases , total_deaths , (total_deaths/total_cases) * 100 as DeathPercentage
FROM CovidDeaths$


-- Total cases vs population
SELECT Location , date , total_cases , population , (total_cases/ population) * 100 as InfectionRate
FROM CovidDeaths$

-- Highest infection rate
SELECT Location , population , MAX(total_cases) as HighestCases  , MAX(total_cases/ population) * 100 as InfectionRate
FROM CovidDeaths$
GROUP BY  Location,  population
ORDER BY  InfectionRate DESC

-- Highest deaths
SELECT Location  , MAX(cast(total_deaths as int)) as HighestDeaths
FROM CovidDeaths$
WHERE continent is not null
GROUP BY  Location 
ORDER BY  HighestDeaths DESC

--Highest deaths by continent
SELECT continent ,  MAX(cast(total_deaths as int)) as HighestDeaths
FROM CovidDeaths$
WHERE continent is not null
GROUP BY  continent 
ORDER BY  HighestDeaths DESC

-- Global death percentage
SELECT SUM(new_cases) as  total_cases ,  SUM(cast(new_deaths as int)) as  total_deaths , 
sum(cast(new_deaths as int)) /sum(new_cases)  * 100 as DeathPercentage
FROM CovidDeaths$
Where continent is not null


-- Global vaccinations

SELECT d.continent , d.location , d.date , d.population , new_vaccinations,
SUM(cast(new_vaccinations as int)) OVER (partition by d.location order by d.location , d.date) as 
Cumulative_cases
FROM CovidDeaths$ d
JOIN CovidVaccinations$ v
on d.location = v.location
and d.date = v.date
where d.continent is not null
ORDER BY 2,3

-- population percent vaccinated
WITH PopvsVac as 
(SELECT d.continent , d.location , d.date , d.population , new_vaccinations,
SUM(cast(new_vaccinations as int)) OVER (partition by d.location order by d.location , d.date) as 
Cumulative_vaccinations
FROM CovidDeaths$ d
JOIN CovidVaccinations$ v
on d.location = v.location
and d.date = v.date
where d.continent is not null)

SELECT * , (Cumulative_vaccinations/ population) * 100 as TotalVaccinationPercentage
FROM PopvsVac


--temp table 

DROP TABLE IF EXISTS #PercentPopVaccinated
create table #PercentPopVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Cumulative_vaccinations numeric)

insert into #PercentPopVaccinated
SELECT d.continent , d.location , d.date , d.population , new_vaccinations,
SUM(cast(new_vaccinations as int)) OVER (partition by d.location order by d.location , d.date) as 
Cumulative_vaccinations
FROM CovidDeaths$ d
JOIN CovidVaccinations$ v
on d.location = v.location
and d.date = v.date
where d.continent is not null

SELECT * , (Cumulative_vaccinations/ population) * 100 as TotalVaccinationPercentage
FROM #PercentPopVaccinated


--VIEW FOR LATER
CREATE VIEW 
PercentPopVaccinated AS 
SELECT d.continent , d.location , d.date , d.population , new_vaccinations,
SUM(cast(new_vaccinations as int)) OVER (partition by d.location order by d.location , d.date) as 
Cumulative_vaccinations
FROM CovidDeaths$ d
JOIN CovidVaccinations$ v
on d.location = v.location
and d.date = v.date
where d.continent is not null






























