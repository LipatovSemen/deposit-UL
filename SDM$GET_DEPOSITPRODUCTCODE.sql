-- Start of DDL Script for Function GC.SDM$GET_DEPOSITPRODUCTCODE
-- Generated 06-ноя-2023 18:12:02 from GC@BANK

CREATE OR REPLACE 
FUNCTION sdm$get_depositproductcode(vDOGID VARCHAR2) 
RETURN VARCHAR2
IS 
  vDEPOSITPRODUCTCODE VARCHAR2(20);
BEGIN 


begin
select max(cc.deposit_name) 
 into vDEPOSITPRODUCTCODE 
          from gc.vw$dog_doga d
              ,gc.dog dop
              ,gc.doga darc
              ,gc.j_qual j
              ,gc.sdm$list_deposit_cc cc
         where 1=1
           and d.objid = vDOGID
           and dop.objid(+)=d.objid
           and darc.objid(+)=d.objid
           and (j.name = gc.rep_calc.vkl_on_date_a(darc.objid,darc.DOpen) and darc.objid is not null
                 or j.name = gc.rep_calc.vkl_on_date(dop.objid,dop.DOpen) and darc.objid is null
                 )         
           and j.objtype = 'DEPTYP'
           and j.objid = 0
           and j.num = 0
           and j.value = cc.deposit_id;
EXCEPTION WHEN OTHERS THEN
vDEPOSITPRODUCTCODE:=null;
END;           
RETURN vDEPOSITPRODUCTCODE;
END;
/



-- End of DDL Script for Function GC.SDM$GET_DEPOSITPRODUCTCODE

