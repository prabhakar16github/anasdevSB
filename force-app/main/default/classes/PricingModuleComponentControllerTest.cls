@isTest
public class PricingModuleComponentControllerTest {
    
    @testSetup
    public static void testDataSetup() {
        Plan_Master__c pm = new Plan_Master__c();
        pm.Name = 'Test Plan Master';
        pm.Visible_for_Template_Creation__c = true;
        insert pm;
        
        Sub_Plan_Master__c spm = new Sub_Plan_Master__c();
        spm.Name = 'Test Sub Plan Master';
        spm.Visible_for_Template_Creation__c = true;
        spm.Plan_Master__c = pm.Id;
        insert spm;
        
        Pricing_Template__c temp = new Pricing_Template__c();
        temp.Name = 'Test Template';
        temp.Sub_Plan_Master__c = spm.Id;
        insert temp;
        
        Template_Mapping__c tempMap = new Template_Mapping__c();
        tempMap.Plan__c = pm.Id;
        tempMap.Sub_Plan__c = spm.Id;
        tempMap.Template__c = temp.Id;
        insert tempMap;
        
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
        pg.Type__c = 'PostApproved';
        insert pg;
        
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
        
        List<Template_Details__c> listTempDet = new List<Template_Details__c>();
        Template_Details__c tempDet = new Template_Details__c();
        tempDet.Payment_Mode__c = pMode.Id;
        tempDet.Payment_Option__c = po.Id;
        tempDet.Pricing_Specification__c = ps.Id;
        tempDet.Payment_Gateway2__c = pg.Id;
        tempDet.Master_Pricing_Data__c = mpd.Id;
        tempDet.Fee_Model__c = 'Net';
        tempDet.Transaction_Type__c = 'TDR';
        tempDet.Template__c = temp.Id;
        listTempDet.add(tempDet);
        
        Template_Details__c tempDet1 = new Template_Details__c();
        tempDet1.Payment_Mode__c = pMode.Id;
        tempDet1.Payment_Option__c = po.Id;
        tempDet1.Pricing_Specification__c = ps.Id;
        tempDet1.Payment_Gateway2__c = pg.Id;
        tempDet1.Master_Pricing_Data__c = mpd.Id;
        tempDet1.Fee_Model__c = 'Net';
        tempDet1.Transaction_Type__c = 'TDR';
        tempDet1.Template__c = temp.Id;
        listTempDet.add(tempDet1);
        insert listTempDet;
        
        Bank_Category__c bc = new Bank_Category__c();
        bc.Name = 'Donation';
        insert bc;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Open';
        opp.Bank_Category__c = bc.Id;
        opp.CloseDate = System.today();
        opp.Prod_Merchant_Id__c = 123456;
        //opp.Aggregator_UUID__c = '11ed-e4ea-b74b48aa-929c-02e708f88ebc';
        insert opp;
        
        List<Commercial2__c> listCommercial = new List<Commercial2__c>();
        Commercial2__c comm = new Commercial2__c();
        comm.Name = 'Test Commercial';
        comm.Opportunity__c = opp.Id;
        comm.Is_Updated__c = true;
        comm.Status__c = 'Live';
        listCommercial.add(comm);
        
        Commercial2__c comm1 = new Commercial2__c();
        comm1.Name = 'Test Commercial 1';
        comm1.Opportunity__c = opp.Id;
        comm1.Is_Updated__c = true;
        comm1.Status__c = 'Draft';
        listCommercial.add(comm1);
        
        insert listCommercial;
        
        List<Pricing__c> listPricing = new List<Pricing__c>(); 
        Pricing__c price = new Pricing__c();
        price.Commercial2__c = comm.Id;
        price.Below_Rack_Rates__c = true;
        price.Master_Pricing_Data__c = mpd.Id;
        price.Payment_Gateway2__c = pg.Id;
        price.Rule_Id__c = '7119698';
        price.Opportunity__c = opp.Id;
        listPricing.add(price);
        
        Pricing__c price1 = new Pricing__c();
        price1.Commercial2__c = comm.Id;
        price1.Below_Rack_Rates__c = true;
        price1.Master_Pricing_Data__c = mpd.Id;
        price1.Payment_Gateway2__c = pg.Id;
        price1.Banking_Ops_Status__c = 'Approved';
        price1.Rule_Id_Conv__c = '7119698';
        price1.Opportunity__c = opp.Id;
        price.Deleted__c = true;
        listPricing.add(price1); 
        
        Pricing__c price3 = new Pricing__c();
        price3.Commercial2__c = comm1.Id;
        price3.Below_Rack_Rates__c = true;
        price3.Master_Pricing_Data__c = mpd.Id;
        price3.Payment_Gateway2__c = pg.Id;
        price3.Rule_Id__c = '7119698';
        price3.Opportunity__c = opp.Id;
        listPricing.add(price3);
        
        Pricing__c price4 = new Pricing__c();
        price4.Commercial2__c = comm.Id;
        price4.Below_Rack_Rates__c = true;
        price4.Master_Pricing_Data__c = mpd.Id;
        price4.Payment_Gateway2__c = pg.Id;
        price4.Banking_Ops_Status__c = 'Approved';
        price4.Rule_Id_Conv__c = '7119698';
        price4.Opportunity__c = opp.Id;
        price4.Deleted__c = true;
        listPricing.add(price4); 
        
        Pricing__c price5 = new Pricing__c();
        price5.Commercial2__c = comm.Id;
        price5.Below_Rack_Rates__c = true;
        price5.Master_Pricing_Data__c = mpd.Id;
        price5.Payment_Gateway2__c = pg.Id;
        price5.Banking_Ops_Status__c = 'Approved';
        price5.Rule_Id_Conv__c = '7119698';
        price5.Opportunity__c = opp.Id;
        price5.Deleted__c = false;
        price5.Published__c = true;
        listPricing.add(price5); 
        
        insert listPricing;
        
        Fixed_Pricing__c fp = new Fixed_Pricing__c();
        fp.Commercial2__c = comm.Id;
        insert fp;
        
        Fixed_Pricing1__c fp1 = new Fixed_Pricing1__c();
        fp1.Commercial__c = comm.Id;
        fp1.Fee_Type__c = 'AMC';
        insert fp1;
        
        Fallback_Charge__c fc = new Fallback_Charge__c();
        fc.Commercial__c = comm.Id;
        fc.Payment_Mode__c = 'BNPL';
        insert fc;
        
        Platform_Fee__c pf = new Platform_Fee__c();
        pf.Commercial__c = comm.Id;
        pf.Amount__c = 0;
        insert pf;
        
        Fallback_Payment_Mode__c fpm = new Fallback_Payment_Mode__c();
        fpm.Name = 'Test';
        insert fpm;
        
        List<Other_Product_Pricing__c> listOtherProductPricing = new List<Other_Product_Pricing__c>();
        Other_Product_Pricing__c other = new Other_Product_Pricing__c();
        other.Opportunity__c = opp.Id;
        other.RecordTypeId = OtherProductPricingComponentController.mapRecordTypeNameToId.get('Instant_Settlement');
        other.Client_Id__c = '1';
        other.Revenue_Model__c = 'instantSettlementTdr';
        other.Debit_Model__c = 'Net';
        other.Amount_Slab__c = 10;
        other.Flat_Fee__c = 2.50;
        other.Rule_Id__c ='12345';
        listOtherProductPricing.add(other);
        
        Other_Product_Pricing__c other1 = new Other_Product_Pricing__c();
        other1.Opportunity__c = opp.Id;
        other1.RecordTypeId = OtherProductPricingComponentController.mapRecordTypeNameToId.get('Offer_Engine');
        other1.Client_Id__c = '1';
        other1.Revenue_Model__c = 'offerTDR';
        other1.Debit_Model__c = 'Net';
        other1.Flat_Fee__c = 2.50;
        listOtherProductPricing.add(other1);
        
        Other_Product_Pricing__c other2 = new Other_Product_Pricing__c();
        other2.Opportunity__c = opp.Id;
        other2.RecordTypeId = OtherProductPricingComponentController.mapRecordTypeNameToId.get('Offer_Engine');
        other2.Client_Id__c = '1';
        other2.Revenue_Model__c = 'offerActivationFee';
        other2.Debit_Model__c = 'Net';
        other2.Flat_Fee__c = 2.50;
        other2.Valid_From__c = Date.newInstance(2024,11,11);
        listOtherProductPricing.add(other2);
        
        insert listOtherProductPricing;
    }
    
