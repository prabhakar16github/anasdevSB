public class MerchantDocTriggerHandler{
    public static void beforeInsertHandler(List<Merchant_Document__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Merchant_Document__c');  
        system.debug('enableUUIDObj=='+enableUUIDObj.Enable__c);
        
        Set<String> oppIds = New Set<String>();
        
        for(Merchant_Document__c each : triggerNew){                             
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);
            updateUrlUpdateCount(each, null);
            
            system.debug('url count ==='+each.UrlUpdateCount__c);
            
            if(String.isBlank(each.Account__c) && String.isNotBlank(each.Opportunity__c)) {
                oppIds.add(each.Opportunity__c);
            }
        }
        if(!oppIds.isEmpty()) updateAccountOnMDoc(triggerNew,oppIds);
         //=============Commenting the code due to onboarding Revamp========
        //checkMerchantDocument(triggerNew);
    }
    
    public static void beforeUpdateHandler(List<Merchant_Document__c> triggerNew, Map<Id, Merchant_Document__c> triggerOldMap){
        for(Merchant_Document__c each : TriggerNew){
            Merchant_Document__c oldEach = triggerOldMap.get(each.Id);
            updateUrlUpdateCount(each, oldEach);
        }
    }
    
    public static void beforeDeleteHandler(List<Merchant_Document__c> triggerOld){
        for(Merchant_Document__c each : TriggerOld){
            updateUrlUpdateCount(null, each);
        }
    }
    
    public static void afterUpdateHandler(List<Merchant_Document__c> triggerNew, Map<Id, Merchant_Document__c> triggerOldMap){
        Map<String,String> OppVsStatusMap = New Map<String,String>();
        Set<Id> oppIdSet = New Set<Id>();
        List<Merchant_Document__c> caseAttachments = new List<Merchant_Document__c>();
        List<String> merchantDocId = new List<String>();
        for(Merchant_Document__c each : TriggerNew){
            Merchant_Document__c oldeach = triggerOldMap.get(each.id);
            if((String.isNotBlank(each.URL__c) && (each.KYC_Documentable_Type__c == 'WebsiteDetail'
                                                   || each.KYC_Documentable_Type__c == 'Account'
                                                   || String.isBlank(each.KYC_Documentable_Type__c)
                                                   || each.KYC_Documentable_Type__c == 'Merchant'
                                                   || each.KYC_Documentable_Type__c == 'ProductAccount'
                                                   || each.KYC_Documentable_Type__c == 'BusinessOwner'))
               && each.Active__c){
                   if(!System.isBatch() && each.Data_need_to_be_publish__c){
                       IntegrationUtility.checkMaintenance(each, triggerOldMap.get(each.Id), 'Merchant_Document__c', 'Merchant_Document__c'); 
                   }
               }
            
            if(String.isNotBlank(each.Opportunity__c) && string.isNotBlank(each.KYC_Documentable_Type__c) 
               && each.KYC_Documentable_Type__c == 'Merchant' && (each.Onboarding_Status__c != triggerOldMap.get(each.Id).Onboarding_Status__c
                                                               || each.Active__c != triggerOldMap.get(each.Id).Active__c
                                                               || each.URL__c != triggerOldMap.get(each.Id).URL__c)){
                oppIdSet.add(each.Opportunity__c);
            }
            
            if(String.isNotBlank(each.Opportunity__c) && String.isNotBlank(each.Document_Category__c) && each.Is_Bank_Document__c && each.Onboarding_Status__c != triggerOldMap.get(each.Id).Onboarding_Status__c){
                OppVsStatusMap.put(each.Opportunity__c,each.Onboarding_Status__c);
            }
            /*if(each.KYC_Documentable_Type__c == 'Case' && each.isContentVersionupdated__c
              && each.isContentVersionupdated__c != oldeach.isContentVersionupdated__c){
                merchantDocId.add(each.id);
            }*/
            
        }
        if(!oppIdSet.isEmpty() && !system.isBatch()) updateEntMerchantData(oppIdSet);
        system.debug('@@@@@@@@@@@@@ OppVsStatusMap '+OppVsStatusMap);
        if(!OppVsStatusMap.isEmpty() && !system.isBatch()) updateBankAccountDetails(OppVsStatusMap);
    }
    
    public static void afterDeleteHandler(List<Merchant_Document__c> triggerOld){
        system.debug('-->> after delete merchant Doc');
        for(Merchant_Document__c each : triggerOld){
            if(each.Active__c && each.Data_need_to_be_publish__c)
                IntegrationUtility.checkMaintenance(each, null, 'Merchant_Document__c', 'Merchant_Document__c'); 
        }
    }
    
    public static void updateUrlUpdateCount(Merchant_Document__c newDoc, Merchant_Document__c oldDoc){
        
        If(Trigger.isInsert){
            newDoc.UrlUpdateCount__c = 1;
        }
        else if(Trigger.isUpdate){
            If(String.isBlank(oldDoc.URL__c) && String.isNotBlank(newDoc.URL__c) && newDoc.KYC_Documentable_Type__c != 'WebsiteDetail'){
                newDoc.UrlUpdateCount__c = 1;
            }
            else if(newDoc.UrlUpdateCount__c != null && newDoc.UrlUpdateCount__c >= 1){
                newDoc.UrlUpdateCount__c = newDoc.UrlUpdateCount__c + 1;
            }
        }
        
    }
    
    public static void afterInsertHandler(List<Merchant_Document__c> triggerNew){
        Set<Id> oppIdSet = New Set<Id>();
        Set<Id> bankDocOppIds = New Set<Id>();
        
        List<String> merchnatDocId = new List<String>();
        
        for(Merchant_Document__c each : triggerNew){
            if(each.KYC_Documentable_Type__c=='WebsiteDetail' && each.Onboarding_Status__c=='Declined'){
                if(!System.isBatch() && each.Data_need_to_be_publish__c){
                    IntegrationUtility.checkMaintenance(each, null, 'Merchant_Document__c', 'Merchant_Document__c'); 
                }
            }
            if(String.isNotBlank(each.Opportunity__c) && string.isNotBlank(each.KYC_Documentable_Type__c) && each.KYC_Documentable_Type__c=='Merchant'){
                oppIdSet.add(each.Opportunity__c);
            }
            if(String.isNotBlank(each.Opportunity__c) && string.isNotBlank(each.KYC_Documentable_Type__c) && each.KYC_Documentable_Type__c=='Merchant' && String.isNotBlank(each.Document_Category__c) && each.Is_Bank_Document__c){
                bankDocOppIds.add(each.Opportunity__c);
            }
            if(String.isNotBlank(each.KYC_Documentable_Type__c) &&  each.KYC_Documentable_Type__c == 'OneCare'){
                merchnatDocId.add(each.Id);
            }
        }
        if(!oppIdSet.isEmpty() && !system.isBatch()) updateEntMerchantData(oppIdSet);
        
        if(!bankDocOppIds.isEmpty() && system.isBatch()) createTaskForOnboarding(bankDocOppIds);
        
        //if(merchnatDocId != null && merchnatDocId.size() > 0) insertFeedItem(merchnatDocId);
    }
    
    /*public static void updateDocStatusOnAccount(List<Merchant_Document__c> listOfDocs, Integer pendingDoc, Integer recievedDoc, Integer approvedDoc, Integer declinedDoc){
List<Id> idList = new List<Id>();
Integer pendingDocs = 0;
Integer recievedDocs = 0;
Integer approvedDocs = 0;
Integer declinedDocs = 0;
List<Account> accList = new List<Account>();
for(Merchant_Document__c merDoc : listOfDocs){
if(merDoc.KYC_Documentable_Type__c != 'WebsiteDetail'){
idList.add(merDoc.Account__c);   
}
}
if(idList != null && !idList.isEmpty()){
for(Account account : [SELECT Id, Name, Document_Status__c, (SELECT Id, Name, Onboarding_Status__c, URL__c FROM Merchant_Documents__r WHERE Active__c = true AND (KYC_Documentable_Type__c = 'Account' OR KYC_Documentable_Type__c = 'Merchant')) 
FROM Account WHERE Id IN :idList]){
if(account.Merchant_Documents__r != null && !account.Merchant_Documents__r.isEmpty()){
for(Merchant_Document__c merDoc : account.Merchant_Documents__r){
system.debug('-->> Onboarding_Status__c '+merDoc.Onboarding_Status__c);
if(merDoc.Onboarding_Status__c == 'Pending' && (merDoc.URL__c == null || String.isBlank(merDoc.URL__c))){ pendingDocs++; }
if(merDoc.Onboarding_Status__c == 'Received' && (merDoc.URL__c != null || !String.isBlank(merDoc.URL__c))){ recievedDocs++; }
if(merDoc.Onboarding_Status__c == 'Approved'){ approvedDocs++; }
if(merDoc.Onboarding_Status__c == 'Declined'){ declinedDocs++; }
}
}
pendingDocs = pendingDocs-pendingDoc;
recievedDocs = recievedDocs-recievedDocs;
approvedDocs = approvedDocs-approvedDoc;
declinedDocs = declinedDocs-declinedDoc;
if(declinedDocs > 0)    account.Document_Status__c = 'Docs Error';
else if(pendingDocs > 0)    account.Document_Status__c = 'Pending';
//else if(recievedDocs == account.Merchant_Documents__r.size() && recievedDocs == account.No_of_Docs_Needed__c && recievedDocs > 0 )    account.Document_Status__c = 'Docs Received';
//else if(approvedDocs == account.Merchant_Documents__r.size() && approvedDocs == account.No_of_Docs_Needed__c && approvedDocs > 0) account.Document_Status__c = 'Docs Approved';
else if(recievedDocs == account.Merchant_Documents__r.size() && recievedDocs > 0 )  account.Document_Status__c = 'Docs Received';
else if(approvedDocs == account.Merchant_Documents__r.size() && approvedDocs > 0)   account.Document_Status__c = 'Docs Approved';
else account.Document_Status__c = 'Pending';
accList.add(account);
}
if(accList != null && !accList.isEmpty()){
try{
update accList;
}catch(Exception exc){
system.debug('-->> Exception occured '+exc.getLineNumber()+' '+exc.getMessage());
}
}
}
}*/
    /* Created By : Akash Pandey
* Created Date : 20 Dec 2019
* Description : This method will check the duplicate merchant document of perticuller Account and delete those
* document based on doc category and doc type.  
*/
    //=============Commenting the code due to onboarding Revamp========
    /*public static void checkMerchantDocument(List<Merchant_Document__c> triggerNew){
        Set<Id> accountIdSet = new Set<Id>();
        Map<String,Merchant_Document__c> docCategoryVsMerchantDocMap = New Map<String,Merchant_Document__c>();
        Map<String,Merchant_Document__c> docTypeVsMerchantDocMap = New Map<String,Merchant_Document__c>();
        List<Merchant_Document__c> listOfMdocToDelete = new List<Merchant_Document__c>();
        List<Merchant_Document__c> listOfMdocToUpdate = new List<Merchant_Document__c>();
        Map<Id,Merchant_Document__c> oldMerchantDocMap;
        Set<String> indentifierSet = New Set<String>();
        
        for(Merchant_Document__c eachMDoc: triggerNew){
            if(String.isNotBlank(eachMDoc.Account__c)){
                accountIdSet.add(eachMDoc.Account__c);
            }
            if(eachMDoc.Document_Category__c != null){
                docCategoryVsMerchantDocMap.put(eachMDoc.Document_Category__c,eachMDoc);
            }
            if(String.isNotBlank(eachMDoc.Identifier__c)){
                indentifierSet.add(eachMDoc.Identifier__c);
            }
        }
        
        if(!accountIdSet.isEmpty() && !docCategoryVsMerchantDocMap.isEmpty() && indentifierSet.size()>0){
            oldMerchantDocMap = new Map<Id,Merchant_Document__c>([SELECT Id, Account__c , Document_Category__c,
                                                                  Identifier__c,	
                                                                  Document_Type__c,URL__c ,Active__c,KYC_Documentable_Type__c
                                                                  FROM Merchant_Document__c WHERE Account__c IN:accountIdSet 
                                                                  AND Document_Category__c IN : docCategoryVsMerchantDocMap.keySet()
                                                                  AND KYC_Documentable_Type__c IN('Account','WebsiteDetail','',null,'Merchant')
                                                                  AND Identifier__c NOT IN: indentifierSet AND Active__c = True
                                                                  AND onboarding_Status__c IN('Pending','Received','Declined','Reuploaded')
                                                                 ]);
            if(!oldMerchantDocMap.isEmpty()){
                for(Merchant_Document__c oldMDoc: oldMerchantDocMap.values()){
                    if(!docCategoryVsMerchantDocMap.isEmpty()){
                        if(docCategoryVsMerchantDocMap.containsKey(oldMDoc.Document_Category__c)
                           && oldMDoc.Document_Category__c == docCategoryVsMerchantDocMap.get(oldMDoc.Document_Category__c).Document_Category__c){
                               if(string.isBlank(oldMDoc.URL__c) 
                                  && oldMDoc.Identifier__c <> docCategoryVsMerchantDocMap.get(oldMDoc.Document_Category__c).Identifier__c) {
                                      listOfMdocToDelete.add(oldMDoc);
                                  }else if(string.isNotBlank(oldMDoc.URL__c) 
                                           && oldMDoc.Identifier__c <> docCategoryVsMerchantDocMap.get(oldMDoc.Document_Category__c).Identifier__c
                                          && String.isNotBlank(docCategoryVsMerchantDocMap.get(oldMDoc.Document_Category__c).URL__c)) {
                                               oldMDoc.Active__c =False;
                                               listOfMdocToUpdate.add(oldMDoc);
                                          }                                                         
                           }
                    }
                }
            }
        }
        
        if(listOfMdocToDelete.size() > 0){
            //delete listOfMdocToDelete;            
            //Database.emptyRecycleBin(listOfMdocToDelete);
        }
        if(listOfMdocToUpdate.size()>0) update listOfMdocToUpdate;
    }
    */
    //================================Method for enterprise documents===============================
        
    public static void updateEntMerchantData(Set<Id> oppIds){
        Map<Id,Opportunity> entMerchantDataMap = New Map<Id,Opportunity>([Select Id,Total_Merchant_Documents__c,
                                                                          Total_Required_Merchant_Documents__c,Document_Status_Document_Issue__c,
                                                                          (Select Id,Onboarding_Status__c,URL__c from Merchant_Documents__r 
                                                                                     Where KYC_Documentable_Type__c='Merchant') from Opportunity 
                                                                          WHERE Id IN: oppIds 
                             AND Merchant_Business_Type__c='Enterprise']);
        Integer totalReceivedDocs = 0;
        Integer totalDeclinedDocs = 0;
        Integer totalApprovedDocs = 0;
        if(!entMerchantDataMap.isEmpty()){
        for(Opportunity eachOpp : entMerchantDataMap.values()){
            eachOpp.Total_Merchant_Documents__c = (entMerchantDataMap.get(eachOpp.Id).Merchant_Documents__r != null && entMerchantDataMap.get(eachOpp.Id).Merchant_Documents__r.Size()>0) ? entMerchantDataMap.get(eachOpp.Id).Merchant_Documents__r.size():0;
            if(eachOpp.Total_Merchant_Documents__c < eachOpp.Total_Required_Merchant_Documents__c){
                eachOpp.Document_Status_Document_Issue__c = 'Pending';
            }else if(eachOpp.Total_Merchant_Documents__c >= eachOpp.Total_Required_Merchant_Documents__c){
                if(entMerchantDataMap.get(eachOpp.Id).Merchant_Documents__r.size()>0){
                    for(Merchant_Document__c eachDoc : entMerchantDataMap.get(eachOpp.Id).Merchant_Documents__r){
                        if(String.isNotBlank(eachDoc.Onboarding_Status__c) && (eachDoc.Onboarding_Status__c=='Pending' || eachDoc.Onboarding_Status__c=='Received')
                          && String.isNotBlank(eachDoc.URL__c)){
                            totalReceivedDocs ++;
                        }
                        if(String.isNotBlank(eachDoc.Onboarding_Status__c) && (eachDoc.Onboarding_Status__c=='Declined')
                          && String.isNotBlank(eachDoc.URL__c)){
                            totalDeclinedDocs ++;
                        }
                        if(String.isNotBlank(eachDoc.Onboarding_Status__c) && (eachDoc.Onboarding_Status__c=='Approved')
                          && String.isNotBlank(eachDoc.URL__c)){
                            totalApprovedDocs ++;
                        }
                    }
                }
                if(totalDeclinedDocs > 0){
                    eachOpp.Document_Status_Document_Issue__c = 'Docs Error';
                }else if(totalApprovedDocs > 0 && totalApprovedDocs >= eachOpp.Total_Required_Merchant_Documents__c){
                    eachOpp.Document_Status_Document_Issue__c = 'Docs Approved';
                }else if(totalReceivedDocs >0 && totalReceivedDocs >= eachOpp.Total_Required_Merchant_Documents__c){
                    eachOpp.Document_Status_Document_Issue__c = 'Docs Received';
                }else if(totalReceivedDocs >0 && totalApprovedDocs>0 && ((totalReceivedDocs+totalApprovedDocs) >= eachOpp.Total_Required_Merchant_Documents__c)){
                    eachOpp.Document_Status_Document_Issue__c = 'Docs Received';
                }else if(totalReceivedDocs < eachOpp.Total_Required_Merchant_Documents__c && totalApprovedDocs < eachOpp.Total_Required_Merchant_Documents__c
                        && (totalReceivedDocs+totalApprovedDocs) < eachOpp.Total_Required_Merchant_Documents__c){
                    eachOpp.Document_Status_Document_Issue__c = 'Pending';
                }
            }            
        }
    }
        if(!entMerchantDataMap.isEmpty() && entMerchantDataMap.values().size() > 0) update entMerchantDataMap.values();
    }
    //================================end Method for enterprise documents===============================
    
    //====================Update Account Id on missing Account Id ========================
    public static void updateAccountOnMDoc(List<Merchant_Document__c> triggerNew, Set<String> oppIds){
        Map<Id,Opportunity> oppMap = New Map<Id,Opportunity>();
        
        for(Opportunity eachOpp : [Select Id,AccountId from Opportunity Where Id IN: oppIds]){
            oppMap.put(eachOpp.Id,eachOpp);
        }
        
        for(Merchant_Document__c each : triggerNew){
            if(string.isBlank(each.Account__c) && !oppMap.isEmpty() && oppMap.containsKey(each.Opportunity__c) && oppMap.get(each.Opportunity__c).AccountId != null){
                each.Account__c = oppMap.get(each.Opportunity__c).AccountId;
            }
        }
    }
    //================================end Update Account Id on missing Account Id===============================
    
    /*public static void updateDocStatusFromMerchantDoc(List<Merchant_Document__c> triggerNew, Map<Id,Merchant_Document__c> triggerOldMap){
Set<Id> oppIds = New Set<Id>();
Set<Id> accountIds = New Set<Id>();
List<Opportunity> opportunities = New List<Opportunity>();
List<Account> accounts = New List<Account>();
for(Merchant_Document__c md : triggerNew){
if(String.IsNotBlank(md.Account__c)) accountIds.add(md.Account__c);
if(String.IsNotBlank(md.Opportunity__c)) oppIds.add(md.Opportunity__c);
}
if(!accountIds.isEmpty()){
for(Merchant_Document__c md : [Select id,Onboarding_Status__c,Account__r.Document_Status__c,Active__c from Merchant_Document__c where Account__c IN: accountIds]){
Account a = New Account();
system.debug('######new MD '+md.Account__r.Document_Status__c+'@@@ '+md.Onboarding_Status__c);
if(md.Active__c && md.Onboarding_Status__c =='Declined' && md.Account__r.Document_Status__c != 'Docs Error'
&& String.isNotBlank(md.Account__r.Document_Status__c)){
a.id = md.Account__c;
a.Document_Status__c = 'Docs Error';
accounts.add(a);
}
else if(md.Active__c && md.Onboarding_Status__c =='Received' && md.Account__r.Document_Status__c != 'Docs Received' 
&& String.isNotBlank(md.Account__r.Document_Status__c)){
a.id = md.Account__c;
a.Document_Status__c = 'Docs Received';
accounts.add(a);
}
else if(md.Active__c && md.Onboarding_Status__c =='Approved' && md.Account__r.Document_Status__c != 'Docs Approved' 
&& String.isNotBlank(md.Account__r.Document_Status__c)){
a.id = md.Account__c;
a.Document_Status__c = 'Docs Approved';
accounts.add(a);
}

}
}
system.debug('@@@@ accounts '+accounts);
if(!accounts.isEmpty() && accounts.size()>0){
try{
update accounts;
}catch(exception e){
system.debug('###### catch '+e);
}
} 
}*/
    public static void updateBankAccountDetails(Map<String,String> OppVsStatusMap){
        List<Bank_Account_Detail__c> bankAccountToBeUpdate = New List<Bank_Account_Detail__c>();
        for(Bank_Account_Detail__c bankObj : [Select Id,Verification_Status__c,Opportunity__c from Bank_Account_Detail__c Where Opportunity__c IN : OppVsStatusMap.keySet() AND Active__c = True]){
            if(OppVsStatusMap.containsKey(bankObj.Opportunity__c) && OppVsStatusMap.get(bankObj.Opportunity__c) != null){
                if(OppVsStatusMap.get(bankObj.Opportunity__c) == 'Approved'){
                    bankObj.Verification_Status__c = 'Success';
                    bankAccountToBeUpdate.add(bankObj);
                }else if(OppVsStatusMap.get(bankObj.Opportunity__c) == 'Declined'){
                    bankObj.Verification_Status__c = 'Failed';
                    bankAccountToBeUpdate.add(bankObj);
                }
            }
        }
        if(!bankAccountToBeUpdate.isEmpty() && bankAccountToBeUpdate.size() > 0) update bankAccountToBeUpdate;
    }
    
    public static void createTaskForOnboarding(Set<Id> bankDocOppIds){
        List<String> queueDeveloperNames = New List<String>{'Document_Onboarding_Team'};
        Map<String,List<GroupMember>> queueDeveloperNameVsMembers = SystemUtility.getQueuesNameMembers(queueDeveloperNames);
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));
        List<Task> taskToBeCreate = New List<Task>();
        for(Bank_Account_Detail__c bankObj : [Select Id,Verification_Status__c,Opportunity__c from Bank_Account_Detail__c Where Opportunity__c IN : bankDocOppIds AND Active__c = True]){
            if(String.isBlank(bankObj.Verification_Status__c) || (String.isNotBlank(bankObj.Verification_Status__c) && bankObj.Verification_Status__c == 'Pending')){
                if(queueDeveloperNameVsMembers.containsKey('Document_Onboarding_Team') && queueDeveloperNameVsMembers.get('Document_Onboarding_Team') != null){
                    Integer userIndex = Math.mod(IntrandomNumber, queueDeveloperNameVsMembers.get('Document_Onboarding_Team').Size());
                    
                    SystemUtility.createTask(taskToBeCreate, System.today()+1, '', false, null, queueDeveloperNameVsMembers.get('Document_Onboarding_Team').get(userIndex).UserOrGroupId, 'High', null, 'Bank Account Verification', 'Not Started', bankObj.Opportunity__c); 
                }
            }
        }
        if(!taskToBeCreate.isEmpty() && taskToBeCreate.size() > 0) upsert taskToBeCreate;
    }
    
    /*@future(callout=true)
    public static void getUrlfromS3(List<String> merchantDocId){
        String strQuery = '';
        strQuery = 'SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Merchant_Document__c')), ',');
        strQuery += ' From Merchant_Document__c Where Id IN (\'' + String.join(merchantDocId, '\',\'') + '\')';
        
        List<Merchant_Document__c> caseAttachments = Database.query(strQuery);
        List<ContentVersion> contentVersionList = [select VersionData,merchant_Document__c from ContentVersion where merchant_document__c in :merchantDocId];
        Map<string,ContentVersion> merchantDocIdCntVersionMap = new Map<string,ContentVersion>();
        List<Merchant_Document__c> MdList = new List<Merchant_Document__c>();
        
        if(contentVersionList.size() >0 && contentVersionList != null){
            for(ContentVersion each : contentVersionList){
                merchantDocIdCntVersionMap.put(each.Merchant_Document__c ,each);
            }
            if(!merchantDocIdCntVersionMap.isEmpty()){
                for(Merchant_Document__c each : caseAttachments){
                    string strEndPoint = AWSUtility.uploadAndGetDocUrlS3Type(each, 'fb2c-ee02-9d7bf3f9-a0c3-7d19538a895a', merchantDocIdCntVersionMap.get(each.Id).VersionData, 'onecare');
                    system.debug('strEndPoint=='+strEndPoint);
                    each.URL__c = strEndPoint;
                    MdList.add(each);
                    system.debug('each=='+each.Id);
                }
            }  
        } 
        
        if(MdList.size() >0 && MdList != null){
            update MdList;
        }
    }*/
    
    @future
    public static void insertFeedItem(List<String> merchantDocId){
        
        system.debug('enter feedItem update');
        String strQuery = '';
        //added by rohit in below line:  AwsConsumerAPI_CTRL
        strQuery = 'SELECT ' + String.join(new List<String>(AwsConsumerAPI_CTRL.getFieldSet('Merchant_Document__c')), ',');
        strQuery += ' From Merchant_Document__c Where Id IN (\'' + String.join(merchantDocId, '\',\'') + '\')';
        
        List<Merchant_Document__c> merchantDocList = Database.query(strQuery);
        
        feedItem feedItemObj = new feedItem();
        feedItemObj.ParentId =  merchantDocList[0].Case__c;
        feedItemObj.LinkUrl = merchantDocList[0].Uploaded_Document__c;
        GuestUserUtilityHelper.upsertSObjectList(new List<feedItem>{feedItemObj});
        
        system.debug('feedItem==='+feedItemObj);
    }
    
}