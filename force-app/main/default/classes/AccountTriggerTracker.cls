@isTest
public class AccountTriggerTracker{  
    
    @testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Account', true);
        insert triggerSwitchObj ;  
        
        Trigger_Switch__c triggerSwitchObj1 = CommonDataTracker.insertTriggerSwitch('Contract', true);
        insert triggerSwitchObj1 ;  

        Trigger_Switch__c triggerSwitchObj2 = CommonDataTracker.insertTriggerSwitch('Merchant_Document__c', true);
        insert triggerSwitchObj2 ;  

        Trigger_Switch__c triggerSwitchObj4 = CommonDataTracker.insertTriggerSwitch('Opportunity', true);
        insert triggerSwitchObj4 ;
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Individual');
        entityObj.Total_Required_Documents__c = 3;
        insert entityObj;
        System.assertEquals('Individual', [SELECT Id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);      
        
        Entity__c entitySocialObj = CommonDataTracker.insertEntity('Social');
        entitySocialObj.Total_Required_Documents__c = 6;
        insert entitySocialObj;
        System.assertEquals('Social', [SELECT Id, Name FROM Entity__c WHERE Id =: entitySocialObj.id].Name); 
        
        Business_Category__c businessCategoryNGO = CommonDataTracker.insertBusinessCategory('NGO', true);
        businessCategoryNGO.Doable__c = true;
        businessCategoryNGO.Categories_For__c = 'Merchant';
        insert businessCategoryNGO ;
        System.assertEquals('NGO', [SELECT Id, name FROM Business_Category__c WHERE id =: businessCategoryNGO.id].Name);
        
        Sub_Category__c subCategoryInd = CommonDataTracker.insertSubCategory('Individual', false);
        subCategoryInd.Category__c = businessCategoryNGO.Id;
        subCategoryInd.Delivery_duration__c = 5;
        insert subCategoryInd ;
        System.assertEquals('Individual', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryInd.id].Name);
        
