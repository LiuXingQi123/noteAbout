tb_yppg_fbk     t1,--相当于【药品品规发布库】
v_ybbm_mlsxh    t2,--相当于【这个没有了，】
tb_yppg_fbk     a,--相当于【药品品规发布库】
tb_ypwjgz_fbk   b,--相当于【药品物价规则发布库】
tb_yellowline1  c,--相当于【药品议价特殊药品黄线表】
tb_ypcggz_fbk   d,--相当于【药品采购规则发布库】
tb_ypscyjjg     e,--相当于【药品首次议价 DRUGPRIC_FSTRSLT_B】
v_ybbm_mlsxh    f,--相当于【关联】[医保目录细分表HILIST_SUBD_B 药品医保规则发布库DRUG_HI_RLS_B][目录中西医标志HILIST_ICD_TYPE  目录顺序号HILIST_CODE]
tb_ypwjgz_bdkmx g--相当于【】
tb_dic_ypjx c,【药品剂型字典？DRUG_DOSFORM_A】



#nstep      := 1;
tb_ypcggz_fbk a,【】
v_yppg_fbk b,【】

#nstep := 2;
tb_yellowline1 a, 
tb_ypscyjjg c,
tb_ypwjgz_fbk b,
tb_ypwjgz_bdkmx d【？】

#nstep := 3;
tb_yppg_fbk     t1,
v_ybbm_mlsxh    t2,【？】
tb_yppg_fbk     a,
tb_ypwjgz_fbk   b,
tb_yellowline1 c,
tb_ypcggz_fbk   d,
tb_ypscyjjg     e,
v_ybbm_mlsxh    f,
tb_ypwjgz_bdkmx g,【？】

#nstep := 4;
tb_yppg_fbk     t1,
v_ybbm_mlsxh   t2,
tb_yppg_fbk     a,
v_ybbm_mlsxh   b,
tb_ypcggz_fbk   d,
tb_ypwjgz_fbk   e,
tb_yellowline1 f,
tb_ypscyjjg     g,
tb_ypwjgz_bdkmx h

#nstep := 6;
v_ybbm_mlsxh   t1,
tb_yppg_fbk     t2,
tb_ypmlk        a,【？】
v_ybbm_mlsxh   b,
tb_ypwjgz_fbk   d,
tb_ypscyjjg     f,
tb_yppg_fbk     g,
tb_ypcggz_fbk   h

#nstep := 7;
tb_yyzgcgj m1, 【？】
tb_yyzgcgj m2,【？】
tb_yyzgcgj m3【？】

#nstep := 8;
v_yppg_fbk     t1,
v_ybbm_mlsxh    t2,
v_yppg_fbk     a,  
v_ybbm_mlsxh    c ,
tb_yyzgcgj m1, 
tb_yyzgcgj m2,
tb_yyzgcgj m3

#nstep := 9;
v_yppg_fbk     t1, 
v_yppg_fbk     a, 
tb_yyzgcgj m1, 
tb_yyzgcgj m2,
tb_yyzgcgj m3


#函数
v_yppg_fbk t1, 【药品品规发布库,`drug_rls_b`】
tb_yjcbl t2,   【药品议价差比率表？DRUGPRIC_DIFF_RATE_B】
tb_ypybgz_fbk a,【药品医保规则发布库,DRUG_HI_RLS_B】
tb_ybgz_mlgzxx b,【药品医保目录发布库？HILIST_INFO_RLS_B】
tb_dic_ypjx c,【药品剂型字典？DRUG_DOSFORM_A】
TB_YJCBL 【】

