drop database pizza_runner;
-- Let's get Started.....

DROP DATABASE IF EXISTS pizza_runner;

CREATE database pizza_runner;

USE pizza_runner;

DROP TABLE IF EXISTS runners;

CREATE TABLE runners (
  runner_id INTEGER PRIMARY KEY,
  registration_date DATE
);

INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

select * from runners;

DROP TABLE IF EXISTS customer_orders;

CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(10),
  extras VARCHAR(10),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

select * from customer_orders;

DROP TABLE IF EXISTS runner_orders;

CREATE TABLE runner_orders (
  order_id INTEGER PRIMARY KEY,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

select * from runner_orders;

DROP TABLE IF EXISTS pizza_names;

CREATE TABLE pizza_names (
  pizza_id INTEGER PRIMARY KEY,
  pizza_name TEXT
);

INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  ('1', 'Meatlovers'),
  ('2', 'Vegetarian');
  
select * from pizza_names;


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER PRIMARY KEY,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  ('1', '1, 2, 3, 4, 5, 6, 8, 10'),
  ('2', '4, 6, 7, 9, 11, 12');

select * from pizza_recipes;

DROP TABLE IF EXISTS pizza_toppings;

CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);

INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
select * from pizza_toppings;
  
 -- Let's create relationship between tables.
 
ALTER TABLE runner_orders                                
ADD FOREIGN KEY (runner_id) REFERENCES runners(runner_id);   
	
ALTER TABLE customer_orders
ADD FOREIGN KEY (order_id) REFERENCES runner_orders(order_id);

ALTER TABLE customer_orders
ADD FOREIGN KEY (pizza_id) REFERENCES pizza_names(pizza_id);

ALTER TABLE customer_orders
ADD FOREIGN KEY (pizza_id) REFERENCES pizza_recipes(pizza_id);
  
-- Since there is some mismatch in some data and hence let's do data cleaning 
-- firstly will clear customer_orders table

DROP TABLE IF EXISTS customer_orders_temp;

CREATE TEMPORARY TABLE customer_orders_temp AS
SELECT order_id,
       customer_id,
       pizza_id,
       CASE
           WHEN exclusions = '' THEN NULL
           WHEN exclusions = 'null' THEN NULL
           ELSE exclusions
       END AS exclusions,
       CASE
           WHEN extras = '' THEN NULL
           WHEN extras = 'null' THEN NULL
           ELSE extras
       END AS extras,
       CAST(order_time AS DATETIME)  AS order_time
FROM customer_orders;

-- now let's do data cleaning in runner_orders table

DROP TABLE IF EXISTS runner_orders_temp;

CREATE TEMPORARY TABLE runner_orders_temp AS
	SELECT order_id,
		   runner_id,
		   CASE
			   WHEN pickup_time LIKE 'null' OR pickup_time IS NULL THEN NULL
			   ELSE CAST(STR_TO_DATE(pickup_time, '%Y-%m-%d %H:%i:%s') AS DATETIME )
		   END AS pickup_time,
		   CASE
			   WHEN distance LIKE 'null' THEN NULL	
			   ELSE CAST(regexp_replace(distance, '[a-z]+', '') AS FLOAT)
		   END AS distance,
		   CASE
			   WHEN duration LIKE 'null' THEN NULL
			   ELSE CAST(regexp_replace(duration, '[a-z]+', '') AS FLOAT)
		   END AS duration,
		   CASE
			   WHEN cancellation LIKE '' THEN NULL
			   WHEN cancellation LIKE 'null' THEN NULL
			   ELSE cancellation
		   END AS cancellation
	FROM runner_orders;


