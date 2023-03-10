-- Select relevent data we are using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectCovid..CovidDeaths
Order By 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows chances of dying if contracted with Covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProjectCovid..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Looking at Total Cases vs Population in United States
-- Shows what percentage of population caught Covid

Select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProjectCovid..CovidDeaths
Where location = 'United States'
Order by 1,2

-- Looking at the total death count for each continent

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProjectCovid..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- Looking at Countries with Highest Infection rate compared to Population

Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProjectCovid..CovidDeaths
Group By location, population
Order by PercentPopulationInfected desc

-- Looking at Countries with Highest Infection Rate based on date

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjectCovid..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


-- Continent with highest death count per population
-- Need to change total_deaths from a nvarchar to integer

Select location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
From PortfolioProjectCovid..CovidDeaths
Where continent is null
Group By location
Order by TotalDeathCount desc

-- Global Numbers
-- changed new_deaths from nvarchar to int

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2


-- Looking at Total Population vs Vaccinations
-- Joined tables CovidDeaths and CovidVaccinations with date and location

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.location is not null
Order by 1, 2, 3

-- CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.location is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.location is not null
Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating Views for data visualization

Create View PercentPopulatedVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.location is not null
--Order by 1, 2, 3
