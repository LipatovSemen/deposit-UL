USE sdm72
go
REVOKE EXECUTE ON dbo.BSS_OpenDeposit_CC FROM public
go
IF OBJECT_ID('dbo.BSS_OpenDeposit_CC') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.BSS_OpenDeposit_CC
    IF OBJECT_ID('dbo.BSS_OpenDeposit_CC') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.BSS_OpenDeposit_CC >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.BSS_OpenDeposit_CC >>>'
END
go
SET ANSI_NULLS ON
go
CREATE procedure [dbo].[BSS_OpenDeposit_CC] 
     @docId varchar(50) --Идентификатор документа
    ,@docNumber varchar(30) -- Номер заявления
	,@docDate date --Дата заявления
	,@orgExtId numeric(18,0) --Идентификатор организации в АБС
    ,@depositProductId varchar(50) --Депозитный продукт
	,@productCode varchar(30)--Код продукта
	,@interestRate DSMONEY --Процентная ставка
	,@individualRate  INT --Индивидуальная ставка 
	,@prolongationByClient INT --Пролонгация 
    ,@autoprolongation  INT --Автопролонгация
	,@partialWithdrawal INT --Частичное снятие
	,@replenishment INT --Пополнение
	,@paymentPeriodicity  varchar(20) --Периодичность выплат
	,@placementCurCode varchar(3) --Валюта
	,@placementEnd DATE  --Дата возврата
	,@placementStart DATE --Дата размещения
    ,@placementSum DSMONEY --Сумма размещения
	,@placementTerm  INT --Срок размещения (дней)
	,@sourceAccountNumber varchar(20) --Счет списания
	,@sourceBankBic varchar(9)  --БИК 
	,@interestAccountNumber varchar(20) --Счет для выплаты процентов
	,@interestBankBic varchar(9) --БИК
	,@refundAccountNumber varchar(20) --Счет для возврата
	,@refundBankBic varchar(9) --БИК
	,@depAppDate DATE --Дата заявления на открытие вклада через ДБО. Нужно сохранить этот доп. атрибут
	,@depAppNumber varchar(20) --Номер заявления на открытие вклада через ДБО.  Нужно сохранить этот доп. атрибут
    ,@branchExtId varchar(15) --ID отделения (для централизованных филиалов)


as
set nocount on
   
  declare @DocRef            varchar(20)
         ,@Portal            varchar(20)
         ,@Inn_5nt           varchar(12)
         ,@Res_Search_in_RBS int
         ,@SUBJ_ID_RBS       varchar(15)
         ,@NameClient        varchar(255)
         ,@AlterNameClient   varchar(255)
         ,@MainMember        int
         ,@KIO               varchar(5)
         ,@SQLStr            nvarchar(4000)
         ,@Params            nvarchar(400)
         ,@CUR               varchar(3)         
         ,@IDRequest         varchar(50)
         ,@BranchID          DSIDENTIFIER
         ,@OGRN_ID           DSIDENTIFIER
         ,@OGRN              varchar(30)
         ,@MREG              varchar(100)
         ,@REGDATE           varchar(10)         
         ,@KPP               varchar(9)
         ,@OKONHID           varchar(20)
         ,@SVOD_NNS_DEPOSIT  varchar(20) --Сводник депозита, туда будем перекидывать средства
         ,@deposit_id        varchar(15)
         ,@ResourceID        DSIDENTIFIER
         ,@Blocked           INT
         ,@res_balance       DSMONEY     
         ,@K_FEE_SUM         numeric(18,0)
         ,@ResourcePsvID     DSIDENTIFIER
         ,@ResourceID_PRC    DSIDENTIFIER
         ,@ResourceID_RFN    DSIDENTIFIER
         ,@UNO_DOCUMENT_RBS  varchar(12)  
         ,@PSCode            DSIDENTIFIER
         ,@RETVAL            INT         

--Юр.адрес
         ,@Country_u    varchar(3)
         ,@Region_u     varchar(100)
         ,@City_u       varchar(100)
         ,@CityPunkt_u  varchar(100)
         ,@Street_u     varchar(100)
         ,@House_u      varchar(50)
         ,@Korp_u       varchar(50)
         ,@Str_u        varchar(50)
         ,@Flat_u       varchar(50) 

--Местонахождение
         ,@Country_m    varchar(3)
         ,@Region_m     varchar(100)
         ,@City_m       varchar(100)
         ,@CityPunkt_m  varchar(100)
         ,@Street_m     varchar(100)
         ,@House_m      varchar(50)
         ,@Korp_m       varchar(50)
         ,@Str_m        varchar(50)
         ,@Flat_m       varchar(50)  


--Исходящие параметры
         ,@ErrorCode int 
         ,@ErrText varchar(255) 
         ,@DepositDogNum varchar(15)  --Номер договора в РБС
         ,@DepositAccount varchar(20)  --20 значный номер депозита
         ,@DepositRefundDate date  --Плановая дата возврата
         ,@DepositAccountBic varchar(15) 
         ,@DocRefOut varchar(30) 

