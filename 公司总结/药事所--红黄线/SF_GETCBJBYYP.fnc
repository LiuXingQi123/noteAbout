create or replace function SF_GETCBJBYYP(PI_YPTBDM IN VARCHAR2,
                                         PI_MINHL  IN VARCHAR2)
  RETURN NUMBER IS
  PO_X     NUMBER;
  V_HL     VARCHAR2(10);
  V_ZL     VARCHAR2(10);
  V_BZSL   VARCHAR2(10);
  V_JJSLDW VARCHAR2(10);
  V_FYTS   VARCHAR2(10);
  V_CBCS   VARCHAR2(1);
  V_CBL    NUMBER(16,4);
  V_ZXYBZ  varchar2(1);

BEGIN
  select trim(substrb(t1.zxdwhl, 1, 10)), --含量
         trim(substrb(t1.zxdwhl, 31, 10)), --装量
         trim(substrb(t1.zxdwhl, 41, 10)), --包装数量
         trim(substrb(t1.zxdwhl, 66, 5)), --计价数量单位
         trim(substrb(t1.zxdwhl, 71, 10)), --服用天数
         case
           when t3.jxmc in (select gljxmc from TB_YJCBL where yxbz = '1') then
            '1'
           else
            '0'
         end,
         case when zxybz='1' then nvl(t2.cbl, 1)  
              when zxybz='2'  and  t1.bsjx like  '%无糖%' then 1.1 else 1 end ,--20210825:中成药如果表述剂型含无糖字样则为晚唐的话，有糖*1.1=无糖
         t1.ZXYBZ
    into V_HL, V_ZL, V_BZSL, V_JJSLDW, V_FYTS, V_CBCS, v_cbl,v_zxybz
    from v_yppg_fbk t1, tb_yjcbl t2,(select distinct yptbdm,c.jxmc from tb_ypybgz_fbk a,tb_ybgz_mlgzxx b,tb_dic_ypjx c
    where a.mlsxh=b.mlsxh and a.zxybz=b.zxybz and b.yxbz='1' and nvl(b.gljxbm,b.jxbm)=c.jxbm(+) and c.yxbz(+)='1' ) t3
   where /*t1.bsjx = t2.bsjx(+)*/instrb(t1.bsjx,t2.bsjx(+))>0 and t1.yptbdm=t3.yptbdm
     and t2.yxbz(+) = '1'
     and t1.yptbdm = PI_YPTBDM;
     
  if V_JJSLDW = '天' then
    PO_X := V_FYTS;
    if v_zxybz ='2' then 
      PO_X := PO_X * v_cbl;
    end if;
  else
    --无包装数量返回1
  if v_bzsl is null then return 1;
  end if;
    PO_X := case
              when V_HL <> '0' and V_HL <> '0.0' then
               power(1.7, log(2, V_HL / PI_MINHL))
              when (V_HL = '0' or V_HL = '0.0' ) and (V_ZL <> '0' and V_ZL <>'0.0') then
               power(1.9, log(2, V_ZL / PI_MINHL))
              else
               1
            end * case
              when v_zxybz ='2' then --中成药包装数量直接整乘整除
                v_bzsl*v_cbl
              when V_CBCS = '1' then
               power(1.95, log(2, V_BZSL))*v_cbl
              when V_CBCS = '0' then
               V_bzsl*1
            end;
  end if;
  RETURN(PO_X);
EXCEPTION
  WHEN OTHERS THEN
    RETURN(-1);
end SF_GETCBJBYYP;
/
