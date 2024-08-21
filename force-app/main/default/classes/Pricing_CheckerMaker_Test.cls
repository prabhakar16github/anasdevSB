@isTest
public class Pricing_CheckerMaker_Test {
    @testSetup
    public static void testDataSetup() {
        
        
        Payment_Mode__c pMode = new Payment_Mode__c();
        pMode.Name = 'Test Payment Mode';
        insert pMode;
        
        Payment_Option2__c po = new Payment_Option2__c();
        po.Name = 'Test Payment Options';
        insert po;
        
        Pricing_Specification__c ps = new Pricing_Specification__c();
        ps.Name = 'Test Pricing Specification';
        insert ps;
        
        Payment_Gateway2__c pg = new Payment_Gateway2__c();
        pg.Name = 'Test Payment Gateway';
        pg.Type__c = 'PreApproved';
        insert pg;
        
        SF_Treasury_Transformer__c sfTrans = new SF_Treasury_Transformer__c();
        sfTrans.Payment_Entity__c = 123;
        sfTrans.Payment_Mode__c = 'abc';
        sfTrans.Bank_Code__c = 'abc';
        //sfTrans.Card_Type__c = 'Credit Card'
        sfTrans.IsOnus__c = '1';
        sfTrans.SF_ID__c = 'SF1';
        insert sfTrans;
        
        
        Master_Pricing_Data__c mpd = new Master_Pricing_Data__c();
        mpd.Payment_Mode__c = pMode.Id;
        mpd.Payment_Option__c = po.Id;
        mpd.Pricing_Specification__c = ps.Id;
        mpd.Payment_Gateway__c = pg.Id;
        mpd.Salesforce_Primary_Key__c = 'SF1';
        mpd.Donation_0_Flat__c = 50;
        mpd.Donation_0_Percentage__c = 1.5;
        mpd.Donation_2000_Flat__c = 100;
        mpd.Donation_2000_Percentage__c = 1.6;
        mpd.ONUS_OFFUS__c = 'ONUS';
        mpd.Bank__c = 'HDFC Bank';
        mpd.POR_Type__c = 'Cards';
        mpd.Active_Instrument__c = true;
        insert mpd;
        
        
        
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Bank_Category__c bc = new Bank_Category__c();
        bc.Name = 'Donation';
        insert bc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Open';
        opp.Bank_Category__c = bc.Id;
        opp.CloseDate = System.today();
        opp.Prod_Merchant_Id__c = 123456;
        //opp.Aggregator_UUID__c = '11ed-e4ea-b74b48aa-929c-02e708f88ebc';
        insert opp;
        
        
        Commercial2__c comm = new Commercial2__c();
        comm.Name = 'Test Commercial';
        comm.Opportunity__c = opp.Id;
        comm.Is_Updated__c = true;
        comm.Status__c = 'Live';
        insert comm;
        
        List<Pricing__c> listPricing = new List<Pricing__c>(); 
        Pricing__c price = new Pricing__c();
        price.Commercial2__c = comm.Id;
        price.Below_Rack_Rates__c = true;
        price.Master_Pricing_Data__c = mpd.Id;
        price.Payment_Gateway2__c = pg.Id;
        price.Transaction_Type__c = 'TDR';
        price.Fee_Model__c = 'Net';
        price.TDR_Amount__c = 100;
        price.TDR__c = 2.5;
        price.TDR_Flat_Fee__c = 2.5;
        price.Rule_Id__c = '7119691';
        price.Banking_Ops_Status__c = 'Approved';
        price.Opportunity__c = opp.Id;
        price.Need_to_Publish__c = true;
        price.Invisible__c = false;
        listPricing.add(price);
        
        Pricing__c price1 = new Pricing__c();
        price1.Commercial2__c = comm.Id;
        price1.Below_Rack_Rates__c = true;
        price1.Master_Pricing_Data__c = mpd.Id;
        price1.Payment_Gateway2__c = pg.Id;
        price1.Banking_Ops_Status__c = 'Approved';
        price1.Rule_Id_Conv__c = '7119698';
        price1.Opportunity__c = opp.Id;
        //price.Deleted__c = true;
        price1.Transaction_Type__c = 'Convenience';
        price1.Fee_Model__c = 'Net';
        price1.Convenience_Amount__c  = 200;
        price1.Convenience__c  = 2.5;
        price1.Convenience_Flat_Fee__c = 2.5;
        price1.Banking_Ops_Status__c = 'Approved';
        price1.Need_to_Publish__c = true;
        price1.Invisible__c = false;
        listPricing.add(price1); 
        
        Pricing__c price3 = new Pricing__c();
        price3.Commercial2__c = comm.Id;
        price3.Below_Rack_Rates__c = true;
        price3.Master_Pricing_Data__c = mpd.Id;
        price3.Payment_Gateway2__c = pg.Id;
        price3.Rule_Id__c = '7119693';
        price3.Rule_Id_Conv__c = '7119694';
        price3.Transaction_Type__c = 'TDR + Convenience';
        price3.Fee_Model__c = 'Net';
        price3.Convenience_Amount__c  = 300;
        price3.Convenience__c  = 2.5;
        price3.Convenience_Flat_Fee__c = 2.5;
        price3.TDR_Amount__c = 100;
        price3.TDR__c = 2.5;
        price3.TDR_Flat_Fee__c = 2.5;
        price3.Banking_Ops_Status__c = 'Approved';
        price3.Need_to_Publish__c = true;
        price3.Invisible__c = false;
        price3.Temp_Id_Delete_TDR__c = '1234';
        price3.Opportunity__c = opp.Id;
        listPricing.add(price3);
        
        
        insert listPricing;
        
        List<Publish_Pricing_Detail__c> publishDetails = new List<Publish_Pricing_Detail__c>();
        Publish_Pricing_Detail__c pd = new Publish_Pricing_Detail__c();
        pd.Type__c = 'TDR';
        pd.Process__c = 'SaveBulkRules-CheckerFalseActionSave';
        pd.Sync_Status__c = 'Processing';
        pd.Request_Id__c = '1234';
        pd.Checker__c = true;
        pd.Object_API_Name__c = 'Pricing__c';
        publishDetails.add(pd);
        
        
        Publish_Pricing_Detail__c pd1 = new Publish_Pricing_Detail__c();
        pd1.Type__c = 'TDR';
        pd1.Process__c = 'SaveBulkRules-CheckerTrueActionSaveFixed_Pricing1__c';
        pd1.Sync_Status__c = 'Processing';
        pd1.Request_Id__c = '12345';
        pd1.Checker__c = true;
        pd1.Object_API_Name__c = 'Fixed_Pricing1__c';
        publishDetails.add(pd1);
        
        Publish_Pricing_Detail__c pd2 = new Publish_Pricing_Detail__c();
        pd2.Type__c = 'TDR';
        pd2.Process__c = 'SaveBulkRules-CheckerFalseActionSaveFixed_Pricing1__c';
        pd2.Sync_Status__c = 'Processing';
        pd2.Request_Id__c = '123456';
        pd2.Checker__c = false;
        pd2.Object_API_Name__c = 'Fixed_Pricing1__c';
        publishDetails.add(pd2);
        
        insert publishDetails;
        
        
        Fixed_Pricing1__c fp1 = new Fixed_Pricing1__c();
        fp1.Commercial__c = comm.Id;
        fp1.Fee_Type__c = 'AMC';
        fp1.Status__c = 'Approved (Awaiting Publishing)';
        fp1.Need_to_Publish__c = true;
        fp1.Deleted__c = false;
        fp1.Start_Date__c = System.today();
        insert fp1;
        
        
        Platform_Fee__c pf = new Platform_Fee__c();
        pf.Commercial__c = comm.Id;
        pf.Amount__c = 0;
        
        insert pf;
    }
    
