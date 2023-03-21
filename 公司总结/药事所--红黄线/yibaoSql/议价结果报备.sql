
#00	议价待提交
#10	已提交待确认
20	议价已确认
#21	企业拒绝
01 	已作废

#药品议价结果（主表） DRUGPRIC_RSLT_B
SELECT * FROM `drugpric_rslt_b`

#企业信息表 ENTP_B  --PENTP_CODE
SELECT * FROM `entp_b`

#医药机构信息表 HOSP_INFO_B --MEDINS_CODE
SELECT * FROM `hosp_info_b`

#药品品规发布库 `drug_rls_b` --DRUG_SH_CODE
SELECT * FROM `drug_rls_b`

#药品外省市价格信息 DRUGPRIC_PROVPRIC_C
SELECT * FROM `drugpric_provpric_c`

#药品外省市价格信息明细 DRUGPRIC_PROVPRICDETL_C
SELECT * FROM `drugpric_provpricdetl_c`





#查询【本机构】所有的【药品议价申请】，申请状态查询条件默认为【待确认】和【不确认】--分页
SELECT A.`DRUGPRIC_RSLT_ID`,A.`DRUG_SH_CODE`,A.`REF_PURC_PRIC`,A.`MEDINS_CONER_NAME`,A.`MEDINS_CONER_TEL`,A.`REF_PURC_PRIC_DRSC`
,A.`PENTP_REJT_DRSC`,A.`PENTP_CONER_NAME`,A.`PENTP_CONER_TEL`,A.`SBMT_TIME`,A.`CHK_TIME`
,B.`CNAME_NAME`,B.`DOSFORM_FORM_CODE`,B.`SPECS_PAC`,B.`PAC_UNT`,B.`PENTP_NAME`,B.`COMMENTP_NAME`,B.`IMPPACENTP_NAME`
,C.`ENTP_NAME`
,D.`STAS`
FROM `drugpric_rslt_b` AS A
LEFT JOIN `drug_rls_b` AS B ON A.`DRUG_SH_CODE`=B.`DRUG_SH_CODE`
LEFT JOIN `entp_drug_b` AS C ON A.`DRUG_SH_CODE`=C.`DRUG_CODE`
LEFT JOIN `drugpric_drugperm_b` AS D ON A.`DRUG_SH_CODE`=D.`DRUG_SH_CODE` AND D.`VALI_FLAG`='1'
WHERE 1=1
AND A.`VALI_FLAG`='1'
AND A.`STAS` IN ('00','10','21')
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN A.`BEGIN_DATE` AND A.`END_DATE`
AND A.`MEDINS_CODE`=''
AND A.`DRUG_SH_CODE` LIKE ''
AND B.`CNAME_NAME` LIKE ''
AND D.`STAS`=''
#药品基本信息--表单
SELECT `DRUG_SH_CODE`,`CNAME_NAME`,`DOSFORM_FORM_CODE`,`SPECS_PAC`,`PAC_UNT`,'所属企业',`PENTP_NAME`,`COMMENTP_NAME`,`IMPPACENTP_NAME`
FROM `drug_rls_b`
WHERE 1=1
AND `DRUG_SH_CODE`=''

#药品外省市价格--分页
SELECT A.`IS_HAS_PRIC`,B.`REGN_CODE`,B.`PRIC`
FROM `drugpric_provpric_c` AS A
LEFT JOIN `drugpric_provpricdetl_c` AS B ON A.`PRIC_INFO_ID`=B.`PRIC_INFO_ID` AND B.`VALI_FLAG`='1'
WHERE 1=1
AND A.`VALI_FLAG`='1'
AND A.`DRUG_SH_CODE`='Z00218000020020'

#各医药机构当前有效的议价结果（含本机构，按确认时间倒序排列）--分页 可查询所有未确认或被驳回，已确认且日期有效的所有议价信息
SELECT A.`DRUGPRIC_RSLT_ID`,A.`REF_PURC_PRIC`,A.`REF_PURC_PRIC_DRSC`,A.`CHK_TIME`
,B.`MEDINS_NAME`
FROM `drugpric_rslt_b` AS A
LEFT JOIN `hosp_info_b` AS B ON A.`MEDINS_CODE`=B.`MEDINS_CODE` AND B.`VALI_FLAG`='1'
WHERE 1=1 
AND A.`VALI_FLAG`='1' 
AND A.`STAS` IN ('10','21') OR (A.`STAS`='20' AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN A.`BEGIN_DATE` AND A.`END_DATE`)
AND A.`DRUG_SH_CODE`='Z00218000020020'
ORDER BY A.`CRTE_TIME`

#本机构的议价结果（含历史，按确认时间倒序排列）--分页 可查询本医院未确认和已确认，被药事所作废的所有议价信息
SELECT `REF_PURC_PRIC`,`REF_PURC_PRIC_DRSC`,`CHK_TIME`,`BEGIN_DATE`,`END_DATE`
FROM `drugpric_rslt_b` 
WHERE 1=1  
AND `STAS` IN ('10','21')
AND `DRUG_SH_CODE`='Z00218000020020' 
AND `MEDINS_CODE`=''
ORDER BY `CRTE_TIME`