SELECT TRIM(substrb(t1.zxdwhl, 1, 10)), --含量
TRIM(substrb(t1.zxdwhl, 31, 10)), --装量
TRIM(substrb(t1.zxdwhl, 41, 10)), --包装数量
TRIM(substrb(t1.zxdwhl, 66, 5)), --计价数量单位
TRIM(substrb(t1.zxdwhl, 71, 10)), --服用天数
CASE WHEN t3.jxmc IN (SELECT gljxmc FROM TB_YJCBL WHERE yxbz = '1') THEN '1' ELSE '0' END,
CASE WHEN zxybz='1' THEN nvl(t2.cbl, 1) WHEN zxybz='2'  AND  t1.bsjx LIKE  '%无糖%' THEN 1.1 ELSE 1 END ,--20210825:中成药如果表述剂型含无糖字样则为晚唐的话，有糖*1.1=无糖
t1.ZXYBZ
INTO V_HL, V_ZL, V_BZSL, V_JJSLDW, V_FYTS, V_CBCS, v_cbl,v_zxybz
FROM 
v_yppg_fbk t1, 
tb_yjcbl t2,
(SELECT DISTINCT yptbdm,c.jxmc FROM tb_ypybgz_fbk a,tb_ybgz_mlgzxx b,tb_dic_ypjx c
WHERE a.mlsxh=b.mlsxh AND a.zxybz=b.zxybz AND b.yxbz='1' AND nvl(b.gljxbm,b.jxbm)=c.jxbm(+) AND c.yxbz(+)='1' ) t3
WHERE /*t1.bsjx = t2.bsjx(+)*/
instrb(t1.bsjx,t2.bsjx(+))>0 AND t1.yptbdm=t3.yptbdm
AND t2.yxbz(+) = '1'
AND t1.yptbdm = PI_YPTBDM;

#函数======
SELECT 
CASE WHEN C.`DOSFORM_FORM_CODE` IN (SELECT `DOSFORM_PARENT_NAME` FROM `drugpric_diff_rate_b` WHERE `VALI_FLAG` = '1') THEN '1' ELSE '0' END
,CASE WHEN A.`DRUG_ICD_TYPE`='1' THEN IFNULL(B.`DIFF_RATE`, 1) WHEN A.`DRUG_ICD_TYPE`='2'  AND  A.`DOSFORM_NAME` LIKE  '%无糖%' THEN 1.1 ELSE 1 END
,A.`DRUG_ICD_TYPE`
INTO V_HL, V_ZL, V_BZSL, V_JJSLDW, V_FYTS, V_CBCS, v_cbl,v_zxybz
FROM `drug_rls_b` AS A,`drugpric_diff_rate_b` AS B
,(SELECT DISTINCT A.`DRUG_SH_CODE`,C.`DOSFORM_FORM_CODE`
FROM `drug_hi_rls_b` A,`hilist_info_rls_b` B,`drugpric_diff_rate_b` C
WHERE A.`HILIST_CODE`=b.`HILIST_CODE`
AND A.`HILIST_ICD_TYPE`=B.`HILIST_ICD_TYPE`
AND IFNULL(B.`DOSFORM_PARENT_CODE`,B.`DOSFORM_CODE`)=C.`DOSFORM_FORM_CODE`
AND C.`VALI_FLAG`='1') AS C
WHERE 1=1
AND A.`DRUG_SH_CODE`=C.`DRUG_SH_CODE`
AND A.`DRUG_SH_CODE`=''






#第一阶段
	SET PO_RETCODE=1;
	SET nstep=1;
    SELECT CASE
             WHEN gzyj LIKE '紧缺药品%' THEN
              '紧缺药品'
             WHEN nvl(SUBSTR(TRIM(b.yptsbz), 15, 1), 0) = '1' OR
                  nvl(SUBSTR(TRIM(b.yptsbz), 16, 1), 0) = '1' THEN
              '原研药品/参比制剂'
             WHEN gzyj LIKE '通过评价%' THEN
              '通过评价'
             WHEN gzyj LIKE '医保药品%' THEN
              '医保药品'
             WHEN gzyj LIKE '新增医保%' THEN
              '新增医保'
             WHEN gzyj LIKE '抗癌药品%' THEN
              '抗癌药品'
             ELSE
              NULL
           END,
           CASE
             WHEN gzyj LIKE '%新申请%' THEN
              '1'
             ELSE
              '0'
           END,
           CASE
             WHEN nvl(TRIM(substrb(b.zxdwhl, 1, 10)), 0) <> '0' AND nvl(TRIM(substrb(b.zxdwhl, 1, 10)), 0) <> '0.0' THEN
              TRIM(substrb(b.zxdwhl, 1, 10))
             WHEN nvl(TRIM(substrb(b.zxdwhl, 31, 10)), 0) <> '0' AND nvl(TRIM(substrb(b.zxdwhl, 31, 10)), 0) <> '0.0' THEN
              TRIM(substrb(b.zxdwhl, 31, 10))
             ELSE
              '1'
           END 
      INTO v_ypfl, v_sfxsq, v_hl 
      FROM tb_ypcggz_fbk a, v_yppg_fbk b
     WHERE a.yptbdm = b.yptbdm
       AND a.yptbdm = PI_YPTBDM;
       
       

