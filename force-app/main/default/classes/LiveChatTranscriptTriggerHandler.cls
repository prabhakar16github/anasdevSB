public class LiveChatTranscriptTriggerHandler {
    
    
    
    public static void beforeInsertHandler(list<LiveChatTranscript> triggerNew){
    }
    
    public static void beforeUpdateHandler(list<LiveChatTranscript> triggerNew, Map<id,LiveChatTranscript> triggerOldMap){
    }
    
    public static void afterInsertHandler(list<LiveChatTranscript> triggerNew, Map<id,LiveChatTranscript> triggerOldMap){
    }
    
    public static void afterUpdateHandler(list<LiveChatTranscript> triggerNew, Map<id,LiveChatTranscript> triggerOldMap){
    	system.debug('enter after insert handler');
        Map<String,LiveChatTranscript> caseIdChatTranscriptMap = new Map<String,LiveChatTranscript>();
        List<Case> caseToUpdate = new List<case>();
        for(LiveChatTranscript each : triggerNew){
            LiveChatTranscript oldeach = triggerOldMap.get(each.id);
            if(each.Body != oldeach.Body){
                if(each.CaseId != null) caseIdChatTranscriptMap.put(each.CaseId,each);
            }
        }
        
        if(!caseIdChatTranscriptMap.isEmpty() && caseIdChatTranscriptMap != null){
            for(Case eachCase : [select id,chat_history__c,TicketId__c,caseNumber from case where id in :caseIdChatTranscriptMap.keySet()]){
                system.debug('body=='+caseIdChatTranscriptMap.get(eachCase.id).Body);
                //eachCase.chat_history__c
                String addreturnStr = caseIdChatTranscriptMap.get(eachCase.id).Body.replaceAll('<br>','\n');
                String replaceSingleQuotes = addreturnStr.replaceAll('&#39;','\'');
                String str = replaceSingleQuotes.replaceAll('\\<.*?\\>', '');
                eachCase.chat_history__c = str;
                eachCase.TicketId__c = eachCase.caseNumber;
                caseToUpdate.add(eachCase);
            }
            update caseToUpdate;
        }
        
    }

}