    @isTest
    static void testPublishPricingToTreasuryTempTable(){
        
        Test.startTest();
        List<Commercial2__c> commList = [SELECT Id FROM Commercial2__c LIMIT 1];
        Database.executeBatch(new PublishPricingToTreasuryTempTable(commList[0].Id,'SaveBulkRules-CheckerFalseActionSave',false),50);
        Set<String> setPricingWithRuleId = new Set<String>();
        List<Pricing__c> prList = new List<Pricing__c>();
        for(Pricing__c pr : [SELECT Id,Deleted__c FROM Pricing__c LIMIT 3]){
            pr.Deleted__c = true;
            prList.add(pr);
            setPricingWithRuleId.add(pr.Id);
        }
        update prList;
        
        Database.executeBatch(new PublishPricingToTreasuryTempTable(setPricingWithRuleId,'DeleteBulkRules-CheckerFalseActionDelete',true),50);  
        Test.stopTest();
    }
    
    @isTest
    static void testPublishPricingToTreasuryTempTableApprove(){
        Test.startTest();
        List<Commercial2__c> commList = [SELECT Id FROM Commercial2__c LIMIT 1];
        Database.executeBatch(new PublishPricingToTreasuryTempTableApprove(commList[0].Id,'SaveBulkRules-CheckerFalseActionSave',false),50);
        Set<String> setPricingWithRuleId = new Set<String>();
        List<Pricing__c> prList = new List<Pricing__c>();
        for(Pricing__c pr : [SELECT Id,Deleted__c FROM Pricing__c LIMIT 3]){
            pr.Deleted__c = true;
            prList.add(pr);
            setPricingWithRuleId.add(pr.Id);
        }
        update prList;
        
        Database.executeBatch(new PublishPricingToTreasuryTempTableApprove(setPricingWithRuleId,'DeleteBulkRules-CheckerFalseActionDelete',true),50);  
        Test.stopTest();
    }
    
