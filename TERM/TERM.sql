-- Creation of Schema

CREATE SCHEMA cruiseships;

USE cruiseships;

-- First I created and loaded all my data into the tables
-- To do so, this first needs to be turned on

SHOW VARIABLES LIKE "local_infile";
SET GLOBAL local_infile = ON;
SET FOREIGN_KEY_CHECKS=0;

-- Creation of table #1

DROP TABLE IF EXISTS ships;

CREATE TABLE ships
(ship_name VARCHAR(50),
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
PRIMARY KEY(ship_name));

LOAD DATA LOCAL INFILE '/Users/Terez/Desktop/brandon-telle-cruise-ship-locations_copy/output_ships.csv'
INTO TABLE ships
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(ship_name,callsign,wiki,imo,mmsi,cruise_line,major_cruise_line,@year_built,class,gross_tonnage,decks,capacity,shiplength,vessel_type,flag,home_port)
SET
year_built = nullif(@year_built, '');

SELECT * FROM ships;

-- Creation of Table #2

DROP TABLE IF EXISTS deaths;

CREATE TABLE deaths
(death_ID INT NOT NULL AUTO_INCREMENT,
date_published DATE,
death_type VARCHAR(100),
deceased_name VARCHAR(100),
deceased_age INTEGER,
deceased_gender VARCHAR(10),
is_passenger VARCHAR (10),
is_crew VARCHAR(10),
ship_cruise_line VARCHAR(50),
ship_name VARCHAR(50) NOT NULL,
ship_callsign VARCHAR (50),
url VARCHAR(100), 
PRIMARY KEY(death_ID),
FOREIGN KEY (ship_name)
REFERENCES ships(ship_name));

LOAD DATA LOCAL INFILE '/Users/Terez/OneDrive - Central European University/Data_Engeniering_01/DE1_Homework/TERM/Cleaned_data/output_deaths.csv'
INTO TABLE deaths
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r' 
IGNORE 1 LINES
(date_published,death_type,deceased_name,@deceased_age,deceased_gender,is_passenger,is_crew,ship_cruise_line,ship_name,ship_callsign,url)
SET
	deceased_age = nullif(@deceased_age, '');

SELECT * FROM deaths LIMIT 50;

-- Creation of Table #3

DROP TABLE IF EXISTS itinerary;

CREATE TABLE itinerary
(country VARCHAR (100),
country_code VARCHAR (20),
itinerary VARCHAR (100),
PRIMARY KEY(country_code));

LOAD DATA LOCAL INFILE '/Users/Terez/OneDrive - Central European University/Data_Engeniering_01/DE1_Homework/TERM/Cleaned_data/cruise_itinerary_data.csv'
INTO TABLE itinerary
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r' 
IGNORE 1 LINES
(country,country_code,itinerary);

SELECT * FROM itinerary LIMIT 50;

-- Creation of Table #4

DROP TABLE IF EXISTS dailylocation;

CREATE TABLE dailylocation
(unique_ID INT NOT NULL AUTO_INCREMENT,
ship_name VARCHAR(50) NOT NULL,
callsign VARCHAR(50),
loc_date DATE,
lat_start FLOAT,
lon_start FLOAT,
lat_end FLOAT,
lon_end FLOAT,
in_port VARCHAR(10),
port_city_id VARCHAR (100),
port_city_name VARCHAR(100),
port_country VARCHAR (20),
PRIMARY KEY(unique_ID),
FOREIGN KEY (ship_name)
REFERENCES ships(ship_name),
FOREIGN KEY (port_country)
REFERENCES itinerary(country_code));

LOAD DATA LOCAL INFILE '/Users/Terez/OneDrive - Central European University/Data_Engeniering_01/DE1_Homework/TERM/Cleaned_data/output_daily_ship_location.csv'
INTO TABLE dailylocation
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(ship_name,callsign,loc_date,lat_start,lon_start,lat_end,lon_end,in_port,port_city_id,port_city_name, port_country);

SELECT * FROM dailylocation LIMIT 50;


-- ANALYSIS
-- Which route did most people die on? (use country to determine possible route)

-- Analytical layer (Data warehouse) : All deaths on ships by date
-- ETL: pulling the new daily entries to dailylocation into the Data Warehouse and from there to the Data Marks
-- Data marks: Deaths comparing cruise lines, years, and routes

-- Now I can combine the tables with a JOIN to give me a new table to create an Analytical Data Layer

-- First I am joining some of the smaller tables to make the future joins easer

-- Deaths and ships

DROP TABLE IF EXISTS deaths_on_ships;

CREATE TABLE deaths_on_ships AS
	SELECT
		d.death_ID,
        d.date_published,
        d.is_passenger,
        s.ship_name,
        s.cruise_line,
        s.major_cruise_line
			FROM deaths AS d
            LEFT JOIN ships AS s
            USING (ship_name);

SELECT * FROM deaths_on_ships;
    
-- Analytical layer table

DROP TABLE IF EXISTS deaths_by_itinerary;

