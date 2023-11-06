-- Start of DDL Script for Procedure GC.SDM$OPEN_DEPOSIT_CC
-- Generated 06-ноя-2023 18:10:31 from GC@BANK

CREATE OR REPLACE 
PROCEDURE sdm$open_deposit_cc
   ( vSubj_ID in varchar2
     ,vCur in varchar2
     ,vPeriod in varchar2
     ,vFinProd in varchar2    
     ,vBranchID in varchar2
     ,vOtdel in varchar2
     ,vApplication_Number in varchar2
     ,vApplication_Date in varchar2
     ,vinterestAccountNumber in varchar2
     ,vrefundAccountNumber in varchar2 
     ,vRequestID in varchar2
     ,vDocID in varchar2
     ,vInstitutionID in varchar2
   )
   as

    vDog_ID_New      GC.DOG.OBJID%TYPE;
    t_tmp            VARCHAR2 (40);
    res              BOOLEAN := NULL;
    vS               VARCHAR2 (12);
    vCura            VARCHAR2 (3);
    vCurName         VARCHAR2 (50);
    vRowID           ROWID;       
    vNns             VARCHAR2 (20); 
    vBs              VARCHAR2 (5);
    vSHORT_NAME      VARCHAR2(100);
    vRES             VARCHAR2(2000);
    vCUR_FinProd     VARCHAR2(3); 
    vAttr_Appl_Num   VARCHAR2(15);
    vAttr_Appl_Dat   VARCHAR2(15);
    vAttr_Req_ID     VARCHAR2(15);
    vAttr_Doc_ID     VARCHAR2(15);    
    vFilial_ID       VARCHAR2(15);


--Выплата процентов
    vVNESH_PR_TYPE   VARCHAR2(50);
    vVNESH_PR_DOG    VARCHAR2(12);
    DOG_ID_PRC       GC.DOG.OBJID%TYPE;
    vBS_PRC          VARCHAR2 (5);
    vCUR_PRC         VARCHAR2 (3);
    vS_PRC           VARCHAR2 (12);
    vCura_PRC        VARCHAR2 (3);
    vCurName_PRC     VARCHAR2 (50);
    vRowID_PRC       ROWID;
    vOBJID_PRC       GC.ACC.OBJID%TYPE;
    vFinProd_PRC     VARCHAR2 (12);
    vRekvId_PRC      VARCHAR2 (15);
    vREZ_PRC         NUMBER;
    vNAME_ORG        VARCHAR2 (200);
    vINN_ORG         VARCHAR2 (12);
    vBIK_DOG         VARCHAR2 (9); 
    vKS_DOG          VARCHAR2 (20);
    vBANK_NAME       VARCHAR2 (200);
    vBANK_ID         VARCHAR2 (12);  
    vBank_CITY       VARCHAR2 (100);
    vRegSbrosID      NUMBER;
    
--Счет для перевода средств по закрытию
    vTRANS_COMPL_DEP_DOG  VARCHAR2(12);
    DOG_ID_RFD            GC.DOG.OBJID%TYPE;
    vBS_RFD               VARCHAR2 (5);
    vCUR_RFD              VARCHAR2 (3);
    vS_RFD                VARCHAR2 (12);
    vCura_RFD             VARCHAR2 (3);
    vCurName_RFD          VARCHAR2 (50);
    vRowID_RFD            ROWID;  
    vOBJID_RFD            GC.ACC.OBJID%TYPE;
    vFinProd_RFD          VARCHAR2 (12);
    vRekvId_RFD           VARCHAR2 (15);
    vREZ_RFD              NUMBER; 
           
       
    
BEGIN

gc.user_login.arm_end;
GC.P_SUPPORT.ARM_START();

IF vBranchID = '2000' THEN
vFilial_ID:='M';
gc.set_filial('M');
End IF;
IF vBranchID = '10000002726' THEN
vFilial_ID:='1787601';
gc.set_filial('1787601');
End IF;
IF vBranchID = '10065608260' THEN
vFilial_ID:='185746585';
gc.set_filial('185746585');
End IF;
IF vBranchID = '10000002624' THEN
vFilial_ID:='1788509';
gc.set_filial('1788509');
End IF;
IF vBranchID = '10000002734' THEN
vFilial_ID:='2188666';
gc.set_filial('2188666');
End IF;
IF vBranchID = '10000004073' THEN
vFilial_ID:='1788104';
gc.set_filial('1788104');
End IF;
IF vBranchID = '10005505775' THEN
vFilial_ID:='5004115';
gc.set_filial('5004115');
End IF;
IF vBranchID = '10000002825' THEN
vFilial_ID:='1228080';
gc.set_filial('1228080');
End IF;
IF vBranchID = '10000174395' THEN
vFilial_ID:='1368349';
gc.set_filial('1368349');
End IF;

