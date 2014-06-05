

-- precomputed tables for users analysis

-- *** filters: all ***

-- Big table with all user product pairings
CREATE TABLE pc_Big (
  uid INT, --id of user
  uname TEXT,
  pid INT, -- id of product
  pname TEXT,
  use_prod_amt INT -- amount * price at the time of sale
);
INSERT INTO pc_Big
SELECT users.id, users.name, products.id, products.name,
       COALESCE(sales.quantity * sales.price, 0) AS amt
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
SELECT * FROM pc_Big
WHERE pc_Big.uid 
      IN (SELECT pc_Users.id FROM pc_Users
          ORDER BY pc_Users.use_amt LIMIT 20;)
  AND pc_Big.pid
      IN (SELECT pc_Prod.pid FROM pc_Prod
          ORDER BY pc_Prod.prod_amt LIMIT 10;)


-- precomputed tables for states analysis

-- filters: all




