/*
* Created Date: 6 Sep 2019
* Created By: Akash Pandey
* Description: This trigger is used to send the Attachment related data to the merchant from the Lightning view.
* */
trigger ContentDocumentTrigger on ContentDocument (after insert, after update, before insert, before update,before delete) {
    System.debug('ContentDocumentTrigger');
    if(Trigger.isAfter){
        ContentDocumentTriggerHandler.getCaseOnInsert(Trigger.New);
        //ContentDocumentTriggerHandler.checkSizeAndType(Trigger.New);
    }
    /* 
Added By    : Shahwaz Khan 
Description : Uploaded file should not be deletable after approval(lazy pay users) 
Created Date: 29 Sep 2020
*/ 
    if(Trigger.isBefore && Trigger.isDelete){
        //ContentDocumentTriggerHandler.checkSizeAndType(Trigger.New);
       //PF_ContectDocLinkHandler.PF_ContectDocLinkHandlerMethod(Trigger.Old);
    }
}