#同通用名药品的议价结果 
SELECT B.`DRUG_SH_CODE`,B.`CNAME_NAME`,B.`DOSFORM_FORM_CODE`,B.`SPECS_PAC`,B.`PAC_UNT`,B.`PENTP_NAME`,B.`COMMENTP_NAME`,B.`IMPPACENTP_NAME`
,A.`REF_PURC_PRIC`
,C.`ENTP_NAME`
FROM `drugpric_rslt_b` AS A
LEFT JOIN `drug_rls_b` AS B ON A.`DRUG_SH_CODE`=B.`DRUG_SH_CODE`
LEFT JOIN `entp_drug_b` AS C ON A.`DRUG_SH_CODE`=C.`DRUG_CODE`
WHERE 1=1
AND A.`VALI_FLAG`='1'
AND A.`STAS`='20' 
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN A.`BEGIN_DATE` AND A.`END_DATE`
AND B.`CNAME_NAME`=''


#可选药品[价格规则]中[采购价格类型]是[自行议价]，[采购规则]中的[采购类型]是[挂网采购]的药品]
#【医院】可选药品的采购规则中的适用医院范围为全部医药机构05、全部医疗机构01
#【药店】可选药品的采购规则中的适用医院范围为全部医药机构05、仅药店04
#01全部医疗机构
#04仅药店
#05全部医药机构
SELECT A.`DRUG_SH_CODE`,A.`CNAME_NAME`,A.`DOSFORM_FORM_CODE`,A.`SPECS_PAC`,A.`PAC_UNT`,A.`APPROVAL_CODE`,A.`PENTP_NAME`,A.`COMMENTP_NAME`,A.`IMPPACENTP_NAME`,
(SELECT DISTINCT`ENTP_NAME` FROM `entp_drug_b` WHERE `DRUG_CODE`=A.`DRUG_SH_CODE`) AS entpName
FROM `drug_rls_b` AS A
LEFT JOIN `drug_purc_rls_b` AS B ON A.`DRUG_SH_CODE`=B.`DRUG_SH_CODE`
LEFT JOIN `drug_pric_rls_b` AS C ON A.`DRUG_SH_CODE`=C.`DRUG_SH_CODE`
WHERE 1=1
AND B.`DRUG_PURC_TYPE` = '5'
AND C.`REF_PURC_TYPE`='06'
AND B.`MEDINS_SCP_TYPE` IN ('05','01')



1.1
4.1









#药品基础信息--表单
SELECT * FROM `drug_rls_b` WHERE 1=1 AND `DRUG_SH_CODE`='Z00218000020020'
#各医药机构当前有效的议价结果（含本机构，按确认时间倒序排列）--分页
SELECT * FROM `drugpric_rslt_b` WHERE 1=1 
AND `VALI_FLAG`='1' AND `DRUG_SH_CODE`='Z00218000020020'  AND `STAS`='' ORDER BY `CRTE_TIME`
#药品外省市价格--表单
SELECT * FROM `drugpric_provpric_c` AS A
LEFT JOIN `drugpric_provpricdetl_c` AS B ON A.`PRIC_INFO_ID`=B.`PRIC_INFO_ID` AND B.`VALI_FLAG`='1'
WHERE 1=1
AND A.`VALI_FLAG`='1'
AND A.`DRUG_SH_CODE`='Z00218000020020'
#本机构有效的议价结果（含历史，按确认时间倒序排列）--分页
SELECT * FROM `drugpric_rslt_b` WHERE 1=1 
AND `VALI_FLAG`='1' AND `DRUG_SH_CODE`='Z00218000020020' AND `MEDINS_CODE`='' AND `STAS`='' ORDER BY `CRTE_TIME`
#药品价格规则
SELECT * FROM `drugpric_provpric_c` AS A
LEFT JOIN `drugpric_provpricdetl_c` AS B ON A.`PRIC_INFO_ID`=B.`PRIC_INFO_ID` AND B.`VALI_FLAG`='1'
WHERE 1=1
AND A.`VALI_FLAG`='1'
AND A.`DRUG_SH_CODE`='Z00218000020020'


#同通用名的当前有效议价结果（含本机构）


#修改 
UPDATE `drugpric_rslt_b` SET `REF_PURC_PRIC`='',`REF_PURC_PRIC_DRSC`='',`MEDINS_CONER_NAME`='',`MEDINS_CONER_TEL`='',`STAS`='',`UPDT_TIME`='',`DEL_TIME`='',`DEL_DRSC`=''
WHERE 1=1
AND `DRUGPRIC_RSLT_ID`=''


#查询
SELECT `MEDINS_CODE`,`MEDINS_TYPE` FROM `hosp_info_b`
WHERE 1=1
AND `MEDINS_CODE`=''

#药品是否填报【外省市价格】
SELECT COUNT(*) FROM `drugpric_provpricdetl_c` AS A 
LEFT JOIN `drugpric_provpric_c` AS B ON A.`PRIC_INFO_ID`=B.`PRIC_INFO_ID` 
AND B.`VALI_FLAG`='1' AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN B.`BEGIN_DATE` AND B.`END_DATE` AND B.`DRUG_SH_CODE`='Z00218000020020'
WHERE 1=1
AND A.`VALI_FLAG`='1'


