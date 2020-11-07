-- HOMEWORK 5

-- Import table with area codes

USE classicmodels;

SELECT * FROM customers WHERE country = 'USA' AND length(phone) = 7;
SELECT * FROM areacodes WHERE city = 'Brickhaven';
SELECT * FROM fixed_customers;

CREATE TABLE areacodes
(areacode INT (10),
city VARCHAR (100),
state VARCHAR (100),
country VARCHAR (10),
longitude DECIMAL (10,2),
lat DECIMAL (10,2), PRIMARY KEY(city));

SET GLOBAL local_infile = ON;
LOAD DATA LOCAL INFILE '/Users/Terez/Desktop/Area-Code-Geolocation-Database-master/us-area-code-cities.csv'
INTO TABLE areacodes
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(areacode,city,state,country,longitude,lat);

INSERT INTO areacodes
VALUES (617, "Brickhaven", 'Massachusetts', 'US', 42.40, 71.38);

-- Write loop for phone numbers

DROP PROCEDURE IF EXISTS FixUSPhones; 

DELIMITER $$

CREATE PROCEDURE FixUSPhones ()
BEGIN
	DECLARE finished INTEGER DEFAULT 0;
	DECLARE phone varchar(50) DEFAULT "x";
    DECLARE areacodephone VARCHAR (50) DEFAULT "a";
	DECLARE customerNumber INT DEFAULT 0;
    	DECLARE country varchar(50) DEFAULT "";

	-- declare cursor for customer
	DECLARE curPhone
		CURSOR FOR 
            		SELECT customers.customerNumber, customers.phone, customers.country, areacodes.areacode
				FROM classicmodels.customers
                INNER JOIN areacodes
                USING (city);

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

	OPEN curPhone;
    
    	-- create a copy of the customer table 
	DROP TABLE IF EXISTS classicmodels.fixed_customers;
	CREATE TABLE classicmodels.fixed_customers LIKE classicmodels.customers;
	INSERT fixed_customers SELECT * FROM classicmodels.customers;
    ALTER TABLE classicmodels.fixed_customers ADD areacode INT;
    INSERT INTO classicmodels.fixed_customers (areacode) SELECT areacode FROM classicmodels.customers
                INNER JOIN classicmodels.areacodes
                USING (city);
    
    fixPhone: LOOP
		FETCH curPhone INTO customerNumber,phone, country, areacodephone;
		IF finished = 1 THEN 
			LEAVE fixPhone;
		END IF;
        
        -- insert into messages select concat('country is: ', country, ' and phone is: ', phone);
        
        IF country = 'USA'  THEN
			IF phone NOT LIKE '+%' THEN
				IF LENGTH(phone) = 7 THEN
					SET  phone = CONCAT('+1',areacodephone,phone);
					UPDATE classicmodels.fixed_customers 
						SET fixed_customers.phone=phone 
							WHERE fixed_customers.customerNumber = customerNumber;               		
				END IF;    
			END IF;
		END IF;
	
	END LOOP fixPhone;
	CLOSE curPhone;

END$$
DELIMITER ;

CALL FixUSPhones();

SELECT * FROM fixed_customers where country = 'USA' AND city = 'Brickhaven';
