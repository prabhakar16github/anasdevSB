public class OneCare_ClickToCallController {
    
    @AuraEnabled
    public static c2cWrapper getClick2CallData(string sObjectId, string sObjectName, String mobileNumber){
        c2cWrapper wrapperObj = New c2cWrapper();
        Set<Id> conIdSet = new Set<Id>();
        List<Contact> contactList = new List<Contact>();
        try{
            List<sObject> sobQueriedDataList = getSObjectData(sObjectId, sObjectName);
            
            wrapperObj.userObj = [Select Id,MobilePhone, Name,Profile.Name from User Where Id=: UserInfo.getUserId()];
            
            if(sObjectName == 'Opportunity'){
                Opportunity OpportunityObj = (Opportunity)sobQueriedDataList[0];
                List<OpportunityContactRole> oppConRoleList = getOpportunityConRoleData(sObjectId);
                if(oppConRoleList != null){
                    for(OpportunityContactRole ocr: oppConRoleList){
                        conIdSet.add(ocr.ContactId);
                    } 
                }
                
                if(!conIdSet.isEmpty()) wrapperObj.contactDetails = getContactData(conIdSet, '', contactList);
                
                String monNum = '%'+OpportunityObj.Mobile__c;
                List<Contact> conList = new List<Contact>();
                if(mobileNumber == null){
                    conList = [SELECT Id, Name, MobilePhone,AccountId FROM Contact where AccountId =:OpportunityObj.AccountId AND MobilePhone Like: monNum LIMIT 1];
                }
                if(conList.size() > 0){
                    wrapperObj.customerName = conList[0].Name;
                    wrapperObj.customerNumber = conList[0].MobilePhone;
                }else{
                    String firstName = String.isNotBlank(OpportunityObj.First_Name__c) ? OpportunityObj.First_Name__c : '';
                    String lastName =  String.isNotBlank(OpportunityObj.Last_Name__c) ? OpportunityObj.Last_Name__c : '';
                    wrapperObj.customerName =  firstName + ' '+lastName;
                    wrapperObj.customerNumber =  OpportunityObj.Mobile__c;
                }
                
            }else if(sObjectName == 'Lead'){
                Lead LeadObj = (Lead)sobQueriedDataList[0];
                LeadObj.Merchant_Name__c = LeadObj.Name;
                LeadObj.Merchant_Mobile__c = LeadObj.MobilePhone;
                wrapperObj.leadObj = LeadObj;
                wrapperObj.customerName = LeadObj.Name;
                wrapperObj.customerNumber =  LeadObj.MobilePhone;
                
                if(String.isNotBlank(sObjectId)) wrapperObj.contactDetails = getContactData(null, sObjectId, contactList);
                
            }else if(sObjectName == 'MCare_Dashboard_Case__c'){
                MCare_Dashboard_Case__c MCareDashObj = (MCare_Dashboard_Case__c)sobQueriedDataList[0];
                wrapperObj.customerName = 'Customer 1';
                wrapperObj.customerNumber = MCareDashObj.Customer1_Phone__c;
                List<String> customerNamePhoneList = New List<String>();
                if(String.isNotBlank(MCareDashObj.Customer1_Phone__c)) customerNamePhoneList.add('Customer 1 - '+MCareDashObj.Customer1_Phone__c);
                if(String.isNotBlank(MCareDashObj.Customer2_Phone__c)) customerNamePhoneList.add('Customer 2 - '+MCareDashObj.Customer2_Phone__c);
                if(String.isNotBlank(MCareDashObj.Customer3_Phone__c)) customerNamePhoneList.add('Customer 3 - '+MCareDashObj.Customer3_Phone__c);
                if(String.isNotBlank(MCareDashObj.Merchant_Mobile__c)) customerNamePhoneList.add(MCareDashObj.Merchant_Legal_Name__c +' - '+MCareDashObj.Merchant_Mobile__c);
                if(!customerNamePhoneList.isEmpty()) wrapperObj.contactDetails = customerNamePhoneList; 
            }
            wrapperObj.message = '';
        }catch(Exception ex){
            wrapperObj.message = 'Error-'+ex.getMessage();
        }
        return wrapperObj;
    }
    
    private static list<SObject> getSObjectData(string sObjectId, string sObjectName){
        //prepare the query string to get the case fields value
        Batch_Setting__mdt batchSetting = [SELECT MasterLabel,Fields_To_Query__c, SObject__c FROM Batch_Setting__mdt 
                                           WHERE MasterLabel = 'PayU_KaleyraClickToCall' AND SObject__c =:sObjectName];
        String query =  batchSetting.Fields_To_Query__c + ' From '+sObjectName+' WHERE Id =:sObjectId';
        system.debug('query*==========='+query);
        return Database.query(query);
    }
    
    private static List<OpportunityContactRole> getOpportunityConRoleData(string OpportunityId){
        List<OpportunityContactRole> oppConRoleList = [SELECT Id, OpportunityId, ContactId, Role, IsPrimary FROM OpportunityContactRole where OpportunityId =:OpportunityId];
        system.debug('oppConRoleList*==========='+oppConRoleList);
        if(oppConRoleList.size()>0){
            return oppConRoleList;
        }else{
            return null;  
        }
    }
    
    private static List<String> getContactData(Set<Id> conIdSet, String sObjectId, List<Contact> contactList){
        List<String> nameMobileStrList = New List<String>();
        if(conIdSet != null && !conIdSet.isEmpty())
            contactList = [SELECT Id, AccountId, Name, Phone, MobilePhone FROM Contact Where Id IN: conIdSet];
        else
            contactList = [SELECT Id, AccountId, Name, Phone, MobilePhone FROM Contact Where Lead__c =: sObjectId];
        
        if(!contactList.isEmpty()){
            for(Contact con: contactList){
                String nameMobileStr = con.Name +' - '+con.MobilePhone;
                nameMobileStrList.add(nameMobileStr);
            }
        }
        return nameMobileStrList;
    }
    
    @AuraEnabled
    public static c2cWrapper callMerchantFromKaleyra(string wrapperStr, string sObjectId, String sObjectName, String customerNumber){
        c2cWrapper wrapperObj = New c2cWrapper();
        try{
            wrapperObj = (c2cWrapper) System.JSON.deserialize(wrapperStr, c2cWrapper.class);
            if(String.isNotBlank(sObjectId)){
                List<OneCare_Caleria_Payload__mdt> kaleyraPayloadList = OneCare_kaleyraUtility.getPayLoadMap('Manual Call', sObjectName);
                Integration_Setting__mdt theIntIns = IntegrationUtility.getIntSetting('PayU_KaleyraClickToCall');
                
                List<sObject> sobQueriedDataList = getSObjectData(sObjectId, sObjectName);
                String strPayload = OneCare_kaleyraUtility.prepareManualCallPayload(kaleyraPayloadList,sobQueriedDataList[0],customerNumber);
                HttpResponse objResponse = IntegrationUtility.requestUtility(theIntIns, false, null, null, null, strPayload);
                String responceBody = String.valueOf(objResponse.getBody());
                system.debug('####### responceBody '+responceBody);
                system.debug('####### objResponse '+objResponse);
                if(objResponse.getStatus() == 'OK' && objResponse.getStatusCode() == 200){
                    String agentName = '';
                    String mobileNumber = '';
                    if(String.isNotBlank(String.valueOf(sobQueriedDataList[0].get('Agent_Name__c')))){
                        agentName = String.valueOf(sobQueriedDataList[0].get('Agent_Name__c'));
                    }
                    if(String.isNotBlank(String.valueOf(sobQueriedDataList[0].get('Agent_Mobile__c')))){
                        mobileNumber = String.valueOf(sobQueriedDataList[0].get('Agent_Mobile__c'));
                    }
                    if(String.isNotBlank(agentName) && String.isNotBlank(mobileNumber)){
                        sobQueriedDataList[0].put('Agent_Details__c', agentName.trim()+'-'+mobileNumber.trim());
                        update sobQueriedDataList[0];
                    }  
                    wrapperObj.checkReturnBool = true;
                }else{
                    wrapperObj.checkReturnBool = false;
                    wrapperObj.message = 'Error - '+objResponse.getStatus();
                }
            }
        }catch(Exception ex){
            wrapperObj.message = 'Error - '+ex.getMessage();
        }
        return wrapperObj;
    }
    
    @AuraEnabled
    public static c2cWrapper createContact(String wrapperStr, String sObjectId, String sObjectName, String oppConRolePickListValue, Contact contactObj){
        c2cWrapper wrapperObj = (c2cWrapper) System.JSON.deserialize(wrapperStr, c2cWrapper.class);
        try{
            if(String.isNotBlank(sObjectId)){
                List<sObject> sobQueriedDataList = getSObjectData(sObjectId, sObjectName);
                
                if(sObjectName == 'Opportunity' && sobQueriedDataList[0] != null){
                    Opportunity OpportunityObj = (Opportunity)sobQueriedDataList[0];
                    
                    if(contactObj != null && OpportunityObj != null ){
                        contactObj.AccountId = OpportunityObj.AccountId;
                        insert contactObj;
                        if(contactObj.Id != null){
                            OpportunityContactRole contactRole = new OpportunityContactRole();
                            contactRole.ContactId = contactObj.Id;
                            contactRole.OpportunityId = OpportunityObj.Id;
                            contactRole.Role = oppConRolePickListValue;
                            insert contactRole;
                            wrapperObj = updateMerchantNameAndMobile(wrapperStr, sObjectId, sObjectName, contactObj.MobilePhone,contactObj.FirstName+' '+contactObj.LastName);
                        }
                    }
                    wrapperObj.customerName = String.isNotBlank(contactObj.FirstName) ? contactObj.FirstName+' '+contactObj.LastName : contactObj.LastName;
                    wrapperObj.customerNumber = contactObj.MobilePhone;
                }
            }
            wrapperObj.message = '';
        }catch(Exception ex){
            wrapperObj.message = 'Error - '+ex.getMessage();
        }
        return wrapperObj;
    }
    
    @AuraEnabled
    public static c2cWrapper updateMerchantNameAndMobile(String wrapperStr, string sObjectId, string sObjectName, string merchantMobile,String merchantName){
        c2cWrapper wrapperObj = (c2cWrapper)JSON.deserialize(wrapperStr, c2cWrapper.class);
        try{
            if(String.isNotBlank(sObjectId)){
                List<sObject> sobQueriedDataList = getSObjectData(sObjectId, sObjectName);
                
                if(sObjectName == 'Opportunity' && sobQueriedDataList[0] != null){
                    Opportunity OpportunityObj = (Opportunity)sobQueriedDataList[0];
                    OpportunityObj.Merchant_Mobile__c = merchantMobile;
                    OpportunityObj.Merchant_Name__c = merchantName;
                    update OpportunityObj;
                    wrapperObj.oppObj = OpportunityObj;
                    
                    if(OpportunityObj.Merchant_Mobile__c == merchantMobile && OpportunityObj.Merchant_Name__c == merchantName){
                        wrapperObj.checkReturnBool = true;
                    }else{
                        wrapperObj.checkReturnBool = false; 
                    }                    
                }else if(sObjectName == 'Lead' && sobQueriedDataList[0] != null){	
                    Lead LeadObj = (Lead)sobQueriedDataList[0];	
                    LeadObj.Merchant_Mobile__c = merchantMobile;	
                    LeadObj.Merchant_Name__c = merchantName;	
                    update LeadObj;	
                    wrapperObj.leadObj = LeadObj;	
                    	
                    if(LeadObj.Merchant_Mobile__c == merchantMobile && LeadObj.Merchant_Name__c == merchantName){	
                        wrapperObj.checkReturnBool = true;	
                    }else{	
                        wrapperObj.checkReturnBool = false; 	
                    }                    	
                }else if(sObjectName == 'MCare_Dashboard_Case__c' && sobQueriedDataList[0] != null){
                    MCare_Dashboard_Case__c MCareDashCaseObj = (MCare_Dashboard_Case__c)sobQueriedDataList[0];
                    MCareDashCaseObj.Agent_Name__c = UserInfo.getUserName();
                    MCareDashCaseObj.Agent_Mobile__c = wrapperObj.userObj.MobilePhone;
                    update MCareDashCaseObj;
                }
                wrapperObj.customerName = merchantName;
                wrapperObj.customerNumber = merchantMobile;
            }
            wrapperObj.message = '';
        }catch(Exception ex){
            wrapperObj.message = 'Error - '+ex.getMessage();
        }
        return wrapperObj;
    }
    
    @AuraEnabled
    public static List<String> getOppConRolePickList(string sObjectName,string field){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(field).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        } 
        System.debug(pickListValuesList);
        return pickListValuesList;
    }
    
    public class c2cWrapper{
        @AuraEnabled
        public Opportunity oppObj {get;set;}
        
        @AuraEnabled
        public Lead leadObj {get;set;}
        
        @AuraEnabled
        public User userObj {get;set;}
        
        @AuraEnabled
        public List<String> contactDetails {get;set;}
        
        @AuraEnabled
        public String customerName {get;set;}
        
        @AuraEnabled
        public String customerNumber {get;set;}
        
        @AuraEnabled
        public Boolean checkReturnBool {get;set;}
        
        @AuraEnabled
        public String message {get;set;}
    }
}