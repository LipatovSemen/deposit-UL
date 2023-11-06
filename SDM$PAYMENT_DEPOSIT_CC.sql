-- Start of DDL Script for Procedure GC.SDM$PAYMENT_DEPOSIT_CC
-- Generated 06-ноя-2023 18:11:27 from GC@BANK

CREATE OR REPLACE 
PROCEDURE sdm$payment_deposit_cc
   ( vDepositAccount in varchar2
     ,vSumm in number 
     ,vRequestID in varchar2
     ,vInstitutionID in varchar2
     ,vRS in varchar2
   )
   as

  T_UNP         GC.MAIN.UNP%type := null;
  T_UNO         GC.MAIN.UNO%type := null;
  T_UNO_KT      GC.MAIN.UNO%type := null;
  vS_KT         GC.ACC.S%type;
  vCUR_KT       GC.ACC.CUR%type;
  vS_DT         GC.BAL.ACC1%type;
  vRES          VARCHAR2(2000);
  vK_FEE_SUMM   number;
  vDOG_ID       GC.ACC.DOG_ID%type;
  vNameOrg      GC.SUBJ.NAME%Type;
  vDate         varchar2(10);
  vPlatBik      VARCHAR2(9);
  vKS           VARCHAR2(20); 
  vPlatPlat     VARCHAR2(200);
  vPlatBank     VARCHAR2(200);
  vFilID        VARCHAR2(15);
  vPlatINN      GC.ORG.IDN%TYPE;
  vRez          NUMBER;
  vCITY         VARCHAR2(100);
  vNO_CRE_DT    VARCHAR2(1);
  vObj_sDT      GC.ACC.OBJID%TYPE;
  
        
    
BEGIN
gc.p_support.arm_start();


INSERT INTO GC.SDM$LOG_DEPOSIT_CC
SELECT VREQUESTID,SYSDATE,VINSTITUTIONID,'Пополнение депозита','WAIT','' FROM DUAL;
COMMIT;


SELECT gc.SEQ_DOC.NEXTVAL
INTO T_UNO 
FROM DUAL;

BEGIN
SELECT A.S , A.CUR, A.DOG_ID, S.NAME,TO_CHAR(SYSDATE,'dd.mm.yyyy')
INTO vS_KT,vCUR_KT,vDOG_ID, vNameOrg,vDate
FROM GC.NNS_LIST N
    ,GC.ACC A
    ,GC.SUBJ S
WHERE N.NNS = vDepositAccount
  AND N.ENDDAT > SYSDATE
  AND A.S = N.S
  AND A.CUR = N.CUR
  AND A.SUBJ_ID = S.ID;
 EXCEPTION WHEN NO_DATA_FOUND THEN
     vRES:='Ошибка пополнения. Счет депозита в РБС не найден'; 
update GC.SDM$LOG_DEPOSIT_CC
        set text = vRES
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Пополнение депозита';    
          commit;     
END;




--Найдем консолидированный счет депозита
IF vRES IS NULL THEN
SELECT B.ACC1,AA.OBJID
INTO vS_DT,vObj_sDT 
FROM GC.ACC A 
    ,GC.BAL B
    ,GC.ACC AA
WHERE 1=1
  AND A.S = vS_KT
  AND B.BS = A.BS
  AND A.FILIAL = B.FILIAL
  AND B.CUR = A.CUR
  AND AA.S = B.ACC1;
END IF;

--Проверим настройку NOCRE_OUT_DT. Иначе ошибка "Нет внешних реквизитов"
IF vRES is NULL THEN
SELECT NVL(GC.QUAL$P_MAIN.GET('ACC',A.OBJID,'NOCRE_OUT_DT'),'N') 
    INTO vNO_CRE_DT 
FROM GC.ACC A 
WHERE A.S = VS_DT;
END IF;

--Если настройка на конс счете не стоит, то поставим ее
IF vRES is null and vNO_CRE_DT = 'N' then
begin
if not gc.radd_q(objtype_ =>'ACC'
                      ,objid_ =>vObj_sDT
                       ,name_ =>'NOCRE_OUT_DT'
                        ,num_ =>'0'
                        ,txt_ =>'Добавлена процедурой sdm$payment_deposit_cc'
                      ,value_ =>'Y'
                     ,date_b_ => sysdate
                     ,date_e_ => TO_DATE('','dd/mm/yyyy hh24:mi:ss')
                      ,filial =>null)
    then   gc.app_err.put ('BOOKKEEP', 292);
    end if;
    commit;
    gc.Q_Refresh(vObj_sDT, 'NOCRE_OUT_DT', filial=>null);
