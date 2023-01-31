Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
Order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2


--Total Cases vs Total Deaths(Death Percentage)

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Order by 1,2

--Likelihood of dying if you contract COVID in your country(Nigeria)

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where Location like '%Nigeria%'
Order by 1,2


--Looking at Total Cases vs Population

Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HigestInfectionCount, Max((total_cases/Population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by Location, Population
Order by PercentPopulationInfected desc

--Showing Continent with Highest Death Count Per Population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathcount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathcount desc



--GLOBAL NUMBERS

Select Sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
--Group by date
Order by 1,2


Select date, Sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by date
Order by 1,2




Select * 
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date


--Looking at Toatl Population vs Vaccination

Select dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations
,  SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.Location, 
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.Location = vac.Location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations
,  SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.Location, 
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.Location = vac.Location
and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE

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
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations
,  SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.Location, 
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.Location = vac.Location
and dea.date = vac.date
--Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations
,  SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.Location, 
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.Location = vac.Location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * 
From #PercentPopulationVaccinated