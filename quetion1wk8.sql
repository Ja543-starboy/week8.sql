-- Library Management System Database
-- Created by [Your Name]

-- Create database
DROP DATABASE IF EXISTS library_db;
CREATE DATABASE library_db;
USE library_db;

-- Members table
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    join_date DATE NOT NULL,
    membership_status ENUM('active', 'expired', 'suspended') DEFAULT 'active'
);

-- Books table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100) NOT NULL,
    publisher VARCHAR(100),
    publication_year INT,
    genre VARCHAR(50),
    total_copies INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1
);

-- Loans table (1-M relationship between members and books)
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    status ENUM('active', 'returned', 'overdue') DEFAULT 'active',
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- Fines table (1-1 relationship with loans)
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT UNIQUE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    issue_date DATE NOT NULL,
    payment_date DATE,
    status ENUM('unpaid', 'paid') DEFAULT 'unpaid',
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

-- Sample data for members
INSERT INTO members (first_name, last_name, email, phone, join_date, membership_status)
VALUES 
    ('John', 'Smith', 'john.smith@email.com', '555-0101', '2022-01-15', 'active'),
    ('Emily', 'Johnson', 'emily.j@email.com', '555-0102', '2022-03-22', 'active'),
    ('Michael', 'Williams', 'michael.w@email.com', NULL, '2023-01-10', 'suspended');

-- Sample data for books
INSERT INTO books (isbn, title, author, publisher, publication_year, genre, total_copies, available_copies)
VALUES
    ('978-0061120084', 'To Kill a Mockingbird', 'Harper Lee', 'J. B. Lippincott & Co.', 1960, 'Fiction', 3, 2),
    ('978-0451524935', '1984', 'George Orwell', 'Secker & Warburg', 1949, 'Dystopian', 2, 1),
    ('978-0743273565', 'The Great Gatsby', 'F. Scott Fitzgerald', 'Charles Scribner''s Sons', 1925, 'Classic', 5, 4);

-- Sample data for loans
INSERT INTO loans (member_id, book_id, loan_date, due_date, return_date, status)
VALUES
    (1, 1, '2023-02-01', '2023-02-15', NULL, 'active'),
    (2, 2, '2023-02-05', '2023-02-19', '2023-02-18', 'returned'),
    (1, 3, '2023-03-10', '2023-03-24', NULL, 'overdue');

-- Sample data for fines
INSERT INTO fines (loan_id, amount, issue_date, payment_date, status)
VALUES
    (3, 5.00, '2023-03-25', NULL, 'unpaid');