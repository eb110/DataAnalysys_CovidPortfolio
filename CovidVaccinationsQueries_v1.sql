select * from PortfolioProject..CovidVaccinations

select * from PortfolioProject..CovidDeaths

--total vaccinations population percentage
select dth.location, dth.population, sum(cast(vac.new_vaccinations as int)) as total_vaccinations,
round(sum(cast(vac.new_vaccinations as int)) / dth.population * 100, 2) as vacc_percentage
from PortfolioProject..CovidVaccinations as vac
join PortfolioProject..CovidDeaths as dth
on vac.location = dth.location and vac.date = dth.date
where vac.new_vaccinations is not null and dth.continent is not null
group by dth.location, dth.population
order by 4 desc

--looking at the percentage of people vaccineted based on date and specific location
--the rolling requires costly process so it has been placed in CTE and then reused

--CTE
with PopVsVac(Contient, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(select dth.continent, dth.location, dth.date, dth.population,
cast(vac.new_vaccinations as int) as New_Vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dth.location order by dth.date) as RollingPeopleVaccinate
from PortfolioProject..CovidVaccinations as vac
join PortfolioProject..CovidDeaths as dth
on vac.location = dth.location and vac.date = dth.date
where vac.new_vaccinations is not null and dth.continent is not null)
--order by 1,2)

select *, round(RollingPeopleVaccinated / Population * 100, 2) as percentage from PopVsVac

--same solution but with temporary table approach
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dth.continent, dth.location, dth.date, dth.population,
cast(vac.new_vaccinations as int) as New_Vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dth.location order by dth.date) as RollingPeopleVaccinate
from PortfolioProject..CovidVaccinations as vac
join PortfolioProject..CovidDeaths as dth
on vac.location = dth.location and vac.date = dth.date
where vac.new_vaccinations is not null and dth.continent is not null

select *, round((RollingPeopleVaccinated / Population * 100), 4) as percentage from #PercentPopulationVaccinated
order by 2,3

--creating the View to store data for later visualization

create view PercentPopulationVaccinated as
select dth.continent, dth.location, dth.date, dth.population,
cast(vac.new_vaccinations as int) as New_Vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dth.location order by dth.date) as RollingPeopleVaccinate
from PortfolioProject..CovidVaccinations as vac
join PortfolioProject..CovidDeaths as dth
on vac.location = dth.location and vac.date = dth.date
where vac.new_vaccinations is not null and dth.continent is not null

select * from PortfolioProject..PercentPopulationVaccinated
order by 2,3
