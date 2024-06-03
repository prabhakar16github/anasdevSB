public class ContactTriggerHandler{
    public static boolean isTriggerExecuted = false;
    
    public static void beforeInsertHandler(List<Contact> triggerNew){
       // List<Contact> ContactList = [SELECT Id, Name, Identifier__c, Email FROM Contact];
        Map<String, Contact> contactMap = new Map<String, Contact>();
       // List<String> identifierList = new List<String>();
       // for(Contact conObj : ContactList){
        //    contactMap.put(conObj.Identifier__c, conObj);
         //   identifierList.add(conObj.Identifier__c);
       // }
        
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Contact'); 
        for(Contact each : triggerNew){
            //boolean isDuplicate = checkDataBeforeInsert(each, ContactList, contactMap, identifierList);
             
            //if(!isDuplicate){ 
                // call this method to get the identifier field value if not exist  
                SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj); 
                //For Collection : update the mobile number format
                
            /*}
            else{
                system.debug('-->> --> '+contactMap.get(each.Identifier__c)+' - '+each);
                each.addError('Duplicate Contact Found');
            }*/
        }
        updateMobile(triggerNew);
    }
    
    public static void afterInsertHandler(List<Contact> triggerNew){
        for(Contact each : TriggerNew){
             if(!System.isBatch() && each.Is_payload_need_to_publish__c && each.Data_need_to_be_publish__c){
                    IntegrationUtility.sendPayLoadData(each, null, 'Contact', 'Contact'); 
            }
        }
    }
    
    
    public static void afterUpdateHandler(list<Contact> triggerNew,map<ID,Contact> maptriggerold){
        
        //Send KYC Call Out.
        if (isTriggerExecuted == false && isLoggedInUserL1AndL2()){ 
            //lazyPayPublish.sendPayLoaddata(triggerNew,maptriggerold,'Contact',null);
            System.debug('Sending contact Info');
            boolean sendPayload = false;
            List<PayloadActMap__mdt> mdtList  = new List<PayloadActMap__mdt>();
            for(PayloadActMap__mdt mdt : [Select FieldsCheck__c,Secondary_Object_Query_Fields__c,LookUpField__c FRom PayloadActMap__mdt where MasterLabel = 'SendContactInformation'] ){
               mdtList.add(mdt); 
            }            
            if(mdtList.size() >0){
                for(Contact conObj : triggerNew){
                    for( String fields : mdtList[0].FieldsCheck__c.split(',') ){
                        if(conObj.get(fields) != maptriggerold.get(conObj.Id).get(fields)){
                            sendPayload = true ;
                            break;
                        }
                    }
                }
                
            }
            
            if(sendPayload){ 
                if(!Test.isRunningTest()){
                    System.debug('Send Payload from Contact');
                   SendInformationToLazyPay.sendContactInfoToLazyPay(triggerNew,maptriggerold);  
                }
                 
            }
            
             isTriggerExecuted = True;
                       
        }
        
        //For Collection : update the mobile number format
        updateMobile(triggerNew);
        
        for (contact each:triggerNew){
             if(!System.isBatch() && each.Is_payload_need_to_publish__c && each.Data_need_to_be_publish__c){
                 system.debug('@@@@@@@@@ contact trigger data send ');
                IntegrationUtility.sendPayLoadData(each, maptriggerold.get(each.Id), 'Contact', 'Contact'); 
            }           
        }
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       update the mobile number in +91xxxxxxxx
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-Sep-18              Eitika Verma               created
    **/
    public static void updateMobile(List<Contact> triggerNew){
        list<Contact> lstContact = new list<Contact>();
        for(Contact eachContact : triggerNew){
            system.debug('eachContact.MobilePhone======='+eachContact.MobilePhone);
             system.debug('!eachContact.MobilePhone.startsWith======='+eachContact.MobilePhone);
            if(eachContact.MobilePhone != NULL && !eachContact.MobilePhone.startsWith('+91')){
                string strMobileNum = '+91'+ eachContact.MobilePhone;
                if(Trigger.isInsert)
                  eachContact.MobilePhone = strMobileNum;
                if(Trigger.isUpdate){
                    Contact objCon = new Contact(id=eachContact.Id,MobilePhone=strMobileNum);
                    lstContact.add(objCon);
                }
                
            }
        }
        
        if(Trigger.isUpdate){
            update lstContact;
        }
    }
    
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       checks that login user is l1 user or l2 user to update the aadhar detail on contact
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-Sep-18              Eitika Verma               created
    **/
    public static boolean isLoggedInUserL1AndL2(){
       list<GroupMember> lstGrpMember = [Select UserOrGroupId
                                              From GroupMember 
                                            WHERE UserOrGroupId =:userInfo.getUserId()
                                            AND GroupId IN (SELECT id 
                                                              FROM Group 
                                                              WHERE type = 'Queue' 
                                                              AND (Name = 'L2 KYC Queue' OR Name = 'L1 KYC Queue'))];
        if(lstGrpMember != null && lstGrpMember.size()>0)
            return true;
        else
            return false;
    }
    
    /*private static boolean checkDataBeforeInsert(Contact eachContact, List<Contact> ContactList, Map<String, Contact> contactMap, List<String> identifierList){
        boolean isDuplicate = false;
        if(identifierList.contains(eachContact.Identifier__c) && (String.isNotBlank(eachContact.Identifier__c) || eachContact.Identifier__c != null)){
            isDuplicate = true;
        }
        return isDuplicate;
    }*/
    
}