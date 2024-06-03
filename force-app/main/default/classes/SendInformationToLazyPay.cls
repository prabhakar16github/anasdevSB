public class SendInformationToLazyPay {

    static Map<String,Object> PayloadMap = new Map<String,Object>();
    static List<Case> caseList = new List<Case>();    
    public static void main1(){
        
    }
    public static void sendContactInfoToLazyPay(List<Contact> triggerNew , Map<ID,Contact> maptriggerold){
        String identifier = '';  
        for(Contact conObj : triggerNew){
            identifier = conObj.Identifier__c; 
        }
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();        
        for(Case caseObj : [Select id , LP_UUID__c, Identifier__c , recordTypeId From Case where LP_UUID__c =: identifier and recordTypeId =:recordTypeId]){
            caseList.add(caseObj);
        }
        if(caseList.size() > 0 || Test.isRunningTest()){
            PayloadActMap__mdt mdt = [Select FieldsCheck__c,JsonMap__c,passport_field_To_Check__c,DL_fields_To_Check__c,VoterId_Fields_To_Check__c,aadhar_Fields_To_Check__c FRom PayloadActMap__mdt where MasterLabel = 'SendContactInformation'];
        // Send Passport Edit informtion ..
            boolean sendPassportInfo;
            boolean sendVoterIdIndo ;
            boolean sendDLInfo;
            boolean sendAadharInfo;
            for(Contact conObj : triggerNew){
               // Send Passport Information 
               for(String field : mdt.passport_field_To_Check__c.split(',')){
                  if(conObj.get(field) != maptriggerold.get(conObj.Id).get(field)){
                     System.debug('Passport Info updated'); 
                     sendPassportInfo = true;
                     String paylaod1 = createPayload(mdt ,triggerNew,maptriggerold ,caseList[0] , 'PASSPORT_FORM','EDIT_PASSPORT_FORM'); 
                     if(!Test.isRunningTest()){
                        lazyPayPublish.PublishData(paylaod1);
                     }
                     
                      break ;
                  }
               }
               //Send aadhar Info      
               for(String field : mdt.aadhar_Fields_To_Check__c.split(',')){
                  if(conObj.get(field) != maptriggerold.get(conObj.Id).get(field)){
                     sendDLInfo = true;
                     System.debug('Aadhar Info updated');  
                     String paylaod2 = createPayload(mdt ,triggerNew,maptriggerold ,caseList[0] , 'AADHAAR_FORM' , 'EDIT_AADHAAR_FORM');
                     if(!Test.isRunningTest()){
                        lazyPayPublish.PublishData(paylaod2);
                     } 
                      break ;
                  }
               }    
         // Send VoterId Info       
               for(String field : mdt.VoterId_Fields_To_Check__c.split(',')){
                  if(conObj.get(field) != maptriggerold.get(conObj.Id).get(field)){
                     sendVoterIdIndo = true;
                      System.debug('voterId Info updated'); 
                     String payload3 =createPayload(mdt ,triggerNew,maptriggerold ,caseList[0] , 'VOTER_ID_FORM', 'EDIT_VOTERID_FORM'); 
                     if(!Test.isRunningTest()){
                        lazyPayPublish.PublishData(payload3); 
                     }
                      break ;
                  }
               }
          //Send DL Info      
               for(String field : mdt.DL_fields_To_Check__c.split(',')){
                  if(conObj.get(field) != maptriggerold.get(conObj.Id).get(field)){
                     sendDLInfo = true;
                     System.debug('DL Info updated'); 
                     String payload4 = createPayload(mdt ,triggerNew,maptriggerold ,caseList[0] , 'DL_FORM','EDIT_DL_FORM'); 
                     if(!Test.isRunningTest()){
                        lazyPayPublish.PublishData(payload4);
                     } 
                      break ;
                  }
               } 
            } 
        }        
                   
    }
   public static String createPayload(PayloadActMap__mdt mdt , List<Contact> triggerNew , Map<Id,Object> maptriggerold ,sObject caseObj , String documentTypeId , String caseStatus){
       Map<String,Object> fieldValueMap = new Map<String,Object>();
       Map<String,String> nodeVsApinameMap = (Map<String,String>)JSON.deserialize(mdt.JsonMap__c,Map<String,String>.class);
        for(Contact conObj : triggerNew){
           for(String fieldValue : nodeVsApinameMap.keySet()){
               System.debug('NOde **' + fieldValue + 'Field  value**' + conObj.get(nodeVsApinameMap.get(fieldValue)));
               fieldValueMap.put(fieldValue, conObj.get(nodeVsApinameMap.get(fieldValue)) );
           }
       }
        
       Map<String,Object> fieldMap = new Map<String,Object>();
       fieldMap.put('value', fieldValueMap);
       fieldMap.put('documentTypeId', documentTypeId); 
       List<Object> ObjectList = new List<Object>();
       ObjectList.add(fieldMap);
       Map<String,Object> mapOfCurrentdata = new Map<String,Object>();
       mapOfCurrentdata.put('documentUpdateList',ObjectList);
       mapOfCurrentdata.put('kycCaseId',caseObj.get('identifier__c') );
       mapOfCurrentdata.put('uuid',caseObj.get('LP_UUID__c'));
       mapOfCurrentdata.put('payloadId',lazyPayPublish.GenerateUniqueID());
       mapOfCurrentdata.put('overrideExistingData',false);
       mapOfCurrentdata.put('username', userInfo.getUserName() );
       mapOfCurrentdata.put('caseStatus',caseStatus);
       mapOfCurrentdata.put('product','CREDIT_LINE');
       Map<String,Object> finalPayloadMap = new Map<String,Object>();
       finalPayloadMap.put('current_data', mapOfCurrentdata);
       finalPayloadMap.put('timestamp', System.now().formatGMT('YYYYMMdd\'T\'HHmmss\'Z\''));
       finalPayloadMap.put('product','LazyPay');
       finalPayloadMap.put('producer','Salesforce');
       finalPayloadMap.put('action','upsert_kyc_detail');
       finalPayloadMap.put('business_object','Customer');
       finalPayloadMap.put('identifier',caseObj.get('LP_UUID__c'));
       return JSON.serialize(finalPayloadMap);
    }
 
}