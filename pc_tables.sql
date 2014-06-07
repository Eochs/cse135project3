
DROP TABLE pc_UsersAmt;
CREATE TABLE pc_UsersAmt (
	uid	INT,
        name    TEXT,
	total	INT
);

INSERT INTO pc_UsersAmt
SELECT u.id, u.name, SUM(s.quantity*s.price)
FROM sales s, users u 
WHERE s.uid = u.id
GROUP BY u.id, u.name;

DROP TABLE pc_ProdAmt;
CREATE TABLE pc_ProdAmt (
	pid	INT,	
        name    TEXT,
	total	INT
);

INSERT INTO pc_ProdAmt 
SELECT p.id, p.name, SUM(s.quantity*s.price) 
FROM sales s,products p
WHERE s.pid = p.id
GROUP BY p.id, p.name;

DROP TABLE pc_StateAmt;
CREATE TABLE pc_StateAmt (
	state	TEXT,
	total	INT
);

INSERT INTO pc_StateAmt 
SELECT st.name, SUM(s.quantity*s.price) 
FROM sales s, states st, users u
WHERE st.name = u.state
AND u.id = s.uid 
GROUP BY st.name;

DROP TABLE pc_UserProdAmt;
CREATE TABLE pc_UserProdAmt (
	uid	INT,
	pid	INT,
	total	INT
);

INSERT INTO pc_UserProdAmt 
SELECT uid, pid, SUM(quantity*price) 
FROM sales GROUP BY uid, pid;

DROP TABLE pc_UseCatAmt;
CREATE TABLE pc_UseCatAmt (
	uid	INT,
        name    TEXT,
	cid	INT,
	total	INT
);

INSERT INTO pc_UseCatAmt 
SELECT s.uid, u.name, c.id, SUM(s.quantity*s.price) 
FROM sales s, categories c, products p, users u 
WHERE  c.id = p.cid
AND s.pid = p.id
AND s.uid = u.id
GROUP BY s.uid, u.name, c.id;

DROP TABLE pc_StateProdAmt;
CREATE TABLE pc_StateProdAmt (
	state 	TEXT,
	pid	INT,
	total	INT
);

INSERT INTO pc_StateProdAmt
SELECT st.name, p.id, SUM(s.quantity*s.price) 
FROM sales s, states st, products p, users u 
WHERE  st.name = u.state
AND s.pid = p.id
AND s.uid = u.id
GROUP BY st.name, p.id;

DROP TABLE pc_StateCatAmt;
CREATE TABLE pc_StateCatAmt (
	state 	TEXT,
	cid	INT,
	total	INT
);

INSERT INTO pc_StateCatAmt 
SELECT st.name, c.id, SUM(s.quantity*s.price) 
FROM sales s, states st, products p, users u, categories c 
WHERE  st.name = u.state
AND s.pid = p.id
AND s.uid = u.id
AND p.cid = c.id
GROUP BY st.name, c.id;