select  @Country_u = '' 
       ,@Region_u = ''  
       ,@City_u = ''    
       ,@CityPunkt_u = ''
       ,@Street_u = ''  
       ,@House_u = ''   
       ,@Korp_u = ''          
       ,@Str_u = ''                 
       ,@Flat_u = ''
       ,@Country_m = ''        
       ,@Region_m = ''         
       ,@City_m = ''           
       ,@CityPunkt_m = ''      
       ,@Street_m = ''         
       ,@House_m = ''          
       ,@Korp_m = ''    
       ,@Str_m = ''     
       ,@Flat_m = ''    
       
       --Все проводки текущей датой!!
       ,@placementStart = getdate()
       
       
begin  

--Формируем ID события. Запишем в журнал
select @IDRequest = newid()

  select @ErrorCode = 1 
        ,@Res_Search_in_RBS = 0
        ,@SUBJ_ID_RBS = '0'


select @CUR = f.Number
  from tFund f
where f.Brief = case when @placementCurCode = 'RUR' then 'RUB' else @placementCurCode end



select @OGRN_ID = PropertyUsrID
  from tPropertyUsr WITH (NOLOCK INDEX = XAK1tPropertyUsr)
 where PropertyType = 51
   and Brief        = 'ГосРегНом'



--Наберем данные по клиенту
select @Portal = trim(i.Portal)
      ,@Inn_5nt = case when i.MainMember = 0 and len(ltrim(rtrim(r2.Reuters))) = 5 then '' else i.Inn end
      ,@NameClient = case when i.PropDealPart = 0 then i.Name+' '+i.Name1+' '+i.Name2 else i.Name end
      ,@AlterNameClient = isnull(ia.Name,'')
      ,@BranchID = i.BranchID
      ,@KPP = isnull(r.Reuters,'')
      ,@OGRN = isnull(il.NumDoc,'')
      ,@MREG = isnull(substring(il.RegName,1,40),'')  --в РБС влезает только 40 символов
      ,@REGDATE = isnull(replace(replace(convert(varchar,il.DateDoc,103),'01/01/1900',''),' ',''),'')
      ,@OKONHID = isnull(r1.Reuters,'')
      ,@MainMember = isnull(i.MainMember,1)
      ,@KIO       = ltrim(rtrim(substring(isnull(r2.Reuters,''),1,5)))
      from tInstitution i WITH (NOLOCK INDEX = XPKtInstitution)
left join tInstAlterName ia WITH (NOLOCK INDEX = XAK1tInstAlterName)
       on ia.InstitutionID = i.InstitutionID
      and ia.AlterNameTypeID = 2 --Англ. наименование
      and ia.Settings = 1 --Основной
left join tReuters r WITH (NOLOCK INDEX = XIE0tReuters)
       on r.InstitutionID = i.InstitutionID
      and r.TradingSysID = 2 --КПП       
      and r.IsDefault = 1 --Основной     
left join tInstlicense il WITH (NOLOCK INDEX = XAK1tInstLicense)    
       on il.InstitutionID = i.InstitutionID 
      and il.type = 1
      and il.DocTypeID = @OGRN_ID       
      and il.Failed <> 1
left join tReuters r1 WITH (NOLOCK INDEX = XIE0tReuters)
       on r1.InstitutionID = i.InstitutionID
      and r1.TradingSysId in (8,25) --ОКВЭД        
      and r1.IsDefault = 1
left join tReuters r2 WITH (NOLOCK INDEX = XIE0tReuters)
       on r2.InstitutionID = i.InstitutionID
      and r2.TradingSysId = 1027 --КИО        
      and r2.IsDefault = 1             
where i.InstitutionID = @orgExtId


select @Country_u = isnull(c.CodeISO,'')
      ,@Region_u = isnull(region.Name,'') --Регион
      ,@City_u = isnull(city.Name,'') --Город
      ,@CityPunkt_u = isnull(city2.Name,'') --Населенный пункт  
      ,@Street_u = isnull(isnull(street.Name,i.Street),'')
      ,@House_u = isnull(i.house,'')
      ,@Korp_u = isnull(i.frame,'')
      ,@Str_u = isnull(i.Construction,'')
      ,@Flat_u = isnull(i.flat,'')
      from tInstAddress i WITH (NOLOCK INDEX = XIE1tInstAddress)
inner join tCountry c WITH (NOLOCK INDEX = XPKtCountry) 
        on c.CountryID = i.CountryID
left join tCountry region WITH (NOLOCK INDEX = XPKtCountry) 
        on region.CountryID = i.RegionID 
left join tCountry city WITH (NOLOCK INDEX = XPKtCountry) 
        on city.CountryID = i.CityID
left join tCountry city2 WITH (NOLOCK INDEX = XPKtCountry) 
        on city2.CountryID = i.City1ID 
left join tCountry area WITH (NOLOCK INDEX = XPKtCountry) 
        on area.CountryID = i.AreaID         
left join tCountry street WITH (NOLOCK INDEX = XPKtCountry) 
        on street.CountryID = i.StreetID        
where i.InstitutionID = @orgExtId
  and i.AddressTypeID = 1 --Юридический
  
select @Country_m = isnull(c.CodeISO,'')
      ,@Region_m = isnull(region.Name,'') --Регион
      ,@City_m = isnull(city.Name,'') --Город
      ,@CityPunkt_m = isnull(city2.Name,'') --Населенный пункт  
      ,@Street_m = isnull(isnull(street.Name,i.Street),'')
      ,@House_m = isnull(i.house,'')
      ,@Korp_m = isnull(i.frame,'')
      ,@Str_m = isnull(i.Construction,'')
      ,@Flat_m = isnull(i.flat,'')
      from tInstAddress i WITH (NOLOCK INDEX = XIE1tInstAddress)
