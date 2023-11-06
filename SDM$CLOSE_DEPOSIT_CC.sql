-- Start of DDL Script for Procedure GC.SDM$CLOSE_DEPOSIT_CC
-- Generated 06-ноя-2023 18:11:03 from GC@BANK

CREATE OR REPLACE 
PROCEDURE sdm$close_deposit_cc
   ( vDog_ID in varchar2
     ,vNNS_RFD in varchar2
     ,vRequestID in varchar2
     ,vInstitutionID in varchar2
   )
   as
  
    vFilial_ID       GC.DOG.FILIAL%TYPE;
    vTEX             GC.DOG.TEX%TYPE; 
    vS               GC.DOG.S%TYPE; 
    vCUR             GC.DOG.CUR%TYPE;
    vS_RFD           GC.ACC.S%TYPE;
    vS_CONS          GC.BAL.ACC1%TYPE;  
    vEXT_CONS_RFD    VARCHAR2(20);  
    vRES             VARCHAR2(2000);
    vCOUNT           INT;
    vbTmp            boolean;
    vRowID           ROWID;  
    RES              boolean := null;
    T_UNO            GC.MAIN.UNO%type := null;
    T_UNP            GC.MAINA.UNP%TYPE := null;
    T_UNO_KT         GC.MAINA.UNO%TYPE := null;    
    vSUMM            number;
    vPlatBik         VARCHAR2(9);
    vKS              VARCHAR2(20); 
    vPlatPlat        VARCHAR2(200);
    vPlatBank        VARCHAR2(200);
    vFilID           VARCHAR2(15);
    vPlatINN         GC.ORG.IDN%TYPE;
    vRez             number;
    vCITY            VARCHAR2(100);
    vNameOrg         VARCHAR2(200);
    vDateDog         VARCHAR2(15);

    t_sum            NUMBER := NULL;
    tmp              BOOLEAN;
    docs             VARCHAR2(100);  
    t_sum1           NUMBER := NULL;       
    t_doc            VARCHAR2(2000) := NULL;
    summ             NUMBER;
    redem            VARCHAR2(1);
    unp              VARCHAR2(12);
    vVnesh_Pr        VARCHAR2(20);

  
BEGIN
GC.P_SUPPORT.ARM_START();

INSERT INTO GC.SDM$LOG_DEPOSIT_CC
SELECT VREQUESTID,SYSDATE,VINSTITUTIONID,'Закрытие депозита','WAIT','' FROM DUAL;
COMMIT;


BEGIN
SELECT D.FILIAL
      ,D.S
      ,D.CUR
      ,ROWIDTOCHAR (d.ROWID) rowi
      ,D.TEX
      ,A.S
      ,GC.QUAL$P_MAIN.GET('ACC',A.OBJID,'EXT_CONS_ACC',d.filial)
      ,GC.SALDO.SIGNED(D.S,D.CUR)
      ,S.NAME
      ,TO_CHAR(TRUNC(D.DOPEN),'DD.MM.YYYY')
      ,GC.QUAL$P_MAIN.GET('DOGBUY',vDog_ID,'VNESH_PR')
      
 INTO vFilial_ID,vS,vCUR,vRowID,vTex,vS_RFD,vEXT_CONS_RFD,vSUMM,vNameOrg,vDateDog,vVnesh_Pr
 FROM GC.DOG D
     ,GC.ACC A
     ,GC.SUBJ S
WHERE 1=1
  AND D.OBJID = vDog_ID
  AND D.STATUS <> '999'
  AND GC.SDM$GET_DEPOSITPRODUCTCODE(D.OBJID) IN (SELECT DISTINCT C.DEPOSIT_NAME FROM GC.SDM$LIST_DEPOSIT_CC C)
  AND A.OBJID(+)=GC.QUAL$P_MAIN.GET('DOGBUY',D.OBJID,'TRANS_COMPL_DEP_DOG',d.filial)
  AND D.SUBJ_ID = S.ID;