tb_ypcggz_fbk a【药品采购规则发布库】
v_yppg_fbk b【药品品规发布库】

SELECT CASE WHEN A.`DRUG_INQ_TYPE` = '1' THEN '紧缺药品'
WHEN IFNULL(SUBSTR(TRIM(B.`DRUG_SP_FLAG`), 15, 1), 0) = '1' OR IFNULL(SUBSTR(TRIM(B.`DRUG_SP_FLAG`), 16, 1), 0) = '1' THEN '原研药品/参比制剂'
WHEN A.`DRUG_INQ_TYPE` = '2' THEN '通过评价'
WHEN A.`DRUG_INQ_TYPE` = '4' THEN '医保药品'
WHEN A.`DRUG_INQ_TYPE` = '5' THEN '新增医保'
WHEN A.`DRUG_INQ_TYPE` = '3' THEN '抗癌药品'
ELSE NULL END,
A.`IS_NEWDCLA_FLAG`,
CASE WHEN IFNULL(TRIM(B.`CNTE`), 0) <> '0' AND IFNULL(TRIM(B.`CNTE`), 0) <> '0.0' THEN TRIM(B.`CNTE`)
WHEN IFNULL(TRIM(B.`LGCYP`), 0) <> '0' AND IFNULL(TRIM(B.`LGCYP`), 0) <> '0.0' THEN TRIM(B.`LGCYP`)
ELSE '1' END 
INTO v_ypfl, v_sfxsq, v_hl 
FROM `drug_purc_rls_b` AS A, `drug_rls_b` AS B
WHERE A.`DRUG_SH_CODE` = B.`DRUG_SH_CODE`
AND A.`DRUG_SH_CODE` = PI_YPTBDM;



#第二阶段
SELECT MAX(CASE
             WHEN v_sfxsq = '1'   THEN
              NULL
             WHEN b.bz LIKE  '%依据05%' THEN to_number(nvl(d.gzcsz, yjjg))
             ELSE
              nvl(a.jg, yjjg)
           END)
      INTO y1
      FROM tb_yellowline1 a, tb_ypscyjjg c,tb_ypwjgz_fbk b,tb_ypwjgz_bdkmx d
     WHERE a.yptbdm(+)=b.yptbdm AND b.yptbdm = c.yptbdm(+) 
       AND b.YPWJBDID=d.ypwjbdid AND gzlx='10'
       AND a.yxbz(+)='1' AND a.jsrq(+)>to_char(SYSDATE,'yyyyMMdd')
       AND c.yxbz(+) = '1'
       AND b.yptbdm = PI_YPTBDM;


tb_yellowline1 a
tb_ypscyjjg c
tb_ypwjgz_fbk b
tb_ypwjgz_bdkmx d
SELECT MAX(
CASE WHEN v_sfxsq = '1' THEN NULL
WHEN B.`MEMO` LIKE '%依据05%' THEN CAST(IFNULL(B.`REF_PURC_PRIC`, yjjg) AS DECIMAL(10,2)) ELSE CAST(IFNULL(A.`REF_PURC_PRIC`, yjjg) AS DECIMAL(10,2)) END) INTO y1
FROM `drugpric_yellow_spdrug_b` AS A, `drugpric_fstrslt_b` AS C,`drug_pric_rls_b` AS B
WHERE A.`DRUG_SH_CODE`=B.`DRUG_SH_CODE` AND B.`DRUG_SH_CODE` = C.`DRUG_SH_CODE`
AND B.`REF_PURC_RULE_TYPE`='10'
AND A.`VALI_FLAG`='1' 
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN A.`BEGIN_DATE` AND IFNULL(A.`END_DATE`,'99991231')
AND B.`DRUG_SH_CODE` = PI_YPTBDM;




       SELECT MAX(
CASE WHEN '1' = '1' THEN NULL
WHEN B.`MEMO` LIKE '%依据05%' THEN CAST(IFNULL(B.`REF_PURC_PRIC`, 20) AS DECIMAL(10,2)) ELSE IFNULL(A.`REF_PURC_PRIC`, 20) END)
FROM `drugpric_yellow_spdrug_b` AS A, `drugpric_fstrslt_b` AS C,`drug_pric_rls_b` AS B
WHERE A.`DRUG_SH_CODE`=B.`DRUG_SH_CODE` AND B.`DRUG_SH_CODE` = C.`DRUG_SH_CODE`
AND B.`REF_PURC_RULE_TYPE`='10'
AND A.`VALI_FLAG`='1' 
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN A.`BEGIN_DATE` AND IFNULL(A.`END_DATE`,'99991231')
AND B.`DRUG_SH_CODE` = PI_YPTBDM;