    @isTest
    public static void testMethod1() {
        Test.startTest();
        PricingModuleComponentController.getPlanDetailsOnLoad();
        
        List<Plan_Master__c> listPlanMaster = [SELECT Id FROM Plan_Master__c LIMIT 1];
        List<Sub_Plan_Master__c> listSubPlanMaster = [SELECT Id FROM Sub_Plan_Master__c LIMIT 1];
        PricingModuleComponentController.getSubPlanDetails(listPlanMaster[0].Id);
        
        PricingModuleComponentController.getPaymentDetails('','');
        List<Pricing_Template__c> listTemplate = [SELECT Id FROM Pricing_Template__c LIMIT 1];
        PricingModuleComponentController.getPaymentDetails(listTemplate[0].Id,'');
        
        List<Payment_Mode__c> listPaymentMode = [SELECT Id FROM Payment_Mode__c LIMIT 1];
        List<Payment_Option2__c> listPaymentOption = [SELECT Id FROM Payment_Option2__c LIMIT 1];
        PricingModuleComponentController.getSpecificationDetails(listPaymentMode[0].Id,listPaymentOption[0].Id);
        
        List<Opportunity> listOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        String selectedListPaymentData = '[{"paymentModeId":"'+listPaymentMode[0].Id+'","paymentModeName":"Test Payment Mode","selectedPaymentOptionsList":[{"key":"a2Q0p000000EetvEAC#a2R0p000000jIl2EAE#International#HdfcCYBER#ONUS","selectedPaymentIndividualList":[{"key":"a2Q0p000000EetvEAC#a2R0p000000jIl2EAE#International#HdfcCYBER#ONUS","selectedPaymentOptionName":"Test Payment Option","selectedPaymentOptionId":"'+listPaymentOption[0].Id+'","selectedSpecification":"Test Pricing Specification","selectedPaymentGatewayName":"Test Payment Gateway","selectedOnusOffus":"ONUS","isChecked":false,"listFeeModel":[{"label":"Net","value":"Net"},{"label":"Gross","value":"Gross"},{"label":"Subvention","value":"Subvention"}],"selectedFeeModel":"Net","listTransactionType":[{"label":"TDR","value":"TDR"},{"label":"Convenience","value":"Convenience"},{"label":"TDR + Convenience","value":"TDR + Convenience"}],"selectedTransactionType":"TDR","showCheckbox":true,"showTDR":true,"showConvenience":false,"tdrAmount":"1000","tdrFee":"20","tdrPercentage":"1.4","convenienceAmount":"0","convenienceFee":"","conveniencePercentage":""},{"key":"a2Q0p000000EetvEAC#a2R0p000000jIl2EAE#International#HdfcCYBER#ONUS#2","selectedPaymentOptionName":"Test Payment Option","selectedPaymentOptionId":"'+listPaymentOption[0].Id+'","selectedSpecification":"Test Pricing Specification","selectedPaymentGatewayName":"Test Payment Gateway","selectedOnusOffus":"ONUS","listFeeModel":[{"label":"Net","value":"Net"},{"label":"Gross","value":"Gross"},{"label":"Subvention","value":"Subvention"}],"listTransactionType":[{"label":"TDR","value":"TDR"},{"label":"Convenience","value":"Convenience"},{"label":"TDR + Convenience","value":"TDR + Convenience"}],"selectedFeeModel":"Gross","selectedTransactionType":"TDR","isChecked":false,"showCheckbox":false,"showTDR":true,"showConvenience":false,"tdrAmount":"2100","tdrFee":"110","tdrPercentage":"1.40","convenienceAmount":"0","convenienceFee":"","conveniencePercentage":""},{"key":"a2Q0p000000EetvEAC#a2R0p000000jIl2EAE#International#HdfcCYBER#ONUS#2","selectedPaymentOptionName":"Test Payment Option","selectedPaymentOptionId":"'+listPaymentOption[0].Id+'","selectedSpecification":"Test Pricing Specification","selectedPaymentGatewayName":"Test Payment Gateway","selectedOnusOffus":"ONUS","listFeeModel":[{"label":"Net","value":"Net"},{"label":"Gross","value":"Gross"},{"label":"Subvention","value":"Subvention"}],"listTransactionType":[{"label":"TDR","value":"TDR"},{"label":"Convenience","value":"Convenience"},{"label":"TDR + Convenience","value":"TDR + Convenience"}],"selectedFeeModel":"Gross","selectedTransactionType":"TDR","isChecked":false,"showCheckbox":false,"showTDR":true,"showConvenience":false,"tdrAmount":"2100","tdrFee":"110","tdrPercentage":"1.90","convenienceAmount":"0","convenienceFee":"","conveniencePercentage":""}]}]}]';
        PricingModuleComponentController.savePricingApex(selectedListPaymentData,listOpportunity[0].Id,'Test Commercial','','');
        
        selectedListPaymentData = '[{"paymentModeId":"'+listPaymentMode[0].Id+'","paymentModeName":"Test Payment Mode","selectedPaymentOptionsList":[{"key":"a2Q0p000000EetvEAC#a2R0p000000jIl2EAE#International#HdfcCYBER#ONUS","selectedPaymentIndividualList":[{"key":"a2Q0p000000EetvEAC#a2R0p000000jIl2EAE#International#HdfcCYBER#ONUS","selectedPaymentOptionName":"Test Payment Option","selectedPaymentOptionId":"'+listPaymentOption[0].Id+'","selectedSpecification":"Test Pricing Specification","selectedPaymentGatewayName":"Test Payment Gateway","selectedOnusOffus":"ONUS","isChecked":false,"listFeeModel":[{"label":"Net","value":"Net"},{"label":"Gross","value":"Gross"},{"label":"Subvention","value":"Subvention"}],"selectedFeeModel":"Net","listTransactionType":[{"label":"TDR","value":"TDR"},{"label":"Convenience","value":"Convenience"},{"label":"TDR + Convenience","value":"TDR + Convenience"}],"selectedTransactionType":"Convenience","showCheckbox":true,"showTDR":true,"showConvenience":false,"tdrAmount":"","tdrFee":"","tdrPercentage":"","convenienceAmount":"1000","convenienceFee":"40","conveniencePercentage":"1.5"},{"key":"a2Q0p000000EetvEAC#a2R0p000000jIl2EAE#International#HdfcCYBER#ONUS#2","selectedPaymentOptionName":"Test Payment Option","selectedPaymentOptionId":"'+listPaymentOption[0].Id+'","selectedSpecification":"Test Pricing Specification","selectedPaymentGatewayName":"Test Payment Gateway","selectedOnusOffus":"ONUS","listFeeModel":[{"label":"Net","value":"Net"},{"label":"Gross","value":"Gross"},{"label":"Subvention","value":"Subvention"}],"listTransactionType":[{"label":"TDR","value":"TDR"},{"label":"Convenience","value":"Convenience"},{"label":"TDR + Convenience","value":"TDR + Convenience"}],"selectedFeeModel":"Gross","selectedTransactionType":"Convenience","isChecked":false,"showCheckbox":false,"showTDR":true,"showConvenience":false,"tdrAmount":"","tdrFee":"","tdrPercentage":"","convenienceAmount":"2100","convenienceFee":"110","conveniencePercentage":"1.40"},{"key":"a2Q0p000000EetvEAC#a2R0p000000jIl2EAE#International#HdfcCYBER#ONUS#2","selectedPaymentOptionName":"Test Payment Option","selectedPaymentOptionId":"'+listPaymentOption[0].Id+'","selectedSpecification":"Test Pricing Specification","selectedPaymentGatewayName":"Test Payment Gateway","selectedOnusOffus":"ONUS","listFeeModel":[{"label":"Net","value":"Net"},{"label":"Gross","value":"Gross"},{"label":"Subvention","value":"Subvention"}],"listTransactionType":[{"label":"TDR","value":"TDR"},{"label":"Convenience","value":"Convenience"},{"label":"TDR + Convenience","value":"TDR + Convenience"}],"selectedFeeModel":"Gross","selectedTransactionType":"Convenience","isChecked":false,"showCheckbox":false,"showTDR":true,"showConvenience":false,"tdrAmount":"","tdrFee":"","tdrPercentage":"","convenienceAmount":"2100","convenienceFee":"110","conveniencePercentage":"1.90"}]}]}]';
        PricingModuleComponentController.savePricingApex(selectedListPaymentData,listOpportunity[0].Id,'Test Commercial',listTemplate[0].Id,'');
        
        selectedListPaymentData = '[{"paymentModeId":"'+listPaymentMode[0].Id+'","paymentModeName":"Test Payment Mode","selectedPaymentOptionsList":[{"key":"a2Q0p000000EetvEAC#a2R0p000000jIl2EAE#International#HdfcCYBER#ONUS","selectedPaymentIndividualList":[{"key":"a2Q0p000000EetvEAC#a2R0p000000jIl2EAE#International#HdfcCYBER#ONUS","selectedPaymentOptionName":"Test Payment Option","selectedPaymentOptionId":"'+listPaymentOption[0].Id+'","selectedSpecification":"Test Pricing Specification","selectedPaymentGatewayName":"Test Payment Gateway","selectedOnusOffus":"ONUS","isChecked":false,"listFeeModel":[{"label":"Net","value":"Net"},{"label":"Gross","value":"Gross"},{"label":"Subvention","value":"Subvention"}],"selectedFeeModel":"Net","listTransactionType":[{"label":"TDR","value":"TDR"},{"label":"Convenience","value":"Convenience"},{"label":"TDR + Convenience","value":"TDR + Convenience"}],"selectedTransactionType":"TDR + Convenience","showCheckbox":true,"showTDR":true,"showConvenience":false,"tdrAmount":"1000","tdrFee":"40","tdrPercentage":"1.5","convenienceAmount":"1000","convenienceFee":"40","conveniencePercentage":"1.5"},{"key":"a2Q0p000000EetvEAC#a2R0p000000jIl2EAE#International#HdfcCYBER#ONUS#2","selectedPaymentOptionName":"Test Payment Option","selectedPaymentOptionId":"'+listPaymentOption[0].Id+'","selectedSpecification":"Test Pricing Specification","selectedPaymentGatewayName":"Test Payment Gateway","selectedOnusOffus":"ONUS","listFeeModel":[{"label":"Net","value":"Net"},{"label":"Gross","value":"Gross"},{"label":"Subvention","value":"Subvention"}],"listTransactionType":[{"label":"TDR","value":"TDR"},{"label":"Convenience","value":"Convenience"},{"label":"TDR + Convenience","value":"TDR + Convenience"}],"selectedFeeModel":"Gross","selectedTransactionType":"TDR + Convenience","isChecked":false,"showCheckbox":false,"showTDR":true,"showConvenience":false,"tdrAmount":"2100","tdrFee":"110","tdrPercentage":"1.40","convenienceAmount":"2100","convenienceFee":"110","conveniencePercentage":"1.40"},{"key":"a2Q0p000000EetvEAC#a2R0p000000jIl2EAE#International#HdfcCYBER#ONUS#2","selectedPaymentOptionName":"Test Payment Option","selectedPaymentOptionId":"'+listPaymentOption[0].Id+'","selectedSpecification":"Test Pricing Specification","selectedPaymentGatewayName":"Test Payment Gateway","selectedOnusOffus":"ONUS","listFeeModel":[{"label":"Net","value":"Net"},{"label":"Gross","value":"Gross"},{"label":"Subvention","value":"Subvention"}],"listTransactionType":[{"label":"TDR","value":"TDR"},{"label":"Convenience","value":"Convenience"},{"label":"TDR + Convenience","value":"TDR + Convenience"}],"selectedFeeModel":"Gross","selectedTransactionType":"TDR + Convenience","isChecked":false,"showCheckbox":false,"showTDR":true,"showConvenience":false,"tdrAmount":"2100","tdrFee":"110","tdrPercentage":"1.90","convenienceAmount":"2100","convenienceFee":"110","conveniencePercentage":"1.90"}]}]}]';
        //PricingModuleComponentController.savePricingApex(selectedListPaymentData,listOpportunity[0].Id,'Test Commercial',listTemplate[0].Id,'');
        
        PricingModuleComponentController.SelectedPaymentData obj1 = new PricingModuleComponentController.SelectedPaymentData();
        PricingModuleComponentController.SelectedPaymentOptions obj2 = new PricingModuleComponentController.SelectedPaymentOptions();
        PricingModuleComponentController.SelectedPaymentDataSingleRecord obj3 = new PricingModuleComponentController.SelectedPaymentDataSingleRecord();
        
        List<Commercial2__c> listCommercial = [SELECT Id,Name FROM Commercial2__c LIMIT 1];
        PricingModuleComponentController.savePricingApex(selectedListPaymentData,listOpportunity[0].Id,'Test Commercial','',listCommercial[0].Id);
        PricingModuleComponentController.getPaymentGatewayData(listPaymentMode[0].Id,listPaymentOption[0].Id,new List<String>{'Test Pricing Specification'});
        PricingModuleComponentController.BelowRackRatesRecordsWrapper wrpCls = PricingModuleComponentController.getBelowRackRatesRecords(listCommercial[0].Id);
        PricingModuleComponentController.updateBelowRackRatesRecords(listCommercial[0].Id,JSON.serialize(wrpCls.listBelowRackRateRecords),wrpCls.listPricingIds);
        PricingModuleComponentController.getSendToBHRecords(listCommercial[0].Id);
        
        List<Pricing__c> listPricing = [SELECT Id,Fee_Model__c FROM Pricing__c LIMIT 1];
        List<String> listPricingIds = new List<String>();
        listPricingIds.add(listPricing[0].Id);
        String listFixedPricing = '[{"key":1,"amcFee":"3","amcInterval":"4","setupFee":"1","securityDeposit":"2"}]';
        PricingModuleComponentController.sendToBHEmail(listCommercial[0].Id,'Test Body','Test Subject',listPricingIds);
        PricingModuleComponentController.getCommercialInformationBeforeValidatePricing(listCommercial[0].Id);
        String message = PricingModuleComponentController.createTemplateForOrdinaryUser('Test Template',selectedListPaymentData,listFixedPricing,listCommercial[0].Id);
        String message1 = PricingModuleComponentController.createTemplateForOrdinaryUser(listTemplate[0].Id,selectedListPaymentData,listFixedPricing,listCommercial[0].Id);
        PricingModuleComponentController.getPrivateTemplateDetails();
        PricingModuleComponentController.getTemplateDetails(listPlanMaster[0].Id, listSubPlanMaster[0].Id);
        PricingModuleComponentController.createTemplateForSuperUser(listTemplate[0].Id,selectedListPaymentData,listFixedPricing,listCommercial[0].Id,false,'','','option1');
        PricingModuleComponentController.createTemplateForSuperUser('Test Template',selectedListPaymentData,listFixedPricing,listCommercial[0].Id,true,listPlanMaster[0].Id,listSubPlanMaster[0].Id,'option2');
        PricingModuleComponentController.createTemplateForSuperUser(listTemplate[0].Id,selectedListPaymentData,listFixedPricing,listCommercial[0].Id,true,'Test Plan','Test Sub Plan','option3');
        PricingModuleComponentController.createTemplateForSuperUser('Test Template',selectedListPaymentData,listFixedPricing,listCommercial[0].Id,true,'Test Plan','Test Sub Plan','option4');
        PricingModuleComponentController.getPlanAndSubPlanDetails();
        //PricingModuleComponentController.getPublicCheckboxForTemplate(listTemplate[0].Id);
        //PricingModuleComponentController.getLiveDetailsFromTreasury(listOpportunity[0].Id);
        listPricing[0].Fee_Model__c = 'Gross';
        update listPricing;
        Test.stopTest();
    }
    
