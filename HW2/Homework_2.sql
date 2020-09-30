-- HOMEWORK 2

-- Exercise 1: What state figures in the 145th line of our database? - Tennessee
SELECT state FROM birdstrikes LIMIT 144,1;

-- Exercise 2: What is flight_date of the latest birstrike in this database? - 2000/04/18
SELECT flight_date FROM birdstrikes ORDER BY flight_date DESC;
SELECT flight_date FROM birdstrikes AS b ORDER BY b.flight_date DESC;

-- Exercise 3: What was the cost of the 50th most expensive damage? -5'345
SELECT DISTINCT cost FROM birdstrikes ORDER BY cost DESC LIMIT 49,1;

-- Exercise 4: What state figures in the 2nd record, if you filter out all records which have no state and no bird_size specified? ('')
SELECT * FROM birdstrikes WHERE state IS NOT NULL and bird_size IS NOT NULL;

-- Exercise 5: How many days elapsed between the current date and the flights happening in week 52, for incidents from Colorado? (Hint: use NOW, DATEDIFF, WEEKOFYEAR)
