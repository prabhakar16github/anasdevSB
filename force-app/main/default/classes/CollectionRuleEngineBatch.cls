/*
    @author: Eitika Verma
    @company: Saasfocus
    @date : 1/11/2018
    @description: To execute the rule engine batch
*/
public class CollectionRuleEngineBatch implements Database.batchable <sObject>,Database.stateful{ 
    public map<string,map<string,map<string,map<String,Collection_Rule_Engine__mdt>>>> mapOfCustScoreVsData;
    public list<Case> lstCase;
    public set<string> setOfQueueName;
    public string strProcessName;
    public map<string,Id> mapOfQueueNameVsQueueId;
    public map<string,CollectionProcessMapping__mdt> mapOfProcessNameVsBatchProcessMdt;
    public map<string,Id> mapOfSMSNameVsId;
    public CollectionRuleEngineBatch(string processName){
        strProcessName = processName;
        setOfQueueName = new set<string>();
        mapOfProcessNameVsBatchProcessMdt = new map<string,CollectionProcessMapping__mdt>();
        mapOfQueueNameVsQueueId = new map<string,Id>();
        mapOfSMSNameVsId = CollectionNotificationUtility.getSMSTemplateId('Collection SMS');
        mapOfCustScoreVsData = new map<string,map<string,map<string,map<String,Collection_Rule_Engine__mdt>>>>();
        
    }
    
   
     public Database.QueryLocator start(Database.BatchableContext BC){
      string query ='SELECT Id,ContactId,Priority,LP_IVR_Call__c,status,LP_SMS_Content__c,LP_Outstanding_Amount__c,LP_Customer_Score__c,LP_Manual_Call__c,LP_SMS__c,LP_Email__c,LP_APP_Notification__c,LP_Communication_Type__c,LP_Communication_sub_type__c,LP_IVR_Call_Count__c,LP_Email_Template_Name__c,LP_CL_Status__c FROM Case where recordtype.developername = \'Collection\' and status != \'Closed\' order by LP_Status_Priority_Order__c asc';
      system.debug('Query+++'+query);
      return Database.getQueryLocator(query);
   } //Pooja removed LP_DPD__c
    
