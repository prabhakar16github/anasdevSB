public class AddressDetailsTriggerHandler{
    
    public static void beforeInsertHandler(List<Address_Details__c> triggerNew){
        
        /**** Mapping the City and State to Pincode**********KUNAL********************/
        Map<String, Pincode_City_Mapping__c> pincodeCityStateMap = new Map<String, Pincode_City_Mapping__c>();
        for(Pincode_City_Mapping__c pcm : [SELECT Id, Pincode__c, State__c, City__c FROM Pincode_City_Mapping__c]){
            String key = pcm.Pincode__c;
            pincodeCityStateMap.put(key, pcm);
        }
        /****END*************** Mapping the City and State to Pincode**********KUNAL********************/
        
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Address_Details__c');         
        for(Address_Details__c each : triggerNew){
            
            if(pincodeCityStateMap.containsKey(each.Pincode__c)){
                Pincode_City_Mapping__c location = pincodeCityStateMap.get(each.Pincode__c);
                each.City__c = location.City__c;
                each.State__c = location.State__c;
                each.Country__c = 'India';
            }
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);            
        }
    }
    
    public static void beforeUpdateHandler(List<Address_Details__c> triggerNew, Map<Id,Address_Details__c> triggerOldMap){
        
        system.debug('@@@@@@ address detail ');
        
        /**** Mapping the City and State to Pincode**********KUNAL********************/
        /*Map<String, Pincode_City_Mapping__c> pincodeCityStateMap = new Map<String, Pincode_City_Mapping__c>();
        for(Pincode_City_Mapping__c pcm : [SELECT Id, Pincode__c, State__c, City__c FROM Pincode_City_Mapping__c]){
            String key = pcm.Pincode__c;
            pincodeCityStateMap.put(key, pcm);
        }*/
        /****END*************** Mapping the City and State to Pincode**********KUNAL********************/ 
        for(Address_Details__c each : triggerNew){
            /*if(pincodeCityStateMap.containsKey(each.Pincode__c)){
                Pincode_City_Mapping__c location = pincodeCityStateMap.get(each.Pincode__c);
                each.City__c = location.City__c;
                each.State__c = location.State__c;
            }*/
           
            Address_Details__c oldAddress = triggerOldMap.get(each.Id);
            if(each.Type__c == 'Registered' && oldAddress.Status__c==false 
               && each.Active__c==true){
                                              system.debug('@@@@@@ address detail reg');
                each.Status__c = true;
            }
            if(each.Type__c == 'Operating' && oldAddress.Status__c==false 
               && each.Active__c==true){
                                              system.debug('@@@@@@ address detail oper ');
                each.Status__c = true;
            }            
        }
    }
    
    // this method call FROM Address Details trigger at after insert
    public static void afterInsertHandler(List<Address_Details__c> triggerNew){
        for(Address_Details__c each : TriggerNew){
            if(!System.isBatch()){
                IntegrationUtility.checkMaintenance(each, null, 'Address_Details__c', 'Address_Details__c'); 
            }
        }
        createOperatingAddress(triggerNew, null);
    }
    
    // this method call FROM Address Details trigger at after update
    public static void afterUpdateHandler(List<Address_Details__c> triggerNew, Map<Id, Address_Details__c> triggerOldMap){
        Set<String> addressUpdatedIds = New Set<String>();
        Set<Id> accId = new Set<Id>();
        
        for(Address_Details__c each : TriggerNew){
            addressUpdatedIds.add(each.Id);
        }
        
       // if(!System.isBatch() && !addressUpdatedIds.isEmpty()) updateagreementByTriggerChangeWithnewURL(addressUpdatedIds);
        
        for(Address_Details__c each : TriggerNew){        
            if(!System.isBatch()){
                IntegrationUtility.checkMaintenance(each, TriggerOldMap.get(each.Id), 'Address_Details__c', 'Address_Details__c'); 
            }
            if(String.isNotBlank(each.Type__c) && each.Pincode__c != triggerOldMap.get(each.Id).Pincode__c 
               && String.isNotBlank(each.Pincode__c) && each.Active__c == True && String.isNotBlank(each.Account__c)){
                   accId.add(each.Account__c);
           }
        }
        
        if(!accId.isEmpty())    blankGst(accId);
        createOperatingAddress(triggerNew, triggerOldMap);       
        
    }
    
    public static void createOperatingAddress(List<Address_Details__c> triggerNew, Map<Id, Address_Details__c> triggerOldMap){
        
        List<Address_Details__c> addressList = new List<Address_Details__c>();
        List<Contract> contractList = new List<Contract>();
        system.debug('@@@@@@@@@@ contract2 ');
        for(Address_Details__c each : triggerNew){
            
            if(each.Type__c == 'Registered' && each.Setup_Operating_Address__c == True && each.Address_Line__c != null &&
               (triggerOldMap == null || triggerOldMap.get(each.id).Setup_Operating_Address__c == False)){
                   
                   Address_Details__c eachAddress = new Address_Details__c();
                   
                   eachAddress.Type__c = 'Operating';
                   eachAddress.Account__c = each.Account__c;
                   eachAddress.Lead__c = each.Lead__c;
                   eachAddress.Active__c = each.Active__c;
                   eachAddress.Address_Line__c = each.Address_Line__c;
                   eachAddress.City__c = each.City__c;
                   eachAddress.State__c = each.State__c;
                   eachAddress.Country__c = each.Country__c;
                   eachAddress.Pincode__c = each.Pincode__c;
                   eachAddress.Identifier__c = '';
                   addressList.add(eachAddress);
                   
               }
        }
        if(!addressList.isEmpty()) insert addressList;       
    }
    
    public static void blankGst(Set<Id> accId){
        List<Opportunity> optyList = new List<Opportunity>();
        Id supportRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        
        List<Account> accList = [Select id, Name, RecordTypeId FROM Account WHERE Id IN: accId Limit 1];
        system.debug('accList=='+accList);
        if(!accList.isEmpty()){
            if(accList[0].RecordTypeId == supportRecordTypeId){
                
                optyList = [Select Id, Name, StageName, GST_Number__c FROM Opportunity 
                            WHERE AccountId IN: accList AND StageName != 'Live & Transacting'
                            AND StageName != 'Terminated' AND GST_Number__c != null Limit 1];
                system.debug('optyList=='+optyList);
                if(!optyList.isEmpty()){
                    optyList[0].GST_Number__c = null;
                    update optyList;
                }
            }
        }
    }
    
    public static void afterDeleteHandler(List<Address_Details__c> triggerOld){
        for(Address_Details__c each : triggerOld){
            IntegrationUtility.checkMaintenance(each, null, 'Address_Details__c', 'Address_Details__c'); 
        }    
    }
    
        
    public static void getAddressFromAccount(Set<String> setAccountId, Map<String,List<Contract>> mapAccountwithContract, Map<String,string> mapofContractWithopport ){
        
        for(Contract objContract:[SELECT Id, Status, AccountId, E_Stamp__c, Document_Master__c, Type__c, Document_Category__c,  
                                  Document_Category__r.Name, Contract_Type__c, Offline_Generation__c, Pricebook2Id, Active__c,Account.Identifier__c,
                                  Document_Content_Type__c, File_Size__c, URL__c, OwnerExpirationNotice, Document_Type__c, 
                                  Document_Category_Name__c, Document_Type_Name__c, StartDate, ContractTerm, E_Stamp_Number__c 
                                  FROM Contract WHERE AccountId IN : setAccountId ORDER BY LastModifiedDate DESC]){                 
                                      
                                      
                                      if(String.isBlank(objContract.Document_Type_Name__c)){
                                          objContract.Document_Type_Name__c = 'Agreement';
                                      }
                                      if(String.isBlank(objContract.Document_Category_Name__c)){
                                          objContract.Document_Category_Name__c = 'Service Agreement';
                                      }
                                      if(mapAccountwithContract.get(String.valueof(objContract.AccountId)) != null){
                                          List<Contract> lstCont = mapAccountwithContract.get(String.valueof(objContract.AccountId));
                                          lstCont.add(objContract);
                                          mapAccountwithContract.put(String.valueof(objContract.AccountId),lstCont);
                                      }
                                      else if(mapAccountwithContract.get(String.valueof(objContract.AccountId)) == null){
                                          List<Contract> lstCont = new List<Contract>();
                                          lstCont.add(objContract);                    
                                          mapAccountwithContract.put(String.valueof(objContract.AccountId),lstCont);
                                          
                                      }
                                      
                                      if(mapofContractWithopport.get(String.valueof(objContract.Id)) != null){
                                          string oppId = mapofContractWithopport.get(String.valueof(objContract.Id));
                                          mapofContractWithopport.put(String.valueof(objContract.Id),oppId);
                                      }
                                      else if(mapofContractWithopport.get(String.valueof(objContract.Id)) == null){                                        
                                          mapofContractWithopport.put(string.valueOf(objContract.Id),String.valueOf([Select Id from opportunity where AccountId=:String.valueof(objContract.AccountId)][0].Id));
                                          
                                      }    
                                  }
    }
    
}