-- update code

-- have userID, role, name (product name), quanitity, price, amount_price (quantity*price), 
--   don't need total_price 

-- get result set from cart before we delete it

	ResultSet rs=null;
	SQL="select u.id, u.name, u.state, p.id, p.name, p.cid, c.quantity, c.price from products p, users u, carts c where c.uid=u.id and c.pid=p.id and c.uid="+userID;
	rs=stmt.executeQuery(SQL);
	
	
        int uid = 0;
        String state=null;
        int pid=0;
        int cid=0;
	int quantity=0;
	float price=0, amount_price=0;
	while(rs.next())
	{
		uid=rs.getInt(1);      //user
                uname=rs.getString(2);
                state=rs.getString(3);
                pid=rs.getInt(4);      //product
                pname=rs.getString(5);
		cid=rs.getInt(6);      //category
		quantity=rs.getInt(7);
		price=rs.getInt(8);
		amount_price=quantity*price;
   
                -- update each table

        }

        -- delete values from cart


-- update pc_Prods
-- update by summing product amount in cart with amount in pc_prods by pid
-- select all from rs

-- need if statements to check if product doesn't exist then do insert
--if(SELECT EXISTS(SELECT 1 FROM table1 WHERE ...id = ...id) {/*update*/} else {/*insert*/} 

-- UPDATE images SET counter=counter+1 WHERE image_id=15

-- update 
UPDATE pc_ProdAmt SET total = total + "+amount_price+" WHERE pid="+pid;

-- insert _.get(i)
INSERT INTO pc_ProdAmt VALUES ("+pid.get(i)+", (SELECT p.name FROM products AS p WHERE p.id = "+pid.get(i)+" LIMIT 1) , "+total.get(i)+");

-- insert simpler
INSERT INTO pc_ProdAmt VALUES ("+pid.get(i)+", "+pname.get(i)+", "+total.get(i)+");


-- update pc_Users
UPDATE pc_UsersAmt SET total = total + "+amount_price+" WHERE uid="+uid;

-- insert pc_Users
INSERT INTO pc_UsersAmt VALUES ("+userID+", "+uName+", "+total.get(i)+");


-- update pc_StateAmt
UPDATE pc_StateAmt SET total = total + "+amount_price+" WHERE state="+state;

-- insert pc_State
INSERT INTO pc_StateAmt VALUES ("+state.get(i)+", "+total.get(i)+");


-- update pc_UserProdAmt
UPDATE pc_UserProdAmt SET total = total + "+amount_price+" WHERE uid="+uid+" AND pid="+pid;

-- insert pc_UserProdAmt
INSERT INTO pc_UserProdAmt VALUES ("+userID+", "+pid.get(i)+", "+total.get(i)+");


-- update pc_UseCatAmt
UPDATE pc_UseCatAmt SET total = total + "+amount_price+" WHERE uid="+uid+" AND cid="+cid;

-- insert pc_UseCatAmt
INSERT INTO pc_UseCatAmt VALUES ("+userID+", "+uName+", "+cid.get(i)+", "+total.get(i)+");


-- update pc_StateProdAmt
UPDATE pc_StateProdAmt SET total = total + "+amount_price+" WHERE state="+state+" AND pid="+pid;

-- insert pc_StateProdAmt
INSERT INTO pc_StateProdAmt VALUES ("+state.get(i)+", "+cid.get(i)+", "+total.get(i)+");


-- update pc_StateCatAmt
UPDATE pc_StateCatAmt SET total = total + "+amount_price+" WHERE state="+state+" AND cid="+cid;

-- insert pc_StateCatAmt
INSERT INTO pc_StateCatAmt VALUES ("+state.get(i)+", "+cid.get(i)+", "+total.get(i)+");









