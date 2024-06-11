/*
 * Created Date: 23 Dec 2021
 * Created By: Sneha Sahi
 * Description: This trigger is used to send the Attachment related data to the merchant from the Lightning view.
 * */
trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert, after update, before insert, before update) {
    
    System.debug('ContentDocumentTrigger');
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            ContentDocumentLinkTriggerHandler.beforeInsertHandler(Trigger.New);
        }
        
    }

}