declare
  vSprav gc.sprav$values%rowtype;
  id number;
begin
  vSprav := GC.SPRAV_VALUE_ADD('5484'
                          ,PVALUE1 => 'CORREQTS_APPLICATION_NUMBER' 
                          ,PVALUE2 => 'Номер заявления на открытие вклада через ДБО ЮЛ'
                          ,PVALUE3 => '' 
                          ,PVALUE4 => '' 
                          ,PVALUE5 => '' 
                          ,PVALUE6 => '' 
                          ,PVALUE7 => '' 
                          ,PVALUE8 => '' 
                          ,PVALUE9 => '' 
                          ,PVALUE10 => '' 
                          ,F_ERROR_ON_DUP_VALUE1 => TRUE
                          ,pREWRITE_USER_VALUES=>TRUE);
  id := vSprav.id;
  --:valueIdField := vSprav.VALUE1; 
end;
commit;

declare
  vSprav gc.sprav$values%rowtype;
  id number;
begin
  vSprav := GC.SPRAV_VALUE_ADD('5484'
                          ,PVALUE1 => 'CORREQTS_APPLICATION_DATE' 
                          ,PVALUE2 => 'Дата заявления на открытие вклада через ДБО ЮЛ'
                          ,PVALUE3 => '' 
                          ,PVALUE4 => '' 
                          ,PVALUE5 => '' 
                          ,PVALUE6 => '' 
                          ,PVALUE7 => '' 
                          ,PVALUE8 => '' 
                          ,PVALUE9 => '' 
                          ,PVALUE10 => '' 
                          ,F_ERROR_ON_DUP_VALUE1 => TRUE
                          ,pREWRITE_USER_VALUES=>TRUE);
  id := vSprav.id;
  --:valueIdField := vSprav.VALUE1; 
end;
commit;

declare
  vSprav gc.sprav$values%rowtype;
  id number;
begin
  vSprav := GC.SPRAV_VALUE_ADD('5484'
                          ,PVALUE1 => 'CORREQTS_REQUEST_ID' 
                          ,PVALUE2 => 'Идентификатор запроса на открытие'
                          ,PVALUE3 => '' 
                          ,PVALUE4 => '' 
                          ,PVALUE5 => '' 
                          ,PVALUE6 => '' 
                          ,PVALUE7 => '' 
                          ,PVALUE8 => '' 
                          ,PVALUE9 => '' 
                          ,PVALUE10 => '' 
                          ,F_ERROR_ON_DUP_VALUE1 => TRUE
                          ,pREWRITE_USER_VALUES=>TRUE);
  id := vSprav.id;
  --:valueIdField := vSprav.VALUE1; 
end;
commit;

declare
  vSprav gc.sprav$values%rowtype;
  id number;
begin
  vSprav := GC.SPRAV_VALUE_ADD('5484'
                          ,PVALUE1 => 'CORREQTS_DOC_ID' 
                          ,PVALUE2 => 'Идентификатор запроса в ДБО'
                          ,PVALUE3 => '' 
                          ,PVALUE4 => '' 
                          ,PVALUE5 => '' 
                          ,PVALUE6 => '' 
                          ,PVALUE7 => '' 
                          ,PVALUE8 => '' 
                          ,PVALUE9 => '' 
                          ,PVALUE10 => '' 
                          ,F_ERROR_ON_DUP_VALUE1 => TRUE
                          ,pREWRITE_USER_VALUES=>TRUE);
  id := vSprav.id;
  --:valueIdField := vSprav.VALUE1; 
end;
commit;
