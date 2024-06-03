public class WebsitePageTriggerHandler{
    public static boolean isNewData = false;
    
    public static void beforeInsertHandler(List<Website_Page__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Website_Page__c'); 
        
        Set<Id> OppIds = New Set<Id>();
        List<Website_Page__c> existingWebPage = New List<Website_Page__c>();
        List<Website_Page__c> duplicateWebPage = New List<Website_Page__c>();
        Map<string,Website_Page_Master__c> wpMasterMap = new Map<string,Website_Page_Master__c>();
        Map<Id,Opportunity> oppObjMap = new Map<Id,Opportunity>();
        
        
        for(Website_Page__c each : triggerNew){
            if(String.isNotBlank(each.Opportunity__c))
                oppIds.add(each.Opportunity__c);
        }
        
        if(!oppIds.isEmpty()){
            for(Opportunity eachOpp : [Select Id,Merchant_Business_Type__c from Opportunity Where Id IN: oppIds]){
                oppObjMap.put(eachOpp.Id,eachOpp);
            }
        }
        
        List<Website_Page_Master__c> wpmList = [Select Id,Name,Page_Details__c,Merchant_Business_Type__c from Website_Page_Master__c where Active__c=true];
        
        
        for(Website_Page__c each : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);
            
            for(Website_Page_Master__c wpm : wpmList){
                if(oppObjMap.containsKey(each.Opportunity__c) && oppObjMap.get(each.Opportunity__c).Merchant_Business_Type__c == wpm.Merchant_Business_Type__c)
                    wpMasterMap.put(wpm.Name,wpm);
            }
            
            
            if(string.isNotBlank(each.Page_Details__c)){
                if(!each.Page_Details__c.startsWith('[')){
                    each.Page_Details__c='['+each.Page_Details__c+']';
                }
            }else if(string.isBlank(each.Page_Details__c)){
                if(wpMasterMap.containsKey(each.Name) && wpMasterMap.get(each.Name).Page_Details__c != null && oppObjMap.containsKey(each.Opportunity__c)
                   && oppObjMap.get(each.Opportunity__c).Merchant_Business_Type__c == wpMasterMap.get(each.Name).Merchant_Business_Type__c){
                       each.Page_Details__c = wpMasterMap.get(each.Name).Page_Details__c;
                   }
            }else if(string.isNotBlank(each.Page_Details__c) && each.Page_Details__c.length()<5){
                if(wpMasterMap.containsKey(each.Name) && wpMasterMap.get(each.Name).Page_Details__c != null && oppObjMap.containsKey(each.Opportunity__c)
                   && oppObjMap.get(each.Opportunity__c).Merchant_Business_Type__c == wpMasterMap.get(each.Name).Merchant_Business_Type__c){
                       each.Page_Details__c = wpMasterMap.get(each.Name).Page_Details__c;
                   }
            }
        }
        
        if(!oppIds.isEmpty()) 
            existingWebPage = WebsitePageTriggerHelper.getRelatedWebsitePages(OppIds);
        
        /*if(!existingWebPage.isEmpty()){
           duplicateWebPage = WebsitePageTriggerHelper.checkWebPagetoDelete(existingWebPage,triggerNew,wpMasterMap.values());
        }*/
        for(Website_Page__c each : triggerNew){
            if(string.isNotBlank(each.Page_Details__c)){
                if(!each.Page_Details__c.startsWith('[')){
                    each.Page_Details__c='['+each.Page_Details__c+']';
                }
            }
            if(string.isNotBlank(each.Page_Details__c) && each.Page_Details__c.length()<5){
                if(wpMasterMap.containsKey(each.Name) && wpMasterMap.get(each.Name).Page_Details__c != null && oppObjMap.containsKey(each.Opportunity__c)
                   && oppObjMap.get(each.Opportunity__c).Merchant_Business_Type__c == wpMasterMap.get(each.Name).Merchant_Business_Type__c){
                       each.Page_Details__c = wpMasterMap.get(each.Name).Page_Details__c;
                   }
            }
            WebsitePageTriggerHelper.getPageDetailsData(each,wpMasterMap.values());
        }
        //if(!duplicateWebPage.isEmpty()) Database.delete(duplicateWebPage,false);
    }
    
    public static void afterInsertHandler(List<Website_Page__c> triggerNew){
        List<String> pgNames = new List<String>{'Terms & Conditions Details','Product/Services Details','Contact Us Details'};
            for(Website_Page__c each : triggerNew){
                if(each.Data_need_to_be_publish__c ){
                    if(!System.isBatch() && String.isNotBlank(each.URL__c) && pgNames.contains(each.Name)){
                        IntegrationUtility.sendPayLoadData(each, null, 'Website_Page__c', 'Website_Page__c'); 
                    }
                }         
            }
    }
    
    public static void beforeUpdateHandler(List<Website_Page__c> triggerNew, Map<Id, Website_Page__c> triggerOldMap){
        
        Set<string> wpmName = New Set<string>();
        List<Website_Page_Master__c> wpmList = [Select Id,Name,Page_Details__c from Website_Page_Master__c where Active__c=true];
        for(Website_Page_Master__c wpm : wpmList){
            if(wpm <> null) wpmName.add(wpm.Name);
        }
        for(Website_Page__c page : triggerNew){
            List<String> finalList = new List<String>();
            if(string.isNotBlank(page.Page_Details__c) && wpmName.contains(page.Name)){
                if(!page.Page_Details__c.startsWith('[')){
                    String str = '['+page.Page_Details__c+']';   
                    page.Page_Details__c = str;
                }
            }
        }
    }
    
    public static void afterUpdateHandler(List<Website_Page__c> triggerNew, Map<Id, Website_Page__c> triggerOldMap){
        List<Id> optyId = new List<Id>();
        List<String> pgNames = new List<String>{'Terms & Conditions Details','Product/Services Details','Contact Us Details'};
            for(Website_Page__c each : triggerNew){
                optyId.add(each.Opportunity__c);
                if(each.Data_need_to_be_publish__c ){
                    if(!System.isBatch() && String.isNotBlank(each.URL__c) && pgNames.contains(each.Name)){
                        
                        IntegrationUtility.sendPayLoadData(each, TriggerOldMap.get(each.Id), 'Website_Page__c', 'Website_Page__c'); 
                    }
                }        
            }
    }
}