    @isTest
    static void testPublishPricingToTreasuryTempTableReject(){
        Test.startTest();
        List<Commercial2__c> commList = [SELECT Id FROM Commercial2__c LIMIT 1];
        Database.executeBatch(new PublishPricingToTreasuryTempTableReject(commList[0].Id,'SaveBulkRules-CheckerFalseActionSave',false),50);
        Set<String> setPricingWithRuleId = new Set<String>();
        List<Pricing__c> prList = new List<Pricing__c>();
        for(Pricing__c pr : [SELECT Id,Deleted__c FROM Pricing__c LIMIT 3]){
            pr.Deleted__c = true;
            prList.add(pr);
            setPricingWithRuleId.add(pr.Id);
        }
        update prList;
        
        Database.executeBatch(new PublishPricingToTreasuryTempTableReject(setPricingWithRuleId,'DeleteBulkRules-CheckerFalseActionDelete',true),50);
        Database.executeBatch(new PublishPricingToTreasuryTempTableReject(setPricingWithRuleId,'SaveBulkRules-CheckerTrueActionRejectDelete',true),50);
        
        Test.stopTest();
    }
    
    @isTest
    static void testPricing_CheckerViewCompController(){
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<String> pricingIdList = new List<String>();
        List<Pricing__c> listPrice = new List<Pricing__c>();
        for(Pricing__c price : [SELECT Id,Temp_Id_TDR__c,Temp_Id_Conv__c FROM Pricing__c ]){
            price.Temp_Id_TDR__c = '1234';
            price.Temp_Id_Conv__c = '3453';
            listPrice.add(price);
            pricingIdList.add(price.Id);
        }
        update listPrice;
        
        List<Fixed_Pricing1__c> fixedPricingList = [SELECT Id,Commercial__c FROM Fixed_Pricing1__c LIMIT 1];
        List<String> fpIdList = new List<String>{fixedPricingList[0].Id};
         Pricing_PublishOtherPricingToTreasury obj = new Pricing_PublishOtherPricingToTreasury('Fixed_Pricing1__c',false, 'save' ,opp.Id, false);
        obj.processTheRequest();
        
        Pricing_CheckerViewCompController.getDataOnLoad(opp.Id);
        Pricing_CheckerViewCompController.getDataOnLoadDelete(opp.Id);
        Pricing_CheckerViewCompController.handleApprovePricing(pricingIdList,fpIdList);
        Pricing_CheckerViewCompController.handleRejectPricing(pricingIdList,'Test Reason',fpIdList);
        Pricing_CheckerViewCompController.handleDeleteApprovePricing(pricingIdList);
        Pricing_CheckerViewCompController.handleDeleteRejectPricing(pricingIdList,'Test Reason');
        Test.stopTest();
    }
    
