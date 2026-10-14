-- Lab Work 5: Database Constraints 
-- Name: Sanzhar Zhumagul
-- Student ID: 25B031282

CREATE SCHEMA lab5;
SET search_path TO lab5;

-- 1.1: CHECK limits age and salary.
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CONSTRAINT valid_age CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CONSTRAINT valid_salary CHECK (salary > 0)
);

-- 1.2: Discount must be positive and below regular price.
CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0 AND discount_price > 0
        AND discount_price < regular_price
    )
);

-- 1.3: Valid guest count and date order.
CREATE TABLE bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CONSTRAINT valid_guests CHECK (num_guests BETWEEN 1 AND 10),
    CONSTRAINT valid_dates CHECK (check_out_date > check_in_date)
);

-- 1.4: Valid inserts succeed (2 rows each).
INSERT INTO employees VALUES
(1, 'Anna', 'Smith', 18, 1500),
(2, 'John', 'Brown', 65, 2500);
INSERT INTO products_catalog VALUES
(1, 'Keyboard', 100, 80), (2, 'Mouse', 50, 40);
INSERT INTO bookings VALUES
(1, '2026-10-01', '2026-10-03', 1),
(2, '2026-10-05', '2026-10-08', 10);

-- Fails valid_age: age below 18 / above 65.
-- INSERT INTO employees VALUES (3, 'Tom', 'Lee', 17, 1000);
-- INSERT INTO employees VALUES (4, 'Bob', 'Lee', 66, 1000);
-- Fails valid_salary: salary is zero.
-- INSERT INTO employees VALUES (5, 'Sam', 'Lee', 25, 0);
-- Fails valid_discount: non-positive regular price.
-- INSERT INTO products_catalog VALUES (3, 'Cable', 0, 1);
-- Fails valid_discount: non-positive discount price.
-- INSERT INTO products_catalog VALUES (4, 'Cable', 10, 0);
-- Fails valid_discount: discount equals regular price.
-- INSERT INTO products_catalog VALUES (5, 'Cable', 10, 10);
-- Fails valid_guests: outside 1..10.
-- INSERT INTO bookings VALUES (3, '2026-10-01', '2026-10-02', 0);
-- INSERT INTO bookings VALUES (4, '2026-10-01', '2026-10-02', 11);
-- Fails valid_dates: checkout is not later.
-- INSERT INTO bookings VALUES (5, '2026-10-02', '2026-10-02', 2);
-- CHECK allows NULL unless NOT NULL is also specified.

-- 2.1: NOT NULL requires a value; phone is optional.
CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

-- 2.2: Required fields with quantity/price checks.
CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

-- 2.3: Both customer inserts succeed, including NULL phone.
INSERT INTO customers VALUES
(1, 'anna@example.com', '77010000001', '2026-10-01'),
(2, 'john@example.com', NULL, '2026-10-02');
INSERT INTO inventory VALUES (1, 'Keyboard', 0, 100, '2026-10-01 10:00:00');
-- Each fails NOT NULL on the NULL column.
-- INSERT INTO customers VALUES (NULL, 'a@ex.com', NULL, CURRENT_DATE);
-- INSERT INTO customers VALUES (3, NULL, NULL, CURRENT_DATE);
-- INSERT INTO customers VALUES (3, 'a@ex.com', NULL, NULL);
-- INSERT INTO inventory VALUES (NULL, 'Mouse', 1, 20, CURRENT_TIMESTAMP);
-- INSERT INTO inventory VALUES (2, NULL, 1, 20, CURRENT_TIMESTAMP);
-- INSERT INTO inventory VALUES (2, 'Mouse', NULL, 20, CURRENT_TIMESTAMP);
-- INSERT INTO inventory VALUES (2, 'Mouse', 1, NULL, CURRENT_TIMESTAMP);
-- INSERT INTO inventory VALUES (2, 'Mouse', 1, 20, NULL);
-- CHECK failures: negative quantity / zero price.
-- INSERT INTO inventory VALUES (2, 'Mouse', -1, 20, CURRENT_TIMESTAMP);
-- INSERT INTO inventory VALUES (2, 'Mouse', 1, 0, CURRENT_TIMESTAMP);

-- 3.1: UNIQUE prevents duplicate non-NULL values.
CREATE TABLE users (
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

-- 3.2: Each student/course/semester combination is unique.
CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT unique_enrollment UNIQUE (student_id, course_code, semester)
);
INSERT INTO course_enrollments VALUES
(1, 101, 'DB101', 'Fall 2026'),
(2, 101, 'DB101', 'Spring 2027');
-- Fails unique_enrollment: repeated combination.
-- INSERT INTO course_enrollments VALUES (3, 101, 'DB101', 'Fall 2026');

