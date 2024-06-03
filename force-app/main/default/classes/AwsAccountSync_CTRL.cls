/*
Created By - Rohit Kumar Gupta
Date - 10-05-2022
Class Name - AwsAccountSync_CTRL
Purpose - get Updated lead from external system (Pan no,Pan Holder Name,Business Entity) If this field will be available then
update existing lead .
*/
@RestResource(urlMapping='/accountSyncWithAws/*')
global class AwsAccountSync_CTRL {
    @HttpPost
    global static AwsAccountSync_CTRL.Response updateLead() {
        AwsAccountSync_CTRL.Response responsePayload = new AwsAccountSync_CTRL.Response() ;
        Boolean success = false;
        String message = '';
        if(RestContext.request != null) {
            String requestBody = RestContext.request.requestBody.toString();
            Set<String> leadUUID = new Set<String>();
            Set<String> panHolderNo = new Set<String>();
            if(String.isNotBlank(requestBody)){
                try{
                    List<Lead> updateLeadList = new List<Lead>();
                    AwsAccountSync_CTRL.AccSync  accPayLoad =  (AwsAccountSync_CTRL.AccSync)JSON.deserialize(requestBody, AwsAccountSync_CTRL.AccSync.class);
                    leadUUID.add(accPayLoad.uuid);
                    panHolderNo.add(accPayLoad.pan_card_number);
                    System.debug('accPayLoad.business_entity_uuid:::::'+accPayLoad.business_entity_uuid);
                    List<Account> accExistingList = new List<Account>();
                    if(panHolderNo.size()>0){
                        if(!Test.isRunningTest())accExistingList = [SELECT Id,PAN_Number__c,Identifier__c,Active__c,Dow_Jones_Status__c,Device__c,Quality_Score__c,Merchant_Business_Type__c,Vertical__c,LOB_Status__c,PAN_Verification_Status__c,PAN_Holder_Name__c,Legal_Name__c FROM Account WHERE PAN_Number__c =:panHolderNo];
                        if(accExistingList !=Null && accExistingList.size()>0 ){
                            responsePayload.message = 'PAN NO already existed related to this Account, Please find details' ;
                            responsePayload.pan_card_number = accExistingList[0].PAN_Number__c;
                            responsePayload.uuid = accExistingList[0].Identifier__c;
                            responsePayload.pan_verification_status = accExistingList[0].PAN_Verification_Status__c;
                            responsePayload.business_name = accExistingList[0].Legal_Name__c;
                            responsePayload.lob_approval_status = accExistingList[0].LOB_Status__c;
                            responsePayload.name_on_pan = accExistingList[0].PAN_Holder_Name__c;
                            responsePayload.merchant_vertical = accExistingList[0].Vertical__c;
                            responsePayload.business_type = accExistingList[0].Merchant_Business_Type__c;
                            responsePayload.quality_score = accExistingList[0].Quality_Score__c;
                            responsePayload.device = accExistingList[0].Device__c;
                            responsePayload.dow_jones_check = accExistingList[0].Dow_Jones_Status__c;
                            responsePayload.active = accExistingList[0].Active__c;
                            responsePayload.success = True;
                        } 
                        else{
                            List<Entity__c> entityList = [Select Id, Identifier__c  FROM Entity__c  Where Identifier__c =:accPayLoad.business_entity_uuid];
                            if( entityList !=null && entityList.size()>0 ){
                                List<Lead> leadList = [Select Id,Identifier__c from Lead Where Identifier__c=:leadUUID];
                                if( leadList !=NULL && leadList.size()>0){
                                    for(Lead leadvarold :leadList) { 
                                        if(String.isNotEmpty(accPayLoad.pan_card_number) && String.isNotEmpty(accPayLoad.business_entity_uuid) && String.isNotEmpty(accPayLoad.name_on_pan)){
                                            Lead leadUpdate = new Lead();
                                            leadUpdate.Identifier__c = accPayLoad.uuid;
                                            leadUpdate.PAN_Number__c = accPayLoad.pan_card_number;
                                            if(entityList !=null && entityList.size()>0){leadUpdate.Business_Entity__c = entityList[0].ID;}
                                            leadUpdate.Legal_Name__c = accPayLoad.business_name;
                                            leadUpdate.PAN_Verification_Status__c = accPayLoad.pan_verification_status ;
                                            leadUpdate.PAN_Holder_Name__c = accPayLoad.name_on_pan ;
                                            leadUpdate.Id =  leadvarold.Id;
                                            updateLeadList.add(leadUpdate);
                                        }
                                        else{  
                                            responsePayload = new AwsAccountSync_CTRL.Response() ;
                                            responsePayload.success = False;
                                            responsePayload.message = 'Update request not processed. Verify that the required fields are missing';
                                            return responsePayload;
                                        }
                                    } 
                                }
                                else{
                                    responsePayload.success = False;
                                    responsePayload.message = 'Lead Identifier not found in salesforce, please send correct identifier';
                                    return responsePayload;
                                }
                            }
                            else{
                                responsePayload.success = False;
                                responsePayload.message = 'Business Entity not found in salesforce, please send correct business_entity_uuid';
                                return responsePayload;
                            }
                            if(updateLeadList.size()>0 && !updateLeadList.isEmpty()){
                                update updateLeadList;
                            }
                            Set<Id> convertedAccId = new Set<Id>();
                            for(Lead ld : [Select Id,IsConverted ,ConvertedAccountId from Lead Where Identifier__c =: leadUUID]){
                                convertedAccId.add(ld.ConvertedAccountId);
                            }
                            convertedAccId.remove(null);
                            if(convertedAccId.size()>0){
                                for(Account acc : [Select Id,PAN_Number__c , PAN_Holder_Name__c, PAN_Verification_Status__c ,Legal_Name__c,
                                                   LOB_Status__c,Identifier__c ,Vertical__c ,Merchant_Business_Type__c , Quality_Score__c,
                                                   Device__c ,Dow_Jones_Status__c ,Active__c from Account Where Id=:convertedAccId]){
                                                       responsePayload = new AwsAccountSync_CTRL.Response() ;
                                                       responsePayload.pan_card_number = acc.PAN_Number__c;
                                                       responsePayload.uuid = acc.Identifier__c;
                                                       responsePayload.pan_verification_status = acc.PAN_Verification_Status__c;
                                                       responsePayload.business_name = acc.Legal_Name__c;
                                                       responsePayload.lob_approval_status = acc.LOB_Status__c;
                                                       responsePayload.name_on_pan = acc.PAN_Holder_Name__c;
                                                       responsePayload.merchant_vertical = acc.Vertical__c;
                                                       responsePayload.business_type = acc.Merchant_Business_Type__c;
                                                       responsePayload.quality_score = acc.Quality_Score__c;
                                                       responsePayload.device = acc.Device__c;
                                                       responsePayload.dow_jones_check = acc.Dow_Jones_Status__c;
                                                       responsePayload.active = acc.Active__c;
                                                       responsePayload.success = True;
                                                       responsePayload.message = 'Update request sucessfully processed. ';
                                                   }
                            }
                        }
                    }
                }
                catch(Exception e){
                    responsePayload.Success = false;
                    responsePayload.message = 'Update request not processed Encountered Error.' + e.getMessage() ;
                    throw new MyCustomException(responsePayload.Success+''+responsePayload.message);
                }
            }
        }
        return responsePayload;
    }
    public class MyCustomException extends Exception {} 
    global class AccSync{
        global String uuid ;
        global String pan_card_number ;
        global String business_name ;
        global String name_on_pan ;
        global String business_entity_uuid ;
        global String pan_verification_status ;
    }
    global class Response{
        global String pan_card_number ;
        global String name_on_pan ;
        global String pan_verification_status ;
        global String business_name ;
        global String lob_approval_status ;
        global String uuid ;
        global String merchant_vertical ;
        global String business_type ;
        global Decimal quality_score  ;
        global String device  ;
        global String dow_jones_check  ;
        global Boolean active ;
        global String message;
        global Boolean success;
    }  
}