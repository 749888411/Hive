1.sigma.py

#!/usr/bin/env python
# -*- coding:utf8 -*-


import os
from configparser import ConfigParser


class EnvironConfig:
    def __init__(self, db_file="env.cfg"):
        self.__db_file = db_file
        try:
            self.__cp = ConfigParser()
        except:
            print ("ConfigParser() error")
        self.__cp.read(db_file)

    def __getStr(self, section, option):
        if(None == self.__cp):
            print ("self.__cp is null")
            return ""
        StrValue = self.__cp.get(section, option)
        if (None != StrValue ):
            return StrValue
        else:
            return ""

    def __getInt(self,section,option):
        StrValue = self.__getStr(section,option)
        if("" != StrValue ):
            return int(StrValue)
        else:
            return -1

    def __getenvironmentType(self):
        type = self.__getStr("env", "type")
        if (None == type or "" == type):
            print("get environment type error")
            return ""
        else:
            return type

    def getStrOption(self,option):
        type = self.__getenvironmentType()
        try:
            value1 = self.__getStr(type, option)
            return value1
        except:
            print('''read [%s:%s] error''' % (type, option))
            return ""

    def getIntOption(self,option):
        value1 = self.getStrOption(option)
        if ("" != value1):
            return int(value1)
        else:
            return -1

    def getCfgStrValue(self,section, option):
        try:
            value1 = self.__getStr(section, option)
            if ("" != value1):
                return value1
            else:
                return ""
        except:
            print('''read [%s:%s] error''' % (section, option))

    def getCfgIntValue(self,section, option):
        value1 = self.getCfgStrValue(section, option)
        if ("" != value1):
            return int(value1)
        else:
            return -1


if __name__ == '__main__':
    env_path = EnvironConfig()
    print(env_path.getStrOption("user"))
    
    
2.rdbswrap.py
    
    
from __future__ import print_function
import os

import sys
import env_config
import cx_Oracle

def initEnvironment():
    cfg = env_config.EnvironConfig()
    pyPath = cfg.getStrOption("py_lib_path")
    if(None == pyPath or "" == pyPath ):
        print ("python path is null,for example: '/u02/FI_Client/Spark2x/spark/python/lib/'?")
        return
    sys.path.insert(0,pyPath)
    print(sys.path)
initEnvironment()

from pyspark import SparkContext
from pyspark import SparkConf
from pyspark.sql import SparkSession

from pyspark.sql.types import *

'''
  日志
  异常

'''

