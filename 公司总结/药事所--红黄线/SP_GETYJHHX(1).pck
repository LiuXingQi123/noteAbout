CREATE OR REPLACE PACKAGE SP_GETYJHHX IS

  PROCEDURE SF_GETHHX(PI_YPTBDM  IN varchar2,
                      lx         IN varchar2,
                      y1         out number,
                      y2         out number,
                      y3         out number,
                      y4         out number,
                      r1         out number,
                      ydy1         out number,
                      ydr1         out number,
                      ydr2         out number,
                      PO_RETCODE OUT NUMBER, --返回代码
                      PO_ERRMSG  OUT VARCHAR2);

END;
/
create or replace package body SP_GETYJHHX is

  PROCEDURE SF_GETHHX(PI_YPTBDM  IN varchar2,
                      lx         IN varchar2,
                      y1         out number,
                      y2         out number,
                      y3         out number,
                      y4         out number,
                      r1         out number,
                      ydy1         out number,
                      ydr1         out number,
                      ydr2         out number,
                      PO_RETCODE OUT NUMBER, --返回代码
                      PO_ERRMSG  OUT VARCHAR2) is
    nstep   number;
    v_ypfl  varchar2(100);
    v_sfxsq varchar2(1);
    v_hl    varchar2(200);
  
  begin
    PO_RETCODE := 1;
    nstep      := 1;
    select case
             when gzyj like '紧缺药品%' then
              '紧缺药品'
             when nvl(substr(trim(b.yptsbz), 15, 1), 0) = '1' or
                  nvl(substr(trim(b.yptsbz), 16, 1), 0) = '1' then
              '原研药品/参比制剂'
             when gzyj like '通过评价%' then
              '通过评价'
             when gzyj like '医保药品%' then
              '医保药品'
             when gzyj like '新增医保%' then
              '新增医保'
             when gzyj like '抗癌药品%' then
              '抗癌药品'
             else
              null
           end,
           case
             when gzyj like '%新申请%' then
              '1'
             else
              '0'
           end,
           case
             when nvl(trim(substrb(b.zxdwhl, 1, 10)), 0) <> '0' and nvl(trim(substrb(b.zxdwhl, 1, 10)), 0) <> '0.0' then
              trim(substrb(b.zxdwhl, 1, 10))
             when nvl(trim(substrb(b.zxdwhl, 31, 10)), 0) <> '0' and nvl(trim(substrb(b.zxdwhl, 31, 10)), 0) <> '0.0' then
              trim(substrb(b.zxdwhl, 31, 10))
             else
              '1'
           end 
      into v_ypfl, v_sfxsq, v_hl 
      from tb_ypcggz_fbk a, v_yppg_fbk b
     where a.yptbdm = b.yptbdm
       and a.yptbdm = PI_YPTBDM;
  if lx='YY' then 
    nstep := 2;
  
    --黄线1  原采购价（物价规则）
    --20200302cjl:依据03且新申请药品去除黄线1
    --20200902cjl:新申请药品去除黄线1
    --20210419:依据05药品黄线1取值为物价规则
  
    select max(case
             when v_sfxsq = '1'   then
              null
             when b.bz like  '%依据05%' then to_number(nvl(d.gzcsz, yjjg))
             else
              nvl(a.jg, yjjg)
           end)
      into y1
      from tb_yellowline1 a, tb_ypscyjjg c,tb_ypwjgz_fbk b,tb_ypwjgz_bdkmx d
     where a.yptbdm(+)=b.yptbdm and b.yptbdm = c.yptbdm(+) 
       and b.YPWJBDID=d.ypwjbdid and gzlx='10'
       and a.yxbz(+)='1' and a.jsrq(+)>to_char(sysdate,'yyyyMMdd')
       and c.yxbz(+) = '1'
       and b.yptbdm = PI_YPTBDM;
    --黄线2  人社编码同品种
    nstep := 3;
  

    select case
         when v_ypfl = '原研药品/参比制剂' then
          round(max(to_number(case when  b.YPFBSJID in ('1','2') then null 
                                --   when d.gzyj like  '%新申请%' then null 
                                   when b.bz like  '%依据01%' then null 
                                   when b.bz like  '%依据03%' then null
                                   when nvl(substrb(a.yptsbz, 15, 1), 0) = '1' or 
                                      nvl(substrb(a.yptsbz, 16, 1), 0) = '1' 
                                           then nvl(case when b.bz like  '%依据05%' then to_number(g.gzcsz) else c.jg end,e.yjjg) end) *--20210419依据05的物价规则作为取值来源
                    sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                    sf_getcbjbyyp(a.yptbdm, v_hl)),
                2) --原研查询全部药品（新申请除外）20210413：原研药品查询原研药品（新申请不除外）
         else
          nvl(round(max(case
                          when nvl(substrb(a.yptsbz, 15, 1), 0) = '1' or
                               nvl(substrb(a.yptsbz, 16, 1), 0) = '1' then
                           null
                          when lengthb(a.zxdwhl) < 51 then
                           null
                          when  b.YPFBSJID in ('1','2') then 
                           null
                          when d.gzyj like  '%新申请%' then 
                           null
                          when b.bz like  '%依据01%' then null 
                          when b.bz like  '%依据03%' then null 
                          when b.bz like  '%依据05%' then to_number(nvl(g.gzcsz ,e.yjjg)) --20210419依据05的物价规则作为取值来源
                          else
                           to_number(nvl(c.jg ,e.yjjg))
                        end * sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                        sf_getcbjbyyp(a.yptbdm, v_hl)),
                    2), --非原研查询除原研的药品（新申请除外）
              round(max(case
                          when nvl(substrb(a.yptsbz, 15, 1), 0) = '1' or
                               nvl(substrb(a.yptsbz, 16, 1), 0) = '1' then
                           null
                          when lengthb(a.zxdwhl) < 51 then
                           null
                          when  b.YPFBSJID in ('1','2') then 
                           null
                          when b.bz like  '%依据01%' then null 
                          when b.bz like  '%依据03%' then null
                          when b.bz like  '%依据05%' then to_number(nvl(g.gzcsz, e.yjjg))--20210419依据05的物价规则作为取值来源
                          else
                           to_number(nvl(c.jg, e.yjjg))
                        end * sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                        sf_getcbjbyyp(a.yptbdm, v_hl)),
                    2) --如除原研，除新申请 最高价为空的话，就包含新申请药品
              )
       end
       into y2
  from tb_yppg_fbk     t1,
       v_ybbm_mlsxh    t2,
       tb_yppg_fbk     a,
       tb_ypwjgz_fbk   b,
       tb_yellowline1 c,
       tb_ypcggz_fbk   d,
       tb_ypscyjjg     e,
       v_ybbm_mlsxh    f,
       tb_ypwjgz_bdkmx g
 where t1.YPCPMWBM=a.ypcpmwbm --20210408：目录编码改为标化通用名查询
   and t1.yptbdm = t2.yptbdm
   and t2.sjmlsxh = f.sjmlsxh--20210419:同目录顺序号
   and t2.zxybz = f.zxybz 
   and a.yptbdm = b.yptbdm
   and b.YPWJBDID=g.ypwjbdid
   and g.gzlx='10' 
   and a.yptbdm = d.yptbdm
   and a.yptbdm = e.yptbdm(+)
   and a.yptbdm = c.yptbdm(+)
   and a.yptbdm = f.yptbdm 
   and c.yxbz(+)='1' 
   and c.jsrq(+)>to_char(sysdate,'yyyyMMdd')
   and d.jczbzt <> '0'
   and e.yxbz(+) <>'0'
   and t1.yptbdm = PI_YPTBDM;

    --红线1  原研红线
    nstep := 4;
    if v_ypfl <> '原研药品/参比制剂' then
    select   max(case
                             when lengthb(a.ZXDWHL) < 51 then
                              null
                             when  e.YPFBSJID in ('1','2') then 
                              null
                             when e.bz like  '%依据01%' then null 
                             when e.bz like  '%依据03%' then null
                             when e.bz like  '%依据05%' then to_number(nvl(h.gzcsz, decode(g.yjjg,0,null,g.yjjg)))--20210419依据05的物价规则作为取值来源
                             else
                              to_number(nvl(f.jg, decode(g.yjjg,0,null,g.yjjg)))
                           end * sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                           sf_getcbjbyyp(a.yptbdm, v_hl)) 
      into r1
      from tb_yppg_fbk     t1,
           v_ybbm_mlsxh   t2,
           tb_yppg_fbk     a,
           v_ybbm_mlsxh   b,
           tb_ypcggz_fbk   d,
           tb_ypwjgz_fbk   e,
           tb_yellowline1 f,
           tb_ypscyjjg     g,
           tb_ypwjgz_bdkmx h
     where t1.yptbdm = t2.yptbdm
       and a.yptbdm = b.yptbdm
       and a.yptbdm = d.yptbdm
       and a.yptbdm = e.yptbdm
       and e.YPWJBDID=h.ypwjbdid
       and h.gzlx='10'
       and a.yptbdm = g.yptbdm(+)
       and a.yptbdm = f.yptbdm(+)
       and f.yxbz(+) = '1'
       and f.jsrq(+) > to_char(sysdate,'yyyyMMdd')
       and d.jczbzt <> '0'
       and g.yxbz(+) <> '0'
       and t2.sjmlsxh = b.sjmlsxh
       and t2.zxybz = b.zxybz 
       and (nvl(substr(trim(a.yptsbz), 15, 1), 0) = '1' or
           nvl(substr(trim(a.yptsbz), 16, 1), 0) = '1')
       and t1.yptbdm = PI_YPTBDM;
       
       --黄线3=红线*0.7
       y3:=round(r1*0.7,2);
       --红线四舍五入
       r1:=round(r1,2);
     end if;
    --黄线4  主流品种
    nstep := 6;
      select round(case when v_sfxsq='1' or v_ypfl = '通过评价' then  --20210402新申请或者过评药品黄线4取法改为一致
      max(case
                          when lengthb(g.ZXDWHL) < 51 then
                           0
                          when  d.YPFBSJID in ('1','2') then 
                           0
                          when d.bz like  '%依据01%' then 0 
                          when d.bz like  '%依据03%' then 0 
                          when h.gzyj like '%新申请%' then--20200803如主流药品为新申请药品，取实时议价最低价
                           (select min(cgjg)
                              from tb_yjjgbb
                             where yptbdm = a.cfgg
                               and zt = '20' and yxbz='1'
                               and to_char(sysdate, 'yyyyMMdd') between ksrq and jsrq)
                          else
                           to_number(nvl(decode(a.cgjg,0,null,a.cgjg), f.yjjg))--20210402价格在目录库中直接维护
                        end * sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                        sf_getcbjbyyp(a.cfgg, v_hl)) 
                        else  null end ,2)
        into y4
        from v_ybbm_mlsxh   t1,
             tb_yppg_fbk     t2,
             tb_ypmlk        a,
             v_ybbm_mlsxh   b,
             tb_ypwjgz_fbk   d,
             tb_ypscyjjg     f,
             tb_yppg_fbk     g,
             tb_ypcggz_fbk   h
       where a.cfgg = b.yptbdm
         and a.cfgg = d.yptbdm
         and a.cfgg = g.yptbdm
         and a.cfgg = h.yptbdm
         and a.cfgg = f.yptbdm(+)
         and t1.sjmlsxh = b.sjmlsxh
         and t1.zxybz = b.zxybz
         and t1.YPTBDM = t2.yptbdm
         and f.yxbz(+) = '1'
         and a.ypmllx = '06'
         and a.yxbz='1'
         and t1.yptbdm = PI_YPTBDM;

