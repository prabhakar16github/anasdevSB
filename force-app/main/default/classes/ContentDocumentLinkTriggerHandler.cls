/*
 * Created Date: 23 Dec 2021
 * Created By: Sneha Sahi
 * Description: This trigger is used to send the Attachment related data to the merchant from the Lightning view.
 * */

public class ContentDocumentLinkTriggerHandler {
    
    public static void beforeInsertHandler(List<ContentDocumentLink> triggerNew){
        
        Map<String,ContentDocumentLink> MessagingSessionIdMap = new Map<String,ContentDocumentLink>();
        //Map<String,ContentDocumentLink> caseIdDocLinkMap = new Map<String,ContentDocumentLink>();
        
        
        for(ContentDocumentLink eachDocLink : triggerNew){
            if(String.isNotBlank(eachDocLink.LinkedEntityId) && String.valueOf(eachDocLink.LinkedEntityId).startsWith('0Mw')){
                MessagingSessionIdMap.put(eachDocLink.LinkedEntityId,eachDocLink);
            }
        }
        
        if(!MessagingSessionIdMap.isEmpty() && MessagingSessionIdMap != null){
            List<MessagingSession> msgSessionList = [Select id, caseId from MessagingSession where id In :MessagingSessionIdMap.keySet()];
            for(MessagingSession each : msgSessionList){
                ContentDocumentLink contentDocLink = MessagingSessionIdMap.get(each.Id);
                if(each.caseId != null){
                    contentDocLink.LinkedEntityId = each.caseId;
                    system.debug('caseID ==='+each.caseId);
                    system.debug('MessagingSession Id=='+each.id);
                }
                
                
                //caseIdDocLinkMap.put(each.caseId,contentDocLink );
            }
        }
        
        
    }

}