SELECT COUNT(*) FROM `drugpric_aplyatt_info_c` AS A
LEFT JOIN `drugpric_provpric_c` AS B ON A.`MAIN_ID`=B.`PRIC_INFO_ID` 
AND B.`VALI_FLAG`='1' 
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN B.`BEGIN_DATE` AND B.`END_DATE` 
AND B.`DRUG_SH_CODE`='Z00218000020020'
WHERE 1=1
AND A.`RID`='1'
AND A.`CERT_TYPE`='99'

SELECT COUNT(*) FROM `drugpric_provpric_c` AS A,`drugpric_provpricdetl_c` AS B,`drugpric_aplyatt_info_c` AS C
WHERE 1=1
AND A.`PRIC_INFO_ID`=B.`PRIC_INFO_ID`
AND A.`PRIC_INFO_ID`=C.`MAIN_ID`
AND A.`DRUG_SH_CODE`='Z00218000020020'
AND A.`RID`='1'
AND B.`RID`='1'
AND C.`RID`='1'
AND C.`CERT_TYPE`='99'
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN A.`BEGIN_DATE` AND A.`END_DATE`


#查询 该药品存在的医院申请【药品议价权限明细表】
SELECT A.`MEDINS_CODE`,A.`ISDRUGPRIC_FLAG`,A.`ISDRUGPURC_FLAG` 
FROM `drugpric_drugpermdetl_b` AS A
LEFT JOIN `drugpric_drugperm_b` AS B ON A.`DRUGPERM_ID`=B.`DRUGPERM_ID` AND B.`VALI_FLAG`='1'
WHERE 1=1
AND A.`VALI_FLAG`='1'
AND B.`DRUG_SH_CODE`=''

#查询 该药品存是否存在黑名单中
SELECT COUNT(*) FROM `drugpric_bwlist_b`
WHERE 1=1
AND `VALI_FLAG`='1'
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN `BEGIN_DATE` AND `END_DATE`
AND `BW_TYPE`='0'
AND `DRUG_SH_CODE`=''

#判断 当前医院是否申请了该药品
SELECT COUNT(*) FROM `drugpric_rslt_b`
WHERE 1=1
AND `VALI_FLAG`='1'
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN `BEGIN_DATE` AND `END_DATE`
AND `STAS` IN ('00','10','21')
AND `DRUG_SH_CODE`=''
AND `MEDINS_CODE`=''

#查询 该药品在【药品议价结果】表中的最低价
SELECT MIN(`REF_PURC_PRIC`) FROM `drugpric_rslt_b`
WHERE 1=1
AND `VALI_FLAG`='1'
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN `BEGIN_DATE` AND `END_DATE`
AND `STAS`='20'
AND `DRUG_SH_CODE`=''

#查询 该药品在【药品物价规则发布库】表中的最低价
SELECT MIN(REF_PURC_PRIC) FROM `drug_pric_rls_b`
WHERE 1=1
AND `REF_PURC_RULE_TYPE`='01'
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN `ENAB_DATE` AND IFNULL(`DSAB_DATE`,'29991231')
AND `DSAB_FLAG`='1'
AND `DRUG_SH_CODE`='' 

01唯一中标价 REF_PURC_TYPE
06自行议价
07协议采购价
#查询 该药品在【药品外省市价格信息明细】表中的最低价
SELECT MIN(A.`PRIC`) FROM `drugpric_provpricdetl_c` AS A
LEFT JOIN `drugpric_provpric_c` AS B ON A.`PRIC_INFO_ID`=B.`PRIC_INFO_ID` AND B.`VALI_FLAG`='1'
WHERE 1=1
AND A.`VALI_FLAG`='1'
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN B.`BEGIN_DATE` AND B.`END_DATE`
AND B.`DRUG_SH_CODE`=''

#
SELECT * FROM `drugpric_rslt_b`



药品医保规则发布库--DRUG_HI_RLS_B


SELECT A.`DRUG_SH_CODE`,
        A.`CNAME_NAME`,
        A.`DOSFORM_FORM_CODE`,
        A.`SPECS_PAC`,
        A.`PAC_UNT`,
        A.`APPROVAL_CODE`,
        A.`PENTP_NAME`,
        A.`COMMENTP_NAME`,
        A.`IMPPACENTP_NAME`,
        A.`CNAME_NAME_STD`,
        A.`LGCYP`,
        A.`PAC_MATL`,
        B.`DRUG_INQ_TYPE`,
        D.`HILIST_CODE`,
        (SELECT DISTINCT `ENTP_NAME` FROM `entp_drug_b` WHERE `DRUG_CODE` = A.`DRUG_SH_CODE`) AS entpName
        FROM `drug_rls_b` AS A
        LEFT JOIN `drug_purc_rls_b` AS B ON A.`DRUG_SH_CODE` = B.`DRUG_SH_CODE` AND B.`DSAB_FLAG`='1'
        LEFT JOIN `drug_pric_rls_b` AS C ON A.`DRUG_SH_CODE` = C.`DRUG_SH_CODE` AND C.`DSAB_FLAG`='1'
        LEFT JOIN `drug_hi_rls_b` AS D ON A.`DRUG_SH_CODE` = D.`DRUG_SH_CODE` AND D.`VALI_FLAG`='1' AND A.`DRUG_ICD_TYPE`=D.`HILIST_ICD_TYPE`
        WHERE 1 = 1
        AND B.`DRUG_PURC_TYPE` = '5'
        AND C.`REF_PURC_TYPE` = '06'
        AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN A.`ENAB_DATE` AND IFNULL(A.`DSAB_DATE`,'29991231')
        AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN B.`ENAB_DATE` AND IFNULL(B.`DSAB_DATE`,'29991231')
	AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN D.`ENAB_DATE` AND IFNULL(D.`DSAB_DATE`,'29991231')