-- 3.3: Replace automatic names with requested names.
ALTER TABLE users DROP CONSTRAINT users_username_key;
ALTER TABLE users DROP CONSTRAINT users_email_key;
ALTER TABLE users ADD CONSTRAINT unique_username UNIQUE (username);
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email);
INSERT INTO users VALUES (1, 'anna', 'anna@example.com', CURRENT_TIMESTAMP);
-- Fails unique_username / unique_email, respectively.
-- INSERT INTO users VALUES (2, 'anna', 'other@example.com', CURRENT_TIMESTAMP);
-- INSERT INTO users VALUES (3, 'john', 'anna@example.com', CURRENT_TIMESTAMP);
-- Succeeds: default UNIQUE allows multiple NULLs.
INSERT INTO users VALUES (4, NULL, NULL, CURRENT_TIMESTAMP),
                         (5, NULL, NULL, CURRENT_TIMESTAMP);

-- 4.1: PRIMARY KEY means unique and non-NULL.
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);
INSERT INTO departments VALUES
(1, 'IT', 'Almaty'), (2, 'HR', 'Astana'), (3, 'Sales', 'Shymkent');
-- Fails primary-key uniqueness: repeated ID.
-- INSERT INTO departments VALUES (1, 'Finance', 'Almaty');
-- Fails NOT NULL: primary key cannot be NULL.
-- INSERT INTO departments VALUES (NULL, 'Finance', 'Almaty');

-- 4.2: The pair identifies one enrollment.
CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);
INSERT INTO student_courses VALUES
(101, 1, '2026-09-01', 'A'), (101, 2, '2026-09-01', 'B');
-- Fails: duplicate pair / NULL key component.
-- INSERT INTO student_courses VALUES (101, 1, CURRENT_DATE, 'C');
-- INSERT INTO student_courses VALUES (NULL, 3, CURRENT_DATE, 'A');

-- 4.3: Comparison
-- PRIMARY KEY identifies rows and forbids NULL in all key columns.
-- UNIQUE enforces alternative keys; NULLs are distinct by default.
-- Use a single-column key for one stable identifier (e.g., dept_id).
-- Use a composite key when a combination identifies a row.
-- A table has one chosen primary identity, possibly several columns.
-- Multiple UNIQUE constraints can enforce other candidate keys.

-- 5.1: FOREIGN KEY requires an existing department (or NULL).
CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);
INSERT INTO employees_dept VALUES
(1, 'Anna Smith', 1, '2026-01-10'),
(2, 'John Brown', 2, '2026-02-15');
-- Fails foreign key: department 999 does not exist.
-- INSERT INTO employees_dept VALUES (3, 'Tom Lee', 999, CURRENT_DATE);

-- 5.2: Library schema; books reference authors and publishers.
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);
CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);
CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);
INSERT INTO authors VALUES
(1, 'Author A', 'Kazakhstan'), (2, 'Author B', 'UK');
INSERT INTO publishers VALUES
(1, 'Publisher A', 'Almaty'), (2, 'Publisher B', 'London');
INSERT INTO books VALUES
(1, 'Database Basics', 1, 1, 2025, '9780000000002'),
(2, 'Learning SQL', 2, 2, 2026, '9780000000019');
-- Fails: unknown author / publisher / duplicate ISBN.
-- INSERT INTO books VALUES (3, 'Book C', 999, 1, 2026, '9780000000026');
-- INSERT INTO books VALUES (3, 'Book C', 1, 999, 2026, '9780000000026');
-- INSERT INTO books VALUES (3, 'Book C', 1, 1, 2026, '9780000000002');

-- 5.3: RESTRICT blocks deletion; CASCADE removes child rows.
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);
CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);
CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);
INSERT INTO categories VALUES (1, 'Electronics');
INSERT INTO products_fk VALUES (1, 'Keyboard', 1);
INSERT INTO orders VALUES (1, '2026-10-01');
INSERT INTO order_items VALUES (1, 1, 1, 2), (2, 1, 1, 1);
-- Fails RESTRICT: category still has a product.
-- DELETE FROM categories WHERE category_id = 1;
SELECT COUNT(*) AS items_before FROM order_items WHERE order_id = 1; -- 2
DELETE FROM orders WHERE order_id = 1;
SELECT COUNT(*) AS items_after FROM order_items WHERE order_id = 1; -- 0
-- CASCADE deleted both items; the product remains.
SELECT COUNT(*) AS products_remaining FROM products_fk; -- 1

-- 6.1: Separate schema avoids earlier table-name conflicts.
CREATE SCHEMA lab5_shop;
SET search_path TO lab5_shop;

-- Email is unique; phone is optional; all IDs are primary keys.
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL
);
-- Price and stock cannot be negative; description is optional.
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);
-- RESTRICT preserves orders when a customer is referenced.
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    order_date DATE NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (
        status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')
    )
);
-- CASCADE removes details; RESTRICT protects referenced products.
CREATE TABLE order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);