inner join tCountry c WITH (NOLOCK INDEX = XPKtCountry) 
        on c.CountryID = i.CountryID
left join tCountry region WITH (NOLOCK INDEX = XPKtCountry) 
        on region.CountryID = i.RegionID 
left join tCountry city WITH (NOLOCK INDEX = XPKtCountry) 
        on city.CountryID = i.CityID
left join tCountry city2 WITH (NOLOCK INDEX = XPKtCountry) 
        on city2.CountryID = i.City1ID 
left join tCountry area WITH (NOLOCK INDEX = XPKtCountry) 
        on area.CountryID = i.AreaID         
left join tCountry street WITH (NOLOCK INDEX = XPKtCountry) 
        on street.CountryID = i.StreetID        
where i.InstitutionID = @orgExtId
  and i.AddressTypeID = 2 --Фактический  


select @ResourceID = r.ResourceID
      ,@Blocked    = r.Blocked 
from tResource r WITH (NOLOCK INDEX = XIE2tResource)
where 1=1
  and r.InstOwnerID = @orgExtId
  and r.Brief = @sourceAccountNumber

IF @ResourceID is null
begin
select 
 @ErrorCode = 0
,@ErrText = 'Счет списания '+@sourceAccountNumber +' не найден у данной организации'
end

IF @Blocked in (1,2)
begin
select 
 @ErrorCode = 0
,@ErrText = 'Счет списания '+@sourceAccountNumber +' заблокирован'
end


IF @ErrorCode = 1
begin
delete pResource where SPID = @@SPID 
-- в эту таблицу вставляем ID счетов, по которым нужно получить остатки и обороты
insert pResource (SPID, ResourceID)
select @@spid, @ResourceID

-- запуск процедуры
exec AccList_Rest 
                  @DateStart    = @placementStart
                 ,@Date         = @placementStart
                 ,@TurnCalc     = 1
                 ,@Confirmed    = 0
                 --,@LastDateCalc = 1


select @res_balance = rl.Rest * (-1)
from pResList rl
where 1=1
  and rl.ResourceID = @ResourceID 
  and rl.SPID = @@SPID 
end

IF @ErrorCode = 1 and @res_balance < @placementSum
begin
select 
 @ErrorCode = 0
,@ErrText = 'Недостаточно средств на счете '+@sourceAccountNumber
end

select @ResourceID_PRC = r.ResourceID
from tResource r WITH (NOLOCK INDEX = XIE2tResource)
where 1=1
  and r.InstOwnerID = @orgExtId
  and r.Brief = @interestAccountNumber

IF @ResourceID_PRC is null
begin
select 
 @ErrorCode = 0
,@ErrText = 'Счет для выплаты процентов '+@interestAccountNumber +' не найден у данной организации'
end

select @ResourceID_RFN = r.ResourceID
from tResource r WITH (NOLOCK INDEX = XIE2tResource)
where 1=1
  and r.InstOwnerID = @orgExtId
  and r.Brief = @refundAccountNumber

IF @ResourceID_RFN is null
begin
select 
 @ErrorCode = 0
,@ErrText = 'Счет для возврата депозита '+@refundAccountNumber +' не найден у данной организации'
end


--Если заполнен Portal_ID в Диасофт, то ищем конкретного клиента в РБС
IF len(@Portal) > 1 and @ErrorCode = 1
begin 
        begin 
        select @SQLStr = N' select @SUBJ_ID_RBS = SUBJ_ID
                                from openquery(' + dbo.sdm_GetRBSDB() + ',' + char(34) + 'select to_char(o.subj_id) SUBJ_ID
                                                                       from gc.subj s
                                                                           ,gc.org o                                                                       
                                                                    where 1=1 
                                                                      and s.id = ' + char(39) +@Portal+ char(39) +' 
                                                                      and s.status is null                                                                      
                                                                      and o.subj_id = s.id
                                                                      '+char(34)+')'
        End                                                                  
        select @Params = N'@SUBJ_ID_RBS varchar(16) output'
    
        exec sp_executesql @stmp     = @SQLStr                  
                          ,@Params   = @Params
                          ,@SUBJ_ID_RBS = @SUBJ_ID_RBS output
End


IF @MainMember = 1 and len(@Inn_5nt) not in (10,12)
begin
select 
 @ErrorCode = 0
,@ErrText = 'У организации в Диасофт отсутсвует ИНН'
end




--Если это ИП, то начитаем заново рег документы. Таран сказала что забираем из интерфейса "Основания для соверешения операции"
IF @ErrorCode = 1
begin
if exists ( select 1 from tReuters r WITH (NOLOCK INDEX = XAK1tReuters)
                        where r.InstitutionID = @orgExtId
                          and r.TradingSysID = 13
                          and r.IsDefault = 1
                          )                         
   begin

