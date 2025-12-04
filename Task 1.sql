-- Task 1: Library Management System
/*
Project Description: 
Design and develop a Library Management System using SQL. The system manages book
inventories, member details, and borrowing transactions using three tables:
Books, Members, and BorrowingRecords.
*/

/* Database Setup:

CREATE DATABASE library_management;
\c library_management
*/

CREATE TABLE Books (
    BOOK_ID SERIAL PRIMARY KEY,
    TITLE VARCHAR(100) NOT NULL,
    AUTHOR VARCHAR(100) NOT NULL,
    GENRE VARCHAR(50),
    YEAR_PUBLISHED INTEGER CHECK (YEAR_PUBLISHED > 0),
    AVAILABLE_COPIES INTEGER CHECK (AVAILABLE_COPIES >= 0)
);

CREATE TABLE Members (
    MEMBER_ID SERIAL PRIMARY KEY,
    NAME VARCHAR(100) NOT NULL,
    EMAIL VARCHAR(100) UNIQUE NOT NULL,
    PHONE_NO VARCHAR(15),
    ADDRESS TEXT,
    MEMBERSHIP_DATE DATE DEFAULT CURRENT_DATE
);

CREATE TABLE BorrowingRecords (
    BORROW_ID SERIAL PRIMARY KEY,
    MEMBER_ID INTEGER REFERENCES Members(MEMBER_ID),
    BOOK_ID INTEGER REFERENCES Books(BOOK_ID),
    BORROW_DATE DATE DEFAULT CURRENT_DATE,
    RETURN_DATE DATE,
    CONSTRAINT valid_dates CHECK (RETURN_DATE >= BORROW_DATE)
);

-- Data Creation:

-- Insert Books with careful genre distribution
INSERT INTO Books (TITLE, AUTHOR, GENRE, YEAR_PUBLISHED, AVAILABLE_COPIES) VALUES
('To Kill a Mockingbird', 'Harper Lee', 'Fiction', 1960, 3),
('1984', 'George Orwell', 'Science Fiction', 1949, 4),
('Pride and Prejudice', 'Jane Austen', 'Romance', 1813, 2),
('The Hobbit', 'J.R.R. Tolkien', 'Fantasy', 1937, 6),
('The Great Gatsby', 'F. Scott Fitzgerald', 'Classic', 1925, 5),
('Dune', 'Frank Herbert', 'Science Fiction', 1965, 3),
('The Catcher in the Rye', 'J.D. Salinger', 'Fiction', 1951, 4);

-- Insert Members
INSERT INTO Members (NAME, EMAIL, PHONE_NO, ADDRESS) VALUES
('John Doe', 'john.doe@email.com', '555-0101', '123 Main St'),
('Jane Smith', 'jane.smith@email.com', '555-0102', '456 Oak Ave'),
('Bob Wilson', 'bob.wilson@email.com', '555-0103', '789 Pine Rd'),
('Alice Brown', 'alice.brown@email.com', '555-0104', '321 Elm St'),
('Charlie Davis', 'charlie.davis@email.com', '555-0105', '654 Maple Dr');

-- Insert BorrowingRecords
-- Planning borrowing patterns to satisfy all query requirements:
-- 1. Some overdue books
-- 2. Multiple borrows for same book
-- 3. Different genres for same member
-- 4. Some returned and some unreturned books
INSERT INTO BorrowingRecords (MEMBER_ID, BOOK_ID, BORROW_DATE, RETURN_DATE) VALUES
-- Recent borrows (not overdue)
(1, 1, '2025-11-25', NULL),                    -- To Kill a Mockingbird
(3, 2, '2025-11-20', NULL),                    -- 1984

-- Overdue books (>30 days from 2025-12-04)
(2, 1, '2025-10-01', NULL),                    -- To Kill a Mockingbird
(4, 3, '2025-10-15', NULL),                    -- Pride and Prejudice
(2, 6, '2025-09-15', NULL),                    -- Dune