   public void execute(Database.BatchableContext info, List<Case> scope){
       try{
           System.debug('Scope in collection rule engine :' + scope.size());
           lstCase = new list<Case>();
           //get the data of rule engine
           if(mapOfCustScoreVsData != NULL && mapOfCustScoreVsData.size() == 0){
               getCollectionRuleEngineMetaData();
              
           }
           if(mapOfQueueNameVsQueueId != NULL && mapOfQueueNameVsQueueId.size() ==0){
               getQueueAndBatchName();
               list<string> lstQueues = new list<string>();
               if(setOfQueueName != NULL && setOfQueueName.size()>0)
                    lstQueues.addAll(setOfQueueName);
               mapOfQueueNameVsQueueId = SystemUtility.getQueuesInfo(lstQueues);
           }
           
           if(mapOfCustScoreVsData != NULL && mapOfCustScoreVsData.size() > 0){
               for(Case eachCase : scope){
                   string strCustomerKey = '';
                   string strAmntKey = '';
                   string strDPDKey = '';
                   String strcLStatus = '';
                   
                   //get the customer key value which is the outermost key of map
                   //this map stores the rule engine data
                   system.debug('eachCase.LP_Customer_Score__c======'+ eachCase.LP_Customer_Score__c);
                   system.debug('eachCase.LP_Outstanding_Amount__c======'+ eachCase.LP_Outstanding_Amount__c);
                  // system.debug('eachCase.LP_DPD__c======'+ eachCase.LP_DPD__c);
                   system.debug('eachCase.LP_CL_Status__c======'+ eachCase.LP_CL_Status__c);
                   system.debug('mapOfCustScoreVsData' + mapOfCustScoreVsData.keySet());
                   if(eachCase.LP_Customer_Score__c != NULL && mapOfCustScoreVsData.containsKey(String.valueOf(eachCase.LP_Customer_Score__c))){
                       strCustomerKey = String.valueOf(eachCase.LP_Customer_Score__c);
                   }
                   else{
                       for(string eachOuterKey : mapOfCustScoreVsData.Keyset()){
                           strCustomerKey = getKeyVal(eachCase.LP_Customer_Score__c,eachOuterKey);
                           if(String.isNotBlank(strCustomerKey))
                               break;
                       }
                   } 
                   
                   //get the outstanding amount key value which is the key of inner map
                   if(String.isNotBlank(strCustomerKey) && mapOfCustScoreVsData.containsKey(strCustomerKey)){
                       if(mapOfCustScoreVsData.get(strCustomerKey).containskey(String.valueOf(eachCase.LP_Outstanding_Amount__c))){
                           strAmntKey = String.valueOf(eachCase.LP_Outstanding_Amount__c);
                       }
                       else{
                           for(string eachInnerKey : mapOfCustScoreVsData.get(strCustomerKey).keyset()){
                               strAmntKey = getKeyVal(eachCase.LP_Outstanding_Amount__c,eachInnerKey);
                               if(String.isNotBlank(strAmntKey))
                                    break;
                           }
                       }
                   }
                   
                   //get the DPD value which is the key of innermost map
                  /* if(String.isNotBlank(strAmntKey) && mapOfCustScoreVsData.get(strCustomerKey).containsKey(strAmntKey)){
                       if(mapOfCustScoreVsData.get(strCustomerKey).get(strAmntKey).containsKey(String.ValueOf(eachCase.LP_DPD__c))){
                           strDPDKey = String.ValueOf(eachCase.LP_DPD__c);
                       }
                       else{
                           for(string eachDPD : mapOfCustScoreVsData.get(strCustomerKey).get(strAmntKey).keyset()){
                               strDPDKey = getKeyVal(eachCase.LP_DPD__c,eachDPD);
                               if(String.isNotBlank(strDPDKey))
                                   break;
                           }
                       }
                   }*/ //Pooja
                   // get the CL_Status value
                   if(String.isNotBlank(strCustomerKey) && String.isNotBlank(strAmntKey) && String.isNotBlank(strDPDKey) && mapOfCustScoreVsData.get(strCustomerKey).containsKey(strAmntKey) &&
                     mapOfCustScoreVsData.get(strCustomerKey).get(strAmntKey).containsKey(strDPDKey)){
                       System.debug('Cl status 11' );  
                       if(mapOfCustScoreVsData.get(strCustomerKey).get(strAmntKey).get(strDPDKey).containsKey(String.ValueOf(eachCase.LP_CL_Status__c))){
                           System.debug('Cl Status 22:: ' );
                           strcLStatus = String.ValueOf(eachCase.LP_CL_Status__c);
                       }
                   }     
                   
                   
                   
                   system.debug('strCustomerKey======'+strCustomerKey); 
                   system.debug('strAmntKey====='+strAmntKey);
                   system.debug('strDPDKey====='+strDPDKey); 
                   System.debug('strcLStatus======' + strcLStatus);
                   //on the basis of Customer Score key, outstanding amount key and DPD key value get the data from custom metatdata
                   //update the values on case
                   if(String.isNotBlank(strDPDKey) && String.isNotBlank(strCustomerKey) && String.isNotBlank(strAmntKey) && String.isNotBlank(strcLStatus) && mapOfCustScoreVsData.get(strCustomerKey).get(strAmntKey).containsKey(strDPDKey)){
                        Collection_Rule_Engine__mdt objCollectionMdt = mapOfCustScoreVsData.get(strCustomerKey).get(strAmntKey).get(strDPDKey).get(strcLStatus);
                       system.debug('objCollectionMdt====='+objCollectionMdt); 
                       Case objCase = updateCaseDetails(objCollectionMdt,eachCase);
                        lstCase.add(objCase);
                       system.debug('lstCase====='+lstCase);
                    }
               }
            }
           if(lstCase!= NULL && lstCase.size()>0){
               system.debug('lstCase======='+lstCase.size());
               update lstCase;
           }
       }
       catch(Exception ex){
            System.debug('Exception Occured : ');
            LazyPayExceptionHandling.ErrorLogWrapper objWrapper = new LazyPayExceptionHandling.ErrorLogWrapper();
            objWrapper.message = ex.getMessage();
            objWrapper.process = 'CollectionRuleEngineBatch';
            objWrapper.stackTrace = ex.getStackTraceString();
            LazyPayExceptionHandling.insertErrorLog(objWrapper);
        }
   }
    
   public void finish(Database.BatchableContext info){
       
           if(String.isNotBlank(strProcessName) && mapOfProcessNameVsBatchProcessMdt!= NULL 
               && mapOfProcessNameVsBatchProcessMdt.size()>0 
               && mapOfProcessNameVsBatchProcessMdt.containsKey(strProcessName)){
                   string strClassName = mapOfProcessNameVsBatchProcessMdt.get(strProcessName).Batch_Class_Name__c;
                   String configParameters = '{"strProcess":'+ '"'+ mapOfProcessNameVsBatchProcessMdt.get(strProcessName).developerName + '"}';
                    BatchCommonClass p = (BatchCommonClass) JSON.deserialize(configParameters, BatchCommonClass.class);
                   Type classType = Type.forName(strClassName);
                   System.debug('strClassName===='+strClassName);
                   Database.executeBatch((Database.Batchable<sObject>)classType.newInstance(),100);
                   
                   
               }
       //}
   } 
  