    @isTest
    public static void testMethod2() {
        test.startTest();
        List<Opportunity> listOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        List<Commercial2__c> listCommercial = [SELECT Id FROM Commercial2__c WHERE Status__c = 'Draft'];
        List<Plan_Master__c> listPlanMaster = [SELECT Id FROM Plan_Master__c LIMIT 1];
        List<Sub_Plan_Master__c> listSubPlanMaster = [SELECT Id FROM Sub_Plan_Master__c LIMIT 1];
        PricingModuleComponentController.getLiveDetailsFromTreasury(listOpportunity[0].Id);
        String listFixedPricing = '[{"key":1,"amcFee":"3","amcInterval":"4","setupFee":"1","securityDeposit":"2"}]';
        List<Platform_Fee__c> listPlatformFeeExisiting = [SELECT Id FROM Platform_Fee__c LIMIT 1];
        String listPlatformFee = '[{"showRemoveButton":false,"percentage":"2","Id":"'+listPlatformFeeExisiting[0].Id+'","flatFee":"1","disabledAmount":true,"backgroundColor":"background-color:white;","amount":"0.00"},{"Id":"","amount":"500","flatFee":"3","percentage":"4","showRemoveButton":true,"disabledAmount":false,"backgroundColor":"background-color:white;"}]';
        List<Fallback_Charge__c> listFallbackChargesExisting = [SELECT Id FROM Fallback_Charge__c LIMIT 1];
        List<Fixed_Pricing1__c> listFixedPricing2Existing = [SELECT Id FROM Fixed_Pricing1__c LIMIT 1];
        String listFallbackCharges = '[{"percentage":"2","paymentModeName":"BNPL","Id":"'+listFallbackChargesExisting[0].Id+'","flatFee":"1"}]';
        String listFixedPricing2 = '[{"startDate":"2023-10-05","showDeleteButton":false,"recordId":"","percentage":"","paymentFrequency":"Quarterly","flatFeeType":"Setup Fee","flatFee":"10.00","endDate":"2023-10-31","debitModel":"Net","amount":""},{"startDate":"2023-10-31","showDeleteButton":false,"recordId":"","percentage":"","paymentFrequency":"Daily","flatFeeType":"Security Deposit","flatFee":"20.00","endDate":"2023-10-25","debitModel":"Net","amount":""},{"startDate":"2023-10-26","showDeleteButton":false,"recordId":"'+listFixedPricing2Existing[0].Id+'","percentage":"","paymentFrequency":"Weekly","flatFeeType":"AMC","flatFee":"30.00","endDate":"2023-10-26","debitModel":"Gross","amount":""}]';
        PricingModuleComponentController.insertFixedPricingAndPublishCommercial(listCommercial[0].Id,listFixedPricing,listPlatformFee,listFallbackCharges,'GMV','Daily','2023-09-1','2023-09-30','Gross',listFixedPricing2);
        List<Pricing_Template__c> listTemplate = [SELECT Id FROM Pricing_Template__c LIMIT 1];
        PricingModuleComponentController.getPublicCheckboxForTemplate(listTemplate[0].Id);
        PricingModuleComponentController.getPrivateTemplateDetailsForPlanAndSubPlan(listPlanMaster[0].Id,listSubPlanMaster[0].Id);
        PricingModuleComponentController.getSubPlanDetailsForSelectedPlan(listPlanMaster[0].Id);
        PricingModuleComponentController.getModalInformation(listCommercial[0].Id);
        test.stopTest();
    }
    
