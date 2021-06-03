-- ***********************
-- Student1 Name: Chiao-Ya Chang ID:130402191
-- Student2 Name: Mia Le ID: 131101198 
-- Student3 Name: Reza Poursafa ID: 140640194 
-- Date: Nov 2, 2020
-- Purpose: Assignment 1 - DBS311
-- ***********************
-- Question 1 – Display the employee number, full employee name, job title,
--              and hire date of all employees hired in September with the most recently hired employees displayed first. 
-- Q1 SOLUTION 
SELECT employee_id AS "Employee Number", last_name || ', ' || first_name AS "Full Name", job_title AS "Job Title", TO_CHAR(hire_date, '[Month ddth "of" yyyy]') AS "Start Date"
FROM employees
WHERE hire_date BETWEEN '01-SEP-16' AND '30-SEP-16'
ORDER BY hire_date DESC;


-- Question 2 – Display the salesman ID and the total sale amount for each employee.
--              Sort the result according to employee number.
-- Q2 SOLUTION
SELECT NVL(employee_id,0) AS "Employee Number", TO_CHAR(SUM(quantity * unit_price),'$99,999,999.99') AS "Total Sale"
FROM employees RIGHT JOIN orders o
ON employee_id = salesman_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY employee_id
ORDER BY "Employee Number";

-- Question 3 - Display customer Id, customer name and total number of orders for customers that the value of their customer ID is in values from 35 to 45.
-- Q3 SOLUTION
SELECT c.customer_id AS "Customer Id", name, COUNT(o.customer_id) AS "Total Orders"
FROM customers c FULL JOIN orders o
ON c.customer_id = o.customer_id
WHERE c.customer_id BETWEEN 35 AND 45
GROUP BY c.customer_id, name
ORDER BY "Total Orders";

-- Question 4 - Display customer ID, customer name, and the order ID and the order date of all orders for customer whose ID is 44.
--              a. Show also the total quantity and the total amount of each customer’s order.
--              b. Sort the result from the highest to lowest total order amount.

-- Q4 SOLUTION
SELECT o.customer_id AS "Customer Id",o.order_id AS "Order Id", order_date AS "Order Date", SUM(quantity)AS "Total Item", TO_CHAR(SUM(unit_price * quantity),'$99,999,999.00') AS "Total Amount"
FROM orders o JOIN order_items oi
ON o.order_id = oi.order_id
WHERE o.customer_id = 44
GROUP BY o.customer_id, o.order_id, o.order_date
ORDER BY "Total Amount" DESC;

-- Question 5 - Display customer Id, name, total number of orders, the total number of items ordered, 
--              and the total order amount for customers who have more than 30 orders. Sort the result based on the total number of orders.
-- Q5 SOLUTION
SELECT o.customer_id AS "Customer Id", c.name, COUNT(oi.order_id)AS "Total Number of Orders", SUM(oi.quantity)AS "Total Items", TO_CHAR(SUM(oi.unit_price * oi.quantity),'$9,999,999.99')AS "Total Amount"
FROM order_items oi JOIN orders o 
ON o.order_id = oi.order_id
JOIN customers c
ON c.customer_id = o.customer_id
GROUP BY o.customer_id, name
HAVING COUNT(o.order_id) > 30
ORDER BY "Total Number of Orders";

-- Question 6 - Display Warehouse Id, warehouse name, product category Id, product category name, and the lowest product standard cost for this combination.
-- Q6 SOLUTION

SELECT w.warehouse_id AS "Warehouse ID", w.warehouse_name AS "Warehouse Name", pc.category_id AS "Category Id",pc.category_name AS "Category Name", TO_CHAR(MIN(standard_cost),'$999.99') AS "Lowest Cost"
FROM warehouses w JOIN inventories i
ON w.warehouse_id = i.warehouse_id
JOIN products p
ON p.product_id = i.product_id
JOIN product_categories pc
ON p.category_id = pc.category_id
GROUP BY w.warehouse_id, w.warehouse_name, pc.category_id, pc.category_name
HAVING MIN(standard_cost) < 200 OR MIN(standard_cost) > 500
ORDER BY w.warehouse_id, w.warehouse_name, pc.category_id, pc.category_name;


-- Question 7 - Display the total number of orders per month. Sort the result from January to December.
-- Q7 SOLUTION

SELECT TO_CHAR(order_date,'Month') AS "Month", COUNT(order_id) AS "Number of Orders"
FROM orders
GROUP BY TO_CHAR(order_date,'Month')
ORDER BY MIN(EXTRACT(MONTH FROM order_date));

-- Question 8 - Display product Id, product name for products that their list price is more than any highest product standard cost per warehouse outside Americas regions.
-- Q8 SOLUTION
SELECT p.product_id "Product ID", p.product_name "Product Name", TO_CHAR(p.list_price , '$999,999.99') "Price"
FROM products p
WHERE list_price > ANY( SELECT MAX(standard_cost)
                        FROM products p
                        JOIN inventories i ON p.product_id = i.product_id
                        JOIN warehouses w ON i.warehouse_id = w.warehouse_id
                        JOIN locations l ON w.location_id = l.location_id
                        JOIN countries c ON l.country_id = c.country_id
                        JOIN regions r ON c.region_id = r.region_id
                    
                    WHERE region_name NOT LIKE 'Americas'
                    GROUP BY w.warehouse_id)
ORDER BY list_price DESC; 

-- Question 9 - Write a SQL statement to display the most expensive and the cheapest product (list price). Display product ID, product name, and the list price.
-- Q9 SOLUTION
SELECT product_id,product_name,TO_CHAR(list_price,'$9,999.99') AS "Price"
FROM products
WHERE list_price = ALL (SELECT MAX(list_price)
                        FROM products)
OR list_price = ALL (SELECT MIN(list_price)
                    FROM products);

-- Question 10 - Write a SQL query to display the number of customers with total order amount over the average amount of all orders, the number of customers with total order amount under the average amount of all orders, 
--               number of customers with no orders, and the total number of customers.
-- Q10 SOLUTION



SELECT 'Number of customers with total purchase amount over average: '|| COUNT(COUNT(c.customer_id)) "Customer Report"
FROM   Customers c
       JOIN Orders o ON o.Customer_id = c.Customer_id 
       JOIN Order_items oi ON o.Order_id = oi.Order_id 
GROUP  BY ( c.Customer_id ) 
HAVING SUM(Quantity * Unit_price) > (SELECT Avg(Quantity * Unit_price) 
                                     FROM   Order_items)
UNION ALL 

SELECT 'Number of customers with total purchase amount below average: '|| COUNT(COUNT(*)) 
FROM   Customers c
       JOIN Orders o ON o.Customer_id = c.Customer_id 
       JOIN Order_items oi ON o.Order_id = oi.Order_id 
GROUP  BY ( c.Customer_id ) 
HAVING SUM(Quantity * Unit_price) < (SELECT Avg(Quantity * Unit_price) 
                                     FROM   Order_items)
                                     
UNION ALL 

SELECT 'Number of customers with no orders: ' || COUNT(*)
FROM   Customers c
       FULL JOIN Orders o ON o.Customer_id = c.Customer_id 
WHERE o.order_id IS NULL

UNION ALL 

SELECT 'Total number of customers: ' || COUNT(*)
FROM customers;




