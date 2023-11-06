-- Start of DDL Script for Procedure GC.SDM$INS_ORG
-- Generated 06-ноя-2023 18:13:29 from GC@BANK

CREATE OR REPLACE 
PROCEDURE sdm$ins_org
   ( vNameClient       in varchar2
     ,vAlterNameClient in varchar2
     ,vInn             in varchar2
     ,vKio             in varchar2
     ,vMainMember      in number
     ,vOGRN            in varchar2
     ,vMREG            in varchar2
     ,vREGDATE         in varchar2
     ,vKPP             in varchar2
     ,vOKONHID         in varchar2
     ,vBranchID        in varchar2
     ,vBankAcc         in varchar2
     ,vCountry_u       in varchar2
     ,vRegion_u        in varchar2
     ,vCity_u          in varchar2
     ,vCityPuntk_u     in varchar2
     ,vStreet_u        in varchar2
     ,vHouse_u         in varchar2
     ,vKorp_u          in varchar2
     ,vStr_u           in varchar2
     ,vFlat_u          in varchar2
     ,vCountry_m       in varchar2
     ,vRegion_m        in varchar2
     ,vCity_m          in varchar2
     ,vCityPuntk_m     in varchar2
     ,vStreet_m        in varchar2
     ,vHouse_m         in varchar2
     ,vKorp_m          in varchar2
     ,vStr_m           in varchar2
     ,vFlat_m          in varchar2     
     ,vRequestID       in varchar2
     ,vInstitutionID   in varchar2
     
   )
   as
     vErrText       VARCHAR2(200);
     vSubj_ID       VARCHAR2(12);
     vBANKMFO       VARCHAR2(9);
     vBANKKS        VARCHAR2(20);
     VBANKGOROD     VARCHAR2(100);
     vBankID        VARCHAR2(20);
     vRES           VARCHAR2(2000);
     vCountryID_U   VARCHAR2(12);
     vCountryID_M   VARCHAR2(12);
     vAddr          GC.ADDR$P_ARM.TADDR;
     Subsystem      VARCHAR2(10);
     matchtxt       VARCHAR2(30);
     matchres       NUMBER;
     vOGRN_IP       VARCHAR2(15);
     vOGRN_UL       VARCHAR2(15);
     vResident      INT;
     
begin
gc.p_support.arm_start();

insert into gc.sdm$log_deposit_cc
select vRequestID,sysdate,vinstitutionID,'Заведение клиента','WAIT','' from dual;
commit;

IF vBranchID = '2000' THEN
vBankID:='382';
vBANKMFO:='044525685';
vBANKKS:='30101810845250000685';
vBANKGOROD:= 'МОСКВА';
End IF;
IF vBranchID = '10000002726' THEN
vBankID:='1787601';
vBANKMFO:='042007778';
vBANKKS:='30101810500000000778';
vBANKGOROD:= 'ВОРОНЕЖ';
End IF;
IF vBranchID = '10065608260' THEN
vBankID:='185746585';
vBANKMFO:='046577978';
vBANKKS:='30101810400000000978';
vBANKGOROD:= 'ЕКАТЕРИНБУРГ';
End IF;
IF vBranchID = '10000002624' THEN
vBankID:='1788509';
vBANKMFO:='040407862';
vBANKKS:='30101810500000000862';
vBANKGOROD:= 'КРАСНОЯРСК';
End IF;
IF vBranchID = '10000002734' THEN
vBankID:='2188666';
vBANKMFO:='042202745';
vBANKKS:='30101810800000000745';
vBANKGOROD:= 'НИЖНИЙ НОВГОРОД';
End IF;
IF vBranchID = '10000004073' THEN
vBankID:='1788104';
vBANKMFO:='045773843';
vBANKKS:='30101810357730000843';
vBANKGOROD:= 'ПЕРМЬ';
End IF;
IF vBranchID = '10005505775' THEN
vBankID:='5004115';
vBANKMFO:='046015088';
vBANKKS:='30101810860150000088';
vBANKGOROD:= 'РОСТОВ';
End IF;
IF vBranchID = '10000002825' THEN
vBankID:='1228080';
vBANKMFO:='044030878';
vBANKKS:='30101810000000000878';
vBANKGOROD:= 'САНКТ-ПЕТЕРБУРГ';
End IF;
IF vBranchID = '10000174395' THEN
vBankID:='1368349';
vBANKMFO:='042809921';
vBANKKS:='30101810500000000921';
vBANKGOROD:= 'ТВЕРЬ';
End IF;

vOGRN_UL:=vOGRN;
vOGRN_IP:='';

IF LENGTH(vINN) = 12 THEN 
vOGRN_IP:=vOGRN;
vOGRN_UL:='';
END IF;

--Диасофт MainMember = 1 --Резидент MainMember = 0 --Нерезидент
--РБС vResident = 0 --Резидент vResident = 1 --Нерезидент
IF vMainMember = 1 then
vResident:=0;
else
vResident:=1;
END IF;

