ALTER SESSION SET NLS_NUMERIC_CHARACTERS='.,';
SELECT GC.REP_SUBJ.GET_BANK_BIK(A.FILIAL) branchExtId
      ,GC.NNS.GET(A.S,A.CUR) depositAccount
/*      ,NVL((SELECT SUM(M.SUMM) 
             FROM GC.MAINA M 
         WHERE 1=1
           AND M.S_KT = A.S
           AND M.K_O = '0023'
           AND M.STORNO IS NULL
           AND TRUNC(M.CREATED) = TRUNC(NVL(D.DOPEN,A.DOPEN))),0) depositAmount*/
      , NVL (
           (SELECT SUM (m.summ)
              FROM gc.maina m
             WHERE     1 = 1
                   AND m.s_kt = a.s
                   AND m.k_o IN ('0023', '0419')
                   AND m.storno IS NULL
                   AND TRUNC (m.created) BETWEEN TRUNC (
                                                     NVL (d.dopen, a.dopen))
                                             AND   TRUNC (
                                                       NVL (d.dopen, a.dopen))
                                                 + 7),
           0)
           depositamount

      ,CASE WHEN NVL(GC.QUAL$P_MAIN.GET('DOGBUY',A.DOG_ID,'TRANS_COMPL_DEP_CNT'), 
                      GC.QUAL$P_MAIN.GETa('DOGBUY',A.DOG_ID,'TRANS_COMPL_DEP_CNT')) is null then 0
            ELSE 1 
            END autoprolongation
      ,CASE WHEN NVL(GC.QUAL$P_MAIN.GET('DOGBUY',A.DOG_ID,'VNESH_PR'), 
                      GC.QUAL$P_MAIN.GETa('DOGBUY',A.DOG_ID,'VNESH_PR')) is null then 0
            ELSE 1 
            END capitalization            
      ,A.CUR currCode
      ,decode(C.CUR_A,'RUB','RUR',C.CUR_A) currIsoCode  
      ,A.DOG_ID docNumber
      ,TRUNC(NVL(D.D_VKL,A.DOPEN)) docDate
      ,CASE WHEN D.STATUS = '999' THEN GC.REPORT.GET_PERC_ST(A.DOG_ID,D.DOPEN,D.DOPEN,D.DOPEN,1)
            WHEN DD.OBJID IS NULL THEN GC.REPORT.GET_PERC_ST(A.DOG_ID,sysdate,sysdate,sysdate,1)
                                  ELSE GC.REPORT.GET_PERC_STa(A.DOG_ID,DD.DOPEN+30/86400,DD.DOPEN+30/86400,DD.DOPEN+30/86400,1)
                                  END depositRate
      ,TRUNC(NVL(D.D_VKL,A.DOPEN)) placementDate
      ,NVL(GC.QUAL$P_MAIN.GET('DOGBUY',A.DOG_ID,'DEP_PERIOD',PTIME => A.DOPEN+1),
            GC.QUAL$P_MAIN.GETa('DOGBUY',A.DOG_ID,'DEP_PERIOD',PTIME => A.DOPEN+1)) depositTerm
      ,NVL(D.D_FINAL,TRUNC(NVL(D.D_VKL,A.DOPEN))+GC.QUAL$P_MAIN.GETa('DOGBUY',A.DOG_ID,'DEP_PERIOD',PTIME => A.DOPEN+1)) refundDate
      ,case when d.status = '999' then trunc(d.d_vkl) else TRUNC(A.DCLOSE) end closeDate
      --,case when TRUNC(A.DCLOSE) < TRUNC(NVL(D.D_VKL,A.DOPEN))+GC.QUAL$P_MAIN.GETa('DOGBUY',A.DOG_ID,'DEP_PERIOD',PTIME => A.DOPEN+1) then 1 else 0 end pretermTerminate
      ,case when SDM$GET_DEPOSITPRODUCTCODE(a.dog_id) = 'SHORT-RUB' then 1 else 0 end pretermTerminate
      ,decode(d.status,'999','2',decode(a.dclose,null,1,2)) status
      ,(select max(oa.value) from gc.sprav$values sv
                    ,gc.obj_attr oa
        WHERE 1=1
          AND SV.ID_TYPE = '5484' --Справочник атрибутов договора
          AND SV.VALUE1 = 'CORREQTS_REQUEST_ID'
          and oa.attr_id = sv.id
          and oa.obj_id = a.dog_id) DocRef
      ,(select max(oa.value) from gc.sprav$values sv
                    ,gc.obj_attr oa
        WHERE 1=1
          AND SV.ID_TYPE = '5484' --Справочник атрибутов договора
          AND SV.VALUE1 = 'CORREQTS_APPLICATION_DATE'
          and oa.attr_id = sv.id
          and oa.obj_id = a.dog_id) depAppDate     
      ,(select max(oa.value) from gc.sprav$values sv
                    ,gc.obj_attr oa
        WHERE 1=1
          AND SV.ID_TYPE = '5484' --Справочник атрибутов договора
          AND SV.VALUE1 = 'CORREQTS_APPLICATION_NUMBER'
          and oa.attr_id = sv.id
          and oa.obj_id = a.dog_id) depAppNumber    
      ,CASE WHEN NVL(GC.QUAL$P_MAIN.GET('DOGBUY',A.DOG_ID,'P_FEE_Y',PTIME => A.DOPEN+1),
                      GC.QUAL$P_MAIN.GETa('DOGBUY',A.DOG_ID,'P_FEE_Y',PTIME => A.DOPEN+1)) = '-1' then 1 
                       else 0 end paymentPeriodicity                        --Ежемесячная или в конце срока?
      
      ,gc.sdm$get_depositproductcode (nvl(d.objid,dd.objid)) depositproductcode

            
         FROM GC.VW$ACC_ACCA A
             ,GC.PLAN P
             ,GC.CURRENCY C
             ,GC.DOG D
             ,GC.DOGA DD
WHERE 1=1
  AND A.SUBJ_ID = '1138448287' --ID-Клиента
  AND P.BS = A.BS
  AND P.PERIOD > 0
  AND P.PS = '005'
  AND A.CUR = C.CUR_N
  AND D.OBJID (+)= A.DOG_ID
  AND DD.OBJID (+)= A.DOG_ID
