-- 1
CREATE TABLE IF NOT EXISTS departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT REFERENCES departments(dept_id),
    salary DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS projects (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100),
    budget DECIMAL(12,2),
    dept_id INT REFERENCES departments(dept_id)
);

INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C')
ON CONFLICT (dept_id) DO NOTHING;

INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000)
ON CONFLICT (emp_id) DO NOTHING;

INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102)
ON CONFLICT (proj_id) DO NOTHING;


-- 2
-- 2.1
CREATE INDEX emp_salary_idx ON employees(salary);
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

-- Answer: Initially there are two indexes on employees:
-- the automatic PRIMARY KEY index on emp_id and emp_salary_idx


-- 2.2
CREATE INDEX emp_dept_idx ON employees(dept_id);

SELECT *
FROM employees
WHERE dept_id = 101;

/*Answer: An index on a foreign key can speed up JOINs and searches
by that column. It can also help when referenced rows are updated
or deleted and PostgreSQL checks related rows*/


-- 2.3
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Answer: PRIMARY KEY indexes are created automatically.


-- 3

-- 3.1
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;

/*Answer: This index is generally not useful for a query filtering only
by salary, because dept_id is the leading column. PostgreSQL may need
another index or a sequential scan*/


-- 3.2 
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

SELECT *
FROM employees
WHERE dept_id = 102 AND salary > 50000;

SELECT *
FROM employees
WHERE salary > 50000 AND dept_id = 102;

/*Answer: Yes, column order matters. A B-tree multicolumn index is most
effective when conditions use its leading column.
The written order of conditions in WHERE does NOT matter: both queries
express the same conditions. The index column order is what matters.*/


-- 4

-- 4.1 
ALTER TABLE employees ADD COLUMN IF NOT EXISTS email VARCHAR(100);

UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

/*INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');*/

/*Answer: PostgreSQL reports a duplicate-key error, typically:
ERROR: duplicate key value violates unique constraint
"emp_email_unique_idx"*/


-- 4.2 UNIQUE constraint
ALTER TABLE employees
ADD COLUMN IF NOT EXISTS phone VARCHAR(20);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'employees_phone_key'
    ) THEN
        ALTER TABLE employees
        ADD CONSTRAINT employees_phone_key UNIQUE (phone);
    END IF;
END $$;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';

/*Answer: Yes. PostgreSQL automatically creates a unique B-tree index
to enforce the UNIQUE constraint*/

-- 5
-- 5.1
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

/*Answer: The index stores salary values in descending order, so PostgreSQL
can read rows in the requested order and may avoid a separate sort*/


-- 5.2
CREATE INDEX proj_budget_nulls_first_idx
ON projects(budget NULLS FIRST);

SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;


-- 6

-- 6.1
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));

SELECT *
FROM employees
WHERE LOWER(emp_name) = 'john smith';
/*Answer: Without the expression index, PostgreSQL generally scans rows
and evaluates LOWER(emp_name) for each row (a sequential scan)*/

-- 6.2
ALTER TABLE employees ADD COLUMN IF NOT EXISTS hire_date DATE;

UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx
ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

-- 7
-- 7.
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;

SELECT indexname
FROM pg_indexes
WHERE tablename = 'employees';

-- 7.2
DROP INDEX emp_salary_dept_idx;

/*Answer: An unused or duplicate index can waste disk space and slow down
INSERT, UPDATE and DELETE operations because indexes must be maintained*/

-- 7.3
REINDEX INDEX employees_salary_index;

/*Answer: REINDEX can be useful when an index is bloated or needs rebuilding
after significant changes. It recreates the index structure*/

-- 8
-- 8.1
CREATE INDEX emp_salary_filter_idx
ON employees(salary)
WHERE salary > 50000;

SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;


-- 8.2
CREATE INDEX proj_high_budget_idx
ON projects(budget)
WHERE budget > 80000;

SELECT proj_name, budget
FROM projects
WHERE budget > 80000;

/*Answer: A partial index contains entries only for rows matching its
condition. It is smaller and has less maintenance overhead than a
full index when only a subset of rows is queried frequently*/

-- 8.3
EXPLAIN
SELECT *
FROM employees
WHERE salary > 52000;

/*Answer: Index Scan or Bitmap Index Scan means PostgreSQL chose an index.
Seq Scan means it reads the table sequentially. With this very small
sample table, Seq Scan is normal because it may be cheaper than using
an index. EXPLAIN ANALYZE shows actual execution details*/

-- 9
-- 9.1
CREATE INDEX dept_name_hash_idx
ON departments USING HASH (dept_name);

SELECT *
FROM departments
WHERE dept_name = 'IT';

/*Answer: A HASH index is suitable for equality comparisons (=).
Use B-tree for general-purpose indexing, including equality and ranges*/

-- 9.2
CREATE INDEX proj_name_btree_idx
ON projects(proj_name);

CREATE INDEX proj_name_hash_idx
ON projects USING HASH (proj_name);

-- Equality search
SELECT *
FROM projects
WHERE proj_name = 'Website Redesign';

-- Range search
SELECT *
FROM projects
WHERE proj_name > 'Database';

-- 10
-- 10.1
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

/*Answer: The largest index depends on the actual data and database.
Usually an index on a table with more rows or wider indexed values is larger.
With this small sample, sizes may be equal or very small*/

-- 10.2
DROP INDEX IF EXISTS proj_name_hash_idx;

-- 10.3
CREATE OR REPLACE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE '%salary%';

SELECT *
FROM index_documentation;

/*SUMMARY QUESTIONS
1. The default index type in PostgreSQL is B-tree.
2. Create an index for frequently used WHERE conditions, JOIN columns, and columns used in ORDER BY.
3. Avoid indexes on columns that are rarely searched and on very small tables where a sequential scan is cheaper. Also avoid redundant indexes.
4. INSERT, UPDATE and DELETE may become slower because PostgreSQL must
maintain the affected indexes.
5. Use EXPLAIN or EXPLAIN ANALYZE to check whether a query uses an index*/