class SparkforOracle:
    def __init__(self,db_string,user,passwd,appname="db_instance"):
        self.db_string = db_string
        self.user = user
        self.passwd = passwd
        self.mysqld = "com.mysql.jdbc.Driver"
        self.oracled = "oracle.jdbc.driver.OracleDriver"
        cfg = env_config.EnvironConfig()
        self.conf = SparkConf().setMaster(cfg.getStrOption("spark_master"))\
          .set("spark.driver.extraClassPath", cfg.getStrOption("ora_dri_addr")) \
          .set("spark.default.parallelism",cfg.getStrOption("spark_default_parallelism"))\
          .set("spark.sql.shuffle.partitions",cfg.getStrOption("spark_sql_shuffle_partitions"))\
          .set("spark.total.executor.cores",cfg.getStrOption("spark_total_executor_cores"))\
          .set("spark.num.executors",cfg.getStrOption("spark_num_executors"))\
          .set("spark.executor.memory",cfg.getStrOption("spark_executor_memory"))\
          .set("spark.executor.cores",cfg.getStrOption("spark_executor_cores"))\
          .set("spark.driver.memory",cfg.getStrOption("spark_driver_memory"))\
          .set("spark.driver.cores",cfg.getStrOption("spark_driver_cores"))

        self.spark = SparkSession.builder \
            .appName(appname) \
            .config(conf=self.conf) \
            .enableHiveSupport() \
            .getOrCreate()
        self.sc = self.spark.sparkContext

    # .option("fetchsize", fetchnum) \
    def readFromRDBS(self, query_text, dbtype="oracle", fetchnum=1000):
        driver = self.oracled if dbtype == "oracle" else self.mysqld
        print(driver)
        dataframe = self.spark.read.format("jdbc") \
            .option("url", self.db_string) \
            .option("dbtable", query_text) \
            .option("driver", driver) \
            .option("user", self.user) \
            .option("password", self.passwd) \
            .load()
        return dataframe

    def writeToHive(self, tablename, dataframe):
        dataframe.createTempView('table_source')
        self.spark.sql("use eye_temp")
        try:
            self.spark.sql("select * from %s where 1=0" % tablename)
            self.spark.sql('insert into %s select * from table_source' % tablename)
        except:
            self.spark.sql('create table %s as select * from table_source' % tablename)
        finally:
            self.spark.catalog.dropTempView('table_source')

    def readFromHive(self, tablename):
        dataframe = self.spark.sql(tablename)
        dataframe.cache()

        for column in dataframe.columns:
            res = column.upper()
            dataframe = dataframe.withColumnRenamed(column, res)
        schema = dataframe.dtypes
        create_oracle_table_sql = []

        for col in schema:
            if 'int' in col[1] or 'decimal' in col[1]:
                col_name = col[0]
                col_type = 'number'
                col_sql = '%s %s' % (col_name, col_type)
                create_oracle_table_sql.append(col_sql)
            if col[1] == 'string':
                col_name = col[0]
                col_type = 'varchar2(3072)'
                col_sql = '%s %s' % (col_name, col_type)
                create_oracle_table_sql.append(col_sql)
            if col[1] == 'timestamp':
                col_name = col[0]
                col_type = 'date'
                col_sql = '%s %s' % (col_name, col_type)
                create_oracle_table_sql.append(col_sql)
        sql_create = ",\n".join(create_oracle_table_sql)
        sql_res = "create table %s (%s)" % (tablename, sql_create)
        dataframe.cache()
        print(sql_res)
        print(dataframe.dtypes)
        print(dataframe.columns)
        return dataframe, sql_res

    def writeToOracle(self, dataframe, tablename, loadmode,dbtype="oracle"):
        driver = self.oracled if dbtype == "oracle" else self.mysqld
        dataframe.write.mode(loadmode)\
            .format("jdbc")\
            .option("url", self.db_string) \
            .option("dbtable", tablename) \
            .option("user", self.user) \
            .option("password", self.passwd) \
            .option("driver", driver) \
            .option("batchsize", 10000) \
            .save()

    def cxOraUpdate(self,con_str,sql):
        try:
            print (sql)
            conn = cx_Oracle.connect(con_str)
            cs = conn.cursor()
            cs.execute(sql)
            conn.commit()
            cs.close()
            conn.close()
        except cx_Oracle.DatabaseError as msg:
            print ("cx_oracle exception:",msg)
            cs.close()
            conn.close()


    def cxOraSelect(self,con_str,sql):
        try:
            print (sql)
            conn = cx_Oracle.connect(con_str)
            cs = conn.cursor()
            x = cs.execute(sql)
            v1 = x.fetchall()
            cs.close()
            conn.close()
            return v1
        except cx_Oracle.DatabaseError as msg:
            print("cx_oracle exception:", msg)

            return []

    def cxOraCur(self,con_str,sql):
        try:
            print (sql)
            conn = cx_Oracle.connect(con_str)
            cs = conn.cursor()
            cs.execute(sql)
            des_res = cs.description
            cs.close()
            conn.close()
            return des_res
        except cx_Oracle.DatabaseError as msg:
            print("cx_oracle exception:", msg)

            return []
    def readFromRDBSByCx(self, con_str,query_text, dbtype="oracle"):

        print (query_text)
        des_res = self.cxOraCur(con_str,query_text)
        col_list = []
        for type_per in des_res:
            col_name = type_per[0]
            col_type = type_per[1].__name__

            if col_type == 'NUMBER':
                if type_per[-3] == 0:
                    col_struct = StructField(col_name, LongType(), True)
                else:
                    de_len = type_per[-3]
                    de_pre = type_per[-2]
                    col_struct = StructField(col_name, DecimalType(de_len, de_pre), True)
            elif col_type == 'STRING':
                col_struct = StructField(col_name, StringType(), True)
            elif col_type == 'DATETIME' or col_type == 'TIMESTAMP':
                col_struct = StructField(col_name, TimestampType(), True)
            else:
                raise Exception('未指定的类型,需要添加')

            col_list.append(col_struct)
        schema = StructType(col_list)
        value1 = self.cxOraSelect(con_str,query_text)
        df = self.spark.createDataFrame(value1,schema)

        return df



if __name__ == '__main__':
    cfg = env_config.EnvironConfig()
    print (cfg.getStrOption("user"))
    c1 = SparkforOracle(cfg.getStrOption("db_string"),cfg.getStrOption("user"),cfg.getStrOption("passwd"))
    sql1 = "(select * from ma_om_detail) alias"
    df = c1.readFromRDBS(sql1,"oracle")
    df.show()
    #c1.writeToOracle(df,"ma_om_detail_0704","append","mysql")

3.env.cfg


[env]
type=test_env

[comp]
result_table = op_ma_om_vendor
alert_table = op_ma_om_vendor_alert
source_table = op_ma_om_detail_2
density_table = op_ma_om_density
alert_config_table = u_alert_config
cm_table = u_cm
mailing_list_table = u_mailing_list
alert_dic_table = u_alert_dic
alert_detail_table = u_alert_detail

sample_num = 10
batch_short = 3
batch_long = 5
compute_size = 500
compute_days = 0
compute_start_time = 2014-01-01
compute_end_time = 2019-12-01
density_start_time = 2014-01-01
density_end_time = 2019-07-01
is_print_debug = 0
is_acc = false
sigma_table = op_ma_om_vendor_sigma
db_type = oracle
loadmode = append
show_length = 1000
retrytimes=1
min_density = 1
max_density = 9
bin_density = 40
level_serious = 3
level_normal= 2
level_info = 1

