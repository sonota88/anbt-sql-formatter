-- 1-01
SELECT col1 FROM table1 AS t1 WHERE col1>'値 \"value'
;

--------------------------------
-- 1-02
SELECT 列1 AS col1,col列2 AS 列2col
 FROM 日本語表名1 AS t1, table日本語2 as t2
;

--------------------------------
-- 1-03
SELECT \tcol1 FROM table1 AS t1\tWHERE col1 = '値 \t\"value'
;

--------------------------------
-- 1-04
SELECT col1 FROM table1 AS t1 WHERE col1<='値 \"value'
;

--------------------------------
-- 1-05
SELECT col1 FROM table1 AS t1 WHERE col1>='値 \"値2'
;

--------------------------------
-- 1-06
SELECT t1.col1,t1.col2,col3 FROM table1 AS t1 WHERE col1>='値' GROUP\n BY col1
;

--------------------------------
-- 1-07
truncate table table1
;

--------------------------------
-- 1-08
drop table table1,table2
;

--------------------------------
-- 1-09
    CREATE TABLE table1 (colID DECIMAL( 10),name    CHAR VARYING(40),PRIMARY KEY(colID)        ); 

--------------------------------
-- 2-01
SELECT col1 FROM table1 AS t1 WHERE col1>'値 \"value' ; SELECT col1 FROM table1 AS t1 WHERE col1>'値 \"value'
;

--------------------------------
-- 2-02
select uriage * 0.05 as 消費税 from 台帳
;

--------------------------------
-- 2-03
select user_name from 得意先 where kaisya_name like '日本%'
;

--------------------------------
-- 2-04
select user_name || 'さん' as 継承付名称 from 得意先
;

--------------------------------
-- 2-05
select a,b from (select a,b from table1 where user_cd = '0123' union select a,b from table1 where user_cd = '0122') where zip_code = '105'
;

--------------------------------
-- 2-06
select user_name || 'さん' as 継承付名称 from 得意先\n
;

--------------------------------
-- 3-01
select a,b from (select a,b from table1 where user_cd = '0123
;
--'
--------------------------------
-- 3-02
select a,b from (select a,b from "table1 where user_cd = '0123'

--"
;
--------------------------------
-- 3-03
INSERT INTO table1 VALUES (1000,'ABC',256
;

--------------------------------
-- 4-01
SELECT a ,avg (b * case when c is null then 0 else c End) from t1 left outer join s Using (a) group by e
;

--------------------------------
-- 4-02
SELECT a ,MAX (b) FROM table_c GROUP BY a having MAX (b) > 10
;

--------------------------------
-- 関数、引数 1つ
max(a)
;

--------------------------------
-- 関数、引数 2つ
max(a,b)
;

--------------------------------
-- 関数でない、引数 1つ
foobar(a)
;

--------------------------------
-- 関数でない、引数 2つ
foobar(a,b)
;

--------------------------------
-- {schema}.{table}, {table}.{column}
select t1.a, `t2`.`b`, "t3"."c"
from schema.t1, `schema`.`t2`, "schema"."t3"