select @OGRN = isnull(a.NumDoc,''),
       @MREG = isnull(case
         when i.PropDealPart = 1  then substring(i.Name,1,40) -- В РБС влезает только 40 символов
         when i.PropDealPart = 0  then substring(rtrim(ltrim((i.Name + ' ' + i.Name1 + ' ' + i.Name2))),1,40)
       end,''),
       @REGDATE = isnull(replace(replace(convert(varchar,a.DateIssue,103),'01/01/1900',''),' ',''),'') 

from
     tInstAuthority  a
                       WITH (NOLOCK index=XIE1tInstAuthority)
left join tPropertyUsr p WITH (NOLOCK index=XPKtPropertyUsr)
       on a.AuthorityTypeID = p.PropertyUsrID
inner join tInstitution i WITH (NOLOCK index=XPKtInstitution)
       on a.RegInstitutionID = i.InstitutionID
left join tInstLicense l WITH (NOLOCK index=XAK1tInstLicense)
       on l.Type = 0
      and a.RegInstitutionID = l.InstitutionID
      and l.isDefault = 1
where a.InstitutionID = @orgExtId     
 
   end
end




--Если не нашли клиента по Portal_ID, то ищем клиента по ИНН из Диасофта
IF @SUBJ_ID_RBS = '0' and @ErrorCode = 1
    Begin 
        begin         
        select @SQLStr = N' select @Res_Search_in_RBS = cnt_in_rbs
                                from openquery(' + dbo.sdm_GetRBSDB() + ',' + char(34) + 'select count(*) cnt_in_rbs
                                                                    from gc.org o
                                                                        ,gc.subj s                                                                    
                                                                    where 1=1
                                                                      and s.id = o.subj_id
                                                                      and s.status is null
                                                                      and (o.idn = ' + char(39) +convert(varchar,@Inn_5nt) + char(39) +'   
                                                                           or o.kio = ' + char(39) +convert(varchar,@KIO) + char(39) +'   
                                                                             and length(' + char(39) +convert(varchar,@KIO) + char(39) +') = 5)
                                                                      '+char(34)+')'
        End                                                                  
        select @Params = N'@Res_Search_in_RBS int output'
    
        exec sp_executesql @stmp     = @SQLStr                  
                          ,@Params   = @Params
                          ,@Res_Search_in_RBS   = @Res_Search_in_RBS output
     End


--Если по ИНН находится больше одного клиента, то ищем максимальный SUBJ_ID с открытыми счетами
If @Res_Search_in_RBS > 1 and @ErrorCode = 1
begin
     begin         
        select @SQLStr = N' select @SUBJ_ID_RBS = subj_id
                                from openquery(' + dbo.sdm_GetRBSDB() + ',' + char(34) + 'select max(o.subj_id) subj_id
                                                                    from gc.org o 
                                                                        ,gc.subj s
                                                                    where 1=1
                                                                      and s.id = o.subj_id
                                                                      and s.status is null  
                                                                      and (o.idn = ' + char(39) +convert(varchar,@Inn_5nt) + char(39) +'   
                                                                           or o.kio = ' + char(39) +convert(varchar,@KIO) + char(39) +'   
                                                                             and length(' + char(39) +convert(varchar,@KIO) + char(39) +') = 5)
                                                                      and exists (select 1 from gc.acc a 
                                                                                               ,gc.plan p
                                                                                   where a.subj_id = o.subj_id
                                                                                     and a.bs = p.bs
                                                                                     )
                                                                                                                                                                         
                                                                      '+char(34)+')'
        End                                                                  
        select @Params = N'@SUBJ_ID_RBS varchar(15) output'
    
        exec sp_executesql @stmp     = @SQLStr                  
                          ,@Params   = @Params
                          ,@SUBJ_ID_RBS = @SUBJ_ID_RBS output
end


--Если по ИНН находится только один клиент, то берем его
If @Res_Search_in_RBS = 1 and @SUBJ_ID_RBS = '0' and @ErrorCode = 1
begin
        begin         
        select @SQLStr = N' select @SUBJ_ID_RBS = subj_id
                                from openquery(' + dbo.sdm_GetRBSDB() + ',' + char(34) + 'select o.subj_id subj_id
                                                                    from gc.org o 
                                                                        ,gc.subj s
                                                                    where 1=1
                                                                      and s.id = o.subj_id
                                                                      and s.status is null  
                                                                      and (o.idn = ' + char(39) +convert(varchar,@Inn_5nt) + char(39) +'   
                                                                           or o.kio = ' + char(39) +convert(varchar,@KIO) + char(39) +'   
                                                                             and length(' + char(39) +convert(varchar,@KIO) + char(39) +') = 5)
                                                                      '+char(34)+')'
        End                                                                  
        select @Params = N'@SUBJ_ID_RBS varchar(15) output'    
        exec sp_executesql @stmp     = @SQLStr                  
                          ,@Params   = @Params
                          ,@SUBJ_ID_RBS = @SUBJ_ID_RBS output
end