end;
END IF;


--Найдем настройку "Минимальная сумма первоначального взноса"
IF vRes IS NULL THEN
SELECT GC.QUAL$P_MAIN.GET('DOGBUY', vDOG_ID, 'K_FEE_SUM')
INTO vK_FEE_SUMM
FROM DUAL;
END IF;

IF vK_FEE_SUMM is not null and vRes is null then
  IF vK_FEE_SUMM > vSUMM then
  vRES:='Минимальная сумма первоначального взноса ('||vK_FEE_SUMM||') больше суммы пополнения ('||vSUMM||')';
  UPDATE GC.SDM$LOG_DEPOSIT_CC
        set text = vRES
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Пополнение депозита';    
          commit; 
  END IF;
end if;


IF vRes is null then
BEGIN
 gc.INS_DOC(T_UNO,
                      vCUR_KT,
                      vS_DT,
                      vS_KT,
                      vSumm,
                      V_KO => '0023',
                      V_NO=>T_UNO,
                      V_STATUS=>'15',
                      V_ENTRIED=>NULL,
                      V_VLTR_DT=>NULL,
                      V_DOC_GROUP=>'',
                      V_TEX_ADVANCED=> 'Перевод в пользу '||vNameOrg||' для зачисления на л/с депозита '||vDepositAccount||' по договору '||vDOG_ID||' от '||vDate||' НДС не облагается'
                      
                    ); 
COMMIT;                    
EXCEPTION
        WHEN OTHERS
        THEN
    vRES:=SQLERRM;
    update GC.SDM$LOG_DEPOSIT_CC
        set text = vRES
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Пополнение депозита';    
          commit;       
END; 
    
END IF;



IF vRes is null then
--Вешаем реквизиты
begin

--Данные по счету и плательщику
select  gc.rep_subj.get_bank_bik(decode(a.filial,'M','382',a.filial))
       ,(select KS from gc.banki where bank_id=decode(a.filial,'M','382',a.filial))
       ,s.name 
       ,gc.report.getbankname(decode(a.filial,'M','382',a.filial))
       ,(select 'г.'||replace(sp.name,' Г','')   
            from gc.ADDRESS a,gc.sprav sp 
           where sp.id(+) = decode(a.city_id,null,a.region_id,a.city_id)
             and a.subj_id = decode(a.filial,'M','382',a.filial) and rownum=1) CITY
       ,decode(a.filial,'M','382',a.filial)
       ,o.idn      
 into vPlatBik,vKS, vPlatPlat,vPlatBank,vCity,vFilID,vPlatINN
     from gc.acc a
         ,gc.subj s
         ,gc.org o
where 1=1 
  and a.s = vS_KT 
  and a.subj_id = s.id
  and o.subj_id = s.id;
  
  
  gc.set_rekv2 (v_s             => vS_KT,
                 v_cur           => vCUR_KT,
                 v_mfo           => vPlatBik,
                 v_ks            => vKS,
                 v_rs            => vRS,
                 v_name          => upper(vPlatPlat),
                 v_bank          => upper(vPlatBank),
                 v_gorod         => vCity,
                 v_uno           => T_UNO,
                 v_bank_id       => vFilID,
                 v_unb           => NULL,
                 v_text          => NULL,
                 v_idn           => vPlatINN,
                 v_is_bs         => NULL,
                 v_ocheredn      => NULL,
                 v_platdat       => NULL,
                 v_copydir       => '0',
                 v_org_id        => vFilID,
                 flvnbal         => NULL,
                 v_rez           => vRez,
                 v_dir           => '1'
                );
COMMIT;                    
EXCEPTION
        WHEN OTHERS
        THEN
    vRES:=SQLERRM;
    update GC.SDM$LOG_DEPOSIT_CC
        set text = vRES
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Пополнение депозита';    
          commit;      
END;
END IF;




IF vRES is NULL THEN
update GC.SDM$LOG_DEPOSIT_CC
        set text = 'Документ отправлен в очередь: '||T_UNO
           ,status = 'SUCCESS' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Пополнение депозита';    
          commit; 
END IF;          


                   
END;
/



-- End of DDL Script for Procedure GC.SDM$PAYMENT_DEPOSIT_CC

