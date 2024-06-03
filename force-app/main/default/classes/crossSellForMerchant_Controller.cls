public class crossSellForMerchant_Controller {
    public String currentRecordId {get;set;}
    public List<Cross_Sell__History> CrossSellHistoryList {get;set;}
    public Opportunity oppObj {get;set;}
    public Address_Details__c registerAddress {get;set;}
    public Address_Details__c operatingAddress {get;set;}
    
    public crossSellForMerchant_Controller(ApexPages.StandardController controller){
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('relatedId');
        oppObj = new Opportunity();
        CrossSellHistoryList = new List<Cross_Sell__History>();
        registerAddress = new Address_Details__c();
        operatingAddress = new Address_Details__c();
        
        Id payOutRecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Payout').getRecordTypeId();
        
        List<Opportunity> oppDetailsList = [SELECT Id, Name, Legal_Name_Account__c ,Integration_Type__c ,AccountId,
                                            Business_Entity__r.Name,BusinessCategory__r.Name,Website__c,Business_Entity_Formula__c, 
                                            Business_Category__c  FROM Opportunity where Id =:currentRecordId LIMIT 1];
        oppObj = oppDetailsList[0];
        List<Cross_Sell__c> crossSellList = [Select Id,Opportunity__c, Name From Cross_Sell__c where Opportunity__c =:currentRecordId AND RecordTypeId =: payOutRecordTypeId];
        
        CrossSellHistoryList = [SELECT CreatedById,CreatedDate,CreatedBy.Name,DataType,Field,Id,IsDeleted,NewValue,
                                OldValue,ParentId 
                                FROM Cross_Sell__History
                                WHERE ParentId =:crossSellList[0].Id ORDER BY CreatedDate DESC];
        
        List<Address_Details__c> addressList = [SELECT Id, City__c,State__c,Country__c,Pincode__c,Address_Line__c,Type__c,
                                                Lead__c,Opportunity__c FROM Address_Details__c 
                                                WHERE Active__c=true AND Type__c IN ('Registered', 'Operating')
                                                AND Account__c =:oppObj.AccountId];
        for(Address_Details__c address: addressList){
            if(address.Type__c == 'Registered'){
                registerAddress = address;
            }
            if(address.Type__c == 'Operating'){
                operatingAddress = address;
            }
        }
    }
    
    @AuraEnabled
    public static oppWithAccountWrapper getCombinedData(Id currentRecId){
        try{
            createCrossSellForProduct(currentRecId);
            Map<String,String> 	CrossSell_ProductAndUserIdMap =(Map<String, String>)JSON.deserialize(system.label.CrossSell_ProductAndUserIdMap, Map<String, String>.class);
            Map<String,String> 	CrossSell_AdditionalAccessAsKamMap = (Map<String,String>)JSON.deserialize(System.Label.CrossSell_Additional_Access_As_Kam_And_Send_CrossSell_Data_Excel ,Map<String, String>.class);
            List<String> CrossSell_AdditionalAccessAsKamList = CrossSell_AdditionalAccessAsKamMap.get('Additional access same as kam').split(',');
            Integer approvedCount = 0;
            oppWithAccountWrapper oppWrap = New oppWithAccountWrapper();
            oppWrap.isEditable = true;
            oppWrap.isTaskToBeCreated = false;
            oppWrap.sendAgreementToMerchant = false;
            List<Fee_Master__c> feeMasterList = New List<Fee_Master__c>();
            
            User user = [Select Id,Profile.Name,Super_User__c from User where Id=:UserInfo.getUserId()];
            List<Group> grp = [SELECT Id,DeveloperName, Name, Type, (SELECT Id, UserOrGroupId, GroupId FROM GroupMembers) FROM Group 
                               WHERE DeveloperName IN ('Cross_Sell_Risk_Team','payu_Money') AND Type =: 'Queue'];
            if(string.isNotBlank(currentRecId) && string.valueOf(currentRecId).startsWith('006')){
                oppWrap.opp = getOpportunity(currentRecId);
                oppWrap.showCarePanel = false;
                oppWrap.showRiskPanel = true;
            }else if(string.isNotBlank(currentRecId) && string.valueOf(currentRecId).startsWith('500')){
                oppWrap.cs = getCase(currentRecId);
                oppWrap.showCarePanel = true;
                oppWrap.showRiskPanel = false;
                if(string.isNotBlank(oppWrap.cs.Merchant_Id__c)) {
                    oppWrap.opp = getOpportunityFromMID(oppWrap.cs.Merchant_Id__c);                
                }
            }        
            oppWrap.currentUser = user;
            oppWrap.acc = getAccount(oppWrap.opp.AccountId);
            oppWrap.crossSell = getCrossSell(oppWrap.opp.Id);
            
            oppWrap.regAddress = New Address_Details__c();
            oppWrap.opAddress = New Address_Details__c();
            //oppWrap.crossSellHistory = New List<Cross_Sell__History>();
            
            if(oppWrap.acc.Id != null){
                for(Address_Details__c addDetail : getAccountAddressDetails(oppWrap.acc.Id)){
                    if(addDetail.Type__c == 'Registered'){
                        oppWrap.regAddress = addDetail;
                    }
                    if(addDetail.Type__c == 'Operating'){
                        oppWrap.opAddress = addDetail;
                    }
                }
            }
            
            if(oppWrap.acc.Id != null){
                for(Merchant_Document__c mdocDetail : getAccountMerchantDocDetails(oppWrap.acc.Id)){
                    if(mdocDetail.Document_Category__r.Name == 'Government Issued Certificate'){
                        oppWrap.merchantDocLink = mdocDetail.URL__c;
                    }
                }
            }
            
            if(!oppWrap.crossSell.isEmpty()){
                oppWrap.lstFeeMaster = getFeeMasters(oppWrap.crossSell);
            }
            integer careStatusCount = 0;
            
            for(Cross_Sell__c cs: getCrossSell(oppWrap.opp.Id)){
                /*if(cs.Care_Status__c == 'Interested'){
careStatusCount++;
}*/
                if(cs.Risk_Status__c == 'Rejected' && (string.isNotBlank(currentRecId) && string.valueOf(currentRecId).startsWith('500'))){
                    oppWrap.showCarePanelMsg = true;
                    oppWrap.showCarePanel = false;
                }
                if(cs.Custom_Product__r.Name == 'Payout'){
                    //oppWrap.crossSellHistory = getCrossSellHistory(cs.Id);
                }else{
                    //oppWrap.crossSellHistory = null;
                }
            }
            
            if(oppWrap.opp.Key_Assigned_Manager__c == UserInfo.getUserId() || CrossSell_AdditionalAccessAsKamList.contains(UserInfo.getUserId())){	
                oppWrap.isShowEditKamStatus = true;                	
            }else{	
                oppWrap.isShowEditKamStatus = false;	
            }	
            if(oppWrap.opp.Key_Assigned_Manager__c == UserInfo.getUserId() || UserInfo.getUserId() == CrossSell_ProductAndUserIdMap.get('MCP') || CrossSell_AdditionalAccessAsKamList.contains(UserInfo.getUserId())){	
                oppWrap.isShowEditRiskStatusForKam = false;	
                oppWrap.isShowEditKamStatus = true;	
            }else{	
                oppWrap.isShowEditRiskStatusForKam = true;	
            }
            
            if(user.Profile.Name == 'System Administrator' || user.Super_User__c){
                
                oppWrap.isCareEditable = true;
                oppWrap.isShowEditKamStatus = true; 
                oppWrap.isShowEditRiskStatusForKam = true;
                oppWrap.isEditPricingDetails = true;
                oppWrap.isShowEditPayoutFields = true;
            }
            else{
                if(careStatusCount > 0 && (oppWrap.opp.Key_Assigned_Manager__c == UserInfo.getUserId() || CrossSell_AdditionalAccessAsKamList.contains(UserInfo.getUserId()))){
                    oppWrap.isShowEditKamStatus = true;    
                    oppWrap.isShowEditPayoutFields = true;
                }else{
                    oppWrap.isShowEditKamStatus = false;
                }
                if(UserInfo.getUserId() == CrossSell_ProductAndUserIdMap.get('MCP') || CrossSell_AdditionalAccessAsKamList.contains(UserInfo.getUserId())){
                    oppWrap.isShowEditRiskStatusForKam = false;
                    oppWrap.isShowEditKamStatus = true;
                }else{
                    oppWrap.isShowEditRiskStatusForKam = true;
                }
                
                if(user.Profile.Name == 'Sales User' || user.Profile.Name == 'Sales Manager'){
                    oppWrap.isEditPricingDetails = true;
                    oppWrap.isShowEditPayoutFields = true;
                }else if(user.Profile.Name == 'Risk Operations User' ){
                    oppWrap.isEditPricingDetails = false;
                    oppWrap.isShowEditPayoutFields = false;
                }
                
                else if(grp.size()>0 && (user.Profile.Name != 'System Administrator' || !user.Super_User__c)){
                    for(Group gp : grp){
                        for(GroupMember gm : gp.GroupMembers){
                            if(gp.DeveloperName == 'Cross_Sell_Risk_Team' && gm.UserOrGroupId == user.Id){
                                System.debug('Cross_Sell_Risk_Team '+gm.UserOrGroupId + ' 2343242 '+user.Id);
                                if(gm.UserOrGroupId == user.Id && (user.Profile.Name != 'System Administrator' || !user.Super_User__c)){
                                    oppWrap.isEditable = true;
                                    oppWrap.isCareEditable = false;
                                }else{
                                    oppWrap.isEditable = false;
                                    oppWrap.isCareEditable = false;
                                }
                            }else if(gp.DeveloperName == 'payu_Money' && gm.UserOrGroupId == user.Id){
                                if(gm.UserOrGroupId == user.Id && (user.Profile.Name != 'System Administrator' || !user.Super_User__c)){
                                    oppWrap.isCareEditable = true;
                                    oppWrap.isEditable = false;
                                }else{
                                    oppWrap.isCareEditable = false;
                                    oppWrap.isEditable = false;
                                }
                            }                        
                        }
                    }                
                }else{
                    oppWrap.isEditable = false;
                }
                if(CrossSell_ProductAndUserIdMap.containsKey('MCP')){
                    oppWrap.isEditable = true;
                }
            }
            riskZoneCalculation(oppWrap.opp, oppWrap.crossSell);
            return oppWrap;
        }catch(Exception ex){
            System.debug('ERROR:: '+ex.getMessage());
            System.debug('Line no :: '+ex.getLineNumber());
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String createCrossSellForProduct(Id currentRecId){
        try{
            System.debug('createCrossSellForProduct>>>'+currentRecId);
            List<Opportunity> oppList = new List<Opportunity>();
            //it will hold all the crosssell product name for the perticuller opportunity.
            Set<String> productNameSet = new Set<String>();
            
            List<Cross_Sell__c> csList = new List<Cross_Sell__c>();
            List<Fee_Master__c> insertedFeeMasterList = new List<Fee_Master__c>();
            List<CrossSell_Creation_crit__mdt > crossSellCreationMetadataList = new List<CrossSell_Creation_crit__mdt >();
            Map<string,Fee_Master__c> payoutFeeMasterMap = New Map<string,Fee_Master__c>();
            
            oppList = [SELECT Id,Product_Name__c, (Select Id, Name,Custom_Product__c,Product_Name__c ,Custom_Product__r.Name,Opportunity__c,Bank_Name__c 
                                                   FROM Cross_Sells__r)	From Opportunity Where Id =:currentRecId ];
            if(oppList.size()>0){
                for(Opportunity op: oppList){
                    for(Cross_Sell__c cs: op.Cross_Sells__r){
                        if(cs.Custom_Product__r.Name != null){
                            productNameSet.add(cs.Custom_Product__r.Name);
                        }
                        
                    }
                }
            }
            
            
            for(Fee_Master__c fm : [Select Id,Mode__c,Pricing_Configurator__c,Cross_Sell__r.Custom_Product__r.Name  
                                    from Fee_Master__c WHERE Cross_Sell__r.Custom_Product__r.Name ='Payout' AND
                                    Cross_Sell__r.Opportunity__c =:currentRecId]){
                                        payoutFeeMasterMap.put(fm.Mode__c,fm);
                                    }
            
            
            crossSellCreationMetadataList = [SELECT Active__c  ,Creation_Criteria__c   ,Product_Name__c, ProductNameVsIdMap__c ,ProductVsRecordTypeMap__c  FROM CrossSell_Creation_crit__mdt ];
            System.debug('crossSellCreationMetadataList>>>'+crossSellCreationMetadataList);
            System.debug('productNameSet>>>'+productNameSet);
            if(crossSellCreationMetadataList.size()>0){
                for(CrossSell_Creation_crit__mdt mtd: crossSellCreationMetadataList){
                    if((productNameSet.isEmpty() || !productNameSet.contains(mtd.Product_Name__c)) && mtd.Active__c){
                        System.debug('ifffff>>>');
                        Map<String,String> 	CrossSell_ProductNameVsIdMap =(Map<String, String>)JSON.deserialize(mtd.ProductNameVsIdMap__c, Map<String, String>.class);
                        Map<String,String> 	CrossSell_ProductNameVsRecordTypeIdMap =(Map<String, String>)JSON.deserialize(mtd.ProductVsRecordTypeMap__c , Map<String, String>.class);
                        Cross_Sell__c csObj = new Cross_Sell__c();
                        csObj.Name = mtd.Product_Name__c;
                        csObj.Custom_Product__c = CrossSell_ProductNameVsIdMap.get(mtd.Product_Name__c);
                        csObj.RecordTypeId = CrossSell_ProductNameVsRecordTypeIdMap.get(mtd.Product_Name__c);
                        csObj.Opportunity__c = currentRecId;
                        csObj.Product_Name__c = oppList[0].Product_Name__c;
                        csObj.Source__c = 'Uploaded by System';	
                        csObj.Active__c = true;
                        csList.add(csObj);
                    }
                }
            }
            System.debug('csList>>>'+csList.size());
            if(csList.size()>0){
                insert csList;
                
                
                for(Cross_Sell__c csObj : csList){
                    if(csObj.Name == 'Payout'){
                        
                        Fee_Master__c UPIfeeMaster = new Fee_Master__c();
                        UPIfeeMaster.Mode__c = 'UPI';
                        UPIfeeMaster.Name = 'UPI Payout';
                        UPIfeeMaster.Active__c = true;
                        UPIfeeMaster.Pricing_Configurator__c = '{"0":{"fixed":0,"percent":4},"1001":{"fixed":0,"percent":5},"25001":{"fixed":0,"percent":9}}';
                        UPIfeeMaster.Cross_Sell__c = csObj.Id;
                        insertedFeeMasterList.add(UPIfeeMaster);
                        
                        
                        Fee_Master__c IMPSfeeMaster = new Fee_Master__c();
                        IMPSfeeMaster.Mode__c = 'IMPS';
                        IMPSfeeMaster.Name = 'IMPS Payout';
                        IMPSfeeMaster.Active__c = true;
                        IMPSfeeMaster.Pricing_Configurator__c = '{"0":{"fixed":0,"percent":4.5},"25001":{"fixed":0,"percent":6.5}}';
                        IMPSfeeMaster.Cross_Sell__c = csObj.Id;
                        insertedFeeMasterList.add(IMPSfeeMaster);
                        
                        Fee_Master__c NEFTfeeMaster = new Fee_Master__c();
                        NEFTfeeMaster.Mode__c = 'NEFT';
                        NEFTfeeMaster.Name = 'NEFT Payout';
                        NEFTfeeMaster.Active__c = true;
                        NEFTfeeMaster.Pricing_Configurator__c = '{"0":{"fixed":0,"percent":1.5}}';
                        NEFTfeeMaster.Cross_Sell__c = csObj.Id;
                        insertedFeeMasterList.add(NEFTfeeMaster);
                        
                    }
                }
            }
            
            if(insertedFeeMasterList.size()>0){
                insert insertedFeeMasterList;
            }
            
            return 'success';
        }catch(Exception ex){
            System.debug('ERROR:: '+ex.getMessage());
            System.debug('Line no :: '+ex.getLineNumber());
            return 'Error message - '+ex.getMessage()+ '.Please connect with admin.';
        }
    }
    
    public static opportunity getOpportunity(Id oppId){
        return[Select Id,Legal_Name_Account__c ,Business_Entity__r.Name,BusinessCategory__r.Name,Business_Entity_Formula__c,Business_Category__c, 
               Website__c,Android_URL__c ,Website_Status__c,iOS_URL__c,Key_Assigned_Manager__c,Integration_Type__c,First_Name__c,AccountId,Last_Name__c, Settlement_Status__c from opportunity where Id=:oppId];
    }
    
    public static opportunity getOpportunityFromMID(string mid){
        Integer prodMid = integer.valueOf(mid);
        System.debug('getOpportunityFromMID>>>'+prodMid);
        List<opportunity> opList = new List<opportunity>();
        return[Select Id,Website__c,Android_URL__c ,Website_Status__c,iOS_URL__c,Prod_Merchant_Id__c, AccountId, 
               Key_Assigned_Manager__c,Integration_Type__c,First_Name__c,Last_Name__c, Settlement_Status__c  from opportunity where Prod_Merchant_Id__c=:prodMid];
    }
    
    public static Account getAccount(Id accountId){
        return[Select Id,PAN_Holder_Name__c,PAN_Number__c,Legal_Name__c,Business_Category__r.Name,Business_Entity__r.Name
               /*(SELECT Id, Name, Address_Line__c, Pincode__c, City__c, State__c, Country__c, Type__c
FROM Address_Details__r WHERE Active__c=true AND Type__c IN ('Registered', 'Operating')),
(SELECT Id,URL__c,Document_Category__r.Name  from Merchant_Documents__r 
WHERE KYC_Documentable_Type__c IN ('Account',null) 
AND Active__c=True)*/
               from Account where Id =: accountId];
    }
    
    public static List<Cross_Sell__c> getCrossSell(Id oppId){
        Set<String> strSet = new Set<String>();
        Id productCrossSellRecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Product Cross-Selling').getRecordTypeId();
        Id InstantSettlementRecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Instant Settlement').getRecordTypeId();
        Id PayoutRecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Payout').getRecordTypeId();
        strSet.add(productCrossSellRecordTypeId);
        strSet.add(InstantSettlementRecordTypeId);
        strSet.add(PayoutRecordTypeId);
        return[Select Id,Custom_Product__c,Custom_Product__r.Name,Opportunity__c, Risk_Comment__c
               ,Risk_Status__c,Fee_Master__c,Risk_Zone__c,
               Create_Task__c,Care_Status__c,Care_Comment__c, Kam_Status__c,KAM_Comment__c
               , Source__c,Nature_of_Payout_intended_to_be_made__c,
               Risk_Rejection_Reason__c ,KAM_Merchant_Rejection_Reason__c  , KAM_Current_Location__c ,LegalEmailIdWithRegion__c
               ,Beneficiary_and_Merchant_relationship__c,Does_shareholding_have_China_connection__c,Bank_Name__c,Response__c 
               FROM Cross_Sell__c where Opportunity__c =: oppId AND recordTypeId=:strSet];
    }
    
    public static Case getCase(Id CaseId){
        return [Select Id,Opportunity__c,Merchant_Id__c from Case where Id=:caseId];
    }
    
    @AuraEnabled
    public static List<String> getCrossSellStatus(string sObjectName,string field){
        if(String.isNotBlank(sObjectName) && String.isNotBlank(field)){
            List<String> pickListValuesList= new List<String>();
            Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(field).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            } 
            System.debug(pickListValuesList);
            return pickListValuesList;
        }else
            return null;
        
    }
    
    public static List<Address_Details__c> getAccountAddressDetails(Id accountId){
        return[SELECT Id, Name, Address_Line__c, Pincode__c, City__c, State__c, Country__c, Type__c
               FROM Address_Details__c WHERE Active__c=true AND Type__c IN ('Registered', 'Operating') 
               AND Account__c =: accountId];
    }
    
    public static List<Merchant_Document__c> getAccountMerchantDocDetails(Id accountId){
        return[SELECT Id,URL__c,Document_Category__r.Name  from Merchant_Document__c 
               WHERE KYC_Documentable_Type__c IN ('Account','',null) 
               AND Active__c=True 
               AND Account__c =: accountId];
    }
    
    @AuraEnabled
    public static string updateCrossSellData(string strWrap){
        
        system.debug('strWrap ************* '+strWrap);
        if(String.isNotBlank(strWrap)){
            
            try{
                oppWithAccountWrapper clsWrapperCrossSell = new oppWithAccountWrapper();
                clsWrapperCrossSell = (oppWithAccountWrapper) System.JSON.deserialize(strWrap, oppWithAccountWrapper.class);
                
                List<Cross_Sell__c> lstCrossSell = New List<Cross_Sell__c>();
                List<Fee_Master__c> lstFeeMaster = New List<Fee_Master__c>();
                
                if(clsWrapperCrossSell.lstFeeMaster != null && !clsWrapperCrossSell.lstFeeMaster.isEmpty()){
                    Id feeMasterRecordTypeId = Schema.SObjectType.Fee_Master__c.getRecordTypeInfosByName().get('Payout Agreement').getRecordTypeId();
                    for(Fee_Master__c eachFee : clsWrapperCrossSell.lstFeeMaster){
                        eachFee.RecordTypeId = feeMasterRecordTypeId;
                        eachFee.Name = eachFee.Mode__c +' Payout';
                        lstFeeMaster.add(eachFee);
                    }
                }
                
                if(clsWrapperCrossSell.crossSell != null && !clsWrapperCrossSell.crossSell.isEmpty()){
                    update clsWrapperCrossSell.crossSell;
                }
                
                if(!lstFeeMaster.isEmpty()) upsert lstFeeMaster;
                
                if(clsWrapperCrossSell.crossSell[0].Custom_Product__r.Name != 'MCP' && clsWrapperCrossSell.isTaskToBeCreated && (clsWrapperCrossSell.currentUser.Profile.Name == 'Sales User' || clsWrapperCrossSell.currentUser.Profile.Name == 'System Administrator') ) {
                    Task taskToUpdate = CrossSellTriggerHandler.getTaskCreate(clsWrapperCrossSell.opp.Id,null,System.label.Cross_Sell_Risk_Task_Subject,'','Cross_Sell_Risk_Team',null);
                    taskToUpdate.Priority = 'High';
                    insert taskToUpdate;
                }else if(clsWrapperCrossSell.crossSell[0].Custom_Product__r.Name == 'MCP' && clsWrapperCrossSell.isTaskToBeCreated && (clsWrapperCrossSell.currentUser.Profile.Name == 'Sales User' || clsWrapperCrossSell.currentUser.Profile.Name == 'System Administrator')){
                    Task taskToUpdate = CrossSellTriggerHandler.getTaskCreate(clsWrapperCrossSell.opp.Id,null,'MCP Cross-Sell Task for Product Approval','','Cross_Sell_Risk_Team',null);
                    taskToUpdate.Priority = 'High';
                    insert taskToUpdate;
                }
                
                if(clsWrapperCrossSell.isTaskToBeCreated && (clsWrapperCrossSell.currentUser.Profile.Name == 'Sales User' || clsWrapperCrossSell.currentUser.Profile.Name == 'System Administrator')
                   && !clsWrapperCrossSell.crossSell.isEmpty()){
                       for(Cross_Sell__c eachCS : clsWrapperCrossSell.crossSell){
                           if(String.isNotBlank(eachCS.KAM_Current_Location__c) && eachCS.Custom_Product__r.Name == 'Payout' && String.isNotBlank(eachCS.LegalEmailIdWithRegion__c)){
                               sendEmailToLegal(eachCS.LegalEmailIdWithRegion__c.split(','),eachCS,clsWrapperCrossSell);
                           }
                       }
                   }
                
                if(clsWrapperCrossSell.sendAgreementToMerchant) {
                    sendPayoutAgreement(clsWrapperCrossSell.opp.Id);
                    
                }
                
                return 'Record saved successfully.';
            }catch(Exception ex){
                return 'Error message- '+ex.getMessage()+' Line No.- '+ex.getLineNumber();
            }
        }
        return 'No Record Exist';
    }
    
    @AuraEnabled
    public static List<Attachment> fetchAttachments(Id crossSellId){
        List<Attachment> attList = new List<Attachment>();
        attList = [
            SELECT Id, Body,Name,ParentId
            FROM Attachment
            WHERE ParentId =: crossSellId AND Name Like 'SF%'
        ];
        if(attList.size()> 0){
            return attList;
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static Merchant_Document__c createNewMerchDocument(string crossSell){
        Cross_Sell__c cs = [Select Id,Opportunity__c,Opportunity__r.AccountId,Identifier__c,Bank_Name__c from Cross_Sell__c Where Id =:crossSell LIMIT 1];
        Merchant_Document__c newDoc = new Merchant_Document__c();
        newDoc.Document_Category_Name__c = 'MCP Doc Category';
        newDoc.Document_Type_Name__c = 'MCP Doc Type';
        newDoc.Cross_Sell__c = cs.Id;
        newDoc.Opportunity__c = cs.Opportunity__c;
        newDoc.Account__c = cs.Opportunity__r.AccountId;
        newDoc.KYC_Documentable_Type__c = 'Merchant consent crossSell';
        //newDoc.Cross_Sell_Identifier__c = cs.Identifier__c;
        Insert newDoc;
        return newDoc;
    }
    
    @AuraEnabled
    public static List<Merchant_Document__c> getMerchantDocList(string parentId){
        return [Select Id,Name,URL__c,Request_Type__c,Document_Type__c,Document_Content_Type__c 
                from Merchant_Document__c where Cross_Sell__c =: parentId AND KYC_Documentable_Type__c =:'Merchant consent crossSell'];
    }
    
    @AuraEnabled
    public static List<Merchant_Document__c> deleteMerchDocument(string mdRecordId){
        try{
            Merchant_Document__c deletedMD = [Select Id,Cross_Sell__c from Merchant_Document__c Where Id =:mdRecordId LIMIT 1];
            string csId = deletedMD.Cross_Sell__c;
            delete deletedMD;
            List<Merchant_Document__c> refreshList = getMerchantDocList(csId);
            return refreshList;
        }catch(Exception ex){
            return null;
        }
    }
    
    @AuraEnabled
    public static string updateRiskStatusToReEvaluate(string crossSellId){
        try{
            if(string.isNotBlank(crossSellId)){
                Cross_Sell__c updatedCross = [Select Id,Risk_Status__c,Re_Evaluate_Count__c,Bank_Name__c from Cross_Sell__c where Id=:crossSellId];
                updatedCross.Re_Evaluate_Count__c = updatedCross.Re_Evaluate_Count__c==null ? 1 : updatedCross.Re_Evaluate_Count__c + 1;
                updatedCross.Risk_Status__c = 'Re-Evaluate';
                update updatedCross;
            }
            return 'Success';
        }catch(Exception ex){
            return 'Error Line No- '+ex.getLineNumber()+' Error message- '+ex.getMessage();
        }
    }
    
    public static List<Fee_Master__c> getFeeMasters(List<Cross_Sell__c> crossSells){
        Set<String> csIds = New Set<String>();
        for(Cross_Sell__c cs : crossSells){
            if(cs.Custom_Product__r.Name == 'Payout'){
                csIds.add(cs.Id);
            }
        }
        
        if(!csIds.isEmpty()){
            List<Fee_Master__c> feeMasterList = [Select Id,Mode__c,Pricing_Configurator__c,Cross_Sell__r.Risk_Status__c from Fee_Master__c Where Cross_Sell__c IN: csIds];
            return feeMasterList;
        }
        return null;
    }
    
    public static void sendEmailToLegal(List<string> toAddress,Cross_Sell__c csObj,oppWithAccountWrapper csWrapperData){
        EmailTemplate objTemplate = [SELECT id, Name FROM EmailTemplate WHERE DeveloperName =:'Payout_Agreement_Pricing_Legal_Detail'  LIMIT 1];
        system.debug('###### '+csObj.Id);
        system.debug('###### toAddress '+toAddress);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddress);
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setTemplateId(objTemplate.Id);
        mail.setWhatId(csObj.Id);
        mail.setSaveAsActivity(false);
        /*
Messaging.SingleEmailMessage bodyMail = new Messaging.SingleEmailMessage();
bodyMail.setSubject('Payout Activation Request');
bodyMail.setToAddresses(toAddress);
String messageBody = '<html><body>Hi Team,'+'\n'+'<br/>'+' Please see merchant details for activation the payout-'+'\n'+'<br/>'+
'<b>1. Name of the Merchant :</b> '+csWrapperData.opp.First_Name__c+' '+csWrapperData.opp.Last_Name__c+ '\n'+'<br/>'+
'<b>2. Organisation Type :</b> '+csWrapperData.acc.Business_Entity__r.Name+ '\n'+'<br/>'+
'<b>3. Merchant Line of business :</b> '+csWrapperData.acc.Business_Category__r.Name+ '\n'+'<br/>'+
'<b>4. Merchant Website :</b> '+csWrapperData.opp.Website__c+ '\n'+'<br/>'+
'<b>5. Nature of Payout intended to be made :</b> '+csObj.Nature_of_Payout_intended_to_be_made__c+ '\n'+'<br/>'+
'<b>6. What is the underlying arrangement between Merchant and beneficiaries for which Payout is proposed? :</b> '+csObj.Beneficiary_and_Merchant_relationship__c+ '\n'+'<br/>'+
'<b>7. Certificate of Incorporation :</b> '+'<a href='+csWrapperData.merchantDocLink+'>'+csWrapperData.merchantDocLink+'</a>'+ '\n'+'<br/>'+
'<b>8. Registered Address Details/Address Proof :</b> '+'\n'+'<br/>'+
'<table width="581" border="1">'+'\n'+'<br/>'+
'<tr>'+
'<td> Address </td>'+
'<td> City </td>'+
'<td> State </td>'+
'<td> Country </td>'+
'<td> Pincode </td>'+
'</tr>'+
'<tr>'+
'<td>'+ csWrapperData.regAddress.Address_Line__c +'</td>'+
'<td>'+ csWrapperData.regAddress.City__c +'</td>'+
'<td>'+ csWrapperData.regAddress.State__c +'</td>'+
'<td>'+ csWrapperData.regAddress.Country__c +'</td>'+
'<td>'+ csWrapperData.regAddress.Pincode__c +'</td>'+
'</tr>'+
'</table>'+
'<b>9. Operating Address Details/Address Proof :</b> '+ '\n'+'<br/>'+
'<table width="581" border="1">'+'\n'+'<br/>'+
'<tr>'+
'<td> Address </td>'+
'<td> City </td>'+
'<td> State </td>'+
'<td> Country </td>'+
'<td> Pincode </td>'+
'</tr>'+
'<tr>'+
'<td>'+ csWrapperData.opAddress.Address_Line__c +'</td>'+
'<td>'+ csWrapperData.opAddress.City__c +'</td>'+
'<td>'+ csWrapperData.opAddress.State__c +'</td>'+
'<td>'+ csWrapperData.opAddress.Country__c +'</td>'+
'<td>'+ csWrapperData.opAddress.Pincode__c +'</td>'+
'</tr>'+
'</table>'+
'<b>10. Commercial Rates agreed with the Merchant :</b> Please see another email.'+ '\n'+'<br/>'+

'<b>11. Whether the Merchant using our PG services? :</b> '+csWrapperData.opp.Integration_Type__c+ '\n'+'<br/>'+
'</body>  </html>';

bodyMail.setHtmlBody(messageBody); 
*/
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    @AuraEnabled
    public static void createContract(Account accObj, Contact authContObj, Boolean isFinal, Opportunity optyObj,string contractType){
        if(contractType == 'PayoutAgreement'){
            WrapperSendAgreement clsWrapperSendAgreement = SendAgreementController.getOpportunityRecord(optyObj.Id,true);
            if(clsWrapperSendAgreement.optyRelatedPayoutContract == null){
                clsWrapperSendAgreement.optyRelatedPayoutContract = SendAgreementController.createContract(clsWrapperSendAgreement.accObj,clsWrapperSendAgreement.authSignContact,true,clsWrapperSendAgreement.oppObj,'PayoutAgreement');
            }
        }
    }
    
    @future(callout=true)
    public static void sendPayoutAgreement(Id OppId){
        WrapperSendAgreement clsWrapperSendAgreement = SendAgreementController.getOpportunityRecord(OppId,true);
        
        clsWrapperSendAgreement.optyRelatedPayoutContract.Document_Content_Type__c = 'application/pdf';
        If(!Test.isRunningTest()) String sentMessage = SendAgreementController.sendMailWithAttachment(clsWrapperSendAgreement.oppObj,clsWrapperSendAgreement.authSignContact,clsWrapperSendAgreement.lstDocMasterPayoutAgreement[0].Id,null,true,clsWrapperSendAgreement.optyRelatedPayoutContract,'PayoutAgreement',true,clsWrapperSendAgreement.counterSignedContract);
        //system.debug('@@@@@@@@@ sentMessage '+sentMessage);
    }
    
    public static List<Cross_Sell__History> getCrossSellHistory(Id csellObjId){
        return[SELECT CreatedById,CreatedDate,CreatedBy.Name,DataType,Field,Id,IsDeleted,NewValue,OldValue,ParentId 
               FROM Cross_Sell__History
               WHERE ParentId =:csellObjId ORDER BY CreatedDate DESC];
    }
    
    //It will Create a task for the risk team when user user click on create task icon For MCP Product	
    @AuraEnabled	
    public static string createTaskForRiskTeam(string strWrap,String productName, string teamName){	
        try{	
            System.debug('strWrap  '+strWrap);	
            oppWithAccountWrapper clsWrapperCrossSell = new oppWithAccountWrapper();	
            clsWrapperCrossSell = (oppWithAccountWrapper) System.JSON.deserialize(strWrap, oppWithAccountWrapper.class);	
            System.debug('clsWrapperCrossSell'+clsWrapperCrossSell);	
            String task_subject = productName+' Cross-Sell Task for Product Approval';	
            if(clsWrapperCrossSell.isTaskToBeCreated != null && clsWrapperCrossSell.isTaskToBeCreated && (teamName=='Risk Team' || teamName=='')
               && (clsWrapperCrossSell.currentUser.Profile.Name == 'Sales User' || clsWrapperCrossSell.currentUser.Profile.Name == 'System Administrator' || clsWrapperCrossSell.currentUser.Profile.Name =='Merchant Care User') ) {	
                   Task taskToUpdate = CrossSellTriggerHandler.getTaskCreate(clsWrapperCrossSell.opp.Id,null,task_subject,'','Cross_Sell_Risk_Team',null);	
                   taskToUpdate.Priority = 'High';	
                   insert taskToUpdate;	
               }
            
            if(clsWrapperCrossSell.isTaskToBeCreated != null && clsWrapperCrossSell.isTaskToBeCreated && (teamName=='KAM Task')
               && (clsWrapperCrossSell.currentUser.Profile.Name == 'System Administrator' || clsWrapperCrossSell.currentUser.Profile.Name =='Merchant Care User') ) {	
                   Map<Id,Opportunity> oppIdMAp = New Map<Id,Opportunity>();
                   if(clsWrapperCrossSell.opp != null) oppIdMAp.put(clsWrapperCrossSell.Opp.Id,clsWrapperCrossSell.Opp);
                   Task taskToUpdate = CrossSellTriggerHandler.getTaskCreate(clsWrapperCrossSell.opp.Id,oppIdMAp,'T+0 Merchant Interested And Risk Approved','','null',null);	
                   taskToUpdate.Priority = 'High';	
                   insert taskToUpdate;	
               }
            return 'Success';	
        }catch(Exception ex){	
            return 'Error Line No- '+ex.getLineNumber()+' Error message- '+ex.getMessage();	
        }	
        
        
    }	
    
    public static void riskZoneCalculation(Opportunity eachOpp,List<Cross_Sell__c> csList){	
        try{	
            Set<Id> oppIdSet = new Set<Id>();	
            List<Cross_Sell__c> CrossSellList2 = new List<Cross_Sell__c>();	
            Map<String,List<Cross_Sell__c>> oppIdVsCrossSellMap = new Map<String,List<Cross_Sell__c>>();	
            Map<String,String> crossSellProductNameVsIDMap = new Map<String,String>();	
            Batch_Setting__mdt batchSetting = new Batch_Setting__mdt();	
            batchSetting = [SELECT MasterLabel,Fields_To_Query__c,Cross_Sell_Creation_Criteria__c , Iteration_Count__c, Record_Limit__c,Active__c, Where_Clause__c FROM Batch_Setting__mdt WHERE MasterLabel = 'CrossSellCreationForOpportunity' AND Active__c = true LIMIT 1];	
            crossSellProductNameVsIDMap = (Map<String,String>)JSON.deserialize(batchSetting.Cross_Sell_Creation_Criteria__c ,Map<String, String>.class);	
            List<Product__c> productEnableFor = new List<Product__c>();	
            productEnableFor = [SELECT Id,Name FROM Product__c where Id IN: crossSellProductNameVsIDMap.values()];	
            List<String> productIdListForNotExistingCrossSell = crossSellProductNameVsIDMap.values();	
            List<Cross_Sell__c> crossSellList = new List<Cross_Sell__c>();	
            List<Cross_Sell__c> cs_List = new List<Cross_Sell__c>();//new	
            List<Cross_Sell__c> cs_ListToUpdate = new List<Cross_Sell__c>();//new	
            List<CrossSell_Creation_crit__mdt > crossSellCreationMetadataList = new List<CrossSell_Creation_crit__mdt >();//new	
            crossSellCreationMetadataList = [SELECT Active__c  ,Creation_Criteria__c   ,Product_Name__c, ProductNameVsIdMap__c ,ProductVsRecordTypeMap__c  FROM CrossSell_Creation_crit__mdt ];	
            if(eachOpp != null){	
                
                if(csList.size()>0){	
                    for(Cross_Sell__c cs:csList){	
                        if(cs.Opportunity__c == eachOpp.id){	
                            if(eachOpp.Website_Status__c == 'Website OK' && eachOpp.Settlement_Status__c == 'Active' && eachOpp.Aging__c >= 90 && eachOpp.CB_Ratio__c < 0.5 && eachOpp.Last_6_months_GMV__c >= 200000.00 && cs.Custom_Product__r.Name == 'T+0'){	
                                cs.Risk_Zone__c = 'Green Zone';	
                                cs.Risk_Status__c = 'Approved';	
                                cs.Cross_Sell_Stop_Task_Creation__c  = true;	
                                cs_ListToUpdate.add(cs);	
                            }else if(cs.Custom_Product__r.Name == 'T+0'){	
                                cs.Risk_Zone__c = 'Amber Zone';	
                                if(cs.Kam_Status__c == ''){	
                                    cs.Risk_Status__c = 'Pending';	
                                }	
                                cs_ListToUpdate.add(cs);	
                            }	
                        }	
                    }	
                }
                if(cs_ListToUpdate.size()> 0){	
                    System.debug('cs_ListToUpdate::>>'+cs_ListToUpdate);	
                    update cs_ListToUpdate;	
                }	
            }	
        }catch(Exception ex){	
            System.debug('ERROR: '+ex.getMessage());	
            System.debug('Line No: '+ex.getLineNumber());	
        }	
    }
    
    @AuraEnabled
    public static string getMerchantAdminIdentifier(Id currentRecId){
        Map<string,Cross_Sell__c> oppIdWithCrossSellMap = New Map<String,Cross_Sell__c>();
        List<Cross_Sell__c> csObjList = New List<Cross_Sell__c>();
        Map<String,Opportunity> oppDataMap = New Map<string,Opportunity>();
        string accesstoken;
        string merchantAdminUUID = '';
        
        if(!Test.isRunningTest()){
            accesstoken = IntegrationUtility.getAuthToken('Payout_Authentication');
        }else{
            accesstoken = 'b74acb75e87f93aa9db8073d570753474e58702aa9e91af4054478bba98af38e';
        }
        Integration_Setting__mdt theIntIns = IntegrationUtility.getIntSetting('Payout_get_user_uuid');
        
        for(Opportunity opp : [Select Id,Identifier__c,First_Name__c ,Last_Name__c,Email__c,Mobile__c,Prod_MID__c,(Select Id,User_UUID__c,Bank_Name__c,Merchant_Name__c,Opportunity_Identifier__c From Cross_Sells__r Where Custom_Product__r.Name ='Payout') from Opportunity where Id =: currentRecId]){
            csObjList = opp.Cross_Sells__r;
        }
        
        HttpResponse response = IntegrationUtility.requestUtility(theIntIns, False, accesstoken, csObjList[0], null, null);
        if(response != null && response.getStatusCode() == 200 || Test.isRunningTest()){
            Map<String, Object> theResMap ;
            if(!Test.isRunningTest()){
                theResMap = (Map<String, Object>)JSON.deserializeUntyped(response.getbody());
            }else{
                theResMap = (Map<String, Object>)JSON.deserializeUntyped('{"merchants": [{"admin_user_uuid": "11eb-50c3-247600b4-9cc4-02f413145cce","uuid": "11eb-50c3-19ac023c-93c8-02053299b2da"}]}');
            }
            Object deserializedMerchantData = theResMap.get('merchants');
            String serializedMerchantData = JSON.serialize(deserializedMerchantData);
            List<Object> merchantDataListResponse = (List<Object>) JSON.deserializeUntyped(serializedMerchantData);
            string payoutAccessToken = '';
            
            for(Integer i=0;i<merchantDataListResponse.size();i++) {
                String strLine = JSON.serialize(merchantDataListResponse[i]);
                Map<String, Object> responseMapLine = (Map<String, Object>) JSON.deserializeUntyped(strLine);
                system.debug('responseMapLine2200 : '+responseMapLine);
                if(responseMapLine.containsKey('admin_user_uuid')){
                    system.debug('responseMapLine22 : '+responseMapLine.get('admin_user_uuid'));
                    system.debug('responseMapLine2222 : '+responseMapLine.get('uuid'));
                    
                    string merchantUUID = String.valueOf(responseMapLine.get('uuid'));
                    merchantAdminUUID = String.valueOf(responseMapLine.get('admin_user_uuid'));
                    csObjList[0].User_UUID__c = merchantAdminUUID;
                    
                }
            }
        }
        system.debug('oppIdWithCrossSellMap : '+oppIdWithCrossSellMap);
        
        if(!csObjList.isEmpty()) update csObjList;
        return merchantAdminUUID;
    }
    
    public class oppWithAccountWrapper{
        @AuraEnabled
        public Account acc{get;set;}
        @AuraEnabled
        public opportunity opp{get;set;}
        @AuraEnabled
        public Case cs{get;set;}
        @AuraEnabled
        public List<Cross_Sell__c> crossSell{get;set;}
        @AuraEnabled
        public boolean isEditable{get;set;}
        @AuraEnabled
        public boolean isCareEditable{get;set;}
        @AuraEnabled
        public boolean showCarePanel{get;set;}
        @AuraEnabled
        public boolean showCarePanelMsg{get;set;}
        @AuraEnabled
        public boolean showRiskPanel{get;set;}
        @AuraEnabled
        public List<Group> groupList{get;set;}
        @AuraEnabled
        public User currentUser{get;set;}
        @AuraEnabled
        public boolean isShowEditKamStatus{get;set;}
        @AuraEnabled
        public boolean isShowEditRiskStatusForKam{get;set;}
        @AuraEnabled
        public List<Fee_Master__c> lstFeeMaster{get;set;}
        //pricing fields is editable for sales disable for risk user.
        @AuraEnabled
        public boolean isEditPricingDetails{get;set;}
        @AuraEnabled
        public Boolean isShowEditPayoutFields {get;set;}
        @AuraEnabled
        public Boolean isTaskToBeCreated {get;set;}
        @AuraEnabled
        public Address_Details__c regAddress {get;set;} 
        @AuraEnabled
        public Address_Details__c opAddress {get;set;}
        @AuraEnabled
        public string merchantDocLink {get;set;}
        @AuraEnabled
        public Boolean sendAgreementToMerchant {get;set;}
        //@AuraEnabled
        //public List<Cross_Sell__History> crossSellHistory = New List<Cross_Sell__History>();//{get;set;}
    }
}