INSERT INTO GC.SDM$LOG_DEPOSIT_CC
SELECT VREQUESTID,SYSDATE,VINSTITUTIONID,'Открытие депозита','WAIT','' FROM DUAL;
COMMIT;

   
    BEGIN
       SELECT B.BS,B.CUR 
        INTO vBS,vCUR_FinProd
        FROM GC.L_QUAL L
            ,GC.BAL B
     WHERE L.OBJID  = vFinProd
       AND L.FILIAL = vFilial_ID
       AND B.OBJID  = L.VALUE; 
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            NULL;
    END;       
    
    
    IF vCUR <> vCUR_FinProd THEN
    update GC.SDM$LOG_DEPOSIT_CC
        set text = 'Открываемая валюта не совпадает с валютой финансового продукта'
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Открытие депозита';   
    commit;     
    End IF;
    
    BEGIN
        SELECT J.NAME 
          INTO vSHORT_NAME
          FROM GC.J_QUAL J
         WHERE J.VALUE   = vFinProd
           AND J.OBJID   = '0'
           AND J.OBJTYPE = 'DEPTYP';
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            NULL;
    END;           
    
    
    If vCUR = vCUR_FinProd then
    begin
    gc.vvkl$p_main.checkvkl (RTRIM (gc.qual$p_main.get ('DEPTYP', vFinProd, 'V_VKL_VNESH_PR')), NVL (gc.user_login.otdel_id, ''), 35);    
    EXCEPTION WHEN OTHERS THEN
    vRES:=SQLERRM;
    update GC.SDM$LOG_DEPOSIT_CC
        set text = vRES
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Открытие депозита';   
    commit;           
    END;
    begin
    gc.ins_dog_buy_tune (vDog_ID_New, vCur, vSubj_ID, 'Открытие депозита через ДБО ЮЛ', NVL ( ( '1' != '0'), FALSE), v_bs => vBS, v_accmode => '', v_otdel => case when vOtdel = '0' then vFilial_ID else vOtdel end, no_nns => TRUE);
    EXCEPTION WHEN OTHERS THEN
    vRES:=SQLERRM;
    update GC.SDM$LOG_DEPOSIT_CC
        set text = vRES
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Открытие депозита';    
    commit;          
    END;
    begin
    gc.p_kr.set_dep_period (vDog_ID_New, gc.obj2type (vDog_ID_New), vFinProd, vPeriod);
    EXCEPTION WHEN OTHERS THEN
    vRES:=SQLERRM;
    update GC.SDM$LOG_DEPOSIT_CC
        set text = vRES
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Открытие депозита';
    commit;              
    END;
    --dogid := vDog_ID_New;

    SELECT d.s, c.cur_a, c.name, ROWIDTOCHAR (d.ROWID) rowi
      INTO vS, vCura, vCurname, vRowiD
      FROM gc.dog d, gc.currency c
     WHERE d.objid = vDog_ID_New AND c.cur_n(+) = d.cur;

    DECLARE
        old_global_commit   BOOLEAN;
    BEGIN
        old_global_commit := gc.std_proc.global_commit;
        gc.std_proc.global_commit := FALSE;
        res :=
            gc.std_proc.renew (
            vDog_ID_New, next_name => vSHORT_NAME, txt_ => 'Открытие договора через ДБО ЮЛ. Процедура GC.SDM$OPEN_DEPOSIT_CC');
        gc.std_proc.global_commit := old_global_commit;
    EXCEPTION
        WHEN OTHERS
        THEN
            gc.std_proc.global_commit := old_global_commit;
    vRES:=SQLERRM;
    update GC.SDM$LOG_DEPOSIT_CC
        set text = vRES
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Открытие депозита';    
          commit;       
    END;

    IF NOT res
    THEN
        update GC.SDM$LOG_DEPOSIT_CC
        set text = 'ORA-20999: BOOKKEEP-00115: Назначение вида вклада неуспешно (данные заняты) !'
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Открытие депозита';
          commit;
          --gc.app_err.put ('BOOKKEEP', 115); --БЫЛО
    ELSIF res IS NULL
    THEN
        update GC.SDM$LOG_DEPOSIT_CC
        set text = '9:30:51  line 1: ORA-20999: BOOKKEEP-00116: Вид вклада не определен !'
           ,status = 'ERROR'  
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Открытие депозита';
          commit;          
          --gc.app_err.put ('BOOKKEEP', 116); --БЫЛО           
    END IF;


IF vS is not null then
    t_tmp :=
        gc.nns.new ( vs, vCur,
        v_mask => RTRIM (gc.qual$p_main.get ('DEPTYP', vFinProd, 'NNS_SHORT_MASK')),
        v_nns => vNns, v_text => 'Открытие договора через ДБО ЮЛ. Процедура GC.SDM$OPEN_DEPOSIT_CC',
        v_userinputnns => 'N');
end IF;   

IF vDog_ID_New is not null then
--Навесим атрибуты на договор 
SELECT SV.ID
INTO vAttr_Appl_Num
 FROM GC.SPRAV$VALUES SV 
WHERE 1=1
  AND SV.ID_TYPE = '5484' --Справочник атрибутов договора
  AND SV.VALUE1 = 'CORREQTS_APPLICATION_NUMBER';
  