[prod_env]
user = hpdm
passwd = hpdm
cx_oracle_str = hpdm/hpdm@10.1.196.212/insightorcl
db_string =jdbc:oracle:thin:@10.1.196.212:1521:insightorcl
ora_dri_addr = ./driver/ojdbc14.jar
#ora_dri_addr = ./driver/mysql-connector-java-5.1.47-bin.jar
py_lib_path = /u02/FI_Client/Spark2x/spark/python/lib/

spark_master = yarn
spark_default_parallelism = 240
spark_sql_shuffle_partitions = 240
spark_total_executor_cores = 72
spark_num_executors = 24
spark_executor_memory = 16G
spark_executor_cores = 3
spark_driver_memory = 32G
spark_driver_cores = 8


[test_env]
user = hpdm
passwd = hpdm
cx_oracle_str = hpdm/hpdm@nkdb104105-cls.huawei.com/nkuatk2
db_string = jdbc:oracle:thin:@nkdb104105-cls.huawei.com:1521:nkuatk2
#db_string = jdbc:mysql://127.0.0.1:3306/db_pangu_rtn?serverTimezone=Hongkong&useSSL=false
ora_dri_addr = ./driver/ojdbc6_g.jar
#ora_dri_addr = ./driver/mysql-connector-java-5.1.47-bin.jar
py_lib_path = D:\

spark_master = local[4]
spark_default_parallelism = 4
spark_sql_shuffle_partitions = 4
spark_total_executor_cores = 16
spark_num_executors = 4
spark_executor_memory = 2G
spark_executor_cores = 4
spark_driver_memory = 2G
spark_driver_cores = 8

4.config.py

#!/usr/bin/env python
# -*- coding:utf8 -*-


import os
from configparser import ConfigParser


class EnvironConfig:
    def __init__(self, db_file="conf/env.cfg"):
        self.__db_file = db_file
        try:
            self.__cp = ConfigParser()
        except:
            print ("ConfigParser() error")
        self.__cp.read(db_file)

    def __getStr(self, section, option):
        if(None == self.__cp):
            print ("self.__cp is null")
            return ""
        StrValue = self.__cp.get(section, option)
        if (None != StrValue ):
            return StrValue
        else:
            return ""

    def __getInt(self,section,option):
        StrValue = self.__getStr(section,option)
        if("" != StrValue ):
            return int(StrValue)
        else:
            return -1

    def __getenvironmentType(self):
        type = self.__getStr("env", "type")
        if (None == type or "" == type):
            print("get environment type error")
            return ""
        else:
            return type

    def getStrOption(self,option):
        type = self.__getenvironmentType()
        try:
            value1 = self.__getStr(type, option)
            return value1
        except:
            print('''read [%s:%s] error''' % (type, option))
            return ""

    def getIntOption(self,option):
        value1 = self.getStrOption(option)
        if ("" != value1):
            return int(value1)
        else:
            return -1

    def getCfgStrValue(self,section, option):
        try:
            value1 = self.__getStr(section, option)
            if ("" != value1):
                return value1
            else:
                return ""
        except:
            print('''read [%s:%s] error''' % (section, option))

    def getCfgIntValue(self,section, option):
        value1 = self.getCfgStrValue(section, option)
        if ("" != value1):
            return int(value1)
        else:
            return -1


if __name__ == '__main__':
    env_path = EnvironConfig()
    print(env_path.getStrOption("user"))
    
    
5.env_config.py
 
 #!/usr/bin/env python
# -*- coding:utf8 -*-


import os
from configparser import ConfigParser


class EnvironConfig:
    def __init__(self, db_file="env.cfg"):
        self.__db_file = db_file
        try:
            self.__cp = ConfigParser()
        except:
            print ("ConfigParser() error")
        self.__cp.read(db_file)

    def __getStr(self, section, option):
        if(None == self.__cp):
            print ("self.__cp is null")
            return ""
        StrValue = self.__cp.get(section, option)
        if (None != StrValue ):
            return StrValue
        else:
            return ""

    def __getInt(self,section,option):
        StrValue = self.__getStr(section,option)
        if("" != StrValue ):
            return int(StrValue)
        else:
            return -1

    def __getenvironmentType(self):
        type = self.__getStr("env", "type")
        if (None == type or "" == type):
            print("get environment type error")
            return ""
        else:
            return type

    def getStrOption(self,option):
        type = self.__getenvironmentType()
        try:
            value1 = self.__getStr(type, option)
            return value1
        except:
            print('''read [%s:%s] error''' % (type, option))
            return ""

    def getIntOption(self,option):
        value1 = self.getStrOption(option)
        if ("" != value1):
            return int(value1)
        else:
            return -1

    def getCfgStrValue(self,section, option):
        try:
            value1 = self.__getStr(section, option)
            if ("" != value1):
                return value1
            else:
                return ""
        except:
            print('''read [%s:%s] error''' % (section, option))

    def getCfgIntValue(self,section, option):
        value1 = self.getCfgStrValue(section, option)
        if ("" != value1):
            return int(value1)
        else:
            return -1


if __name__ == '__main__':
    env_path = EnvironConfig()
    print(env_path.getStrOption("user"))