-- now our data is ready for analysis..
#1.How many pizzas were ordered?
SELECT COUNT(*) AS total_pizzas_ordered 
FROM customer_orders;
#2.How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS unique_customer_orders 
FROM customer_orders;
#3.How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS successful_orders 
FROM runner_orders 
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;
#4.How many of each type of pizza was delivered?
SELECT p.pizza_name, COUNT(co.pizza_id) AS total_delivered 
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
JOIN pizza_names p ON co.pizza_id = p.pizza_id
WHERE ro.pickup_time IS NOT NULL
GROUP BY p.pizza_name;
#5.How many Vegetarian and Meatlovers were ordered by each customer?
SELECT co.customer_id, 
       SUM(CASE WHEN p.pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS vegetarian_orders,
       SUM(CASE WHEN p.pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS meatlovers_orders
FROM customer_orders co
JOIN pizza_names p ON co.pizza_id = p.pizza_id
GROUP BY co.customer_id;
#6.What was the maximum number of pizzas delivered in a single order?
SELECT co.order_id, COUNT(co.pizza_id) AS max_pizzas
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL  -- Ensures only delivered orders are counted
GROUP BY co.order_id
ORDER BY max_pizzas DESC
LIMIT 1;
#7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT co.customer_id, 
       SUM(CASE WHEN (co.exclusions IS NOT NULL OR co.extras IS NOT NULL) THEN 1 ELSE 0 END) AS changed_pizzas,
       SUM(CASE WHEN (co.exclusions IS NULL AND co.extras IS NULL) THEN 1 ELSE 0 END) AS unchanged_pizzas
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
GROUP BY co.customer_id;
#8. How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(*) AS pizzas_with_both_changes
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL 
AND co.exclusions IS NOT NULL 
AND co.extras IS NOT NULL;
#9. What was the total volume of pizzas ordered for each hour of the day?
SELECT HOUR(order_time) AS order_hour, COUNT(*) AS total_pizzas_ordered
FROM customer_orders
GROUP BY HOUR(order_time)
ORDER BY order_hour;
#10.What was the volume of orders for each day of the week?
SELECT DAYNAME(order_time) AS order_day, 
       COUNT(DISTINCT order_id) AS total_orders
FROM customer_orders
GROUP BY order_day
ORDER BY FIELD(order_day, 
'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');
 ##  Runner and Customer Experience
 
#1.How many runners signed up for each 1-week period (starting 2021-01-01)?
SELECT YEARWEEK(registration_date, 1) AS week_number, 
       COUNT(runner_id) AS total_runners
FROM runners
GROUP BY week_number
ORDER BY week_number;
#2.What was the average time (in minutes) it took for each runner to arrive at Pizza Runner 
# HQ to pick up the order?
SELECT runner_id, 
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)), 2) AS avg_arrival_time_minutes
FROM runner_orders ro
JOIN customer_orders co ON ro.order_id = co.order_id
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;
#3.Is there a relationship between the number of pizzas and how long the order takes to prepare?
SELECT co.order_id, 
       COUNT(co.pizza_id) AS num_pizzas, 
       TIMESTAMPDIFF(MINUTE, MIN(co.order_time), ro.pickup_time) AS prep_time_minutes
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
GROUP BY co.order_id, ro.pickup_time
ORDER BY num_pizzas;
#4. What was the average distance traveled for each customer?
SELECT co.customer_id, 
       ROUND(AVG(ro.distance), 2) AS avg_distance_km
FROM runner_orders ro
JOIN customer_orders co ON ro.order_id = co.order_id
WHERE ro.distance IS NOT NULL
GROUP BY co.customer_id;
#5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration) - MIN(duration) AS delivery_time_difference
FROM runner_orders
WHERE duration IS NOT NULL;
#6. What was the average speed for each runner for each delivery and do you notice any trend?
SELECT runner_id, order_id, 
       ROUND(AVG(distance / (duration / 60)), 2) AS avg_speed_kmh
FROM runner_orders
WHERE distance IS NOT NULL AND duration IS NOT NULL
GROUP BY runner_id, order_id
ORDER BY runner_id, order_id;
#7.What is the successful delivery percentage for each runner?
SELECT runner_id, 
       ROUND(100 * SUM(CASE WHEN pickup_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(order_id), 2) AS success_rate
FROM runner_orders
GROUP BY runner_id;


##----C. Ingredient Optimisation

#1. What are the standard ingredients for each pizza?
SELECT pn.pizza_name, 
       GROUP_CONCAT(DISTINCT pt.topping_name ORDER BY pt.topping_name SEPARATOR ', ') AS ingredients
FROM pizza_names pn
JOIN pizza_recipes pr ON pn.pizza_id = pr.pizza_id
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, pr.toppings) > 0
GROUP BY pn.pizza_name
ORDER BY pn.pizza_name;

#2.What was the most commonly added extra?
SELECT pt.topping_name, COUNT(*) AS count
FROM customer_orders co
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, co.extras) > 0
GROUP BY pt.topping_name
ORDER BY count DESC
LIMIT 1;
#3.What was the most common exclusion?
SELECT pt.topping_name, COUNT(*) AS count
FROM customer_orders co
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, co.exclusions) > 0
GROUP BY pt.topping_name
ORDER BY count DESC
LIMIT 1;

