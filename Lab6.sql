-- Laboratory Work 6
--1.1
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
);
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);
CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
);

--1.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);
INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');
INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

--2.1 CROSS JOIN; 5*4=20 rows
SELECT e.emp_name, d.dept_name
FROM employees e CROSS JOIN departments d;

--2.2a Comma notation; 20 rows
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

--2.2b INNER JOIN ON TRUE; 20 rows
SELECT e.emp_name, d.dept_name
FROM employees e INNER JOIN departments d ON TRUE;

--2.3 Employee/project availability matrix; 5*5=25 rows
SELECT e.emp_name, p.project_name
FROM employees e CROSS JOIN projects p
ORDER BY e.emp_id, p.project_id;

--3.1 INNER JOIN ON; 4 rows
--Tom's NULL dept_id does not match any department using equality.
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

--3.2 INNER JOIN USING; 4 rows
--This explicit SELECT returns the same columns as 3.1.
--With SELECT *, USING exposes one merged dept_id; ON exposes both.
SELECT emp_name, dept_name, location
FROM employees INNER JOIN departments USING (dept_id);

--3.3 NATURAL INNER JOIN; 4 rows
SELECT emp_name, dept_name, location
FROM employees NATURAL INNER JOIN departments;

--3.4 Three-table INNER JOIN; 6 rows
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;

--4.1 LEFT JOIN; 5 rows
--Tom appears with NULL emp_dept, dept_dept and dept_name.
SELECT e.emp_name, e.dept_id AS emp_dept,
       d.dept_id AS dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

--4.2 USING; preserve the exact output columns from 4.1
SELECT e.emp_name, e.dept_id AS emp_dept,
       d.dept_id AS dept_dept, d.dept_name
FROM employees e LEFT JOIN departments d USING (dept_id);

--4.3 Employees without a matching department; Tom Brown
SELECT e.emp_name, e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

--4.4 Employee counts; IT=2, Finance=1, HR=1, Marketing=0
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC, d.dept_name;

--5.1 RIGHT JOIN; 5 rows, including Marketing with NULL employee
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

--5.2 Equivalent LEFT JOIN
SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id;

--5.3 Departments without employees; Marketing, Building D
SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

--6.1 FULL JOIN; 6 rows
--Marketing has NULL employee-side columns.
--Tom Brown has NULL department-side columns.
SELECT e.emp_name, e.dept_id AS emp_dept,
       d.dept_id AS dept_dept, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;

--6.2 Departments/projects FULL JOIN; 6 rows
--Marketing has no project.AI Research has no department.
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;

--6.3 Unmatched records; Tom Brown and Marketing
SELECT CASE
           WHEN e.emp_id IS NULL THEN 'Department without employees'
           WHEN d.dept_id IS NULL THEN 'Employee without department'
           ELSE 'Matched'
       END AS record_status,
       e.emp_name, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;

--7.1 ON controls matching
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d
    ON e.dept_id = d.dept_id AND d.location = 'Building A';

--7.2 WHERE filters joined rows
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

--7.3a INNER JOIN, filter in ON; 2 rows
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d
    ON e.dept_id = d.dept_id AND d.location = 'Building A';

--7.3b INNER JOIN, filter in WHERE; identical results
-- Both conditions must be TRUE; no unmatched rows are preserved
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- 8.1
SELECT d.dept_name, e.emp_name, e.salary, p.project_name, p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name, p.project_name;

-- 8.2
ALTER TABLE employees ADD COLUMN manager_id INT;
UPDATE employees SET manager_id = 3 WHERE emp_id IN (1, 2, 4, 5);
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
SELECT e.emp_name AS employee, m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;
-- Mike has NULL manager; all other employees report to Mike

-- 8.3: Join with a subquery
SELECT d.dept_name, s.avg_salary
FROM departments d
INNER JOIN (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY dept_id
    HAVING AVG(salary) > 50000
) s ON d.dept_id = s.dept_id
ORDER BY d.dept_id;


/* Lab questions
1. INNER JOIN returns matching rows only. LEFT JOIN also preserves every
   left-table row, using NULLs for missing right-table data.
2. CROSS JOIN generates combinations(employees x projects or dates x rooms).
3. For an outer join, ON determines matches while preserving rows from the
   preserved sides. WHERE filters the resulting rows, potentially removing
   NULL-extended rows. Moving these conjunctive predicates between ON and
   WHERE in an INNER JOIN does not change the result.
4. 5*10 = 50
5. NATURAL JOIN uses equality on every identically named column in both tables.
6. Adding a shared column can silently change its meaning. Unrelated columns
   may share a name. With no shared names it behaves like a CROSS JOIN.
7. SELECT * FROM B RIGHT JOIN A ON A.id = B.id;
8. Use FULL OUTER JOIN to retain unmatched rows from both tables.
*/

-- Additional challenge  Simulate
--1
SELECT e.emp_id, e.emp_name, e.dept_id AS emp_dept,
       d.dept_id AS dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
UNION ALL
SELECT e.emp_id, e.emp_name, e.dept_id AS emp_dept,
       d.dept_id AS dept_dept, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

--2
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN(
    SELECT dept_id
    FROM projects
    GROUP BY dept_id
    HAVING COUNT(*) > 1
) p ON d.dept_id = p.dept_id;

--3
WITH RECURSIVE management_chain AS (
    SELECT emp_id AS employee_id, emp_name AS employee,
           emp_id AS current_id, manager_id,
           CAST(emp_name AS TEXT) AS chain, 0 AS depth
    FROM employees
    UNION ALL
    SELECT c.employee_id, c.employee, m.emp_id, m.manager_id,
           c.chain || ' -> ' || m.emp_name, c.depth + 1
    FROM management_chain c
    INNER JOIN employees m ON c.manager_id = m.emp_id
)
SELECT employee, chain, depth
FROM management_chain
WHERE manager_id IS NULL
ORDER BY employee_id;

--4
SELECT e1.emp_name AS employee_1, e2.emp_name AS employee_2, d.dept_name
FROM employees e1
INNER JOIN employees e2
    ON e1.dept_id = e2.dept_id AND e1.emp_id < e2.emp_id
INNER JOIN departments d ON e1.dept_id = d.dept_id;