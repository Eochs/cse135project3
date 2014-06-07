-- "first precomputation program"

-- create the precomputed tables and insert data from the database
-- project requirements:
-- 1) CREATE TABLE all the precomputed tables of the lattice.
-- 2) Load the precomputed tables with the appropriate data, via
-- INSERT commands. In particular, given the Sales table, write a
-- “first precomputation” program that will insert data in the
-- precomputed tables efficiently.

-- Create big table with all columns (at bottom of the lattice)
-- users, products, amt

-- test

DROP TABLE IF EXISTS pc_Big;
DROP TABLE IF EXISTS pc_StateProd;
DROP TABLE IF EXISTS pc_UseCat;
DROP TABLE IF EXISTS pc_StateCat;
DROP TABLE IF EXISTS pc_Users;
DROP TABLE IF EXISTS pc_Prod;
DROP TABLE IF EXISTS pc_All;
DROP TABLE IF EXISTS pc_state;
DROP TABLE IF EXISTS pc_cat;
DROP TABLE IF EXISTS pc_Users_Limit;
DROP TABLE IF EXISTS pc_Prod_Limit;

CREATE TABLE pc_Big (
  uid INT, --id of user
  pid INT, -- id of product
  use_prod_amt INT -- amount * price at the time of sale
);

/*
INSERT INTO pc_Big
SELECT users.id, products.id, sales.quantity * sales.price AS amt
FROM users, products, sales
WHERE users.id = sales.uid
AND sales.pid = products.id ;
*/
INSERT INTO pc_Big
SELECT users.id, products.id, COALESCE(sales.quantity * sales.price, 0) AS amt
FROM (users LEFT OUTER JOIN sales ON users.id = sales.uid) 
     RIGHT OUTER JOIN products ON sales.pid = products.id ;


-- state, products
CREATE TABLE pc_StateProd (
  st_name TEXT,
  prod_id INT,
  st_prod_amt INT
);



/*
INSERT INTO pc_StateProd
SELECT users.state, pc_Big.pid, SUM(pc_Big.use_prod_amt)
FROM users, pc_Big
WHERE users.id = pc_Big.uid
GROUP BY users.state, pc_Big.pid;
*/
INSERT INTO pc_StateProd
SELECT users.state, products.id, COALESCE(sum(sales.quantity * sales.price), 0)
FROM users
LEFT OUTER JOIN sales ON users.id = sales.uid
RIGHT OUTER JOIN products ON sales.pid = products.id
GROUP BY users.state, products.id;

-- users, categories
CREATE TABLE pc_UseCat (
  uid INT,
  cid INT,
  use_cat_amt INT
);

INSERT INTO pc_UseCat
SELECT pc_Big.uid, products.cid, SUM(pc_Big.use_prod_amt)
FROM products, pc_Big
WHERE products.id = pc_Big.pid
GROUP BY pc_Big.uid, products.cid;

-- state, categories
CREATE TABLE pc_StateCat (
  st_name TEXT,
  cid INT,
  st_cat_amt INT
);

INSERT INTO pc_StateCat
SELECT pc_StateProd.st_name, products.cid, SUM(pc_StateProd.st_prod_amt)
FROM products, pc_StateProd -- use StateProd since O(50k rows) vs UseCat with O(200k rows)
WHERE pc_StateProd.prod_id = products.id -- join to get categories
GROUP BY pc_StateProd.st_name, products.cid; -- should work


-- users
CREATE TABLE pc_Users (
  uid INT,
  name TEXT,
  use_amt INT
);

/*INSERT INTO pc_Users
SELECT pc_UseCat.uid, SUM(pc_UseCat.use_cat_amt)
FROM pc_UseCat
GROUP BY pc_UseCat.uid -- sum over categories
LIMIT 20;*/

INSERT INTO pc_Users
SELECT users.id, users.name, COALESCE(sum(sales.quantity * sales.price), 0) as use_amt
FROM users left outer join sales 
on sales.uid = users.id 
group by users.id 
order by use_amt desc;

-- new temp for row header names and sums
CREATE TABLE pc_Users_Limit (
  uid INT,
  name TEXT,
  use_amt INT
);

INSERT INTO pc_Users_Limit
SELECT pc_UseCat.uid, users.name, SUM(pc_UseCat.use_cat_amt) AS use_amt
FROM pc_UseCat, users
WHERE pc_UseCat.uid = users.id
GROUP BY pc_UseCat.uid, users.name -- sum over categories
ORDER BY use_amt DESC LIMIT 20;


-- products
CREATE TABLE pc_Prod (
  pid INT,
  name TEXT,
  prod_amt INT
);

INSERT INTO pc_Prod
SELECT products.id, products.name, COALESCE(sum(sales.quantity * sales.price), 0) AS prod_amt
FROM products LEFT OUTER JOIN sales ON products.id = sales.pid
GROUP BY products.id ORDER BY prod_amt DESC;

/*INSERT INTO pc_Prod
SELECT pc_StateProd.prod_id, SUM(pc_StateProd.st_prod_amt)
FROM pc_StateProd
GROUP BY pc_StateProd.prod_id; -- sum over states*/

-- new temp for col header names
CREATE TABLE pc_Prod_Limit (
  pid INT,
  name TEXT,
  prod_amt INT
);

INSERT INTO pc_Prod_Limit
SELECT pc_StateProd.prod_id, products.name, SUM(pc_StateProd.st_prod_amt) as prod_amt
FROM pc_StateProd, products
WHERE pc_StateProd.prod_id = products.id
GROUP BY pc_StateProd.prod_id, products.name -- sum over states
ORDER BY prod_amt DESC LIMIT 10;



-- state
CREATE TABLE pc_State (
  st_name TEXT,
  st_amt INT
);

INSERT INTO pc_State
SELECT pc_StateCat.st_name, SUM(pc_StateCat.st_cat_amt)
FROM pc_StateCat
GROUP BY pc_StateCat.st_name; -- sum over categories


-- categories
CREATE TABLE pc_Cat (
  cid INT,
  cat_amt INT
);

INSERT INTO pc_Cat
SELECT pc_StateCat.cid, SUM(pc_StateCat.st_cat_amt)
FROM pc_StateCat
GROUP BY pc_StateCat.cid; -- sum over states


-- all
CREATE TABLE pc_All (
  all_amt INT
);

INSERT INTO pc_All
SELECT SUM(pc_Cat.cat_amt)
FROM pc_Cat;
-- chose sum over categories since 20 categories < 50 states
-- if number of categories gets > 50 would switch to using pc_State

DROP TABLE IF EXISTS new_table; 
/*I need the top 20 users from pc_users and the top 10 products from pc_Prod instead of from users and products*/
CREATE TABLE new_table as (select users.id as uid, products.id as pid, pc_users.use_amt as total 
                           from users, products, pc_users 
                           WHERE users.id = pc_users.uid 
                           group by users.id, pid, pc_users.use_amt);


DROP TABLE IF EXISTS pc_trent; 
CREATE TABLE pc_trent as (select n.uid, n.pid, n.total, coalesce(sum(sales.price * sales.quantity), 0) 
                          from new_table as n 
                          left outer join sales 
                          on n.uid = sales.uid 
                          and n.pid = sales.pid 
                          group by n.uid, n.pid, n.total 
                          order by n.total, n.uid, n.pid);