SELECT SV.ID
INTO vAttr_Appl_Dat
 FROM GC.SPRAV$VALUES SV 
WHERE 1=1
  AND SV.ID_TYPE = '5484' --Справочник атрибутов договора
  AND SV.VALUE1 = 'CORREQTS_APPLICATION_DATE';  
  
SELECT SV.ID
INTO vAttr_Req_ID
 FROM GC.SPRAV$VALUES SV 
WHERE 1=1
  AND SV.ID_TYPE = '5484' --Справочник атрибутов договора
  AND SV.VALUE1 = 'CORREQTS_REQUEST_ID';    
  
SELECT SV.ID
INTO vAttr_Doc_ID
 FROM GC.SPRAV$VALUES SV 
WHERE 1=1
  AND SV.ID_TYPE = '5484' --Справочник атрибутов договора
  AND SV.VALUE1 = 'CORREQTS_DOC_ID';   
   
gc.Obj_Attr_Ins(vDog_ID_New,'DOGBUY',vAttr_Appl_Num,vApplication_Number,'Добавлено автоматически при открытии депозита через ДБО ЮЛ',sysdate,pOldValueId=>'');
gc.Obj_Attr_Ins(vDog_ID_New,'DOGBUY',vAttr_Appl_Dat,vApplication_Date,'Добавлено автоматически при открытии депозита через ДБО ЮЛ',sysdate,pOldValueId=>'');
gc.Obj_Attr_Ins(vDog_ID_New,'DOGBUY',vAttr_Req_ID,vRequestID,'Добавлено автоматически при открытии депозита через ДБО ЮЛ',sysdate,pOldValueId=>'');
gc.Obj_Attr_Ins(vDog_ID_New,'DOGBUY',vAttr_Doc_ID,vDocID,'Добавлено автоматически при открытии депозита через ДБО ЮЛ',sysdate,pOldValueId=>'');
commit;
END IF;

IF vDog_ID_New is not null then
--Обновим статус
        update GC.SDM$LOG_DEPOSIT_CC
        set text = vDog_ID_New
           ,status = 'SUCCESS'  
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Открытие депозита';    
END IF;

--Разбираемся со счетом выплаты процентов
IF vDog_ID_New is not null then


--Есть ли настройка на вкладе??
SELECT 
GC.QUAL$P_MAIN.GET('DOGBUY',vDog_ID_New,'V_VKL_VNESH_PR')
INTO vVNESH_PR_TYPE
FROM DUAL;

--Должен быть открыт счет
--Ищем может такой счет уже открыт
IF vVNESH_PR_TYPE is not null then
BEGIN
SELECT MAX(DD.OBJID)
INTO vVNESH_PR_DOG
FROM GC.DOG D
    ,GC.DOG DD
    ,GC.REGTRANS RT
    ,GC.REKV_DOC R
WHERE 1=1
  AND D.OBJID = vDog_ID_New
  AND D.SUBJ_ID = DD.SUBJ_ID
  AND DD.V_VKL = vVNESH_PR_TYPE  
  AND DD.OBJID = RT.DOG_ID
  AND RT.OBJTYPE = 'R_DROP'
  AND RT.REKV = R.UNO
  AND R.ACC = vinterestAccountNumber;
 EXCEPTION WHEN NO_DATA_FOUND THEN
 vVNESH_PR_DOG := NULL;
END;    
END IF;

--Если счет нашли, то на договор добавляем настройку VNESH_PR со значением найденного договора
IF vVNESH_PR_TYPE is not null 
 AND vVNESH_PR_DOG is not null THEN
    if not gc.radd_q(objtype_ =>'DOGBUY'
                      ,objid_ =>vDog_ID_New
                       ,name_ =>'VNESH_PR'
                        ,num_ =>'0'
                        ,txt_ =>'Добавлено автоматически при открытии вклада через ДБО ЮЛ'
                      ,value_ =>vVNESH_PR_DOG
                     ,date_b_ => sysdate
                     ,date_e_ => ''
                      ,filial =>null)
    then   gc.app_err.put ('BOOKKEEP', 292);
   
    end if;
    gc.Q_Refresh(vDog_ID_New, 'VNESH_PR', filial=>null);
COMMIT;    
END IF; 
 
--Счет не нашли, значит открываем новый договор и привязываем его
IF vVNESH_PR_TYPE is not null 
AND vVNESH_PR_DOG is null THEN

INSERT INTO GC.SDM$LOG_DEPOSIT_CC
SELECT VREQUESTID,SYSDATE,VINSTITUTIONID,'Открытие счета для выплаты процентов','WAIT','' FROM DUAL;
COMMIT;

    BEGIN
       SELECT B.BS,B.CUR,J.VALUE 
        INTO vBS_PRC,vCUR_PRC,vFinProd_PRC
        FROM GC.J_QUAL J
            ,GC.L_QUAL L
            ,GC.BAL B
     WHERE 1=1
       AND J.OBJTYPE = 'DEPTYP'
       AND J.OBJID = 0
       AND J.NAME = vVNESH_PR_TYPE
       AND L.OBJID  = J.VALUE
       AND L.FILIAL = vFilial_ID
       AND B.OBJID  = L.VALUE; 
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            NULL;
    END;    