--Клиента не нашли, создаем новое досье в РБС      
IF @SUBJ_ID_RBS = '0' and @ErrorCode = 1   
begin     
        select @SQLStr = N'EXECUTE (' + char(39) + 'BEGIN GC.SDM$INS_ORG(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?); END;' + char(39) + '
                                                ,'+ char(39) + @NameClient + char(39) + '
                                                ,' + char(39) + @AlterNameClient + char(39) + '
                                                ,'+ char(39) + @Inn_5nt + char(39) + '
                                                ,'+ char(39) + @KIO + char(39) + '
                                                ,'+ char(39) + convert(varchar,@MainMember) + char(39) + '   
                                                ,'+ char(39) + @OGRN + char(39) + '
                                                ,'+ char(39) + @MREG + char(39) + '
                                                ,'+ char(39) + @REGDATE + char(39) + '
                                                ,'+ char(39) + @KPP + char(39) + '
                                                ,'+ char(39) + @OKONHID + char(39) + '
                                                ,'+ char(39) + convert(varchar,@BranchID) + char(39) + '
                                                ,'+ char(39) + convert(varchar,@sourceAccountNumber) + char(39) + '
                                                ,'+ char(39) + @Country_u + char(39) + '
                                                ,'+ char(39) + @Region_u + char(39) + '
                                                ,'+ char(39) + @City_u + char(39) + '
                                                ,'+ char(39) + @CityPunkt_u + char(39) + '
                                                ,'+ char(39) + @Street_u + char(39) + '
                                                ,'+ char(39) + @House_u + char(39) + '
                                                ,'+ char(39) + @Korp_u + char(39) + '
                                                ,'+ char(39) + @Str_u + char(39) + '
                                                ,'+ char(39) + @Flat_u + char(39) + '
                                                ,'+ char(39) + @Country_m + char(39) + '
                                                ,'+ char(39) + @Region_m + char(39) + '
                                                ,'+ char(39) + @City_m + char(39) + '
                                                ,'+ char(39) + @CityPunkt_m + char(39) + '
                                                ,'+ char(39) + @Street_m + char(39) + '
                                                ,'+ char(39) + @House_m + char(39) + '
                                                ,'+ char(39) + @Korp_m + char(39) + '
                                                ,'+ char(39) + @Str_m + char(39) + '
                                                ,'+ char(39) + @Flat_m + char(39) + '                                                
                                                ,'+ char(39) + @IDRequest + char(39) + '
                                                ,'+ char(39) + convert(varchar,@orgExtId) + char(39) + '
                                                ) at ' + dbo.sdm_GetRBSDB() + ''

                                
        exec sp_executesql @stmp = @SQLStr    

--Заберем ID созданного клиента
select @SQLStr = N' select @SUBJ_ID_RBS = subj_id
                                   from openquery(' + dbo.sdm_GetRBSDB() + ', "select substr(TEXT,1,15) subj_id
                                                             from GC.SDM$LOG_DEPOSIT_CC
                                                             where RequestID = ' + char(39) + convert(varchar(36), @IDRequest) + char(39) + '
                                                               and type_oper = ' + char(39) + 'Заведение клиента' + char(39) + '
                                                               and status    = ' + char(39) + 'SUCCESS' + char(39) + '
                                                               and InstitutionID = '+char(39)+convert(varchar, @orgExtId) +char(39) + ' '+char(34)+')'
        select @Params = N'@SUBJ_ID_RBS varchar(15) output'
        exec sp_executesql @stmp        = @SQLStr    
                          ,@Params      = @Params
                          ,@SUBJ_ID_RBS = @SUBJ_ID_RBS output  


--Пропишем номер ID-RBS в карточке Диасофт                          
--Перенёс ниже
/*exec @RETVAL = Institution_Update 
                        @InstitutionID = @orgExtId 
                       ,@Portal        = @SUBJ_ID_RBS                          */
end

   
IF @SUBJ_ID_RBS = '0' and @ErrorCode = 1
begin
select
 @ErrorCode = 0
,@ErrText = 'Досье не создано, что-то не так'
end


--Поиск финансового продукта по переданному параметру @depositProductId
--Поиск осуществляем по таблице gc.sdm$list_deposit_cc в РБС
--Для поиска нам нужен срок @placementTerm, валюта @placementCurCode, счет списания @sourceAccountNumber, группа депозитов @productCode 
IF @ErrorCode = 1 and @SUBJ_ID_RBS <> '0'
begin

select @SQLStr = N' select @deposit_id = deposit_id
                                       from openquery(' + dbo.sdm_GetRBSDB() + ',' + char(34) + 'select max(to_char(sd.deposit_id)) deposit_id 
                                                from gc.sdm$list_deposit_cc sd
                                           where 1=1
                                             and sd.deposit_name = '+ char(39) + convert(varchar,@productCode) + char(39) + '
                                             and sd.rs = '+ char(39) + substring(@sourceAccountNumber,1,5) + char(39) + '
                                             and sd.srok_from <= '+ char(39) + convert(varchar,@placementTerm) + char(39) + '
                                             and sd.srok_to >= '+ char(39) + convert(varchar,@placementTerm) + char(39) + '
                                          '+char(34)+')'

                       select @Params = N'@deposit_id varchar(15) output' 

               
           exec sp_executesql @stmp     = @SQLStr                  
                             ,@Params   = @Params
                             ,@deposit_id = @deposit_id output
end

IF @deposit_id is null and @ErrorCode = 1
begin
select
 @ErrorCode = 0
,@ErrText = 'Не найден подходящий финансовый продукт. Таблица соответствия gc.sdm$list_deposit_cc'
end


