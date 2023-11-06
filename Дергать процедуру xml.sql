SET SERVEROUTPUT ON SIZE 1000000
spool ReqAccountExtract.log
declare
  G$VERSION VARCHAR2 (200) := '@(#) $Archive: /SQL/XmlServer/Tests/StepUp/ReqAccountExtract.sql $Revision: 1 $';
  cAgentId varchar2(64) := 'StepUp-Telebank';
  --
  vReq gc.xmlsrv_clnt.varchar2tabtype := gc.xmlsrv_clnt.varchar2tabtype('
<?xml version="1.0" encoding="UTF-8"?>
<Document xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation="rbsxml.xsd" docId="1cc63844-cb96-5f19-bd7a-db20b214c445" agentId="StepUp-Telebank" created="2023-03-28T15:59:11.55+03:00">
  <ReqClientAccounts>
    <clientId>416023455</clientId>
  </ReqClientAccounts>
</Document>
  ');
  --
  
  vAns gc.xmlsrv_clnt.varchar2tabtype;
  --
  vDocId varchar2(64);
  vCreated varchar2(50);
  vResult integer;
  --
  vDogId varchar2(15);
  vStartDate date;
  vEndDate date;
begin

    vResult := gc.xmlsrv_clnt.call_server(
    preq => vReq,
    pans => vAns
  );
  if vResult != 0 then
    dbms_output.put_line('RESULT '||vResult);
    return;
  end if;
       
  xmlsrv_clnt.print(vAns);
end;
/
spool off

--select * from rx$request where received>sysdate-0.1
