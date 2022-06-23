Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3, 4

-- Select data that we are going to use
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1, 2

--Looking at Total cases vs. Total deaths
--Shows likelihood of dying in your country if you contact covid
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%ind%'
Order by 1,2

--Looking at Total cases vs. Population
Select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Where location like '%ind%'
Order by 1,2


--Countries with highest infection rate compared to population
Select location, Max(total_cases) as HighestInfectioncount, population, MAX((total_cases/population))*100 as PopulationPercentInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by PopulationPercentInfected desc

--Countries with highest Death count compared to population
Select location, Max(total_deaths) as HighestDeathcount, population, MAX((total_deaths/population))*100 as PopulationPercentDeath
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by PopulationPercentDeath desc

--Countries with highest Death count
Select location, Max(cast(total_deaths as int)) as TotalDeathcount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Breaking things by continent

-- null values are included is this by continent
Select continent, Max(cast(total_deaths as int)) as ContinentTotalDeathcount
From PortfolioProject..CovidDeaths
--Where continent is not null
Group by continent
Order by ContinentTotalDeathcount desc

-- vs

--Null included by location
Select location, Max(cast(total_deaths as int)) as ContinentTotalDeathcount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by ContinentTotalDeathcount desc

-- Global Numbers
Select  date ,SUM( new_cases), SUM(cast(new_deaths as int)) ,(SUM( new_cases)/SUM(cast(new_deaths as int)))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1, 2

-- Whole world
Select SUM( new_cases) as Total_cases, SUM(cast(new_deaths as int))as total_deaths ,(SUM(cast(new_deaths as int))/SUM( new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1, 2

-- Join Deaths and vacinations
-- Looking at total population vs vacination
Select dea.location,dea.continent, dea.population, dea.date, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeoplePopulation,
--(RollingPeoplePopulation/ dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by dea.location, dea.date

--Use CTE

With PopvsVac(continent, location, population, date, new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.location,dea.continent, dea.population, dea.date, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) 
Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--Order by dea.location, dea.date
)
Select *, (RollingPeopleVaccinated/ population)*100 as PercentagepopulationVaccinated
FRom PopvsVac
Order by PercentagepopulationVaccinated


--Temp table
Drop table if exists #PercentagePopuplationVaccinated
Create table #PercentagePopuplationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentagePopuplationVaccinated

Select dea.location,dea.continent, dea.population, dea.date, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) 
Over (Partition by dea.location Order by dea.location) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/ population)*100 as PercentagepopulationVaccinated
From #PercentagePopuplationVaccinated

--Creating view to store data for later visualizations

CREATE VIEW PopuplationVaccinated%v as
Select dea.location,dea.continent, dea.population, dea.date, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) 
Over (Partition by dea.location Order by dea.location) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null