#第三阶段
SELECT CASE WHEN v_ypfl = '原研药品/参比制剂' THEN ROUND(MAX(CAST(
CASE WHEN  B.`EM_FLAG` IN ('1','2') THEN NULL  
WHEN B.`MEMO` LIKE  '%依据01%' THEN NULL 
WHEN B.`MEMO` LIKE  '%依据03%' THEN NULL
WHEN IFNULL(SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 15, 1), 0) = '1' OR IFNULL(SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 16, 1), 0) = '1' 
THEN IFNULL(CASE WHEN B.`MEMO` LIKE  '%依据05%' 
THEN CAST(B.`REF_PURC_PRIC` AS DECIMAL(10,2)) ELSE C.`REF_PURC_PRIC` END,E.`REF_PURC_PRIC`) END AS DECIMAL(10,2)) * sf_getcbjbyyp(PI_YPTBDM, v_hl) / sf_getcbjbyyp(A.`DRUG_SH_CODE`, v_hl)),2) 
ELSE IFNULL(ROUND(MAX(
CASE WHEN IFNULL(SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 15, 1), 0) = '1' OR IFNULL(SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 16, 1), 0) = '1' THEN NULL
--when LENGTH(a.zxdwhl) < 51 THEN NULL
WHEN B.`EM_FLAG` IN ('1','2') THEN NULL
WHEN D.`IS_NEWDCLA_FLAG` = '1' THEN NULL
WHEN B.`MEMO` LIKE  '%依据01%' THEN NULL 
WHEN B.`MEMO` LIKE  '%依据03%' THEN NULL 
WHEN B.`MEMO` LIKE  '%依据05%' THEN CAST(IFNULL(B.`REF_PURC_PRIC` ,E.`REF_PURC_PRIC`) AS DECIMAL(10,2)) ELSE CAST(IFNULL(C.`REF_PURC_PRIC` ,E.`REF_PURC_PRIC`) AS DECIMAL(10,2)) 
END * sf_getcbjbyyp(PI_YPTBDM, v_hl) /sf_getcbjbyyp(A.`DRUG_SH_CODE`, v_hl)),2), 
ROUND(MAX(CASE WHEN IFNULL(SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 15, 1), 0) = '1' OR IFNULL(SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 16, 1), 0) = '1' THEN NULL
--when LENGTH(a.zxdwhl) < 51 THEN NULL
WHEN B.`EM_FLAG` IN ('1','2') THEN NULL
WHEN B.`MEMO` LIKE  '%依据01%' THEN NULL 
WHEN B.`MEMO` LIKE  '%依据03%' THEN NULL
WHEN B.`MEMO` LIKE  '%依据05%' THEN CAST(IFNULL(B.`REF_PURC_PRIC` ,E.`REF_PURC_PRIC`) AS DECIMAL(10,2))
ELSE CAST(IFNULL(C.`REF_PURC_PRIC` ,E.`REF_PURC_PRIC`) AS DECIMAL(10,2)) END * sf_getcbjbyyp(PI_YPTBDM, v_hl) / sf_getcbjbyyp(A.`DRUG_SH_CODE`, v_hl)),2))
END INTO y2
FROM 
`drug_rls_b` AS A,
`drug_pric_rls_b` AS B,
`drugpric_yellow_spdrug_b` AS C,
`drug_purc_rls_b` AS D,
`drugpric_fstrslt_b` AS E
WHERE 1=1
AND A.`DRUG_SH_CODE` = B.`DRUG_SH_CODE`
AND B.`REF_PURC_RULE_TYPE`='10'
AND A.`DRUG_SH_CODE` = D.`DRUG_SH_CODE`
AND A.`DRUG_SH_CODE` = E.`DRUG_SH_CODE`
AND A.`DRUG_SH_CODE` = C.`DRUG_SH_CODE`
AND C.`VALI_FLAG`='1' 
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN C.`BEGIN_DATE` AND IFNULL(C.`END_DATE`,'99991231')
AND D.`PURC_STAS` <> '0'
AND E.`VALI_FLAG`='1'
AND A.`DRUG_SH_CODE` = PI_YPTBDM;