        Sub_Category__c subCategoryBooks = CommonDataTracker.insertSubCategory('Books', true);
        subCategoryBooks.Category__c = businessCategoryNGO.Id;
        subCategoryBooks.Delivery_duration__c = 5;
        insert subCategoryBooks ;
        System.assertEquals('Books', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryBooks.id].Name);
        
        Document_Category_Master__c docCategoryAddressObj =  CommonDataTracker.insertDocCategoryMaster('Address Proof of Signing Authority');
        
        Document_Category_Master__c docCategoryPanObj =  CommonDataTracker.insertDocCategoryMaster('PAN Card of Signing Authority');
        
        Document_Category_Master__c docCategoryBankObj =  CommonDataTracker.insertDocCategoryMaster('Bank Account Proof');
        
        List<Document_Category_Master__c> docCategList = new List<Document_Category_Master__c>{docCategoryAddressObj,docCategoryPanObj,docCategoryBankObj};
            insert docCategList; 
        System.assertEquals('Address Proof of Signing Authority', [SELECT Id, Name FROM Document_Category_Master__c WHERE Id =: docCategoryAddressObj.Id].Name);
        System.assertEquals('PAN Card of Signing Authority', [SELECT Id, Name FROM Document_Category_Master__c WHERE Id =: docCategoryPanObj.Id].Name);  
        System.assertEquals('Bank Account Proof', [SELECT Id, Name FROM Document_Category_Master__c WHERE Id =: docCategoryBankObj.Id].Name);  
        
        Document_Type_Master__c docTypeObj = CommonDataTracker.insertDcoTypeMaster('Agreement');
        insert docTypeObj;
        
        Id addendumRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Merchant Document').getRecordTypeId();
        Id docMasterRecId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Merchant Document').getRecordTypeId();
        Id agreementRecId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Agreement').getRecordTypeId();
      
        Document_Master__c docMasterPan = CommonDataTracker.insertDocumentMaster('Pan',docCategoryPanObj,docMasterRecId,'');
        docMasterPan.Document_For__c = 'Merchant';
        docMasterPan.Entity__c = entityObj.Id;
        
        Document_Master__c docMasterAddress = CommonDataTracker.insertDocumentMaster('Address',docCategoryAddressObj,docMasterRecId,'');
        docMasterAddress.Document_For__c = 'Merchant';
        docMasterAddress.Document_Category__c = docCategoryAddressObj.Id;
        docMasterAddress.Entity__c = entityObj.Id;
        
        Document_Master__c docMasterBank = CommonDataTracker.insertDocumentMaster('Bank',docCategoryBankObj,docMasterRecId,'');
        docMasterBank.Document_For__c = 'Merchant';
        docMasterBank.Entity__c = entityObj.Id;
        
        Document_Master__c docMasterAgreement = CommonDataTracker.insertDocumentMaster('Agreement',docCategoryBankObj,agreementRecId,'ServiceAgreementMoney');
        docMasterAgreement.Document_For__c = 'Merchant';
        docMasterAgreement.Document_Type__c = docTypeObj.Id;
        docMasterAgreement.Entity__c = entityObj.Id;
        
        List<Document_Master__c> docMasterList = new List<Document_Master__c>{docMasterPan,docMasterAddress,docMasterBank,docMasterAgreement};
            insert docMasterList;
        System.assertEquals(docCategoryAddressObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterAddress.Id].Document_Category__c);
        System.assertEquals(docCategoryBankObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterBank.Id].Document_Category__c);
        System.assertEquals(docCategoryPanObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterPan.Id].Document_Category__c);
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Money');
        insert platformObj;
        System.assertEquals('PayU Money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass()); 
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        accountObj.Delivery_Duration__c = 9;
        accountObj.Monthly_Expected_Sale__c = 5.0;
        accountObj.Transaction_Facility_Required__c = 'Domestic';
        accountObj.Business_Category__c = businessCategoryNGO.Id;
        accountObj.Type__c = 'Merchant';
        accountObj.LOB_Status__c = 'Pending';
        accountObj.Sub_Category__c = subCategoryBooks.Id; 
        accountObj.Merchant_Business_Type__c = 'LongTail';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: accountObj.Id].PAN_Number__c);
        
        Account accountPartnerObj = CommonDataTracker.insertAccount('Test Account 2', 'LegalName87686823', 'GKMUT4212Y');
        accountPartnerObj.Business_Entity__c =  entityObj.Id;
        accountPartnerObj.Identifier__c = '98673223239089887';
        accountPartnerObj.Delivery_Duration__c = 9;
        accountPartnerObj.Monthly_Expected_Sale__c = 5.0;
        accountPartnerObj.Transaction_Facility_Required__c = 'Domestic';
        accountPartnerObj.Business_Category__c = businessCategoryNGO.Id;
        accountPartnerObj.Type__c = 'Partner';
        accountPartnerObj.LOB_Status__c = 'Pending';
        accountPartnerObj.Sub_Category__c = subCategoryBooks.Id;
        insert accountPartnerObj;
        System.assertEquals('GKMUT4212Y', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: accountPartnerObj.Id].PAN_Number__c);
        
        Account accountAggregatorObj = CommonDataTracker.insertAccount('Test Account 3', 'LegalName8732686823', 'AMMUT4212Y');
        accountAggregatorObj.Business_Entity__c =  entityObj.Id;
        accountAggregatorObj.Identifier__c = '98673223239089887';
        accountAggregatorObj.Delivery_Duration__c = 9;
        accountAggregatorObj.Monthly_Expected_Sale__c = 5.0;
        accountAggregatorObj.Transaction_Facility_Required__c = 'Domestic';
        accountAggregatorObj.Business_Category__c = businessCategoryNGO.Id;
        accountAggregatorObj.Type__c = 'Merchant';
        accountAggregatorObj.LOB_Status__c = 'Pending';
        accountAggregatorObj.Merchant_Business_Type__c = 'LongTail';
        insert accountAggregatorObj;
        System.assertEquals('AMMUT4212Y', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: accountAggregatorObj.Id].PAN_Number__c);
        
        Client_Name__c clnm= new Client_Name__c ();
        clnm.Name='Axis Bank';
        clnm.Country__c='India';
        clnm.Region__c='India';
        insert clnm;
        
        Account accountwibmo = CommonDataTracker.insertAccount('Test Account 4', 'LegalName8732686823', 'AMMUT4312Y');
        accountwibmo.Business_Entity__c =  entityObj.Id;
        accountwibmo.Identifier__c = '98673223239089887';
        accountwibmo.Delivery_Duration__c = 9;
        accountwibmo.Monthly_Expected_Sale__c = 5.0;
        accountwibmo.Transaction_Facility_Required__c = 'Domestic';
        accountwibmo.Business_Category__c = businessCategoryNGO.Id;
        accountwibmo.Type__c = 'Wibmo';
        accountwibmo.LOB_Status__c = 'Pending';
        accountwibmo.Client_Name_New__c=clnm.id; 
        insert accountwibmo;
        System.assertEquals('AMMUT4212Y', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: accountAggregatorObj.Id].PAN_Number__c);

        
        Contact contactObj = CommonDataTracker.insertContact(accountObj);
        insert contactObj;
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj.BusinessCategory__c = businessCategoryNGO.id;
        opportunityObj.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj.Delivery_Duration__c = 90;
        opportunityObj.AccountId = accountObj.Id;
        opportunityObj.Prod_Merchant_Id__c = 23424234;
        opportunityObj.Website_Status__c = 'Website OK';
        opportunityObj.Bank_Verification_Status__c = 'Success';
        opportunityObj.MAF_Status__c = 'Received';
        opportunityObj.Website__c = 'www.google.com';
        opportunityObj.Settlement_Status__c = 'Active';
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        user userObj = CommonDataTracker.insertUser(profileId);
        userObj.username = 'newUser1@yah.com';
        insert userObj;
        system.assertNotEquals(userObj.Id, null);
        
        user userObj1 = CommonDataTracker.insertUser(profileId);
        userObj1.username = 'newUser2@yah.com';
        insert userObj1;
        system.assertNotEquals(userObj1.Id, null);
        
        AccountTeamMember actm = new AccountTeamMember(AccountId = accountObj.Id, TeamMemberRole = 'Risk User', AccountAccessLevel  = 'Edit', UserId = leadConversionUser.Id);
        insert actm;
        //system.assertEquals(accountObj.Id, [SELECT UserId, AccountId, TeamMemberRole FROM AccountTeamMember LIMIT 1].AccountId);
        
        AccountTeamMember actm1 = new AccountTeamMember(AccountId = accountObj.Id, TeamMemberRole = 'Onboarding User', AccountAccessLevel  = 'Edit', UserId = userObj.Id);
        insert actm1;
        //system.assertEquals(accountObj.Id, [SELECT UserId, AccountId, TeamMemberRole FROM AccountTeamMember LIMIT 1].AccountId);
        
        AccountTeamMember actm2 = new AccountTeamMember(AccountId = accountObj.Id, TeamMemberRole = 'Banking User', AccountAccessLevel  = 'Edit', UserId = userObj.Id);
        insert actm2;
        //system.assertEquals(accountObj.Id, [SELECT UserId, AccountId, TeamMemberRole FROM AccountTeamMember LIMIT 1].AccountId);
        
        AccountShare asObj = new AccountShare(AccountId = accountObj.Id, UserOrGroupId = leadConversionUser.Id, AccountAccessLevel= 'Edit', RowCause  = 'Manual', OpportunityAccessLevel = 'Edit');
        insert asObj;
        //system.assertEquals(accountObj.Id, [SELECT Id, UserOrGroupId, AccountId FROM AccountShare LIMIT 1].AccountId);
        
        AccountShare asObj1 = new AccountShare(AccountId = accountObj.Id, UserOrGroupId = userObj.Id, AccountAccessLevel= 'Edit', RowCause  = 'Manual', OpportunityAccessLevel = 'Edit');
        insert asObj1;
        //system.assertEquals(accountObj.Id, [SELECT Id, UserOrGroupId, AccountId FROM AccountShare LIMIT 1].AccountId);
         
        AccountShare asObj2 = new AccountShare(AccountId = accountObj.Id, UserOrGroupId = userObj.Id, AccountAccessLevel= 'Edit', RowCause  = 'Manual', OpportunityAccessLevel = 'Edit');
        insert asObj2;
        //system.assertEquals(accountObj.Id, [SELECT Id, UserOrGroupId, AccountId FROM AccountShare LIMIT 1].AccountId);
         
        Contract contractObj = CommonDataTracker.insertContract(accountObj,contactObj,null,docMasterAgreement,'Pending');
        contractObj.Active__c = false;
        insert contractObj;
        
        Test.stopTest(); 
    }
    
    static testMethod void testMethod_1(){
        
        Business_Category__c businessCategoryNGO = [Select Id from Business_Category__c LIMIT 1];
         
        Sub_Category__c subCategoryBooks = [Select Id,Delivery_Duration__c from Sub_Category__c LIMIT 1];
        
        Entity__c entityObj = [Select Id,Total_Required_Documents__c from Entity__c LIMIT 1];
        
        Product__c prodObj = [Select Id,Name from Product__c LIMIT 1];
        
        Account accountObj = [SELECT Id, Total_KYC_Auto_Approve__c, All_Approved_KYC_Documentable_type__c,
                              Total_Required_Merchant_Documents_New__c, Total_Docs_Onboarding_Status_Pending__c, 
                              Total_Docs_For_Merchant__c, Total_Docs_Onboarding_Status_Approved__c, 
                              Document_Received_Time__c, Lead_Type__c, PAN_Verification_Status__c, 
                              SubCategoryName__c, Prod_Merchant_Id__c, BusinessCategoryName__c, 
                              Total_Required_Merchant_Documents__c, Total_Docs_Received_Status_Received__c, 
                              Total_Docs_Onboarding_Status_Decline__c,Merchant_Business_Type__c,
                              Sub_Category__c, Payload_Header__c, NDX_Score__c, Monthly_Expected_Sale__c, 
                              Legal_Name__c, LOB_Status__c, Identifier__c, Document_Status__c, Delivery_Duration__c,
                              Business_Entity__c, Business_Category__c, Agreement_Status__c, Active__c,Type__c
                              FROM Account WHERE Type__c='Merchant' AND Pan_Number__c = 'GKMSF4212W' LIMIT 1]; 
        system.debug('accountObj ### '+accountObj);
        
        Account accountAggregatorObj = [SELECT Id, Total_KYC_Auto_Approve__c, All_Approved_KYC_Documentable_type__c,
                              Total_Required_Merchant_Documents_New__c, Total_Docs_Onboarding_Status_Pending__c, 
                              Total_Docs_For_Merchant__c, Total_Docs_Onboarding_Status_Approved__c, 
                              Document_Received_Time__c, Lead_Type__c, PAN_Verification_Status__c, 
                              SubCategoryName__c, Prod_Merchant_Id__c, BusinessCategoryName__c, 
                              Total_Required_Merchant_Documents__c, Total_Docs_Received_Status_Received__c, 
                              Total_Docs_Onboarding_Status_Decline__c,Merchant_Business_Type__c,
                              Sub_Category__c, Payload_Header__c, NDX_Score__c, Monthly_Expected_Sale__c, 
                              Legal_Name__c, LOB_Status__c, Identifier__c, Document_Status__c, Delivery_Duration__c,
                              Business_Entity__c, Business_Category__c, Agreement_Status__c, Active__c,Type__c
                              FROM Account WHERE Type__c='Merchant' AND PAN_Number__c = 'AMMUT4212Y' LIMIT 1]; 
        system.debug('accountAggregatorObj ### '+accountAggregatorObj);
        
        Opportunity opportunityAggObj = CommonDataTracker.insertOpportunity(accountAggregatorObj);
        opportunityAggObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Aggregator').getRecordTypeId();
        opportunityAggObj.BusinessCategory__c = businessCategoryNGO.id;
        opportunityAggObj.Transaction_Facility_Required__c = 'Domestic';
        opportunityAggObj.Delivery_Duration__c = 90;
        opportunityAggObj.AccountId = accountAggregatorObj.Id;
        opportunityAggObj.Prod_Merchant_Id__c = 42766733;
        opportunityAggObj.Merchant_Id__c = 41366733;
        opportunityAggObj.Website_Status__c = 'Website OK';
        opportunityAggObj.Product__c = prodObj.Id;
        insert opportunityAggObj;
        System.assertEquals(accountAggregatorObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityAggObj.id].AccountId);
        
        
        accountAggregatorObj.Type__c = 'Aggregator';
        update accountAggregatorObj;
        
        Document_Category_Master__c docCategoryAddressObj = [Select Id from Document_Category_Master__c WHERE Name='Address Proof of Signing Authority' LIMIT 1];
        
        Document_Category_Master__c docCategoryPanObj = [Select Id from Document_Category_Master__c WHERE Name='PAN Card of Signing Authority' LIMIT 1];
        
        Document_Category_Master__c docCategoryBankObj = [Select Id from Document_Category_Master__c WHERE Name='Bank Account Proof' LIMIT 1];
        
        Merchant_Document__c MerchantDocumentPanObj = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentPanObj.Onboarding_Status__c = 'Pending';
        MerchantDocumentPanObj.KYC_Documentable_Type__c = 'Account';
        MerchantDocumentPanObj.Document_Category__c = docCategoryPanObj.Id;
        
        Merchant_Document__c MerchantDocumentAddressObj = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentAddressObj.Onboarding_Status__c = 'Pending';
        MerchantDocumentAddressObj.KYC_Documentable_Type__c = 'Account';
        MerchantDocumentAddressObj.Document_Category__c = docCategoryAddressObj.Id;
        
        Merchant_Document__c MerchantDocumentBankObj = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentBankObj.Onboarding_Status__c = 'Pending';
        MerchantDocumentBankObj.KYC_Documentable_Type__c = 'Account';
        MerchantDocumentBankObj.Document_Category__c = docCategoryBankObj.Id;
        
        List<Merchant_Document__c> merchDocList = new List<Merchant_Document__c>{MerchantDocumentPanObj,MerchantDocumentAddressObj,MerchantDocumentBankObj};
            insert merchDocList;
        System.assertEquals(accountObj.id, [SELECT id, Account__c FROM Merchant_Document__c WHERE id =: merchDocList[0].id].Account__c);
        
        Contract contractObj = [Select Id,Status,Active__c from Contract LIMIT 1];
        contractObj.Status = 'Approved';
        update contractObj;
        
        accountObj.PAN_Verification_Status__c = 'Success';
        accountObj.Document_Status__C = 'Docs Received';
        accountObj.Agreement_Status__c = 'Approved';
        accountObj.Monthly_Expected_Sale__c = 213;
        accountObj.Sub_Category__c = subCategoryBooks.Id;
        update accountObj;
                        
        Opportunity opportunityObj = [Select Id,AccountId,Settlement_Status__c,Website_Status__c,Risk_Unhold_Reason__c,
                                      Bank_Verification_Status__c,Credit_Underwriter_Check__c,MAF_Status__c,Pricing_Negotiation_Validator__c,
                                      Stage_Closed_Won_Lost__c,RecordType.Name,Website__c,Android_URL__c,IOS_URL__c,Risk_Level__c,
                                      StageName,Document_Status_Document_Issue__c,LOB_Status_Sending__c from opportunity LIMIT 1];
        
        
        
        AccountTriggerHandler.updateDocStatus(accountObj.Id);
        
        System.debug('##### account doc status '+accountObj.Total_Docs_Onboarding_Status_Approved__c);
        System.debug('##### account agreement status '+accountObj.Total_Required_Merchant_Documents_New__c);
        System.debug('##### account pan_Verify status '+accountObj.Total_Required_Merchant_Documents__c);
        System.debug('##### account doc status '+accountObj.Document_Status__c);
        System.debug('##### account agreement status '+accountObj.Agreement_Status__c);
        System.debug('##### account pan_Verify status '+accountObj.PAN_Verification_Status__c);
    }
    
    static testMethod void testMethod_2(){
        
        Business_Category__c businessCategoryNGO = [Select Id from Business_Category__c LIMIT 1];
         
        Entity__c entityObj = [Select Id,Total_Required_Documents__c from Entity__c Where Name='Individual' LIMIT 1];
        
        Entity__c socialEntityObj = [Select Id,Name from Entity__c Where Name='Social' LIMIT 1];
        
        Product__c prodObj = [Select Id,Name from Product__c LIMIT 1];
        
        Account accountObj = [SELECT Id, Total_KYC_Auto_Approve__c, All_Approved_KYC_Documentable_type__c,
                              Total_Required_Merchant_Documents_New__c, Total_Docs_Onboarding_Status_Pending__c, 
                              Total_Docs_For_Merchant__c, Total_Docs_Onboarding_Status_Approved__c, 
                              Document_Received_Time__c, Lead_Type__c, PAN_Verification_Status__c, 
                              SubCategoryName__c, Prod_Merchant_Id__c, BusinessCategoryName__c, 
                              Total_Required_Merchant_Documents__c, Total_Docs_Received_Status_Received__c, 
                              Total_Docs_Onboarding_Status_Decline__c,
                              Sub_Category__c, Payload_Header__c, NDX_Score__c, Monthly_Expected_Sale__c, 
                              Legal_Name__c, LOB_Status__c, Identifier__c, Document_Status__c, Delivery_Duration__c,
                              Business_Entity__c, Business_Category__c, Agreement_Status__c, Active__c,Type__c
                              FROM Account WHERE Type__c='Merchant' AND Pan_Number__c = 'GKMSF4212W' LIMIT 1]; 
        system.debug('accountObj ### '+accountObj);
        
        Account accountPartnerObj = [Select Id,Business_Entity__c from Account Where Type__c='Partner' LIMIT 1];
        accountPartnerObj.Business_Entity__c = socialEntityObj.Id;
        //accountPartnerObj.Client_Name__c='Axis Bank';
       // accountPartnerObj.Region__c='India'; 
        update accountPartnerObj; 
        
        Opportunity opportunityAggObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityAggObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityAggObj.BusinessCategory__c = businessCategoryNGO.id;
        opportunityAggObj.Transaction_Facility_Required__c = 'International';
        opportunityAggObj.Delivery_Duration__c = 90;
        opportunityAggObj.AccountId = accountObj.Id;
        opportunityAggObj.Prod_Merchant_Id__c = 42166733;
        opportunityAggObj.Merchant_Id__c = 40366733;
        opportunityAggObj.Website_Status__c = 'Website OK';
        opportunityAggObj.Product__c = prodObj.Id;
        insert opportunityAggObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityAggObj.id].AccountId);
        
        Document_Category_Master__c docCategoryAddressObj = [Select Id from Document_Category_Master__c WHERE Name='Address Proof of Signing Authority' LIMIT 1];
        
        Document_Category_Master__c docCategoryPanObj = [Select Id from Document_Category_Master__c WHERE Name='PAN Card of Signing Authority' LIMIT 1];
        
        Document_Category_Master__c docCategoryBankObj = [Select Id from Document_Category_Master__c WHERE Name='Bank Account Proof' LIMIT 1];
        
        Merchant_Document__c MerchantDocumentPanObj = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentPanObj.Onboarding_Status__c = 'Pending';
        MerchantDocumentPanObj.KYC_Documentable_Type__c = 'Account';
        MerchantDocumentPanObj.Document_Category__c = docCategoryPanObj.Id;
        
        Merchant_Document__c MerchantDocumentAddressObj = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentAddressObj.Onboarding_Status__c = 'Pending';
        MerchantDocumentAddressObj.KYC_Documentable_Type__c = 'Account';
        MerchantDocumentAddressObj.Document_Category__c = docCategoryAddressObj.Id;
        
        Merchant_Document__c MerchantDocumentBankObj = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentBankObj.Onboarding_Status__c = 'Pending';
        MerchantDocumentBankObj.KYC_Documentable_Type__c = 'Account';
        MerchantDocumentBankObj.Document_Category__c = docCategoryBankObj.Id;
        
        List<Merchant_Document__c> merchDocList = new List<Merchant_Document__c>{MerchantDocumentPanObj,MerchantDocumentAddressObj,MerchantDocumentBankObj};
            insert merchDocList;
        System.assertEquals(accountObj.id, [SELECT id, Account__c FROM Merchant_Document__c WHERE id =: merchDocList[0].id].Account__c);
        
        Contract contractObj = [Select Id,Status,Active__c from Contract LIMIT 1];
        contractObj.Status = 'Approved';
        update contractObj;
        
        accountObj.PAN_Verification_Status__c = 'Success';
        accountObj.Document_Status__C = 'Docs Received';
        //accountObj.Agreement_Status__c = 'Approved';
        accountObj.Monthly_Expected_Sale__c = 213;
        update accountObj;
        accountObj.Document_Status__C = 'Docs Approved';
        accountObj.Agreement_Status__c = 'Approved';
        accountObj.Pan_Verification_Status__c= 'Success';
        update accountObj;                
        Opportunity opportunityObj = [Select Id,AccountId,Settlement_Status__c,Website_Status__c,Risk_Unhold_Reason__c,
                                      Bank_Verification_Status__c,Credit_Underwriter_Check__c,MAF_Status__c,Pricing_Negotiation_Validator__c,
                                      Stage_Closed_Won_Lost__c,RecordType.Name,Website__c,Android_URL__c,IOS_URL__c,Risk_Level__c,
                                      StageName,Document_Status_Document_Issue__c,LOB_Status_Sending__c from opportunity LIMIT 1];
        
        
        
        AccountTriggerHandler.updateDocStatus(accountObj.Id);
        
        System.debug('##### account doc status '+accountObj.Total_Docs_Onboarding_Status_Approved__c);
        System.debug('##### account agreement status '+accountObj.Total_Required_Merchant_Documents_New__c);
        System.debug('##### account pan_Verify status '+accountObj.Total_Required_Merchant_Documents__c);
        System.debug('##### account doc status '+accountObj.Document_Status__c);
        System.debug('##### account agreement status '+accountObj.Agreement_Status__c);
        System.debug('##### account pan_Verify status '+accountObj.PAN_Verification_Status__c);
    }
    
    static testMethod void testMethod_3(){
        
        Business_Category__c businessCategoryNGO = [Select Id from Business_Category__c LIMIT 1];
         
        Entity__c entityObj = [Select Id,Total_Required_Documents__c from Entity__c Where Name='Individual' LIMIT 1];
        
        Entity__c socialEntityObj = [Select Id,Name from Entity__c Where Name='Social' LIMIT 1];
        
        Product__c prodObj = [Select Id,Name from Product__c LIMIT 1];
        
        Account accountObj = [SELECT Id, Total_KYC_Auto_Approve__c, All_Approved_KYC_Documentable_type__c,
                              Total_Required_Merchant_Documents_New__c, Total_Docs_Onboarding_Status_Pending__c, 
                              Total_Docs_For_Merchant__c, Total_Docs_Onboarding_Status_Approved__c, 
                              Document_Received_Time__c, Lead_Type__c, PAN_Verification_Status__c, 
                              SubCategoryName__c, Prod_Merchant_Id__c, BusinessCategoryName__c, 
                              Total_Required_Merchant_Documents__c, Total_Docs_Received_Status_Received__c, 
                              Total_Docs_Onboarding_Status_Decline__c,
                              Sub_Category__c, Payload_Header__c, NDX_Score__c, Monthly_Expected_Sale__c, 
                              Legal_Name__c, LOB_Status__c, Identifier__c, Document_Status__c, Delivery_Duration__c,
                              Business_Entity__c, Business_Category__c, Agreement_Status__c, Active__c,Type__c
                              FROM Account WHERE Type__c='Merchant' AND Pan_Number__c = 'GKMSF4212W' LIMIT 1]; 
        system.debug('accountObj ### '+accountObj);
        
        Account accountPartnerObj = [Select Id,Business_Entity__c from Account Where Type__c='Partner' LIMIT 1];
        accountPartnerObj.Business_Entity__c = socialEntityObj.Id;
        //accountPartnerObj.Client_Name__c='Axis Bank';
       // accountPartnerObj.Region__c='India'; 
        update accountPartnerObj; 
        
        Opportunity opportunityAggObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityAggObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityAggObj.BusinessCategory__c = businessCategoryNGO.id;
        opportunityAggObj.Transaction_Facility_Required__c = 'International';
        opportunityAggObj.Delivery_Duration__c = 90;
        opportunityAggObj.AccountId = accountObj.Id;
        opportunityAggObj.Prod_Merchant_Id__c = 42166733;
        opportunityAggObj.Merchant_Id__c = 40366733;
        opportunityAggObj.Website_Status__c = 'Website OK';
        opportunityAggObj.Product__c = prodObj.Id;
        insert opportunityAggObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityAggObj.id].AccountId);
        
        Document_Category_Master__c docCategoryAddressObj = [Select Id from Document_Category_Master__c WHERE Name='Address Proof of Signing Authority' LIMIT 1];
        
        Document_Category_Master__c docCategoryPanObj = [Select Id from Document_Category_Master__c WHERE Name='PAN Card of Signing Authority' LIMIT 1];
        
        Document_Category_Master__c docCategoryBankObj = [Select Id from Document_Category_Master__c WHERE Name='Bank Account Proof' LIMIT 1];
        
        Merchant_Document__c MerchantDocumentPanObj = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentPanObj.Onboarding_Status__c = 'Pending';
        MerchantDocumentPanObj.KYC_Documentable_Type__c = 'Account';
        MerchantDocumentPanObj.Document_Category__c = docCategoryPanObj.Id;
        
        Merchant_Document__c MerchantDocumentAddressObj = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentAddressObj.Onboarding_Status__c = 'Pending';
        MerchantDocumentAddressObj.KYC_Documentable_Type__c = 'Account';
        MerchantDocumentAddressObj.Document_Category__c = docCategoryAddressObj.Id;
        
        Merchant_Document__c MerchantDocumentBankObj = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentBankObj.Onboarding_Status__c = 'Pending';
        MerchantDocumentBankObj.KYC_Documentable_Type__c = 'Account';
        MerchantDocumentBankObj.Document_Category__c = docCategoryBankObj.Id;
        
        List<Merchant_Document__c> merchDocList = new List<Merchant_Document__c>{MerchantDocumentPanObj,MerchantDocumentAddressObj,MerchantDocumentBankObj};
            insert merchDocList;
        System.assertEquals(accountObj.id, [SELECT id, Account__c FROM Merchant_Document__c WHERE id =: merchDocList[0].id].Account__c);
        
        Contract contractObj = [Select Id,Status,Active__c from Contract LIMIT 1];
        contractObj.Status = 'Counter Signed Received';
        update contractObj;
        
        accountObj.PAN_Verification_Status__c = 'Success';
        accountObj.Document_Status__C = 'Docs Received';
        //accountObj.Agreement_Status__c = 'Approved';
        accountObj.Monthly_Expected_Sale__c = 213;
        update accountObj;
        
        accountObj.Agreement_Status__c = 'Counter Signed Received';
        accountObj.Pan_Verification_Status__c= 'Success';
        update accountObj;    
        
        accountObj.PAN_Verification_Status__c = 'Pending';
        update accountObj;
        
        accountObj.Document_Status__C = 'Docs Approved';
        update accountObj;
    }
    
    static testMethod void testMethod_4(){
        
        Business_Category__c businessCategoryNGO = [Select Id from Business_Category__c LIMIT 1];
        Sub_Category__c subCategoryInd = [Select Id from Sub_Category__c LIMIT 1];
        
        Sub_Category__c subCategoryInd2 = CommonDataTracker.insertSubCategory('Individual', false);
        subCategoryInd2.Category__c = businessCategoryNGO.Id;
        subCategoryInd2.Delivery_duration__c = 5;
        insert subCategoryInd2 ;
        
        System.assertEquals('Individual', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryInd.id].Name);
        
        Entity__c entityObj = [Select Id,Total_Required_Documents__c from Entity__c Where Name='Individual' LIMIT 1];
        
        Entity__c socialEntityObj = [Select Id,Name from Entity__c Where Name='Social' LIMIT 1];
        
        Product__c prodObj = [Select Id,Name from Product__c LIMIT 1];
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c = entityObj.Id;
        accountObj.Business_Category__c = businessCategoryNGO.Id;
        accountObj.Sub_Category__c = subCategoryInd.Id;
        accountObj.Skip_Document_Verification__c = true;
        accountObj.Skip_Agreement_Verification__c = true;
        insert accountObj;
        
        accountObj.Transaction_Facility_Required__c = 'International';
        accountObj.Business_Category__c = businessCategoryNGO.Id;
        accountObj.Sub_Category__c = subCategoryInd2.Id;
        accountObj.Delivery_Duration__c = 10;
        accountObj.Monthly_Expected_Sale__c = 10000;
        update accountObj;
    }
}