CREATE TABLE deaths_by_itinerary(
	ID INT NOT NULL AUTO_INCREMENT,
	date_published DATE,
    is_passenger VARCHAR (20),
    ship_name VARCHAR (50),
    major_cruise_line VARCHAR (50),
    itinerary VARCHAR (100),
    PRIMARY KEY(ID));

-- ETL

-- For transformation, I will solve the issue of the column length of dailylocation.port_country

SELECT LENGTH(port_country) FROM dailylocation;

-- First importing of data

TRUNCATE deaths_by_itinerary;

DROP PROCEDURE IF EXISTS aggregation;

DELIMITER $$

CREATE PROCEDURE aggregation()
BEGIN
	INSERT INTO deaths_by_itinerary
	SELECT
		NULL,
		d.date_published,
		d.is_passenger,
		d.ship_name,
		d.major_cruise_line,
		i.itinerary
			FROM dailylocation dl
				INNER JOIN deaths_on_ships d
				ON dl.ship_name = d.ship_name
					AND dl.loc_date = d.date_published
				LEFT JOIN itinerary i
				ON LEFT(dl.port_country,2) = i.country_code
			ORDER BY d.date_published;
END $$

DELIMITER ;

CALL aggregation();

SELECT * FROM deaths_by_itinerary LIMIT 10;


-- Adding new data to the table when it is added in the operational layer

DROP TABLE IF EXISTS messages;

CREATE TABLE IF NOT EXISTS messages (
message varchar(100) NOT NULL);

DROP TRIGGER IF EXISTS deaths_insert;

DELIMITER $$

CREATE TRIGGER deaths_insert
AFTER INSERT
ON deaths FOR EACH ROW
BEGIN
	INSERT INTO messages SELECT CONCAT('death_ID: ', NEW.death_ID);
    
    INSERT INTO deaths_on_ships
	SELECT
		d.death_ID,
        d.date_published,
        d.is_passenger,
        s.ship_name,
        s.cruise_line,
        s.major_cruise_line
			FROM deaths AS d
				LEFT JOIN ships AS s
				USING (ship_name)
            WHERE death_ID = NEW.death_ID;
END $$    

DELIMITER ;

DROP TRIGGER IF EXISTS deaths_insert_from_aggrgation; 

DELIMITER $$

CREATE TRIGGER deaths_insert_from_aggrgation
AFTER INSERT
ON deaths_on_ships FOR EACH ROW
BEGIN
	INSERT INTO messages SELECT CONCAT('death_on_ships_ID: ', NEW.death_ID);
    
    INSERT INTO deaths_by_itinerary
	SELECT
		NULL,
		d.date_published,
		d.is_passenger,
		d.ship_name,
		d.major_cruise_line,
		i.itinerary
			FROM dailylocation dl
				INNER JOIN deaths_on_ships d
				ON dl.ship_name = d.ship_name
					AND dl.loc_date = d.date_published
				LEFT JOIN itinerary i
				ON LEFT(dl.port_country,2) = i.country_code
			WHERE death_ID = NEW.death_ID
            ORDER BY d.date_published;
END $$

DELIMITER ;

INSERT INTO deaths (date_published, death_type, deceased_name, deceased_age, deceased_gender, is_passenger, is_crew, ship_cruise_line, ship_name, ship_callsign, url)
VALUES('2017-08-15', 'suicide', 'Someone John', 45, 'Male', 'TRUE', 'FALSE', 'Carnival Cruise Lines', 'Carnival Splender', '', 'www.tlc.com');

SELECT * FROM deaths;
SELECT * FROM messages;

-- Data Marks in the form of views

-- Answer to original question
-- Do more people die in the Carribbean or in Northern Europe?

DROP VIEW IF EXISTS Northern_Europe_VS_Carribbean;

CREATE VIEW `Northern_Europe_VS_Carribbean` AS
SELECT * FROM deaths_by_itinerary WHERE deaths_by_itinerary.itinerary = 'Northern Europe' OR deaths_by_itinerary.itinerary = 'Carribbean and Antilles' ;

SELECT itinerary,COUNT(*) FROM Northern_Europe_VS_Carribbean GROUP BY itinerary;

-- Other interesting aspects
-- How many passangers die a year?

DROP VIEW IF EXISTS Passenger_deaths;

CREATE VIEW `Passenger_deaths` AS
SELECT is_passenger,date_published FROM deaths_by_itinerary WHERE deaths_by_itinerary.is_passenger = 'TRUE';

SELECT YEAR(date_published), COUNT(*) FROM Passenger_deaths GROUP BY YEAR(date_published);

-- Does Norvegian or Carneval have more total deaths?

DROP VIEW IF EXISTS Norwegian_VS_Carnival;

CREATE VIEW `Norwegian_VS_Carnival` AS
SELECT date_published, major_cruise_line FROM deaths_by_itinerary WHERE major_cruise_line ='Norwegian Cruise Line' OR major_cruise_line ='Carnival Cruise Line';

SELECT major_cruise_line, COUNT(*) FROM Norwegian_VS_Carnival GROUP BY major_cruise_line;