begin
GC.INS_DOG_BUY_TUNE (DOG_ID_PRC
                    ,vCur_PRC
                    ,vSubj_ID
                    ,'Открытие счета через ДБО ЮЛ'
                    ,NVL ( ( '1' != '0'),FALSE)
                    ,v_bs => vBS_PRC
                    ,v_accmode => ''
                    ,v_otdel => case when vOtdel = '0' then vFilial_ID else vOtdel end
                    ,no_nns => TRUE);
                    
    EXCEPTION WHEN OTHERS THEN
    vRES:=SQLERRM;
    update GC.SDM$LOG_DEPOSIT_CC
        set text = vRES
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Открытие счета для выплаты процентов';    
    commit;          
END;  

    SELECT d.s, c.cur_a, c.name, ROWIDTOCHAR (d.ROWID) rowi, a.objid
      INTO vS_PRC, vCura_PRC, vCurname_PRC, vRowiD_PRC, vObjid_PRC
      FROM gc.dog d, gc.currency c, gc.acc a
     WHERE d.objid = DOG_ID_PRC AND c.cur_n(+) = d.cur and a.dog_id = d.objid; 
     
 DECLARE
        old_global_commit   BOOLEAN;
    BEGIN
        old_global_commit := gc.std_proc.global_commit;
        gc.std_proc.global_commit := FALSE;
        res := gc.std_proc.renew (DOG_ID_PRC
                                 ,next_name => vVNESH_PR_TYPE
                                 ,txt_ => 'Открытие договора через ДБО ЮЛ. Процедура GC.SDM$OPEN_DEPOSIT_CC');
            gc.std_proc.global_commit := old_global_commit;
    EXCEPTION
        WHEN OTHERS
        THEN
            gc.std_proc.global_commit := old_global_commit;
    vRES:=SQLERRM;
    update GC.SDM$LOG_DEPOSIT_CC
        set text = vRES
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Открытие счета для выплаты процентов';    
          commit;       
    END; 
    
IF vS_PRC is not null then
    t_tmp := gc.nns.new (vs_PRC
                        ,vCur_PRC
                        ,v_mask => RTRIM (gc.qual$p_main.get ('DEPTYP', vFinProd_PRC, 'NNS_SHORT_MASK'))
                        ,v_nns => vNns
                        ,v_text => 'Открытие договора через ДБО ЮЛ. Процедура GC.SDM$OPEN_DEPOSIT_CC'
                        ,v_userinputnns => 'N');                        
END IF;            

IF DOG_ID_PRC is not null THEN
    if not gc.radd_q(objtype_ =>'DOGBUY'
                      ,objid_ =>vDog_ID_New
                       ,name_ =>'VNESH_PR'
                        ,num_ =>'0'
                        ,txt_ =>'Добавлено автоматически при открытии вклада через ДБО ЮЛ'
                      ,value_ =>DOG_ID_PRC
                     ,date_b_ => sysdate
                     ,date_e_ => ''
                      ,filial =>null)
    then   gc.app_err.put ('BOOKKEEP', 292);
   
    end if;
    gc.Q_Refresh(vDog_ID_New, 'VNESH_PR', filial=>null);
COMMIT;    
END IF; 

IF DOG_ID_PRC is not null THEN
    if not gc.radd_q(objtype_ =>'DOGBUY'
                      ,objid_ =>DOG_ID_PRC
                       ,name_ =>'R_DROP_POST_KT'
                        ,num_ =>'0'
                        ,txt_ =>'Добавлено автоматически при открытии вклада через ДБО ЮЛ'
                      ,value_ =>'Y'
                     ,date_b_ => sysdate
                     ,date_e_ => ''
                      ,filial =>null)
    then   gc.app_err.put ('BOOKKEEP', 292);
   
    end if;
    gc.Q_Refresh(DOG_ID_PRC, 'R_DROP_POST_KT', filial=>null);
    if not gc.radd_q(objtype_ =>'ACC'
                    ,objid_ =>vOBJID_PRC
                    ,name_ =>'EXT_CONS_ACC'
                    ,num_ => 0
                    ,txt_ =>'Подвязан автоматически при открытии депозита через ДБО ЮЛ'
                    ,value_ =>vinterestAccountNumber
                    ,date_b_ => sysdate
                    ,date_e_ => null
                    ,filial =>null)
    then 
        gc.app_err.put ('BOOKKEEP', 292);
    end if;      
COMMIT;    
END IF; 


