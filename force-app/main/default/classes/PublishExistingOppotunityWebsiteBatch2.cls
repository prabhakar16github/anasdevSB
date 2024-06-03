global class PublishExistingOppotunityWebsiteBatch2 implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Batch_Setting__mdt bsMDT = [Select Id,Record_Limit__c,Where_Clause__c from Batch_Setting__mdt where DeveloperName=:'PublishExistingOppotunityWebsiteBatch2' LIMIT 1];
        Integer recordNo = Integer.valueOf(bsMDT.Record_Limit__c);
        string query = '';
        if(recordNo != null)
        	query = 'Select Id, Website__c,Website_Status__c,Android_URL__c,iOS_URL__c,integration_type__c from Opportunity '+bsMDT.Where_Clause__c +' LIMIT '+recordNo;
        else
            query = 'Select Id, Website__c,Website_Status__c,Android_URL__c,iOS_URL__c,integration_type__c from Opportunity '+bsMDT.Where_Clause__c;
        
        // string query = 'Select Id,URL__c,Opportunity__c,Do_Not_Publish__c,Active__c,Opportunity__r.Website_Status__c,Opportunity__r.Website__c from Website_Page__c where Opportunity__c!=null';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> oppLists) {
        system.debug('######## oppLists '+oppLists.size());
        
        List<Opportunity> updatedPendingOpp = New List<Opportunity>();
        List<Opportunity> updatedNAOpp = New List<Opportunity>();
        List<Opportunity> updatedWOURLOpp = New List<Opportunity>();
        for(Opportunity opp : oppLists){
            /*if(opp.Integration_Type__c=='ThirdParty' && (string.isNotBlank(opp.Website__c) || string.isNotBlank(opp.iOS_URL__c) || string.isNotBlank(opp.Android_URL__c))){
                Opportunity oppo = New Opportunity(Id=opp.Id);
                oppo.Website_Status__c = 'Pending';
                updatedPendingOpp.add(oppo);
            }
            */
            if(opp.Integration_Type__c=='Tools'){
                Opportunity oppo = New Opportunity(Id=opp.Id);
                oppo.Website_Status__c = 'Not Applicable';
                updatedNAOpp.add(oppo);
            }
            /*if((string.isBlank(opp.Website__c) && string.isBlank(opp.iOS_URL__c) && string.isBlank(opp.Android_URL__c))){
                Opportunity oppo = New Opportunity(Id=opp.Id);
                oppo.Website_Status__c = 'Not Applicable';
                oppo.Integration_Type__c = 'Tools';
                updatedWOURLOpp.add(oppo);
            }*/
        }
        system.debug('#####updatedPendingOpp '+updatedPendingOpp.size()+' @@@@ updatedNAOpp '+updatedNAOpp.size()+' !!!!updatedWOURLOpp  '+updatedWOURLOpp.size());
        if(!updatedPendingOpp.isEmpty()) Database.update(updatedPendingOpp,false);
        if(!updatedNAOpp.isEmpty()) Database.update(updatedNAOpp,false);
        if(!updatedWOURLOpp.isEmpty()) Database.update(updatedWOURLOpp,false);
       /* Set<Id> oppOKsetIds = New Set<Id>();
        Set<Id> oppNotOKSetIds = New Set<Id>();
        Set<string> wpmName = New Set<string>(); 
        List<string> oldWebNames = New List<string>{'Home Page','Checkout/E-Commerce flow','Product Description','Refund and Cancellation Policy (Optional)'};
        if(oppLists.size()>0 && !oppLists.isEmpty()){
            List<Website_Page__c> websiteToBeInserted = New List<Website_Page__c>();
            List<Website_Page__c> existingWebsiteToBeUpdated = New List<Website_Page__c>();
            Map<string,List<string>> pageDetailWithNameMap = New Map<string,List<string>>();
            webPageDetailHelper.statusApprovedSerialization(pageDetailWithNameMap,'Not Applicable');
            Map<Id,List<Website_Page__c>> oppWithWebsitePage = New Map<Id,List<Website_Page__c>>();
            for(Opportunity opp : oppLists){
                oppOKsetIds.add(opp.Id);
            }
            
        	for(Website_Page_Master__c wpm : [Select Id,Name from Website_Page_Master__c]){
            	if(wpm <> null) wpmName.add(wpm.Name);
        	}
            
            for(Opportunity opp : [Select Id,(Select Id,Name from Website_Pages__r), Website__c,Website_Status__c,Android_URL__c,iOS_URL__c from Opportunity where Id IN:oppOKsetIds]){
                oppWithWebsitePage.put(opp.Id,opp.Website_Pages__r);
            }
            
            if(!oppWithWebsitePage.values().isEmpty()){
                for(Opportunity opp : [Select Id,Website__c,Website_Status__c,Android_URL__c,iOS_URL__c from Opportunity where Id IN: oppWithWebsitePage.keySet()]){
                    if(!oppWithWebsitePage.isEmpty() && oppWithWebsitePage.containsKey(opp.Id)){
                        List<Website_Page__c> wpList = oppWithWebsitePage.get(opp.Id);
                        if(!wpList.isEmpty()){
                            for(Website_Page__c oldWebPage : wpList){
                                if(oldWebNames.contains(oldWebPage.Name)){
                                    Website_Page__c oldPage = New Website_Page__c(Id = oldWebPage.Id);
                                    oldPage.Active__c = false;
                                    oldPage.Do_Not_Publish__c = true;
                                    oldPage.Status__c = 'Not Applicable';
                                    existingWebsiteToBeUpdated.add(oldPage);
                                }
                            }
                        }
                            if(string.isNotBlank(opp.Website__c) || string.isNotBlank(opp.Android_URL__c) || string.isNotBlank(opp.iOS_URL__c)){
                                                                
                                if(!pageDetailWithNameMap.isEmpty() && pageDetailWithNameMap.containsKey('Contact Us Details')){
                                    Website_Page__c newWeb = New Website_Page__c();
                                    newWeb.Opportunity__c = opp.Id;
                                    newWeb.Active__c = true;
                                    newWeb.Do_Not_Publish__c = false;
                                    if(string.isNotBlank(opp.Website__c)){
                                        newWeb.URL__c = opp.Website__c;
                                    }else if(string.isNotBlank(opp.Android_URL__c)){
                                        newWeb.URL__c = opp.Android_URL__c;
                                    }else if(string.isNotBlank(opp.iOS_URL__c)){
                                        newWeb.URL__c = opp.iOS_URL__c;
                                    }else{
                                        newWeb.URL__c = 'www.setduetounavailability.com';
                                    }
                                    newWeb.status__c='Approved';
                                    newWeb.Is_Migration__c = true;
                                    newWeb.Name = 'Contact Us Details';
                                    newWeb.Page_Details__c = '['+string.join(pageDetailWithNameMap.get('Contact Us Details'), ', ')+']';                                       
                                	websiteToBeInserted.add(newWeb);
                                }
                                if(!pageDetailWithNameMap.isEmpty() && pageDetailWithNameMap.containsKey('Product/Services Details')){
                                    Website_Page__c newWeb = New Website_Page__c();
                                    newWeb.Opportunity__c = opp.Id;
                                    newWeb.Active__c = true;
                                    newWeb.Do_Not_Publish__c = false;
                                    if(string.isNotBlank(opp.Website__c)){
                                        newWeb.URL__c = opp.Website__c;
                                    }else if(string.isNotBlank(opp.Android_URL__c)){
                                        newWeb.URL__c = opp.Android_URL__c;
                                    }else if(string.isNotBlank(opp.iOS_URL__c)){
                                        newWeb.URL__c = opp.iOS_URL__c;
                                    }else{
                                        newWeb.URL__c = 'www.setduetounavailability.com';
                                    }
                                    newWeb.status__c='Approved';
                                    newWeb.Is_Migration__c = true;
                                    newWeb.Name = 'Product/Services Details';
                                    newWeb.Page_Details__c = '['+string.join(pageDetailWithNameMap.get('Product/Services Details'), ', ')+']';                                       
                                	websiteToBeInserted.add(newWeb);
                                }
                                if(!pageDetailWithNameMap.isEmpty() && pageDetailWithNameMap.containsKey('Terms & Conditions Details')){
                                    Website_Page__c newWeb = New Website_Page__c();
                                    newWeb.Opportunity__c = opp.Id;
                                    newWeb.Active__c = true;
                                    newWeb.Do_Not_Publish__c = false;
                                    if(string.isNotBlank(opp.Website__c)){
                                        newWeb.URL__c = opp.Website__c;
                                    }else if(string.isNotBlank(opp.Android_URL__c)){
                                        newWeb.URL__c = opp.Android_URL__c;
                                    }else if(string.isNotBlank(opp.iOS_URL__c)){
                                        newWeb.URL__c = opp.iOS_URL__c;
                                    }else{
                                        newWeb.URL__c = 'www.setduetounavailability.com';
                                    }
                                    newWeb.status__c='Approved';
                                    newWeb.Is_Migration__c = true;
                                    newWeb.Name = 'Terms & Conditions Details';
                                    newWeb.Page_Details__c = '['+string.join(pageDetailWithNameMap.get('Terms & Conditions Details'), ', ')+']';                                       
                                	websiteToBeInserted.add(newWeb);
                                }                                
                            
                        }
                    }
                }  
            } 
            
            system.debug('##### websiteToBeInserted '+websiteToBeInserted);
            system.debug('##### existingWebsiteToBeUpdated '+existingWebsiteToBeUpdated);
            if(!websiteToBeInserted.isEmpty()) Database.insert(websiteToBeInserted,false);
            if(!existingWebsiteToBeUpdated.isEmpty()) Database.update(existingWebsiteToBeUpdated,false);
        }
        
        if(!IntegrationUtility.logList.isEmpty()) Database.insert(IntegrationUtility.logList, false);
*/
    }
    
    global void finish(Database.BatchableContext BC) {
        Batch_Setting__mdt bsMDT = [Select Id,Record_Limit__c,Where_Clause__c,Re_Run_Apex_Job__c from Batch_Setting__mdt where DeveloperName=:'PublishExistingOppotunityWebsiteBatch2' LIMIT 1];
        if(!Test.isRunningTest()){
            if(bsMDT.Re_Run_Apex_Job__c){
                Database.executeBatch(new PublishExistingOppotunityWebsiteBatch2());
            }
        }
    }
}