#4.Generate an order item for each record in the customers_orders table in the format of one of the following:
# Meat Lovers
# Meat Lovers - Exclude Beef
# Meat Lovers - Extra Bacon
# Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers.
SELECT co.order_id,
       pn.pizza_name,
       CONCAT(
           pn.pizza_name, 
           IF(co.exclusions IS NOT NULL AND co.exclusions != '', CONCAT(' - Exclude ', GROUP_CONCAT(DISTINCT pt1.topping_name ORDER BY pt1.topping_name SEPARATOR ', ')), ''),
           IF(co.extras IS NOT NULL AND co.extras != '', CONCAT(' - Extra ', GROUP_CONCAT(DISTINCT pt2.topping_name ORDER BY pt2.topping_name SEPARATOR ', ')), '')
       ) AS formatted_order
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
LEFT JOIN pizza_toppings pt1 ON FIND_IN_SET(pt1.topping_id, co.exclusions) > 0
LEFT JOIN pizza_toppings pt2 ON FIND_IN_SET(pt2.topping_id, co.extras) > 0
GROUP BY co.order_id, pn.pizza_name;

#5.Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
# For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
SELECT co.order_id,
       pn.pizza_name,
       GROUP_CONCAT(
           CASE 
               WHEN FIND_IN_SET(pt.topping_id, co.extras) > 0 THEN CONCAT('2x', pt.topping_name)
               ELSE pt.topping_name
           END
           ORDER BY pt.topping_name SEPARATOR ', '
       ) AS ingredient_list
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
JOIN pizza_recipes pr ON co.pizza_id = pr.pizza_id
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, pr.toppings) > 0
LEFT JOIN pizza_toppings pt_extra ON FIND_IN_SET(pt_extra.topping_id, co.extras) > 0
LEFT JOIN pizza_toppings pt_excl ON FIND_IN_SET(pt_excl.topping_id, co.exclusions) > 0
WHERE co.order_id IS NOT NULL
GROUP BY co.order_id, pn.pizza_name;

#6.What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
SELECT pt.topping_name, COUNT(*) AS total_quantity
FROM runner_orders ro
JOIN customer_orders co ON ro.order_id = co.order_id
JOIN pizza_recipes pr ON co.pizza_id = pr.pizza_id
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, pr.toppings) > 0
WHERE ro.cancellation IS NULL
GROUP BY pt.topping_name
ORDER BY total_quantity DESC;

##----D. Pricing and Ratings
#1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for
# changes - how much money has Pizza Runner made so far if there are no delivery fees?
SELECT SUM(
    CASE 
        WHEN pn.pizza_name = 'Meatlovers' THEN 12
        WHEN pn.pizza_name = 'Vegetarian' THEN 10
    END
) AS total_revenue
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id;

#2.What if there was an additional $1 charge for any pizza extras?
SELECT SUM(
    CASE 
        WHEN pn.pizza_name = 'Meatlovers' THEN 12
        WHEN pn.pizza_name = 'Vegetarian' THEN 10
    END 
    + (LENGTH(COALESCE(co.extras, '')) - LENGTH(REPLACE(COALESCE(co.extras, ''), ',', '')) + 1) * 1
) AS total_revenue_with_extras
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
WHERE co.extras IS NOT NULL AND co.extras != '';

#3.The Pizza Runner team now wants to add an additional ratings system that allows customers 
#to rate their runner, how would you design an additional table for this new dataset - 
#generate a schema for this new table and insert your own data for ratings for each successful customer 
#order between 1 to 5.?
CREATE TABLE runner_ratings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    runner_id INT,
    customer_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    FOREIGN KEY (order_id) REFERENCES runner_orders(order_id),
    FOREIGN KEY (runner_id) REFERENCES runners(runner_id)
);

#4.Using your newly generated table - can you join all of the information together to form 
# a table which has the following information for successful deliveries?
#.customer_id
#.order_id
#.runner_id
#.rating
#.order_time
#.pickup_time
#.Time between order and pickup
#.Delivery duration
#.Average speed
#.Total number of pizzas
INSERT INTO runner_ratings (order_id, runner_id, customer_id, rating)
SELECT ro.order_id, ro.runner_id, co.customer_id, 
       FLOOR(1 + (RAND() * 5))  -- Random ratings between 1 and 5
FROM runner_orders ro
JOIN customer_orders co ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL;

#5.If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
SELECT 
    co.customer_id,
    co.order_id,
    ro.runner_id,
    rr.rating,
    co.order_time,
    ro.pickup_time,
    TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time) AS time_between_order_and_pickup,
    ro.duration AS delivery_duration,
    (ro.distance / (ro.duration / 60)) AS average_speed,
    COUNT(co.pizza_id) AS total_pizzas
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
JOIN runner_ratings rr ON ro.order_id = rr.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id, co.order_id, ro.runner_id, rr.rating, co.order_time,
 ro.pickup_time, ro.duration, ro.distance;
 
 #--------------------------------------------------------------------------------------------














select * from customer_orders;

