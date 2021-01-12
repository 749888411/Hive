# Hive
现有公共函数如下：
1. dmp.ora_decode
        函数说明：实现oracle中的decode函数，等同--if--then--then--then.....else逻辑
        使用示例：
                select dmp.ora_decode(1,2,'a');
                select dmp.ora_decode(1,2,'a',2,'b');
                select dmp.ora_decode(1,3,'a',2,'b','c');
        示例结果：
                NULL
                NULL
                c

2. dmp.is_null
        函数说明：判断入参是否为空
        使用示例：
                select dmp.is_null('');
                select dmp.is_null('c');
        示例结果：
                ture
                false

3. dmp.nvl_ext
        函数说明：判断入参1是否为空？不为空，返回参数1;为空，返回参数2
        使用示例：
                select dmp.nvl_ext('a','b');
                select dmp.nvl_ext('','c');
        示例结果：
                a
                c

4. dmp.nvl_pairs
        函数说明：按顺序判断成对参数（1-2,3-4,....）,返回第一个奇数位为空的偶数位。
        使用示例：
                select dmp.nvl_pairs('','a');
                select dmp.nvl_pairs('a','','','c');
                select dmp.nvl_pairs('a','c','c','d','','e');
        示例结果：
                a
                c
                e

5. dmp.str_to_array
        函数说明：将json字符串解析为字符串数组
        使用示例：
                select dmp.str_to_array('[{"qq":"ww","ee":"rr"}]');
        示例结果：
                ["{\"qq\":\"ww\",\"ee\":\"rr\"}"]

6. dmp.coalesce_ext
        函数说明：按顺序获得第一个不为空的字符
        使用示例：
                select dmp.coalesce_ext('','','b');
                select dmp.coalesce_ext('','a','','','b');
        示例结果：
                b
                a

7. dmp.get_dim_value
        函数说明：关联缓慢编码维定制udf函数（韦红绕 00476302）
        http://3ms.huawei.com/hi/group/3504321/thread_7797906.html?mapId=9586094
        使用示例：
            select dmp.get_dim_value('2016-12-18\u00012016-04-19','2019-01-03\u00012016-12-17'
            ,'1001\u00011002','2016-12-04');
        示例结果：
                1002

8.dmp.time_zone
        函数说明：服务主题时区转化函数，该函数绑定时区表（dm_sv.dm_sv_timezone_t）、
                    时令表（dm_sv.bas_sv_summer_winter_tz_f）该函数采用内存读表方式加载数据
        入参说明：国家代码、用来判断逻辑的时间、需要转换时区的时间
        使用示例：
            select dmp.time_zone('AU','2015/01/01 01:01:01','2019/09/25 19:32:41');
            select dmp.time_zone('AT','2015/05/11 11:11:11','2019/01/01 01:01:01');
        示例结果：
            2019/09/25 19:32:41
            2019/01/01 01:01:01

9. dmp.ora_lengthb
        函数说明：计算字符串的字节长度，同oracle中的lengthb函数一样。
        使用示例：
            select dmp.ora_lengthb('你好世界!');
            select dmp.ora_lengthb('ssssssss');
        示例结果：
            13
            8

10. dmp.ora_substrb
        函数说明：按字节长度进行截取，同oracle中的substrb函数一样。
        使用示例：
            select dmp.ora_substrb('世界aaa',0,4);
            select dmp.ora_substrb('世界aaa',4,4);
        示例结果：
            世
            界a

11. dmp.get_weekend_f
        函数说明：返回两个日期之间周六，周日的合计天数
        使用示例：
            select dmp.get_weekend_f('2018-12-28','2018-12-30');
            select dmp.get_weekend_f('2018-12-30','2018-12-30');
        示例结果：
            2
            1

12. dmp.get_week_hour
          函数说明：剔除节假日函数，计算某一时间范围内（除节假日+华为小周末外）的工作时长（小时）
          入参说明：节假日字符串、开始时间、结束时间、上午上班时间、上午下班时间、下午上班时间、下午下班时间
          使用示例：
          select dmp.get_week_hour('2018-09-18 00:00:00', '2018-09-17 03:29:40', '2018-09-19 08:53:32', '08:30:00', '12:00:00', '13:30:00', '18:00:00');
          示例结果：
               8.39

13. dmp.get_nonwork_day
         函数说明：计算从t开始到第一个工作日之间的节假日天数
         入参说明：开始时间字符串、节假日字符串；
         使用示例：
         select dmp.get_nonwork_day('20190930','2019-10-01 00:00:00,2019-10-02 00:00:00,2019-10-03 00:00:00');
          示例结果：
              3

14. dmp.aes_hex_encrypt
        函数说明：AES加密函数
        入参说明：明文、加密秘钥
        使用示例：
                select dmp.aes_hex_encrypt('wh12622','ideal!@#$%^%$#@*');
        示例结果：
                2c206f2e37ee24488a4a413d4fd78818

15. dmp.aes_hex_decrypt
        函数说明：AES解密函数
        入参说明：密文、加密秘钥
        使用示例：
                select dmp.aes_hex_decrypt('2c206f2e37ee24488a4a413d4fd78818','ideal!@#$%^%$#@*');
        示例结果：
                wh1262214

16. dmp.get_field
        函数说明：解析json字符串，获取该字段内容
        入参说明：json字符串、提取字段
        使用示例：
                select dmp.get_field('{"code":"0","message":"good"}','message');
                select dmp.get_field('{"idx":"aaa","pay":{"days":"15"},"comm":"bbb"}','pay.days');
                select dmp.get_field('{"pay":[{"name":"aa"},{"name":"bb"}]}','pay.1.name');
         示例结果：
                good
                15
                bb

