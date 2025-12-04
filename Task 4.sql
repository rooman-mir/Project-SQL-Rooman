-- Task 4: Movie Rental Analysis System
/*
Project Description: 
Perform advanced analysis on movie rental data using OLAP operations.
The system will track movie rentals, customer behavior, and generate analytical reports.
*/

/* Database Creation:

CREATE DATABASE MovieRental;
\c MovieRental
*/

/* Creating rental_data table with composite primary key */
CREATE TABLE rental_data (
    MOVIE_ID INTEGER,
    CUSTOMER_ID INTEGER,
    GENRE VARCHAR(50),
    RENTAL_DATE DATE,
    RETURN_DATE DATE,
    RENTAL_FEE NUMERIC(6,2),
    PRIMARY KEY (MOVIE_ID, CUSTOMER_ID, RENTAL_DATE)
);

/* Insert sample rental records to support all OLAP operations:
   - Multiple genres for drill-down analysis
   - Multiple rentals across months for temporal analysis
   - Variety of rental fees for aggregation
   - Sufficient Action and Drama movies for slice/dice operations
*/
INSERT INTO rental_data VALUES
-- Action movies
(1, 101, 'Action', '2025-11-01', '2025-11-04', 4.99),
(2, 102, 'Action', '2025-11-02', '2025-11-05', 4.99),
(3, 103, 'Action', '2025-11-03', '2025-11-06', 4.99),
(4, 101, 'Action', '2025-10-15', '2025-10-18', 4.99),

-- Drama movies
(5, 102, 'Drama', '2025-11-05', '2025-11-08', 3.99),
(6, 103, 'Drama', '2025-11-06', '2025-11-09', 3.99),
(7, 104, 'Drama', '2025-10-20', '2025-10-23', 3.99),
(8, 101, 'Drama', '2025-10-25', '2025-10-28', 3.99),

-- Comedy movies
(9, 102, 'Comedy', '2025-11-08', '2025-11-11', 3.99),
(10, 103, 'Comedy', '2025-11-09', '2025-11-12', 3.99),
(11, 104, 'Comedy', '2025-10-10', '2025-10-13', 3.99),
(12, 101, 'Comedy', '2025-10-12', '2025-10-15', 3.99);

-- OLAP Operations Queries:

/* Question a: Drill Down - Analyze rentals from genre to individual movie level */
SELECT 
    GENRE,
    MOVIE_ID,
    COUNT(*) as rental_count,
    SUM(RENTAL_FEE) as total_revenue
FROM rental_data
GROUP BY ROLLUP(GENRE, MOVIE_ID)
ORDER BY GENRE, MOVIE_ID;

/* Question b: Rollup - Summarize total rental fees by genre and then overall */
SELECT 
    GENRE,
    SUM(RENTAL_FEE) as total_fees,
    COUNT(*) as rental_count
FROM rental_data
GROUP BY ROLLUP(GENRE)
ORDER BY GENRE;

/* Question c: Cube - Analyze total rental fees across combinations of genre, rental date, and customer */
SELECT 
    GENRE,
    DATE_TRUNC('month', RENTAL_DATE) as rental_month,
    CUSTOMER_ID,
    SUM(RENTAL_FEE) as total_fees
FROM rental_data
GROUP BY CUBE(GENRE, DATE_TRUNC('month', RENTAL_DATE), CUSTOMER_ID)
ORDER BY GENRE, rental_month, CUSTOMER_ID;

/* Question d: Slice - Extract rentals only from the 'Action' genre */
SELECT *
FROM rental_data
WHERE GENRE = 'Action';

/* Question e: Dice - Extract rentals where GENRE = 'Action' or 'Drama' 
   and RENTAL_DATE is in the last 3 months */
SELECT *
FROM rental_data
WHERE GENRE IN ('Action', 'Drama')
AND RENTAL_DATE >= CURRENT_DATE - INTERVAL '3 months'
ORDER BY RENTAL_DATE;