SELECT S.NAME
      ,O.IDN
      ,GC.REP_SUBJ.GET_BANK_BIK(D.FILIAL)
      ,(SELECT KS FROM GC.BANKI WHERE BANK_ID=DECODE(D.FILIAL,'M','382',D.FILIAL)) 
      ,GC.REPORT.GETBANKNAME(DECODE(D.FILIAL,'M','382',D.FILIAL))
      ,DECODE(D.FILIAL,'M','382',D.FILIAL) 
      ,(SELECT 'г.'||REPLACE(SP.NAME,' г','')   
        FROM GC.ADDRESS A,GC.SPRAV SP 
        WHERE SP.ID(+) = DECODE(A.CITY_ID,NULL,A.REGION_ID,A.CITY_ID)
        AND A.SUBJ_ID = DECODE(d.otdel,0,DECODE(D.FILIAL,'M','382',D.FILIAL),d.otdel) AND ROWNUM=1)  
   INTO 
     vNAME_ORG
    ,vINN_ORG
    ,vBIK_DOG 
    ,vKS_DOG
    ,vBANK_NAME
    ,vBANK_ID  
    ,vBank_CITY
FROM GC.DOG D
    ,GC.SUBJ S
    ,GC.ORG O
WHERE 1=1
  AND D.OBJID = vDog_ID_New
  AND D.SUBJ_ID = S.ID
  AND O.SUBJ_ID (+)= S.ID;    

IF DOG_ID_PRC is not null THEN
BEGIN
        SELECT -GC.SEQ_DOC.NEXTVAL 
             INTO vRekvId_PRC 
             FROM dual;
--Реквизиты для регулярного сброса в Диасофт             
      GC.SET_REKV2(V_S=>''
                  ,V_CUR=>''
                  ,V_MFO=>vBIK_DOG
                  ,V_KS=>vKS_DOG
                  ,V_RS=>vinterestAccountNumber
                  ,V_NAME=>vNAME_ORG
                  ,V_BANK=>vBANK_NAME
                  ,V_GOROD=>vBank_CITY
                  ,V_UNO=>vRekvId_PRC
                  ,V_BANK_ID=>vBANK_ID
                  ,V_UNB=>null
                  ,V_TEXT=>null
                  ,V_IDN=>vINN_ORG
                  ,V_IS_BS=>null
                  ,V_OCHEREDN=>null
                  ,V_PLATDAT=>null
                  ,V_COPYDIR=>'0'
                  ,V_ORG_ID=>''
                  ,P_ISRKC=>''                 
                  ,flVNBAL=>''
                  ,V_REZ=>vREZ_PRC              
                  ,V_DIR=>'0'
           
                  ); 
COMMIT;
  INSERT INTO GC.SDM$LOG_DEPOSIT_CC
  SELECT VREQUESTID,SYSDATE,VINSTITUTIONID,'Реквизиты для регулярки счета выплаты процентов','SUCCESS','Установлены (gc.rekv_doc). UNO:'||vRekvId_PRC FROM DUAL; 
  COMMIT;                                       
  EXCEPTION WHEN OTHERS THEN
  vRES:=SQLERRM;
  INSERT INTO GC.SDM$LOG_DEPOSIT_CC
  SELECT VREQUESTID,SYSDATE,VINSTITUTIONID,'Реквизиты для регулярки счета выплаты процентов','ERROR',vRES FROM DUAL;
  COMMIT;
  END;

  --Создадим новую регулярку на счете                
  vRegSbrosID:= gc.p$regtrans.CreateRegTrans(DOG_ID_PRC,'DOGCOR','R_DROP',pIsTemplate=>'');  
  COMMIT;  
  --Заполним данные регулярного сброса
  BEGIN
    gc.p$RegFillDrop.UpdateRegFillDrop(pObjId=>vRegSbrosID
                                      ,pDFirst=>TRUNC(SYSDATE)
                                      ,pDLast=>NULL
                                      ,pInt=>'00:01'
                                      ,pQnt=>1
                                      ,pOff=>0
                                      ,pMinSumm=>0
                                      ,pMaxSumm=>NULL
                                      ,pPayDebt=>'N'
                                      ,pRoute=>'2'
                                      ,pAcc=>NULL
                                      ,pRekv=>vRekvId_PRC
                                      ,pPurpose=>''
                                      ,pOst=>0
                                      ,pQue=>100
                                      ,pName=>'Сброс в Диасофт'
                                      ,pConvType=>0
                                      ,pTaxCalcMeth=>'0'
                                      ,pUseVnb=>'N'
                                      ,pIncomeTypeCode=>''
                                      ,pCodeNazPlat=>''
                                        );
  INSERT INTO GC.SDM$LOG_DEPOSIT_CC
  SELECT VREQUESTID,SYSDATE,VINSTITUTIONID,'Регулярный сброс на счет выплаты процентов','SUCCESS','ID регулярки - '||vRegSbrosID FROM DUAL; 
  COMMIT;                                       
  EXCEPTION WHEN OTHERS THEN
  vRES:=SQLERRM;
  INSERT INTO GC.SDM$LOG_DEPOSIT_CC
  SELECT VREQUESTID,SYSDATE,VINSTITUTIONID,'Регулярный сброс на счет выплаты процентов','ERROR',vRES FROM DUAL;
  COMMIT;
  END;
                                          
COMMIT;                 
                  
END IF;


