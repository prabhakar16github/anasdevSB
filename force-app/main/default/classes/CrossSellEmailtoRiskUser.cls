public class CrossSellEmailtoRiskUser {
    public ApexPages.StandardSetController setCon;
    public list<Cross_sell__c> CrossSellLst {get;set;}
    
    public CrossSellEmailtoRiskUser(ApexPages.StandardSetController controller) {
        setCon = controller;         
    }
    
    public CrossSellEmailtoRiskUser() {
        
    }
    
    public integer getMySelectedSize() {        
        return setCon.getSelected().size();
    }
    
    public List<Cross_sell__c> getSelectedCrossSell() {        
        return setCon.getSelected();
    }
    
    public List<Cross_sell__c> getSelectedCs(){
        List<Cross_sell__c> selectedCs = new List<Cross_sell__c>();	
        
        CrossSellLst= [Select ID, Risk_Status__c,Risk_Manager_Status__c from Cross_sell__c where Id IN:setCon.getSelected()];
        
        update selectedCs;
        return selectedCs;
        
    }
    
    public void sendEmailtoRiskTeam(){
        try{
            getSelectedCs();
            
            List<GroupMember> groupMember = [SELECT Id, GroupId,group.name,group.DeveloperName, UserOrGroupId 
                                             FROM GroupMember where Group.DeveloperName='Pre_Onboarding_Risk_Team'];
            Set<Id> userIdSet = new Set<Id>();
            for(GroupMember gm: groupMember){
                userIdSet.add(gm.UserOrGroupId);
            }
            List<User> userList = [SELECT Id, Name,IsActive, Title, Email FROM User where Id IN:userIdSet AND IsActive=true and Email != null];
            String[] toEmailAddress = New List<string>();
            //String[] ccEmailAddress = New List<string>();
            for(User u: userList){
                if(u.IsActive) toEmailAddress.add(u.Email);
            }
            Messaging.singleEmailmessage Email =new Messaging.singleEmailmessage();
            EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                           from EmailTemplate where name = 'Request Email to Risk Team'];
            Email.setsubject('PayU Instant Settlement Re-evaluation');
            Email.setHtmlBody(emailTemplate.HtmlValue);
            
            Email.SetToAddresses(toEmailAddress);
            Messaging.sendemailResult[] results = Messaging.sendemail(new Messaging.singleEmailmessage[]{email});
            
        }catch(Exception ex){
            
        }
    }
    
    @AuraEnabled
    public static string sendEmailtoRiskTeam(List<Cross_Sell__c> csToUpdate){
        try{
            if(!csToUpdate.isEmpty() && csToUpdate.size()>0 && csToUpdate != null) update csToUpdate;
            
            List<GroupMember> groupMember = [SELECT Id, GroupId,group.name,group.DeveloperName, UserOrGroupId 
                                             FROM GroupMember where Group.DeveloperName='Pre_Onboarding_Risk_Team'];
            Set<Id> userIdSet = new Set<Id>();
            for(GroupMember gm: groupMember){
                userIdSet.add(gm.UserOrGroupId);
            }
            List<User> userList = [SELECT Id, Name,IsActive, Title, Email FROM User where Id IN:userIdSet AND IsActive=true and Email != null];
            String[] toEmailAddress = New List<string>();
            //String[] ccEmailAddress = New List<string>();
            for(User u: userList){
                if(u.IsActive) toEmailAddress.add(u.Email);
            }
            Messaging.singleEmailmessage Email =new Messaging.singleEmailmessage();
            EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                           from EmailTemplate where name = 'Request Email to Risk Team'];
            Email.setsubject('PayU Instant Settlement Re-evaluation');
            Email.setHtmlBody(emailTemplate.HtmlValue);
            
            Email.SetToAddresses(toEmailAddress);
            Messaging.sendemailResult[] results = Messaging.sendemail(new Messaging.singleEmailmessage[]{email});
            if (results[0].success) {
                return 'Success';
            } 
        }catch(Exception ex){
            return null;
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Cross_Sell__c> getCrossSellSelectedRec(List<string> selectedIds){
        List<Cross_Sell__c> csList = new List<Cross_Sell__c>();
        system.debug('@#@####### !!!!!!!!selectedIds '+selectedIds);
        List<String> IdList = new List<string>();
        
        if(selectedIds != null){
            if(string.valueOf(selectedIds).startsWith('([')){
                String removeStart = string.valueOf(selectedIds).removeStart('([');
                String removeEnd = removeStart.removeEnd('])');
                IdList = removeEnd.split(', ');
            }
            
            system.debug('@#@####### IdList '+IdList);
            for(Cross_Sell__c cs : [Select Id,Risk_Status__c,Risk_Comment__c
                                    ,Opportunity__r.Name,RecordTypeId,
                                    CreatedDate,Legal_Name__c,Risk_Manager_Comment__c,Risk_Manager_Status__c,
                                    Risk_Manager_Approver__c,Risk_User_Approver__c,Re_Evaluate_Count__c from Cross_Sell__c 
                                    where Id IN: IdList]){
                                        if(cs.Re_Evaluate_Count__c == null) cs.Re_Evaluate_Count__c = 1;
                                        else cs.Re_Evaluate_Count__c = cs.Re_Evaluate_Count__c + 1;
                                        
                                        cs.Uploaded_by_Team__c = 'Business Team';
                                        csList.add(cs);                                        
                                    }
            update csList;
            return csList;
        }
        system.debug('@#@####### selectedIds '+selectedIds);
        
        system.debug('@#@#######csList '+csList);
        
        // }        
        return null;
    }
    
    @AuraEnabled
    public static Merchant_Document__c uploadDocToS3(string fileName , String base64Data, String contentType,string recordId){
        Merchant_Document__c merDoc ;
        string strEndPoint = '';
        if(String.isNotBlank(recordId)){
            Cross_Sell__c eachCS = [Select Id,Opportunity__r.Identifier__c,Opportunity__r.Account.Identifier__c from Cross_Sell__c Where Id=:recordId];
            merDoc = new Merchant_Document__c();
            merDoc.Document_Category_Name__c = 'MCP Doc Category';
            merDoc.Document_Content_Type__c = contentType;
            merDoc.Document_Type_Name__c = 'MCP Doc Type';
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            Blob body = EncodingUtil.base64Decode(base64Data);
            if(!test.isRunningTest()){
                strEndPoint = AWSUtility.uploadAndGetDocUrlS3(merDoc, eachCS.Opportunity__r.Identifier__c, body);
            }else{
                strEndPoint = 'test';
            }
            
            
            if(String.isNotBlank(strEndPoint)){                
                merDoc.Active__c = true;
                merDoc.URL__c = strEndPoint;
                merDoc.Opportunity__c = eachCS.Opportunity__c;
                merDoc.Account__c = eachCs.Opportunity__r.AccountId;               
                merDoc.Cross_Sell__c = eachCS.Id;
                merDoc.KYC_Documentable_Type__c = 'CrossSellDocument';                
                Insert merDoc;
            }
            return merDoc ;
        }
        return merDoc;
    }
    
    @AuraEnabled
    public static List<Merchant_Document__c> getMerchantDocList(string parentId){
        return [Select Id,Name,URL__c,Request_Type__c,Document_Type__c,Document_Content_Type__c 
                from Merchant_Document__c where Cross_Sell__c =: parentId AND KYC_Documentable_Type__c =:'CrossSellDocument' 
                AND Cross_Sell__r.Re_Evaluate_Count__c>0];
    }
    
    @AuraEnabled
    public static List < String > getselectOptions(string objectStr, string fld) {
        List < String > allOpts = new list < String > ();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectStr) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fld).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        // Add these values to the selectoption list.
        
        for (Schema.PicklistEntry a: ple) {
            allOpts.add(a.getValue());
        }
        system.debug('allOpts ---->' + allOpts);
        //allOpts.sort();
        return allOpts;
    }
    
    @AuraEnabled
    public static Merchant_Document__c createNewMerchDocument(string crossSell){
        Cross_Sell__c cs = [Select Id,Opportunity__c,Opportunity__r.AccountId from Cross_Sell__c Where Id =:crossSell LIMIT 1];
        Merchant_Document__c newDoc = new Merchant_Document__c();
        newDoc.Document_Category_Name__c = 'MCP Doc Category';
        newDoc.Document_Type_Name__c = 'MCP Doc Type';
        newDoc.Cross_Sell__c = cs.Id;
        newDoc.Opportunity__c = cs.Opportunity__c;
        newDoc.Account__c = cs.Opportunity__r.AccountId;
        newDoc.KYC_Documentable_Type__c = 'CrossSellDocument';
        Insert newDoc;
        return newDoc;
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
    
    // method for user login in site
    @AuraEnabled
    public static crossSellWrapper getUserIdentity(string emailId){
        crossSellWrapper csObjWrapper = New crossSellWrapper();
        List<Object> crossSellUserManagerLabel = (List<Object>)JSON.deserializeUntyped(System.Label.CrossSell_UserandManagerMap);
        system.debug('emailAdd=='+emailId);
        for(object obj : crossSellUserManagerLabel){
            Map<string,object> objMap =  (Map<string,object>)obj;
            if((string)objMap.get('email') == emailId){
                system.debug('owner type =='+objMap.get('owner'));
                if((string)objMap.get('owner') == 'User'){
                    csObjWrapper.userORmanager = 'User';
                    csObjWrapper.userORmanagerId = (string)objMap.get('id');
                    csObjWrapper.checkPresence = true;
                    csObjWrapper.userORmanagerEmailId = emailId;
                    csObjWrapper.userORmanagerName = (string)objMap.get('name');
                }
                else if((string)objMap.get('owner') == 'Manager'){
                    csObjWrapper.userORmanager = 'Manager';
                    csObjWrapper.userORmanagerId = (string)objMap.get('id');
                    csObjWrapper.checkPresence = true;
                    csObjWrapper.userORmanagerEmailId = emailId;
                    csObjWrapper.userORmanagerName = (string)objMap.get('name');
                }
                csObjWrapper.crossSellLst = fetchCrossSell();
            }else if(csObjWrapper == null){
                csObjWrapper.checkPresence = false;
            }
        }
        return csObjWrapper;
    }
    
    // method for fetch crossSell records list  
    @AuraEnabled
    public static List<Cross_Sell__c> fetchCrossSell(){
        System.debug('Inside fetchCrossSell');
        
        //string[] str = crossSellUserManagerMap.get('User').split(',');
        Id InstantSettlementRecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Instant Settlement').getRecordTypeId();
        List<Cross_Sell__c> lstOfcrossSell =  [select id, Risk_Status__c,Risk_Comment__c
                                               ,Opportunity__r.Name,Re_Evaluate_Count__c,
                                               RecordTypeId,CreatedDate,Legal_Name__c,Risk_Manager_Comment__c,Request_Type__c,
                                               Risk_Manager_Status__c,Risk_User_Approver__c,Risk_Manager_Approver__c,Uploaded_by_Team__c
                                               from Cross_Sell__c where RecordTypeId =: InstantSettlementRecordTypeId 
                                               AND LastModifiedDate = LAST_N_DAYS:15];
        
        return lstOfcrossSell;
    }
    
    // method for update records after inline editing  
    @AuraEnabled
    public static List<Cross_Sell__c> saveCrossSell(List<Cross_Sell__c> lstCrossSell,string userORmanager,string riskUserORmanagerId) {
        integer sendEmailRiskManager = 0;
        integer sendEmailBusinessUser = 0;
        Map<Id,Cross_Sell__c> updatedCSMap = new Map<Id,Cross_Sell__c>();
        System.debug('###########lstCrossSell '+lstCrossSell);
        System.debug('###########csObj.userORmanager '+userORmanager);
        if(!lstCrossSell.isEmpty()){            
            for(Cross_Sell__c eachCrossSell : lstCrossSell){
                if(eachCrossSell.Risk_Status__c !='Pending' && userORmanager=='User') {
                    eachCrossSell.Uploaded_by_Team__c = 'Risk Team';
                    eachCrossSell.Risk_User_Approver__c = riskUserORmanagerId;
                }
                
                if(eachCrossSell.Risk_Manager_Status__c !='Pending' && userORmanager=='Manager'){
                    eachCrossSell.Uploaded_by_Team__c = 'Risk Team';                
                    eachCrossSell.Risk_Manager_Approver__c = riskUserORmanagerId;
                }
                
                updatedCSMap.put(eachCrossSell.Id,eachCrossSell);
            } 
        }
        System.debug('########### updatedCSMap '+updatedCSMap);
        if(!updatedCSMap.isEmpty()){
            Database.SaveResult[] results = Database.update(updatedCSMap.values(),false);
            for(Database.SaveResult sr : results){
                if(sr.isSuccess()){
                    System.debug('########### updatedCSMap sr '+updatedCSMap);
                    if(updatedCSMap.containsKey(sr.getId())){
                        if((updatedCSMap.get(sr.getId()).Risk_Manager_Status__c == 'Pending' || String.isBlank(updatedCSMap.get(sr.getId()).Risk_Manager_Status__c)) && 
                           (updatedCSMap.get(sr.getId()).Risk_Status__c == 'Approved') && String.isBlank(updatedCSMap.get(sr.getId()).Risk_Manager_Approver__c)){                       
                               sendEmailRiskManager++;
                           }
                        else if(updatedCSMap.get(sr.getId()).Risk_Manager_Status__c == 'Approved' && updatedCSMap.get(sr.getId()).Risk_Status__c == 'Approved'){
                            sendEmailBusinessUser++;
                        }
                    }
                }else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
                
            }
        }
        if(sendEmailRiskManager>0){
            System.debug('sendEmailManager'+sendEmailRiskManager);
            system.debug('sendEmailBusinessUser'+sendEmailBusinessUser);
            CrossSellTriggerHandler.sendEmailCommonMethod('PayU Instant Settlement', 'Request Email to Risk Manager',
                                                          'Cross_Sell_Risk_Manager_Team', new List<Attachment>());            
            }
            else if(sendEmailBusinessUser>0){
                CrossSellTriggerHandler.sendEmailCommonMethod('PayU Instant Settlement', 'Notification Email to Business',
                                                          'Cross_Sell_Business_Team', new List<Attachment>());                
            }
                
        return updatedCSMap.values();
    }
    
    // method for fetch picklist values dynamic  
    @AuraEnabled
    public static List<String> getselectOptions(sObject objectType, string fld) {
        system.debug('bjectType --->' + objectType);
        system.debug('fld --->' + fld);
        List<String> allOpts = new list <String> ();
        // Get the object type of the SObject.
        map <String, Schema.SObjectField> fieldMap = objectType.getSObjectType().getDescribe().fields.getMap();        
        // Get the list of picklist values for this field.
        list <Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            if(a.getValue() =='Approved' || a.getValue() =='Rejected' ||a.getValue() =='Pending' ){
                allOpts.add(a.getValue());
            }
            
        }
        system.debug('allOpts ---->' + allOpts);
        allOpts.sort();
        System.debug('allOpts'+allOpts);
        return allOpts;
    } 
    
    @AuraEnabled
    public static Cross_Sell__c saveTheFile(Id parentId, String fileName, String base64Data, String contentType, Cross_Sell__c crossSellRecord) { 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = new Attachment();
        a.parentId = parentId;
        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = contentType;
        system.debug('a.Body==='+a.Body);
        insert a;        
        update crossSellRecord;
        return crossSellRecord;
    }
    
    
    public class crossSellWrapper{
        @AuraEnabled
        public list<Cross_Sell__c> crossSellLst;
        @AuraEnabled
        public Boolean checkPresence;
        @AuraEnabled
        public string userORmanager;
        @AuraEnabled
        public string userORmanagerId;
        @AuraEnabled
        public string userORmanagerEmailId;
        @AuraEnabled
        public string userORmanagerName;
    }
    
}