#上一季度2/3级医院最低议价价格
SELECT MIN(A.`REF_PURC_PRIC`) FROM `drugpric_rslt_b` AS A
LEFT JOIN (SELECT `MEDINS_CODE`,`MEDINS_LV_TYPE`,`VALI_FLAG` FROM `hosp_info_b` WHERE `VALI_FLAG`='1' AND `MEDINS_LV_TYPE` IN ('2','3')) AS B
ON A.`MEDINS_CODE`=B.`MEDINS_CODE`
WHERE 1=1
AND A.`VALI_FLAG`='1'
AND QUARTER(NOW())=QUARTER(DATE_SUB(NOW(),INTERVAL 1 QUARTER))


#判断 该药品的医保类型【医保内】【医保外】
SELECT COUNT(*) FROM `drug_hi_rls_b`
WHERE 1=1
AND `VALI_FLAG`='1'
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN `ENAB_DATE` AND IFNULL(`DSAB_DATE`,'99991231')
AND `DRUG_SH_CODE`='1'




SELECT A.`MEDINS_CODE`, A.`ISDRUGPRIC_FLAG`, A.`ISDRUGPURC_FLAG`, C.`MEDINS_TYPE`
        FROM `drugpric_drugpermdetl_b` AS A
                 LEFT JOIN `drugpric_drugperm_b` AS B ON A.`DRUGPERM_ID` = B.`DRUGPERM_ID` AND B.`VALI_FLAG` = '1'
                 LEFT JOIN (SELECT `MEDINS_CODE`,`MEDINS_TYPE` FROM `hosp_info_b` WHERE `VALI_FLAG`='1' AND `MEDINS_TYPE` IN ('1','2')) AS C ON A.`MEDINS_CODE`=C.`MEDINS_CODE`
        WHERE 1 = 1
          AND A.`VALI_FLAG` = '1'
          AND A.


#判断 该药品是否是【大输液品种】
SELECT COUNT(*) FROM `drug_hi_rls_b`
WHERE 1=1 
AND `VALI_FLAG` = '1'
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN `ENAB_DATE` AND IFNULL(`DSAB_DATE`,'99991231')
AND `HILIST_ICD_TYPE` ='1'
AND `HILIST_CODE` IN ('405','406','422') 
AND `DRUG_SH_CODE`= ?

#判断 该药品是否是 4+7同品种
SELECT COUNT(*) FROM `drug_pric_rls_b`
WHERE 1=1
AND `DSAB_FLAG`='1'
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN `ENAB_DATE` AND IFNULL(`DSAB_DATE`,'99991231')
AND `EM_FLAG` IN('1','2')
AND `DRUG_SH_CODE`= ?

#1.同品种（目录序号+标化通用名），同装量，同包装材料药品全市加权平均价（固化）
SELECT * FROM `drugpric_rslt_b` AS A
LEFT JOIN (SELECT `DRUG_SH_CODE`,`HILIST_CODE`,`HILIST_ICD_TYPE`, FROM `drug_hi_rls_b` 
WHERE `VALI_FLAG`='1' AND `DSAB_FLAG`='1' AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN A.`ENAB_DATE` AND IFNULL(A.`DSAB_DATE`,'99991231')) AS B 
ON A.`DRUG_SH_CODE`=B.`DRUG_SH_CODE`
LEFT JOIN (SELECT `DRUG_SH_CODE`,`CNAME_NAME_STD`,`LGCYP`,`PAC_MATL` FROM `drug_rls_b`) AS C ON A.`DRUG_SH_CODE`=C.`DRUG_SH_CODE`
WHERE 1=1
AND A.`VALI_FLAG`='1'
AND A.`STAS`='20'
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN A.`ENAB_DATE` AND IFNULL(A.`DSAB_DATE`,'99991231')

#查询 药品议价大输液黄线表
SELECT `YELLOW_ID`,`YELLOW1`,`YELLOW2` FROM `drugpric_yellow_sp_b`
WHERE 1=1
AND `VALI_FLAG`='1'
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN `BEGIN_DATE` AND IFNULL(`END_DATE`,'99991231')
AND `HILIST_CODE`=''
AND `HILIST_ICD_TYPE`=''
AND `CNAME_NAME`=''
AND `LGCYP`=''
AND `PAC_MATL`=''


#查询 该药品在【药品外省市价格信息明细】表中的平均价【外省市平均价】
SELECT AVG(A.`PRIC`) FROM `drugpric_provpricdetl_c` AS A
LEFT JOIN (SELECT `PRIC_INFO_ID` FROM `drugpric_provpric_c` 
WHERE `VALI_FLAG`='1' AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN `BEGIN_DATE` AND `END_DATE` AND `DRUG_SH_CODE`='') AS B 
ON A.`PRIC_INFO_ID`=B.`PRIC_INFO_ID`
WHERE 1=1
AND A.`VALI_FLAG`='1'

