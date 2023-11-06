SELECT '40807','-------' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL
UNION ALL  
SELECT 'ПРОЦЕНТЫ','47426810400003000002' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL
UNION ALL
SELECT 'ДОХОДЫ','70601810100352421411' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL
UNION ALL
SELECT 'РАСХОДЫ','70606810800353131461' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL    
UNION ALL  
SELECT DISTINCT
       P.BBALN
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = 'M'),'EXT_CONS_ACC','M') ГО
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1788509'),'EXT_CONS_ACC','1788509') КРАСНОЯРСК
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1787601'),'EXT_CONS_ACC','1787601') ВОРОНЕЖ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1788104'),'EXT_CONS_ACC','1788104') ПЕРМЬ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1228080'),'EXT_CONS_ACC','1228080') ПИТЕР
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1368349'),'EXT_CONS_ACC','1368349') ТВЕРЬ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '2188666'),'EXT_CONS_ACC','2188666') НИЖНИЙ_НОВГОРОД
         FROM GC.PLAN P
WHERE 1=1
  AND P.BBALN IN ('42502','42503','42504','42505','42506','42507')
  AND P.NAME LIKE '%RUR%'
  
UNION ALL  

SELECT '40802','-------' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL

UNION ALL  

SELECT 'ПРОЦЕНТЫ','47426810700004000002' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL
UNION ALL
SELECT 'ДОХОДЫ','70601810700352421811' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL
UNION ALL
SELECT 'РАСХОДЫ','70606810400353131861' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL    
UNION ALL  

SELECT DISTINCT
       P.BBALN
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = 'M'),'EXT_CONS_ACC','M') ГО
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1788509'),'EXT_CONS_ACC','1788509') КРАСНОЯРСК
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1787601'),'EXT_CONS_ACC','1787601') ВОРОНЕЖ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1788104'),'EXT_CONS_ACC','1788104') ПЕРМЬ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1228080'),'EXT_CONS_ACC','1228080') ПИТЕР
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1368349'),'EXT_CONS_ACC','1368349') ТВЕРЬ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '2188666'),'EXT_CONS_ACC','2188666') НИЖНИЙ_НОВГОРОД
         FROM GC.PLAN P
WHERE 1=1
  AND P.BBALN IN ('42109','42110','42111','42112','42113','42114')
  
UNION ALL  

SELECT '40703','-------' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL

UNION ALL  

SELECT 'ПРОЦЕНТЫ','47426810800001000002' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL
UNION ALL
SELECT 'ДОХОДЫ','70601810300352421211' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL
UNION ALL
SELECT 'РАСХОДЫ','70606810000353131261' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL    
UNION ALL  

SELECT DISTINCT
       P.BBALN
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = 'M'),'EXT_CONS_ACC','M') ГО
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1788509'),'EXT_CONS_ACC','1788509') КРАСНОЯРСК
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1787601'),'EXT_CONS_ACC','1787601') ВОРОНЕЖ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1788104'),'EXT_CONS_ACC','1788104') ПЕРМЬ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1228080'),'EXT_CONS_ACC','1228080') ПИТЕР
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1368349'),'EXT_CONS_ACC','1368349') ТВЕРЬ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '2188666'),'EXT_CONS_ACC','2188666') НИЖНИЙ_НОВГОРОД
         FROM GC.PLAN P
WHERE 1=1
  AND P.BBALN IN ('42202','42203','42204','42205','42206','42207')
  AND P.NAME LIKE '%RUR%'  
  
UNION ALL  

SELECT '40702','-------' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL

UNION ALL  

SELECT 'ПРОЦЕНТЫ','47426810800001000002' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL
UNION ALL
SELECT 'ДОХОДЫ','70601810300352421211' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL
UNION ALL
SELECT 'РАСХОДЫ','70606810000353131261' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL    
UNION ALL  

SELECT DISTINCT
       P.BBALN
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = 'M'),'EXT_CONS_ACC','M') ГО
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1788509'),'EXT_CONS_ACC','1788509') КРАСНОЯРСК
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1787601'),'EXT_CONS_ACC','1787601') ВОРОНЕЖ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1788104'),'EXT_CONS_ACC','1788104') ПЕРМЬ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1228080'),'EXT_CONS_ACC','1228080') ПИТЕР
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1368349'),'EXT_CONS_ACC','1368349') ТВЕРЬ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '2188666'),'EXT_CONS_ACC','2188666') НИЖНИЙ_НОВГОРОД
         FROM GC.PLAN P
WHERE 1=1
  AND P.BBALN IN ('42102','42103','42104','42105','42106','42107')
  AND P.NAME LIKE '%RUR%'    


UNION ALL  

SELECT '40701','-------' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL

UNION ALL  

SELECT 'ПРОЦЕНТЫ','47426810800001000002' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL
UNION ALL
SELECT 'ДОХОДЫ','70601810400352421111' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL
UNION ALL
SELECT 'РАСХОДЫ','70606810000353131261' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL    
UNION ALL  

SELECT DISTINCT
       P.BBALN
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = 'M'),'EXT_CONS_ACC','M') ГО
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1788509'),'EXT_CONS_ACC','1788509') КРАСНОЯРСК
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1787601'),'EXT_CONS_ACC','1787601') ВОРОНЕЖ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1788104'),'EXT_CONS_ACC','1788104') ПЕРМЬ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1228080'),'EXT_CONS_ACC','1228080') ПИТЕР
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1368349'),'EXT_CONS_ACC','1368349') ТВЕРЬ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '2188666'),'EXT_CONS_ACC','2188666') НИЖНИЙ_НОВГОРОД
         FROM GC.PLAN P
WHERE 1=1
  AND P.BBALN IN ('42002','42003','42004','42005','42006','42007')
  AND P.NAME LIKE '%RUR%'    
  
UNION ALL  

SELECT '40503','-------' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL

UNION ALL  

SELECT 'ПРОЦЕНТЫ','47426810800001000002' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL
UNION ALL
SELECT 'ДОХОДЫ','70601810700352440151' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL
UNION ALL
SELECT 'РАСХОДЫ','70606810200353130761' ГО,'-------' КРАСНОЯРСК,'-------' ВОРОНЕЖ,'-------' ПЕРМЬ,'-------' ПИТЕР,'-------' ТВЕРЬ,'-------' НИЖНИЙ_НОВГОРОД FROM DUAL    
UNION ALL  

SELECT DISTINCT
       P.BBALN
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = 'M'),'EXT_CONS_ACC','M') ГО
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1788509'),'EXT_CONS_ACC','1788509') КРАСНОЯРСК
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1787601'),'EXT_CONS_ACC','1787601') ВОРОНЕЖ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1788104'),'EXT_CONS_ACC','1788104') ПЕРМЬ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1228080'),'EXT_CONS_ACC','1228080') ПИТЕР
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '1368349'),'EXT_CONS_ACC','1368349') ТВЕРЬ
      ,GC.QUAL$P_MAIN.GET('BAL',(SELECT B.OBJID FROM GC.BAL B WHERE B.BS = P.BS AND B.CUR = '810' AND B.FILIAL = '2188666'),'EXT_CONS_ACC','2188666') НИЖНИЙ_НОВГОРОД
         FROM GC.PLAN P
WHERE 1=1
  AND P.BBALN IN ('41602','41603','41604','41605','41606','41607')
  AND P.NAME LIKE '%RUR%'     