EXCEPTION WHEN NO_DATA_FOUND THEN
vRES := 'Договор не найден или помечен на закрытие';
UPDATE GC.SDM$LOG_DEPOSIT_CC
        set text = vRES
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Закрытие депозита';
COMMIT;          
END;  
   
IF vRES is NULL THEN
gc.set_filial(vFilial_ID);
END IF;





SELECT count(1)
  INTO vCOUNT
  FROM GC.DOG D
     ,GC.L_QUAL Q 
 WHERE D.OBJID=vDog_ID
   AND Q.objid=d.OBJID
   AND Q.NAME IN ('MIN_FREE_CRD','MIN_FREE','K_MIN_SALDO_SUM');

IF vCOUNT <> 0 THEN
vRES:='На договоре '||vDog_ID||' настроен арест';
UPDATE GC.SDM$LOG_DEPOSIT_CC
        set text = vRES
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Закрытие депозита';
COMMIT;
vCount:=0;
END IF;

SELECT Count(1)
 INTO vCOUNT 
  FROM  GC.DOG D
       ,GC.ACC A
       ,GC.L_QUAL Q 
 WHERE D.OBJID=vDog_ID
   AND A.S=D.S
   AND A.CUR=D.CUR
   AND Q.NAME IN ('FROZEN')
   AND LENGTH(Q.VALUE) > 1 --Не удалена
   AND Q.OBJID=A.OBJID;


IF vCOUNT <>0 THEN
vRES:=vRES||'. Счет блокирован!';
UPDATE GC.SDM$LOG_DEPOSIT_CC
        set text = vRes
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Закрытие депозита';
COMMIT;
vCount:=0;
END IF;



IF vRES is NULL then
begin
gc.p_dog.set_otdelconf(vDog_ID,null);
gc.p_dog.setWhyCloseUseArmComment(true);
GC.UPD_DOG(vRowID,vTEX,'','999',V_STATE=>1, V_REASON_CLOSE_NULL => null );
gc.p_dog.setWhyCloseUseArmComment(false); 
GC.p_facom.set_psumcom(vDog_ID,'.00');
GC.p_facom.set_psumla(vDog_ID,'.00'); 
gc.c_d_p.gsLastObjid:=NULL; 
gc.std_proc.global_commit:=false; 
gc.c_d_p.init;
RES:=GC.STD_PROC.renew(vDog_ID,NEXT_NAME=>'+',TXT_=>'Вклад закрыт клиентом через ДБО ЮЛ',d_renew=>sysdate); 
EXCEPTION WHEN OTHERS THEN
vRES:=SQLERRM;
UPDATE GC.SDM$LOG_DEPOSIT_CC
        set text = vRes
           ,status = 'ERROR' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Закрытие депозита';
COMMIT;
END;
END IF;



IF vRES is NULL then
GC.JOUR_PACK.ADD_JOUR_TXT('Вклад закрыт клиентом через ДБО ЮЛ');
GC.JOUR_PACK.ADD_TO_JOURNAL('C',vDog_ID,'JDG00004','U','0',GC.GENMESSAGE('JOUR',7,'999'));
COMMIT;
END IF;


IF vRES is null THEN
--Сброс рассчитанных процентов
 GC.INF_F_P(t_sum,vDog_ID,tmp,t_unp,num_otd=>vFilial_ID);
 --if nvl(t_sum,0) <> 0 then

  begin
   GC.DOC_F_P(t_sum1,
             t_doc,
             unp,
             vDog_ID,
             f_sbros=>gc.iif.iif(1=1,true,null),
             num_otd=>vFilial_ID,
             f_move=>gc.iif.iif(0=1,true,null),
             text_=>'Расчет процентов при закрытии через ДБО ЮЛ',
             vltr_dt_=>sysdate,
             IsDoc=>false,
             f_list=>gc.iif.iif(0=1,true,null));
   redem := '1';
   docs := t_doc;
  end;
 --end if;
 summ := to_char(t_sum);
 commit;
END IF;



