USE sdm72
go
REVOKE EXECUTE ON dbo.BSS_CloseDeposit_CC FROM public
go
IF OBJECT_ID('dbo.BSS_CloseDeposit_CC') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.BSS_CloseDeposit_CC
    IF OBJECT_ID('dbo.BSS_CloseDeposit_CC') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.BSS_CloseDeposit_CC >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.BSS_CloseDeposit_CC >>>'
END
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[BSS_CloseDeposit_CC] 



     @orgExtId numeric(18,0) --Идентификатор компании в 5NT
    ,@DocRef varchar(50) --Уникальный идентификатор, полученный в результате вызова BSS_OpenDeposit_Req_CC  
    ,@depositContractDate DATE --Дата закрываемого депозита (Поле типа DATE)
    ,@depositContractNr varchar(15) --Номер закрываемого депозита (ID договора в РБС)
    ,@accInOurBank varchar(20) --Счет на который перевести средства
    ,@bicAccInOurBank varchar(9) -- БИК счета, на который перевести средства
    ,@refundSum DSMONEY --Сумма возврата
    


as
set nocount on

declare 

--Выходные параметры:
        @ErrorCode         int 
       ,@ErrText           varchar(255) 
       ,@DepositCloseDate  DATE --Дата закрытия депозита
       
       
       
       ,@IDRequest         varchar(50)
       ,@ResourceID        DSIDENTIFIER
       ,@Check_deposit     int
       ,@Check_sts_depo    int
       ,@SQLStr            nvarchar(4000)
       ,@Params            nvarchar(400)   
       ,@CHECK_CLOSE       int       
       
       
--Формируем ID события. Запишем в журнал
select @IDRequest = newid()

  select @ErrorCode = 1 




select @ResourceID = r.ResourceID
from tResource r WITH (NOLOCK INDEX = XIE2tResource)
where 1=1
  and r.InstOwnerID = @orgExtId
  and r.Brief = @accInOurBank

IF @ResourceID is null
begin
select 
 @ErrorCode = 0
,@ErrText = 'Счет для перевода средств '+@accInOurBank+' не найден у данной организации'
end     



--Ищем депозит
IF @ErrorCode = 1
begin 
        begin 
        select @SQLStr = N' select @Check_deposit = cnt
                                from openquery(' + dbo.sdm_GetRBSDB() + ',' + char(34) + 'select count(*) cnt
                                                                       from gc.dog d                                                                       
                                                                    where 1=1 
                                                                      and d.objid = ' + char(39) +@depositContractNr+ char(39) +'
                                                                      and d.status <> ' + char(39) +'999' + char(39) +'
                                                                      '+char(34)+')'
        End                                                                  
        select @Params = N'@Check_deposit int output'
    
        exec sp_executesql @stmp     = @SQLStr                  
                          ,@Params   = @Params
                          ,@Check_deposit = @Check_deposit output
End

--Проверим статус депозита
IF @ErrorCode = 1
begin 
        begin 
        select @SQLStr = N' select @Check_sts_depo = cnt
                                from openquery(' + dbo.sdm_GetRBSDB() + ',' + char(34) + 'select count(*) cnt
                                                                       from gc.dog d                                                                       
                                                                    where 1=1 
                                                                      and d.objid = ' + char(39) +@depositContractNr+ char(39) +'
                                                                      and d.status = ' + char(39) +'999' + char(39) +'
                                                                      '+char(34)+')'
        End                                                                  
        select @Params = N'@Check_sts_depo int output'
    
        exec sp_executesql @stmp     = @SQLStr                  
                          ,@Params   = @Params
                          ,@Check_sts_depo = @Check_sts_depo output
End

IF @Check_sts_depo > 0
begin
select 
 @ErrorCode = 0
,@ErrText = 'Депозит '+@depositContractNr+' уже помечен на закрытие'
end 

IF @Check_deposit = 0 and @ErrorCode = 1
begin
select 
 @ErrorCode = 0
,@ErrText = 'Депозит '+@depositContractNr+' не найден'
end    



IF @ErrorCode = 1
begin
 select @SQLStr = N'EXECUTE (' + char(39) + 'BEGIN GC.SDM$CLOSE_DEPOSIT_CC(?,?,?,?); END;' + char(39) + ','+ char(39) + @depositContractNr + char(39) + ',' + char(39) + @accInOurBank + char(39) + ','+ char(39) + @IDRequest + char(39) + ','+ char(39) + convert(varchar,@orgExtId) + char(39) + ') at ' + dbo.sdm_GetRBSDB() + ''

                                
        exec sp_executesql @stmp = @SQLStr
        
        
--Проверим статус, закрыли или нет?
select @SQLStr = N' select @CHECK_CLOSE = cnt
                                    from openquery(' + dbo.sdm_GetRBSDB() + ', "select count(*) cnt
                                                             from GC.SDM$LOG_DEPOSIT_CC
                                                             where RequestID = ' + char(39) + convert(varchar(36), @IDRequest) + char(39) + '
                                                               and type_oper = ' + char(39) + 'Закрытие депозита' + char(39) + '
                                                               and status = ' + char(39) + 'SUCCESS' + char(39) + '
                                                               and InstitutionID = '+char(39)+convert(varchar, @orgExtId) +char(39) + ' '+char(34)+')'
        select @Params = N'@CHECK_CLOSE int output'
        exec sp_executesql @stmp        = @SQLStr    
                          ,@Params      = @Params
                          ,@CHECK_CLOSE = @CHECK_CLOSE output

--Ответ не найден, ищем причину
IF @CHECK_CLOSE = 0 and @ErrorCode = 1
begin 
select @ErrorCode = 0
select @SQLStr = N' select @ErrText = error
                                   from openquery(' + dbo.sdm_GetRBSDB() + ', "select text error
                                                             from GC.SDM$LOG_DEPOSIT_CC
                                                             where RequestID = ' + char(39) + convert(varchar(36), @IDRequest) + char(39) + '
                                                               and type_oper = ' + char(39) + 'Закрытие депозита' + char(39) + '
                                                               and status = ' + char(39) + 'ERROR' + char(39) + '
                                                               and InstitutionID = '+char(39)+convert(varchar, @orgExtId) +char(39) + ' '+char(34)+')'
        select @Params = N'@ErrText varchar(255) output'
        exec sp_executesql @stmp        = @SQLStr    
                          ,@Params      = @Params
                          ,@ErrText     = @ErrText output        
end
end


SELECT  ErrorCode = @ErrorCode
      , ErrText = @ErrText
Return 0
go
SET ANSI_NULLS OFF
go
IF OBJECT_ID('dbo.BSS_CloseDeposit_CC') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.BSS_CloseDeposit_CC >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.BSS_CloseDeposit_CC >>>'
go
GRANT EXECUTE ON dbo.BSS_CloseDeposit_CC TO public
go