    public case updateOwnerOnCase(Case objCase){
        if(mapOfQueueNameVsQueueId != NULL && mapOfQueueNameVsQueueId.size()>0){
            if(String.isNotBlank(strProcessName) && mapOfProcessNameVsBatchProcessMdt!= NULL 
               && mapOfProcessNameVsBatchProcessMdt.size()>0 
               && mapOfProcessNameVsBatchProcessMdt.containsKey(strProcessName)){
                   CollectionProcessMapping__mdt objMdt = mapOfProcessNameVsBatchProcessMdt.get(strProcessName);
                   CollectionProcessMapping__mdt objManualMdt = mapOfProcessNameVsBatchProcessMdt.get('Manual Call');
                   if(objCase.get(objMdt.Flag_On_Case__c) != NULL && (Decimal)objCase.get(objMdt.Flag_On_Case__c) > 0)
                        objCase.OwnerId = mapOfQueueNameVsQueueId.get(objMdt.Queue_Name__c);
                   else if(objCase.get(objManualMdt.Flag_On_Case__c) != NULL && (Decimal)objCase.get(objManualMdt.Flag_On_Case__c) > 0)
                        objCase.OwnerId = mapOfQueueNameVsQueueId.get(objManualMdt.Queue_Name__c);
               }
        }     
        return objCase;
    }
    
   //update the priority and notification flags on case
    public Case updateCaseDetails(Collection_Rule_Engine__mdt objCollectionMdt, Case eachCase){
        system.debug('objCollectionMdt=========='+objCollectionMdt);
        system.debug('eachCase=========='+eachCase);
        eachCase.LP_Status_Priority_Order__c = objCollectionMdt.LP_Priority__c!=NULL?Integer.ValueOf(objCollectionMdt.LP_Priority__c):null;
        eachCase.LP_IVR_Call__c = objCollectionMdt.LP_IVR_Call__c;
        eachCase.LP_Manual_Call__c = objCollectionMdt.LP_Manual_Call__c;
        eachCase.LP_SMS__c = objCollectionMdt.LP_SMS__c;
        eachCase.LP_Email__c = objCollectionMdt.LP_Email__c;
        eachCase.LP_APP_Notification__c = objCollectionMdt.LP_App_Notification__c;
        eachCase.LP_Communication_Type__c = objCollectionMdt.LP_Communication_Type__c;
        eachCase.LP_Communication_sub_type__c = objCollectionMdt.LP_Communication_Sub_Type__c;
        eachCase.LP_Email_Template_Name__c = objCollectionMdt.LP_Email_Template_Name__c;
        eachCase.LP_App_Template__c = objCollectionMdt.App_Template_Name__c;
        eachCase.LP_Custom_Type__c = objCollectionMdt.LP_Custom_Type__c;
        eachCase.LP_Action__c = objCollectionMdt.LP_Action__c;
        //eachCase.Agency__c = objCollectionMdt.Agency__c;
        String dateStr = Date.today().format();
        eachCase.Collection_Rule_Time__c = dateStr;
        //eachCase.status = 'Pending';
        if(String.isNotBlank(objCollectionMdt.LP_SMSContent__c)){           
           System.debug('objCollectionMdt.LP_SMSContent__c :: ' + objCollectionMdt.LP_SMSContent__c);
           if(mapOfSMSNameVsId.get(objCollectionMdt.LP_SMSContent__c) != null){
              System.debug('Template ID :' + mapOfSMSNameVsId.get(objCollectionMdt.LP_SMSContent__c)); 
             eachCase.LP_SMS_Content__c = getSMSContent(mapOfSMSNameVsId.get(objCollectionMdt.LP_SMSContent__c),eachCase.ContactId,eachCase.Id);   
           }               
        }           
        eachCase = updateOwnerOnCase(eachCase);
        return eachCase;
        
    }
    
