public class WebsitePageTriggerHelper {
    
    public static List<Website_Page__c> getRelatedWebsitePages(Set<Id> OppIds){
        return[Select Id,Name,Page_Details__c,Active__c,Opportunity__c,Approved__c from Website_Page__c where Opportunity__c IN: oppIds AND Active__c=true];
    }
    
    public static List<Website_Page__c> checkWebPagetoDelete(List<Website_Page__c> existingWebPage,List<Website_Page__c> newWebPage,List<Website_Page_Master__c> wpmList){
        List<Website_Page__c> deletedWebPages = New List<Website_Page__c>();
                
        Boolean checkName = false;
        
        for(Website_Page__c newWeb : newWebPage){            
            for(Website_Page__c oldWeb : existingWebPage){
                if(newWeb.Name == oldWeb.Name && oldWeb.Active__c==true){
                    checkName = true;
                    deletedWebPages.add(oldWeb);
                }
            }
        }
        return deletedWebPages;        
    }
    
    //public static void getPageDetailsData(Website_Page__c wbPage, Map<String, List<String>> mapStr){
    public static void getPageDetailsData(Website_Page__c wbPage,List<Website_Page_Master__c> wpmList){    
        List<String> pgDetailsName = new List<String>();
        List<String> finalList = new List<String>();
        Map<String, List<String>> mapStr = new Map<String, List<String>>();
        
        for(Website_Page_Master__c wpm : wpmList){
            
            List<object> pgDetailJSONList = (List<object>)JSON.deserializeUntyped(wpm.Page_Details__c);
            
            List<String> allJsonData = new List<String>();
            for(object obj : pgDetailJSONList){
                String objString = JSON.serialize(obj);
                allJsonData.add(string.valueOf(objString));
            }
            mapStr.put(wpm.Name, allJsonData);
        }
        
        String wbPgDetails= wbPage.Page_Details__c;
        
        if(wbPgDetails != null && !String.isEmpty(wbPgDetails) && wbPgDetails != '' && wbPgDetails.length()>5){
            if(wbPgDetails.startsWith('[')){
                wbPgDetails = wbPgDetails.substring(1, wbPgDetails.length()-1);
            }
            List<String> eachVal = wbPgDetails.split(', ');
            for(String each : eachVal){
                Map<String, String> jMap = (Map<String, String>)JSON.deserialize(each, Map<String, String>.class);
                pgDetailsName.add(jMap.get('name'));
                finalList.add(each);
            }
            system.debug('--<<>> '+mapStr);
            
            if(mapStr.get(wbPage.Name) != null && mapStr.get(wbPage.Name).size()>0){
                List<String> jsonList = mapStr.get(wbPage.Name);
                for(String jstr : jsonList){
                    system.debug('- jstr - '+jstr);
                    Map<String, String> jMap = (Map<String, String>)JSON.deserialize(jstr, Map<String, String>.class);
                    String name = jMap.get('name');
                    if(!pgDetailsName.contains(name)){
                        jMap.remove('is_present');
                        String stts = jMap.remove('status');
                        jMap.put('status','Not Applicable');
                        jstr = JSON.serialize(jMap);
                        finalList.add(jstr);
                    }
                }
            }  
            wbPage.Page_Details__c = '['+String.join(finalList, ', ')+']';   
        }else{
            if(mapStr.get(wbPage.Name) != null && mapStr.get(wbPage.Name).size()>0){
                List<String> jsonList = mapStr.get(wbPage.Name);
                for(String jstr : jsonList){
                    Map<String, String> jMap = (Map<String, String>)JSON.deserialize(jstr, Map<String, String>.class);
                    jMap.remove('is_present');
                    jMap.remove('status');
                    jMap.put('status','Not Applicable');
                    jstr = JSON.serialize(jMap);
                    finalList.add(jstr);
                }
                wbPage.Page_Details__c = '['+String.join(finalList, ', ')+']';
            }
        }
    }
}