17. dmp.uuid
        函数说明：获取32位随机uuid字符串
        使用示例：
                select dmp.uuid();
        示例结果：
                360a2ccbacaa41d9895ece4579a480e9

18. dmp.date_from_to
        函数说明：获取起始至结束日期的yyyymm值
        入参说明：起始日期（yyyymm）、结束日期（yyyymm）
        使用示例：
                select dmp.date_from_to('201801','201908');
        示例结果：
                201801,201802,201803,201804

19. dmp.uuid_code
        函数说明：获取19位随机uuid code数值
        使用示例：
                select dmp.uuid_code();
        示例结果：
                1747898166104639776

20. dmp.period
        函数说明：入参为1时，返回1至当前月的日期（yyyymm）,入参为2时，返回上一年1月至当前月日期
        入参说明：当前日期、年份数值
        使用示例：
                select dmp.period(current_date,1);
                select dmp.period('2020-03-01',2);
        示例结果：
                202007,202006,202005,202004,202003,202002,202001
                201912,201911,...................................,202002,202001

21. dmp.sequence
        函数说明：获取序列号（同一任务内序列号不重复）
        使用示例：
                select dmp.sequence();
        示例结果：
                1

22. dmp.geohash_encode
        函数说明：加密网格
        使用示例：
                select dmp.geohash_encode('22.65913','114.00699');
        示例结果：
                ws10fk

23. dmp.geohash_decode
        函数说明：解密网格
        使用示例：
                select dmp.geohash_decode('ws10fk');
        示例结果：
                22.65,114.01

24. dmp.calculateAdjacent
        函数说明：获取周围8网格
        使用示例：
                select dmp.calculateAdjacent('ws10fk');
        示例结果：
                ws10fj,ws10fm,ws10ft,ws10fh,ws10fs,ws10f5,ws10f7,ws10fe

25. dmp.neighbor
        函数说明：通过偏移量获取周围网格
        使用示例：
                select dmp.neighbor('ws10fk',0,1);
        示例结果：
                ws10fm

26. dmp.trans2Sha256
        函数说明：base64解密
        使用示例：
                select dmp.trans2Sha256('Xpju63ZvzcMc2Epa$nTdD5BIDUHJFZ5x3rW5o1Uj5bE=');
        示例结果：
                5e98eeeb766fcdc31cd84a5afe74dd0f90480d41c9159e71deb5b9a35523e5b1

27. dmp.privateInfoEncrypt
        函数说明：智家app上报加密处理函数
        入参说明：明文
        使用示例：
                select dmp.privateInfoEncrypt('user01');
        示例结果：
                d0ef7fad6476c2e7dca859523776020***3f5d56fe7ff08482d0f6ea8524b0a8

28. dmp.ora_instr
        函数说明：实现oracle中的instr函数
        入参说明：母字符串,子字符串,从第几个字符开始找,找第几次匹配
        使用示例：
                select dmp.ora_instr('abcdefgcdcd','cd');
                select dmp.ora_instr('abcdefgcdcd','cd',10);
                select dmp.ora_instr('abcdefgcdcd','cd',5,2);
                select dmp.ora_instr('abcdefgcdcd','cd',-1,2);
        示例结果：
                3
                10
                10
                8

29. dmp.kms_encrypt
        函数说明：kms加密函数
        使用示例：
                select dmp.kms_encrypt('hello kms');
        示例结果：
                2020010816220940oneXIY4......./9jqVQSbBlPYrzpLTEw==

30. dmp.kms_decrypt
        函数说明：kms解密函数
        使用示例：
                select dmp.kms_decrypt('2020010816220940oneXIY4......./9jqVQSbBlPYrzpLTEw==');
        示例结果：
                hello kms
31. dmp.pocnlwinflg
        函数说明：
        使用示例：
     select dmp.pocnlwinflg('N',1.2,'sw000224','M','2025-03-10',1.3,'2026-03-11','2028-04-10','2026-02-10','2024-03-10','2026-05-10');
        示例结果：
             N

32. dmp.pinyin_decode
        函数说明：返回字符串的拼音
        使用示例：
             select dmp.pinyin_decode('你好');
        示例结果：
             NI HAO

33. dmp.pinyin_decode_first
        函数说明：返回拼音首字母
        使用示例：
             select dmp.pinyin_decode_first('你好');
        示例结果：
             nh

34. dmp.blobToString
        函数说明：oracle Blob字段内容sqoop到hive 中16进制字段内容还原为对应的内容
        使用示例：
            select dmp.blobToString ('ac ed 00 05 73 72 00 22 6a 61 76 61 78 2e 73 71 6c 2e 72 6f 77 73 65 74 2e 73 65 72 69 61 6c 2e 53 65 72 69 61 6c 42 6c 6f 62 8e f8 6b 51 8c 14 92 e7 03 00 04 4a 00 03 6c 65 6e 4a 00 07 6f 72 69 67 4c 65 6e 4c 00 04 62 6c 6f 62 74 00 0f 4c 6a 61 76 61 2f 73 71 6c 2f 42 6c 6f 62 3b 5b 00 03 62 75 66 74 00 02 5b 42 78 70 00 00 00 00 00 00 00 13 00 00 00 00 00 00 00 13 70 75 72 00 02 5b 42 ac f3 17 f8 06 08 54 e0 02 00 00 78 70 00 00 00 13 3c 70 3e e7 9f ad e6 9c 9f e6 8e aa e6 96 bd 3c 2f 70 3e 78');
        示例结果：
             <P>短期措施</p>
