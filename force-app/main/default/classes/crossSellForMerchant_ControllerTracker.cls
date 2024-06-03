@isTest
public class crossSellForMerchant_ControllerTracker {
    
    @testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Address_Details__c', true);
        insert triggerSwitchObj ; 
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);    
        
        E_Stamp_Master__c EStampMasterObj = CommonDataTracker.insertEStampMaster('12345678');
        insert EStampMasterObj;
        System.assertEquals(true, [SELECT Id, Active__c FROM E_Stamp_Master__c WHERE Id =: EStampMasterObj.Id].Active__c);
        
        User salesUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales User'].Id,
            LastName = 'last Sales',
            Email = 'puser000@amamama.com',
            Username = 'puser000@salesamamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        insert salesUser;
        
        Id supportRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        accountObj.recordtypeId = supportRecordTypeId;
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: accountObj.Id].PAN_Number__c); 
        
        Contact contactObj = CommonDataTracker.InsertContact(accountObj);
        contactObj.Email = 'uma.shankar@saasfocus.com';
        insert contactObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj.id].AccountId);
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        opportunityObj.GST_Number__c = '343443343443';
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId); 
        
        Document_Category_Master__c docCategoryMasterObj =  CommonDataTracker.insertDocCategoryMaster('Address Proof');
        insert docCategoryMasterObj; 
        System.assertEquals('Address Proof', [SELECT Id, Name FROM Document_Category_Master__c WHERE Id =: docCategoryMasterObj.Id].Name);   
        
        Id addendumRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Addendum').getRecordTypeId();
        Id agreementRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Agreement').getRecordTypeId();
        
        Document_Master__c docMasterAddendumObj = CommonDataTracker.insertDocumentMaster('Passport', docCategoryMasterObj, addendumRecordTypeId, 'ServiceAgreementHUF');
        docMasterAddendumObj.Entity__c = entityObj.Id;
        insert docMasterAddendumObj ;
        System.assertEquals(docCategoryMasterObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterAddendumObj.Id].Document_Category__c);
        
        Document_Master__c docMasterAgreementObj = CommonDataTracker.insertDocumentMaster('Aadhar Card', docCategoryMasterObj, agreementRecordTypeId, 'ServiceAgreementIndianTrustsActOf1882');
        docMasterAgreementObj.Entity__c = entityObj.Id;
        insert docMasterAgreementObj ;
        System.assertEquals(docCategoryMasterObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterAgreementObj.Id].Document_Category__c);
        
        Error_Solution_Mapping__c errorSolutionObj = CommonDataTracker.insertErrorSolutionMapping(entityObj, docCategoryMasterObj);
        insert errorSolutionObj;
        System.assertEquals(docCategoryMasterObj.id, [SELECT id, Document_Category__c FROM Error_Solution_Mapping__c WHERE id =: errorSolutionObj.id].Document_Category__c);
        
        Merchant_Document__c MerchantDocumentObj = CommonDataTracker.insertMerchantDoc(accountObj);
        insert MerchantDocumentObj;
        System.assertEquals(accountObj.id, [SELECT id, Account__c FROM Merchant_Document__c WHERE id =: MerchantDocumentObj.id].Account__c);
        
        ContentVersion contentVersionObj =  CommonDataTracker.insertContentVersion('Test title');
        insert contentVersionObj;
        
        Contract contractObj = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Draft Sent');
        contractObj.E_Stamp__c = EStampMasterObj.Id;
        contractObj.Type__c = 'Final';
        contractObj.status = 'Pending';
        insert contractObj;
        System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractObj.Id].AccountId);
        
        Business_Category__c businessCategoryOthers = CommonDataTracker.insertBusinessCategory('Others', false);
        insert businessCategoryOthers ;
        System.assertEquals('Others', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryOthers.id].Name);
        
        Business_Category__c businessCategoryNGO = CommonDataTracker.insertBusinessCategory('NGO', true);
        insert businessCategoryNGO ;
        System.assertEquals('NGO', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryNGO.id].Name);
        
        Sub_Category__c subCategoryOthers = CommonDataTracker.insertSubCategory('Others', false);
        subCategoryOthers.Category__c = businessCategoryOthers.Id;
        insert subCategoryOthers ;
        System.assertEquals('Others', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryOthers.id].Name);
        
        Sub_Category__c subCategoryBooks = CommonDataTracker.insertSubCategory('Books', true);
        subCategoryBooks.Category__c = businessCategoryNGO.Id;
        insert subCategoryBooks ;
        System.assertEquals('Books', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryBooks.id].Name);
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        String SalesProfileId = [SELECT Id FROM Profile WHERE Name =:'Sales User' LIMIT 1].Id;
            
        Lead leadObj = CommonDataTracker.insertLead(prodObj, businessCategoryNGO, subCategoryBooks, entityObj);
        leadObj.Merchant_Id__c = null;
        leadObj.Email = 'uma.shankar+jbshadbash7y281y@gmail.com';
        leadObj.LeadSource = 'Organic';
        leadObj.Sub_Source__c = 'Email';
        leadObj.OwnerId = salesUser.Id;
        insert leadObj;
        System.assertEquals(prodObj.Id, [SELECT id, Product__c FROM Lead WHERE id =: leadObj.Id].Product__c);
        
        Address_Details__c addDetailsRegObj = CommonDataTracker.insertAddressDetails(leadObj.id, accountObj.Id, null,'Registered');
        	insert  addDetailsRegObj;
        
        Address_Details__c addDetailsOppObj = CommonDataTracker.insertAddressDetails(leadObj.id, accountObj.Id, null,'Operating');
        	insert  addDetailsOppObj;
    }
    
    @isTest
    public static void testMethod1(){
        Test.startTest();
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        insert u;
        system.runAs(u){
            Account acc = [SELECT Id, PAN_Number__c FROM Account LIMIT 1];
            
            Lead leadObj = [SELECT id, ProductLabel__c, Merchant_Id__c, IntegrationInfo__c, Name, FirstName, LastName, Email, MobilePhone__c, Identifier__c, 
                        Business_Entity_Identifier__c, Business_Category_Identifier__c, Sub_Category_Identifier__c, Website__c, Merchant_Trading_Name__c, Device__c, 
                        Merchant_Business_Type__c, PAN_Holder_Name__c, PAN_Number__c, Android_URL__c, iOS_URL__c, GST_Number__c, Integration_Type__c, Delivery_Duration__c, 
                        Monthly_Expected_Sale__c, SAP_Id__c,Lead_Type__c,Active__c, Campaign_Name__c, Campaign_Medium__c, Campaign_Source__c, Campaign_Term__c, Partner_UUID__c, LeadSource, Sub_Source__c 
                        FROM Lead LIMIT 1 ];
            
            Opportunity opportunityObj = [SELECT Id, AccountId, Merchant_Id__c FROM Opportunity WHERE AccountId =: acc.Id LIMIT 1];
        
            opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
            opportunityObj.Transaction_Facility_Required__c = 'Domestic';
            opportunityObj.Delivery_Duration__c = 90;
            opportunityObj.AccountId = acc.Id;
            opportunityObj.Prod_Merchant_Id__c = 123456;
            opportunityObj.Website_Status__c = 'Website OK';
            opportunityObj.Settlement_Status__c = 'Active';
            opportunityObj.CB_Ratio__c = 0.4;
            opportunityObj.Last_6_months_GMV__c = 200000.00;
            opportunityObj.First_Txn_date__c = Date.today()-100;
            opportunityObj.GMV_Latest_Date__c = Date.today();
            update opportunityObj;
            
            contact oContact1=new contact();
            oContact1.LastName='test';
            oContact1.AccountId = acc.Id;
            oContact1.Email='test@test.com';
            oContact1.MobilePhone='1234567890';
            insert oContact1;
            
            Case cs =new Case();
            cs.Status='New';
            cs.OwnerId = u.Id;
            cs.LP_Sub_Status__c='Waiting On Technical Team';
            cs.Priority='Medium';
            cs.SuppliedEmail = 'test1@test.com';
            cs.SuppliedName = 'Test2';
            cs.LP_TAT__c = '3';
            cs.LP_Business_Vertical__c = 'PayU Money';
            cs.LP_Category__c = 'PayU Money';
            cs.ContactId=oContact1.id;
            cs.LOB_Name__c='PayU Money';
            cs.Opportunity__c = opportunityObj.Id;
            cs.Comments = 'Testing comment';
            cs.AccountId = acc.Id;
            cs.Merchant_Id__c = '123456';
            cs.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
            insert cs;
            
            Platform__c platformObj = [Select Id from Platform__c LIMIT 1];
            
            Product__c prod = new Product__c();
            prod.Active__c = true;
            prod.Name = 'T+0';
            prod.Platform__c = platformObj.id;
            insert prod;
            
            Cross_Sell__c crs = new Cross_Sell__c();
            crs.Care_Status__c = 'Interested';
            crs.Opportunity__c = opportunityObj.Id;
            crs.Risk_Status__c = 'Rejected';
            crs.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Product Cross-Selling').getRecordTypeId();
            crs.Custom_Product__c = prod.Id;
            insert crs;
            List<Cross_Sell__c> csList = new List<Cross_Sell__c>();
            csList.add(crs);
            
            
            System.debug('cs.AccountId '+cs.AccountId);
            crossSellForMerchant_Controller.getCombinedData(opportunityObj.Id);
            crossSellForMerchant_Controller.getCase(cs.Id);
            crossSellForMerchant_Controller.riskZoneCalculation(opportunityObj,csList);
            
            crossSellForMerchant_Controller.oppWithAccountWrapper temp= new crossSellForMerchant_Controller.oppWithAccountWrapper();
            //temp.isEditable;
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testMethod2(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales User'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        insert u;
        system.runAs(u){
            Account acc = [SELECT Id, PAN_Number__c FROM Account LIMIT 1];
            Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(acc);
        opportunityObj.GST_Number__c = '343443343443';
        
            opportunityObj.Transaction_Facility_Required__c = 'Domestic';
            opportunityObj.Delivery_Duration__c = 90;
            opportunityObj.AccountId = acc.Id;
            opportunityObj.Prod_Merchant_Id__c = 123456;
            opportunityObj.Website_Status__c = 'Website OK';
            opportunityObj.Settlement_Status__c = 'Active';
            opportunityObj.CB_Ratio__c = 0.4;
            opportunityObj.Last_6_months_GMV__c = 200000.00;
            opportunityObj.First_Txn_date__c = Date.today()-100;
            opportunityObj.GMV_Latest_Date__c = Date.today();
            insert opportunityObj;
            
            Platform__c platformObj = [Select Id from Platform__c LIMIT 1];
            
            Product__c prod = new Product__c();
            prod.Active__c = true;
            prod.Name = 'MCP';
            prod.Platform__c = platformObj.id;
            insert prod;
            
            Cross_Sell__c cs = new Cross_Sell__c();
            cs.Care_Status__c = 'Interested';
            cs.Custom_Product__c = prod.Id;
            cs.Opportunity__c = opportunityObj.Id;
            cs.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Product Cross-Selling').getRecordTypeId();
            insert cs;
            Cross_Sell__c cs2 = new Cross_Sell__c();
            cs2.Care_Status__c = 'Interested';
            cs2.Custom_Product__c = prod.Id;
            cs2.Opportunity__c = opportunityObj.Id;
            cs2.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Product Cross-Selling').getRecordTypeId();
            insert cs2;
            Cross_Sell__c cs3 = new Cross_Sell__c();
            cs3.Care_Status__c = 'Interested';
            cs3.Custom_Product__c = prod.Id;
            cs3.Opportunity__c = opportunityObj.Id;
            cs3.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Product Cross-Selling').getRecordTypeId();
            insert cs3;
            Cross_Sell__c cs4 = new Cross_Sell__c();
            cs4.Care_Status__c = 'Interested';
            cs4.Custom_Product__c = prod.Id;
            cs4.Opportunity__c = opportunityObj.Id;
            cs4.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Product Cross-Selling').getRecordTypeId();
            insert cs4;
            List<Cross_Sell__c> crossSellList = new List<Cross_Sell__c>();
            crossSellList.add(cs);
            Merchant_Document__c newDoc = new Merchant_Document__c();
            newDoc.Document_Category_Name__c = 'MCP Doc Category';
            newDoc.Document_Type_Name__c = 'MCP Doc Type';
            newDoc.Cross_Sell__c = cs.Id;
            newDoc.Opportunity__c = cs.Opportunity__c;
            newDoc.Account__c = acc.Id;
            newDoc.KYC_Documentable_Type__c = 'Merchant concent crossSell';
            Insert newDoc;
            
            string crossSellStr = '{"acc":{"Id":"001N000001li0TGIAY","PAN_Holder_Name__c":"Dummy Roy","PAN_Number__c":"CDKPS2999P","Legal_Name__c":"Dummy Roy"},"crossSell":[{"Id":"'+cs.Id+'","Custom_Product__c":"a0UN0000008IGfqMAG","Opportunity__c":"006N000000FNYpqIAH","Risk_Comment__c":"approve test1","Risk_Status__c":"Rejected","Create_Task__c":false,"Kam_Status__c":"Rejected by Risk","KAM_Comment__c":"ertyui","Custom_Product__r":{"Name":"T+0","Id":"'+cs2.Id+'"}},{"Id":"'+cs3.Id+'","Custom_Product__c":"a0UN0000008IGhWMAW","Opportunity__c":"006N000000FNYpqIAH","Risk_Comment__c":"fgh","Risk_Status__c":"Approved","Create_Task__c":false,"Kam_Status__c":"Rejected by Risk","KAM_Comment__c":"hhjsadh","Source__c":"Care","Risk_Rejection_Reason__c":"Financials are not good enough","Custom_Product__r":{"Name":"MCP","Id":"a0UN0000008IGhWMAW"},"KAM_Merchant_Rejection_Reason__c":""},{"Id":"'+cs4.Id+'","Custom_Product__c":"a0UN0000009irE6MAI","Opportunity__c":"006N000000FNYpqIAH","Create_Task__c":false,"Custom_Product__r":{"Name":"Payout","Id":"a0UN0000009irE6MAI"}}],"currentUser":{"Id":"0057F000005wg1HQAQ","ProfileId":"00e7F000002zRq5QAE","Super_User__c":false,"Profile":{"Name":"System Administrator","Id":"00e7F000002zRq5QAE"}},"isCareEditable":true,"isEditable":true,"isShowEditKamStatus":false,"isShowEditRiskStatusForKam":true,"opp":{"Id":"006N000000FNYpqIAH","Website__c":"youbusinessmail23.com","Website_Status__c":"Website OK","Key_Assigned_Manager__c":"0057F000005HnMKQA0","AccountId":"001N000001li0TGIAY"},"showCarePanel":false,"showRiskPanel":true,"isTaskToBeCreated":true}';
            crossSellForMerchant_Controller.updateCrossSellData(crossSellStr);
            crossSellForMerchant_Controller.createTaskForRiskTeam(crossSellStr,'MCP','Risk Team');
            crossSellForMerchant_Controller.createTaskForRiskTeam(crossSellStr,'T+0','KAM Task');
            crossSellForMerchant_Controller.getOpportunityFromMID(String.valueOf(opportunityObj.Prod_Merchant_Id__c) );
            crossSellForMerchant_Controller.updateRiskStatusToReEvaluate(cs.Id);
            crossSellForMerchant_Controller.getCrossSellStatus('Cross_Sell__c', 'Care_Status__c');
            crossSellForMerchant_Controller.getCombinedData(opportunityObj.Id);
            //crossSellForMerchant_Controller.fetchAttachments(cs.Id);
            crossSellForMerchant_Controller.createNewMerchDocument(cs.Id);
            crossSellForMerchant_Controller.getMerchantDocList(cs.Id);
            crossSellForMerchant_Controller.deleteMerchDocument(newDoc.Id);
            //Batch_CrossSellCreationForOpportunity bc = new Batch_CrossSellCreationForOpportunity();
            //database.executeBatch(bc);
            
        }
    }
    
    @isTest
    public static void testMethod3(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales User'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        insert u;
        system.runAs(u){
            Account acc = [SELECT Id, PAN_Number__c FROM Account LIMIT 1];
            Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(acc);
        opportunityObj.GST_Number__c = '343443343443';
        
            opportunityObj.Transaction_Facility_Required__c = 'Domestic';
            opportunityObj.Delivery_Duration__c = 90;
            opportunityObj.AccountId = acc.Id;
            opportunityObj.Prod_Merchant_Id__c = 123456;
            opportunityObj.Website_Status__c = 'Website OK';
            opportunityObj.Settlement_Status__c = 'Active';
            opportunityObj.CB_Ratio__c = 0.4;
            opportunityObj.Last_6_months_GMV__c = 200000.00;
            opportunityObj.First_Txn_date__c = Date.today()-100;
            opportunityObj.GMV_Latest_Date__c = Date.today();
            insert opportunityObj;
            
            Platform__c platformObj = [Select Id from Platform__c LIMIT 1];
            
            Product__c prod = new Product__c();
            prod.Active__c = true;
            prod.Name = 'MCP';
            prod.Platform__c = platformObj.id;
            insert prod;
            
            Cross_Sell__c cs = new Cross_Sell__c();
            cs.Care_Status__c = 'Interested';
            cs.Custom_Product__c = prod.Id;
            cs.Opportunity__c = opportunityObj.Id;
            cs.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Payout').getRecordTypeId();
            insert cs;
            
            Document_Category_Master__c  docCat = New Document_Category_Master__c();
            docCat.Name = 'Government Issued Certificate';
            docCat.Active__c = true;
            insert docCat;
            
            Merchant_Document__c newDoc = new Merchant_Document__c();
            newDoc.Document_Category_Name__c = 'MCP Doc Category';
            newDoc.Document_Type_Name__c = 'MCP Doc Type';
            newDoc.Cross_Sell__c = cs.Id;
            newDoc.Opportunity__c = cs.Opportunity__c;
            newDoc.Account__c = acc.Id;
            newDoc.KYC_Documentable_Type__c = 'Merchant concent crossSell';
            newDoc.Document_Category__c = docCat.Id;
            Insert newDoc;
            
            Address_Details__c addDetailsRegObj = [Select Id,City__c,State__c,Country__c,Pincode__c,Address_Line__c,Type__c,
                                                Lead__c,Opportunity__c from Address_Details__c Where Type__c='Registered' LIMIT 1];
            
            Address_Details__c addDetailsOppObj = [Select Id,City__c,State__c,Country__c,Pincode__c,Address_Line__c,Type__c,
                                                Lead__c,Opportunity__c from Address_Details__c Where Type__c='Operating' LIMIT 1];
            
            ApexPages.currentPage().getParameters().put('relatedId',opportunityObj.Id);

			ApexPages.StandardController sc = new ApexPages.StandardController(opportunityObj);
			crossSellForMerchant_Controller crossController = new crossSellForMerchant_Controller(sc);
        }
    }
    
    @isTest
    public static void testMethod4(){
        
            Account acc = [SELECT Id, PAN_Number__c FROM Account LIMIT 1];
            Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(acc);
        opportunityObj.GST_Number__c = '343443343443';
        
            opportunityObj.Transaction_Facility_Required__c = 'Domestic';
            opportunityObj.Delivery_Duration__c = 90;
            opportunityObj.AccountId = acc.Id;
            opportunityObj.Prod_Merchant_Id__c = 123456;
            opportunityObj.Website_Status__c = 'Website OK';
            opportunityObj.Settlement_Status__c = 'Active';
            opportunityObj.CB_Ratio__c = 0.4;
            opportunityObj.Last_6_months_GMV__c = 200000.00;
            opportunityObj.First_Txn_date__c = Date.today()-100;
            opportunityObj.GMV_Latest_Date__c = Date.today();
            insert opportunityObj;
            
            Platform__c platformObj = [Select Id from Platform__c LIMIT 1];
            
            Product__c prodObj = CommonDataTracker.insertCustomProduct('Payout', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        	insert prodObj;
            
            Cross_Sell__c cs = new Cross_Sell__c();
            cs.Care_Status__c = 'Interested';
            cs.Opportunity__c = opportunityObj.Id;
            cs.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Payout').getRecordTypeId();
            cs.Custom_Product__c = prodObj.Id;
            insert cs;
            
            Merchant_Document__c newDoc = new Merchant_Document__c();
            newDoc.Document_Category_Name__c = 'MCP Doc Category';
            newDoc.Document_Type_Name__c = 'MCP Doc Type';
            newDoc.Cross_Sell__c = cs.Id;
            newDoc.Opportunity__c = cs.Opportunity__c;
            newDoc.Account__c = acc.Id;
            newDoc.KYC_Documentable_Type__c = 'Merchant concent crossSell';
            Insert newDoc;
            
            Address_Details__c addDetailsRegObj = [Select Id,City__c,State__c,Country__c,Pincode__c,Address_Line__c,Type__c,
                                                Lead__c,Opportunity__c from Address_Details__c Where Type__c='Registered' LIMIT 1];
            
            Address_Details__c addDetailsOppObj = [Select Id,City__c,State__c,Country__c,Pincode__c,Address_Line__c,Type__c,
                                                Lead__c,Opportunity__c from Address_Details__c Where Type__c='Operating' LIMIT 1];
            
            contact oContact=new contact();
            oContact.LastName='test';
            oContact.AccountId = acc.Id;
            oContact.Email='test@test.com';
            oContact.MobilePhone='1234567890';
            insert oContact;
            
            
            Case caseObj =new Case();
            caseObj.Status='New';
            caseObj.LP_Sub_Status__c='Waiting On Technical Team';
            caseObj.Priority='Medium';
            caseObj.SuppliedEmail = 'test1@test.com';
            caseObj.SuppliedName = 'Test2';
            caseObj.LP_TAT__c = '3';
            caseObj.LP_Business_Vertical__c = 'PayU Money';
            caseObj.LP_Category__c = 'PayU Money';
            caseObj.ContactId=oContact.id;
            caseObj.LOB_Name__c='PayU Money';
            caseObj.Opportunity__c = opportunityObj.Id;
            caseObj.Comments = 'Testing comment';
            caseObj.AccountId = acc.Id;
            caseObj.Merchant_Id__c = '123456';
            caseObj.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
            insert caseObj;
            
        Document_Master__c docMasterAgreementObj = [Select Id from Document_Master__c LIMIT 1];
        
        E_Stamp_Master__c EStampMasterObj = [Select Id from E_Stamp_Master__c LIMIT 1];
        
        Contract contractObj = CommonDataTracker.insertContract(acc, oContact, opportunityObj, docMasterAgreementObj, 'Draft Sent');
        contractObj.E_Stamp__c = EStampMasterObj.Id;
        contractObj.Type__c = 'Final';
        contractObj.status = 'Pending';
        insert contractObj;
        System.assertEquals(acc.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractObj.Id].AccountId);
        
        
        Test.startTest();
            crossSellForMerchant_Controller.getCombinedData(caseObj.Id);
            crossSellForMerchant_Controller.fetchAttachments(cs.Id);
            crossSellForMerchant_Controller.sendEmailToLegal(new list<string>{'abc@gmail.ciom'},cs,null);
            crossSellForMerchant_Controller.createContract(acc,oContact,true,opportunityObj,'PayoutAgreement');
        crossSellForMerchant_Controller.sendPayoutAgreement(opportunityObj.Id);
        crossSellForMerchant_Controller.getMerchantAdminIdentifier(opportunityObj.Id);
        Test.stopTest();
    }
}