CREATE DATABASE PIZZA_STORE;
USE PIZZA_STORE;
SELECT * FROM orders LIMIT 10000000;
CREATE TABLE order_details(
order_details_id INT NOT NULL,
order_id INT NOT NULL,
pizza_id TEXT NOT NULL,
quantity INT NOT NULL,
PRIMARY KEY(order_details_id)
);


-- 1. TOTAL NUMBER OF ORDERS PLACED
SELECT COUNT(*) AS TOTAL_ORDERS FROM orders;

-- 2. TOTAL REVENUE GENERATED
SELECT ROUND(SUM(od.quantity * p.price),2) AS TOTAL_REVENUE
FROM order_details od JOIN pizzas p
ON od.pizza_id = p.pizza_id;

-- 3. HIGHEST PRICED PIZZA
SELECT pt.name AS PIZZA_NAME, p.price AS PRICE
FROM pizzas p JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC LIMIT 1;

-- 4. MOST COMMONLY ORDERED PIZZA SIZE
SELECT p.size, SUM(od.quantity) AS QUANTITY
FROM order_details od JOIN pizzas p
ON p.pizza_id = od.pizza_id
GROUP BY p.size ORDER BY quantity DESC LIMIT 1;

-- 5. TOP 5 MOST ORDERED PIZZA TYPE
SELECT pt.name, SUM(od.quantity) AS QUANTITY
FROM pizza_types pt JOIN pizzas p
ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY QUANTITY DESC LIMIT 5;

-- 6. QUANTITY OF EACH PIZZA CATEGORY ORDERED
SELECT pt.category, SUM(od.quantity) AS QUANTITY
FROM pizza_types pt JOIN pizzas p
ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
ON od.pizza_id = p.pizza_id
GROUP BY pt.category ORDER BY QUANTITY DESC;

-- 7. DISTRIBUTON OF ORDERS BY HOUR OF THE DAY
SELECT HOUR(o.`time`) AS "TIME", SUM(od.quantity) AS QUANTITY
FROM orders o JOIN order_details od
ON o.order_id = od.order_id
GROUP BY HOUR(o.`time`)
ORDER BY QUANTITY DESC; 

-- 8. CATEGORY WISE PIZZA DISTRIBUTION
SELECT pt.category, COUNT(pt.name) AS QUANTITY
FROM pizza_types pt
GROUP BY pt.category;

-- 9. GROUP ORDERS BY DATE AND CALCULATE AVERAGE NUMBER OF PIZZAS ORDERED EACH DAY
SELECT ROUND(AVG(QUANTITY)) AS AVG_DAILY_ORDERS FROM (SELECT o.date, SUM(od.quantity) AS QUANTITY
FROM orders o JOIN order_details od
ON o.order_id = od.order_id
GROUP BY date) AS ORDERS;

-- 10. TOP 3 MOST ORDERED PIZZA BASED ON REVENUE
SELECT pt.name, SUM(p.price*od.quantity) AS PRICE
FROM order_details od JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY name
ORDER BY PRICE DESC LIMIT 3;

-- 11. CONTRIBUTION OF EACH PIZZA TYPE TO TOTAL REVENUE
SELECT pt.category, ROUND((SUM(p.price * od.quantity) / (SELECT SUM(od.quantity * p.price) AS TOTAL_SALES
FROM order_details od JOIN pizzas p
ON od.pizza_id = p.pizza_id) * 100),2) AS PERCENTAGE_CONTRIBUTION
FROM pizza_types pt JOIN pizzas p 
ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details od
ON od.pizza_id = p.pizza_id
GROUP BY category;

-- 12. CUMULATIVE REVENUE OVER TIME
SELECT date, SUM(REVENUE) OVER (ORDER BY date)
FROM
(SELECT o.date, ROUND(SUM(od.quantity * p.price), 2) AS REVENUE
FROM orders o JOIN order_details od
ON od.order_id = o.order_id
JOIN pizzas p 
ON p.pizza_id = od.pizza_id
GROUP BY date) AS REVENUE;

-- 13. TOP 3 MOST ORDERED PIZZA TYPE BASED ON REVENUE FOR EACH PIZZA CATEGORY
SELECT category, name, REVENUE FROM
(SELECT category, name, REVENUE, RANK() OVER (PARTITION BY category ORDER BY REVENUE) AS RNK
FROM
(SELECT pt.category, pt.name, SUM(od.quantity * p.price) AS REVENUE
FROM order_details od JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY category, name) AS A) AS B
WHERE RNK <= 3;