SELECT CASE WHEN '12' = '原研药品/参比制剂' THEN ROUND(MAX(CAST(
CASE WHEN  B.`EM_FLAG` IN ('1','2') THEN NULL  
WHEN B.`MEMO` LIKE  '%依据01%' THEN NULL 
WHEN B.`MEMO` LIKE  '%依据03%' THEN NULL
WHEN IFNULL(SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 15, 1), 0) = '1' OR IFNULL(SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 16, 1), 0) = '1' 
THEN IFNULL(CASE WHEN B.`MEMO` LIKE  '%依据05%' 
THEN CAST(B.`REF_PURC_PRIC` AS DECIMAL(10,2)) ELSE C.`REF_PURC_PRIC` END,E.`REF_PURC_PRIC`) END AS DECIMAL(10,2)) * 2),2) 
ELSE IFNULL(ROUND(MAX(
CASE WHEN IFNULL(SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 15, 1), 0) = '1' OR IFNULL(SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 16, 1), 0) = '1' THEN NULL
--when LENGTH(a.zxdwhl) < 51 THEN NULL
WHEN B.`EM_FLAG` IN ('1','2') THEN NULL
WHEN D.`IS_NEWDCLA_FLAG` = '1' THEN NULL
WHEN B.`MEMO` LIKE  '%依据01%' THEN NULL 
WHEN B.`MEMO` LIKE  '%依据03%' THEN NULL 
WHEN B.`MEMO` LIKE  '%依据05%' THEN CAST(IFNULL(B.`REF_PURC_PRIC` ,E.`REF_PURC_PRIC`) AS DECIMAL(10,2)) ELSE CAST(IFNULL(C.`REF_PURC_PRIC` ,E.`REF_PURC_PRIC`) AS DECIMAL(10,2)) 
END * 2),2), 
ROUND(MAX(CASE WHEN IFNULL(SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 15, 1), 0) = '1' OR IFNULL(SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 16, 1), 0) = '1' THEN NULL
--when LENGTH(a.zxdwhl) < 51 THEN NULL
WHEN B.`EM_FLAG` IN ('1','2') THEN NULL
WHEN B.`MEMO` LIKE  '%依据01%' THEN NULL 
WHEN B.`MEMO` LIKE  '%依据03%' THEN NULL
WHEN B.`MEMO` LIKE  '%依据05%' THEN CAST(IFNULL(B.`REF_PURC_PRIC` ,E.`REF_PURC_PRIC`) AS DECIMAL(10,2))
ELSE CAST(IFNULL(C.`REF_PURC_PRIC` ,E.`REF_PURC_PRIC`) AS DECIMAL(10,2)) END * 2),2))
END 
FROM 
`drug_rls_b` AS A,
`drug_pric_rls_b` AS B,
`drugpric_yellow_spdrug_b` AS C,
`drug_purc_rls_b` AS D,
`drugpric_fstrslt_b` AS E
WHERE 1=1
AND A.`DRUG_SH_CODE` = B.`DRUG_SH_CODE`
AND B.`REF_PURC_RULE_TYPE`='10'
AND A.`DRUG_SH_CODE` = D.`DRUG_SH_CODE`
AND A.`DRUG_SH_CODE` = E.`DRUG_SH_CODE`
AND A.`DRUG_SH_CODE` = C.`DRUG_SH_CODE`
AND C.`VALI_FLAG`='1' 
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN C.`BEGIN_DATE` AND IFNULL(C.`END_DATE`,'99991231')
AND D.`PURC_STAS` <> '0'
AND E.`VALI_FLAG`='1'
AND A.`DRUG_SH_CODE` = PI_YPTBDM;



