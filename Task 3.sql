-- Task 3: Online Store Order Management System
/*
Project Description: 
Create a system to manage orders, customers, and products for an online store.
The system will handle customer information, product inventory, and order processing.
*/

/* Database Creation:

CREATE DATABASE OnlineStore;
\c OnlineStore
*/

-- First drop tables in correct order (due to foreign key constraints)
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;

/* Creating Customers table */
CREATE TABLE Customers (
    CUSTOMER_ID SERIAL PRIMARY KEY,
    NAME VARCHAR(100) NOT NULL,
    EMAIL VARCHAR(100) UNIQUE NOT NULL,
    PHONE VARCHAR(15),
    ADDRESS TEXT
);

/* Creating Products table */
CREATE TABLE Products (
    PRODUCT_ID SERIAL PRIMARY KEY,
    PRODUCT_NAME VARCHAR(100) NOT NULL,
    CATEGORY VARCHAR(50) NOT NULL,
    PRICE NUMERIC(10,2) CHECK (PRICE > 0),
    STOCK INTEGER CHECK (STOCK >= 0)
);

/* Creating Orders table with foreign key constraints */
CREATE TABLE Orders (
    ORDER_ID SERIAL PRIMARY KEY,
    CUSTOMER_ID INTEGER REFERENCES Customers(CUSTOMER_ID),
    PRODUCT_ID INTEGER REFERENCES Products(PRODUCT_ID),
    QUANTITY INTEGER CHECK (QUANTITY > 0),
    ORDER_DATE DATE DEFAULT CURRENT_DATE
);

-- Data Creation:

/* Insert Customers */
INSERT INTO Customers (NAME, EMAIL, PHONE, ADDRESS) VALUES
('John Doe', 'john@email.com', '555-0101', '123 Main St'),
('Jane Smith', 'jane@email.com', '555-0102', '456 Oak Ave'),
('Bob Wilson', 'bob@email.com', '555-0103', '789 Pine Rd'),
('Alice Brown', 'alice@email.com', '555-0104', '321 Elm St'),
('Charlie Davis', 'charlie@email.com', '555-0105', '654 Maple Dr');

/* Insert Products with some out-of-stock items */
INSERT INTO Products (PRODUCT_NAME, CATEGORY, PRICE, STOCK) VALUES
('Laptop', 'Electronics', 999.99, 50),
('Smartphone', 'Electronics', 699.99, 0),    -- Out of stock
('Running Shoes', 'Sports', 89.99, 200),
('Coffee Maker', 'Appliances', 79.99, 0),    -- Out of stock
('Backpack', 'Fashion', 49.99, 150),
('Headphones', 'Electronics', 199.99, 75),
('Tennis Racket', 'Sports', 159.99, 45);

/* Insert Orders with diverse categories */
INSERT INTO Orders (CUSTOMER_ID, PRODUCT_ID, QUANTITY, ORDER_DATE) VALUES
(1, 1, 1, '2025-11-01'),    -- John Doe - Laptop (Electronics)
(1, 5, 1, '2025-11-25'),    -- John Doe - Backpack (Fashion)
(1, 2, 1, '2025-09-05'),    -- John Doe - Smartphone (Electronics)

(2, 2, 1, '2025-11-15'),    -- Jane Smith - Smartphone (Electronics)
(2, 6, 1, '2025-10-15'),    -- Jane Smith - Headphones (Electronics)
(2, 3, 2, '2025-08-20'),    -- Jane Smith - Running Shoes (Sports)

(3, 3, 2, '2025-10-01'),    -- Bob Wilson - Running Shoes (Sports)
(3, 7, 1, '2025-11-10'),    -- Bob Wilson - Tennis Racket (Sports)

(4, 4, 1, '2025-11-20'),    -- Alice Brown - Coffee Maker (Appliances)
(4, 1, 1, '2025-07-15');    -- Alice Brown - Laptop (Electronics)

-- Order Management Queries:

/* Question a: Retrieve all orders placed by a specific customer */
SELECT c.NAME, p.PRODUCT_NAME, o.QUANTITY, o.ORDER_DATE
FROM Orders o
JOIN Customers c ON o.CUSTOMER_ID = c.CUSTOMER_ID
JOIN Products p ON o.PRODUCT_ID = p.PRODUCT_ID
WHERE c.CUSTOMER_ID = 1;

/* Question b: Find products that are out of stock */
SELECT PRODUCT_NAME, CATEGORY, STOCK
FROM Products
WHERE STOCK = 0;

/* Question c: Calculate the total revenue generated per product */
SELECT 
    p.PRODUCT_NAME,
    SUM(o.QUANTITY * p.PRICE) as total_revenue
FROM Products p
LEFT JOIN Orders o ON p.PRODUCT_ID = o.PRODUCT_ID
GROUP BY p.PRODUCT_NAME
ORDER BY total_revenue DESC;

/* Question d: Retrieve the top 5 customers by total purchase amount */
SELECT 
    c.NAME,
    ROUND(SUM(o.QUANTITY * p.PRICE), 2) as total_spent
FROM Customers c
JOIN Orders o ON c.CUSTOMER_ID = o.CUSTOMER_ID
JOIN Products p ON o.PRODUCT_ID = p.PRODUCT_ID
GROUP BY c.NAME
ORDER BY total_spent DESC
LIMIT 5;

/* Question e: Find customers who placed orders in at least two different product categories */
SELECT 
    c.NAME,
    COUNT(DISTINCT p.CATEGORY) as different_categories
FROM Customers c
JOIN Orders o ON c.CUSTOMER_ID = o.CUSTOMER_ID
JOIN Products p ON o.PRODUCT_ID = p.PRODUCT_ID
GROUP BY c.NAME
HAVING COUNT(DISTINCT p.CATEGORY) >= 2;

-- Analytics Queries:

/* Question a: Find the month with the highest total sales */
SELECT 
    TO_CHAR(DATE_TRUNC('month', o.ORDER_DATE), 'YYYY-MM') as month,
    ROUND(SUM(o.QUANTITY * p.PRICE), 2) as total_sales
FROM Orders o
JOIN Products p ON o.PRODUCT_ID = p.PRODUCT_ID
GROUP BY DATE_TRUNC('month', o.ORDER_DATE)
ORDER BY total_sales DESC
LIMIT 1;

/* Question b: Identify products with no orders in the last 6 months */
SELECT PRODUCT_NAME
FROM Products p
WHERE NOT EXISTS (
    SELECT 1 FROM Orders o
    WHERE o.PRODUCT_ID = p.PRODUCT_ID
    AND o.ORDER_DATE > CURRENT_DATE - INTERVAL '6 months'
); -- all products have been ordered

/* Question c: Retrieve customers who have never placed an order */
SELECT NAME, EMAIL
FROM Customers c
WHERE NOT EXISTS (
    SELECT 1 FROM Orders o
    WHERE o.CUSTOMER_ID = c.CUSTOMER_ID
);

/* Question d: Calculate the average order value across all orders */
SELECT ROUND(AVG(order_value), 2) as average_order_value
FROM (
    SELECT o.ORDER_ID, SUM(o.QUANTITY * p.PRICE) as order_value
    FROM Orders o
    JOIN Products p ON o.PRODUCT_ID = p.PRODUCT_ID
    GROUP BY o.ORDER_ID
) subquery;