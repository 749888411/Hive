1	Hive常用函数
1.1	Hive时间函数
select from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss');
select from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm');
select from_unixtime(unix_timestamp(),'yyyy-MM-dd HH');
select from_unixtime(unix_timestamp(),'yyyy-MM-dd');
select from_unixtime(unix_timestamp('20210308','yyyyMMdd'),'yyyy-MM-dd');
select from_unixtime(unix_timestamp('2021-03-08','yyyy-MM-dd'),'yyyy-MM-dd');

select
--将number类型转换成date型,相当于to_date(20201001,'yyyymmdd')
from_unixtime(to_unix_timestamp(substr(PLAN_TIME,1,8),'yyyyMMdd'),'yyyy-MM-dd');
1、from_unixtime(to_unix_timestamp(‘2021-03-08’,’yyyy-MM-dd’),’yyyy-MM-dd’);
2、from_unixtime(to_unix_timestamp(‘20210308’,’yyyyMMdd’),’yyyy-MM-dd’);
3、from_unixtime(to_unix_timestamp(‘2021-03-08’,’yyyyMMdd’),’yyyy-MM-dd’);
注意:上面返回的值 第1条语句 = 第2条语句 <> 第3条语句，因为第3条时间和转换格式不一样。

时间同周期转换: 两个时间差的天数，然后除以7，取余数，然后减去余数。
SELECT
--将时间20200622转成和2020-05-22同星期的星期5
date_sub(from_unixtime(unix_timestamp('20200622','yyyyMMdd') ,'yyyy-MM-dd'), pmod(datediff(from_unixtime(unix_timestamp('20200622','yyyyMMdd') ,'yyyy-MM-dd'),'2020-05-22'),7)) AS X1,

--将时间20200622转成和2020-05-21同星期的星期4
date_sub(from_unixtime(unix_timestamp('20200622','yyyyMMdd') ,'yyyy-MM-dd'), pmod(datediff(from_unixtime(unix_timestamp('20200622','yyyyMMdd') ,'yyyy-MM-dd'),'2020-05-21'),7)) AS X2,

--将时间20200622转成和2020-05-18同星期的星期1
date_sub(from_unixtime(unix_timestamp('20200622','yyyyMMdd') ,'yyyy-MM-dd'), pmod(datediff(from_unixtime(unix_timestamp('20200622','yyyyMMdd') ,'yyyy-MM-dd'),'2020-05-18'),7)) AS X3
;
判断是否周一：
PMOD(DATEDIFF(FROM_UNIXTIME(UNIX_TIMESTAMP(substr(replace('DPS_WK20201103_1730','WK',''),5,8),'yyyyMMdd') ,'yyyy-MM-dd'), '2020-08-02'), 7)=1

