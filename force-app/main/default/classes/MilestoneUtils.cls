public class MilestoneUtils {
    
    public static void sendEmailtoManager(List<Case> violatedCases, Map<Id,Id> userWithManagerIdMap, string templateName){
        if(violatedCases.size()>0 && String.isNotBlank(templateName)){
            //get Template Id
            Id templateId = [SELECT id FROM EmailTemplate where name=:templateName].id;
            string L3managerId;
            Id ETCFarmingRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ETC PayU Farming').getRecordTypeId();
            
            String orgWideEmailAdd = Label.Organization_Wide_Email_Address;
            Id orgWideEmailAddId = null;
            List<OrgWideEmailAddress> lstOrgWideEmailAddress = new List<OrgWideEmailAddress>();
            if(String.isNotBlank(orgWideEmailAdd)) lstOrgWideEmailAddress = [select Id from OrgWideEmailAddress where DisplayName =: orgWideEmailAdd];
            if(!lstOrgWideEmailAddress.isEmpty()) orgWideEmailAddId = lstOrgWideEmailAddress[0].Id;
            
            system.debug('eachCase.Owner.ManagerId========'+userWithManagerIdMap);           
            list<Messaging.SingleEmailMessage> lstEmails = new list<Messaging.SingleEmailMessage>();
            if(!userWithManagerIdMap.isEmpty()){
                for(Case eachCase : violatedCases){
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                    system.debug('eachCase.Owner.ManagerId========'+eachCase.OwnerId);
                    if(Test.isRunningTest()){
                        semail.setToAddresses(new Id[] {UserInfo.getUserId()});
                    }
                    if(string.isNotBlank(eachCase.ownerId) && string.valueOf(eachCase.ownerId).startsWith('005')){
                        if(userWithManagerIdMap.containsKey(eachCase.ownerId)){
                            if(Test.isRunningTest()){ 
                                System.debug('###### running test ');
                                semail.setToAddresses(new Id[] {UserInfo.getUserId()});
                            }else{
                                System.debug('###### not running test ');
                                string managerId = userWithManagerIdMap.get(eachCase.ownerId) !=null ? userWithManagerIdMap.get(eachCase.ownerId) : Label.Default_ManagerId_for_Violation;
                                if(userWithManagerIdMap.containsKey(managerId))
                                    L3managerId = (managerId != null && managerId != Label.Default_ManagerId_for_Violation) ? userWithManagerIdMap.get(managerId) : Label.Default_ManagerId_for_Violation; 
                                if(eachCase.Is_L2_Violated__c && !eachCase.Is_L3_Violated__c){
                                    if(eachCase.owner.Name !='Integration User' && managerId != Label.IntegrationUserId ) semail.setToAddresses(new Id[] {managerId});
                                }else if(eachCase.Is_L3_Violated__c && L3managerId != null){
                                    if(L3managerId != Label.IntegrationUserId && managerId != Label.IntegrationUserId ) semail.setToAddresses(new Id[] {L3managerId});
                                }
                                
                            }                            
                        }
                        semail.setTargetObjectId(eachCase.OwnerId);
                    }  
                    if(String.isNotBlank(OrgWideEmailAddId)) semail.setOrgWideEmailAddressId(OrgWideEmailAddId);
                    semail.setTemplateId(templateId);
                    semail.setSaveAsActivity(false);
                    semail.setWhatId(eachCase.Id);
                    if((eachCase.Is_L2_Violated__c || eachCase.Is_L3_Violated__c) 
                       && eachCase.RecordTypeId != ETCFarmingRecordTypeId && eachCase.LOB_Name__c != 'Waiting On PUM-Farming'
                       && eachCase.OwnerId != Label.IntegrationUserId)
                        lstEmails.add(semail);
                }
            }
            if(!lstEmails.isEmpty() && lstEmails.size() > 0 && lstEmails != null)
                Messaging.sendEmail(lstEmails);   
        }
    }
    
    public static void sendEmailtoOwner(List<Case> violatedCases, Map<Id,Id> userWithManagerIdMap, string templateName){
        if(violatedCases.size()>0 && String.isNotBlank(templateName)){
            //get Template Id
            Id templateId = [SELECT id FROM EmailTemplate where name=:templateName].id;
            Id ETCFarmingRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ETC PayU Farming').getRecordTypeId();
            system.debug('eachCase.Owner.ManagerId========'+userWithManagerIdMap);
            
            String orgWideEmailAdd = Label.Organization_Wide_Email_Address;
            Id orgWideEmailAddId = null;
            List<OrgWideEmailAddress> lstOrgWideEmailAddress = new List<OrgWideEmailAddress>();
            if(String.isNotBlank(orgWideEmailAdd)) lstOrgWideEmailAddress = [select Id from OrgWideEmailAddress where DisplayName =: orgWideEmailAdd];
            if(!lstOrgWideEmailAddress.isEmpty()) orgWideEmailAddId = lstOrgWideEmailAddress[0].Id;
            
            list<Messaging.SingleEmailMessage> lstEmails = new list<Messaging.SingleEmailMessage>();
            if(!userWithManagerIdMap.isEmpty()){
                for(Case eachCase : violatedCases){
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                    
                    system.debug('eachCase.Owner.ManagerId========'+eachCase.OwnerId);
                    if(string.isNotBlank(eachCase.ownerId) && string.valueOf(eachCase.ownerId).startsWith('005') 
                       && eachCase.OwnerId != Label.IntegrationUserId && !eachCase.Is_L2_Violated__c && !eachCase.Is_L3_Violated__c
                       && eachCase.RecordTypeId != ETCFarmingRecordTypeId && eachCase.LOB_Name__c != 'Waiting On PUM-Farming'){
                           semail.setToAddresses(new Id[] {eachCase.ownerId});
                           semail.setTargetObjectId(eachCase.OwnerId);
                           
                           if(String.isNotBlank(OrgWideEmailAddId)) semail.setOrgWideEmailAddressId(OrgWideEmailAddId);                      
                           semail.setTemplateId(templateId);
                           semail.setSaveAsActivity(false);
                           semail.setWhatId(eachCase.Id);
                           lstEmails.add(semail);
                       }
                }
            }
            if(!lstEmails.isEmpty() && lstEmails.size() > 0 && lstEmails != null)
                Messaging.sendEmail(lstEmails);           
        }
    }
    
    public static void completeMilestone(List<case> listCase,String milestoneName, DateTime complDate) {  
        List<CaseMilestone> cmsToUpdate = new  List<CaseMilestone>();
        List<String> strList = new List<String>{'Parent Case Owner Change','Parent Ticket Milestone','L2 merchant Care Milestone','L3 Merchant Care Milestone'};
            if(String.isNotBlank(milestoneName)){
                cmsToUpdate = [select Id, completionDate
                               from CaseMilestone cm
                               where caseId in :listCase and cm.MilestoneType.Name=:milestoneName 
                               and completionDate = null];
                
                if (cmsToUpdate.isEmpty() == false){
                    for (CaseMilestone cm : cmsToUpdate){
                        if(cm.completionDate==null)
                            cm.completionDate = complDate;
                    }
                    update cmsToUpdate;
                }
            }/*else{
cmsToUpdate = [select Id, MilestoneType.Name,completionDate from CaseMilestone cm
where caseId in :listCase and completionDate = null 
AND cm.MilestoneType.Name IN: strList AND cm.isViolated=false limit 1];
system.debug('@@@@@ milestone name '+cmsToUpdate);
if (cmsToUpdate.isEmpty() == false){
for (CaseMilestone cm : cmsToUpdate){
if(cm.completionDate==null)
cm.completionDate = complDate;
}
update cmsToUpdate;
}
}*/
        
    }
    
    public static void sendEmails(list<Case> lstCase,string templateName){
        if(lstCase != NULL && lstCase.size()>0 && String.isNotBlank(templateName)){
            //get Template Id
            Id templateId = [SELECT id FROM EmailTemplate where name=:templateName].id;
            
            String orgWideEmailAdd = Label.Organization_Wide_Email_Address;
            Id orgWideEmailAddId = null;
            List<OrgWideEmailAddress> lstOrgWideEmailAddress = new List<OrgWideEmailAddress>();
            if(String.isNotBlank(orgWideEmailAdd)) lstOrgWideEmailAddress = [select Id from OrgWideEmailAddress where DisplayName =: orgWideEmailAdd];
            if(!lstOrgWideEmailAddress.isEmpty()) orgWideEmailAddId = lstOrgWideEmailAddress[0].Id;
            
            list<Messaging.SingleEmailMessage> lstEmails = new list<Messaging.SingleEmailMessage>();
            for(Case eachCase : [SELECT id,ContactId,Parent_Case__r.OwnerId,ownerId,Parent_Case__r.owner.Email FROM Case WHERE ID IN:lstCase]){
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                system.debug('eachCase.Parent_Case__r.OwnerId========'+eachCase.Parent_Case__r.OwnerId);
                if(eachCase.Parent_Case__r.OwnerId != NULL && String.ValueOf(eachCase.Parent_Case__r.OwnerId).startsWith('005')
                   && eachCase.Owner.Name !='Integration User'){
                       semail.setToAddresses(new Id[] {eachCase.Parent_Case__r.OwnerId});
                       semail.setTargetObjectId(eachCase.Parent_Case__r.OwnerId);
                   }
                else
                    semail.setTargetObjectId(eachCase.OwnerId);
                semail.setTemplateId(templateId);
                semail.setSaveAsActivity(false);
                semail.setWhatId(eachCase.Id);
                if(String.isNotBlank(OrgWideEmailAddId)) semail.setOrgWideEmailAddressId(OrgWideEmailAddId);
                lstEmails.add(semail);
            }
            Messaging.sendEmail(lstEmails);
            
        }  
    }
    
}