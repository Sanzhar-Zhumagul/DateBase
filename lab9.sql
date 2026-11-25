--1.1
DROP TABLE IF EXISTS rentals, bikes, members, stations CASCADE;

CREATE TABLE stations (
    station_id   INT PRIMARY KEY,
    station_name VARCHAR(50) NOT NULL,
    city         VARCHAR(40) NOT NULL,
    capacity     INT NOT NULL
);

CREATE TABLE bikes (
    bike_id    INT PRIMARY KEY,
    model      VARCHAR(50) NOT NULL,
    station_id INT REFERENCES stations(station_id),
    daily_rate NUMERIC(8,2) NOT NULL
);

CREATE TABLE members (
    member_id INT PRIMARY KEY,
    full_name VARCHAR(60) NOT NULL,
    city      VARCHAR(40) NOT NULL,
    joined_on DATE NOT NULL
);

CREATE TABLE rentals (
    rental_id  INT PRIMARY KEY,
    member_id  INT REFERENCES members(member_id),
    bike_id    INT REFERENCES bikes(bike_id),
    start_date DATE NOT NULL,
    end_date   DATE,
    fee        NUMERIC(8,2)
);

--1.2
INSERT INTO stations VALUES
 (10, 'Central Park', 'Almaty',   4),
 (20, 'Riverside',    'Almaty',   3),
 (30, 'Expo Gate',    'Astana',   5),
 (40, 'Old Town',     'Shymkent', 2),
 (50, 'Depot',        'Astana',   0);

INSERT INTO bikes VALUES
 (101, 'City Cruiser', 10,  4.50),
 (102, 'City Cruiser', 10,  4.50),
 (103, 'Mountain X',   20,  7.00),
 (104, 'Mountain X',   30,  7.00),
 (105, 'Road Sprint',  30,  9.25),
 (106, 'Folding Mini', 40,  3.75),
 (107, 'Cargo Hauler', 20, 12.00),
 (108, 'Road Sprint',  10,  9.25);

INSERT INTO members VALUES
 (1, 'Aisha Nurlanova', 'Almaty',   DATE '2023-03-14'),
 (2, 'Daniyar Serik',   'Almaty',   DATE '2023-07-02'),
 (3, 'Marta Kowalski',  'Astana',   DATE '2024-01-20'),
 (4, 'Chen Wei',        'Astana',   DATE '2024-05-11'),
 (5, 'Omar Haddad',     'Shymkent', DATE '2024-09-30'),
 (6, 'Elena Petrova',   'Almaty',   DATE '2025-02-05');

INSERT INTO rentals VALUES
 ( 1, 1, 101, DATE '2024-04-05', DATE '2024-04-08', 13.50),
 ( 2, 1, 103, DATE '2024-06-11', DATE '2024-06-16', 35.00),
 ( 3, 1, 108, DATE '2025-02-02', DATE '2025-02-04', 18.50),
 ( 4, 1, 102, DATE '2025-05-20', DATE '2025-05-27', 31.50),
 ( 5, 2, 101, DATE '2024-05-01', DATE '2024-05-02',  4.50),
 ( 6, 2, 107, DATE '2024-11-15', DATE '2024-11-19', 48.00),
 ( 7, 2, 107, DATE '2025-03-08', DATE '2025-03-14', 72.00),
 ( 8, 3, 104, DATE '2024-02-14', DATE '2024-02-18', 28.00),
 ( 9, 3, 105, DATE '2024-08-03', DATE '2024-08-06', 27.75),
 (10, 3, 104, DATE '2025-01-09', DATE '2025-01-10',  7.00),
 (11, 3, 105, DATE '2025-06-01', DATE '2025-06-09', 74.00),
 (12, 4, 104, DATE '2024-07-19', DATE '2024-07-21', 14.00),
 (13, 4, 105, DATE '2025-04-12', DATE '2025-04-15', 27.75),
 (14, 4, 103, DATE '2025-07-23', DATE '2025-07-29', 42.00),
 (15, 5, 106, DATE '2024-10-05', DATE '2024-10-12', 26.25),
 (16, 5, 106, DATE '2025-01-18', DATE '2025-01-20',  7.50),
 (17, 5, 106, DATE '2025-08-14', DATE '2025-08-21', 26.25),
 (18, 2, 102, DATE '2025-09-02', DATE '2025-09-05', 13.50),
 (19, 1, 101, DATE '2025-10-10', NULL,              NULL),
 (20, 4, 108, DATE '2024-12-28', DATE '2025-01-03', 55.50),
 (21, 3, 103, DATE '2025-02-26', DATE '2025-03-02', 28.00),
 (22, 5, 104, DATE '2025-05-05', DATE '2025-05-08', 21.00);