--Проверем минимальную сумму вклада в настройках и сравним с суммой клиента
IF @ErrorCode = 1
begin
select @SQLStr = N' select @K_FEE_SUM = K_FEE_SUM
                                       from openquery(' + dbo.sdm_GetRBSDB() + ',' + char(34) + 'select nvl(gc.qual$p_main.get(' + char(39) + 'DEPTYP' + char(39) + ', '+ char(39) + convert(varchar,@deposit_id) + char(39) + ', ' + char(39) + 'K_FEE_SUM' + char(39) + '),0) K_FEE_SUM
                                                from dual
                                           where 1=1
                                          '+char(34)+')'

                       select @Params = N'@K_FEE_SUM numeric(18,0) output' 

               
           exec sp_executesql @stmp     = @SQLStr                  
                             ,@Params   = @Params
                             ,@K_FEE_SUM = @K_FEE_SUM output
end


IF @placementSum < @K_FEE_SUM and @ErrorCode = 1
begin
select
 @ErrorCode = 0
,@ErrText = 'Минимальная сумма первоначального взноса ('+convert(varchar,@K_FEE_SUM)+') больше суммы пополнения ('+convert(varchar,@placementSum)+')';
end

--Клиента создали/нашли, фин продукт нашли
--Пробуем открыть депозит
IF @ErrorCode = 1 
begin --Начало обработки по открытию депозита

        select @SQLStr = N'EXECUTE (' + char(39) + 'BEGIN GC.SDM$OPEN_DEPOSIT_CC(?,?,?,?,?,?,?,?,?,?,?,?,?); END;' + char(39) + '
                                             ,'+ char(39) + @SUBJ_ID_RBS + char(39) + '
                                             ,' + char(39) + @CUR + char(39) + '
                                             ,'+ char(39) + convert(varchar,@placementTerm) + char(39) + '
                                             ,'+ char(39) + convert(varchar,@deposit_id) + char(39) + '
                                             ,'+ char(39) + convert(varchar,@BranchID) + char(39) + '
                                             ,'+ char(39) + convert(varchar,@branchExtId) + char(39) + '
                                             ,'+ char(39) + convert(varchar(20),@depAppNumber) + char(39) + '
                                             ,'+ char(39) + convert(varchar,@depAppDate,103) + char(39) + '
                                             ,'+ char(39) + @interestAccountNumber + char(39) + '
                                             ,'+ char(39) + @refundAccountNumber + char(39) + '
                                             ,'+ char(39) + @IDRequest + char(39) + '
                                             ,'+ char(39) + @DocID + char(39) + '
                                             ,'+ char(39) + convert(varchar,@orgExtId) + char(39) + ') at ' + dbo.sdm_GetRBSDB() + ''

                                
        exec sp_executesql @stmp = @SQLStr  


--Заберем ID созданного договора
select @SQLStr = N' select @DepositDogNum = dog_id
                                   from openquery(' + dbo.sdm_GetRBSDB() + ', "select substr(TEXT,1,15) dog_id
                                                             from GC.SDM$LOG_DEPOSIT_CC
                                                             where RequestID = ' + char(39) + convert(varchar(36), @IDRequest) + char(39) + '
                                                               and type_oper = ' + char(39) + 'Открытие депозита' + char(39) + '
                                                               and status = ' + char(39) + 'SUCCESS' + char(39) + '
                                                               and InstitutionID = '+char(39)+convert(varchar, @orgExtId) +char(39) + ' '+char(34)+')'
        select @Params = N'@DepositDogNum varchar(15) output'
        exec sp_executesql @stmp        = @SQLStr    
                          ,@Params      = @Params
                          ,@DepositDogNum = @DepositDogNum output



--Успешный запрос по открытию договора не нашли, заберем причину
IF @DepositDogNum is null                          
begin 
select @ErrorCode = 0
select @SQLStr = N' select @ErrText = error
                                   from openquery(' + dbo.sdm_GetRBSDB() + ', "select text error
                                                             from GC.SDM$LOG_DEPOSIT_CC
                                                             where RequestID = ' + char(39) + convert(varchar(36), @IDRequest) + char(39) + '
                                                               and type_oper = ' + char(39) + 'Открытие депозита' + char(39) + '
                                                               and status = ' + char(39) + 'ERROR' + char(39) + '
                                                               and InstitutionID = '+char(39)+convert(varchar, @orgExtId) +char(39) + ' '+char(34)+')'
        select @Params = N'@ErrText varchar(255) output'
        exec sp_executesql @stmp        = @SQLStr    
                          ,@Params      = @Params
                          ,@ErrText     = @ErrText output
end


--Успешный запрос. Заберём остальные данные
IF @DepositDogNum is not null                          
begin 

--Депозит открыт, меняем значение PortalID в любом случае, даже если не было заведено новое досье
exec @RETVAL = Institution_Update 
                        @InstitutionID = @orgExtId 
                       ,@Portal        = @SUBJ_ID_RBS                          