#第四阶段
SELECT   MAX(
CASE 
--when LENGTH(A.ZXDWHL) < 51 THEN NULL
WHEN E.`EM_FLAG` IN ('1','2') THEN NULL
WHEN E.`MEMO` LIKE  '%依据01%' THEN NULL 
WHEN E.`MEMO` LIKE  '%依据03%' THEN NULL
WHEN E.`MEMO` LIKE  '%依据05%' THEN CAST(IFNULL(E.`REF_PURC_PRIC`, IF(G.`REF_PURC_PRIC`=0,NULL,G.`REF_PURC_PRIC`)) AS DECIMAL(10,2))
ELSE CAST(IFNULL(F.`REF_PURC_PRIC`, IF(G.`REF_PURC_PRIC`=0,NULL,G.`REF_PURC_PRIC`)) AS DECIMAL(10,2)) END * sf_getcbjbyyp(PI_YPTBDM, v_hl) /sf_getcbjbyyp(A.`DRUG_SH_CODE`, v_hl)) 
INTO r1
FROM 
`drug_rls_b` AS A,
`drug_purc_rls_b` AS D,
`drug_pric_rls_b` AS E,
`drugpric_yellow_spdrug_b` AS F,
`drugpric_fstrslt_b` AS G
WHERE 1=1
AND A.`DRUG_SH_CODE` = D.`DRUG_SH_CODE`
AND A.`DRUG_SH_CODE` = E.`DRUG_SH_CODE`
AND E.`REF_PURC_RULE_TYPE`='01'
AND A.`DRUG_SH_CODE` = G.`DRUG_SH_CODE`
AND A.`DRUG_SH_CODE` = F.`DRUG_SH_CODE`
AND F.`VALI_FLAG` = '1'
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN F.`BEGIN_DATE` AND IFNULL(F.`END_DATE`,'99991231')
AND D.`PURC_STAS` <> '0'
AND G.`VALI_FLAG` <> '0'
AND (IFNULL(SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 15, 1), 0) = '1' OR IFNULL(SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 16, 1), 0) = '1')
AND A.`DRUG_SH_CODE` = PI_YPTBDM;

SELECT   MAX(
CASE 
WHEN E.`EM_FLAG` IN ('1','2') THEN NULL
WHEN E.`MEMO` LIKE  '%依据01%' THEN NULL 
WHEN E.`MEMO` LIKE  '%依据03%' THEN NULL
WHEN E.`MEMO` LIKE  '%依据05%' THEN CAST(IFNULL(E.`REF_PURC_PRIC`, IF(G.`REF_PURC_PRIC`=0,NULL,G.`REF_PURC_PRIC`)) AS DECIMAL(10,2))
ELSE CAST(IFNULL(F.`REF_PURC_PRIC`, IF(G.`REF_PURC_PRIC`=0,NULL,G.`REF_PURC_PRIC`)) AS DECIMAL(10,2)) END * 2) 
FROM 
`drug_rls_b` AS A,
`drug_purc_rls_b` AS D,
`drug_pric_rls_b` AS E,
`drugpric_yellow_spdrug_b` AS F,
`drugpric_fstrslt_b` AS G
WHERE 1=1
AND A.`DRUG_SH_CODE` = D.`DRUG_SH_CODE`
AND A.`DRUG_SH_CODE` = E.`DRUG_SH_CODE`
AND E.`REF_PURC_RULE_TYPE`='01'
AND A.`DRUG_SH_CODE` = G.`DRUG_SH_CODE`
AND A.`DRUG_SH_CODE` = F.`DRUG_SH_CODE`
AND F.`VALI_FLAG` = '1'
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN F.`BEGIN_DATE` AND IFNULL(F.`END_DATE`,'99991231')
AND D.`PURC_STAS` <> '0'
AND G.`VALI_FLAG` <> '0'
AND (IFNULL(SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 15, 1), 0) = '1' OR IFNULL(SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 16, 1), 0) = '1')
AND A.`DRUG_SH_CODE` = PI_YPTBDM;


