exec BSS_OpenDeposit_CC 
        @docId                  = '0186e031-729e-1bff-9a60-9e423acfd59a' --не обрабатываемый
       ,@docNumber              = '17' --не обрабатываемый
        ,@docDate                = '2023-04-27T00:00:00.000+03:00' --не обрабатываемый
       ,@orgExtId               = '10060587715' --ID в Диасофте
       ,@depositProductId       = '5435432543' --Не обрабатываемый параметр
       ,@productCode            = 'DOHOD-RUB'
        ,@interestRate           = 4.00 --не обрабатываемый 
        ,@individualRate         = 0 --не обрабатываемый  
        ,@prolongationByClient   = 0 --не обрабатываемый 
       ,@autoprolongation       = 1 --не обрабатываемый 
        ,@partialWithdrawal      = 0 --не обрабатываемый 
        ,@replenishment          = 0 --не обрабатываемый
        ,@paymentPeriodicity     = '' --не обрабатываемый
       ,@placementCurCode       = 'RUR'
       ,@placementEnd           = '2023-04-27T00:00:00.000+03:00' --не обрабатываемый
       ,@placementStart         = '2023-04-27T00:00:00.000+03:00'
       ,@placementSum           = 1000001.00
       ,@placementTerm          = 31
       ,@sourceAccountNumber    = '40702810500000006882' --Счет списания
       ,@sourceBankBic          = '' --не обрабатываемый
       ,@interestAccountNumber  = '40702810500000006882' --Счет выплаты процентов
       ,@interestBankBic        = '' --не обрабатываемый
       ,@refundAccountNumber    = '40702810500000006882' --Счет для возврата --40702810900009999998
       ,@refundBankBic          = '' --не обрабатываемый
       ,@depAppDate             = '2023-04-27T00:00:00.000+03:00'
       ,@depAppNumber           = '17'
       ,@branchExtId            = '2858299385'


exec BSS_CloseDeposit_CC
       @orgExtId = '10060587715'
      ,@DocRef = '0186e031-729e-1bff-9a60-9e423acfd59a'
      ,@depositContractDate = '2023-03-18T00:00:00.000+03:00'
      ,@depositContractNr = '42103810300000001765'
      ,@accInOurBank = '40702810500000006882'
      ,@bicAccInOurBank = ''
      ,@refundSum = 1000000.00