#查询 该药品在【药品外省市价格信息明细】表中的次低价【外省市次低价】
SELECT AVG(A.`PRIC`) FROM `drugpric_provpricdetl_c` AS A
LEFT JOIN (SELECT `PRIC_INFO_ID` FROM `drugpric_provpric_c` 
WHERE `VALI_FLAG`='1' AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN `BEGIN_DATE` AND `END_DATE` AND `DRUG_SH_CODE`='') AS B 
ON A.`PRIC_INFO_ID`=B.`PRIC_INFO_ID`
WHERE 1=1
AND A.`VALI_FLAG`='1'
AND A.`PRIC`!=(
SELECT MIN(A.`PRIC`) FROM `drugpric_provpricdetl_c` AS A
LEFT JOIN (SELECT `PRIC_INFO_ID` FROM `drugpric_provpric_c` 
WHERE `VALI_FLAG`='1' AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN `BEGIN_DATE` AND `END_DATE` AND `DRUG_SH_CODE`='') AS B 
ON A.`PRIC_INFO_ID`=B.`PRIC_INFO_ID`
WHERE 1=1
AND A.`VALI_FLAG`='1'
)

#查询 原研药品
SELECT B.`REF_PURC_PRIC` FROM `drug_rls_b` AS A
LEFT JOIN (SELECT `DRUG_SH_CODE`,`REF_PURC_PRIC` FROM `drug_pric_rls_b` WHERE `DSAB_FLAG`='1' 
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN `ENAB_DATE` AND IFNULL(`DSAB_DATE`,'99991231') AND `DRUG_SH_CODE`='X01140080060010') AS B ON A.`DRUG_SH_CODE`=B.`DRUG_SH_CODE`
WHERE 1=1
AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN A.`ENAB_DATE` AND IFNULL(A.`DSAB_DATE`,'99991231')
AND (SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 15, 1)='1' 
OR SUBSTRING(TRIM(A.`DRUG_SP_FLAG`), 16, 1)='1')
AND A.`DRUG_SH_CODE`='X01140080060010'

#查询 同品种（原研药/参比制剂除外）原采购价最高价（物价规则）	
SELECT `REF_PURC_PRIC`
FROM `drug_pric_rls_b`
WHERE 1 = 1
AND `DSAB_FLAG` = '1'
AND DATE_FORMAT(NOW(), '%Y%m%d') BETWEEN `ENAB_DATE` AND IFNULL(`DSAB_DATE`, '99991231')
AND `REF_PURC_RULE_TYPE` = '01'
AND `DRUG_SH_CODE` = ''





SELECT MAX(CASE WHEN v_sfxsq = '1' THEN NULL WHEN b.bz LIKE '%依据05%' THEN to_number(nvl(d.gzcsz, yjjg)) ELSE nvl(a.jg, yjjg) END) INTO y1
FROM tb_yellowline1 a, tb_ypscyjjg c,tb_ypwjgz_fbk b,tb_ypwjgz_bdkmx d
WHERE a.yptbdm(+)=b.yptbdm AND b.yptbdm = c.yptbdm(+) 
AND b.YPWJBDID=d.ypwjbdid AND gzlx='10'
AND a.yxbz(+)='1' AND a.jsrq(+)>to_char(SYSDATE,'yyyyMMdd')
AND c.yxbz(+) = '1'
AND b.yptbdm = PI_YPTBDM;

#1.原采购价（物价规则）
SELECT MAX(CASE WHEN D.`IS_NEWDCLA_FLAG` = '1' THEN NULL WHEN A.`MEMO` LIKE '%依据05%' THEN IFNULL(B.`REF_PURC_PRIC`, '100') ELSE IFNULL(C.`REF_PURC_PRIC`, '100') END) AS y1
FROM `drug_rls_b` AS A
LEFT JOIN (SELECT `DRUG_SH_CODE`,`MEMO`,`REF_PURC_PRIC` FROM `drug_pric_rls_b` WHERE `DSAB_FLAG`='1' AND DATE_FORMAT(NOW(), '%Y%m%d') BETWEEN `ENAB_DATE` AND IFNULL(`DSAB_DATE`, '99991231') AND `REF_PURC_RULE_TYPE`='01') 
AS B ON A.`DRUG_SH_CODE`=B.`DRUG_SH_CODE`
LEFT JOIN (SELECT `DRUG_SH_CODE`,`REF_PURC_PRIC` FROM `drugpric_yellow_spdrug_b` WHERE `VALI_FLAG`='1' AND DATE_FORMAT(NOW(), '%Y%m%d') BETWEEN `BEGIN_DATE` AND IFNULL(`END_DATE`, '99991231'))
AS C ON A.`DRUG_SH_CODE`=C.`DRUG_SH_CODE`
LEFT JOIN (SELECT `DRUG_SH_CODE`,`IS_NEWDCLA_FLAG` FROM `drug_purc_rls_b` WHERE `DSAB_FLAG`='1' AND DATE_FORMAT(NOW(), '%Y%m%d') BETWEEN `ENAB_DATE` AND IFNULL(`DSAB_DATE`, '99991231'))
AS D ON A.`DRUG_SH_CODE`=D.`DRUG_SH_CODE`
WHERE 1=1
AND DATE_FORMAT(NOW(), '%Y%m%d') BETWEEN A.`ENAB_DATE` AND IFNULL(A.`DSAB_DATE`, '99991231')
AND A.`DRUG_SH_CODE` ='X01140080060010'

