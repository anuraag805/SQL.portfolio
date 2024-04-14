SELECT *
FROM PortfolioProject..Death
WHERE continent is not null 
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..Vaccination
--ORDER BY 3,4

--Select Data which we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Death
ORDER BY 1,2

--Looking at total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float) /cast(total_cases as float))*100 AS Death
FROM PortfolioProject..Death
WHERE location like '%India%'
ORDER BY 1,2

--Looking at total cases vs population
--Shows the percentage of population suffer from covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentOfTotalCases
FROM PortfolioProject..Death
WHERE location like '%india%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate Compared to Population

SELECT location, MAX(total_cases) as PopulationWithHighestInfection, population, (MAX(total_cases/population))*100 AS PercentOfMaximumTotalCases
FROM PortfolioProject..Death
--WHERE location like '%india%'
GROUP BY location, population
ORDER BY PercentOfMaximumTotalCases desc

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int))as TotalDeathCount
FROM PortfolioProject..Death
--WHERE location like '%india%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc 

--To Check Total Deaths in Continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..Death
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--To check the Total Death of locations including Null

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..Death
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

--Global Numbers

SELECT date, total_cases, total_deaths, (cast(total_deaths as float) /cast(total_cases as float))*100 AS DeathPercenatage
FROM PortfolioProject..Death
--WHERE location like '%India%'
WHERE continent is not null
ORDER BY 1,2

--When we group by date we need an aggregate function

SELECT date, SUM(new_cases)
FROM PortfolioProject..Death
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases , SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentages
FROM PortfolioProject..Death
--WHERE location like '%india%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--COVID Vaccination

SELECT*
FROM PortfolioProject..Death dea
JOIN PortfolioProject..Vaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date

--Looking for Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..Death dea
JOIN PortfolioProject..Vaccination vac
	ON dea.date = vac.date
	and dea.location = vac.location
WHERE dea.continent is not null
ORDER BY 1,2,3

SELECT dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location)
FROM PortfolioProject..Death dea
JOIN PortfolioProject..Vaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3

Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, CONVERT(date, dea.date)) AS PeopleVaccinated
From PortfolioProject..Death dea
Join PortfolioProject..Vaccination vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3

--USE CTE to find totalpeoplevaccinated / population

WITH PopvsVac (continent, Location, date, Population, new_vaccination, PeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, CONVERT(date, dea.date)) AS PeopleVaccinated
From PortfolioProject..Death dea
Join PortfolioProject..Vaccination vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

SELECT*, (PeopleVaccinated/Population)*100 AS PercentOfPopulationVaccinated
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentOfPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, CONVERT(date, dea.date)) AS PeopleVaccinated
From PortfolioProject..Death dea
Join PortfolioProject..Vaccination vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3

SELECT*, (PeopleVaccinated/Population)*100 AS PercentOfPopulationVaccinated
FROM #PercentPopulationVaccinated

--CREATING VIEWS

CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, CONVERT(date, dea.date)) AS PeopleVaccinated
From PortfolioProject..Death dea
Join PortfolioProject..Vaccination vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

SELECT*
FROM PercentPopulationVaccinated