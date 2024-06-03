public class LeadAssignmentBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.stateful{
    
    
    public String batchSettingName = '';
    public Batch_Setting__mdt batchSetting;
    
    public LeadAssignmentBatch(string batchName){
        this.batchSettingName = batchName;
        batchSetting = [SELECT MasterLabel, Where_Clause__c,Record_Limit__c,Iteration_Count__c,Re_Run_Apex_Job__c, 
                        Fields_To_Query__c,Verification_Hours__c,Group_Developer_Name__c,Partner_UUID__c,Active__c
                        FROM Batch_Setting__mdt WHERE MasterLabel =:this.batchSettingName LIMIT 1];
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        string queryResult = 'SELECT '+batchSetting.Fields_To_Query__c+' FROM Lead WHERE IsConverted=FALSE AND Bank_Verification_Status__c !=\'Success\' AND BatchAssignment__c= FALSE ';
        queryResult += String.isNotBlank(batchSetting.Partner_UUID__c)?' AND Partner_ID__c=\''+batchSetting.Partner_UUID__c+'\'':'';
        queryResult += String.isNotBlank(batchSetting.Where_Clause__c) ? ' AND '+ batchSetting.Where_Clause__c : '';
        queryResult += ' ORDER BY LastModifiedDate DESC';
        queryResult += batchSetting.Record_Limit__c != null ? ' LIMIT '+batchSetting.Record_Limit__c : '';
        return Database.getQueryLocator(queryResult);
                                       
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> scope){
        If(!scope.isEmpty() && scope.size()>0){
            List<Lead> leadsToUpdate = new List<Lead>();
            DateTime maxConversionTime = Datetime.now().addHours(-Integer.ValueOf(batchSetting.Verification_Hours__c));
            Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));
            Group grp = [SELECT Id, Name, Type, (SELECT Id, UserOrGroupId, GroupId FROM GroupMembers) FROM Group 
                         WHERE DeveloperName =:batchSetting.Group_Developer_Name__c AND Type =: 'Queue' LIMIT 1];
            
            if(grp != null && grp.GroupMembers != null && !grp.GroupMembers.isEmpty()){
                for(Lead lead : scope){
                    If(lead.Owner_Queue_name__c !='PayU_SMB_Outsource_Team'){
                        Integer userIndex = Math.mod(IntrandomNumber, grp.GroupMembers.Size());                    
                        if(lead.CreatedDate < maxConversionTime){                        
                            lead.Previous_QueueId_OwnerId__c = lead.ownerId;
                            lead.Current_QueueId_OwnerId__c = grp.GroupMembers.get(userIndex).UserOrGroupId;
                            lead.ownerId = grp.GroupMembers.get(userIndex).UserOrGroupId;
                            lead.BatchAssignment__c = true;
                            leadsToUpdate.add(lead);   
                        }                    
                        IntrandomNumber += 1;
                    }
                }
            }
            if(!leadsToUpdate.isEmpty() && leadsToUpdate.Size()>0) update leadsToUpdate;            
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}