DRUGPRIC_YELLOW_SPDRUG_B




#2.同品种（原研药/参比制剂除外）原采购价最高价（物价规则）
SELECT CASE WHEN v_ypfl = '原研药品/参比制剂' THEN ROUND(MAX(to_number(CASE WHEN  b.YPFBSJID IN ('1','2') THEN NULL -- when d.gzyj like '%新申请%' then null 
WHEN b.bz LIKE  '%依据01%' THEN NULL 
WHEN b.bz LIKE  '%依据03%' THEN NULL
WHEN nvl(substrb(a.yptsbz, 15, 1), 0) = '1' OR nvl(substrb(a.yptsbz, 16, 1), 0) = '1' 
THEN nvl(CASE WHEN b.bz LIKE  '%依据05%' THEN to_number(g.gzcsz) ELSE c.jg END,e.yjjg) END) * --20210419依据05的物价规则作为取值来源
sf_getcbjbyyp(PI_YPTBDM, v_hl) / sf_getcbjbyyp(a.yptbdm, v_hl)),2) --原研查询全部药品（新申请除外）20210413：原研药品查询原研药品（新申请不除外）
ELSE nvl(ROUND(MAX(CASE WHEN nvl(substrb(a.yptsbz, 15, 1), 0) = '1' OR nvl(substrb(a.yptsbz, 16, 1), 0) = '1' THEN NULL
WHEN lengthb(a.zxdwhl) < 51 THEN NULL
WHEN  b.YPFBSJID IN ('1','2') THEN NULL
WHEN d.gzyj LIKE  '%新申请%' THEN NULL
WHEN b.bz LIKE  '%依据01%' THEN NULL 
WHEN b.bz LIKE  '%依据03%' THEN NULL 
WHEN b.bz LIKE  '%依据05%' THEN to_number(nvl(g.gzcsz ,e.yjjg)) --20210419依据05的物价规则作为取值来源
ELSE to_number(nvl(c.jg ,e.yjjg)) END * sf_getcbjbyyp(PI_YPTBDM, v_hl) / sf_getcbjbyyp(a.yptbdm, v_hl)),2), --非原研查询除原研的药品（新申请除外）
ROUND(MAX(CASE WHEN nvl(substrb(a.yptsbz, 15, 1), 0) = '1' OR nvl(substrb(a.yptsbz, 16, 1), 0) = '1' THEN NULL
WHEN lengthb(a.zxdwhl) < 51 THEN NULL
WHEN  b.YPFBSJID IN ('1','2') THEN NULL
WHEN b.bz LIKE  '%依据01%' THEN NULL 
WHEN b.bz LIKE  '%依据03%' THEN NULL
WHEN b.bz LIKE  '%依据05%' THEN to_number(nvl(g.gzcsz, e.yjjg))--20210419依据05的物价规则作为取值来源
ELSE to_number(nvl(c.jg, e.yjjg)) END * sf_getcbjbyyp(PI_YPTBDM, v_hl) / sf_getcbjbyyp(a.yptbdm, v_hl)),2) --如除原研，除新申请 最高价为空的话，就包含新申请药品
) END INTO y2
FROM tb_yppg_fbk     t1,--相当于【药品品规发布库】
v_ybbm_mlsxh    t2,--相当于【】
tb_yppg_fbk     a,--相当于【药品品规发布库】
tb_ypwjgz_fbk   b,--相当于【药品物价规则发布库】
tb_yellowline1 c,--相当于【药品议价特殊药品黄线表】
tb_ypcggz_fbk   d,--相当于【药品采购规则发布库】
tb_ypscyjjg     e,--相当于【药品首次议价 DRUGPRIC_FSTRSLT_B】
v_ybbm_mlsxh    f,--相当于【关联】[医保目录细分表HILIST_SUBD_B 药品医保规则发布库DRUG_HI_RLS_B][目录中西医标志HILIST_ICD_TYPE  目录顺序号HILIST_CODE]
tb_ypwjgz_bdkmx g--相当于【】
WHERE t1.YPCPMWBM=a.ypcpmwbm --20210408：目录编码改为标化通用名查询
AND t1.yptbdm = t2.yptbdm
AND t2.sjmlsxh = f.sjmlsxh--20210419:同目录顺序号
AND t2.zxybz = f.zxybz 
AND a.yptbdm = b.yptbdm
AND b.YPWJBDID=g.ypwjbdid
AND g.gzlx='10' 
AND a.yptbdm = d.yptbdm
AND a.yptbdm = e.yptbdm(+)
AND a.yptbdm = c.yptbdm(+)
AND a.yptbdm = f.yptbdm 
AND c.yxbz(+)='1' 
AND c.jsrq(+)>to_char(SYSDATE,'yyyyMMdd')
AND d.jczbzt <> '0'
AND e.yxbz(+) <>'0'
AND t1.yptbdm = PI_YPTBDM;