SELECT (SELECT COUNT(*) FROM stations) AS stations,
       (SELECT COUNT(*) FROM bikes)    AS bikes,
       (SELECT COUNT(*) FROM members)  AS members,
       (SELECT COUNT(*) FROM rentals)  AS rentals;

CREATE OR REPLACE FUNCTION inc(val INTEGER) RETURNS INTEGER AS $$
DECLARE
    result INTEGER;
BEGIN
    result := val + 1;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT inc(10);

--2.1
CREATE OR REPLACE FUNCTION rental_days(p_rental_id INT) RETURNS INT AS $$
DECLARE
    v_days INT;
BEGIN
    SELECT end_date - start_date INTO v_days
    FROM rentals
    WHERE rental_id = p_rental_id;
    RETURN v_days;
END;
$$ LANGUAGE plpgsql;

SELECT rental_days(2);
SELECT rental_days(11);
SELECT rental_days(19);
SELECT rental_days(999);
-- Both return NULL for different reasons: rental 19 exists but has end_date IS NULL (so NULL - start_date = NULL), whereas rental 999 does not exist so SELECT INTO assigns NULL to v_days.

--2.2
CREATE OR REPLACE FUNCTION member_rental_count(p_member_id INT) RETURNS INT AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM rentals
    WHERE member_id = p_member_id;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

SELECT member_rental_count(1);
SELECT member_rental_count(5);
SELECT member_rental_count(6);
SELECT member_rental_count(99);
-- COUNT(*) is an aggregate over the whole filtered set without GROUP BY, so it always returns a single row with 0 when zero rows match rather than returning no rows (which would become NULL in SELECT INTO).

--2.3
CREATE OR REPLACE FUNCTION station_city(p_station_id INT) RETURNS VARCHAR AS $$
DECLARE
    v_city VARCHAR;
BEGIN
    SELECT city INTO v_city
    FROM stations
    WHERE station_id = p_station_id;
    RETURN v_city;
END;
$$ LANGUAGE plpgsql;

SELECT station_city(30);
SELECT station_city(77);

--2.4
SELECT rental_id, member_id, rental_days(rental_id) AS duration
FROM rentals
WHERE rental_days(rental_id) > 4
ORDER BY duration DESC;

--3.1
CREATE OR REPLACE FUNCTION fee_with_discount(p_fee NUMERIC, p_percent NUMERIC) RETURNS NUMERIC AS $$
BEGIN
    RETURN ROUND(p_fee * (1 - p_percent / 100.0), 2);
END;
$$ LANGUAGE plpgsql;

SELECT fee_with_discount(74.00, 15);

--3.2
CREATE OR REPLACE FUNCTION member_stats(
    p_member_id INT,
    OUT rental_cnt INT,
    OUT total_fee NUMERIC,
    OUT last_start DATE
) AS $$
BEGIN
    SELECT COUNT(*), COALESCE(SUM(fee), 0), MAX(start_date)
    INTO rental_cnt, total_fee, last_start
    FROM rentals
    WHERE member_id = p_member_id;
END;
$$ LANGUAGE plpgsql;

SELECT member_stats(3);
SELECT * FROM member_stats(3);
SELECT * FROM member_stats(6);
-- SELECT member_stats(3) returns a single composite/record column "(5,164.75,2025-06-01)", while SELECT * FROM member_stats(3) expands OUT parameters into separate columns; use SELECT * FROM (or LATERAL) in a larger query to access individual columns directly, and member 6 returns (0, 0, NULL).

--3.3
CREATE OR REPLACE FUNCTION apply_late_fee(INOUT p_fee NUMERIC) AS $$
BEGIN
    p_fee := p_fee + 5.00;
END;
$$ LANGUAGE plpgsql;

SELECT apply_late_fee(fee) FROM rentals WHERE rental_id = 1;
-- An INOUT parameter acts as both input and output, so PostgreSQL implicitly defines the function's return type as the INOUT parameter's type and returns its final value when the block ends without needing RETURNS or RETURN.

--3.4
CREATE OR REPLACE FUNCTION fee_summary(
    VARIADIC p_fees NUMERIC[],
    OUT total NUMERIC,
    OUT average NUMERIC,
    OUT largest NUMERIC
) AS $$
BEGIN
    SELECT SUM(p_fees[i]), ROUND(AVG(p_fees[i]), 2), MAX(p_fees[i])
    INTO total, average, largest
    FROM generate_subscripts(p_fees, 1) AS g(i);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fee_summary(13.50, 35.00, 18.50, 31.50);