-- Returned books
(1, 4, '2025-08-01', '2025-09-01'),           -- The Hobbit
(2, 5, '2025-09-01', '2025-10-01'),           -- Great Gatsby
(3, 6, '2025-10-01', '2025-11-01'),           -- Dune
(4, 7, '2025-11-01', '2025-12-01'),           -- Catcher in the Rye

-- Additional borrows for most borrowed book
(5, 1, '2025-07-01', '2025-08-01'),           -- To Kill a Mockingbird
(3, 1, '2025-08-15', '2025-09-15');           -- To Kill a Mockingbird

-- Information Retrieval Queries:

/* Query a: Retrieve books currently borrowed by Member ID 1 */
SELECT b.TITLE, br.BORROW_DATE, br.RETURN_DATE
FROM Books b
JOIN BorrowingRecords br ON b.BOOK_ID = br.BOOK_ID
WHERE br.MEMBER_ID = 1 AND br.RETURN_DATE IS NULL;

/* Query b: Find members with overdue books (as of 2025-12-04) */
SELECT m.NAME, b.TITLE, br.BORROW_DATE,
    CURRENT_DATE - br.BORROW_DATE AS days_overdue
FROM Members m
JOIN BorrowingRecords br ON m.MEMBER_ID = br.MEMBER_ID
JOIN Books b ON br.BOOK_ID = b.BOOK_ID
WHERE br.RETURN_DATE IS NULL 
AND (CURRENT_DATE - br.BORROW_DATE) > 30;

/* Query c: Retrieve books by genre with available copies count */
SELECT GENRE, COUNT(*) as total_books, 
    SUM(AVAILABLE_COPIES) as available_copies
FROM Books
GROUP BY GENRE
ORDER BY GENRE;

/* Query d: Find the most borrowed book(s) */
SELECT b.TITLE, COUNT(*) as times_borrowed
FROM Books b
JOIN BorrowingRecords br ON b.BOOK_ID = br.BOOK_ID
GROUP BY b.TITLE
ORDER BY times_borrowed DESC
LIMIT 1;

/* Query e: Retrieve members who borrowed books from at least three different genres */
SELECT m.NAME, COUNT(DISTINCT b.GENRE) as different_genres
FROM Members m
JOIN BorrowingRecords br ON m.MEMBER_ID = br.MEMBER_ID
JOIN Books b ON br.BOOK_ID = b.BOOK_ID
GROUP BY m.NAME
HAVING COUNT(DISTINCT b.GENRE) >= 3;

-- Reporting and Analytics Queries:

/* Query a: Calculate total books borrowed per month */
SELECT TO_CHAR(DATE_TRUNC('month', BORROW_DATE), 'YYYY-MM') as month,
    COUNT(*) as total_borrowed
FROM BorrowingRecords
GROUP BY DATE_TRUNC('month', BORROW_DATE)
ORDER BY month;

/* Query b: Find top three most active members */
SELECT m.NAME, COUNT(*) as books_borrowed
FROM Members m
JOIN BorrowingRecords br ON m.MEMBER_ID = br.MEMBER_ID
GROUP BY m.NAME
ORDER BY books_borrowed DESC
LIMIT 3;

/* Query c: Retrieve authors whose books have been borrowed at least 10 times */
SELECT b.AUTHOR, COUNT(*) as total_borrows
FROM Books b
JOIN BorrowingRecords br ON b.BOOK_ID = br.BOOK_ID
GROUP BY b.AUTHOR
HAVING COUNT(*) >= 10; -- no books have been borrowed 10 times

/* Query d: Identify members who have never borrowed a book */
SELECT m.NAME
FROM Members m
LEFT JOIN BorrowingRecords br ON m.MEMBER_ID = br.MEMBER_ID
WHERE br.BORROW_ID IS NULL; -- No rows returned - all members have borrowed at least once.