IF DOG_ID_PRC is not null then
--Обновим статус
        UPDATE GC.SDM$LOG_DEPOSIT_CC
        SET TEXT = DOG_ID_PRC
           ,STATUS = 'SUCCESS'  
        WHERE REQUESTID = vRequestID
          AND INSTITUTIONID = vInstitutionID
          AND TYPE_OPER = 'Открытие счета для выплаты процентов';    
END IF;               
                    
END IF;--Счет не нашли, значит открываем новый договор и привязываем его






END IF;--Разбираемся со счетом выплаты процентов


--Разбираемся со счетом перевода средств при закрытии
IF vDog_ID_New is not null then

BEGIN
SELECT MAX(A.OBJID)
INTO vTRANS_COMPL_DEP_DOG
FROM GC.DOG D
    ,GC.DOG DD
    ,GC.ACC A
    ,GC.REGTRANS RT
    ,GC.REKV_DOC R
WHERE 1=1
  AND D.OBJID = vDog_ID_New
  AND D.SUBJ_ID = DD.SUBJ_ID
  AND DD.OBJID = RT.DOG_ID
  AND DD.OBJID = A.DOG_ID
  AND RT.OBJTYPE = 'R_DROP'
  AND RT.REKV = R.UNO
  AND R.ACC = vrefundAccountNumber;
 EXCEPTION WHEN NO_DATA_FOUND THEN
 vTRANS_COMPL_DEP_DOG := NULL;
END;    


--Если счет нашли, то на договор добавляем настройку TRANS_COMPL_DEP_DOG со значением найденного договора
IF vTRANS_COMPL_DEP_DOG is not null THEN
    if not gc.radd_q(objtype_ =>'DOGBUY'
                      ,objid_ =>vDog_ID_New
                       ,name_ =>'TRANS_COMPL_DEP_DOG'
                        ,num_ =>'0'
                        ,txt_ =>'Добавлено автоматически при открытии вклада через ДБО ЮЛ'
                      ,value_ =>vTRANS_COMPL_DEP_DOG
                     ,date_b_ => sysdate
                     ,date_e_ => ''
                      ,filial =>null)
    then   gc.app_err.put ('BOOKKEEP', 292);
   
    end if;
    gc.Q_Refresh(vDog_ID_New, 'TRANS_COMPL_DEP_DOG', filial=>null);
COMMIT;    
END IF;


--Если договор с выплатой процентов в конце срока, то нам неизвестно какой договор должен быть связанный
--Ищем финпродукт "Расчетный счет ЮЛ" по валюте и счету vrefundAccountNumber
IF vVNESH_PR_TYPE is null 
 and vTRANS_COMPL_DEP_DOG is null then
begin
       SELECT MAX(J.NAME) 
        INTO vVNESH_PR_TYPE
        FROM GC.J_QUAL J
            ,GC.L_QUAL L
            ,GC.BAL B
            ,GC.PLAN P
     WHERE 1=1
       AND J.OBJTYPE = 'DEPTYP'
       AND J.OBJID = 0
       AND J.NAME like '%Расчетный счет%'
       AND L.OBJID  = J.VALUE
       AND L.FILIAL = vFilial_ID
       AND B.OBJID  = L.VALUE
       AND B.BS = P.BS
       AND P.BBALN = SUBSTR(vrefundAccountNumber,1,5)
       AND B.CUR = vCUR_FinProd;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            NULL;              
END;
END IF;

--Счет для перевода средств не нашли, значит открываем новый договор и привязываем его
IF vVNESH_PR_TYPE is not null 
AND vTRANS_COMPL_DEP_DOG is null THEN

INSERT INTO GC.SDM$LOG_DEPOSIT_CC
SELECT VREQUESTID,SYSDATE,VINSTITUTIONID,'Открытие счета для перевода стредств при закрытии','WAIT','' FROM DUAL;
COMMIT;


    BEGIN
       SELECT B.BS,B.CUR,J.VALUE 
        INTO vBS_RFD,vCUR_RFD,vFinProd_RFD
        FROM GC.J_QUAL J
            ,GC.L_QUAL L
            ,GC.BAL B
     WHERE 1=1
       AND J.OBJTYPE = 'DEPTYP'
       AND J.OBJID = 0
       AND J.NAME = vVNESH_PR_TYPE
       AND L.OBJID  = J.VALUE
       AND L.FILIAL = vFilial_ID
       AND B.OBJID  = L.VALUE; 
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            NULL;
    END;    

begin
GC.INS_DOG_BUY_TUNE (DOG_ID_RFD
                    ,vCur_RFD
                    ,vSubj_ID
                    ,'Открытие счета через ДБО ЮЛ'
                    ,NVL ( ( '1' != '0'),FALSE)
                    ,v_bs => vBS_RFD
                    ,v_accmode => ''
                    ,v_otdel => case when vOtdel = '0' then vFilial_ID else vOtdel end                    
                    ,no_nns => TRUE);
                    
    EXCEPTION WHEN OTHERS THEN
    vRES:=SQLERRM;
    update GC.SDM$LOG_DEPOSIT_CC
        set text = vRES
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Открытие счета для перевода стредств при закрытии';    
    commit;          
