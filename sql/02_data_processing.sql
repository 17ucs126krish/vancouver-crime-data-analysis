-- Data Preprocessing --
-- Converting years, months, days and other similar varibales into timestamp

--ALTER TABLE crime_data ADD COLUMN timestamp TIMESTAMP;

--UPDATE crime_data
--SET timestamp = make_timestamp(years, months, days, hours, minutes, 0);

-- Removing the time vailables like years, month etc since we already created a seperate column for that

-- ALTER TABLE crime_data
-- DROP COLUMN years,
-- DROP COLUMN months,
-- DROP COLUMN days,
-- DROP COLUMN hours,
-- DROP COLUMN minutes;

-- Changing the  column names of x and y
-- ALTER TABLE crime_data
-- RENAME COLUMN x TO longitude;

--ALTER TABLE crime_data
--RENAME COLUMN y TO latitude;
