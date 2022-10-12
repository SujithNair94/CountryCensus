-- The Dataset is based out of Country census for 2011. The dataset contains area, Km, Literacy , sex ratio and growth % ---

-- Dataset for Gujarat and Maharashtra --

select * from PortfolioProject.dbo.Data1
where State in ('Gujarat' , 'Maharashtra');

--Total Population of India--

select sum(Population) as TotalPopulationofIndia
from PortfolioProject.dbo.Data2;

-- Average Growth of the country

select (avg(Growth)*100) as Average_Growth 
from PortfolioProject.dbo.Data1 ;

--Average Growth by State--

select State, (avg(Growth)*100) as Avg_Growth_Percentage
from PortfolioProject.dbo.Data1 
group by State;

-- Average Sex Ratio

select State,round(avg(Sex_Ratio),0) as Sex_Ratio_Avg 
from PortfolioProject.dbo.Data1
group by State
order by Sex_Ratio_Avg desc;

--States with highest Literacy Ratio (Greater then 90)--

select State, round(avg(Literacy),0) as Avg_Literacy_Ratio 
from PortfolioProject.dbo.Data1
group by State
having avg(Literacy) > 90
order by Avg_Literacy_Ratio desc;

--Top 3 states which are displaying the highest grwoth ratio--

select top 3 State, (avg(Growth)*100) as Avg_Growth_Percentage
from PortfolioProject.dbo.Data1 
group by State
order by Avg_Growth_Percentage desc;

--Bottom 3 states which are displaying the lowest sex ratio--

select top 3 State,round(avg(Sex_Ratio),0) as Sex_Ratio_Avg 
from PortfolioProject.dbo.Data1
group by State
order by Sex_Ratio_Avg asc;

-- States performing extremely well and states performing extremely poor for Literacy rate --

drop table if exists #topstate
create table #topstate
( State nvarchar(255),
  Literacy_Rate float
  );

insert into #topstate
select State, round(avg(Literacy),0) as Avg_Literacy_Ratio 
from PortfolioProject.dbo.Data1
group by State
order by Avg_Literacy_Ratio desc;

select top 3 * from #topstate
order by Literacy_Rate desc ;


drop table if exists #Bottomstate
create table #Bottomstate
( State nvarchar(255),
  Literacy_Rate float
  );

insert into #Bottomstate
select State, round(avg(Literacy),0) as Avg_Literacy_Ratio 
from PortfolioProject.dbo.Data1
group by State
order by Avg_Literacy_Ratio asc;

select top 3 * from #Bottomstate
order by Literacy_Rate asc ;


select * from(
select top 3 * from #topstate
order by Literacy_Rate desc) a
union
select * from(
select top 3 * from #Bottomstate
order by Literacy_Rate asc) b;


-- Pull States with names starting from Alphabet A--

select distinct(State)
from PortfolioProject.dbo.Data1
where State like 'A%'
order by State;

-- Total number of Males and Females by State--


       ----- To calculate sex ratio we need to creae calc fr Male and female sex ratio 
       ----- Female + Male = Population  Hence Female = Population - Male  ------------
	   ----- Sex Ratio = Female/Male= Population-Male/Male .. Population-Male= Sex ratio + Male= Population=Sexratio*Male+male---
	   ----- Male = Population/Sexratio+1 and Female = Population-(Population/Sexratio+1) = (Population*Sexratio)/Sexratio +1---



select d.state , sum(d.Male) as Male , sum(d.female) as Female from
(select c.district , c.State, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) as Female , round((c.population)/(c.sex_ratio+1),0) as Male from
(select a.district , a.state , (a.sex_ratio)/1000 as sex_ratio , b.population
from PortfolioProject.dbo.Data1 a inner join PortfolioProject.dbo.Data2 b
on a.district = b.district) c ) d
group by d.state;

--- Literacy Rate broken down by States --

-- Total Literate People/Population = Literacy Ratio... Total Literate People= Population*LiteracyRatio
-- Similary Total Illiterate People = (1-Literacy Ratio)*Population

select d.State , sum(Total_Literate_People) as Literate , sum(Total_Illiterate_People) as Illiterate from 
(select c.district , c.State , round((c.population*c.literacyRatio),0) as Total_Literate_People , round((1-c.LiteracyRatio)*c.population,0) as Total_Illiterate_People from 
(select a.district , a.State , b.Population , a.literacy/100 as LiteracyRatio
from PortfolioProject.dbo.Data1 a inner join PortfolioProject.dbo.Data2 b
on a.District = b.District) c) d 
group by d.State;

--- Population In Previous Census vs Current Census ---

select sum(e.Previous_Population) as Population_Before , sum(e.Current_Population) as Population_Current from 
(select d.State, sum(d.Prev_Population) as Previous_Population , sum(d.Population) as Current_Population from 
(select c.State , round((c.Population)/(1+c.Growth_Rate),0) as Prev_Population , c.Growth_Rate , c.Population from
(select a.District , a.State , a.Growth as Growth_Rate , b.Population
from PortfolioProject.dbo.Data1 a inner join PortfolioProject.dbo.Data2 b
on a.District = b.District) c ) d 
group by d.State ) e;


-- Area by Population. Since the Population increased but the Area remains the same. We need to identify the Area by Previous Population vs Area by Current Population--


select (k.Total_Area/k.Population_Before) as Prev_Population_vs_Area , (k.Total_Area/k.Population_Current) as Current_Population_vs_Area from
(select h.* , i.Total_Area from 
(select '1' as Col1,f.* from (
select sum(e.Previous_Population) as Population_Before , sum(e.Current_Population) as Population_Current from 
(select d.State, sum(d.Prev_Population) as Previous_Population , sum(d.Population) as Current_Population from 
(select c.State , round((c.Population)/(1+c.Growth_Rate),0) as Prev_Population , c.Growth_Rate , c.Population from
(select a.District , a.State , a.Growth as Growth_Rate , b.Population
from PortfolioProject.dbo.Data1 a inner join PortfolioProject.dbo.Data2 b
on a.District = b.District) c ) d 
group by d.State ) e ) f ) h
inner join 
(select '1' as Col2,g.* from
(select sum(Area_km2) as Total_Area from PortfolioProject.dbo.Data2) g) i on h.Col1 = i.Col2 ) k

-- Top 3 Districts from Each state with Highest Literacy Rate --

select a.* from (
select District,state,Literacy,rank() over (partition by state order by Literacy desc) rnk
from PortfolioProject.dbo.Data1 ) a
where a.rnk in (1,2,3)
order by state;