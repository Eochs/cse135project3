
--------------------------------------------------------------------------------------------
-- *********  user view **********
--------------------------------------------------------------------------------------------
-- case 0,0
-- state:off, category:off

DROP TABLE IF EXISTS temp1; 
CREATE TABLE temp1 (u_rank SERIAL PRIMARY KEY, uid INT); 
INSERT INTO temp1(uid) select pua.uid from pc_UsersAmt as pua order by pua.total desc limit 20; 

DROP TABLE IF EXISTS temp2; 
CREATE TABLE temp2 (p_Rank SERIAL PRIMARY KEY, pid INT); 
INSERT INTO temp2(pid) select ppa.pid from pc_ProdAmt as ppa order by ppa.total desc limit 10; 

DROP TABLE IF EXISTS temp3; CREATE TABLE temp3 (t_rank SERIAL PRIMARY KEY, uid INT, pid INT); INSERT INTO temp3(uid, pid) select t1.uid, t2.pid from temp1 as t1, temp2 as t2;

select t3.t_rank, t3.uid, t3.pid, coalesce(pc_UserProdAmt.total,0) as total
from temp3 as t3
left outer join pc_UserProdAmt on t3.uid = pc_UserProdAmt.uid
AND t3.pid = pc_UserProdAmt.pid
order by t3.t_rank;


-- case 1,0
-- state:on, category:off


DROP TABLE IF EXISTS temp1; 
CREATE TABLE temp1 (u_rank SERIAL PRIMARY KEY, uid INT); 
INSERT INTO temp1(uid) select pua.uid from pc_UsersAmt as pua
                       WHERE pua.uid IN (select * from users where users.state = ?)
                       order by pua.total desc limit 20; 

-- slow as fuck version
/*
DROP TABLE IF EXISTS temp2; 
CREATE TABLE temp2 (p_Rank SERIAL PRIMARY KEY, pid INT); 
INSERT INTO temp2(pid) select ppa.pid from pc_ProdAmt as ppa 
                       WHERE ppa.pid = pc_UserProdAmt.pid AND pc_UserProdAmt.uid = users.id
                       AND users.state = ?
                       order by ppa.total desc limit 10; 
*/

-- make new precomputed table with users, states, and products in one.
/*
DROP TABLE IF EXISTS pc_UserStateProdCatAmt;
CREATE TABLE pc_UserStateProdCatAmt (
	uid	INT,
        state   TEXT,
	pid	INT,
        cid     INT,
	total	INT
);

INSERT INTO pc_UserStateProdCatAmt 
SELECT users.id, users.state, products.id, products.cid, SUM(sales.quantity*sales.price) 
FROM sales, users, products 
WHERE sales.uid = users.id AND sales.pid = products.id
GROUP BY users.id, state, products.id, products.cid;
*/
-- fast as fuck version
DROP TABLE IF EXISTS temp2; 
CREATE TABLE temp2 (p_Rank SERIAL PRIMARY KEY, pid INT); 
INSERT INTO temp2(pid) select ppa.pid from pc_ProdAmt as ppa, pc_UserStateProdCatAmt 
                       WHERE ppa.pid = pc_UserStateProdCatAmt.pid AND pc_UserStateProdCatAmt.state = ?
                       order by ppa.total desc limit 10; 

DROP TABLE IF EXISTS temp3; CREATE TABLE temp3 (t_rank SERIAL PRIMARY KEY, uid INT, pid INT); INSERT INTO temp3(uid, pid) select t1.uid, t2.pid from temp1 as t1, temp2 as t2;

select t3.t_rank, t3.uid, t3.pid, coalesce(pc_UserProdAmt.total,0) as total
from temp3 as t3
left outer join pc_UserStateProdCatAmt on t3.uid = pc_UserStateProdCatAmt.uid
AND t3.pid = pc_UserStateProdCatAmt.pid AND pc_UserStateProdCatAmt.state = ?
order by t3.t_rank;


-- case 1 1
-- state:on, category:on

DROP TABLE IF EXISTS temp1; 
CREATE TABLE temp1 (u_rank SERIAL PRIMARY KEY, uid INT); 
INSERT INTO temp1(uid) select pua.uid from pc_UsersAmt as pua
                       WHERE pua.uid = pc_UserStateProdCatAmt.uid 
                         AND pc_UserStateProdCatAmt.state = ? 
                         AND pc_UserStateProdCatAmt.cid = ?
                       order by pua.total desc limit 20; 

DROP TABLE IF EXISTS temp2; 
CREATE TABLE temp2 (p_Rank SERIAL PRIMARY KEY, pid INT); 
INSERT INTO temp2(pid) select ppa.pid from pc_ProdAmt as ppa 
                       WHERE ppa.pid = pc_UserStateProdCatAmt.pid 
                         AND pc_UserStateProdCatAmt.state = ?
                         AND pc_UserStateProdCatAmt.cid = ?
                       order by ppa.total desc limit 10; 

DROP TABLE IF EXISTS temp3; CREATE TABLE temp3 (t_rank SERIAL PRIMARY KEY, uid INT, pid INT); INSERT INTO temp3(uid, pid) select t1.uid, t2.pid from temp1 as t1, temp2 as t2;

select t3.t_rank, t3.uid, t3.pid, coalesce(pc_UserProdAmt.total,0) as total
from temp3 as t3
left outer join pc_UserStateProdCatAmt on t3.uid = pc_UserStateProdCatAmt.uid
AND t3.pid = pc_UserStateProdCatAmt.pid 
AND pc_UserStateProdCatAmt.cid = ?   -- necessary? or are they already limited to cid and state?
AND pc_UserStateProdCatAmt.state = ? -- check if taking off lines changes speed or results
order by t3.t_rank;