    private string getSMSContent(string templateId,string whoId,string whatId){
        System.debug('template Id : ' + templateId );
        Messaging.SingleEmailMessage objSM = Messaging.renderStoredEmailTemplate(templateId,whoId,whatId);
        System.debug('objSM======='+objSM.getPlainTextBody());
        return objSM.getPlainTextBody();
    }
    public void getCollectionRuleEngineMetaData(){
        //collect the data from custom metadata
        
       for(Collection_Rule_Engine__mdt eachMdt : [SELECT   LP_App_Notification__c,
                                                           LP_Communication_Sub_Type__c,
                                                           LP_Communication_Type__c,
                                                           LP_Customer_Score__c,
                                                          // LP_DPD__c,LP_Email__c, pooja
                                                           App_Template_Name__c,
                                                           LP_Custom_Type__c,
                                                           LP_Action__c,
                                                           LP_IVR_Call__c,LP_Manual_Call__c,
                                                           LP_Outstanding_Amount__c,
                                                           LP_Priority__c,
                                                           LP_Email_Template_Name__c,
                                                           LP_SMS__c,
                                                           LP_SMSContent__c,
                                                           LP_CL_Status__c
                                                  FROM Collection_Rule_Engine__mdt]){
                                                      // Cutomer Score > outstanding amount >> DPD
                                                      if(eachMdt.LP_Customer_Score__c != NULL && mapOfCustScoreVsData!=NULL && !mapOfCustScoreVsData.containsKey(eachMdt.LP_Customer_Score__c)){
                                                          mapOfCustScoreVsData.put(eachMdt.LP_Customer_Score__c,new map<string,map<string,map<String,Collection_Rule_Engine__mdt>>>());
                                                      }  
                                                      if(!mapOfCustScoreVsData.get(eachMdt.LP_Customer_Score__c).containsKey(eachMdt.LP_Outstanding_Amount__c)){
                                                          mapOfCustScoreVsData.get(eachMdt.LP_Customer_Score__c).put(eachMdt.LP_Outstanding_Amount__c,new map<string,map<String,Collection_Rule_Engine__mdt>>());
                                                      }
                                         
                                                      /*if(!mapOfCustScoreVsData.get(eachMdt.LP_Customer_Score__c).get(eachMdt.LP_Outstanding_Amount__c).containsKey(eachMdt.LP_DPD__c)){
                                                          mapOfCustScoreVsData.get(eachMdt.LP_Customer_Score__c).get(eachMdt.LP_Outstanding_Amount__c).put(eachMdt.LP_DPD__c,new map<String,Collection_Rule_Engine__mdt>());
                                                      }
                                                      if(!mapOfCustScoreVsData.get(eachMdt.LP_Customer_Score__c).get(eachMdt.LP_Outstanding_Amount__c).get(eachMdt.LP_DPD__c).containsKey(eachMdt.LP_CL_Status__c)){
                                                          mapOfCustScoreVsData.get(eachMdt.LP_Customer_Score__c).get(eachMdt.LP_Outstanding_Amount__c).get(eachMdt.LP_DPD__c).put(eachMdt.LP_CL_Status__c,eachMdt);
                                                      }*/
       }
    }
    
    //check that in which metadata record case value lies and return the key value of map
    public string getKeyVal(decimal caseVal,string metadataVal){
        if(String.isNotBlank(metadataVal) && caseVal != NULL){
            system.debug('caseVal====='+caseVal);
            if(metadataVal.contains('>=') && caseVal >= decimal.valueOf(metadataVal.substringAfter('>='))){
                System.debug('1 key ----' + metadataVal);
                return metadataVal;
            }
            else if(metadataVal.contains('<=') && caseVal <= decimal.valueOf(metadataVal.substringAfter('<='))){
                System.debug('1 key ----' + metadataVal);
                return metadataVal;
            }
            else if(metadataVal.contains('>') && !metadataVal.substringAfter('>').contains('=') && caseVal > decimal.valueOf(metadataVal.substringAfter('>'))){
                System.debug('2 key ----' + metadataVal);
                return metadataVal;
            }
            else if(metadataVal.contains('<') && !metadataVal.substringAfter('<').contains('=') && caseVal < decimal.valueOf(metadataVal.substringAfter('<'))){
                System.debug('3 key ----' + metadataVal);
                return metadataVal;
            }
            else if(metadataVal.contains('-') && decimal.valueOf(metadataVal.substringBefore('-')) < caseVal && caseVal < decimal.valueOf(metadataVal.substringAfter('-'))){
                System.debug('4 key ----' + metadataVal);
                return metadataVal;
            }
            else if(!metadataVal.contains('>') && !metadataVal.contains('-') && 
                    !metadataVal.contains('>=') && !metadataVal.contains('<') && 
                    !metadataVal.contains('<=') && caseVal == decimal.valueOf(metadataVal)){
                    System.debug('5 key ----' + metadataVal);
                    return metadataVal;
            }
        }
        return '';
    }
    
    //get the batch and queue name according to process name from custom metadata
    public void getQueueAndBatchName(){
        for(CollectionProcessMapping__mdt eachMdt : [SELECT label,
                                                             Batch_Class_Name__c,
                                                             Queue_Name__c,
                                                             Flag_On_Case__c,
                                                             DeveloperName
                                                     FROM CollectionProcessMapping__mdt]){
                                                         setOfQueueName.add(eachMdt.Queue_Name__c);
                                                         mapOfProcessNameVsBatchProcessMdt.put(eachMdt.label,eachMdt);
                                                     }
    }
    
   
}