else 
  --药店红线1：该药品在医疗机构最高采购价按差比价折算后的零售价。
    nstep := 7;
    select  
           max(t.cgjg)   
       into ydr1
  from  
       (select nvl(nvl(m1.yptbdm,m2.yptbdm),m3.yptbdm) yptbdm,nvl(nvl(m1.cgjg,m2.cgjg),m3.cgjg) cgjg
       from tb_yyzgcgj m1, tb_yyzgcgj m2,tb_yyzgcgj m3
       where m3.yptbdm=m1.yptbdm(+) and m3.yptbdm=m2.yptbdm(+)
       and m1.yxbz(+)='1' and m2.yxbz(+)='1' AND M3.YXBZ='1' 
       and m1.yxq(+)=3 and m2.yxq(+)=6 and m3.yxq=0
       and to_char(sysdate,'yyyyMMdd') between m3.ksrq and m3.jsrq 
       and to_char(sysdate,'yyyyMMdd') between m1.ksrq(+) and m1.jsrq(+) 
       and to_char(sysdate,'yyyyMMdd') between m2.ksrq(+) and m2.jsrq(+) ) t
 where   t.yptbdm = PI_YPTBDM;
    
    --药店红线2：本企业同品种（mlsxh）药品（原研参比除外）医疗机构最高采购价按差比价折算后的零售价。
    nstep := 8;
    select   case
         when v_ypfl = '原研药品/参比制剂' then--原研只看原研
          max(case when nvl(substrb(a.yptsbz, 15, 1), 0) = '1' or 
                                      nvl(substrb(a.yptsbz, 16, 1), 0) = '1' then d.cgjg end * 
                    sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                    sf_getcbjbyyp(a.yptbdm, v_hl))   
         else --普通看普通
           max(case when nvl(substrb(a.yptsbz, 15, 1), 0) = '1' or 
                                      nvl(substrb(a.yptsbz, 16, 1), 0) = '1' then null else  d.cgjg end * 
                    sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                    sf_getcbjbyyp(a.yptbdm, v_hl))   end
           
        
       into ydr2
  from v_yppg_fbk     t1,
       v_ybbm_mlsxh    t2,
       v_yppg_fbk     a,  
       v_ybbm_mlsxh    c ,
       (select nvl(nvl(m1.yptbdm,m2.yptbdm),m3.yptbdm) yptbdm,nvl(nvl(m1.cgjg,m2.cgjg),m3.cgjg) cgjg
       from tb_yyzgcgj m1, tb_yyzgcgj m2,tb_yyzgcgj m3
       where m3.yptbdm=m1.yptbdm(+) and m3.yptbdm=m2.yptbdm(+)
       and m1.yxbz(+)='1' and m2.yxbz(+)='1' and m3.yxbz='1'
       and m1.yxq(+)=3 and m2.yxq(+)=6 and m3.yxq=0
       and to_char(sysdate,'yyyyMMdd') between m3.ksrq and m3.jsrq 
       and to_char(sysdate,'yyyyMMdd') between m1.ksrq(+) and m1.jsrq(+) 
       and to_char(sysdate,'yyyyMMdd') between m2.ksrq(+) and m2.jsrq(+)) d
 where trim(upper(to_single_byte(t1.scqymc)))=trim(upper(to_single_byte(a.scqymc))) 
   and t1.yptbdm = t2.yptbdm
   and a.yptbdm=c.yptbdm
   and t2.sjmlsxh = c.sjmlsxh 
   and t2.zxybz = c.zxybz 
   and a.yptbdm=d.yptbdm(+) 
   and t1.yptbdm = PI_YPTBDM;
    --药店黄线：同通用名药品(原研参比除外)在医疗机构的最高采购价按差比价折算后的零售价
    nstep := 9;
     select  case
         when v_ypfl = '原研药品/参比制剂' then--原研只看原研
           max(case when nvl(substrb(a.yptsbz, 15, 1), 0) = '1' or 
                                      nvl(substrb(a.yptsbz, 16, 1), 0) = '1' then d.cgjg end  * 
                    sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                    sf_getcbjbyyp(a.yptbdm, v_hl))  
          else --普通看普通
            max(case when nvl(substrb(a.yptsbz, 15, 1), 0) = '1' or 
                                      nvl(substrb(a.yptsbz, 16, 1), 0) = '1' then null else  d.cgjg end   * 
                    sf_getcbjbyyp(PI_YPTBDM, v_hl) /
                    sf_getcbjbyyp(a.yptbdm, v_hl))  end
        
       into ydy1
  from v_yppg_fbk     t1, 
       v_yppg_fbk     a,   
       (select nvl(nvl(m1.yptbdm,m2.yptbdm),m3.yptbdm) yptbdm,nvl(nvl(m1.cgjg,m2.cgjg),m3.cgjg) cgjg
       from tb_yyzgcgj m1, tb_yyzgcgj m2,tb_yyzgcgj m3
       where m3.yptbdm=m1.yptbdm(+) and m3.yptbdm=m2.yptbdm(+)
       and m1.yxbz(+)='1' and m2.yxbz(+)='1' and m3.yxbz='1'
       and m1.yxq(+)=3 and m2.yxq(+)=6 and m3.yxq=0
       and to_char(sysdate,'yyyyMMdd') between m3.ksrq and m3.jsrq 
       and to_char(sysdate,'yyyyMMdd') between m1.ksrq(+) and m1.jsrq(+) 
       and to_char(sysdate,'yyyyMMdd') between m2.ksrq(+) and m2.jsrq(+)) d
 where t1.ypcpmwbm=a.ypcpmwbm 
   and a.yptbdm=d.yptbdm(+) 
   and t1.yptbdm = PI_YPTBDM;
      
      select case
               when ydr1 >= 500 then
                round(ydr1,2) + 75
               when ydr1 < 500 then
                round(ydr1 * 1.15,2)
             end,
             case
               when ydr2 >= 500 then
                round(ydr2,2) + 75
               when ydr2 < 500 then
                round(ydr2 * 1.15,2)
             end,
             case
               when ydy1 >= 500 then
                round(ydy1,2) + 75
               when ydy1 < 500 then
                round(ydy1 * 1.15,2)
             end
             
        into ydr1, ydr2,ydy1
        from dual;
      end if;

  EXCEPTION
    WHEN OTHERS THEN
      PO_RETCODE := 2;
      PO_ERRMSG  := nstep || '处理出现错误,错误内容为:' || SQLERRM;
    
  end;

end SP_GETYJHHX;
/
