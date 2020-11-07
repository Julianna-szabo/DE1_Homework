-- Creation of Schema

CREATE SCHEMA cruiseships;

USE cruiseships;

-- First I created and loaded all my data into the tables
-- Creation of table #1

DROP TABLE IF EXISTS ships;

CREATE TABLE ships
(name VARCHAR(50),
callsign VARCHAR(50),
wiki VARCHAR(100),
imo VARCHAR(100),
mmsi VARCHAR(100),
cruise_line VARCHAR(50),
major_cruise_line VARCHAR(50),
year_built INT,
class VARCHAR (50),
gross_tonnage INTEGER,
decks INTEGER,
capacity INTEGER,
shiplength INTEGER,
vessel_type VARCHAR(100),
flag VARCHAR(100),
home_port VARCHAR(100), 
PRIMARY KEY(name));

LOAD DATA LOCAL INFILE '/Users/Terez/Desktop/brandon-telle-cruise-ship-locations_copy/output_ships.csv'
INTO TABLE ships
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(name,callsign,wiki,imo,mmsi,cruise_line,major_cruise_line,@year_built,class,gross_tonnage,decks,capacity,shiplength,vessel_type,flag,home_port)
SET
year_built = nullif(@year_built, '');

-- Creation of Table #2

DROP TABLE IF EXISTS dailylocation;

CREATE TABLE dailylocation
(ship_name VARCHAR(50) NOT NULL,
callsign VARCHAR(50),
major_cruise_line VARCHAR(100),
loc_date DATE,
meters_traveled INTEGER,
lat_start FLOAT,
lon_start FLOAT,
lat_end FLOAT,
lon_end FLOAT,
in_port VARCHAR(10),
stopped_minutes INTEGER,
num_periods INTEGER,
port_city_id VARCHAR (100),
port_city_name VARCHAR(100),
port_city_country VARCHAR(100), 
PRIMARY KEY(ship_name));

LOAD DATA LOCAL INFILE '/Users/Terez/Desktop/brandon-telle-cruise-ship-locations_copy/output_daily_ship_location.csv'
INTO TABLE dailylocation
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(ship_name,callsign,major_cruise_line,loc_date,meters_traveled,lat_start,lon_start,lat_end,lon_end,in_port,stopped_minutes,num_periods,port_city_id,port_city_name,port_city_country);

-- Creation of Table #3

DROP TABLE IF EXISTS cities;

CREATE TABLE cities
(id VARCHAR(50),
city VARCHAR(50),
country VARCHAR (100),
country_code VARCHAR(100),
lat FLOAT,
lon FLOAT,
PRIMARY KEY(id));

LOAD DATA LOCAL INFILE '/Users/Terez/Desktop/brandon-telle-cruise-ship-locations_copy/output_cities.csv'
INTO TABLE cities
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(id,city,country,country_code,lat,lon);

-- Creation of Table #4 - MAYBE don't include since not relevant for analysis

DROP TABLE IF EXISTS deaths;

CREATE TABLE deaths
(date_published DATE,
death_time INTEGER,
death_type VARCHAR(100),
deceased_name VARCHAR(100),
deceased_age INTEGER,
deceased_gender VARCHAR(10),
is_passenger VARCHAR (10),
is_crew VARCHAR(10),
ship_cruise_line VARCHAR(50),
ship_name VARCHAR(50),
ship_callsign VARCHAR (50),
url VARCHAR(100), 
PRIMARY KEY(date_published, deceased_name));

LOAD DATA LOCAL INFILE '/Users/Terez/Desktop/brandon-telle-cruise-ship-locations_copy/output_deaths.csv'
INTO TABLE deaths
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES
(date_published,death_time,death_type,deceased_name,deceased_age,deceased_gender,is_passenger,is_crew,ship_cruise_line,ship_name,ship_callsign,url);


LOAD DATA LOCAL INFILE '/Users/Terez/Desktop/brandon-telle-cruise-ship-locations_copy/output_deaths.csv'
INTO TABLE deaths
CHARACTER SET latin1
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(date_published,death_time,death_type,deceased_name,deceased_age,deceased_gender,is_passenger,is_crew,ship_cruise_line,ship_name,ship_callsign,url);

SELECT * FROM deaths;

-- ANALYSIS
-- 1, How many large ships are in a certain city at once?
-- 2, How many ships from one company are docked in the same country on the same day?
-- 3, Where are the different ships of one fleet docked at the same time?
-- 4, Which ship did most people die on?
-- 5, Which route did most people die on? (use country to determine possible route)

-- Analytical layer (Data warehouse) : All the ships in any port every day
-- ETL: pulling the new daily entries to dailylocation into the Data Warehouse and from there to the Data Marks
-- Data marks: Different views by cruise line company, different views by port

-- To be able to do the joins I need to delete some columns for the dailylocation table

ALTER TABLE dailylocation
DROP COLUMN port_city_country;
ALTER TABLE dailylocation
DROP COLUMN major_cruise_line;

-- Now I can combine the tables with a JOIN to give me a new table

-- Analytical layer table

DROP TABLE IF EXISTS dailylocation_complete;

CREATE TABLE dailylocation_complete(
	ID INT NOT NULL AUTO_INCREMENT,
	ship_name VARCHAR (50),
    callsign VARCHAR (50),
    cruise_line VARCHAR (50),
    major_cruise_line VARCHAR (50),
    loc_date DATE,
    meters_traveled INT,
    lat_start FLOAT,
    lon_start FLOAT,
    lat_end FLOAT,
    lon_end FLOAT,
    in_port VARCHAR (10),
    stopped_minutes INT,
    num_periods INT,
    id_city VARCHAR (50),
    city VARCHAR (50),
    country VARCHAR (50),
    country_code VARCHAR (10),
    lat_city FLOAT,
    lon_city FLOAT,
    imo VARCHAR (100),
    mmsi VARCHAR (100),
    year_built INT,
    class VARCHAR (50),
    gross_tonnage INT,
    decks INT,
    capacity INT,
    shiplength INT,
    vessel_type VARCHAR (50),
    flag VARCHAR (50),
    home_port VARCHAR (100), 
    PRIMARY KEY(ID));


-- ETL

-- First importing of data

DROP PROCEDURE IF EXISTS aggregation;

DELIMITER $$

CREATE PROCEDURE aggregation()

BEGIN
	INSERT INTO dailylocation_complete
	SELECT
		NULL,
		d.ship_name,
		d.callsign,
		s.cruise_line,
		s.major_cruise_line,
		d.loc_date,
		d.meters_traveled,
		d.lat_start,
		d.lon_start,
		d.lat_end,
		d.lon_end,
		d.in_port,
		d.stopped_minutes,
		d.num_periods,
		c.id AS id_city,
		c.city,
		c.country,
		c.country_code,
		c.lat AS lat_city,
		c.lon AS lon_city,
		s.imo,
		s.mmsi,
		s.year_built,
        s.class,
		s.gross_tonnage,
		s.decks,
		s.capacity,
		s.shiplength,
		s.vessel_type,
		s.flag,
		s.home_port
			FROM dailylocation d
				LEFT JOIN cities c
				ON port_city_id = id
				LEFT JOIN ships s
				USING (callsign);
END $$

DELIMITER ;

CALL aggregation();

SELECT * FROM dailylocation_complete;

-- Adding new data to the table when it is added in the operational layer