    @isTest
    public static void testMethod3() {
        test.startTest();
        List<Master_Pricing_Data__c> listMasterPricingData = [SELECT Id,Active_Instrument__c FROM Master_Pricing_Data__c LIMIT 1];
        MasterPricingDataComponentController.getMasterPricingDataInfo(listMasterPricingData[0].Id);        
        MasterPricingDataComponentController.updateData(listMasterPricingData[0].Id,true); 
        
        listMasterPricingData[0].Active_Instrument__c = false;
        update listMasterPricingData;  
        
        MasterPricingDataComponentController.getMasterPricingDataInfo(listMasterPricingData[0].Id);        
        MasterPricingDataComponentController.updateData(listMasterPricingData[0].Id,false);         
        test.stopTest();
    }
    
    @isTest
    public static void testMethod4() {
        test.startTest();
        List<Commercial2__c> listCommercial = [SELECT Id,Name FROM Commercial2__c LIMIT 1];
        List<Opportunity> listOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        List<Pricing__c> listPricing = [SELECT Id FROM Pricing__c LIMIT 1];
        String listFixedPricing = '[{"key":1,"amcFee":"3","amcInterval":"4","setupFee":"1","securityDeposit":"2"}]';
        List<Platform_Fee__c> listPlatformFeeExisiting = [SELECT Id FROM Platform_Fee__c LIMIT 1];
        String listPlatformFee = '[{"showRemoveButton":false,"percentage":"2","Id":"'+listPlatformFeeExisiting[0].Id+'","flatFee":"1","disabledAmount":true,"backgroundColor":"background-color:white;","amount":"0.00"},{"Id":"","amount":"500","flatFee":"3","percentage":"4","showRemoveButton":true,"disabledAmount":false,"backgroundColor":"background-color:white;"}]';
        List<Fallback_Charge__c> listFallbackChargesExisting = [SELECT Id FROM Fallback_Charge__c LIMIT 1];
        String listFallbackCharges = '[{"percentage":"2","paymentModeName":"BNPL","Id":"'+listFallbackChargesExisting[0].Id+'","flatFee":"1"}]';
        List<Fixed_Pricing1__c> listFixedPricing2Existing = [SELECT Id FROM Fixed_Pricing1__c LIMIT 1];
        String listFixedPricing2 = '[{"startDate":"2023-10-05","showDeleteButton":false,"recordId":"","percentage":"","paymentFrequency":"Quarterly","flatFeeType":"Setup Fee","flatFee":"10.00","endDate":"2023-10-31","debitModel":"Net","amount":""},{"startDate":"2023-10-31","showDeleteButton":false,"recordId":"","percentage":"","paymentFrequency":"Daily","flatFeeType":"Security Deposit","flatFee":"20.00","endDate":"2023-10-25","debitModel":"Net","amount":""},{"startDate":"2023-10-26","showDeleteButton":false,"recordId":"'+listFixedPricing2Existing[0].Id+'","percentage":"","paymentFrequency":"Weekly","flatFeeType":"AMC","flatFee":"30.00","endDate":"2023-10-26","debitModel":"Gross","amount":""}]';
        PricingModuleComponentController.FixedPricing obj4 = new PricingModuleComponentController.FixedPricing();
        PricingModuleComponentController.insertFixedPricingAndPublishCommercial(listCommercial[0].Id,listFixedPricing,listPlatformFee,listFallbackCharges,'GMV','Daily','2023-09-1','2023-09-30','Gross',listFixedPricing2);
        
        PricingModuleComponentController.getPaymentDetails('',listCommercial[0].Id);
        PricingModuleComponentController.existingCommercial(listOpportunity[0].Id);
        PricingModuleComponentController.getPricingRecordsForCommercial(listCommercial[0].Id,listCommercial[0].Name);
        PricingModuleComponentController.getAuditTrailRecordsForCommercial(listCommercial[0].Id);
        PricingModuleComponentController.getPricingData(listPricing[0].Id);
        PricingModuleComponentController.getOverallAuditTrail(listOpportunity[0].Id);
        PricingModuleComponentController.getOverallAuditForStackTrail(listOpportunity[0].Id);
        test.stopTest();
    }
    
