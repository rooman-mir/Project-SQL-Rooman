-- Task 2: Employee Payroll Management System
/*
Project Description: 
Design and implement an employee payroll system to store, manage, and analyze
salary data. The system will handle employee details, salaries, bonuses, and tax calculations.
*/

/* Database Setup:

CREATE DATABASE payroll_database;
\c payroll_database
*/

-- Table Creation
CREATE TABLE employees (
    EMPLOYEE_ID SERIAL PRIMARY KEY,
    NAME TEXT NOT NULL,
    DEPARTMENT TEXT NOT NULL,
    EMAIL TEXT UNIQUE NOT NULL,
    PHONE_NO VARCHAR(15),
    JOINING_DATE DATE DEFAULT CURRENT_DATE,
    SALARY NUMERIC(10,2) CHECK (SALARY >= 0),
    BONUS NUMERIC(10,2) DEFAULT 0,
    TAX_PERCENTAGE NUMERIC(5,2) CHECK (TAX_PERCENTAGE BETWEEN 0 AND 100)
);

-- Data Entry:

INSERT INTO employees (NAME, DEPARTMENT, EMAIL, PHONE_NO, JOINING_DATE, SALARY, BONUS, TAX_PERCENTAGE) VALUES
('John Smith', 'Sales', 'john.smith@company.com', '555-0101', '2025-01-15', 95000, 8000, 25),
('Mary Johnson', 'IT', 'mary.j@company.com', '555-0102', '2024-08-20', 98000, 12000, 28),
('Robert Brown', 'Sales', 'robert.b@company.com', '555-0103', '2024-06-10', 70000, 4500, 22),
('Sarah Wilson', 'HR', 'sarah.w@company.com', '555-0104', '2025-07-01', 65000, 3000, 20),
('Michael Lee', 'IT', 'michael.l@company.com', '555-0105', '2024-12-01', 105000, 15000, 30),
('Lisa Anderson', 'Sales', 'lisa.a@company.com', '555-0106', '2025-02-15', 72000, 4800, 24),
('James Taylor', 'HR', 'james.t@company.com', '555-0107', '2024-09-01', 68000, 3500, 21),
('Emily Davis', 'IT', 'emily.d@company.com', '555-0108', '2025-03-01', 96000, 14000, 29),
('David Miller', 'Sales', 'david.m@company.com', '555-0109', '2024-11-15', 76000, 5200, 26),
('Patricia White', 'HR', 'patricia.w@company.com', '555-0110', '2025-05-01', 67000, 3200, 20);

-- Payroll Queries:

/* Question a: List of employees sorted by salary in descending order */
SELECT NAME, DEPARTMENT, SALARY
FROM employees
ORDER BY SALARY DESC;

/* Question b: Employees with total compensation > $100,000 */ 
-- Update sample data to mee the requirement output as per the question.
UPDATE employees 
SET SALARY = 95000, BONUS = 8000 
WHERE NAME = 'Michael Lee';

UPDATE employees 
SET SALARY = 94000, BONUS = 7500 
WHERE NAME = 'Emily Davis';

SELECT NAME, DEPARTMENT, (SALARY + BONUS) as total_compensation
FROM employees
WHERE (SALARY + BONUS) > 100000;

/* Question c: Update bonus for Sales department (10% increase) */
UPDATE employees
SET BONUS = BONUS * 1.10
WHERE DEPARTMENT = 'Sales'
RETURNING NAME, DEPARTMENT, BONUS;

/* Question d: Calculate the net salary after deducting tax for all employees */
SELECT 
    NAME,
    DEPARTMENT,
    SALARY,
    BONUS,
    (SALARY + BONUS) * (1 - TAX_PERCENTAGE/100) as net_salary
FROM employees;

/* Question e: Retrieve the average, minimum, and maximum salary per department */
SELECT 
    DEPARTMENT,
    ROUND(AVG(SALARY), 2) as avg_salary,
    MIN(SALARY) as min_salary,
    MAX(SALARY) as max_salary
FROM employees
GROUP BY DEPARTMENT;

-- Advanced Queries:

/* Question a: Retrieve employees who joined in the last 6 months (from 2025-12-04) */
SELECT NAME, DEPARTMENT, JOINING_DATE
FROM employees
WHERE JOINING_DATE >= CURRENT_DATE - INTERVAL '6 months';

/* Question b: Group employees by department and count how many employees each has */
SELECT DEPARTMENT, COUNT(*) as employee_count
FROM employees
GROUP BY DEPARTMENT;

/* Question c: Find the department with the highest average salary */
SELECT 
    DEPARTMENT,
    ROUND(AVG(SALARY), 2) as avg_salary
FROM employees
GROUP BY DEPARTMENT
ORDER BY avg_salary DESC
LIMIT 1;

/* Question d: Identify employees who have the same salary as at least one other employee */
SELECT e1.NAME, e1.SALARY
FROM employees e1
JOIN employees e2 ON e1.SALARY = e2.SALARY AND e1.EMPLOYEE_ID != e2.EMPLOYEE_ID
ORDER BY e1.SALARY;