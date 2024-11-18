Select * 
From Covid..death
Order By 3,4
Select * 
From Covid..vaccination
Order By 3,4

--Select Data that we are going to be using 

Select location, date,  total_cases, new_cases, total_deaths,population
From Covid..death
order by 1,2

-- Looking at Total cases vs Total Deaths
-- Shows Likelihood of dying if you contract covid in your country
Select location, date,  total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From Covid..death
where location like '%states%'
order by 1,2

-- Looking at Total cases vs Population
-- shows what percentage of Population got Covid
Select location, date, Population, total_cases,(total_cases/population)*100 as Deathpercentage
From Covid..death
--where location like '%states%'
order by 1,2

-- Looking at Country with Highest Infection Rate compared to Population 

select location, population,max(total_cases) as Highestinfectioncount, max((total_cases/Population)) as 
percentPopulationInfected
From Covid..death 
Group By location, population
order By percentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population 

select location,MAX(Total_deaths) as TotalDeathCount
From Covid..death 
Group By location
Order By TotalDeathCount desc

--LET's BREAK THINGS DOWN BY CONTINENT 

Select location, max(cast(Total_deaths as int)) as TotalDeathcount 
From Covid..death
where continent is null
Group By location
Order By TotalDeathCount desc

--Showing continents with  the highest Death count  per Population 

Select location, max(cast(Total_deaths as int)) as TotalDeathcount 
From Covid..death
where continent is not null
Group By location
Order By TotalDeathCount desc


--Global Number 

Select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int ))/SUM(New_cases)*100 as DeathPercentage
From Covid..death
where continent is not null
order by 1,2


-- Lookinng at Total Population vs Vaccination 
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
sum(CONVERT(int,dea.new_vaccinations)) over (partition By dea.location Order By dea.location, dea.date) as 
RollingPeopleVaccinated
From  Covid..death dea
Join  Covid..vaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 1,2,3


 --USE CTE

 With PopvsVac  (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as
 (
 Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
sum(CONVERT(int,dea.new_vaccinations)) over (partition By dea.location Order By dea.location, dea.date) as 
RollingPeopleVaccinated
From  Covid..death dea
Join  Covid..vaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
-- order by 1,2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table 
Drop Table If exists ##PercentPopulationVacccinated
Create Table #PercentPopulationVacccinated
(
Continent nvarchar(255),
Location  Nvarchar(255),
Date datetime,
Population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVacccinated
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
sum(CONVERT(int,dea.new_vaccinations)) over (partition By dea.location Order By dea.location, dea.date) as 
RollingPeopleVaccinated
From  Covid..death dea
Join  Covid..vaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 1,2,3

 Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVacccinated


--Creaating View to store for later visualizations 

Create view PercentPopulationVacccinated as 
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
sum(CONVERT(int,dea.new_vaccinations)) over (partition By dea.location Order By dea.location, dea.date) as 
RollingPeopleVaccinated
From  Covid..death dea
Join  Covid..vaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 1,2,3

 Select * 
 From PercentPopulationVacccinated