    @isTest
    static void testBulkPostResponseAPI(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sendBulkPostResponse';
        
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        
        List<Pricing__c> listPricing = [SELECT Id FROM Pricing__c LIMIT 3];
        
        String responseBody = '{"userToken":"0050p000004MneAAAS","requestId":"1234","createdAt":1719309315549,"responseDtos":[{"code":"2000","message":"Success","status":0,"result":{"pricingRuleConfigId":486,"clientId":1,"subClientId":null,"entityId":10084310,"revenueModel":"Conv Fee","debitModel":"Net","amountSlab":100,"validFrom":1718630909000,"validTill":null,"fromTime":0,"tillTime":2359,"dayOfWeek":null,"frequency":null,"aggregationRequired":false,"percentFee":1.21,"flatFee":0.31,"maxCapTdrCharge":null,"minCapTdrCharge":null,"isActive":true,"approved":0,"sharedFee":0,"feeBearerEntity":null,"feeBearerEntityId":0,"attributes":[{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"mode","pricingRuleValue":"cashcard","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"ibiboCode","pricingRuleValue":"PAYZ","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"pgId","pricingRuleValue":"129","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"onus","pricingRuleValue":"on_us","operator":"=","isActive":true}],"mappingId":13867595,"addedOn":1719309315799,"updatedOn":1719309315799,"addedBy":"Prabhakar Joshi","updatedBy":null,"merchantName":null,"isAggregationRequired":null,"entityRatesId":null,"aggregationPeriod":null,"sfId":"'+listPricing[0].Id+'#Convenience","gmvSlabValue":0,"aggregatedRevenue":0,"countSlabValue":0,"attributeAggregationDetails":[],"pgMid":null,"bearerOfCharges":null,"versionNumber":3,"allowEdit":true,"source":"Salesforce","table":"main","requestedBy":"admin"}},{"code":"2000","message":"Success","status":0,"result":{"pricingRuleConfigId":487,"clientId":1,"subClientId":null,"entityId":10084310,"revenueModel":"TDR","debitModel":"Net","amountSlab":300,"validFrom":1718629103000,"validTill":null,"fromTime":0,"tillTime":2359,"dayOfWeek":null,"frequency":null,"aggregationRequired":false,"percentFee":1.21,"flatFee":2.1,"maxCapTdrCharge":null,"minCapTdrCharge":null,"isActive":true,"approved":0,"sharedFee":0,"feeBearerEntity":null,"feeBearerEntityId":0,"attributes":[{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"mode","pricingRuleValue":"creditcard","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"ibiboCode","pricingRuleValue":"RUPAYCC","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"scheme","pricingRuleValue":"RUPAY","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"pgId","pricingRuleValue":"259","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"onus","pricingRuleValue":"on_us","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"cardType","pricingRuleValue":"Corporate","operator":"=","isActive":true}],"mappingId":13867589,"addedOn":1719309315792,"updatedOn":1719309315792,"addedBy":"Prabhakar Joshi","updatedBy":null,"merchantName":null,"isAggregationRequired":null,"entityRatesId":null,"aggregationPeriod":null,"sfId":"'+listPricing[1].Id+'#TDR","gmvSlabValue":0,"aggregatedRevenue":0,"countSlabValue":0,"attributeAggregationDetails":[],"pgMid":null,"bearerOfCharges":null,"versionNumber":2,"allowEdit":true,"source":"admin","table":"main","requestedBy":"admin"}}],"action":"save"}';
        req.requestBody = Blob.valueOf(responseBody);
        RestContext.request = req;
        RestContext.response= res;
        BulkPostResponseAPI.doConsumeBulkPostAPIResponse();
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testBulkPostResponseAPI2(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sendBulkPostResponse';
        
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        
        List<Pricing__c> listPricing = [SELECT Id FROM Pricing__c LIMIT 3];
        
        String responseBody = '{"userToken":"0050p000004MneAAAS","requestId":"1234","createdAt":1719309315549,"responseDtos":[{"code":"2001","message":"edit was not allowed","status":0,"result":{"pricingRuleConfigId":486,"clientId":1,"subClientId":null,"entityId":10084310,"revenueModel":"Conv Fee","debitModel":"Net","amountSlab":100,"validFrom":1718630909000,"validTill":null,"fromTime":0,"tillTime":2359,"dayOfWeek":null,"frequency":null,"aggregationRequired":false,"percentFee":1.21,"flatFee":0.31,"maxCapTdrCharge":null,"minCapTdrCharge":null,"isActive":true,"approved":0,"sharedFee":0,"feeBearerEntity":null,"feeBearerEntityId":0,"attributes":[{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"mode","pricingRuleValue":"cashcard","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"ibiboCode","pricingRuleValue":"PAYZ","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"pgId","pricingRuleValue":"129","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"onus","pricingRuleValue":"on_us","operator":"=","isActive":true}],"mappingId":13867595,"addedOn":1719309315799,"updatedOn":1719309315799,"addedBy":"Prabhakar Joshi","updatedBy":null,"merchantName":null,"isAggregationRequired":null,"entityRatesId":null,"aggregationPeriod":null,"sfId":"'+listPricing[0].Id+'#Convenience","gmvSlabValue":0,"aggregatedRevenue":0,"countSlabValue":0,"attributeAggregationDetails":[],"pgMid":null,"bearerOfCharges":null,"versionNumber":3,"allowEdit":true,"source":"Salesforce","table":"main","requestedBy":"admin"}},{"code":"2000","message":"Success","status":0,"result":{"pricingRuleConfigId":487,"clientId":1,"subClientId":null,"entityId":10084310,"revenueModel":"TDR","debitModel":"Net","amountSlab":300,"validFrom":1718629103000,"validTill":null,"fromTime":0,"tillTime":2359,"dayOfWeek":null,"frequency":null,"aggregationRequired":false,"percentFee":1.21,"flatFee":2.1,"maxCapTdrCharge":null,"minCapTdrCharge":null,"isActive":true,"approved":0,"sharedFee":0,"feeBearerEntity":null,"feeBearerEntityId":0,"attributes":[{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"mode","pricingRuleValue":"creditcard","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"ibiboCode","pricingRuleValue":"RUPAYCC","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"scheme","pricingRuleValue":"RUPAY","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"pgId","pricingRuleValue":"259","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"onus","pricingRuleValue":"on_us","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"cardType","pricingRuleValue":"Corporate","operator":"=","isActive":true}],"mappingId":13867589,"addedOn":1719309315792,"updatedOn":1719309315792,"addedBy":"Prabhakar Joshi","updatedBy":null,"merchantName":null,"isAggregationRequired":null,"entityRatesId":null,"aggregationPeriod":null,"sfId":"'+listPricing[1].Id+'#TDR","gmvSlabValue":0,"aggregatedRevenue":0,"countSlabValue":0,"attributeAggregationDetails":[],"pgMid":null,"bearerOfCharges":null,"versionNumber":2,"allowEdit":true,"source":"admin","table":"main","requestedBy":"admin"}}],"action":"save"}';
        req.requestBody = Blob.valueOf(responseBody);
        RestContext.request = req;
        RestContext.response= res;
        BulkPostResponseAPI.doConsumeBulkPostAPIResponse();
        Test.stopTest();
    }
    
    
    
    @isTest
    static void testBulkPostResponseAPI3(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sendBulkPostResponse';
        
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        
        List<Pricing__c> listPricing = [SELECT Id FROM Pricing__c LIMIT 3];
        List<Publish_Pricing_Detail__c> publishList = [SELECT Id,Delete_Request__c,Sync_Status__c,Response_Body__c,Checker__c,Process__c 
                                                       FROM Publish_Pricing_Detail__c LIMIT 1];
        publishList[0].Delete_Request__c = true;
        publishList[0].Checker__c = true;
        publishList[0].Process__c = 'DeleteBulkRules-CheckerTrueActionReject';
        update publishList;
        
        
        String responseBody = '{"userToken":"0050p000004MneAAAS","requestId":"1234","createdAt":1719309315549,"responseDtos":[{"code":"2001","message":"edit was not allowed","status":0,"result":{"pricingRuleConfigId":486,"clientId":1,"subClientId":null,"entityId":10084310,"revenueModel":"Conv Fee","debitModel":"Net","amountSlab":100,"validFrom":1718630909000,"validTill":null,"fromTime":0,"tillTime":2359,"dayOfWeek":null,"frequency":null,"aggregationRequired":false,"percentFee":1.21,"flatFee":0.31,"maxCapTdrCharge":null,"minCapTdrCharge":null,"isActive":true,"approved":0,"sharedFee":0,"feeBearerEntity":null,"feeBearerEntityId":0,"attributes":[{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"mode","pricingRuleValue":"cashcard","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"ibiboCode","pricingRuleValue":"PAYZ","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"pgId","pricingRuleValue":"129","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"onus","pricingRuleValue":"on_us","operator":"=","isActive":true}],"mappingId":13867595,"addedOn":1719309315799,"updatedOn":1719309315799,"addedBy":"Prabhakar Joshi","updatedBy":null,"merchantName":null,"isAggregationRequired":null,"entityRatesId":null,"aggregationPeriod":null,"sfId":"'+listPricing[0].Id+'#Convenience","gmvSlabValue":0,"aggregatedRevenue":0,"countSlabValue":0,"attributeAggregationDetails":[],"pgMid":null,"bearerOfCharges":null,"versionNumber":3,"allowEdit":true,"source":"Salesforce","table":"main","requestedBy":"admin"}},{"code":"2000","message":"Success","status":0,"result":{"pricingRuleConfigId":487,"clientId":1,"subClientId":null,"entityId":10084310,"revenueModel":"TDR","debitModel":"Net","amountSlab":300,"validFrom":1718629103000,"validTill":null,"fromTime":0,"tillTime":2359,"dayOfWeek":null,"frequency":null,"aggregationRequired":false,"percentFee":1.21,"flatFee":2.1,"maxCapTdrCharge":null,"minCapTdrCharge":null,"isActive":true,"approved":0,"sharedFee":0,"feeBearerEntity":null,"feeBearerEntityId":0,"attributes":[{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"mode","pricingRuleValue":"creditcard","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"ibiboCode","pricingRuleValue":"RUPAYCC","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"scheme","pricingRuleValue":"RUPAY","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"pgId","pricingRuleValue":"259","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"onus","pricingRuleValue":"on_us","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"cardType","pricingRuleValue":"Corporate","operator":"=","isActive":true}],"mappingId":13867589,"addedOn":1719309315792,"updatedOn":1719309315792,"addedBy":"Prabhakar Joshi","updatedBy":null,"merchantName":null,"isAggregationRequired":null,"entityRatesId":null,"aggregationPeriod":null,"sfId":"'+listPricing[1].Id+'#TDR","gmvSlabValue":0,"aggregatedRevenue":0,"countSlabValue":0,"attributeAggregationDetails":[],"pgMid":null,"bearerOfCharges":null,"versionNumber":2,"allowEdit":true,"source":"admin","table":"main","requestedBy":"admin"}}],"action":"save"}';
        req.requestBody = Blob.valueOf(responseBody);
        RestContext.request = req;
        RestContext.response= res;
        BulkPostResponseAPI.doConsumeBulkPostAPIResponse();
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testBulkPostResponseAPI4(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sendBulkPostResponse';
        
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        
        List<Fixed_Pricing1__c> listPricing = [SELECT Id FROM Fixed_Pricing1__c LIMIT 1];
        
        String responseBody = '{"userToken":"0050p000004MneAAAS","requestId":"12345","createdAt":1719309315549,"responseDtos":[{"code":"2000","message":"Success","status":0,"result":{"pricingRuleConfigId":486,"clientId":1,"subClientId":null,"entityId":10084310,"revenueModel":"Conv Fee","debitModel":"Net","amountSlab":100,"validFrom":1718630909000,"validTill":null,"fromTime":0,"tillTime":2359,"dayOfWeek":null,"frequency":null,"aggregationRequired":false,"percentFee":1.21,"flatFee":0.31,"maxCapTdrCharge":null,"minCapTdrCharge":null,"isActive":true,"approved":0,"sharedFee":0,"feeBearerEntity":null,"feeBearerEntityId":0,"attributes":[{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"mode","pricingRuleValue":"cashcard","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"ibiboCode","pricingRuleValue":"PAYZ","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"pgId","pricingRuleValue":"129","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"onus","pricingRuleValue":"on_us","operator":"=","isActive":true}],"mappingId":13867595,"addedOn":1719309315799,"updatedOn":1719309315799,"addedBy":"Prabhakar Joshi","updatedBy":null,"merchantName":null,"isAggregationRequired":null,"entityRatesId":null,"aggregationPeriod":null,"sfId":"'+listPricing[0].Id+'#Convenience","gmvSlabValue":0,"aggregatedRevenue":0,"countSlabValue":0,"attributeAggregationDetails":[],"pgMid":null,"bearerOfCharges":null,"versionNumber":3,"allowEdit":true,"source":"Salesforce","table":"main","requestedBy":"admin"}}],"action":"save"}';
        req.requestBody = Blob.valueOf(responseBody);
        RestContext.request = req;
        RestContext.response= res;
        BulkPostResponseAPI.doConsumeBulkPostAPIResponse();
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testBulkPostResponseAPI5(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sendBulkPostResponse';
        
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        
        List<Fixed_Pricing1__c> listPricing = [SELECT Id FROM Fixed_Pricing1__c LIMIT 1];
        
        String responseBody = '"userToken":"0050p000004MneAAAS","requestId":"","createdAt":1719309315549,"responseDtos":[{"code":"2000","message":"Success","status":0,"result":{"pricingRuleConfigId":486,"clientId":1,"subClientId":null,"entityId":10084310,"revenueModel":"Conv Fee","debitModel":"Net","amountSlab":100,"validFrom":1718630909000,"validTill":null,"fromTime":0,"tillTime":2359,"dayOfWeek":null,"frequency":null,"aggregationRequired":false,"percentFee":1.21,"flatFee":0.31,"maxCapTdrCharge":null,"minCapTdrCharge":null,"isActive":true,"approved":0,"sharedFee":0,"feeBearerEntity":null,"feeBearerEntityId":0,"attributes":[{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"mode","pricingRuleValue":"cashcard","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"ibiboCode","pricingRuleValue":"PAYZ","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"pgId","pricingRuleValue":"129","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"onus","pricingRuleValue":"on_us","operator":"=","isActive":true}],"mappingId":13867595,"addedOn":1719309315799,"updatedOn":1719309315799,"addedBy":"Prabhakar Joshi","updatedBy":null,"merchantName":null,"isAggregationRequired":null,"entityRatesId":null,"aggregationPeriod":null,"sfId":"'+listPricing[0].Id+'#Convenience","gmvSlabValue":0,"aggregatedRevenue":0,"countSlabValue":0,"attributeAggregationDetails":[],"pgMid":null,"bearerOfCharges":null,"versionNumber":3,"allowEdit":true,"source":"Salesforce","table":"main","requestedBy":"admin"}}],"action":"save"}';
        req.requestBody = Blob.valueOf(responseBody);
        RestContext.request = req;
        RestContext.response= res;
        BulkPostResponseAPI.doConsumeBulkPostAPIResponse();
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testBulkPostResponseAPI6(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sendBulkPostResponse';
        
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        
        List<Fixed_Pricing1__c> listPricing = [SELECT Id FROM Fixed_Pricing1__c LIMIT 1];
        
        String responseBody = '{"userToken":"0050p000004MneAAAS","requestId":"123456","createdAt":1719309315549,"responseDtos":[{"code":"2000","message":"Success","status":0,"result":{"pricingRuleConfigId":486,"clientId":1,"subClientId":null,"entityId":10084310,"revenueModel":"Conv Fee","debitModel":"Net","amountSlab":100,"validFrom":1718630909000,"validTill":null,"fromTime":0,"tillTime":2359,"dayOfWeek":null,"frequency":null,"aggregationRequired":false,"percentFee":1.21,"flatFee":0.31,"maxCapTdrCharge":null,"minCapTdrCharge":null,"isActive":true,"approved":0,"sharedFee":0,"feeBearerEntity":null,"feeBearerEntityId":0,"attributes":[{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"mode","pricingRuleValue":"cashcard","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"ibiboCode","pricingRuleValue":"PAYZ","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"pgId","pricingRuleValue":"129","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"onus","pricingRuleValue":"on_us","operator":"=","isActive":true}],"mappingId":13867595,"addedOn":1719309315799,"updatedOn":1719309315799,"addedBy":"Prabhakar Joshi","updatedBy":null,"merchantName":null,"isAggregationRequired":null,"entityRatesId":null,"aggregationPeriod":null,"sfId":"'+listPricing[0].Id+'#Convenience","gmvSlabValue":0,"aggregatedRevenue":0,"countSlabValue":0,"attributeAggregationDetails":[],"pgMid":null,"bearerOfCharges":null,"versionNumber":3,"allowEdit":true,"source":"Salesforce","table":"main","requestedBy":"admin"}}],"action":"save"}';
        req.requestBody = Blob.valueOf(responseBody);
        RestContext.request = req;
        RestContext.response= res;
        BulkPostResponseAPI.doConsumeBulkPostAPIResponse();
        Test.stopTest();
        
        
    }
     @isTest
    static void testBulkPostResponseAPI7(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sendBulkPostResponse';
        
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        
        List<Fixed_Pricing1__c> listPricing = [SELECT Id FROM Fixed_Pricing1__c LIMIT 1];
        
        String responseBody = '{"userToken":"0050p000004MneAAAS","requestId":"123456","createdAt":1719309315549,"responseDtos":[{"code":"5000","message":"Edit not allowed","status":0,"result":{"pricingRuleConfigId":486,"clientId":1,"subClientId":null,"entityId":10084310,"revenueModel":"Conv Fee","debitModel":"Net","amountSlab":100,"validFrom":1718630909000,"validTill":null,"fromTime":0,"tillTime":2359,"dayOfWeek":null,"frequency":null,"aggregationRequired":false,"percentFee":1.21,"flatFee":0.31,"maxCapTdrCharge":null,"minCapTdrCharge":null,"isActive":true,"approved":0,"sharedFee":0,"feeBearerEntity":null,"feeBearerEntityId":0,"attributes":[{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"mode","pricingRuleValue":"cashcard","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"ibiboCode","pricingRuleValue":"PAYZ","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"pgId","pricingRuleValue":"129","operator":"=","isActive":true},{"pricingRuleAttributesId":null,"clientId":null,"pricingRuleConfigId":null,"pricingRuleKey":"onus","pricingRuleValue":"on_us","operator":"=","isActive":true}],"mappingId":13867595,"addedOn":1719309315799,"updatedOn":1719309315799,"addedBy":"Prabhakar Joshi","updatedBy":null,"merchantName":null,"isAggregationRequired":null,"entityRatesId":null,"aggregationPeriod":null,"sfId":"'+listPricing[0].Id+'#Convenience","gmvSlabValue":0,"aggregatedRevenue":0,"countSlabValue":0,"attributeAggregationDetails":[],"pgMid":null,"bearerOfCharges":null,"versionNumber":3,"allowEdit":true,"source":"Salesforce","table":"main","requestedBy":"admin"}}],"action":"save"}';
        req.requestBody = Blob.valueOf(responseBody);
        RestContext.request = req;
        RestContext.response= res;
        BulkPostResponseAPI.doConsumeBulkPostAPIResponse();
        Test.stopTest();
        
        
    }
}