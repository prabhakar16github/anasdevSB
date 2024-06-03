/*******************************************************************************************************
 * Author       : PayU Payments Pvt. Ltd.
 * Class Name   : PostRiskHoldEmail
 * Created Date : 22 Novemeber 2022
 * Description  : This class is called from "Post Risk Hold Alert To Initiators And KAMs" flow to send an email to Initiators and KAMs when the merchant is put on Risk Hold
 ********************************************************************************************************
 * Updates
 * Author                 | Date                | Description
 * Aditya Mukkawar        | 22 Novemeber 2022   | Initial Creation
 *******************************************************************************************************/

public with sharing class PostRiskHoldEmail {
    @InvocableMethod(label='Send Email' description='Send an email to Initiators and KAMs when the merchant is put on Risk Hold')    
    public static void sendEmailToInitiatorsAndKAMs(List<String> opportunityId) {
        // Get Key assigned manager
        Opportunity objOpportunity = [SELECT Id,Key_Assigned_Manager__c,Key_Assigned_Manager__r.Email FROM Opportunity WHERE Id =:opportunityId];
        Delegation_User_Matrix__mdt  l1InitiatorsMetadata = Delegation_User_Matrix__mdt.getInstance('L1_Initiators');
        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
        if(l1InitiatorsMetadata!=null && l1InitiatorsMetadata.Initiators__c!=null){
            // get all the queue members to send an email
            List<User> inititatorsUserList = [SELECT ID,Email FROM User WHERE Email!=null AND ID IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId =:l1InitiatorsMetadata.Initiators__c)];
            // Sending email to Inititators
            Id initiatorTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName='MerchantOnRiskHoldAlertToL1Initiators']?.Id;
            if(!inititatorsUserList.isEmpty() && initiatorTemplateId!=null){
                List<string> toAddress = new List<string>();
                for(User objUser:inititatorsUserList){
                    toAddress.add(objUser.Email);
                }
                Messaging.SingleEmailMessage emailToInitiator = new Messaging.SingleEmailMessage();
                emailToInitiator.setTargetObjectId(UserInfo.getUserId());
                emailToInitiator.setWhatId(objOpportunity.Id);
                emailToInitiator.setTemplateId(initiatorTemplateId);
                emailToInitiator.setToAddresses(toAddress);
                emailToInitiator.setSaveAsActivity(false);
                emailToInitiator.setTreatTargetObjectAsRecipient(false);
                singleEmailMessageList.add(emailToInitiator);
                system.debug('emailToInitiator=>'+emailToInitiator);
            }
        }
        // Sending email to KAMs
        if(objOpportunity.Key_Assigned_Manager__c !=null && objOpportunity.Key_Assigned_Manager__r.Email !=null){
            Id kamsTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName='MerchantOnRiskHoldAlertToL1KAMs']?.Id;
            if(kamsTemplateId!=null){
                Messaging.SingleEmailMessage emailToKAMs = new Messaging.SingleEmailMessage();
                emailToKAMs.setTargetObjectId(UserInfo.getUserId());
                emailToKAMs.setWhatId(objOpportunity.Id);
                emailToKAMs.setTemplateId(kamsTemplateId);
                emailToKAMs.setToAddresses(new List<String>{objOpportunity.Key_Assigned_Manager__r.Email});
                emailToKAMs.setSaveAsActivity(false);
                emailToKAMs.setTreatTargetObjectAsRecipient(false);
                singleEmailMessageList.add(emailToKAMs);
                system.debug('emailToKAMs=>'+emailToKAMs);
            }
        }
        // Send an email to Initiators and KAMs
        if(!singleEmailMessageList.isEmpty()){
            Messaging.sendEmail(singleEmailMessageList);
        }
    }
}