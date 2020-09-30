-- Creation of Schema

CREATE SCHEMA cruiseships

USE cruiseships

-- Creation of table #1

CREATE TABLE ships
(name VARCHAR(50),
callsign VARCHAR(50),
wiki VARCHAR(100),
imo VARCHAR(100),
mmsi VARCHAR(100),
cruise_line VARCHAR(50),
major_cruise_line VARCHAR(50),
year_built DATE,
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
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(name,callsign,wiki,imo,mmsi,cruise_line,major_cruise_line,year_built,class,gross_tonnage,decks,capacity,shiplength,vessel_type,flag,home_port)

-- Creation of Table #2
CREATE TABLE dailylocation
(ship_name VARCHAR(50),
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
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(ship_name,callsign,major_cruise_line,loc_date,meters_traveled,lat_start,lon_start,lat_end,lon_end,in_port,stopped_minutes,num_periods,port_city_id,port_city_name,port_city_country)

-- Creation of Table #3
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
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(id,city,country,country_code,lat,lon)

-- Creation of Table #4
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
PRIMARY KEY(date_published));


LOAD DATA LOCAL INFILE '/Users/Terez/Desktop/brandon-telle-cruise-ship-locations_copy/output_deaths.csv'
INTO TABLE deaths
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(date_published,death_time,death_type,deceased_name,deceased_age,deceased_gender,is_passenger,is_crew,ship_cruise_line,ship_name,ship_callsign,url)
