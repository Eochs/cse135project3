-- users

-- state 0, category 1
SELECT pc.uid, pc.name FROM pc_UseCat as pc
WHERE pc.cid = ? -- value from c_id