select unix_timestamp(),
       from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss'),
       from_unixtime(unix_timestamp(),'yyyyMMddHHmmss'),
       year(from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss')),
       month(from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss')),
       day(from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss')),
       weekofyear(from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss')),
       hour(from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss')),
       minute(from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss')),
       second(from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss')),
       datediff('2020-01-01','2020-08-01'),
       date_add('2020-01-01',10),
       date_sub('2020-01-01',10),
       to_date('2020-01-08 14:30:40'),
       date_sub('2020-11-05',cast(date_format('2020-11-05','u') as int)-1),--转成周一
       date_sub(next_day(CURRENT_DATE,'MO'),7), --转成周一
       date_format('2021-03-09','u'), 返回星期几
       cast(date_format('2021-03-08','u') as int)-1, --返回：星期几减1; 如果2021-03-08是礼拜1，返回0 --
       date_add(date_sub('2020-11-05',cast(date_format('2020-11-05','u') as int)-1),6) as x2,--转成周日
       --转成两年后的周日
       date_add(date_sub(CONCAT(CAST(SUBSTR('2020-11-05',1,4)+2 AS INT),'-',SUBSTR('2020-11-05',6,5)),cast(date_format(CONCAT(CAST(SUBSTR('2020-11-05',1,4)+2 AS INT),'-',SUBSTR('2020-11-05',6,5)),'u') as int)-1),6)
;
注意:周几的表示方法：
next_day函数：和指定的时间有关，如果指定的时间是礼拜２，那么该周从礼拜３到礼拜日都对应的还是该周。但是礼拜１，礼拜２是下周。
如果CURRENT_DATE是周二：返回值如下：
select date_sub(next_day(CURRENT_DATE,'MO'),7),--本周一
       date_sub(next_day(CURRENT_DATE,'TU'),7), --本周二
       date_sub(next_day(CURRENT_DATE,'WE'),7), --上周三
       date_sub(next_day(CURRENT_DATE,'TH'),7), --上周四
       date_sub(next_day(CURRENT_DATE,'FR'),7), --上周五
       date_sub(next_day(CURRENT_DATE,'SA'),7), --上周六
       date_sub(next_day(CURRENT_DATE,'SU'),7); --上周日
select next_day(CURRENT_DATE,'MO'),--下周一
       next_day(CURRENT_DATE,'TU'), --下周二
       next_day(CURRENT_DATE,'WE'), --本周三
       next_day(CURRENT_DATE,'TH'), --本周四
       next_day(CURRENT_DATE,'FR'), --本周五
       next_day(CURRENT_DATE,'SA'), --本周六
       next_day(CURRENT_DATE,'SU'); --本周日

1.2	Hive分支函数
select if(1=2,100,200),
       case when 1=2 then 100 when 1=1 then 200 else 300 end,
       case when 'AAA' IN ('AAA','B','C') then 500 when 1=1 then 200 else 300 end,
       case when 'AAA' NOT IN ('AAA','B','C') then 500 when 1=1 then 200 else 300 end,
       case when 'aaa' is null then 100
            when 'aaa' = '' then 200
            when 'aaa' is not null then 300
            else 400 end;


1.3	Hive基本函数
select upper('abEcd'),ucase('adEcd'),
       lower('abEcd'),lcase('abEcd'),
       trim(' abEcd '),ltrim(' abEcd '),rtrim(' abEcd '),
       length('abEcdfg'),
       reverse('abcdefg'),  --反转函数--
       concat('abc','def'), --字符串连接函数--
       concat_ws(',','abc','def','ghi'),--字符串连接且用逗号分隔函数--
       substr('abckdefghi',5),substr('abckdefghi',5,2),
       substr('abckdefghi',-5),substr('abckdefghi',-5,2),
       split('abckdcefcghci','c'),  --按照字母c进行分隔--
       find_in_set('cd','abcdefg'), --和instr类似--
       instr('aaa|bbb|ccc','|'),
       repeat('abc',5),  --重复取值--
       round(45.926,2),
       round(45.926,1),
       round(45.926,0),
       round(45.926,-1),
       round(45.926,-2),
       rand(),  --取随机值:返回0到1之间的随机数--
       rand(10),--取随机值:也是返回0到1之间的随机数--
       cast('1' as bigint),
       cast(0.2 as float),
       format_number(120.32,0), --返回120
       format_number(120.3258,2),  --返回120.33（进行四色五入）
       substr('aaa|bbb|ccc',1,instr('aaa|bbb|ccc','|')-1),
       nvl(字段名,'test')
       ;

regexp_extract()
regexp_replace()
nvl(a,'xx'),
nvl2(a,100,200), --a为空，返回100，否则返回200
COALESCE(a,b,c)  --a为空，返回b，a不为空回c，否则返回本身

1.4	Hive map函数，explode函数，size函数
map(key,value)
select explode (map(1,'x',2,'xx',3,'xxx'));  --生成列表形式的数据--
select size(map(1,'x',2,'xx',3,'xxx')); --size函数和map函数一样使用，就相当于count--
select size(map(1,100,2,200,3,300));

1.5	hive中基本的关键字
is null
is not null
like '%xxx%'
not like '%xxx%'
a <> b

1.6	Hive开窗函数
select group_id,job,sum(salary) from group_test group by group_id, job with cube;
select group_id,job,sum(salary) from group_test group by group_id, job with rollup;
grouping sets()
grouping__id
row_number() 
drnk() 
dense_rank()
lag()
lead()
first_value()
last_value()

1.7	Hive开窗函数sql用法—
1.7.1	With语法
with tmp as (select distinct plan_id from tmp_isc.dwd_plan_atp_adj_f),
tmp1 as (select distinct item_code from tmp_isc.dwd_plan_atp_adj_f)
select f.plan_id,f.item_code,sum(f.atp_total_qty)
  from tmp_isc.dwd_plan_atp_adj_f f
  inner join tmp t on (f.plan_id = t.plan_id)
  inner join tmp1 t1 on (f.item_code = t1.item_code)
 where f.atp_start_date >= '2020-01-01'
 group by f.plan_id,f.item_code;

1.7.2	cube用法
with tmp as (select distinct plan_id from tmp_isc.dwd_plan_atp_adj_f),
tmp1 as (select distinct item_code from tmp_isc.dwd_plan_atp_adj_f)
select f.plan_id,f.item_code,sum(f.atp_total_qty)
  from tmp_isc.dwd_plan_atp_adj_f f
  inner join tmp t on (f.plan_id = t.plan_id)
  inner join tmp1 t1 on (f.item_code = t1.item_code)
 where f.atp_start_date >= '2020-01-01'
 group by f.plan_id,f.item_code
 with cube;

1.7.3	rollup用法
with tmp as (select distinct plan_id from tmp_isc.dwd_plan_atp_adj_f),
tmp1 as (select distinct item_code from tmp_isc.dwd_plan_atp_adj_f)
select f.plan_id,f.item_code,sum(f.atp_total_qty)
  from tmp_isc.dwd_plan_atp_adj_f f
  inner join tmp t on (f.plan_id = t.plan_id)
  inner join tmp1 t1 on (f.item_code = t1.item_code)
 where f.atp_start_date >= '2020-01-01'
 group by f.plan_id,f.item_code
 with rollup;

1.7.4	grouping sets用法
with tmp as (select distinct plan_id from tmp_isc.dwd_plan_atp_adj_f),
tmp1 as (select distinct item_code from tmp_isc.dwd_plan_atp_adj_f)
select f.plan_id,f.item_code,sum(f.atp_total_qty)
  from tmp_isc.dwd_plan_atp_adj_f f
  inner join tmp t on (f.plan_id = t.plan_id)
  inner join tmp1 t1 on (f.item_code = t1.item_code)
 where f.atp_start_date >= '2020-01-01'
 group by f.plan_id,f.item_code
 grouping sets(f.plan_id,f.item_code);

1.7.5	grouping__id用法
with tmp as (select distinct plan_id from tmp_isc.dwd_plan_atp_adj_f),
tmp1 as (select distinct item_code from tmp_isc.dwd_plan_atp_adj_f)
select f.plan_id,f.item_code,sum(f.atp_total_qty),grouping__id
  from tmp_isc.dwd_plan_atp_adj_f f
  inner join tmp t on (f.plan_id = t.plan_id)
  inner join tmp1 t1 on (f.item_code = t1.item_code)
 where f.atp_start_date >= '2020-01-01'
 group by f.plan_id,f.item_code
 grouping sets(f.plan_id,f.item_code);

1.7.6	over(partition by xxx order by xxx asc)用法
with tmp as (select distinct plan_id from tmp_isc.dwd_plan_atp_adj_f),
tmp1 as (select distinct item_code from tmp_isc.dwd_plan_atp_adj_f)
select f.plan_id,f.item_code,sum(f.atp_total_qty),
       sum(sum(f.atp_total_qty)) over(partition by item_code order by plan_id asc) as qty,
       grouping__id
  from tmp_isc.dwd_plan_atp_adj_f f
  inner join tmp t on (f.plan_id = t.plan_id)
  inner join tmp1 t1 on (f.item_code = t1.item_code)
 where f.atp_start_date >= '2020-01-01'
 group by f.plan_id,f.item_code
 grouping sets(f.plan_id,f.item_code);

1.7.7	交叉用法例子
with tmp as (select distinct plan_id from tmp_isc.dwd_plan_pfc_prod_fcst_dtl_f),
tmp1 as (select distinct SOURCE_PROD_SERIES_EN_NAME from tmp_isc.dwd_plan_pfc_prod_fcst_dtl_f)
select f.plan_id,f.SOURCE_PROD_SERIES_EN_NAME,sum(f.fcst_qty),
       sum(sum(f.fcst_qty)) over(partition by SOURCE_PROD_SERIES_EN_NAME order by plan_id asc) as qty,
       grouping__id
  from tmp_isc.dwd_plan_pfc_prod_fcst_dtl_f f
  inner join tmp t on (f.plan_id = t.plan_id)
  inner join tmp1 t1 on (f.SOURCE_PROD_SERIES_EN_NAME = t1.SOURCE_PROD_SERIES_EN_NAME)
 where f.fcst_date >= '2020-01-01'
   and f.plan_id = 'MRPWK_20191209'
 group by f.plan_id,f.SOURCE_PROD_SERIES_EN_NAME
 grouping sets(f.plan_id,f.SOURCE_PROD_SERIES_EN_NAME);


with tmp as (select distinct plan_id from tmp_isc.dwd_plan_pfc_prod_fcst_dtl_f),
tmp1 as (select distinct SOURCE_PROD_SERIES_EN_NAME from tmp_isc.dwd_plan_pfc_prod_fcst_dtl_f)
select f.plan_id,f.SOURCE_PROD_SERIES_EN_NAME,sum(f.fcst_qty),
       sum(sum(f.fcst_qty)) over(partition by SOURCE_PROD_SERIES_EN_NAME order by plan_id asc) as qty
  from tmp_isc.dwd_plan_pfc_prod_fcst_dtl_f f
  inner join tmp t on (f.plan_id = t.plan_id)
  inner join tmp1 t1 on (f.SOURCE_PROD_SERIES_EN_NAME = t1.SOURCE_PROD_SERIES_EN_NAME)
 where f.fcst_date >= '2020-01-01'
   and f.plan_id = 'MRPWK_20191209'
 group by f.plan_id,f.SOURCE_PROD_SERIES_EN_NAME;


1.7.8	LIKE 和RLIKE 的用法
LIKE 和RLIKE 的用法:
select name,deductions from employees where like address.city like 'Chi%'; --Chi打头的--
select name,deductions from employees where like address.city like '%ago'; --ago结尾的--
select name,deductions from employees where like address.city like '%a%';  --匹配a字符的--

select name,deductions from employees where like address.city rlike '.*(Chicago|OakPark).*';  --可以写正则表达式--


2	Hive 执行计划
Explain select * from emp;
Explain extended select * from emp;

3	Hive中操作对象（新增，删除，修改对象）
3.1	Hive中删库必须先删表
Hive中删库必须先删表:
DROP DATABASE IF EXISTS IOC_DB CASCADE;  
加CASCADE关键字，hive会自动先删除表再删除数据库
DROP DATABASE IF EXISTS IOC_DB RESTRICT; 
RESTRICT关键字和默认情况一样，必须手动删除表，才能执行删除库

3.2	Hive创建表
3.2.1	创建内部表
创建内部表1
CREATE TABLE IF NOT EXISTS example.employee
(
Id INT COMMENT 'employeeid',
DateInCompany STRING COMMENT 'date come in company',
Money FLOAT  COMMENT 'work money',
Mapdata Map<STRING,ARRAY<STRING>>,
Arraydata ARRAY<INT>,
StructorData STRUCT<col1:STRING,col2:STRING>
)
PARTITIONED BY (century STRING COMMENT 'centruy come in company',
year STRING COMMENT 'come in company year')
CLUSTERED BY (DateInCompany) into 32 buckets
ROW FORMAT DELIMITED FIELDS TERMINATED BY ‘,' 
COLLECTION ITEMS TERMINATED BY '@'
MAP KEYS TERMINATED BY '$'
STORED AS TEXTFILE;

创建内部表2
CREATE TABLE IF NOT EXISTS tmp_isc.dwd_plan_mkt_srv_sop_dtl_f
(
  dtl_id                        bigint comment 'id',
  plan_end_time                 string comment '时间',
  plan_natural_week             bigint comment '周',
  plan_id                       string comment '计划期次',
  head_id                       bigint comment '头id',
  item_key                      bigint comment '物料编码key',
  item_code                     string comment '物料编码',
  write_off_relation_code_list  string comment 'code',
  sop_type_id                   bigint comment 'sop类型id',
  fcst_date                     string comment '预测时间',
  create_by_emp_no              string comment '工号',
  create_time                   string comment '创建时间',
  last_modify_by_emp_no         string comment '修改人工号',
  last_modify_time              string comment '修改时间',
  last_modify_version           bigint comment '修改版本',
  desc                            string comment 'desc',
  sop_qty                    bigint comment 'sop_qty',
  last_sop_qty                    bigint comment 'last_sop_qty',
  atp_qty                    bigint comment 'atp_qty',
  dw_creation_date            string comment 'dw_creation_date',
  dw_last_modified_date            string comment 'dw_last_modified_date'
)
COMMENT 'dwd_plan_mkt_srv_sop_dtl_f'
PARTITIONED BY (plan_natural_week_monday STRING COMMENT 'plan_natural_week_monday')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\001'
STORED AS ORCFILE;

创建内部表（分区表:注意分区字段不要放在字段列表中）
create table if not exists tmp_isc.employees_test
(
name         STRING,
Age          INT,
salary       FLOAT,
subordinates ARRAY<STRING>,
deductions   MAP<STRING,FLOAT>,
address      STRUCT<street:STRING,city:STRING,state:STRING,zip:INT>
)
PARTITIONED BY (country STRING,state STRING) --存储属性必选
CLUSTERED BY (Age) INTO 10 buckets           --存储属性必选
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '@'
MAP KEYS TERMINATED BY '$'
STORED AS sequencefile   --存储属性可选
LOCATION '/localtest';

3.2.2	创建外部表
创建外部表:
CREATE EXTERNAL TABLE IF NOT EXISTS company.person
(
Id int,
Name string,
Age int,
Birthday string
)
PARTITIONED BY (century string ,year string)
CLUSTERED BY (Age) INTO 10 buckets
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS sequencefile
LOCATION ‘/localtest’;

创建外部表（分区表）
create external table if not exists tmp_isc.employees_test
(
name         STRING,
salary       FLOAT,
subordinates ARRAY<STRING>,
deductions   MAP<STRING,FLOAT>,
address      STRUCT<street:STRING,city:STRING,state:STRING,zip:INT>
)
PARTITIONED BY (country STRING,state STRING)   --存储属性必选
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '@'
MAP KEYS TERMINATED BY '$'
STORED AS TEXTFILE;  --存储属性可选

表重命名
ALTER TABLE employee rename to employee_test;
删除表
DROP TABLE IF EXISTS EMPLOYEE;


3.2.3	单个查询语句创建表并加载数据
单个查询语句创建表并加载数据（不能用于外部表）
适用于备份表数据
CREATE TABLE tmp_isc.employees_bak1 AS
SELECT NAME,SALARY,subordinates
 FROM tmp_isc.employees WHERE country = 'GD';

CREATE TABLE tmp_isc.employees_bak2 AS
SELECT *
 FROM tmp_isc.employees;
注意:这样创建的表是普通表，没有分区和索引。
3.2.4	Like关键字创建表
Like关键字创建表（不会copy数据;如果要添加数据，可以set location 's3n://hive/warehouse/ioc/employees'）
CREATE TABLE IF NOT EXISTS tmp_isc.employees_test LIKE tmp_isc.employees;
注意: 这样创建的表和原表保持一致，原表是分区表新表也是分区表。

CREATE TABLE IF NOT EXISTS tmp_isc.employees_test LIKE tmp_isc.employees location 's3n://hive/warehouse/ioc/employees';


3.2.5	Hive分区
--添加分区
ALTER TABLE employee ADD IF NOT EXISTS PARTITION (century= '21',year='2012');
--删除分区
ALTER TABLE employee DROP PARTITION  (century= '23',year='2010');
--在表上添加指定分区--
ALTER TABLE tmp_isc.employees_test ADD PARTITION (country = 'CH',state = 'GX');

ALTER TABLE tmp_isc.employees_test ADD PARTITION (country = 'CH',state = 'GX') LOCATION 'hdfs://hive/warehose/tmp_isc/employees_test/CH/GX';

ALTER TABLE tmp_isc.employees_test PARTITION (country = 'CH',state = 'GX') SET LOCATION 's3n://hive/warehose/tmp_isc/employees/CH/GX';

--分区压缩--
ALTER TABLE tmp_isc.employees_test ARCHIVE PARTITION (country = 'CH',state = 'GX');
--分区解压缩--
ALTER TABLE tmp_isc.employees_test UNARCHIVE PARTITION (country = 'CH',state = 'GX');
--分区保护--
ALTER TABLE tmp_isc.employees_test PARTITION (country = 'CH',state = 'GX') enable no_drop;  --防止drop分区
ALTER TABLE tmp_isc.employees_test PARTITION (country = 'CH',state = 'GX') enable offline;  --防止下线
ALTER TABLE tmp_isc.employees_test PARTITION (country = 'CH',state = 'GX') disable no_drop;  --取消drop分区
ALTER TABLE tmp_isc.employees_test PARTITION (country = 'CH',state = 'GX') disable offline;  --取消下线
3.2.6	Hive表中列操作
--修改列将列salary修改成salary_bak（并且将该列放在name列之后）
ALTER TABLE tmp_isc.employees_test_bak CHANGE COLUMN salary     salary_bak INT   comment '字段备注信息' AFTER name;

修改列将列salary_bak修改成salary
ALTER TABLE tmp_isc.employees_test_bak CHANGE COLUMN salary_bak salary     FLOAT comment '员工工资'     AFTER name;

修改列并且将该列放在表的第一列
ALTER TABLE tmp_isc.employees_test_bak CHANGE COLUMN salary_bak salary     FLOAT comment '员工工资'     FIRST;

添加列
ALTER TABLE tmp_isc.employees_test_bak ADD columns(test String);

alter table tmp_isc.employees_test_bak ADD COLUMNS(
deductions   MAP<STRING,FLOAT>,
address      STRUCT<street:STRING,city:STRING,state:STRING,zip:INT>
);

--删除列（下面的语句执行后，表里面只有一个字段prod_model_set，其他字段全部删除）
ALTER TABLE tmp_isc.dwd_proc_demdsup_gap_f replace columns (prod_model_set string);

--删除或者替换列（替换原来的列，并且添加新的列）
--这种写法是替换所有的列，新增4个新列
ALTER TABLE tmp_isc.employees_test_bak REPLACE COLUMNS
(
 street  string  comment 'street',
 city    string  comment 'city',
 state   string  comment 'state',
 zip     int     comment 'zip'
);
3.2.7	Hive修改文件格式
ALTER TABLE tmp_isc.employees_test_bak SET fileformat  TEXTFILE;
ALTER TABLE tmp_isc.employees_test_bak SET fileformat  sequencefile;
ALTER TABLE tmp_isc.employees_test_bak SET fileformat  ORCFILE;

3.2.8	创建视图
create view stocks_dividends_v as
SELECT /*+STREAMTABLE(s)*/
       s.ymd,
       s.symbol,
       s.price_close,
       d.dividend
  from stocks s 
  join dividends d on s.ymd = d.ymd and s.symbol = d.symbol
 where 1=1
   and s.symbol = 'AAPL';


--为这个表tmp_isc.employees_test创建视图--
--把MAP集合元素创建视图:
create view if not exists tmp_isc.employees_test_v(Federal_Taxes,State_Taxes,Insurance) as
select deductions["Federal Taxes"],deductions["State Taxes"],deductions["Insurance"]
  from tmp_isc.employees_test
 where deductions["Federal Taxes"] = 0.2;

--把STRUCT结构创建视图(BITMAP):
create view tmp_isc.employees_test_v(street,city,state) as
select address.street,address.city,address.state
  from tmp_isc.employees_test
 where address.street like '%a%';

--用like关键字创建视图--
create view tmp_isc.employees_test_v1 like tmp_isc.employees_test_v;
--删除视图--
drop view if exists tmp_isc.employees_test_v;


3.2.9	hive中创建索引(CompactIndexHandler)--
create index employees_index
on table employees(country)
as 'org.apache.hadoop.hive.ql.index.compact.CompactIndexHandler'
with deferred rebuild
IDXPROPERTIES('creator' = 'me','created_at' = 'some_time')
IN TABLE employees_index_table
PARTITIONED BY (country,name)
COMMENT 'Employees indexed by country and name.';


--创建Bitmap索引--
create index employees_index
on table employees(country)
as 'Bitmap'
with deferred rebuild
IDXPROPERTIES('creator' = 'me','created_at' = 'some_time')
IN TABLE employees_index_table
PARTITIONED BY (country,name)
COMMENT 'Employees indexed by country and name.';

--重建索引--
alter index emploees_index on table employees partition (country = 'CN') REBUILD;
--删除索引--
drop index if exists emploees_index on table employees;

3.3	Hive数据迁移
3.3.1	Hive数据处理
将分区下的数据copy到其他存储设备的s3n目录中--
hadoop distcp /data/log/log_message/2011/12/02 s3n://ourbucket/logs/2011/12/02
--修改表，将分区路径指向s3路径:
ALTER TABLE tmp_isc.employees_test PARTITION (country = 'CH',state = 'GX')
SET LOCATION 's3n:////ourbucket/logs/2011/12/02';
--删除hdfs的这个分区数据
hadoop fs -rmr /data/log/log_message/2011/12/02

3.3.2	写数据到分区表
	编辑一条数据:
John Doe,1500.00,Mary Smith@Todd Jones,Federal Taxes$0.2@State Taxes$0.05@Insurance$0.1,Michigan Ave.@SHENZHEN@GD@0755

	先添加一个分区:
alter table tmp_isc.employees add PARTITION(country='CN',state='GD');

	这样无法写入数据到表（hive不支持行级的数据insert，update，delete）--
insert OVERWRITE TABLE tmp_isc.employees_test PARTITION (country='CN',state='GD')
select 'John Doe' as name,
       1500.00 as salary,
       'Mary Smith@Todd Jones' as subordinates,
       'Federal Taxes$0.2@State Taxes$0.05@Insurance$0.1' as deductions,
       'Michigan Ave.@SHENZHEN@GD@0755' as address;

	可以这样操作：
先创建2个分区：
alter table tmp_isc.employees add PARTITION(country='GD',state='SZ');
alter table tmp_isc.employees add PARTITION(country='GD',state='GZ');

修改表结构，这三个字段是对象类型（截图如下），修改成string类型。
ALTER TABLE tmp_isc.employees CHANGE COLUMN subordinates subordinates string;
ALTER TABLE tmp_isc.employees CHANGE COLUMN deductions deductions string;
ALTER TABLE tmp_isc.employees CHANGE COLUMN address address string;
 


set mapred.job.name = tmp_isc.dwd_plan_mkt_srv_sop_dtl_f.xwx559919;
set hive.auto.convert.join = true;
set hive.ignore.mapjoin.hint=false;
set hive.merge.mapredfiles=True;
set hive.merge.size.per.task=128000000;
SET hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.mapjoin.localtask.max.memory.usage=0.999;

FROM (
  SELECT 'test1' AS NAME,20 as salary,'GD' as country,'SZ' AS state  UNION ALL
  SELECT 'test2' AS NAME,21 as salary,'GD' as country,'GZ' AS state  UNION ALL
  SELECT 'test3' AS NAME,22 as salary,'GD' as country,'DG' AS state  UNION ALL
  SELECT 'test4' AS NAME,20 as salary,'HN' as country,'YY' AS state  UNION ALL
  SELECT 'test5' AS NAME,21 as salary,'HN' as country,'CS' AS state  UNION ALL
  SELECT 'test6' AS NAME,23 as salary,'HN' as country,'XT' AS state
  ) E
INSERT OVERWRITE TABLE TMP_ISC.employees PARTITION (country='GD',state='SZ')
SELECT E.NAME,E.salary,null as subordinates,null as deductions,null as address--,E.country,E.state
 WHERE E.state = 'SZ' AND country = 'GD'
INSERT OVERWRITE TABLE TMP_ISC.employees PARTITION (country='GD',state='GZ')
SELECT  E.NAME,E.salary,null as subordinates,null as deductions,null as address--,E.country,E.state
 WHERE E.state = 'GZ' AND country = 'GD';

	用create方式写数据到表
CREATE TABLE tmp_isc.employees_bak AS
SELECT NAME,SALARY,subordinates
FROM tmp_isc.employees WHERE country = 'GD';

INSERT数据到表
OVERWRITE:进行数据覆盖
INSERT OVERWRITE TABLE employees PARTITION (country = 'CH',state = 'GX')
SELECT * FROM staged_employees se
WHERE se.cnty = 'CH' 
  AND se.state = 'GX';

--动态分区--
INSERT OVERWRITE TABLE employees PARTITION (country,state)
SELECT *,se.cnty,se.state FROM staged_employees se;

--动静结合分区--
INSERT OVERWRITE TABLE employees PARTITION (country = 'CH',state)
SELECT *,se.cnty,se.state FROM staged_employees se
WHERE se.cnty = 'CH';

INTO:进行数据追加（hive 8.0版本才有的功能）
INSERT INTO TABLE employees PARTITION (country = 'CH',state = 'GX')
SELECT * FROM staged_employees se
WHERE se.cnty = 'CH' 
  AND se.state = 'GX';

--多次INSERT数据到表(只读一次表,多次写入)语法:OVERWRITE 和 INTO可以搭配使用
FROM staged_employees se
INSERT OVERWRITE TABLE employees PARTITION (country = 'CH',state = ' GD')
select * where se.cnty = 'CH' AND se.state = 'GD'
INSERT INTO TABLE employees PARTITION (country = 'CH',state = 'GX')
select * where se.cnty = 'CH' AND se.state = 'GX'
INSERT INTO TABLE employees PARTITION (country = 'CH',state = 'YN')
select * where se.cnty = 'CH' AND se.state = 'YN';

3.3.3	查看hive数据库对象命令
查看schema下的表
show tables in tmp_isc;
--查看表分区
show partitions tmp_isc.employees;
--查看表中指定的分区
show partitions tmp_isc.employees partition(country = 'CH');
--查看表结构
DESCRIBE tmp_isc.employees;
DESC tmp_isc.employees;
--可查看该表的分区键
DESCRIBE EXTENDED tmp_isc.employees;
DESC EXTENDED tmp_isc.employees;

3.3.4	实例: array\map\struct 的使用例子--
--创建内部表（分区表:注意分区字段不要放在字段列表中）
create table if not exists tmp_isc.employees_test
(
name         STRING,
Age          INT,
salary       FLOAT,
subordinates ARRAY<STRING>,
deductions   MAP<STRING,FLOAT>,
address      STRUCT<street:STRING,city:STRING,state:STRING,zip:INT>
)
PARTITIONED BY (country STRING,state STRING) --存储属性必选
CLUSTERED BY (Age) INTO 10 buckets           --存储属性必选
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '@'
MAP KEYS TERMINATED BY '$'
STORED AS sequencefile   --存储属性可选
LOCATION '/localtest';

--创建外部表（分区表）
create external table if not exists tmp_isc.employees_test
(
name         STRING,
salary       FLOAT,
subordinates ARRAY<STRING>,
deductions   MAP<STRING,FLOAT>,
address      STRUCT<street:STRING,city:STRING,state:STRING,zip:INT>
)
PARTITIONED BY (country STRING,state STRING)   --存储属性必选
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '@'
MAP KEYS TERMINATED BY '$'
STORED AS TEXTFILE;  --存储属性可选

表数据如下:
select name,subordinates from employees;
输出:
John Doe   ["Mary Smith","Todd Jones"]
Mary Smith ["Bill King"]
Todd Jones []
Bill King  []

select name,deductions from employees;
输出:
John Doe   {"Federal Taxes":0.2,"State Taxes":0.05,"Insurance":0.1}
Mary Smith {"Federal Taxes":0.2,"State Taxes":0.05,"Insurance":0.1}
Todd Jones {"Federal Taxes":0.3,"State Taxes":0.15,"Insurance":0.1}
Bill King  {"Federal Taxes":0.3,"State Taxes":0.15,"Insurance":0.1}

select name,address from employees;
输出:
John Doe   {"street":"1 Michigan Ave.","city":"Chicago","State":"GD","zip":60600}
Mary Smith {"street":"2 Michigan Ave.","city":"Chicago","State":"GD","zip":60601}
Todd Jones {"street":"3 Michigan Ave.","city":"OakPark1","State":"GD","zip":60602}
Bill King  {"street":"4 Michigan Ave.","city":"OakPark2","State":"GD","zip":60603}


ARRAY类型：
select name,aubordinates[0] from employees;
输出:
John Doe    Mary Smith
Mary Smith  Bill King
Todd Jones  NULL
Bill King   NULL

MAP类型：
select name,deductions["State Taxes"] from employees;
输出:
John Doe    0.05
Mary Smith  0.05
Todd Jones  0.15
Bill King   0.15

STRUCT类型：
select name,address.city from employees;
输出:
John Doe    Chicago
Mary Smith  Chicago
Todd Jones  OakPark1
Bill King   OakPark2


4	HIVE SQL优化
4.1	加/*+STREAMTABLE(s)*/的方式
HIVE在查询sql语句读表的顺序是从左到右的方式，所以一般把大表放到sql语句的最后。
但是可以使用加/*+STREAMTABLE(s)*/这种方式来指定哪个表是大表（可以把大表放前面）。
SELECT /*+STREAMTABLE(s)*/
       s.ymd,
       s.symbol,
       s.price_close,
       d.dividend
  from stocks s 
  join dividends d on s.ymd = d.ymd and s.symbol = d.symbol
 where s.symbol = 'AAPL';

4.2	将小表放到内存中和大表计算，或者调整参数为true--
set hive.auto.convert.join=true;
也可以配置能够使用这个优化的小表的大小，这个属性默认值(单位是字节):hive的右连接(rigth out join)和全连接(full out join)不支持这个优化
hvie.mapjoin.smalltable.filesize=25000000

SELECT /*+MAPJOIN(d)*/
       s.ymd,
       s.symbol,
       s.price_close,
       d.dividend
  from stocks s 
  join dividends d on s.ymd = d.ymd and s.symbol = d.symbol
 where s.symbol = 'AAPL';

4.3	HIVE中只支持等值连接
--HIVE中只支持等值连接--
--HIVE中不支持select * from xxx where aa in(子查询)的语法--
select s.ymd,s.symbol,s.price_close from stocks s
where s.ymd,s.symbol in
(select d.ymd,d.symbol from dividends d);

上面的语句可改造如下：
hive左半开连接:left semi join
hive不支持右半开连接。
 select s.ymd，s.symbol,s.price_colse
   from stocks s left semi join dividends d on s.ymd = d.ymd and s.symbol = d.symbol;

4.4	hive左半开连接:left semi join
接上面一节4.3节讲的sql语句，举例说明:
--不支持--
set mapred.job.name = tmp_isc.dwd_plan_mkt_srv_sop_dtl_f.xwx559919;
set hive.auto.convert.join = true;
set hive.ignore.mapjoin.hint=false;
set hive.merge.mapredfiles=True;
set hive.merge.size.per.task=128000000;
SET hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.mapjoin.localtask.max.memory.usage=0.999;
with tmp as (
  SELECT 1 AS ID,'test1' AS NAME,20 as Age,'SZ' AS CITY  UNION ALL
  SELECT 2 AS ID,'test2' AS NAME,21 as Age,'SZ' AS CITY  UNION ALL
  SELECT 3 AS ID,'test3' AS NAME,22 as Age,'SZ' AS CITY  UNION ALL
  SELECT 7 AS ID,'test7' AS NAME,20 as Age,'GZ' AS CITY  UNION ALL
  SELECT 8 AS ID,'test8' AS NAME,21 as Age,'GZ' AS CITY  UNION ALL
  SELECT 9 AS ID,'test9' AS NAME,23 as Age,'GZ' AS CITY
),
v_time as (
  SELECT 10 AS ID,'test7' AS NAME,'LH' AS address  UNION ALL
  SELECT 12 AS ID,'test7' AS NAME,'LG' AS address  UNION ALL
  SELECT 13 AS ID,'test7' AS NAME,'NS' AS address  UNION ALL
  SELECT 7  AS ID,'test7' AS NAME,'FT' AS address  UNION ALL
  SELECT 8  AS ID,'test7' AS NAME,'LF' AS address  UNION ALL
  SELECT 9  AS ID,'test7' AS NAME,'GM' AS address
)
select t.*
  from tmp t where t.id,t.name in (select v.id,v.name from v_time v);
  

--上面的可以改写成-- 
set mapred.job.name = tmp_isc.dwd_plan_mkt_srv_sop_dtl_f.xwx559919;
set hive.auto.convert.join = true;
set hive.ignore.mapjoin.hint=false;
set hive.merge.mapredfiles=True;
set hive.merge.size.per.task=128000000;
SET hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.mapjoin.localtask.max.memory.usage=0.999;
with tmp as (
  SELECT 1 AS ID,'test1' AS NAME,20 as Age,'SZ' AS CITY  UNION ALL
  SELECT 2 AS ID,'test2' AS NAME,21 as Age,'SZ' AS CITY  UNION ALL
  SELECT 3 AS ID,'test3' AS NAME,22 as Age,'SZ' AS CITY  UNION ALL
  SELECT 7 AS ID,'test7' AS NAME,20 as Age,'GZ' AS CITY  UNION ALL
  SELECT 8 AS ID,'test8' AS NAME,21 as Age,'GZ' AS CITY  UNION ALL
  SELECT 9 AS ID,'test9' AS NAME,23 as Age,'GZ' AS CITY
),
v_time as (
  SELECT 10 AS ID,'test7' AS NAME,'LH' AS address  UNION ALL
  SELECT 12 AS ID,'test7' AS NAME,'LG' AS address  UNION ALL
  SELECT 13 AS ID,'test7' AS NAME,'NS' AS address  UNION ALL
  SELECT 7  AS ID,'test7' AS NAME,'FT' AS address  UNION ALL
  SELECT 8  AS ID,'test7' AS NAME,'LF' AS address  UNION ALL
  SELECT 9  AS ID,'test7' AS NAME,'GM' AS address
)
select t.*
  from tmp t 
  left semi join v_time v on t.id = v.id and t.name= v.name;

--写法1--
  SELECT 1 AS ID,'A' AS NAME  UNION ALL
  SELECT 2 AS ID,'B' AS NAME  UNION ALL
  SELECT 3 AS ID,'C' AS NAME;

--写法2--
FROM (
  SELECT 1 AS ID,'A' AS NAME  UNION ALL
  SELECT 2 AS ID,'B' AS NAME  UNION ALL
  SELECT 3 AS ID,'C' AS NAME 
  ) E
SELECT E.ID,E.NAME
WHERE E.ID >= 3;

--写法3--
SELECT E.ID,E.NAME
FROM (
  SELECT 1 AS ID,'A' AS NAME  UNION ALL
  SELECT 2 AS ID,'B' AS NAME  UNION ALL
  SELECT 3 AS ID,'C' AS NAME 
  ) E
WHERE E.ID >= 3;


union all多的时候 
set hive.exec.parallel=true;
set hive.exec.parallel.thread.number=8;
开并行



4.5	Insert 数据到分区表:覆盖分区的方式--
create table if not exists tmp_isc.plan_test1
(
 id           INT,
 name         STRING,
 Age          INT
)
COMMENT 'tmp_isc.plan_test1'
PARTITIONED BY (city STRING COMMENT 'city')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\001'
STORED AS ORCFILE;

set mapred.job.name = tmp_isc.dwd_plan_mkt_srv_sop_dtl_f.xwx559919;
set hive.auto.convert.join = true;
set hive.ignore.mapjoin.hint=false;
set hive.merge.mapredfiles=True;
set hive.merge.size.per.task=128000000;
SET hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.mapjoin.localtask.max.memory.usage=0.999;

FROM (
  SELECT 1 AS ID,'test1' AS NAME,20 as Age,'SZ' AS CITY  UNION ALL
  SELECT 2 AS ID,'test2' AS NAME,21 as Age,'SZ' AS CITY  UNION ALL
  SELECT 3 AS ID,'test3' AS NAME,22 as Age,'SZ' AS CITY  UNION ALL
  SELECT 4 AS ID,'test4' AS NAME,20 as Age,'GZ' AS CITY  UNION ALL
  SELECT 5 AS ID,'test5' AS NAME,21 as Age,'GZ' AS CITY  UNION ALL
  SELECT 6 AS ID,'test6' AS NAME,23 as Age,'GZ' AS CITY
  ) E
INSERT OVERWRITE TABLE TMP_ISC.PLAN_TEST1 PARTITION (CITY)
SELECT E.ID,E.NAME,E.Age,E.CITY
 WHERE E.CITY = 'SZ'
INSERT OVERWRITE TABLE TMP_ISC.PLAN_TEST1 PARTITION (CITY)
SELECT E.ID,E.NAME,E.Age,E.CITY
 WHERE E.CITY = 'GZ';


4.6	Insert 数据到表:覆盖全表的方式（非分区表）--
drop table tmp_isc.plan_test;
create table if not exists tmp_isc.plan_test
(
id           INT,
name         STRING,
Age          INT,
city         STRING
)
COMMENT 'tmp_isc.plan_test'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\001'
STORED AS ORCFILE;

FROM (
  SELECT 1 AS ID,'test1' AS NAME,20 as Age,'SZ' AS CITY  UNION ALL
  SELECT 2 AS ID,'test2' AS NAME,21 as Age,'SZ' AS CITY  UNION ALL
  SELECT 3 AS ID,'test3' AS NAME,22 as Age,'SZ' AS CITY  UNION ALL
  SELECT 4 AS ID,'test4' AS NAME,20 as Age,'GZ' AS CITY  UNION ALL
  SELECT 5 AS ID,'test5' AS NAME,21 as Age,'GZ' AS CITY  UNION ALL
  SELECT 6 AS ID,'test6' AS NAME,23 as Age,'GZ' AS CITY
  ) E
INSERT OVERWRITE TABLE TMP_ISC.PLAN_TEST
SELECT E.ID,E.NAME,E.Age,E.CITY
 WHERE E.CITY = 'SZ';



4.7	Insert 数据到分区表:覆盖分区的方式,采用with语句的方式--
set mapred.job.name = tmp_isc.dwd_plan_mkt_srv_sop_dtl_f.xwx559919;
set hive.auto.convert.join = true;
set hive.ignore.mapjoin.hint=false;
set hive.merge.mapredfiles=True;
set hive.merge.size.per.task=128000000;
SET hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.mapjoin.localtask.max.memory.usage=0.999;

with tmp as (
  SELECT 1 AS ID,'test1' AS NAME,20 as Age,'SZ' AS CITY  UNION ALL
  SELECT 2 AS ID,'test2' AS NAME,21 as Age,'SZ' AS CITY  UNION ALL
  SELECT 3 AS ID,'test3' AS NAME,22 as Age,'SZ' AS CITY  UNION ALL
  SELECT 7 AS ID,'test7' AS NAME,20 as Age,'GZ' AS CITY  UNION ALL
  SELECT 8 AS ID,'test8' AS NAME,21 as Age,'GZ' AS CITY  UNION ALL
  SELECT 9 AS ID,'test9' AS NAME,23 as Age,'GZ' AS CITY
  ),
v_time as (
  SELECT 10 AS ID,'LH' AS address  UNION ALL
  SELECT 12 AS ID,'LG' AS address  UNION ALL
  SELECT 13 AS ID,'NS' AS address  UNION ALL
  SELECT 7 AS ID,'FT' AS address  UNION ALL
  SELECT 8 AS ID,'LF' AS address  UNION ALL
  SELECT 9 AS ID,'GM' AS address
)

FROM (
SELECT T.*
  FROM tmp T
 INNER JOIN v_time V ON T.ID = V.ID
 WHERE V.address IN ('FT','LF','GM')
) E
INSERT OVERWRITE TABLE TMP_ISC.PLAN_TEST1 PARTITION (CITY)
SELECT E.ID,E.NAME,E.Age,E.CITY
 WHERE E.CITY = 'SZ'
INSERT OVERWRITE TABLE TMP_ISC.PLAN_TEST1 PARTITION (CITY)
SELECT E.ID,E.NAME,E.Age,E.CITY
 WHERE E.CITY = 'GZ';



4.8	Insert 数据到分区表:不覆盖分区，增量的方式处理,采用with语句的方式--
set mapred.job.name = tmp_isc.dwd_plan_mkt_srv_sop_dtl_f.xwx559919;
set hive.auto.convert.join = true;
set hive.ignore.mapjoin.hint=false;
set hive.merge.mapredfiles=True;
set hive.merge.size.per.task=128000000;
SET hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.mapjoin.localtask.max.memory.usage=0.999;

with tmp as (
  SELECT 1 AS ID,'test1' AS NAME,20 as Age,'SZ' AS CITY  UNION ALL
  SELECT 2 AS ID,'test2' AS NAME,21 as Age,'SZ' AS CITY  UNION ALL
  SELECT 3 AS ID,'test3' AS NAME,22 as Age,'SZ' AS CITY  UNION ALL
  SELECT 4 AS ID,'test7' AS NAME,20 as Age,'GZ' AS CITY  UNION ALL
  SELECT 5 AS ID,'test8' AS NAME,21 as Age,'GZ' AS CITY  UNION ALL
  SELECT 6 AS ID,'test9' AS NAME,23 as Age,'GZ' AS CITY
  ),
v_time as (
  SELECT 10 AS ID,'LH' AS address  UNION ALL
  SELECT 12 AS ID,'LG' AS address  UNION ALL
  SELECT 13 AS ID,'NS' AS address  UNION ALL
  SELECT 4 AS ID,'FT' AS address  UNION ALL
  SELECT 5 AS ID,'LF' AS address  UNION ALL
  SELECT 6 AS ID,'GM' AS address
)

FROM (
SELECT T.*
  FROM tmp T
 INNER JOIN v_time V ON T.ID = V.ID
 WHERE V.address IN ('FT','LF','GM')
) E
INSERT INTO TMP_ISC.PLAN_TEST1 PARTITION (CITY)
SELECT E.ID,E.NAME,E.Age,E.CITY
 WHERE E.CITY = 'SZ'
INSERT INTO TMP_ISC.PLAN_TEST1 PARTITION (CITY)
SELECT E.ID,E.NAME,E.Age,E.CITY
 WHERE E.CITY = 'GZ';

4.9	输出字段可以用*号来替代
set mapred.job.name = tmp_isc.dwd_plan_mkt_srv_sop_dtl_f.xwx559919;
set hive.auto.convert.join = true;
set hive.ignore.mapjoin.hint=false;
set hive.merge.mapredfiles=True;
set hive.merge.size.per.task=128000000;
SET hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.mapjoin.localtask.max.memory.usage=0.999;

with tmp1 as (
  SELECT 1 AS ID,'test1' AS NAME,20 as Age,'SZ' AS CITY  UNION ALL
  SELECT 2 AS ID,'test2' AS NAME,21 as Age,'SZ' AS CITY  UNION ALL
  SELECT 3 AS ID,'test3' AS NAME,22 as Age,'SZ' AS CITY  UNION ALL
  SELECT 4 AS ID,'test4' AS NAME,20 as Age,'GZ' AS CITY  UNION ALL
  SELECT 5 AS ID,'test5' AS NAME,21 as Age,'GZ' AS CITY  UNION ALL
  SELECT 6 AS ID,'test6' AS NAME,23 as Age,'GZ' AS CITY
  ),

 tmp2 as (
  SELECT 1 AS ID,'test1' AS NAME,20 as Age,'SZ' AS CITY  UNION ALL
  SELECT 2 AS ID,'test2' AS NAME,21 as Age,'SZ' AS CITY  UNION ALL
  SELECT 3 AS ID,'test3' AS NAME,22 as Age,'SZ' AS CITY  UNION ALL
  SELECT 4 AS ID,'test4' AS NAME,20 as Age,'GZ' AS CITY  UNION ALL
  SELECT 5 AS ID,'test5' AS NAME,21 as Age,'GZ' AS CITY  UNION ALL
  SELECT 6 AS ID,'test6' AS NAME,23 as Age,'GZ' AS CITY
  )
  
from (
select b.*,'a' as c1 from tmp1 b union all
select id,name,age,city,'b' as c1 from tmp2 
) E

SELECT E.ID,E.NAME,E.Age,E.CITY,c1
 WHERE E.CITY = 'SZ';


4.10	GROUP BY\ORDER BY\SORT BY\DISTRIBUTE BY\CLUSTER BY
SELECT /*+STREAMTABLE(s)*/
       s.ymd,
       s.symbol,
       s.price_close,
       d.dividend
  from stocks s 
  join dividends d on s.ymd = d.ymd and s.symbol = d.symbol
 where 1=1
 distribute by symbol
 sort by s.symbol asc,
         s.price_close asc;
;

5	Load数据到Hive表语法
--Load数据到Hive表语法(这个命令作用:如果分区目录不存在,会先创建分区，然后把文件copy到对应的目录下)
LOAD DATA LOCAL INPATH '${env:HOME}/california-employees'
OVERWRITE INTO TABLE employees
PARTITION (country = 'CN',state = 'GD');

--从本地加载数据到Hive表
LOAD DATA LOCAL INPATH 'employee.txt' OVERWRITE INTO TABLE example.employee partition (century='21',year='2012');

--从另一个表加载数据到Hive表
INSERT INTO TABLE company.person PARTITION(century= '21',year='2010')
SELECT id, name, age, birthday FROM company.person_tmp WHERE century= '23' AND year='2010';


--导出数据(导出数据到本地目录)
INSERT OVERWRITE LOCAL DIRECTORY '/tmp/ca_employees'
select name,salary,address
  from employees
 where se.state = 'GD';

--导出数据:输出多个文件--
FROM staged_employees se
INSERT OVERWRITE DIRECTORY '/tmp/gd_employees'
select * where se.cnty = 'CH' AND se.state = 'GD'
INSERT OVERWRITE DIRECTORY '/tmp/gx_employees'
select * where se.cnty = 'CH' AND se.state = 'GX'
INSERT OVERWRITE DIRECTORY '/tmp/yn_employees'
select * where se.cnty = 'CH' AND se.state = 'YN';

--导出数据到HDFS
EXPORT TABLE company.person TO '/department';

--从HDFS导入数据
IMPROT TABLE company.person FROM '/department‘;


 

 

create table if not exists dm_isc.dm_plan_mps_f_hive (
   plan_id bigint,
   plan_natural_week_Monday string,
   source_plan_id string,
   data_source_type string,
   create_date string,
   last_modified_date string,
   del_flag string
)
comment 'dm_plan_mps_f'
partitioned by (plan_natural_week_monday string,data_source_type string)
row format delimited fields terminated by '\001'
stored as orcfile;

set mapred.job.name = dm_isc.dm_plan_prod_fcst_f.xwx559919;
set hive.auto.convert.join = true;
set hive.ignore.mapjoin.hint=true;
set hive.merge.mapredfiles=True;
set hive.merge.size.per.task=256000000;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.mapjoin.localtask.max.memory.usage=0.999;
set hive.exec.parallel=true;

--set mapred.max.split.size=256000000;
--set mapred.min.split.size.per.node=256000000;
--set mapred.min.split.size.per.rack=256000000;
--set hive.input.format=org.apache.hadoop.hive.ql.io.CombineHiveInputFormat;
--set hive.exec.reducers.bytes.per.reducer=1024000000;
--set mapred.reduce.parallel.copies=10;
--set mapred.job.reuse.jvm.num.tasks=8;