END;  

    SELECT d.s, c.cur_a, c.name, ROWIDTOCHAR (d.ROWID) rowi, a.objid
      INTO vS_RFD, vCura_RFD, vCurname_RFD, vRowiD_RFD,vOBJID_RFD
      FROM gc.dog d, gc.currency c, gc.acc a
     WHERE d.objid = DOG_ID_RFD AND c.cur_n(+) = d.cur and a.dog_id = d.objid; 
     
 DECLARE
        old_global_commit   BOOLEAN;
    BEGIN
        old_global_commit := gc.std_proc.global_commit;
        gc.std_proc.global_commit := FALSE;
        res := gc.std_proc.renew (DOG_ID_RFD
                                 ,next_name => vVNESH_PR_TYPE
                                 ,txt_ => 'Открытие договора через ДБО ЮЛ. Процедура GC.SDM$OPEN_DEPOSIT_CC');
            gc.std_proc.global_commit := old_global_commit;
    EXCEPTION
        WHEN OTHERS
        THEN
            gc.std_proc.global_commit := old_global_commit;
    vRES:=SQLERRM;
    update GC.SDM$LOG_DEPOSIT_CC
        set text = vRES
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Открытие счета для перевода стредств при закрытии';    
          commit;       
    END; 
    
IF vS_RFD is not null then
    t_tmp := gc.nns.new (vs_RFD
                        ,vCur_RFD
                        ,v_mask => RTRIM (gc.qual$p_main.get ('DEPTYP', vFinProd_RFD, 'NNS_SHORT_MASK'))
                        ,v_nns => vNns
                        ,v_text => 'Открытие договора через ДБО ЮЛ. Процедура GC.SDM$OPEN_DEPOSIT_CC'
                        ,v_userinputnns => 'N');                        
END IF;            

IF DOG_ID_RFD is not null THEN
    if not gc.radd_q(objtype_ =>'DOGBUY'
                      ,objid_ =>vDog_ID_New
                       ,name_ =>'TRANS_COMPL_DEP_DOG'
                        ,num_ =>'0'
                        ,txt_ =>'Добавлено автоматически при открытии вклада через ДБО ЮЛ'
                      ,value_ =>vOBJID_RFD
                     ,date_b_ => sysdate
                     ,date_e_ => ''
                      ,filial =>null)
    then   gc.app_err.put ('BOOKKEEP', 292);
   
    end if;
    gc.Q_Refresh(vDog_ID_New, 'TRANS_COMPL_DEP_DOG', filial=>null);
COMMIT;    
END IF; 

IF DOG_ID_RFD is not null THEN
    if not gc.radd_q(objtype_ =>'DOGBUY'
                      ,objid_ =>DOG_ID_RFD
                       ,name_ =>'R_DROP_POST_KT'
                        ,num_ =>'0'
                        ,txt_ =>'Добавлено автоматически при открытии вклада через ДБО ЮЛ'
                      ,value_ =>'Y'
                     ,date_b_ => sysdate
                     ,date_e_ => ''
                      ,filial =>null)
    then   gc.app_err.put ('BOOKKEEP', 292);
   
    end if;
    gc.Q_Refresh(DOG_ID_RFD, 'R_DROP_POST_KT', filial=>null);    
    if not gc.radd_q(objtype_ =>'ACC'
                    ,objid_ =>vOBJID_RFD
                    ,name_ =>'EXT_CONS_ACC'
                    ,num_ => 0
                    ,txt_ =>'Подвязан автоматически при открытии депозита через ДБО ЮЛ'
                    ,value_ =>vrefundAccountNumber
                    ,date_b_ => sysdate
                    ,date_e_ => null
                    ,filial =>null)
    then 
        gc.app_err.put ('BOOKKEEP', 292);
    end if;   
COMMIT;
END IF; 


SELECT S.NAME
      ,O.IDN
      ,GC.REP_SUBJ.GET_BANK_BIK(D.FILIAL)
      ,(SELECT KS FROM GC.BANKI WHERE BANK_ID=DECODE(D.FILIAL,'M','382',D.FILIAL)) 
      ,GC.REPORT.GETBANKNAME(DECODE(D.FILIAL,'M','382',D.FILIAL))
      ,DECODE(D.FILIAL,'M','382',D.FILIAL) 
      ,(SELECT 'г.'||REPLACE(SP.NAME,' г','')   
        FROM GC.ADDRESS A,GC.SPRAV SP 
        WHERE SP.ID(+) = DECODE(A.CITY_ID,NULL,A.REGION_ID,A.CITY_ID)
        AND A.SUBJ_ID = DECODE(d.otdel,0,DECODE(D.FILIAL,'M','382',D.FILIAL),d.otdel) AND ROWNUM=1)  
   INTO 
     vNAME_ORG
    ,vINN_ORG
    ,vBIK_DOG 
    ,vKS_DOG
    ,vBANK_NAME
    ,vBANK_ID  
    ,vBank_CITY