select @DocRefOut = @IDRequest
select @SQLStr = N' select @DepositAccount = nns
                          ,@SVOD_NNS_DEPOSIT = SVOD_NNS_DEPOSIT
                          ,@DepositRefundDate = d_final
                          ,@DepositAccountBic = bik 
                                   from openquery(' + dbo.sdm_GetRBSDB() + ', "select gc.nns.get(d.s,d.cur,sysdate) nns
                                              ,gc.qual$p_main.get(' + char(39) + 'ACC' + char(39) + ',a.objid,' + char(39) + 'EXT_CONS_ACC' + char(39) + ') SVOD_NNS_DEPOSIT
                                                                   ,d.d_final d_final
                                                                   ,gc.rep_subj.get_bank_bik(d.filial) bik
                                                             from GC.DOG D
                                                                 ,GC.ACC A
                                                             where D.OBJID = ' + char(39) + convert(varchar, @DepositDogNum) + char(39) + '
                                                               and a.dog_id = d.objid
                                                      '+char(34)+')'
        select @Params = N'@DepositAccount varchar(20) output
                          ,@SVOD_NNS_DEPOSIT varchar(20) output
                          ,@DepositRefundDate date output
                          ,@DepositAccountBic varchar(15) output'
                        
        exec sp_executesql @stmp              = @SQLStr    
                          ,@Params            = @Params
                          ,@DepositAccount    = @DepositAccount output
                          ,@SVOD_NNS_DEPOSIT  = @SVOD_NNS_DEPOSIT output
                          ,@DepositRefundDate = @DepositRefundDate output
                          ,@DepositAccountBic = @DepositAccountBic output
end




--Создадим документ в Диасофт с расчетного счета на сводник депозита
IF @ErrorCode = 1
begin


select @ResourcePsvID = r.ResourceID
from tResource r WITH (NOLOCK INDEX = XAK1tResource)
where 1=1
  and r.Brief = @SVOD_NNS_DEPOSIT
  
IF @ResourcePsvID is null and @ErrorCode = 1
begin
select
 @ErrorCode = 0
,@ErrText = 'Сводный счет '+@SVOD_NNS_DEPOSIT+' депозита не найден в Диасофт'
end


set implicit_transactions off   
set transaction isolation level read committed 

begin transaction



declare @SYS_ErrorCode int
       ,@SYS_DocRef    DSIDENTIFIER
       ,@SYS_ErrorText DSCOMMENT
       ,@DealID        DSIDENTIFIER
       ,@Naz_Plat      DSCOMMENT
       ,@Bank_Out      DSIDENTIFIER
       ,@InnOut        varchar(15)
       ,@NameOut       varchar(255)
       ,@KppOut        varchar(15)
select  @SYS_ErrorCode = 0,
        @SYS_DocRef    = 0,
        @SYS_ErrorText = '',
        @Naz_plat = 'Перевод в пользу '+@NameClient+' для зачисления на л/с депозита '+@DepositAccount+' по договору '+@DepositDogNum+' от '+convert(varchar,@placementStart,104)+' НДС не облагается'
select @Bank_Out  = R.InstitutionID
      ,@InnOut   = i.Inn
      ,@NameOut  = i.Name
      ,@KppOut  = r1.Reuters
    from tResource R
    inner join tInstitution i WITH(NOLOCK INDEX = XPKtInstitution)
            on i.InstitutionID = R.InstitutionID
    left join tReuters r1 WITH (NOLOCK INDEX = XIE0tReuters)
      on r1.InstitutionID = i.InstitutionID
     and r1.TradingSysID = 2 --КПП       
     and r1.IsDefault = 1 --Основной 
   where R.ResourceType =1
     and (R.BalanceID=2140 or R.BalanceID=2123 or R.BalanceID=55015845)
     and R.Brief=@SVOD_NNS_DEPOSIT
     and R.DateEnd='19000101'     



IF @MainMember = 0 
begin
select @PsCode = 10000000150 --код VO 60070 select * from tCurrencyTranCode 
end
       
/*
exec @SYS_ErrorCode = DealTransact_Insert
               @DealTransactID= @SYS_DocRef out,
               @DealID        = 0,
               @TransactType  = 5,
               @Date          = @placementStart,
               @Qty           = @placementSum,
               @FixQty        = @placementSum,
               @ResourceID    = @ResourceID,
               @ResSecondID   = 0,
               @InstitutionID = @BranchID,
               @FixCourse     = 1,
               @FixDate       = @placementStart,
               @RealCourse    = 1,
               @RealQty       = @placementSum,
               @Confirmed     = 1,
               @Direction     = 0,
               @Type          = 4,
               @NettQty       = 0,
               @SecurityID    = 0,
               @FundID        = 2,
               @Comment       = @Naz_plat,
               @ExpensePrc    = 0,
               @ExpenseFundID = 0,
               @ExpenseCourse = 0,
               @DocDate       = @placementStart,
               @BalanceQty    = $0.0000,
               @ResourcePsvID = @ResourcePsvID,
               @ResSecondPsvID= 0   ,
               @InstrumentID  = 1558,--ВнутрПлат
               @NumberExt     = '       1                 ',
               @CouponID      = 0,
               @BatchID       = '5000025',
               @ValueDate     = @placementStart,
               @OpCode        = 9,
               @FundPsvID     = 2 */
               

 -- создаем документ
 exec @SYS_ErrorCode = TDocumentPlat_F_Insert
  @DealTransactID  =  @SYS_DocRef out,
  @InstrumentID    =  1558,
  @DealID          =  0,
  @BatchID         =  '5000025',
  @OpCode          =  1,
  @Date            =  @placementStart,
  @Confirmed       =  1,  
  @Priority        =  5, --Очередность 
  @Qty             =  @placementSum,
  @BankIn          =  @BranchID,
  @AccInID         =  @ResourceID,
  @AccIn           =  @sourceAccountNumber,
  @KppIn           =  @KPP,
  @InnIn           =  @Inn_5nt,
  @NameIn          =  @NameClient,

  @BankOut         =  @Bank_Out,
  @AccOutID        =  @ResourcePsvID,
  @AccOut          =  @SVOD_NNS_DEPOSIT,
  @KppOut          =  @KppOut,
  @InnOut          =  @InnOut,
  @NameOut         =  @NameOut,
  @PSCode          =  @PsCode,

  @DocDate         =  @placementStart,
  @TermDate        =  @placementStart,
  @Comment         =  @Naz_plat,
  @ResDebID        =  @ResourceID,
  @ResCreID        =  @ResourcePsvID,
  @Flag            =  '       1                 ',
  @ValueDate       =  @placementStart            

