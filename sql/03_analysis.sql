
-- EDA --
-- 1) Checking duplicates 

Select type_of_crime, 
       timestamp, 
       address, 
       neighbourhood, 
       longitude, 
       latitude, 
       count(*) as "occurrences"
from crime_data
group by type_of_crime, timestamp, address, neighbourhood,longitude, latitude
having count(*) > 1;

/* Query Purpose:
To analyze the daily frequency of each type of crime over the 10-year period by grouping records by
timestamp (converted to date) and type_of_crime.

Reason:
Due to privacy offsetting in location data (e.g., slightly shifting coordinates or addresses),
multiple entries may refer to the same incident. To avoid misinterpretation, this query focuses on time and category, 
rather than location, to get a cleaner view of crime trends.
*/

Select  date(timestamp) as "crime_day",
        type_of_crime,
        count(*) as "reported_count"
from crime_data
group by crime_day, type_of_crime
order by crime_day;


-- Checking null values--
Select * 
from crime_data
where type_of_crime is null or neighbourhood is null;

/*
Notes regarding above for the report:
A total of 56 records were found to have missing neighbourhood values. Based on the pattern observed, 
these records are associated with sensitive offenses such as 'Offence Against a Person'.
It is likely that these values were intentionally omitted due to privacy regulations or anonymization protocols.
*/

-- Replacing null values with unknown for the above query
UPDATE crime_data
SET neighbourhood = 'Unknown'
WHERE neighbourhood IS NULL;


--crime by categories--
SELECT 
    DATE(timestamp) AS date,
    COUNT(*) AS daily_crimes
FROM crime_data
WHERE timestamp >= NOW() - INTERVAL '3 months'
GROUP BY date
ORDER BY date;


--2) Counting total number of crimes  in 10 years--
select count(*) as "total_crimes"
from crime_data;


-- 3)Counting total number of crimes in last 5 years --

Select count(*) as "total_crime"
from crime_data
where extract(year from timestamp) between 2020 and 2025;


-- 4) Top 5 crime rates over the 10 year period --
select type_of_crime, count(*) as "counts"
from crime_data
group by type_of_crime
order by counts desc
Limit 5;

-- 5) Top 5 crine rates over the 5 year period --
select type_of_crime, 
       count(*) as "counts"
from crime_data
where extract( year from timestamp) between 2020 and 2025
group by type_of_crime
order by counts desc
Limit 5;

-- 6) Top 5 neighbourhood with highest number of counts over the 10 year period

Select distinct neighbourhood, count(*) as "counts"
from crime_data
group by neighbourhood
order by counts desc
limit 5;

--7)  Top 5 neighbourhood with highest number of counts over the 5 year period
Select distinct neighbourhood, count(*) as "counts"
from crime_data
where extract(year from timestamp)between 2020 and 2025
group by neighbourhood
order by counts desc;

--note: this is the most common crime by area 

Select distinct neighbourhood,
                type_of_crime, 
				count(*) as "counts"
from crime_data
group by neighbourhood, type_of_crime
order by counts desc;

-- Time series based analysis --

-- Month wise crime trend over the 10 year period
Select extract(year from timestamp) as "years",
       extract(month from timestamp) as "months",
       count(*) as "counts"
from crime_data
where extract(year from timestamp) between 2015 and 2025
group by years, months
order by years, months;

-- Month wise crime trend over the 5 year period
select extract(year from timestamp) as "years",
       extract(month from timestamp)as "months",
       count(*) as "counts"
from crime_data
where extract(year from timestamp) between 2020 and 2025
group by years, months
order by years, months;

--  quarterly crime trends (2021–2025 only)

select extract(year from timestamp) as "years",
       extract(quarter FROM timestamp) as "quarters",
       count(*) as "counts"
from crime_data
where extract(year from timestamp) between 2021 and 2025
group by years, quarters
order by years, quarters;

-- Location based Analysis --

Select neighbourhood, 
       count(*) as "total_crimes"
from crime_data
where timestamp >= NOW() - INTERVAL '5 years'
group by neighbourhood
order by total_crimes desc;

-- Comparing trends over time --
with crime_counts as (
select neighbourhood,
       extract(year from timestamp) as "years"
from crime_data
)
select neighbourhood,
count(*) filter (where years between 2015 and 2019) as "crimes_early",
count(*) filter (where years between 2020 and 2024) as "crimes_recent",
round(100.0 * (count(*) filter (where years between 2020 and 2024) - count(*) filter (where years between 2015 and 2019)) 
 / nullif(count(*) filter (where years between 2015 and 2019), 0), 2
  ) as "percent_change"
from crime_counts
group by neighbourhood
order by percent_change desc;

--Crime rate for past 10 years by percentage
with crime_type_counts as (
Select type_of_crime,
      EXTRACT(YEAR FROM timestamp) AS year
  FROM crime_data
)
SELECT 
  type_of_crime,
  COUNT(*) FILTER (WHERE year BETWEEN 2015 AND 2019) AS crimes_early,
  COUNT(*) FILTER (WHERE year BETWEEN 2020 AND 2024) AS crimes_recent,
  ROUND(
    100.0 * (
      COUNT(*) FILTER (WHERE year BETWEEN 2020 AND 2024) -
      COUNT(*) FILTER (WHERE year BETWEEN 2015 AND 2019)
    ) / NULLIF(COUNT(*) FILTER (WHERE year BETWEEN 2015 AND 2019), 0),
    2
  ) AS percent_change
FROM crime_type_counts
GROUP BY type_of_crime
ORDER BY percent_change DESC;

-- Checking location parameter(mean) for the crime rate by neighbourhood and to find treshold for future analysis 

With dailycrimes as (
Select neighbourhood, 
       type_of_crime,
       date(timestamp) as "crime_day",
	   count(*) as "daily_count"
from crime_Data
group by neighbourhood, crime_day, type_of_crime
)
Select neighbourhood,
       crime_day, 
	   count(*) as "total_crime",
	   round(avg(daily_count),2) as "avg_daily_crimes"
from dailycrimes
group by neighbourhood, crime_day;   

-- 	Checking avergae crime rate by years  
With YearlyCounts as (
Select neighbourhood,
       type_of_crime,
	   extract(year from timestamp) as "years",
	   count(*) as "yearly_counts"
from crime_data
group by neighbourhood, type_of_crime, years
)
Select years,
	   count(*) as "total_crime_by_years",
	   round(avg(yearly_counts), 2) as "avg_yearly_counts"
from YearlyCounts
group by years
order by years;


-- Total crime rate for the first quarter of 2025
WITH quarter1_2025 AS (
  SELECT Extract(month from timestamp) as "m",
         Count(*) as "total_count_of_crimes_by_month"
  FROM crime_data
  WHERE timestamp >= '2025-01-01' AND timestamp < '2025-04-01'
  group by m
)
SELECT distinct m as "months",
       sum(total_count_of_crimes_by_month) as "total_crimes_by_month"
FROM quarter1_2025
GROUP BY months
ORDER BY months;

--Crime location
SELECT latitude, longitude
FROM crime_data
WHERE timestamp >= '2025-01-01' AND timestamp < '2025-04-01'
AND latitude IS NOT NULL AND longitude IS NOT NULL;




SELECT MIN(latitude), MAX(latitude), MIN(longitude), MAX(longitude)
FROM crime_data;


