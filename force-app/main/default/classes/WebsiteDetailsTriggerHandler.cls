public class WebsiteDetailsTriggerHandler {
    public static Boolean runningFromConsumerAPI = false;
    public static Boolean runningWebsiteDetails = false; // added by rohit risk revamp
    //Commented due to Multiproduct change, Website status is not syncing due to lead type and merchantBusinessType declared
    //public static List<String> merchantBusinessTypeList = New List<String>();//{'LongTail','Compulsive'};
        //public static List<String> leadTypeList = New List<String>();//{'Merchant','Seller','ProductAccount', 'Aggregator', 'Partner'};
            
            public static void beforeInsertHandler(List<Website_Details__c> triggerNew){
                Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Website_Details__c');
                Map<Id, Opportunity> mapOpportunity = New Map<Id, Opportunity>();
                List<Website_Details__c> lstWebsiteDetails = New List<Website_Details__c>();
                for(Website_Details__c wdObj : triggerNew){
                    // call this method to get the identifier field value if not exist                    
                    SystemUtility.getIdentifierUUID(wdObj, 'Identifier__c', enableUUIDObj); 
                    
                    //===========get Active website details records===========
                    getActiveWebsiteDetails(wdObj, null, lstWebsiteDetails, mapOpportunity);
                }
             
                
                
                //==============Website Detail check to Insert only one active record at once=======
                if(!lstWebsiteDetails.isEmpty()) processActiveWebsiteDetail(lstWebsiteDetails, mapOpportunity);
            }
    
    public static void beforeUpdateHandler(List<Website_Details__c> triggerNew, Map<Id,Website_Details__c> triggerOldMap){
       Map<Id, Opportunity> mapOpportunity = New Map<Id, Opportunity>();
        List<Website_Details__c> lstWebsiteDetails = New List<Website_Details__c>();
        for(Website_Details__c wdObj : triggerNew){
            //===========get Active website details records===========
            getActiveWebsiteDetails(wdObj, triggerOldMap.get(wdObj.Id), lstWebsiteDetails, mapOpportunity);
        }
        //==============Website Detail check to Insert only one active record at once=======
        if(!lstWebsiteDetails.isEmpty()) processActiveWebsiteDetail(lstWebsiteDetails, mapOpportunity);
    }
    
    public static void afterInsertHandler(List<Website_Details__c> triggerNew){
        Map<Id,Opportunity> opportunityMap = New Map<Id,Opportunity>();
        List<Opportunity> opportunityToUpdate = New List<Opportunity>();
        Set<Id> oppIdSet = New Set<Id>();
        List<Task> taskList = New List<Task>();
        
        for(Website_Details__c wdObj : triggerNew){
            if(string.isNotBlank(wdObj.Opportunity__c) && wdObj.Website_Status__c != 'Website OK' && ((String.isNotBlank(wdObj.Website_URL__c))
                                                                                                      || (String.isNotBlank(wdObj.IOS_URL__c))
                                                                                                      || (String.isNotBlank(wdObj.Android_URL__c)))
               && wdObj.Active__c){
                   oppIdSet.add(wdObj.Opportunity__c);
                   
                   runningWebsiteDetails  = true;
               }
            if(!system.isBatch() && wdObj.Data_need_to_be_publish__c  && !runningFromConsumerAPI){
                IntegrationUtility.sendPayLoadData(wdObj, null, 'Website_Details__c', 'Website_Details__c'); 
            }
        }
        
        if(!oppIdSet.isEmpty()){
            getOpportunityData(oppIdSet, opportunityMap);
        }
        
        if(!opportunityMap.isEmpty()){
            updateParentObjData(triggerNew, opportunityMap, opportunityToUpdate, taskList);
        }
        if(!opportunityToUpdate.isEmpty()) update opportunityToUpdate;
        
        if(!taskList.isEmpty()) Insert taskList;
    }
    
    public static void afterUpdateHandler(List<Website_Details__c> triggerNew, Map<Id,Website_Details__c> triggerOldMap){
            Map<Id,Opportunity> opportunityMap = New Map<Id,Opportunity>();
            List<Opportunity> opportunityToUpdate = New List<Opportunity>();
            Set<Id> oppIdSet = New Set<Id>();
            List<Task> taskList = New List<Task>();
        	List<Opportunity> oppListToUpdateStatusTrue = new List<Opportunity>();//new added risk revamp
        	
            Set<Id> oppIdToUpdateWebsiteUrlAndStatus  = new Set<Id>(); // Risk Revamp added by rohit gupta to store the opportunity for current website details
            Set<Id> oppIdToUpdateWebsiteTrue  = new Set<Id>(); // Risk Revamp added by rohit gupta to store the opportunity for current website details 
        	Set<Id> webDetailsIdTrue = new Set<Id>(); // Risk Revamp added by rohit
        	Set<Id> webDetailsIdFalse = new Set<Id>(); // Risk Revamp added by rohit
        	for(Website_Details__c wdObj : triggerNew){
                Website_Details__c oldWdObj = triggerOldMap.get(wdObj.Id);
               
                if(wdObj.Active__c && wdObj.Website_Status__c != 'Website OK' && ((string.isNotBlank(wdObj.Opportunity__c) && wdObj.Opportunity__c != oldWdObj.Opportunity__c)
                                                                                  || (string.isNotBlank(wdObj.Website_Status__c) && wdObj.Website_Status__c != oldWdObj.Website_Status__c) 
                                                                                  || (wdObj.Is_Website_Live__c != oldWdObj.Is_Website_Live__c) || (wdObj.Active__c != oldWdObj.Active__c)
                                                                                  || (String.isNotBlank(wdObj.Website_URL__c) && wdObj.Website_URL__c != oldWdObj.Website_URL__c)
                                                                                  || (String.isNotBlank(wdObj.IOS_URL__c) && wdObj.IOS_URL__c != oldWdObj.IOS_URL__c)
                                                                                  || (String.isNotBlank(wdObj.Android_URL__c) && wdObj.Android_URL__c != oldWdObj.Android_URL__c))){
                                                                                      oppIdSet.add(wdObj.Opportunity__c);
                                                                                  }
               
                // added by rohit
                // Checking if any website details is true and it is becming false by user then in this
                // case opp website and status should be also empty : line 91 to 93
                if(!wdObj.Active__c && oldWdObj.Active__c && oldWdObj.Active__c != wdObj.Active__c && (string.isNotBlank(wdObj.Opportunity__c))){
                    oppIdToUpdateWebsiteUrlAndStatus.add(wdObj.Opportunity__c);
                    webDetailsIdFalse.add(oldWdObj.Id); // Risk Revamp added by rohit
                    System.debug('webDetailsIdFalse:::::'+webDetailsIdFalse);
                }
                if( !oldWdObj.Active__c && wdObj.Active__c  && string.isNotBlank(wdObj.Opportunity__c)){ // added by rohit Risk Revamp
                    oppIdToUpdateWebsiteTrue.add(wdObj.Opportunity__c);
                    Opportunity opp = new Opportunity();
                    opp.Website__c = wdObj.Website_URL__c;
                    opp.Id = wdObj.Opportunity__c;
                    opp.Website_Status__c =  wdObj.Website_Status__c;
                    oppListToUpdateStatusTrue.add(opp);
                    runningWebsiteDetails = true;
                    webDetailsIdTrue.add(wdObj.Id); // Risk Revamp added by rohit
                }
                if(!system.isBatch() && wdObj.Data_need_to_be_publish__c && !runningFromConsumerAPI){
                    IntegrationUtility.sendPayLoadData(wdObj, oldWdObj, 'Website_Details__c', 'Website_Details__c'); 
                }
            }
        if(!oppIdSet.isEmpty()){
            getOpportunityData(oppIdSet, opportunityMap);
        }
        if(!opportunityMap.isEmpty()){
            updateParentObjData(triggerNew, opportunityMap, opportunityToUpdate, taskList);
        }
        /*added by rohit
         *Quering the current opp if the website details became false then need to update the website status and url as empty 
		*/ 
        List<Opportunity> oppListToUpdateStatusAndUrl = new List<Opportunity>();
        List<Website_Details__c> oldWebsiteUpdateToFalse = new List<Website_Details__c>();
        List<Website_Page__c> updateWebPageToTrue = new List<Website_Page__c>();
        List<Website_Page__c> updateWebPageToFalse = new List<Website_Page__c>();
        if(oppIdToUpdateWebsiteUrlAndStatus !=NULL && oppIdToUpdateWebsiteUrlAndStatus.size()>0){
            for(Opportunity opp : [SELECT Id,Website__c,Website_Status__c FROM Opportunity WHERE Id=:oppIdToUpdateWebsiteUrlAndStatus]){
                opp.Website__c = '';
                opp.Website_Status__c = '';
                opp.Android_URL__c = '';
                opp.iOS_URL__c = '';
                oppListToUpdateStatusAndUrl.add(opp);
                System.debug('opp:::::47:::::'+opp);
            	}
             if(!OpportunityTriggerHandler.isWebsiteUpdate &&  oppListToUpdateStatusAndUrl !=NULL && oppListToUpdateStatusAndUrl.size()>0){
            update oppListToUpdateStatusAndUrl; 
                if(webDetailsIdFalse !=NULL){
                    for(Website_Page__c  webPage : [SELECT Id,Active__c FROM Website_Page__c  WHERE Website_Details__c =:webDetailsIdFalse]){
                        webPage.Active__c = False;
                        updateWebPageToFalse.add(webPage);
                    }
                    if(updateWebPageToFalse !=NULL && updateWebPageToFalse.size()>0){
                        update updateWebPageToFalse;
                    } 
                }
             }
        }
        if(oppIdToUpdateWebsiteTrue !=NULL && oppIdToUpdateWebsiteTrue.size()>0){
            if(webDetailsIdTrue !=NULL){
                for(Website_Page__c  webPage : [SELECT Id,Active__c FROM Website_Page__c  WHERE Website_Details__c =:webDetailsIdTrue]){
                    webPage.Active__c = True;
                    updateWebPageToTrue.add(webPage);
                }
                if(updateWebPageToTrue !=NULL && updateWebPageToTrue.size()>0){
                    update updateWebPageToTrue;
                }
            }
             if(!OpportunityTriggerHandler.isWebsiteUpdate && oppIdToUpdateWebsiteTrue !=NULL ){
                update oppListToUpdateStatusTrue;
                  
            }
        }
        /****END*****/
        if(!opportunityToUpdate.isEmpty() && opportunityToUpdate.size()>0){
                System.debug('opportunityToUpdate:::::'+opportunityToUpdate);
                //update opportunityToUpdate; 
            } 
        
            if(!taskList.isEmpty()) Insert taskList;
        
    }
    
    public static void getActiveWebsiteDetails(Website_Details__c each, Website_Details__c oldEach, List<Website_Details__c> lstWebsiteDetails, Map<Id, Opportunity> mapOpportunity){
        if(validateActiveWebsiteDetail(each, oldEach)){
            lstWebsiteDetails.add(each);
            if(each.Opportunity__c != null) mapOpportunity.put(each.Opportunity__c, null);
        }                
    }
    
    public static Boolean validateActiveWebsiteDetail(Website_Details__c each, Website_Details__c oldEach){
        return (each.Active__c && each.Opportunity__c != null) && 
            (Trigger.isInsert || 
             (Trigger.isUpdate && 
              ((each.Opportunity__c != oldEach.Opportunity__c && each.Opportunity__c != null) || each.Active__c != oldEach.Active__c)
             ));
    }
    
    public static void processActiveWebsiteDetail(List<Website_Details__c> lstWebsiteDetails, Map<Id, Opportunity> mapOpportunity){
        if(!mapOpportunity.isEmpty()) mapOpportunity.putAll([SELECT Id, (SELECT Id, Active__c FROM Website_Details__r WHERE Active__c = true) FROM Opportunity WHERE Id IN : mapOpportunity.keyset()]);
        Map<Id, Website_Details__c> websiteDetailsMap = New Map<Id, Website_Details__c>();
        for(Website_Details__c each : lstWebsiteDetails){
            if(each.Opportunity__c != null && mapOpportunity.containskey(each.Opportunity__c) && mapOpportunity.get(each.Opportunity__c) != null && !mapOpportunity.get(each.Opportunity__c).Website_Details__r.isEmpty()){
                //if(!Test.isRunningTest()) each.Opportunity__
                //c.addError('Opportunity has already an active Website details records.');
                for(Website_Details__c existingWebsite : mapOpportunity.get(each.Opportunity__c).Website_Details__r){
                    existingWebsite.Active__c = false;
                    websiteDetailsMap.put(existingWebsite.Id, existingWebsite);
                }
            }
        }
        if(!websiteDetailsMap.isEmpty()) update websiteDetailsMap.values();
    }
    
    public static void updateParentObjData(List<Website_Details__c> triggerNew, Map<Id,Opportunity> opportunityMap, List<Opportunity> opportunityToUpdate, List<Task> taskList){
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));
        List<String> queueDeveloperNames = New List<String>{'Pre_Onboarding_Risk_Team','Risk_Team_For_CS'};
            
            Map<String,List<GroupMember>> queueDeveloperNameVsMembers = SystemUtility.getQueuesNameMembers(queueDeveloperNames);
        Integer userIndex;
        List<String> BusinessCategorysName = Label.Business_Category.split(',');
        Map<string,string> BusinessHourIdMap = (Map<string,string>)json.deserialize(System.label.BusinessHourNameIdMap, Map<string,string>.class);
        String BusinessHourId = BusinessHourIdMap.get('PayU OneCare Child');
        Map<Id,Merchant_Plan__c> merchantPlanVsOppIdMap = New Map<Id,Merchant_Plan__c>();
        List<Website_Details__c> autoApproveWebsiteDetailList = New List<Website_Details__c>();
        
        //Added by Kunal | 30th May 2022
        Set<Id> setOpportunityIdsToSkipTaskCreation = new Set<Id>();
        if(opportunityMap != NULL && opportunityMap.keySet().size() > 0) {
        	for(Task tsk : [SELECT WhatId,Status FROM Task 
                            WHERE WhatId IN :opportunityMap.keySet() 
                            AND Status IN ('Open','Not Started') 
                            AND Subject IN ('Website Status is in Verification in Process','Website Status is in Verification in Process for Premium Customer')]) {
                            	setOpportunityIdsToSkipTaskCreation.add(tsk.WhatId);    
                            }   
        }
       	//End by Kunal | 30th May 2022
        
        //========get Merchant Plan Map Data================
        for(Merchant_Plan__c mpObj : [Select Id,Opportunity__c,Plan_Type__c from Merchant_Plan__c Where Opportunity__c IN: opportunityMap.keySet() LIMIT 1]){
            merchantPlanVsOppIdMap.put(mpObj.Opportunity__c,mpObj);
        }
        for(Website_Details__c wdObj : triggerNew){
            if(string.isNotBlank(wdObj.Opportunity__c) && opportunityMap.containsKey(wdObj.Opportunity__c)){
                Opportunity oppObj = opportunityMap.get(wdObj.Opportunity__c);
                oppObj.Website_Status__c = wdObj.Website_Status__c;
                oppObj.Android_URL__c = String.isNotBlank(wdObj.Android_URL__c) ?  wdObj.Android_URL__c : '';
                oppObj.IOS_URL__c = String.isNotBlank(wdObj.IOS_URL__c) ? wdObj.IOS_URL__c : '';
                oppObj.Website__c = String.isNotBlank(wdObj.Website_URL__c) ? wdObj.Website_URL__c : '' ;
                
                if(!opportunityMap.get(wdObj.Opportunity__c).Skip_Website_Verification__c){
                    if(wdObj.Active__c && (String.isNotBlank(wdObj.Website_URL__c) || String.isNotBlank(wdObj.Android_URL__c) || String.isNotBlank(wdObj.IOS_URL__c))
                       && string.isNotBlank(wdObj.Website_Status__c)
                       //&& merchantBusinessTypeList.contains(opportunityMap.get(wdObj.Opportunity__c).Merchant_Business_Type__c) 
                       && (String.isBlank(wdObj.Addendum_Status__c) || wdObj.Addendum_Status__c != 'Pending')){
                      /*Commented the following line : SFI-328 | Kunal Raj - 30th May 2022 :-
                        && (opportunityMap.get(wdObj.Opportunity__c).Integration_Type__c == 'ThirdParty' || opportunityMap.get(wdObj.Opportunity__c).Integration_Type__c == 'Tools') 
                      */      
                   //===========================Commenting to remove the criteria of non-creation of website task for NDX<50K====================================================================================================
                          /* if(opportunityMap.get(wdObj.Opportunity__c).NDX_Score__c > 0 && opportunityMap.get(wdObj.Opportunity__c).NDX_Score__c <=50000 && wdObj.Website_Status__c == 'Verification in Process' 
                              && !BusinessCategorysName.contains(opportunityMap.get(wdObj.Opportunity__c).BusinessCategory__r.Name)){
                                  
                                  oppObj.Website_Status__c = 'Website OK';
                                  oppObj.Risk_Level__c = 'High-Auto Approved';
                                  
                                  //==========Website Detail to update=============
                                  Website_Details__c wdObjToUpdate = New Website_Details__c(Id = wdObj.Id, Website_Status__c = 'Website OK');
                                  autoApproveWebsiteDetailList.add(wdObjToUpdate);
                              }*/
                    //====================Comment-End=============================================================================================================       
                           //else if((opportunityMap.get(wdObj.Opportunity__c).NDX_Score__c > 50000 || opportunityMap.get(wdObj.Opportunity__c).NDX_Score__c == 0 || opportunityMap.get(wdObj.Opportunity__c).NDX_Score__c == null) && wdObj.Website_Status__c == 'Verification in Process' && !BusinessCategorysName.contains(opportunityMap.get(wdObj.Opportunity__c).BusinessCategory__r.Name)){
                           if((opportunityMap.get(wdObj.Opportunity__c).NDX_Score__c > 50000 || opportunityMap.get(wdObj.Opportunity__c).NDX_Score__c == 0 || opportunityMap.get(wdObj.Opportunity__c).NDX_Score__c == null || (opportunityMap.get(wdObj.Opportunity__c).NDX_Score__c > 0 && opportunityMap.get(wdObj.Opportunity__c).NDX_Score__c <=50000)) && wdObj.Website_Status__c == 'Verification in Process' && !BusinessCategorysName.contains(opportunityMap.get(wdObj.Opportunity__c).BusinessCategory__r.Name)){
                               // create task for risk team
                               if(!opportunityMap.get(wdObj.Opportunity__c).isPremiumCustomer__c){
                                  if(queueDeveloperNameVsMembers.containsKey('Pre_Onboarding_Risk_Team') && queueDeveloperNameVsMembers.get('Pre_Onboarding_Risk_Team') != null){
                                       userIndex = Math.mod(IntrandomNumber, queueDeveloperNameVsMembers.get('Pre_Onboarding_Risk_Team').Size());
                                   }
                                   if(!setOpportunityIdsToSkipTaskCreation.contains(wdObj.Opportunity__c)) {
                                   	SystemUtility.createTask(taskList, System.today(), '', False, null, queueDeveloperNameVsMembers.get('Pre_Onboarding_Risk_Team').get(userIndex).UserOrGroupId, 'Normal', null, Label.VIP_task_Subject, 'Not Started', wdObj.Opportunity__c);    
                                   }
                                   
                                   
                               }else{
                                   if(queueDeveloperNameVsMembers.containsKey('Risk_Team_For_CS') && queueDeveloperNameVsMembers.get('Risk_Team_For_CS') != null && merchantPlanVsOppIdMap.containsKey(wdObj.Opportunity__c)){
                                       userIndex = Math.mod(IntrandomNumber, queueDeveloperNameVsMembers.get('Risk_Team_For_CS').Size());
                                   }
                                   if(!setOpportunityIdsToSkipTaskCreation.contains(wdObj.Opportunity__c)) {
                                    	SystemUtility.createTask(taskList, System.today()+1, '', True, merchantPlanVsOppIdMap.get(wdObj.Opportunity__c).Id, queueDeveloperNameVsMembers.get('Risk_Team_For_CS').get(userIndex).UserOrGroupId, 'High', MerchantPlanTriggerHandler.addBusinessHours(BusinessHourId,System.now(),10800000), Label.VIP_task_Subject_Premium, 'Not Started', wdObj.Opportunity__c);   
                                   }
                                   
                               }
                               IntrandomNumber = IntrandomNumber+1;
                           }
                           else if(wdObj.Website_Status__c == 'Pending' && wdObj.Is_Website_Live__c == 'active' && !BusinessCategorysName.contains(opportunityMap.get(wdObj.Opportunity__c).BusinessCategory__r.Name)){
                               // create task for risk team
                               if(!opportunityMap.get(wdObj.Opportunity__c).isPremiumCustomer__c){
                                   if(queueDeveloperNameVsMembers.containsKey('Pre_Onboarding_Risk_Team') && queueDeveloperNameVsMembers.get('Pre_Onboarding_Risk_Team') != null){
                                       userIndex = Math.mod(IntrandomNumber, queueDeveloperNameVsMembers.get('Pre_Onboarding_Risk_Team').Size());
                                   }
                                   if(!setOpportunityIdsToSkipTaskCreation.contains(wdObj.Opportunity__c)) {
                                       SystemUtility.createTask(taskList, System.today(), '', False, null, queueDeveloperNameVsMembers.get('Pre_Onboarding_Risk_Team').get(userIndex).UserOrGroupId, 'Normal', null, Label.VIP_task_Subject, 'Not Started', wdObj.Opportunity__c);
                                   }
                               }else{
                                   if(queueDeveloperNameVsMembers.containsKey('Risk_Team_For_CS') && queueDeveloperNameVsMembers.get('Risk_Team_For_CS') != null && merchantPlanVsOppIdMap.containsKey(wdObj.Opportunity__c)){
                                       userIndex = Math.mod(IntrandomNumber, queueDeveloperNameVsMembers.get('Risk_Team_For_CS').Size());
                                   }
                                   if(!setOpportunityIdsToSkipTaskCreation.contains(wdObj.Opportunity__c) && !merchantPlanVsOppIdMap.isEmpty() && !queueDeveloperNameVsMembers.isEmpty())
                                   SystemUtility.createTask(taskList, System.today()+1, '', True, merchantPlanVsOppIdMap.get(wdObj.Opportunity__c).Id, queueDeveloperNameVsMembers.get('Risk_Team_For_CS').get(userIndex).UserOrGroupId, 'High', MerchantPlanTriggerHandler.addBusinessHours(BusinessHourId,System.now(),10800000), Label.VIP_task_Subject_Premium, 'Not Started', wdObj.Opportunity__c);
                               }
                               IntrandomNumber = IntrandomNumber+1;
                           }else if(wdObj.Website_Status__c == 'Verification in Process' && BusinessCategorysName.contains(opportunityMap.get(wdObj.Opportunity__c).BusinessCategory__r.Name)){
                               if(!opportunityMap.get(wdObj.Opportunity__c).isPremiumCustomer__c){
                                   if(queueDeveloperNameVsMembers.containsKey('Pre_Onboarding_Risk_Team') && queueDeveloperNameVsMembers.get('Pre_Onboarding_Risk_Team') != null){
                                       userIndex = Math.mod(IntrandomNumber, queueDeveloperNameVsMembers.get('Pre_Onboarding_Risk_Team').Size());
                                   }
                                   SystemUtility.createTask(taskList, System.today(), '', False, null, queueDeveloperNameVsMembers.get('Pre_Onboarding_Risk_Team').get(userIndex).UserOrGroupId, 'Normal', null, Label.Business_Category_Task, 'Not Started', wdObj.Opportunity__c);
                               }else{
                                   if(queueDeveloperNameVsMembers.containsKey('Risk_Team_For_CS') && queueDeveloperNameVsMembers.get('Risk_Team_For_CS') != null && merchantPlanVsOppIdMap.containsKey(wdObj.Opportunity__c)){
                                       userIndex = Math.mod(IntrandomNumber, queueDeveloperNameVsMembers.get('Risk_Team_For_CS').Size());
                                   }
                                   if(!merchantPlanVsOppIdMap.isEmpty() && !queueDeveloperNameVsMembers.isEmpty())
                                   SystemUtility.createTask(taskList, System.today()+1, '', True, merchantPlanVsOppIdMap.get(wdObj.Opportunity__c).Id, queueDeveloperNameVsMembers.get('Risk_Team_For_CS').get(userIndex).UserOrGroupId, 'High', MerchantPlanTriggerHandler.addBusinessHours(BusinessHourId,System.now(),10800000),Label.Business_Category_Task, 'Not Started', wdObj.Opportunity__c);
                               }
                               IntrandomNumber = IntrandomNumber+1;
                           }else if(wdObj.Website_Status__c == 'Pending' && wdObj.Is_Website_Live__c == 'active' && BusinessCategorysName.contains(opportunityMap.get(wdObj.Opportunity__c).BusinessCategory__r.Name)){
                               
                               if(!opportunityMap.get(wdObj.Opportunity__c).isPremiumCustomer__c){
                                   if(queueDeveloperNameVsMembers.containsKey('Pre_Onboarding_Risk_Team') && queueDeveloperNameVsMembers.get('Pre_Onboarding_Risk_Team') != null){
                                       userIndex = Math.mod(IntrandomNumber, queueDeveloperNameVsMembers.get('Pre_Onboarding_Risk_Team').Size());
                                   }
                                   SystemUtility.createTask(taskList, System.today(), '', False, null, queueDeveloperNameVsMembers.get('Pre_Onboarding_Risk_Team').get(userIndex).UserOrGroupId, 'Normal', null, Label.Business_Category_Task, 'Not Started', wdObj.Opportunity__c);
                               }else{
                                   if(queueDeveloperNameVsMembers.containsKey('Risk_Team_For_CS') && queueDeveloperNameVsMembers.get('Risk_Team_For_CS') != null && merchantPlanVsOppIdMap.containsKey(wdObj.Opportunity__c)){
                                       userIndex = Math.mod(IntrandomNumber, queueDeveloperNameVsMembers.get('Risk_Team_For_CS').Size());
                                   }
                                   if(!merchantPlanVsOppIdMap.isEmpty() && !queueDeveloperNameVsMembers.isEmpty())
                                   SystemUtility.createTask(taskList, System.today()+1, '', True, merchantPlanVsOppIdMap.get(wdObj.Opportunity__c).Id, queueDeveloperNameVsMembers.get('Risk_Team_For_CS').get(userIndex).UserOrGroupId, 'High', MerchantPlanTriggerHandler.addBusinessHours(BusinessHourId,System.now(),10800000),Label.Business_Category_Task, 'Not Started', wdObj.Opportunity__c);
                               }
                               IntrandomNumber = IntrandomNumber+1;
                           }
                           //}
                           
                       }
                }else{
                    oppObj.Website_Remarks__c='Website marked auto approved for whitelabel Partner Referred Merchants';
                    oppObj.Website_Status__c = 'Website OK';
                    oppObj.Risk_Level__c = 'High-Auto Approved';
                    
                    //==========Website Detail to update=============
                    Website_Details__c wdObjToUpdate = New Website_Details__c(Id = wdObj.Id, Website_Status__c = 'Website OK');
                    autoApproveWebsiteDetailList.add(wdObjToUpdate);
                }
                opportunityToUpdate.add(oppObj);
            }
        }
        
        if(!autoApproveWebsiteDetailList.isEmpty()) update autoApproveWebsiteDetailList;
    }
    
    public static void getOpportunityData(Set<Id> oppIdSet, Map<Id,Opportunity> opportunityMap){
        if(!oppIdSet.isEmpty()){
            for(Opportunity oppObj : [Select Id,Monthly_Expected_Sale__c,NDX_Score__c,Integration_Type__c,Risk_Level__c,
                                      Website_Status__c,Merchant_Business_Type__c,BusinessCategory__r.Name,Lead_Type__c,
                                      isPremiumCustomer__c,Skip_Website_Verification__c,Website__c,IOS_URL__c,Android_URL__c from Opportunity Where Id IN: oppIdSet]){ 
                                          //AND Lead_Type__c IN : leadTypeList] || Commented due to Multiproduct change, Website status is not syncing due to lead type declared on line no.5
                                          opportunityMap.put(oppObj.Id,oppObj);
                                      }
        }
    }
}