commit transaction               
               
IF @SYS_ErrorCode <> 0 and @ErrorCode = 1 
begin
 select @SYS_ErrorText = r.Message 
 from treturncode r 
 where r.RetCode = @SYS_ErrorCode
select
 @ErrorCode = 0
,@ErrText = 'Документ в Диасофт не создан. Операция прервана. '+@SYS_ErrorText
end  


             
end--Конец создания документа в Диасофте

--Создадим документ пополнения депозита в РБС
IF @ErrorCode = 1
begin
 select @SQLStr = N'EXECUTE (' + char(39) + 'BEGIN GC.SDM$PAYMENT_DEPOSIT_CC(?,?,?,?,?); END;' + char(39) + '
                                               ,'+ char(39) + @DepositAccount + char(39) + '
                                               ,' + char(39) + convert(varchar(20),@placementSum) + char(39) + '
                                               ,'+ char(39) + @IDRequest + char(39) + '
                                               ,'+ char(39) + convert(varchar,@orgExtId) + char(39) + '
                                               ,'+ char(39) + convert(varchar,@sourceAccountNumber) + char(39) + ') at ' + dbo.sdm_GetRBSDB() + ''

                                
        exec sp_executesql @stmp = @SQLStr
        

--Заберем UNO документа в РБС
select @SQLStr = N' select @UNO_DOCUMENT_RBS = UNO
                                   from openquery(' + dbo.sdm_GetRBSDB() + ', "select substr(TEXT,1,15) UNO
                                                             from GC.SDM$LOG_DEPOSIT_CC
                                                             where RequestID = ' + char(39) + convert(varchar(36), @IDRequest) + char(39) + '
                                                               and type_oper = ' + char(39) + 'Пополнение депозита' + char(39) + '
                                                               and status = ' + char(39) + 'SUCCESS' + char(39) + '
                                                               and InstitutionID = '+char(39)+convert(varchar, @orgExtId) +char(39) + ' '+char(34)+')'
        select @Params = N'@UNO_DOCUMENT_RBS varchar(12) output'
        exec sp_executesql @stmp        = @SQLStr    
                          ,@Params      = @Params
                          ,@UNO_DOCUMENT_RBS = @UNO_DOCUMENT_RBS output

--Номер документа не нашли. Ищем причину
IF @UNO_DOCUMENT_RBS is null and @ErrorCode = 1
begin 
select @ErrorCode = 0
select @SQLStr = N' select @ErrText = error
                                   from openquery(' + dbo.sdm_GetRBSDB() + ', "select text error
                                                             from GC.SDM$LOG_DEPOSIT_CC
                                                             where RequestID = ' + char(39) + convert(varchar(36), @IDRequest) + char(39) + '
                                                               and type_oper = ' + char(39) + 'Пополнение депозита' + char(39) + '
                                                               and status = ' + char(39) + 'ERROR' + char(39) + '
                                                               and InstitutionID = '+char(39)+convert(varchar, @orgExtId) +char(39) + ' '+char(34)+')'
        select @Params = N'@ErrText varchar(255) output'
        exec sp_executesql @stmp        = @SQLStr    
                          ,@Params      = @Params
                          ,@ErrText     = @ErrText output
                          
                          
--Зафиктивим проводку в Диасофте, так как документ в РБС не создался
exec DealTransact_QuickUpdate
    @DealTransactID = @SYS_DocRef
   ,@Confirmed = 101                         
end



               
end --Конец создания документа в РБС


end --Конец обработки открытия депозита


--ищем по Postal_ID
end

   

SELECT  ErrorCode = @ErrorCode
      , ErrText = @ErrText
      , DepositDogNum = @DepositDogNum
      , DepositAccount = @DepositAccount
      , DepositRefundDate = @DepositRefundDate
      , DepositAccountBic = @DepositAccountBic
      , DocRefOut = @DocRefOut
Return 0
go
SET ANSI_NULLS OFF
go
IF OBJECT_ID('dbo.BSS_OpenDeposit_CC') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.BSS_OpenDeposit_CC >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.BSS_OpenDeposit_CC >>>'
go
GRANT EXECUTE ON dbo.BSS_OpenDeposit_CC TO public
go