-- Five valid records per table.
INSERT INTO customers VALUES
(1, 'Anna', 'anna@example.com', '77010000001', '2026-10-01'),
(2, 'John', 'john@example.com', NULL, '2026-10-02'),
(3, 'Sara', 'sara@example.com', '77010000003', '2026-10-03'),
(4, 'Tom', 'tom@example.com', '77010000004', '2026-10-04'),
(5, 'Aida', 'aida@example.com', '77010000005', '2026-10-05');
INSERT INTO products VALUES
(1, 'Keyboard', 'USB keyboard', 100, 20),
(2, 'Mouse', 'Wireless mouse', 50, 30),
(3, 'Monitor', '24-inch monitor', 200, 10),
(4, 'Cable', NULL, 10, 0),
(5, 'Sticker', 'Promotional gift', 0, 100);
INSERT INTO orders VALUES
(1, 1, '2026-10-10', 100, 'pending'),
(2, 2, '2026-10-10', 100, 'processing'),
(3, 3, '2026-10-11', 200, 'shipped'),
(4, 4, '2026-10-11', 30, 'delivered'),
(5, 5, '2026-10-12', 0, 'cancelled');
INSERT INTO order_details VALUES
(1, 1, 1, 1, 100), (2, 2, 2, 2, 50),
(3, 3, 3, 1, 200), (4, 4, 4, 3, 10), (5, 5, 5, 1, 0);

-- Primary-key tests: each fails on duplicate / NULL ID.
-- INSERT INTO customers VALUES (1, 'X', 'x@ex.com', NULL, CURRENT_DATE);
-- INSERT INTO customers VALUES (NULL, 'X', 'x@ex.com', NULL, CURRENT_DATE);
-- INSERT INTO products VALUES (1, 'X', NULL, 1, 1);
-- INSERT INTO products VALUES (NULL, 'X', NULL, 1, 1);
-- INSERT INTO orders VALUES (1, 1, CURRENT_DATE, 1, 'pending');
-- INSERT INTO orders VALUES (NULL, 1, CURRENT_DATE, 1, 'pending');
-- INSERT INTO order_details VALUES (1, 1, 1, 1, 1);
-- INSERT INTO order_details VALUES (NULL, 1, 1, 1, 1);

-- UNIQUE fails: email already exists.
-- INSERT INTO customers VALUES (6, 'X', 'anna@example.com', NULL, CURRENT_DATE);
-- FOREIGN KEY fails: referenced ID 999 is absent.
-- INSERT INTO orders VALUES (6, 999, CURRENT_DATE, 1, 'pending');
-- INSERT INTO order_details VALUES (6, 999, 1, 1, 1);
-- INSERT INTO order_details VALUES (6, 1, 999, 1, 1);

-- CHECK fails: negative price / stock / total / invalid status.
-- INSERT INTO products VALUES (6, 'X', NULL, -1, 1);
-- INSERT INTO products VALUES (6, 'X', NULL, 1, -1);
-- INSERT INTO orders VALUES (6, 1, CURRENT_DATE, -1, 'pending');
-- INSERT INTO orders VALUES (6, 1, CURRENT_DATE, 1, 'unknown');
-- CHECK fails: non-positive quantity / negative unit price.
-- INSERT INTO order_details VALUES (6, 1, 1, 0, 1);
-- INSERT INTO order_details VALUES (6, 1, 1, 1, -1);

-- NOT NULL tests: each fails on the specified column.
-- UPDATE customers SET name = NULL WHERE customer_id = 1;
-- UPDATE customers SET email = NULL WHERE customer_id = 1;
-- UPDATE customers SET registration_date = NULL WHERE customer_id = 1;
-- UPDATE products SET name = NULL WHERE product_id = 1;
-- UPDATE products SET price = NULL WHERE product_id = 1;
-- UPDATE products SET stock_quantity = NULL WHERE product_id = 1;
-- UPDATE orders SET customer_id = NULL WHERE order_id = 1;
-- UPDATE orders SET order_date = NULL WHERE order_id = 1;
-- UPDATE orders SET total_amount = NULL WHERE order_id = 1;
-- UPDATE orders SET status = NULL WHERE order_id = 1;
-- UPDATE order_details SET order_id = NULL WHERE order_detail_id = 1;
-- UPDATE order_details SET product_id = NULL WHERE order_detail_id = 1;
-- UPDATE order_details SET quantity = NULL WHERE order_detail_id = 1;
-- UPDATE order_details SET unit_price = NULL WHERE order_detail_id = 1;

-- RESTRICT fails: customer/product has dependent rows.
-- DELETE FROM customers WHERE customer_id = 1;
-- DELETE FROM products WHERE product_id = 1;

-- CASCADE succeeds; rollback keeps the five sample orders.
BEGIN;
DELETE FROM orders WHERE order_id = 1;
SELECT COUNT(*) AS remaining_details FROM order_details WHERE order_id = 1; -- 0
ROLLBACK;
SELECT COUNT(*) AS restored_details FROM order_details WHERE order_id = 1; -- 1

-- Expected: five rows in each table.
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_details', COUNT(*) FROM order_details;

-- Expected: no rows (sample totals match their details).
-- Cross-table totals require application logic or a trigger.
SELECT o.order_id
FROM orders o
LEFT JOIN order_details d ON d.order_id = o.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount <> COALESCE(SUM(d.quantity * d.unit_price), 0);

RESET search_path;























--10 октября 2026