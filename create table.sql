CREATE TABLE sdm$log_deposit_cc
    (requestid                      VARCHAR2(50 BYTE),
    insdate                        DATE,
    institutionid                  VARCHAR2(12 BYTE),
    type_oper                      VARCHAR2(100 BYTE),
    status                         VARCHAR2(10 BYTE),
    text                           VARCHAR2(255 BYTE))
  SEGMENT CREATION IMMEDIATE
  PCTFREE     10
  INITRANS    1
  MAXTRANS    255
  TABLESPACE  users
  STORAGE   (
    INITIAL     65536
    NEXT        1048576
    MINEXTENTS  1
    MAXEXTENTS  2147483645
  )
  NOCACHE
  MONITORING
  NOPARALLEL
  LOGGING
/

CREATE TABLE sdm$list_deposit_cc                
    (deposit_name                   VARCHAR2(10 BYTE),
    rs                             VARCHAR2(5 BYTE),
    srok_from                      NUMBER,
    srok_to                        NUMBER,
    deposit_id                     VARCHAR2(12 BYTE))
  SEGMENT CREATION IMMEDIATE
  PCTFREE     10
  INITRANS    1
  MAXTRANS    255
  TABLESPACE  users
  STORAGE   (
    INITIAL     65536
    NEXT        1048576
    MINEXTENTS  1
    MAXEXTENTS  2147483645
  )
  NOCACHE
  MONITORING
  NOPARALLEL
  LOGGING