-- Calling fee_summary() with no arguments fails because a VARIADIC parameter requires at least one argument (unless given a default), and VARIADIC must be last because it greedily consumes all remaining trailing arguments of that type.

--3.5
-- (a) IN because the lookup ID is read-only input; (b) INOUT because the caller passes an initial balance and receives the updated value back; (c) VARIADIC because it collects a variable number of station IDs into an array; (d) OUT because two separate return values are produced together in one pass.

--4.1
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT) RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO v_total
    FROM rentals
    WHERE member_id = p_member_id;
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1);
SELECT total_fees(6);

--4.2
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT, p_from_date DATE) RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO v_total
    FROM rentals
    WHERE member_id = p_member_id AND start_date >= p_from_date;
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1, DATE '2024-01-01');
SELECT total_fees(1, DATE '2025-01-01');
SELECT proname, pg_get_function_arguments(oid) FROM pg_proc WHERE proname = 'total_fees';

--4.3
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT, p_from_date DATE DEFAULT DATE '2025-01-01') RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO v_total
    FROM rentals
    WHERE member_id = p_member_id AND start_date >= p_from_date;
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1);
-- Error "ERROR: function total_fees(integer) is not unique" / Hint "Could not choose a best candidate function. You might need to add explicit type casts." occurs because both total_fees(INT) and total_fees(INT, DATE DEFAULT ...) match a single integer argument equally well.

--4.4
DROP FUNCTION total_fees(INTEGER);
SELECT total_fees(1);
-- The two-parameter version total_fees(INT, DATE DEFAULT '2025-01-01') answers the call and returns 50.00; dropping the two-parameter version instead would have kept total_fees(INT) which sums all dates and returns 98.50.

--4.5
CREATE OR REPLACE FUNCTION total_fees(p_full_name VARCHAR) RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(r.fee), 0) INTO v_total
    FROM members m
    LEFT JOIN rentals r ON m.member_id = r.member_id
    WHERE m.full_name = p_full_name;
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees('Aisha Nurlanova');
SELECT total_fees(1);
-- There is no ambiguity because VARCHAR and INT are distinct types; total_fees('Aisha Nurlanova') calls total_fees(VARCHAR) summing all her rentals (98.50), while total_fees(1) calls total_fees(INT, DATE DEFAULT '2025-01-01') summing only rentals from 2025-01-01 onward (50.00).