--Если счет для перевода средств найден в РБС и остаток на депозите не 0, то формируем документ
IF vS_RFD is not null
    and vRES is NULL 
       and vEXT_CONS_RFD = vNNS_RFD 
          and vSUMM > 0 
          THEN
BEGIN
--К основной сумме прибавим рассчитанные проценты, если сброс процентов произошел на счет депозита
IF vVnesh_Pr is null then
vSumm:=vSumm+nvl(t_sum,0);
END IF;

SELECT gc.SEQ_DOC.NEXTVAL
INTO T_UNO 
FROM DUAL;
 gc.INS_DOC(T_UNO,
                      vCUR,
                      vS,
                      vS_RFD,
                      vSumm,
                      V_KO => '0040',
                      V_UNO=>T_UNO, 
                      V_NO=>T_UNO,
                      V_STATUS=>'15',
                      V_ENTRIED=>sysdate+60/86400,
                      V_VLTR_DT=>sysdate+60/86400,
                      V_DOC_GROUP=>'',
                      V_TEX_ADVANCED=> 'Возврат депозита по дог.№ '||vDog_ID||' от '||vDateDog||' '||vNameOrg
                      
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
          and Type_Oper = 'Закрытие депозита';    
          commit;       
END; 

end if;


IF vRES is NULL
   and vEXT_CONS_RFD <> vNNS_RFD 
      and vSUMM > 0  THEN
BEGIN 
--К основной сумме прибавим рассчитанные проценты, если сброс процентов произошел на счет депозита
IF vVnesh_Pr is null then
vSumm:=vSumm+nvl(t_sum,0);
END IF;
    
SELECT gc.SEQ_DOC.NEXTVAL
INTO T_UNO 
FROM DUAL;

--Консолидированный счет
SELECT B.ACC1
INTO vS_CONS
         FROM GC.ACC A
             ,GC.BAL B
WHERE 1=1
  AND A.S = vS
  AND A.BS = B.BS
  AND A.FILIAL = B.FILIAL
  AND A.CUR = B.CUR;
  
--Добавим документ  
Begin
           gc.INS_DOC_ADVANCED(T_UNO
                              ,T_UNO_KT
                              ,T_UNP
                              ,v_NO=>Null
                              ,v_s_dt=>vS
                              ,v_s_kt=>vS_CONS
                              ,v_Cur=>vCUR
                              ,v_Cur_KT=>vCUR
                              ,v_ko=>'0024'
                              ,v_SUMM=>vSumm
                              ,v_CROSS=>True
                              ,v_STATUS=>'15'
                              ,v_entried=>sysdate+60/86400
                              ,v_vltr_dt=>sysdate+60/86400
                              ,v_ROUND=>False
                              ,v_TEX_ADVANCED=>'Возврат депозита по дог.№ '||vDog_ID||' от '||vDateDog||' '||vNameOrg
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
          and Type_Oper = 'Закрытие депозита';    
          commit;       
END;


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
  and a.s = vS 
  and a.subj_id = s.id
  and o.subj_id = s.id;
  
  
  gc.set_rekv2 (v_s             => vS,
                 v_cur           => vCUR,
                 v_mfo           => vPlatBik,
                 v_ks            => vKS,
                 v_rs            => vNNS_RFD,
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
          and Type_Oper = 'Закрытие депозита';    
          commit;       
END;

END;
      --ФОРМИРУЕМ ДОКУМЕНТ 0024 Списание через реквизиты!!!
      --!!!!ДОДЕЛАТЬ
      END IF;
      
      
IF vRES is null THEN  
update GC.SDM$LOG_DEPOSIT_CC
        set text = 'Номер документа '||T_UNO
           ,status = 'SUCCESS' 
        where RequestID = vRequestID
          and InstitutionID = vInstitutionID
          and Type_Oper = 'Закрытие депозита';    
          commit;  
END IF;               
   
gc.user_login.arm_end;
END;
/



-- End of DDL Script for Procedure GC.SDM$CLOSE_DEPOSIT_CC