#第六阶段 DRUGLIST_TYPE_B 药品目录库分类
SELECT ROUND(
CASE WHEN v_sfxsq='1' OR v_ypfl = '通过评价' THEN
MAX(
CASE 
--when lengthb(g.ZXDWHL) < 51 THEN 0
WHEN  D.`EM_FLAG` IN ('1','2') THEN 0
WHEN D.`MEMO` LIKE  '%依据01%' THEN 0 
WHEN D.`MEMO` LIKE  '%依据03%' THEN 0 
WHEN H.`IS_NEWDCLA_FLAG` = '1' THEN
(SELECT MIN(`REF_PURC_PRIC`) FROM `drugpric_rslt_b` WHERE `DRUG_SH_CODE` = A.`DRUG_SH_CODE`
AND `STAS` = '20' AND `VALI_FLAG`='1' AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN `BEGIN_DATE` AND IFNULL(`END_DATE`,'99991231'))
ELSE CAST(IFNULL(IF(D.`REF_PURC_PRIC`=0,NULL,D.`REF_PURC_PRIC`), F.`REF_PURC_PRIC`) AS DECIMAL(10,2)) END * 
sf_getcbjbyyp(PI_YPTBDM, v_hl) /sf_getcbjbyyp(D.`REF_PURC_PRIC`, v_hl)) ELSE  NULL END ,2)
INTO y4
FROM 
`druglist_type_b` AS A,
v_ybbm_mlsxh AS B,
`drug_pric_rls_b` AS D,
`drugpric_fstrslt_b` AS F,
`drug_rls_b` AS G,
`drug_purc_rls_b` AS H
WHERE 
A.`DRUG_SH_CODE` = B.`DRUG_SH_CODE`
AND A.`DRUG_SH_CODE` = D.`DRUG_SH_CODE`
AND A.`DRUG_SH_CODE` = G.`DRUG_SH_CODE`
AND A.`DRUG_SH_CODE` = H.`DRUG_SH_CODE`
AND A.`DRUG_SH_CODE` = F.`DRUG_SH_CODE`
AND F.`VALI_FLAG` = '1'
AND A.`DRUGLIST_TYPE` = '0'
AND A.`VALI_FLAG` = '1'
AND D.`DRUG_SH_CODE` = PI_YPTBDM;



SELECT ROUND(
CASE WHEN '1'='1' OR '2' = '通过评价' THEN
MAX(
CASE 
WHEN  D.`EM_FLAG` IN ('1','2') THEN 0
WHEN D.`MEMO` LIKE  '%依据01%' THEN 0 
WHEN D.`MEMO` LIKE  '%依据03%' THEN 0 
WHEN H.`IS_NEWDCLA_FLAG` = '1' THEN
(SELECT MIN(`REF_PURC_PRIC`) FROM `drugpric_rslt_b` WHERE `DRUG_SH_CODE` = A.`DRUG_SH_CODE`
AND `STAS` = '20' AND `VALI_FLAG`='1' AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN `BEGIN_DATE` AND IFNULL(`END_DATE`,'99991231'))
ELSE CAST(IFNULL(IF(D.`REF_PURC_PRIC`=0,NULL,D.`REF_PURC_PRIC`), F.`REF_PURC_PRIC`) AS DECIMAL(10,2)) END * 
2) ELSE  NULL END ,2)
FROM 
`druglist_type_b` AS A,
`drug_pric_rls_b` AS D,
`drugpric_fstrslt_b` AS F,
`drug_rls_b` AS G,
`drug_purc_rls_b` AS H
WHERE 1=1
AND A.`DRUG_SH_CODE` = D.`DRUG_SH_CODE`
AND A.`DRUG_SH_CODE` = G.`DRUG_SH_CODE`
AND A.`DRUG_SH_CODE` = H.`DRUG_SH_CODE`
AND A.`DRUG_SH_CODE` = F.`DRUG_SH_CODE`
AND F.`VALI_FLAG` = '1'
AND A.`DRUGLIST_TYPE` = '0'
AND A.`VALI_FLAG` = '1'
AND D.`DRUG_SH_CODE` = PI_YPTBDM;