    @isTest
    public static void testMethod5() {
        Test.startTest();
        List<Opportunity> listOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        OtherProductPricingComponentController.getDetailsOnLoad(listOpportunity[0].Id,'Instant_Settlement');
        List<Other_Product_Pricing__c> listCommercial = [SELECT Id,Rule_Id__c,Published__c FROM Other_Product_Pricing__c LIMIT 1];
        OtherProductPricingComponentController.getCommercialDetails(listCommercial[0].Id);
        String commercialObj = '{"amountSlab":"10.00","flatFee":"2.50","fromTime":"09:30:00.000Z","listDaysOfTheWeek":[{"label":"--None--","value":""},{"label":"Monday","value":"Monday"},{"label":"Tuesday","value":"Tuesday"},{"label":"Wednesday","value":"Wednesday"},{"label":"Thursday","value":"Thursday"},{"label":"Friday","value":"Friday"},{"label":"Saturday","value":"Saturday"},{"label":"Sunday","value":"Sunday"}],"listDebitModel":[{"label":"Net","value":"Net"},{"label":"Gross","value":"Gross"},{"label":"Subvention","value":"Subvention"}],"message":"SUCCESS","percentage":"1.25000","recordId":"","selectedDayOfTheWeek":"Tuesday","selectedDebitModel":"Net","tillTime":"21:30:00.000Z","validFrom":"2023-07-01","validFromTime":"00:15:00.000Z","validTill":"2023-07-31","validTillTime":"23:30:00.000Z"}';
        OtherProductPricingComponentController.saveCommercialChanges(listOpportunity[0].Id,commercialObj);
        commercialObj = '{"amountSlab":"10.00","flatFee":"2.50","fromTime":"09:30:00.000Z","listDaysOfTheWeek":[{"label":"--None--","value":""},{"label":"Monday","value":"Monday"},{"label":"Tuesday","value":"Tuesday"},{"label":"Wednesday","value":"Wednesday"},{"label":"Thursday","value":"Thursday"},{"label":"Friday","value":"Friday"},{"label":"Saturday","value":"Saturday"},{"label":"Sunday","value":"Sunday"}],"listDebitModel":[{"label":"Net","value":"Net"},{"label":"Gross","value":"Gross"},{"label":"Subvention","value":"Subvention"}],"message":"SUCCESS","percentage":"1.25000","recordId":"'+listCommercial[0].Id+'","selectedDayOfTheWeek":"Friday","selectedDebitModel":"Net","tillTime":"21:30:00.000Z","validFrom":"2023-07-01","validFromTime":"00:15:00.000Z","validTill":"2023-07-31","validTillTime":"23:30:00.000Z"}';
        listCommercial[0].Rule_Id__c = '1234';
        listCommercial[0].Published__c = true;
        update listCommercial;
        OtherProductPricingComponentController.saveCommercialChanges(listOpportunity[0].Id,commercialObj);
        OtherProductPricingComponentController.publishCommercial(listOpportunity[0].Id,'Instant_Settlement');
        OtherProductPricingComponentController.deleteCommercial(listCommercial[0].Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testMethod6() {
        Test.startTest();
        List<Opportunity> listOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        List<Other_Product_Pricing__c> listCommercial = [SELECT Id,Rule_Id__c FROM Other_Product_Pricing__c WHERE Opportunity__c = :listOpportunity[0].Id AND Revenue_Model__c = 'offerActivationFee' ];
        OtherProductPricingComponentController.getExistingOfferEngineCommercial(listOpportunity[0].Id,'Offer_Engine','offerActivationFee');
        String commercialObj = '{"amountSlab":"","flatFee":"2.50","fromTime":"","listDaysOfTheWeek":[{"label":"--None--","value":""},{"label":"Monday","value":"Monday"},{"label":"Tuesday","value":"Tuesday"},{"label":"Wednesday","value":"Wednesday"},{"label":"Thursday","value":"Thursday"},{"label":"Friday","value":"Friday"},{"label":"Saturday","value":"Saturday"},{"label":"Sunday","value":"Sunday"}],"listDebitModel":[{"label":"Net","value":"Net"},{"label":"Gross","value":"Gross"},{"label":"Subvention","value":"Subvention"}],"message":"SUCCESS","percentage":"","recordId":"","selectedDayOfTheWeek":"","selectedDebitModel":"Net","tillTime":"","validFrom":"2043-07-01","validFromTime":"","validTill":"","validTillTime":""}';
        OtherProductPricingComponentController.saveCommercialChangesOfferEngine(listOpportunity[0].Id,commercialObj,'offerActivationFee');
        commercialObj = '{"amountSlab":"","flatFee":"2.50","fromTime":"","listDaysOfTheWeek":[{"label":"--None--","value":""},{"label":"Monday","value":"Monday"},{"label":"Tuesday","value":"Tuesday"},{"label":"Wednesday","value":"Wednesday"},{"label":"Thursday","value":"Thursday"},{"label":"Friday","value":"Friday"},{"label":"Saturday","value":"Saturday"},{"label":"Sunday","value":"Sunday"}],"listDebitModel":[{"label":"Net","value":"Net"},{"label":"Gross","value":"Gross"},{"label":"Subvention","value":"Subvention"}],"message":"SUCCESS","percentage":"","recordId":"'+listCommercial[0].Id+'","selectedDayOfTheWeek":"","selectedDebitModel":"Net","tillTime":"","validFrom":"2053-07-01","validFromTime":"","validTill":"","validTillTime":""}';
        OtherProductPricingComponentController.saveCommercialChangesOfferEngine(listOpportunity[0].Id,commercialObj,'offerActivationFee');
        OtherProductPricingComponentController.getPublishedInformation(listOpportunity[0].Id,'Offer_Engine','offerActivationFee');
        Test.stopTest();
    }
    // added by rohit
     @isTest
    public static void testMethod7() {
        Test.startTest();
        List<Opportunity> listOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        List<Other_Product_Pricing__c> listCommercial = [SELECT Id,Rule_Id__c,Percent_Fee__c FROM Other_Product_Pricing__c WHERE Opportunity__c = :listOpportunity[0].Id AND Revenue_Model__c = 'offerActivationFee' ];
        String commercialObj = '{"amountSlab":"10","flatFee":"2.50","fromTime":"","listDaysOfTheWeek":[{"label":"--None--","value":""},{"label":"Monday","value":"Monday"},{"label":"Tuesday","value":"Tuesday"},{"label":"Wednesday","value":"Wednesday"},{"label":"Thursday","value":"Thursday"},{"label":"Friday","value":"Friday"},{"label":"Saturday","value":"Saturday"},{"label":"Sunday","value":"Sunday"}],"listDebitModel":[{"label":"Net","value":"Net"},{"label":"Gross","value":"Gross"},{"label":"Subvention","value":"Subvention"}],"message":"SUCCESS","percentage":"","recordId":"","selectedDayOfTheWeek":"","selectedDebitModel":"Net","tillTime":"","validFrom":"2043-07-01","validFromTime":"","validTill":"","validTillTime":""}';
        OtherProductPricingComponentController.saveCommercialChangesOfferEngine(listOpportunity[0].Id,commercialObj,'offerActivationFee');
        commercialObj = '{"amountSlab":"10","flatFee":"2.10","fromTime":"","listDaysOfTheWeek":[{"label":"--None--","value":""},{"label":"Monday","value":"Monday"},{"label":"Tuesday","value":"Tuesday"},{"label":"Wednesday","value":"Wednesday"},{"label":"Thursday","value":"Thursday"},{"label":"Friday","value":"Friday"},{"label":"Saturday","value":"Saturday"},{"label":"Sunday","value":"Sunday"}],"listDebitModel":[{"label":"Net","value":"Net"},{"label":"Gross","value":"Gross"},{"label":"Subvention","value":"Subvention"}],"message":"SUCCESS","percentage":"","recordId":"'+listCommercial[0].Id+'","selectedDayOfTheWeek":"","selectedDebitModel":"Net","tillTime":"","validFrom":"2053-07-01","validFromTime":"","validTill":"","validTillTime":""}';
        OtherProductPricingComponentController.saveCommercialChangesForCheckOut(String.valueOf(listOpportunity[0].Id),commercialObj);
        Test.stopTest();
    }
    // added by rohit
      @isTest
    public static void testMethod8() {
        Test.startTest();
        List<Opportunity> listOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        List<Other_Product_Pricing__c> listCommercial = [SELECT Id,Rule_Id__c,Percent_Fee__c FROM Other_Product_Pricing__c WHERE Opportunity__c = :listOpportunity[0].Id AND Revenue_Model__c = 'offerActivationFee' ];
        String commercialObj = '{"amountSlab":"10","flatFee":"2.50","fromTime":"","listDaysOfTheWeek":[{"label":"--None--","value":""},{"label":"Monday","value":"Monday"},{"label":"Tuesday","value":"Tuesday"},{"label":"Wednesday","value":"Wednesday"},{"label":"Thursday","value":"Thursday"},{"label":"Friday","value":"Friday"},{"label":"Saturday","value":"Saturday"},{"label":"Sunday","value":"Sunday"}],"listDebitModel":[{"label":"Net","value":"Net"},{"label":"Gross","value":"Gross"},{"label":"Subvention","value":"Subvention"}],"message":"SUCCESS","percentage":"","recordId":"","selectedDayOfTheWeek":"","selectedDebitModel":"Net","tillTime":"","validFrom":"2043-07-01","validFromTime":"","validTill":"","validTillTime":""}';
        OtherProductPricingComponentController.saveCommercialChangesOfferEngine(listOpportunity[0].Id,commercialObj,'offerActivationFee');
        OtherProductPricingComponentController.saveCommercialChangesForCheckOut(String.valueOf(listOpportunity[0].Id),commercialObj);
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateCommercialsForExistingMerchant() {
        Test.startTest();
        Database.executeBatch(new CreateCommercialsForExistingMerchant(),2000);
        Test.stopTest();
    }
    
}