---------------------------------------------------------------------------------------------
-- ************* state view **************
----------------------------------------------------------------------------------------------

-- case 0,0
-- state:off, category:off

DROP TABLE IF EXISTS temp1; 
CREATE TABLE temp1 (u_rank SERIAL PRIMARY KEY, sid INT); 
INSERT INTO temp1(sid) select states.id from states, pc_StateAmt as psa 
                         WHERE states.name = psa.state order by psa.total desc limit 20; 

DROP TABLE IF EXISTS temp2; 
CREATE TABLE temp2 (p_Rank SERIAL PRIMARY KEY, pid INT); 
INSERT INTO temp2(pid) select pspa.pid from pc_StateProdAmt as pspa order by pspa.total desc limit 10; 

DROP TABLE IF EXISTS temp3; CREATE TABLE temp3 (t_rank SERIAL PRIMARY KEY, sid INT, pid INT); INSERT INTO temp3(sid, pid) select t1.sid, t2.pid from temp1 as t1, temp2 as t2;

select t3.t_rank, t3.sid, t3.pid, coalesce(pc_StateProdAmt.total,0) as total
from temp3 as t3 join states on t3.sid = states.id
left outer join pc_StateProdAmt on states.name = pc_StateProdAmt.state
AND t3.pid = pc_StateProdAmt.pid
order by t3.t_rank;


-- case 1,0
-- state:on, category:off

DROP TABLE IF EXISTS temp1; 
CREATE TABLE temp1 (u_rank SERIAL PRIMARY KEY, sid INT); 
INSERT INTO temp1(sid) select states.id from states, pc_StateAmt as psa 
                       WHERE states.name = psa.state AND states.name = ?
                       order by psa.total desc limit 20; 

DROP TABLE IF EXISTS temp2; 
CREATE TABLE temp2 (p_Rank SERIAL PRIMARY KEY, pid INT); 
INSERT INTO temp2(pid) select pspa.pid from pc_StateProdAmt as pspa, states 
                       where states.name = pspa.state and states.name = ?
                       order by pspa.total desc limit 10; 

DROP TABLE IF EXISTS temp3; 
CREATE TABLE temp3 (t_rank SERIAL PRIMARY KEY, sid INT, pid INT); INSERT INTO temp3(sid, pid) select t1.sid, t2.pid from temp1 as t1, temp2 as t2;

select t3.t_rank, t3.sid, t3.pid, coalesce(pc_StateProdAmt.total,0) as total
from temp3 as t3 join states on t3.sid = states.id
left outer join pc_StateProdAmt on states.name = pc_StateProdAmt.state
AND t3.pid = pc_StateProdAmt.pid
order by t3.t_rank;


-- case 0,1
-- state:off, category:on

DROP TABLE IF EXISTS temp1; 
CREATE TABLE temp1 (u_rank SERIAL PRIMARY KEY, sid INT); 
INSERT INTO temp1(sid) select states.id from states, products, pc_StateCatAmt as psca 
                       WHERE states.name = psca.state 
                       AND products.cid = psca.cid AND psca.cid = ?
                       order by psca.total desc limit 20; 

DROP TABLE IF EXISTS temp2; 
CREATE TABLE temp2 (p_Rank SERIAL PRIMARY KEY, pid INT); 
INSERT INTO temp2(pid) select products.pid from products, pc_StateCatAmt as psca 
                       WHERE products.cid = psca.cid AND psca.cid = ?
                       order by psca.total desc limit 10; 

DROP TABLE IF EXISTS temp3; 
CREATE TABLE temp3 (t_rank SERIAL PRIMARY KEY, sid INT, pid INT); INSERT INTO temp3(sid, pid) select t1.sid, t2.pid from temp1 as t1, temp2 as t2;

select t3.t_rank, t3.sid, t3.pid, coalesce(pc_StateCatAmt.total,0) as total
from products join temp3 as t3 on products.id = t3.pid 
left outer join pc_StateCatAmt on products.cid = pc_StateCatAmt.cid and pc_StateCatAmt.cid = ?
order by t3.t_rank;


-- case 1,1
-- state:on, category:on

DROP TABLE IF EXISTS temp1; 
CREATE TABLE temp1 (u_rank SERIAL PRIMARY KEY, sid INT); 
INSERT INTO temp1(sid) select states.id from states, pc_StateCatAmt as psca 
                       WHERE states.name = psca.state AND states.name = ?
                       order by psca.total desc limit 20; 

DROP TABLE IF EXISTS temp2; 
CREATE TABLE temp2 (p_Rank SERIAL PRIMARY KEY, pid INT); 
INSERT INTO temp2(pid) select pspa.pid from pc_StateCatAmt as psca, states, products 
                       where states.name = psca.state 
                       and psca.cid = products.cid
                       and psca.cid = ?
                       and states.name = ?
                       order by pspa.total desc limit 10; 

DROP TABLE IF EXISTS temp3; 
CREATE TABLE temp3 (t_rank SERIAL PRIMARY KEY, sid INT, pid INT); INSERT INTO temp3(sid, pid) select t1.sid, t2.pid from temp1 as t1, temp2 as t2;

select t3.t_rank, t3.sid, t3.pid, coalesce(pc_StateProdAmt.total,0) as total
from temp3 as t3 join states on t3.sid = states.id
left outer join pc_StateProdAmt on states.name = pc_StateProdAmt.state
AND t3.pid = pc_StateProdAmt.pid
order by t3.t_rank;
