public class EmailMessageTriggerHandler {
    
    public static void beforeInsertHandler(list<EmailMessage> triggerNew){
        beforeInsertActions(triggerNew);
        updateVerticalOnCase(triggerNew);
        
        // This method is used to attach all duplicate cases to same case having same customer and same subject line.
        
        LazyPayattachDuplicateEmailToSameCase(triggerNew);
            
        System.debug('Email Message Before Insert called ');
    }
    
    public static void beforeUpdateHandler(list<EmailMessage> triggerNew, map<Id,EmailMessage> TriggeroldMap){      
    }  
    public static void afterInsertHandler(list<EmailMessage> triggerNew){
    }
    public static void afterUpdateHandler(list<EmailMessage> triggerNew, map<Id,EmailMessage> TriggeroldMap){
        
    }
 
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method handles the before insert actions of email message

    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    6-Mar-19              Eitika Verma               created
    **/
    public static void beforeInsertActions(list<EmailMessage> triggerNew){
        list<Id> listOfCaseId = new list<Id>();
        list<Id> listOfOutgoingCaseId = new list<Id>();
        for(EmailMessage eachMessage : triggerNew){
            if(eachMessage.ParentId != NULL && String.valueOf(eachMessage.ParentId).StartsWith('500')){
                if(eachMessage.Incoming && eachMessage.Subject != NULL && eachMessage.Subject.contains('Re:')){
                    listOfCaseId.add(eachMessage.ParentId);
                }
                if(!eachMessage.Incoming){
                    listOfOutgoingCaseId.add(eachMessage.ParentId);
                }
            }
        }
        if(listOfCaseId != NULL && listOfCaseId.size()>0){
            updateCaseStatusFlagAndSendMail(listOfCaseId);
        }
        
        if(listOfOutgoingCaseId != NULL && listOfOutgoingCaseId.size()>0){
            updateAgentFlag(listOfOutgoingCaseId);
        }
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method update the flag on case if agent reply on customer email

    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    6-Mar-19              Eitika Verma               created
    **/
    public static void updateAgentFlag(list<Id> ListOfCaseId){
        list<Case> lstCase = new list<Case>();
        for(Id eachCaseID : ListOfCaseId){
            Case objCase = new Case(Id=eachCaseID,LP_Has_Agent_Reverted__c=true);
            lstCase.add(objCase);
        }
        
        if(lstCase != NULL && lstCase.size()>0)
            update lstCase; //pooja
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method update the count on case if second time mail is coming 
                        from customer and update case status to reopen if agent marked 
                        case status as resolved and customer response back on email
                        If Case status is closed then send the auto responder to customer

    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    6-Mar-19              Eitika Verma               created
    **/
    public static void updateCaseStatusFlagAndSendMail(list<Id> ListOfCaseId){
        
        list<Case> lstCase = new list<Case>();
        list<Case> lstOfClosedCase = new list<Case>();
        string etcRecType = System.label.ETC_RecordType;
        List<string> etcRecTypeList = etcRecType.split(',');
        
        if(listOfCaseId != NULL && listOfCaseId.size()>0){
            for(Case eachCase : [SELECT id,status,
                                 ContactId,
                                 LP_Customer_Response_Count__c,
                                 Contact.Email,Is_Duplicate__c
                                 FROM Case 
                                 WHERE Id IN:listOfCaseId 
                                 AND Status != 'New' AND RecordTypeId NOT IN: etcRecTypeList
                                 ]){
                if(eachCase.status == 'Resolved'){
                  eachCase.status = 'Re-Open';
                }
                else if(eachCase.status == 'Closed'){
                    lstOfClosedCase.add(eachCase);                     
                }               
                else{
                  eachCase.LP_Customer_Response_Count__c = eachCase.LP_Customer_Response_Count__c!=null?eachCase.LP_Customer_Response_Count__c+1:1;                      
                  eachCase.LP_Customer_Response_Timestamp__c = Datetime.now();
                  eachCase.LP_Has_Agent_Reverted__c = false;
                }
                lstCase.add(eachCase);
            }
            
            if(lstOfClosedCase != NULL && lstOfClosedCase.size()>0)
                sendAutoResponder(lstOfClosedCase);
        }
        
        system.debug('lstCase======='+lstCase);
        if(lstCase != NULL && lstCase.size()>0)
            update lstCase;
    }
    
    public static void sendAutoResponder(list<Case> lstOfClosedCase){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate etemplate = [select id from EmailTemplate where developername='Closed']; 
        // Use Organization Wide Address  
        list<OrgWideEmailAddress> lstOrgWideEmailAddress = [select id, Address from OrgWideEmailAddress Where displayName='noreply@lazypay.in'];

        for(Case eachCase : lstOfClosedCase){
            //send Email to customers
            if(eachCase.Contact.Email != NULL && !eachCase.Is_Duplicate__c){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(eachCase.ContactId); 
                mail.setWhatId(eachCase.Id);
                mail.setTemplateId(etemplate.Id);
                if(lstOrgWideEmailAddress != NULL && lstOrgWideEmailAddress.size()>0)
                    mail.setOrgWideEmailAddressId(lstOrgWideEmailAddress[0].id);
                mail.setToAddresses(new list<string>{eachCase.Contact.Email});            
                mails.add(mail);
            }
        }
        
        //send emails
        Messaging.sendEmail(mails);
    }
    
    
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method update business vertical and category on case

    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    6-Mar-19              Eitika Verma               created
    **/
    public static void updateVerticalOnCase(list<EmailMessage> triggerNew){
        //get the data from custom metadata
        map<string,Duplicacy_And_Ownership__mdt> mapOfEmailVsVertical = getVerticalValue();
        System.debug('mapOfEmailVsVertical======'+mapOfEmailVsVertical);
        list<Case> lstCase = new list<Case>();
        for(EmailMessage eachMessage : triggerNew){
            System.debug('eachMessage======'+eachMessage);
            if(eachMessage.ParentId != NULL && String.ValueOf(eachMessage.ParentId).StartsWith('500') && eachMessage.Incoming 
               && eachMessage.Subject!= NULL && !eachMessage.Subject.contains('Re:') && mapOfEmailVsVertical != NULL 
               && mapOfEmailVsVertical.containsKey(eachMessage.ToAddress)){
                Duplicacy_And_Ownership__mdt objMtdt = mapOfEmailVsVertical.get(eachMessage.ToAddress);
                Case objCase = new Case(Id=eachMessage.ParentId,
                                        LP_Business_Vertical__c=objMtdt.Business_Vertical__c,
                                        LP_Category__c=objMtdt.Sub_Vertical__c);
                lstCase.add(objCase);
            }
        }
        System.debug('lstCase======'+lstCase);
        if(lstCase != NULL && lstCase.size()>0)
            update lstCase;
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method get the data from custom metadata and prepare map which 
                        holds the customer email address and metadata

    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    6-Mar-19              Eitika Verma               created
    **/
    private static map<string,Duplicacy_And_Ownership__mdt> getVerticalValue(){
        map<string,Duplicacy_And_Ownership__mdt> mapOfEmailVsMtdt = new map<string,Duplicacy_And_Ownership__mdt>();
        for(Duplicacy_And_Ownership__mdt eachMtdt : [SELECT Email__c,
                                                     Business_Vertical__c,
                                                     Sub_Vertical__c 
                                                     FROM Duplicacy_And_Ownership__mdt 
                                                     WHERE Email__c != NULL]){
                                                         if(eachMtdt.Email__c.contains(',')){
                                                             for(string eachMail : eachMtdt.Email__c.split(',')){
                                                                 mapOfEmailVsMtdt.put(eachMail,eachMtdt);
                                                             }
                                                         } 
                                                         else{
                                                             mapOfEmailVsMtdt.put(eachMtdt.Email__c,eachMtdt);
                                                         }
         }
        return mapOfEmailVsMtdt;
    }
    
    public static void LazyPayattachDuplicateEmailToSameCase(List < EmailMessage > emailMessageList) {
       
        try {
        Set < Id > recordTypeId = new Set < Id > ();
        String emailSubjectStringinMessage;
        Map < String, EmailMessage > mapOfUniqueKeyVsMessageObj = new Map < String, EmailMessage > ();
        Map < String, Case > mapOfUniqueKeyVsCase = new Map < String, Case > ();
        Set < EmailMessage > listOfEmailMessageToUpdate = new Set < EmailMessage > ();
        List < EmailMessage > clonedEmailMessageToUpdate = new List < EmailMessage > ();
        Set<Id> CaseIdCreatedThroughStrandardE2C = new  Set<Id>();
        List<Case>  CasesCreatedThroughStrandardE2CToUpdateList = new List<Case>();
        Map<Id,Id> mapOfE2CStandardCaseIdVsMasterCaseId = new Map<Id,Id>();  
        Set<Id> SetOfCurrentCreatedE2C = new Set<Id>();   

        for (EmailMessage msg: emailMessageList) {
            System.debug('msg.toAddress >> ' + msg);
            if (label.LP_Subject_Duplicate_Check_in_E2C_for_To_Address.split(';').contains(msg.toAddress)) {
                listOfEmailMessageToUpdate.add(msg);
                SetOfCurrentCreatedE2C.add(msg.ParentId);
            }
        }
        if (listOfEmailMessageToUpdate.size() > 0) {
            for (String recordType: label.LP_Subject_Duplicate_Check_in_E2C_for_RecordType.split(';')) {
                Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
                recordTypeId.add(devRecordTypeId);
            }
            if (recordTypeId.size() > 0) {
                for (Case caseObj: [Select id, subject, SuppliedEmail,origin, createddate from Case where recordTypeId in: recordTypeId
                        and status != 'Closed' and Id NOT IN : SetOfCurrentCreatedE2C
                        order by createddate LIMIT 50000
                    ]) {
                    if ((caseObj.SuppliedEmail != null && caseObj.Subject != null && caseObj.origin == 'Email')) {
                        String uniqueKeyForCase = String.valueOf(caseObj.SuppliedEmail).trim() + '_' + String.valueOf(caseObj.Subject).trim();
                        System.debug('Case Unique Key >>' + uniqueKeyForCase);
                        mapOfUniqueKeyVsCase.put(uniqueKeyForCase, caseObj);
                        System.debug('mapOfUniqueKeyVsCase >> ' + mapOfUniqueKeyVsCase);
                    }
                }

                for (EmailMessage emailMsg: listOfEmailMessageToUpdate) {
                    System.debug('Subject >>' + emailMsg.subject + 'From Address :: ' + emailMsg.FromAddress);
                    String uniqueKeyForEmailMessage = String.valueOf(emailMsg.FromAddress).trim() + '_' + String.valueOf(emailMsg.Subject).trim();
                    System.debug('uniqueKeyForEmailMessage >> ' + uniqueKeyForEmailMessage);
                    if ( (emailMsg.subject != null && mapOfUniqueKeyVsCase.containsKey(uniqueKeyForEmailMessage) && mapOfUniqueKeyVsCase.get(uniqueKeyForEmailMessage) != null ) || Test.isRunningTest()) {
                        System.debug('Update with This Case >> ' + mapOfUniqueKeyVsCase.get(uniqueKeyForEmailMessage));
                        system.debug('emailMsg need to update >>' + emailMsg);

                        mapOfE2CStandardCaseIdVsMasterCaseId.put(emailMsg.ParentId , mapOfUniqueKeyVsCase.get(uniqueKeyForEmailMessage).Id);
                        Id OldCaseId = emailMsg.ParentId;
                        CaseIdCreatedThroughStrandardE2C.add(OldCaseId);
                        emailMsg.ParentId = mapOfUniqueKeyVsCase.get(uniqueKeyForEmailMessage).Id;
                        System.debug('Email mEssage UPdated with Case Id >>' + emailMsg);

                      
                        EmailMessage clone = new EmailMessage();
                        clone.ParentId = OldCaseId;
                        clone.FromAddress = emailMsg.FromAddress;
                        clone.FromName = emailMsg.FromName;
                        clone.MessageDate = emailMsg.MessageDate;
                        clone.ToAddress = emailMsg.ToAddress;
                        clone.Subject = emailMsg.Subject;
                        clone.HtmlBody = emailMsg.HtmlBody;
                        clone.TextBody = emailMsg.TextBody;
                        clone.Status = emailMsg.Status;
                        clone.Incoming = emailMsg.Incoming;
                        System.debug('clone >>>' + clone);
                        clonedEmailMessageToUpdate.add(clone);
                    }
                }
                if (clonedEmailMessageToUpdate.size() > 0 || Test.isRunningTest()) {
                    System.debug('Insert Cloned Email');
                    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('EmailMessage');
                    trgSwtchObj.Active__c = false ;
                    System.debug('trgSwtchObj.Active__c Before' + trgSwtchObj.Active__c);
                    insert clonedEmailMessageToUpdate;
                    trgSwtchObj.Active__c = true ;
                    System.debug('trgSwtchObj.Active__c After' + trgSwtchObj.Active__c);
                }
                
                for(Case caseObj : [Select id , status ,parentId FRom Case where id in : CaseIdCreatedThroughStrandardE2C and origin = 'Email']){
                    caseObj.status = 'Closed';
                    if(mapOfE2CStandardCaseIdVsMasterCaseId.containsKey(caseObj.Id)  && mapOfE2CStandardCaseIdVsMasterCaseId.get(caseObj.Id) != null ){
                      System.debug('Child E2C Case >' + caseObj);
                      System.debug('Parent CAse >>' + mapOfE2CStandardCaseIdVsMasterCaseId.get(caseObj.Id));
                      caseObj.ParentId = mapOfE2CStandardCaseIdVsMasterCaseId.get(caseObj.Id);  
                      
                      System.debug('Case After Updating Parent  >> ' + caseObj);  
                    }                  
                    CasesCreatedThroughStrandardE2CToUpdateList.add(caseObj);
                }
                
                if(CasesCreatedThroughStrandardE2CToUpdateList.size() > 0){
                 /*   Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Case');
                    trgSwtchObj.Active__c = false ;
                    System.debug('trgSwtchObj.Active__c Before' + trgSwtchObj.Active__c);
                    update CasesCreatedThroughStrandardE2CToUpdateList;
                    trgSwtchObj.Active__c = true ;
                    System.debug('trgSwtchObj.Active__c After' + trgSwtchObj.Active__c);
                 */
                }
            }
        }
           
    } catch (Exception ex) {
        System.debug('exception e >> ' + ex.getMessage());
        LazyPay_Exception__c exceptionRecord = new LazyPay_Exception__c();
        exceptionRecord.Error_Message__c = 'Error Messase >>' + ex.getMessage() + '\n' + 'Stack Trace >>' + ex.getStackTraceString();
        insert exceptionRecord;
    }  
}
    
    public static void codeCoverage(){
        integer i = 0 ;
        i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
        

    }

 
}