begin
GC.INS_ORG1(vSubj_ID
           ,vErrText
           ,vNameClient
           ,replace(vAlterNameClient,'?','')
           ,V_IDN=>regexp_replace(vInn,'\D')
           ,V_OGRN=>regexp_replace(replace(vOGRN_UL,'?',''),'\D')
           ,V_OGRN_IP=>regexp_replace(replace(vOGRN_IP,'?',''),'\D')
           ,V_MREG=>replace(vMREG,'?','')
           ,V_REG_DATE=>to_date(replace(vREGDATE,'?',''),'dd/mm/yyyy')
           ,V_KPP=>regexp_replace(replace(vKPP,'?',''),'\D')
           ,V_BANK_ACC=>vBankAcc
           ,V_BANK_ID=>vBANKID
           ,V_BANK_MFO=>vBANKMFO
           ,V_BANK_KS=>vBANKKS
           ,V_BANK_GOROD=>VBANKGOROD
           ,V_KIO=>regexp_replace(replace(vKIO,'?',''),'\D')
           ,V_RESIDENT=>vResident
           ,V_OKONH_ID=>VOKONHID);
--dbms_lock.sleep(10);
commit;          
EXCEPTION WHEN OTHERS THEN
vRES:=SQLERRM;
update gc.sdm$log_deposit_cc
set text = vRES
   ,status = 'ERROR'
where RequestID = vRequestID
  and InstitutionID = vInstitutionID;
commit;          
end;


IF vSubj_ID is not null
  and vCity_u is not null then
  BEGIN
                BEGIN
                SELECT max(ID)
                INTO vCountryID_U
                FROM GC.COUNTRIES 
                WHERE OTHERCODE = vCountry_u;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                vCountryID_U := '1181';
                END;
      vAddr:= gc.addr$p_arm.prepareAddr(pobjtype => 'ORG',
                                     pobjid => vSubj_ID,
                                     paddrtype => 'REG',
                                     pcountry => replace(vCountryID_U,'?',''),
                                     pregion => replace(vRegion_u,'?',''),
                                     pdistrict => null,
                                     pcity => replace(vCity_u,'?',''),
                                     pplace => replace(vCityPuntk_u,'?',''),
                                     pstreet => replace(vStreet_u,'?',''),
                                     pbuilding => replace(vHouse_u,'?',''),
                                     --plocation => vLocation,   --элемент планированный структуры
                                     pstr => replace(vStr_u,'?',''),
                                     pflat => replace(vFlat_u,'?',''),
                                     pkorp => replace(vKorp_u,'?',''),
                                     pformat => 'FREE',
                                     pMatchAddr => 'N');                                       
                                     commit;                                  
        Subsystem:=gc.addr$p_arm.getDossSubsystem(pSubjId => vSubj_ID);
        gc.addr$p_arm.saveAddr(vAddr);
        --Сопоставим ФИАС 
        gc.addr$p_arm.doMatchAddrId(pMatchTxt => matchtxt, pMatchRes =>matchres, pAddrId => vAddr.Addr_id);

COMMIT;
             EXCEPTION WHEN OTHERS THEN
                null;
       
  END;
  
  
END IF;  


IF vSubj_ID is not null
  and vCity_m is not null then
  BEGIN
                BEGIN
                SELECT max(ID)
                INTO vCountryID_m
                FROM GC.COUNTRIES 
                WHERE OTHERCODE = vCountry_m;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                vCountryID_m := '1181';
                END;
      vAddr:= gc.addr$p_arm.prepareAddr(pobjtype => 'ORG',
                                     pobjid => vSubj_ID,
                                     paddrtype => 'PLACE',
                                     pcountry => vCountryID_m,
                                     pregion => replace(vRegion_m,'?',''),
                                     pdistrict => null,
                                     pcity => replace(vCity_m,'?',''),
                                     pplace => replace(vCityPuntk_m,'?',''),
                                     pstreet => replace(vStreet_m,'?',''),
                                     pbuilding => replace(vHouse_m,'?',''),
                                     --plocation => vLocation,   --элемент планированный структуры
                                     pstr => replace(vStr_m,'?',''),
                                     pflat => replace(vFlat_m,'?',''),
                                     pkorp => replace(vKorp_m,'?',''),
                                     pformat => 'FREE',
                                     pMatchAddr => 'N');                                       
                                     commit;                                  
        Subsystem:=gc.addr$p_arm.getDossSubsystem(pSubjId => vSubj_ID);
        gc.addr$p_arm.saveAddr(vAddr);
        --Сопоставим ФИАС 
        gc.addr$p_arm.doMatchAddrId(pMatchTxt => matchtxt, pMatchRes =>matchres, pAddrId => vAddr.Addr_ID);

COMMIT;
             EXCEPTION WHEN OTHERS THEN
                null;
       
  END;
  
  
END IF;



IF vRES is null then
update gc.sdm$log_deposit_cc
set text = vSubj_ID
   ,status = 'SUCCESS'
where RequestID = vRequestID
  and InstitutionID = vInstitutionID;
end if;  
commit;
end;
/



-- End of DDL Script for Procedure GC.SDM$INS_ORG

