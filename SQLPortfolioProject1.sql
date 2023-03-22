SELECT *
FROM PortfolioProject1..CovidDeaths
order by 3,4

--SELECT *
--FROM PortfolioProject1..CovidVaccinations
--order by 3,4

--Select Data that would be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths 
order by 1,2

--Comparing Total Cases Vs Total Deaths
--This depicts the likelihood of dying from covid in your country in 2020/2021
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths 
WHERE location like '%States' and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--This shows the percentage of people who got covid against the population of the country
Select location, date, total_cases, population, (total_cases/population)*100 as InfectedPopulationPercentage
From PortfolioProject1..CovidDeaths 
where location like '%states' and continent is not null
order by 1,2

--Countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as MaxInfectedPopulationPercentage
From PortfolioProject1..CovidDeaths 
WHERE continent is not null
group by location,population
order by MaxInfectedPopulationPercentage desc

--This shows countries with highest Death Count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths 
WHERE continent is not null
group by location
order by TotalDeathCount desc

--Breaking data down by continent
Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths 
WHERE CONTINENT IS NOT NULL
group by continent
order by TotalDeathCount desc

--Showing the continents with the highest Death Count
Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths 
WHERE CONTINENT IS NOT NULL
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths,Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths 
--WHERE location like '%States' 
WHERE continent is not null
--GROUP BY date
order by 1,2

--looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Cummulative_of_people_vaccinated
--,(Cummulative_of_people_vaccinated/population)*100 nb; we cant use this because we just introduced it hence we need CTE
From PortfolioProject1..CovidVaccinations vac
JOIN PortfolioProject1..CovidDeaths Dea
    ON vac.location = Dea.location
	and vac.date = Dea.date
	WHERE dea.continent is not null
	order by 2,3

--Using CTE

With PopvsVac (Continent, location, Date, Population, new_vaccinations, Cummulative_of_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Cummulative_of_people_vaccinated
From PortfolioProject1..CovidVaccinations vac
JOIN PortfolioProject1..CovidDeaths Dea
    ON vac.location = Dea.location
	and vac.date = Dea.date
	WHERE dea.continent is not null
	--order by 2,3
	)
 SELECT *, (Cummulative_of_people_vaccinated/Population)*100
 FROM PopvsVac

 --Using TEMP TABLE to obtain same results
 DROP table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 Date datetime, 
 Population numeric,
 New_vaccinations numeric, 
 Cummulative_of_people_vaccinated numeric
 ) 

 Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Cummulative_of_people_vaccinated
From PortfolioProject1..CovidVaccinations vac
JOIN PortfolioProject1..CovidDeaths Dea
    ON vac.location = Dea.location
	and vac.date = Dea.date
	WHERE dea.continent is not null
	--order by 2,3
	
 SELECT *, (Cummulative_of_people_vaccinated/Population)*100
 FROM #PercentPopulationVaccinated
 

 -- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Cummulative_of_people_vaccinated
--, (Cummulative_of_people_vaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

