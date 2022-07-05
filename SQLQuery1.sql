Select *
From PortfolioProject..CovidDeath
Order by 3,4

Select *
From PortfolioProject..CovidVaccination
Order by 3,4

--Data selection for future use

Select location, date, population, total_cases, total_deaths
From Portfolioproject..CovidDeath
Order by 1,2

--Analysing total cases vs total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As [Percentage Death]
From Portfolioproject..CovidDeath
where location like '%kingdom%'
Order by 5 Desc

--Analysing Total cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 As [Percentage Cases per Population]
From Portfolioproject..CovidDeath
where location like '%kingdom%'
Order by 1,2

--Checking at Countries with Highest infection rate per population
Select location, MAX(total_cases) as [Highest Infection], population, MAX((total_cases/population))*100 As [Highest Percentage Case per Population per Country]
From Portfolioproject..CovidDeath
Group by location, population
Order by [Highest Percentage Case per Population per Country] Desc

--To Show Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as [Highest Death]
From Portfolioproject..CovidDeath
where continent is not null
Group by location
Order by [Highest Death] Desc

--ANALYSIS BY CONTINENT
Select continent, Sum(MAX(cast(total_deaths as int)) as [Highest Death]
From Portfolioproject..CovidDeath
where continent is not null
Group by continent
Order by [Highest Death] Desc

--GLOBAL ANALYSIS
Select date, SUM(new_cases) as [Global Daily New Cases], SUM(cast(new_deaths as int)) as [Global Daily New Deaths], (SUM(cast(new_deaths as int))/SUM(new_cases))*100 As [Global Percentage Death]
From Portfolioproject..CovidDeath
where continent is not null
--where location like '%kingdom%'
Group by Date 
Order by 1,2

--Global Summary
Select SUM(new_cases) as [Global Daily New Cases], SUM(cast(new_deaths as int)) as [Global Daily New Deaths], (SUM(cast(new_deaths as int))/SUM(new_cases))*100 As [Global Percentage Death]
From Portfolioproject..CovidDeath
where continent is not null
--where location like '%kingdom%'
--Group by Date 
Order by 1,2

--Combined Analysis
Select *
From Portfolioproject..CovidDeath dea
Join Portfolioproject..CovidVaccination vac
	On dea.location = vac.location 
	and dea.date = vac.date

--Analysing People Vaccinated vs Population
Select dea.continent, dea.location, dea.date, vac.new_vaccinations
From Portfolioproject..CovidDeath dea
Join Portfolioproject..CovidVaccination vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is  not null
Order by 2,3

--Rolling addition of Vaccination
Select dea.continent, dea.location, dea.date, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) [Daily Increment]
From Portfolioproject..CovidDeath dea
Join Portfolioproject..CovidVaccination vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is  not null
Order by 2,3

--Creating Common Table Expression (CTE)
With PopvsVac (Continent, Location, Date, Population, New_Vaccination, Daily_Increment)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) [Daily Increment]
From Portfolioproject..CovidDeath dea
Join Portfolioproject..CovidVaccination vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is  not null
)
Select *, (Daily_Increment/Population)*100

From PopvsVac

--Creating TEMP TABLE
DROP Table if exists #PopulationVaccinated
Create Table #PopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Daily_increment numeric
)
Insert into #PopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) [Daily Increment]
From Portfolioproject..CovidDeath dea
Join Portfolioproject..CovidVaccination vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is  not null

Select *
From #PopulationVaccinated

--Creating Views for Visualisation

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) [Daily Increment]
From Portfolioproject..CovidDeath dea
Join Portfolioproject..CovidVaccination vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is  not null