--5.1
CREATE OR REPLACE FUNCTION find_bikes(p_pattern VARCHAR)
RETURNS TABLE(found_id INT, found_model VARCHAR, found_rate NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT bike_id, model, daily_rate
    FROM bikes
    WHERE model ILIKE p_pattern
    ORDER BY bike_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM find_bikes('%road%');
SELECT * FROM find_bikes('%Mini');
SELECT find_bikes('%road%');
-- Without FROM, SELECT find_bikes('%road%') returns a single column of composite record tuples (e.g. "(105,"Road Sprint",9.25)") instead of separate columns because the set-returning function is evaluated in the select list rather than as a table source.

--5.2
CREATE OR REPLACE FUNCTION member_history(p_member_id INT)
RETURNS TABLE(rental_id INT, model VARCHAR, station_name VARCHAR, duration INT, fee NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT r.rental_id, b.model, s.station_name, (r.end_date - r.start_date), r.fee
    FROM rentals r
    JOIN bikes b ON r.bike_id = b.bike_id
    JOIN stations s ON b.station_id = s.station_id
    WHERE r.member_id = p_member_id
    ORDER BY r.start_date;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM member_history(3);

--5.3
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE(bike_id INT, model VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT bike_id, model FROM bikes WHERE station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list(10);
-- PL/pgSQL validates SQL queries inside the body lazily on first execution rather than at CREATE time, so the ambiguous reference between the OUT column bike_id and table column bikes.bike_id fails only when called ("ERROR: column reference "bike_id" is ambiguous").

CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE(out_bike_id INT, out_model VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT bike_id, model FROM bikes WHERE station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list(10);

CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE(bike_id INT, model VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT b.bike_id, b.model FROM bikes b WHERE b.station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list(10);

--5.4
CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE(s_name VARCHAR, s_bikes INT, s_free INT) AS $$
BEGIN
    RETURN QUERY
    SELECT s.station_name, COUNT(b.bike_id)::INT, (s.capacity - COUNT(b.bike_id))::INT
    FROM stations s
    LEFT JOIN bikes b ON s.station_id = b.station_id
    WHERE s.city = p_city
    GROUP BY s.station_id, s.station_name, s.capacity
    ORDER BY s.station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM station_board('Almaty');
-- Without casting COUNT(*) to INT, calling the function raises "ERROR: structure of query does not match function result type" / "DETAIL: Returned type bigint does not match expected type integer in column 2."

--6.1
DO $$
<<rental_report>>
DECLARE
    total_rentals INTEGER := 0;
BEGIN
    SELECT COUNT(*) INTO total_rentals FROM rentals;
    RAISE NOTICE 'The rentals table holds % rows.', total_rentals;
END rental_report $$;
-- If the label after END does not match the label at the top, PostgreSQL raises a syntax/compile error ("ERROR: end label "..." differs from block's label "rental_report"").

--6.2
DO $$
<<rental_report>>
DECLARE
    fee_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO fee_total FROM rentals;
    RAISE NOTICE 'Outer before subblock: %', fee_total;
    DECLARE
        fee_total NUMERIC;
    BEGIN
        SELECT COALESCE(SUM(fee), 0) INTO fee_total FROM rentals WHERE start_date >= DATE '2025-01-01';
        RAISE NOTICE 'Subblock own value: %', fee_total;
        RAISE NOTICE 'Outer reached via label: %', rental_report.fee_total;
    END;
    RAISE NOTICE 'Outer after subblock: %', fee_total;
END rental_report $$;
-- It prints 591.25, 338.25, 591.25, and 591.25; the inner assignment did not modify the outer variable because subblock declarations create a separate local variable that only shadows the outer one within that block's scope.

--6.3
DO $$
<<rental_report>>
DECLARE
    shared_var INT := 10;
BEGIN
    DECLARE
        local_var INT := 5;
    BEGIN
        RAISE NOTICE 'First subblock sees local_var = % and shared_var = %', local_var, shared_var;
    END;
    BEGIN
        RAISE NOTICE 'Second subblock sees shared_var = %', shared_var;
    END;
END rental_report $$;
-- Trying to read local_var in the second subblock raises "ERROR: column "local_var" does not exist" because local_var goes out of scope when the first subblock ends; declaring shared_var in the outer block makes it visible to both subblocks.

--6.4
CREATE OR REPLACE FUNCTION fee_split(
    p_from_date DATE,
    OUT before_total NUMERIC,
    OUT after_total NUMERIC
) AS $$
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO before_total FROM rentals WHERE start_date < p_from_date;
    SELECT COALESCE(SUM(fee), 0) INTO after_total FROM rentals WHERE start_date >= p_from_date;
END;
$$ LANGUAGE plpgsql;

SELECT *, before_total + after_total AS combined_total FROM fee_split(DATE '2025-01-01');

--7.1
CREATE OR REPLACE FUNCTION station_load(
    p_station_id INT,
    OUT bikes_parked INT,
    OUT capacity_pct NUMERIC
) AS $$
DECLARE
    v_cap INT;
BEGIN
    SELECT s.capacity, COUNT(b.bike_id)::INT
    INTO v_cap, bikes_parked
    FROM stations s
    LEFT JOIN bikes b ON s.station_id = b.station_id
    WHERE s.station_id = p_station_id
    GROUP BY s.station_id, s.capacity;

    IF v_cap IS NULL OR v_cap = 0 THEN
        capacity_pct := 0.0;
    ELSE
        capacity_pct := ROUND((bikes_parked::NUMERIC / v_cap) * 100, 1);
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT s.station_id, s.station_name, l.*
FROM stations s, LATERAL station_load(s.station_id) l;
-- Returning 0.0 avoids division by zero when capacity is 0, keeps the numeric column clean for aggregations, and reflects that 0% of usable dock capacity is occupied at the Depot.

--7.2
CREATE OR REPLACE FUNCTION top_members(p_limit INT DEFAULT 3)
RETURNS TABLE(member_name VARCHAR, rental_count INT, total_spent NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT m.full_name, COUNT(r.rental_id)::INT, COALESCE(SUM(r.fee), 0)
    FROM members m
    LEFT JOIN rentals r ON m.member_id = r.member_id
    GROUP BY m.member_id, m.full_name
    ORDER BY total_spent DESC, m.member_id
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM top_members();
SELECT * FROM top_members(6);
-- Aisha Nurlanova (5 rentals, 98.50 spent) has more rentals than Daniyar Serik (4 rentals, 138.00 spent) and Marta Kowalski (5 rentals, 164.75 spent) yet ranks below them because the specification orders by total amount spent rather than rental count (and her 5th rental is still open with NULL fee).

--7.3
CREATE OR REPLACE FUNCTION rental_invoice(p_rental_id INT)
RETURNS TABLE(member_name VARCHAR, bike_model VARCHAR, days INT, amount_owed NUMERIC, status VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT m.full_name,
           b.model,
           (COALESCE(r.end_date, CURRENT_DATE) - r.start_date)::INT,
           ROUND((COALESCE(r.end_date, CURRENT_DATE) - r.start_date) * b.daily_rate, 2),
           (CASE WHEN r.end_date IS NULL THEN 'OPEN' ELSE 'CLOSED' END)::VARCHAR
    FROM rentals r
    JOIN members m ON r.member_id = m.member_id
    JOIN bikes b ON r.bike_id = b.bike_id
    WHERE r.rental_id = p_rental_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM rental_invoice(11);
SELECT * FROM rental_invoice(19);
-- Yes, rental 11 calculates 8 * 9.25 = 74.00 matching the stored fee; rental 19 changes daily because COALESCE(r.end_date, CURRENT_DATE) grows each day, so the function cannot be IMMUTABLE (it must be STABLE) because its output depends on the current date rather than solely its input arguments.

--7.4
CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR)
RETURNS TABLE(member_cnt INT, rental_cnt INT, total_revenue NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(DISTINCT m.member_id)::INT,
           COUNT(r.rental_id)::INT,
           COALESCE(SUM(r.fee), 0)
    FROM members m
    LEFT JOIN rentals r ON m.member_id = r.member_id
    WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR, p_from_date DATE)
RETURNS TABLE(member_cnt INT, rental_cnt INT, total_revenue NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(DISTINCT m.member_id)::INT,
           COUNT(r.rental_id)::INT,
           COALESCE(SUM(r.fee), 0)
    FROM members m
    LEFT JOIN rentals r ON m.member_id = r.member_id AND r.start_date >= p_from_date
    WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM city_report('Almaty');
SELECT * FROM city_report('Almaty', DATE '2025-01-01');
-- The date filter belongs in the ON clause; putting it in ON preserves members with no qualifying rentals (giving Almaty 3 members), whereas putting r.start_date >= p_from_date in WHERE filters out NULL-matched rows, turning the LEFT JOIN into an INNER JOIN and dropping Elena Petrova (Almaty becomes 2 members).

--1 A function's name is just its identifier (e.g. total_fees), while its signature is the name plus the ordered list of input argument data types; PostgreSQL requires the signature to drop an overloaded function so it knows which specific overload to remove.
--2 Dollar quoting ($$ ... $$) avoids escaping single quotes inside function bodies; for example, a dynamic query string like EXECUTE 'SELECT * FROM members WHERE city = ''Almaty''' becomes clean without doubled quotes inside $$.
--3 Choose several OUT parameters when returning a single row of multiple values (like scalar stats), and choose RETURNS TABLE when returning zero, one, or many rows from a query result set.
--4 VARIADIC must be last because it consumes a variable number of trailing arguments into an array; if another parameter followed it, e.g. f(VARIADIC a INT[], b INT), a call f(1, 2, 3) would be ambiguous as to whether 3 belongs to a or b.
--5 RETURN exits the function immediately (returning a scalar value if applicable), whereas RETURN QUERY appends the result set of a SELECT statement to the function's output table without terminating execution immediately.
--6 Adding a DEFAULT parameter creates an additional effective call signature with fewer arguments that can collide with an existing function having that exact parameter list; avoid this in production by keeping a single function with defaults rather than overloading the same prefix, or by naming functions distinctly.
--7 When a subblock ends, its local variables are destroyed and go out of scope; an outer variable shadowed by a subblock variable can still be read inside the subblock by qualifying it with the outer block's label (e.g. outer_label.var_name).
--8 Advantage: centralizes business logic in the DB so all clients enforce the exact same rule with fewer network round trips; Disadvantage: harder to version-control/unit-test and shifts CPU load onto the database server.
--9 Trusted languages (PL/pgSQL) cannot access the OS filesystem, network, or external processes so any regular user with CREATE privileges can use them, whereas untrusted languages (PL/Python) have full OS access and can only be used by superusers.
--10 CREATE OR REPLACE FUNCTION with different argument types does not replace the original function—it creates a second overloaded function with a new signature, which can leave stale versions behind and cause ambiguous function call errors.