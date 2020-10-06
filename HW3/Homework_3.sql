-- Exercise 1 If speed is NULL or speed < 100 create a "LOW SPEED" category, otherwise, mark as "HIGH SPEED". Use IF instead of CASE!
SELECT aircraft, airline, speed, IF (speed is NULL OR speed<100, 'LOW SPEED', 'HIGH SPEED') AS speed_category FROM birdstrikes ORDER BY speed_category

-- Exercise2 - How many distinct 'aircraft' we have in the database? - 3
SELECT COUNT(DISTINCT(aircraft)) FROM birdstrikes;

-- Exercise3 - What was the lowest speed of aircrafts starting with 'H'
SELECT MIN(speed) as lowest_speed FROM birdstrikes WHERE aircraft LIKE 'H%';

-- Exercise4 - Which phase_of_flight has the least of incidents? - Taxi
SELECT phase_of_flight, Count(*) AS count FROM birdstrikes GROUP BY phase_of_flight;

-- Exercise5 - What is the rounded highest average cost by phase_of_flight? - 54'673
SELECT phase_of_flight, ROUND(AVG(cost)) AS avg FROM birdstrikes WHERE phase_of_flight !='' GROUP BY phase_of_flight ORDER BY avg DESC;

-- Exercise6 - What the highest AVG speed of the states with names less than 5 characters? - Iowa
SELECT state, AVG(speed) AS avg_speed,state FROM birdstrikes WHERE state !='' GROUP BY state HAVING LENGTH(state)<5;
SELECT state, AVG(speed) AS avg_speed,state FROM birdstrikes WHERE state !='' AND LENGTH(state)<5 GROUP BY state;