#看药品发布库里的药品特殊标识 ,第15 ,16位 ,只要有一个是1 就走这个【原研】【参比制剂 药品】的规则
#
CASE WHEN  b.YPFBSJID IN ('1','2') THEN NULL -- when d.gzyj like '%新申请%' then null 
WHEN b.bz LIKE  '%依据01%' THEN NULL 
WHEN b.bz LIKE  '%依据03%' THEN NULL
WHEN nvl(substrb(a.yptsbz, 15, 1), 0) = '1' OR nvl(substrb(a.yptsbz, 16, 1), 0) = '1' 
THEN nvl(CASE WHEN b.bz LIKE  '%依据05%' THEN to_number(g.gzcsz) ELSE c.jg END,e.yjjg) 
END

#
#如果是原研药品返回null
CASE WHEN nvl(substrb(a.yptsbz, 15, 1), 0) = '1' OR nvl(substrb(a.yptsbz, 16, 1), 0) = '1' THEN NULL
WHEN lengthb(a.zxdwhl) < 51 THEN NULL
WHEN  b.YPFBSJID IN ('1','2') THEN NULL
WHEN d.gzyj LIKE  '%新申请%' THEN NULL
WHEN b.bz LIKE  '%依据01%' THEN NULL 
WHEN b.bz LIKE  '%依据03%' THEN NULL 
WHEN b.bz LIKE  '%依据05%' THEN to_number(nvl(g.gzcsz ,e.yjjg)) --20210419依据05的物价规则作为取值来源
ELSE to_number(nvl(c.jg ,e.yjjg)) END * sf_getcbjbyyp(PI_YPTBDM, v_hl) / sf_getcbjbyyp(a.yptbdm, v_hl)

#
ROUND(MAX(CASE WHEN nvl(substrb(a.yptsbz, 15, 1), 0) = '1' OR nvl(substrb(a.yptsbz, 16, 1), 0) = '1' THEN NULL
WHEN lengthb(a.zxdwhl) < 51 THEN NULL
WHEN  b.YPFBSJID IN ('1','2') THEN NULL
WHEN b.bz LIKE  '%依据01%' THEN NULL 
WHEN b.bz LIKE  '%依据03%' THEN NULL
WHEN b.bz LIKE  '%依据05%' THEN to_number(nvl(g.gzcsz, e.yjjg))--20210419依据05的物价规则作为取值来源
ELSE to_number(nvl(c.jg, e.yjjg)) END * sf_getcbjbyyp(PI_YPTBDM, v_hl) / sf_getcbjbyyp(a.yptbdm, v_hl)),2)



#紧缺药品--1、原采购价nvl(议价，gzcsz）2、同目录同标化通用名品种议价最高价nvl(议价，gzcsz)（包装数量乘除差比）
SELECT * FROM (SELECT * FROM (
SELECT  a.yptbdm bzpbm2 ,trunc((DECODE(
TRIM(substrb(a.zxdwhl, 51, 10)), 0, 0, nvl(d.cgjg, f.gzcsz) * TRIM(substrb(t1.zxdwhl, 51, 10)) / TRIM(substrb(a.zxdwhl, 51, 10))
)),2)   hx2
FROM 
tb_yppg_fbk     t1,
v_ybbm_mlsxh    t2,
tb_ypcggz_fbk   t3,
v_yppg_fbk      a,
v_ybbm_mlsxh    b,
tb_ypcggz_fbk   c,
tb_yjjgbb       d,
tb_ypwjgz_fbk   e,
tb_ypwjgz_bdkmx f
WHERE t1.yptbdm=t2.yptbdm AND t1.yptbdm=t3.yptbdm AND t3.gzyj LIKE  '紧缺药品%' AND a.yptbdm=b.yptbdm
AND a.yptbdm=c.yptbdm AND a.yptbdm=d.yptbdm(+) AND a.yptbdm=e.yptbdm AND e.YPWJBDID=f.ypwjbdid
AND f.gzlx='10' AND d.yxbz(+)='1' AND d.zt(+)='20' AND to_char(SYSDATE,'yyyyMMdd') BETWEEN d.ksrq(+) AND d.jsrq(+)
AND t1.YPCPMWBM=a.YPCPMWBM AND t2.sjmlsxh=b.sjmlsxh AND t2.zxybz=b.zxybz AND c.jczbzt<>'0'
AND nvl(SUBSTR(TRIM(a.yptsbz),15,2),0) ='00' AND NOT (c.gzyj LIKE  '新增医保%'  AND EXISTS(SELECT 1 FROM tb_yjqx m,tb_yjqxmx n
WHERE m.yjqxid=n.yjqxid AND yptbdm=a.yptbdm AND fpid IS NULL )) AND t1.yptbdm=?)
ORDER BY hx2 DESC nulls LAST) WHERE rownum=1;



