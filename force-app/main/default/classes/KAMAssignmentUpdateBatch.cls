public class KAMAssignmentUpdateBatch implements Database.Batchable<sObject>, 
Database.AllowsCallouts, Database.stateful{
    
    public string batchSettingName = '';
    public Batch_Setting__mdt batchSetting = New Batch_Setting__mdt();
    public Map<String,List<User>> segmantwithKAMUserMap = New Map<String,List<User>>();
    public Boolean isPublisherExecute = false;
    public Boolean isUpdateExecute = false;
    public Boolean isStopRecurrsion = false;
    public Set<Id> oppIdsToPublish = New Set<Id>();
    
    public KAMAssignmentUpdateBatch(){}
    
    public KAMAssignmentUpdateBatch(string batchName,Boolean isPublisher, Boolean isUpdate, Set<Id> oppIds){
        
        for(User eachUser : [Select Id,KAM_Segment__c,Key_Assigned_Manager__c from User Where Key_Assigned_Manager__c = True AND KAM_Segment__c != null AND isActive=True]){
            If(!segmantwithKAMUserMap.containsKey(eachUser.KAM_Segment__c)){
                segmantwithKAMUserMap.put(eachUser.KAM_Segment__c,New List<User>{eachUser});
            }else{
                List<User> userList = segmantwithKAMUserMap.get(eachUser.KAM_Segment__c);
                userList.add(eachUser);
                segmantwithKAMUserMap.put(eachUser.KAM_Segment__c,userList);
            }
        }
        
        this.isPublisherExecute = isPublisher;
        this.isUpdateExecute = isUpdate;
        this.batchSettingName = batchName;
        this.oppIdsToPublish = oppIds;
        
        batchSetting = [SELECT MasterLabel, Where_Clause__c,Record_Limit__c,Iteration_Count__c,Fields_To_Query__c,Re_Run_Apex_Job__c 
                        FROM Batch_Setting__mdt WHERE MasterLabel =:this.batchSettingName LIMIT 1];
        
    }   
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        List<String> settlementStatusRestrictedLabels = System.label.Settlement_Status_Published.split(',');
        List<String> leadTypes = New List<String>{'Merchant','seller','Aggregator'};
            
            string queryResult = '';
        If(isPublisherExecute && !oppIdsToPublish.isEmpty()){
            queryResult = 'SELECT '+batchSetting.Fields_To_Query__c+' FROM Opportunity WHERE Settlement_Status__c NOT IN : settlementStatusRestrictedLabels AND gmv_latest_date__c != null AND Id IN: oppIdsToPublish';
            queryResult += String.isNotBlank(batchSetting.Where_Clause__c) ? ' AND '+ batchSetting.Where_Clause__c : '';
            
        }else{
            queryResult = 'SELECT '+batchSetting.Fields_To_Query__c+' FROM Opportunity WHERE Settlement_Status__c NOT IN : settlementStatusRestrictedLabels AND gmv_latest_date__c != null AND Lead_Type__c IN : leadTypes';
            queryResult += String.isNotBlank(batchSetting.Where_Clause__c) ? ' AND '+ batchSetting.Where_Clause__c : '';        
            queryResult += ' ORDER BY LastModifiedDate ASC';
            queryResult += batchSetting.Record_Limit__c != null ? ' LIMIT '+batchSetting.Record_Limit__c : '';
            
        }
        system.debug('####### '+settlementStatusRestrictedLabels);
        system.debug('####### leadTypes '+leadTypes);
        If(!Test.isRunningTest()) return Database.getQueryLocator(queryResult);
        else return Database.getQueryLocator('Select '+batchSetting.Fields_To_Query__c+' from Opportunity');
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> oppList){
        List<Opportunity> oppListToUpdate = New List<Opportunity>();
        Set<String> oppIds = new Set<String>();
        List<String> segmentNotPublish = New List<String>{'Silver-Biz','Silver-Money'};
            
            If(!oppList.isEmpty() && oppList.size() > 0){
                If(isUpdateExecute){
                    Integer userIndex = 0;
                    for(Opportunity eachOpp : oppList){
                        If(!segmantwithKAMUserMap.isEmpty() && segmantwithKAMUserMap.containsKey(eachOpp.KAM_Segment_By_GMV__c) && segmantwithKAMUserMap.get(eachOpp.KAM_Segment_By_GMV__c).Size() >0){
                            Map<Id,User> userMap = New Map<Id,User>(segmantwithKAMUserMap.get(eachOpp.KAM_Segment_By_GMV__c));
                            If(!userMap.containsKey(eachOpp.Key_Assigned_Manager__c)){
                                userIndex = getUserIdByRoundRobin(userIndex,segmantwithKAMUserMap.get(eachOpp.KAM_Segment_By_GMV__c));
                                eachOpp.Key_Assigned_Manager__c = segmantwithKAMUserMap.get(eachOpp.KAM_Segment_By_GMV__c).get(userIndex).Id;
                                eachOpp.Key_Assigned_Manager_Segment__c = eachOpp.KAM_Segment_By_GMV__c;
                                oppListToUpdate.add(eachOpp);
                                oppIdsToPublish.add(eachOpp.Id);
                            }
                        }else {
                            userIndex = 0;
                        }
                    } 
                }else If(isPublisherExecute){
                    oppIdsToPublish = New Set<Id>();
                    for(Opportunity eachOpp : oppList){
                        if(String.isNotBlank(eachOpp.Key_Assigned_Manager__c) && String.isNotBlank(eachOpp.Key_Assigned_Manager_Segment__c) && !segmentNotPublish.contains(eachOpp.Key_Assigned_Manager_Segment__c)) 
                            oppIds.add(eachOpp.Id);
                    }
                    If(!oppIds.isEmpty() && oppIds.size()>0){
                        for(Opportunity each : Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Opportunity')), ',') + ' FROM Opportunity WHERE Id IN (\'' + String.join(new List<String>(oppIds), '\',\'') + '\')')){                    
                            IntegrationUtility.oppConvertedSet.add(each.Id);
                            IntegrationUtility.isFutureUpdate = true;
                            IntegrationUtility.sendPayLoadData(each, null, 'Opportunity', 'Lead');                                        
                        }
                    }
                }
            }
        system.debug('@@@@@@ '+oppIdsToPublish);
        If(!oppListToUpdate.isEmpty()) Database.Update(oppListToUpdate,false);
    }
    
    public void finish(Database.BatchableContext BC){
        system.debug('@@@@@@ isStopRecurrsion '+isStopRecurrsion);
        system.debug('@@@@@@ isUpdateExecute '+isUpdateExecute);
        system.debug('@@@@@@ oppIdsToPublish.isEmpty() '+oppIdsToPublish.isEmpty());
        
        If(!isStopRecurrsion && isUpdateExecute && !oppIdsToPublish.isEmpty()){
            isStopRecurrsion = true;
            Database.executeBatch(New KAMAssignmentUpdateBatch(batchSettingName,true,false,oppIdsToPublish),5);
        }
        /*
if(!isUpdateExecute && isPublisherExecute){
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

// Use the
AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors,
a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById,
a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];

// below code will send an email to User about the status
String[] email = new String[]{'.com'};
mail.setToAddresses(email);
mail.setReplyTo('test@test.com'); // Add here your email address
mail.setSenderDisplayName('Apex Batch Processing Module');
mail.setSubject('Batch Processing '+a.Status);
mail.setPlainTextBody('The Batch Apex job processed '+ a.TotalJobItems+'batches with '+a.NumberOfErrors+'failures '+'Job Itemprocessed are '+a.JobItemsProcessed);
Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
}*/
    }
    
    public static Integer getUserIdByRoundRobin(Integer userIndex,List<User> userObjList){
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));
        return userIndex = Math.mod(IntrandomNumber, userObjList.size());
    }
    
}