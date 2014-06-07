

-- precomputed tables for users analysis

-- *** filters: all ***

-- Big table with all user product pairings
CREATE TABLE pc_BigUsers (
  uid INT, --id of user
  uname TEXT,
  pid INT, -- id of product
  pname TEXT,
  use_prod_amt INT -- amount * price at the time of sale
);
INSERT INTO pc_BigUsers
SELECT users.id, users.name, products.id, products.name,
       COALESCE(sales.quantity * sales.price, 0) AS use_prod_amt
FROM users LEFT OUTER JOIN sales ON users.id = sales.uid
     RIGHT OUTER JOIN products ON sales.pid = products.id ;

-- top 20 users as ranked by amount spent by that user
CREATE TABLE pc_Users (
  uid INT,
  name TEXT,
  use_amt INT
);
INSERT INTO pc_Users
SELECT users.id, users.name, COALESCE(SUM(sales.quantity * sales.price), 0) AS use_amt
FROM users LEFT OUTER JOIN sales ON users.id = sales.uid
GROUP BY users.id, users.name ORDER BY use_amt DESC LIMIT 20; 

-- top 10 products as ranked by amount spent on that product
CREATE TABLE pc_Prod (
  pid INT,
  name TEXT,
  prod_amt INT
);
INSERT INTO pc_Prod
SELECT products.id, products.name, COALESCE(sum(sales.quantity * sales.price), 0) AS prod_amt
FROM products LEFT OUTER JOIN sales ON products.id = sales.pid
GROUP BY products.id, products.name ORDER BY prod_amt DESC LIMIT 10; 

-- precomputed table of top 20 users and top 10 products to fill cell values 
CREATE TABLE pc_CustomersAll (
  uid INT,
  uname TEXT,
  pid INT,
  pname TEXT,
  user_x_prod_amt INT
);
INSERT INTO pc_CustomersAll
SELECT * FROM pc_BigUsers
WHERE pc_BigUsers.uid 
      IN (SELECT pc_Users.uid FROM pc_Users
          ORDER BY pc_Users.use_amt LIMIT 20)
  AND pc_BigUsers.pid
      IN (SELECT pc_Prod.pid FROM pc_Prod
          ORDER BY pc_Prod.prod_amt LIMIT 10)
ORDER BY use_prod_amt
;

-- precomputed tables for states analysis
-- need to run states.sql to get states table


-- *** filters: all ***

CREATE TABLE pc_BigStates (
  sid INT, --id of user
  sname TEXT,
  pid INT, -- id of product
  pname TEXT,
  state_prod_amt INT -- amount * price at the time of sale
);
INSERT INTO pc_BigStates
SELECT states.id, states.name, products.id, products.name,
       COALESCE(sales.quantity * sales.price, 0) AS amt
FROM states LEFT OUTER JOIN users ON states.name = users.state
     LEFT OUTER JOIN sales ON users.id = sales.uid
     JOIN products ON sales.pid = products.id ;