#原研药品（待定）1.新4黄线中的黄线1：原采购价2.人社编码同品种原采购价最高价（物价规则）（新4黄线第2条）[1、外省市最低加最高的平均价]
SELECT * FROM (SELECT * FROM (
SELECT  a.yptbdm bzpbm2, ROUND(
(to_number(CASE WHEN  b.YPFBSJID IN ('1','2') THEN NULL  --   when d.gzyj like  '%新申请%' then null 
WHEN b.bz LIKE  '%依据01%' THEN NULL  WHEN b.bz LIKE  '%依据03%' THEN NULL 
WHEN nvl(substrb(a.yptsbz, 15, 1), 0) = '1' OR nvl(substrb(a.yptsbz, 16, 1), 0) = '1' 
THEN nvl(CASE WHEN b.bz LIKE  '%依据05%' THEN to_number(g.gzcsz) ELSE c.jg END,e.yjjg) END) * --20210419依据05的物价规则作为取值来源
sf_getcbjbyyp(?, 111) / sf_getcbjbyyp(a.yptbdm, 111)),2)  hx2
FROM 
tb_yppg_fbk     t1, 
v_ybbm_mlsxh    t2,
tb_yppg_fbk      a,
tb_ypwjgz_fbk    b,
tb_yellowline1   c,
tb_ypcggz_fbk    d,
tb_ypscyjjg      e,
v_ybbm_mlsxh     f,
tb_ypwjgz_bdkmx  g
WHERE t1.YPCPMWBM=a.ypcpmwbm   --20210408：目录编码改为标化通用名查询
AND t1.yptbdm = t2.yptbdm AND t2.sjmlsxh = f.sjmlsxh   --20210419:同目录顺序号
AND t2.zxybz = f.zxybz AND a.yptbdm = b.yptbdm AND b.YPWJBDID=g.ypwjbdid
AND g.gzlx='10' AND a.yptbdm = d.yptbdm AND a.yptbdm = e.yptbdm(+) AND a.yptbdm = c.yptbdm(+)
AND a.yptbdm = f.yptbdm AND c.yxbz(+)='1' AND c.jsrq(+)>to_char(SYSDATE,'yyyyMMdd')
AND d.jczbzt <> '0' AND e.yxbz(+) <>'0' AND t1.yptbdm = ?) ORDER BY hx2 DESC nulls LAST ) WHERE rownum=1;


#原研药品（待定）红线---1、外省市最低价最高价的平均价
SELECT (CAST(MAX(A.`PRIC`) AS DECIMAL(10,2))+CAST(MIN(A.`PRIC`) AS DECIMAL(10,2)))/2 FROM `drugpric_provpricdetl_c` AS A
LEFT JOIN (SELECT `PRIC_INFO_ID` FROM `drugpric_provpric_c` 
WHERE `VALI_FLAG`='1' AND DATE_FORMAT(NOW(),'%Y%m%d') BETWEEN `BEGIN_DATE` AND `END_DATE` AND `DRUG_SH_CODE`='') AS B 
ON A.`PRIC_INFO_ID`=B.`PRIC_INFO_ID`
WHERE 1=1
AND A.`VALI_FLAG`='1'

#判断 是否是原研药品 被标识为原研或参比制剂的药品（与挂网通道无关，仅看药品标识）
SELECT COUNT(*) FROM `drug_rls_b`
WHERE 1=1
AND (SUBSTRING(TRIM(`DRUG_SP_FLAG`), 15, 1) = '1' OR SUBSTRING(TRIM(`DRUG_SP_FLAG`), 16, 1) = '1')
AND `DRUG_SH_CODE`=''


#
WITH temp AS(SELECT t.*,rownum rn FROM (
SELECT yptbdm, ssdm1 ssdm, cgjg1 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm2 ssdm, cgjg2 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm3 ssdm, cgjg3 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm4 ssdm, cgjg4 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm5 ssdm, cgjg5 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm6 ssdm, cgjg6 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm7 ssdm, cgjg7 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm8 ssdm, cgjg8 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm9 ssdm, cgjg9 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm10 ssdm, cgjg10 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm11 ssdm, cgjg11 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm12 ssdm, cgjg12 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm13 ssdm, cgjg13 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm14 ssdm, cgjg14 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm15 ssdm, cgjg15 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm16 ssdm, cgjg16 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm17 ssdm, cgjg17 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm18 ssdm, cgjg18 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm19 ssdm, cgjg19 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq UNION
SELECT yptbdm, ssdm20 ssdm, cgjg20 cgjg FROM tb_ssjgxx WHERE yxbz = '1' AND to_char(SYSDATE, 'yyyyMMdd') BETWEEN ksrq AND jsrq
) t WHERE yptbdm = ?)
SELECT min15 minprice, ROUND((min15 + max15) / 2, 2) wsspjj, nvl(min5, min10) wsszdj,min2price wsscdj 
FROM (SELECT b.yptbdm, MIN(b.cgjg) min15, MAX(b.cgjg) max15,
MIN(CASE WHEN ssdm IN ('北京', '天津', '浙江', '广东', '江苏') THEN b.cgjg END) min5,
MIN(CASE WHEN ssdm NOT IN ('北京', '天津', '浙江', '广东', '江苏') THEN b.cgjg END) min10,
MIN(b.cgjg) min2price
FROM temp b,(SELECT yptbdm,cgjg FROM temp WHERE rn=2) a WHERE b.yptbdm=a.yptbdm(+) 
GROUP BY b.yptbdm)








SELECT * FROM DRUGPRIC_PROVPRICDETL_C



