FROM GC.DOG D
    ,GC.SUBJ S
    ,GC.ORG O
WHERE 1=1
  AND D.OBJID = vDog_ID_New
  AND D.SUBJ_ID = S.ID
  AND O.SUBJ_ID (+)= S.ID;    

IF DOG_ID_RFD is not null THEN
BEGIN
        SELECT -GC.SEQ_DOC.NEXTVAL 
             INTO vRekvId_RFD 
             FROM dual;
--Реквизиты для регулярного сброса в Диасофт             
      GC.SET_REKV2(V_S=>''
                  ,V_CUR=>''
                  ,V_MFO=>vBIK_DOG
                  ,V_KS=>vKS_DOG
                  ,V_RS=>vrefundAccountNumber
                  ,V_NAME=>vNAME_ORG
                  ,V_BANK=>vBANK_NAME
                  ,V_GOROD=>vBank_CITY
                  ,V_UNO=>vRekvId_RFD
                  ,V_BANK_ID=>vBANK_ID
                  ,V_UNB=>null
                  ,V_TEXT=>null
                  ,V_IDN=>vINN_ORG
                  ,V_IS_BS=>null
                  ,V_OCHEREDN=>null
                  ,V_PLATDAT=>null
                  ,V_COPYDIR=>'0'
                  ,V_ORG_ID=>''
                  ,P_ISRKC=>''                 
                  ,flVNBAL=>''
                  ,V_REZ=>vREZ_RFD              
                  ,V_DIR=>'0'
           
                  ); 
COMMIT;
  INSERT INTO GC.SDM$LOG_DEPOSIT_CC
  SELECT VREQUESTID,SYSDATE,VINSTITUTIONID,'Реквизиты для регулярки счета перевода средств при закрытии','SUCCESS','Установлены (gc.rekv_doc). UNO:'||vRekvId_RFD FROM DUAL; 
  COMMIT;                                       
  EXCEPTION WHEN OTHERS THEN
  vRES:=SQLERRM;
  INSERT INTO GC.SDM$LOG_DEPOSIT_CC
  SELECT VREQUESTID,SYSDATE,VINSTITUTIONID,'Реквизиты для регулярки счета перевода средств при закрытии','ERROR',vRES FROM DUAL;
  COMMIT;
  END;

  --Создадим новую регулярку на счете                
  vRegSbrosID:= gc.p$regtrans.CreateRegTrans(DOG_ID_RFD,'DOGCOR','R_DROP',pIsTemplate=>'');  
  COMMIT;  
  --Заполним данные регулярного сброса
  BEGIN
    gc.p$RegFillDrop.UpdateRegFillDrop(pObjId=>vRegSbrosID
                                      ,pDFirst=>TRUNC(SYSDATE)
                                      ,pDLast=>NULL
                                      ,pInt=>'00:01'
                                      ,pQnt=>1
                                      ,pOff=>0
                                      ,pMinSumm=>0
                                      ,pMaxSumm=>NULL
                                      ,pPayDebt=>'N'
                                      ,pRoute=>'2'
                                      ,pAcc=>NULL
                                      ,pRekv=>vRekvId_RFD
                                      ,pPurpose=>''
                                      ,pOst=>0
                                      ,pQue=>100
                                      ,pName=>'Сброс в Диасофт'
                                      ,pConvType=>0
                                      ,pTaxCalcMeth=>'0'
                                      ,pUseVnb=>'N'
                                      ,pIncomeTypeCode=>''
                                      ,pCodeNazPlat=>''
                                        );
  INSERT INTO GC.SDM$LOG_DEPOSIT_CC
  SELECT VREQUESTID,SYSDATE,VINSTITUTIONID,'Регулярный сброс на счет перевода средств при закрытии','SUCCESS','ID регулярки - '||vRegSbrosID FROM DUAL; 
  COMMIT;                                       
  EXCEPTION WHEN OTHERS THEN
  vRES:=SQLERRM;
  INSERT INTO GC.SDM$LOG_DEPOSIT_CC
  SELECT VREQUESTID,SYSDATE,VINSTITUTIONID,'Регулярный сброс на счет перевода средств при закрытии','ERROR',vRES FROM DUAL;
  COMMIT;
  END;
                                          
COMMIT;                 
                  
END IF;


IF DOG_ID_RFD is not null then
--Обновим статус
        UPDATE GC.SDM$LOG_DEPOSIT_CC
        SET TEXT = DOG_ID_RFD
           ,STATUS = 'SUCCESS'  
        WHERE REQUESTID = vRequestID
          AND INSTITUTIONID = vInstitutionID
          AND TYPE_OPER = 'Открытие счета для перевода стредств при закрытии';    
END IF;               

END IF;--Счет для перевода средств не нашли, значит открываем новый договор и привязываем его

END IF;--Разбираемся со счетом перевода средств при закрытии



           
COMMIT;

END IF;

gc.user_login.arm_end;
END;
/



-- End of DDL Script for Procedure GC.SDM$OPEN_DEPOSIT_CC

