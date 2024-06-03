public class Whatsapp_CreateCase {
    
    public class MessagingInput {
        @InvocableVariable(required=false)
        public String Comments;
        
        @InvocableVariable(required=false)
        public String Email;
        
        @InvocableVariable(required=false)
        public String Issue;
        
        @InvocableVariable(required=false)
        public String Mobile;
        
        @InvocableVariable(required=false)
        public String FirstName;
        
        @InvocableVariable(required=false)
        public String SubIssue;
        
        @InvocableVariable(required=false)
        public String Mid;
        
        @InvocableVariable(required=false)
        public string Product;
        
        @InvocableVariable(required=false)
        public string website;
        
        @InvocableVariable(required=false)
        public string monthlyExpectedSales;        
        
        @InvocableVariable(required=false)
        public String isloggedIn;
        
    }
    
    public class MessagingOutput{
        
        @InvocableVariable(required=true)
        public Boolean sExistingCase;
        
        @InvocableVariable(required=true)
        public string sCaseNumber; 
        
        @InvocableVariable(required=true)
        public string sCaseId;
        
    }
    
    @InvocableMethod(Label = 'create case for whatsapp users')
    public static List<MessagingOutput> createCase(List<MessagingInput> InputMessageList){
        
        
        MessagingOutput Output = new MessagingOutput();
        List<MessagingOutput> OutputList = new List<MessagingOutput>();
        Map<string,string> ProductNameVsProductLabel = (map<string,string>)JSON.deserialize(System.Label.ProductNameVsProductLabel,map<string,string>.class);
        String recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        try{
            //Iterate over Input Messages
            if(InputMessageList != null && InputMessageList.size() == 1){
                MessagingInput input = InputMessageList[0];
                if(input.Mobile != null && input.Issue != null && input.subIssue != null && input.Email != null){
                    String Mobile = input.Mobile;
                    String Issue = input.Issue;
                    String subIssue = input.subIssue;
                    String Eml = input.Email;
                    //Check existing Case
                    List<Case> caseList = GuestUserUtilityHelper.querySobject('Case','ContactMobile = \''+ Mobile + '\' and LP_Issue__c = \''+ Issue + '\' and LP_Sub_Issue__c = \''+ SubIssue + '\' and ContactEmail = \''+ Eml + '\' and Status != \'Closed\' Limit 1');
                    //system.debug('caseList=='+caseList);
                    if(caseList != null && caseList.size() > 0){
                        Output.sExistingCase = true;
                        Output.sCaseNumber = caseList[0].caseNumber;
                        Output.sCaseId = caseList[0].id;
                        OutputList.add(Output);
                    }
                    else{
                        //Create new Case
                        //Check Existing Contact
                        if(input.Email != null && input.FirstName != null){
                            String Email = input.Email;
                            String sName = input.FirstName;
                            Case newCase = new Case();
                            Contact ExistingContact = checkExistingContact(Email,sName,Mobile);
                            if(ExistingContact != null){
                                newCase.ContactId = ExistingContact.id;
                                newCase.AccountId = ExistingContact.AccountId;
                            }
                            newCase.LP_Issue__c = Issue;
                            newCase.LP_Sub_Issue__c = SubIssue;
                            newCase.Comments = input.Comments;
                            newCase.recordTypeId = recordtypeid;
                            newCase.Origin = 'WhatsappChatbot';
                            if(input.isLoggedin != null && input.isLoggedin == 'false'){
                                newCase.Monthly_Expected_Sale__c = input.monthlyExpectedSales;
                                newCase.Website__c = input.website;
                            }
                            newCase.Subject = Issue;
                            //newCase.Merchant_Type__c = 'Potential Lead';
                            if(input.mid != null && input.Product != null ){
                                newCase.Merchant_Id__c = input.mid;
                                newCase.LP_Business_Vertical__c = ProductNameVsProductLabel.get(input.Product); 
                                newCase.LP_Category__c = ProductNameVsProductLabel.get(input.Product); 
                            }
                            
                            
                            List<case> csList = new List<Case>{newCase};
                                GuestUserUtilityHelper.upsertSObjectList(csList);
                            
                            //handle null later
                            system.debug('casenumber==='+csList[0].id);
                            id caseId = csList[0].id;
                            List<Case> queriedCaseList = GuestUserUtilityHelper.querySobject('Case','id = \''+ caseId + '\'');
                            Output.sExistingCase = false;
                            Output.sCaseNumber = queriedCaseList[0].caseNumber;
                            Output.sCaseId = queriedCaseList[0].Id;
                            OutputList.add(Output);
                            updateCaseOwner(String.valueOf(newCase.Id) ,String.valueOf(ExistingContact.Id),recordtypeid);
                            
                        }
                    }
                }   
            }}catch(Exception ex){
                System.debug('ex>>>'+ex.getLineNumber());
                Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'Whatsapp ChatBot createcase failure');
                insert erDetail;
            }
        return OutputList;
    }
    
    
    Private static Contact checkExistingContact(String Email, String Name, String Mobile){
        Contact existingContact = new Contact();
        List<Contact> ContactList = GuestUserUtilityHelper.querySobject('Contact','MobilePhone = \''+ Mobile + '\' and Email = \''+ Email + '\' and LastName = \''+ Name + '\'');
        if(ContactList != null && ContactList.size() > 0){
            existingContact = ContactList[0];
            if(existingContact.AccountId != null) return existingContact;
            else{
                String AccountId = createAccount(Name);
                existingContact.AccountId = AccountId;
                GuestUserUtilityHelper.upsertSObjectList(new List<Contact>{existingContact});
                return existingContact;
            }
            
        }
        else{
            Contact newContact = createContact(Email,Mobile,Name);
            return newContact;
        }
    }
    
    Private static String createAccount(String Name){
        Account acc = new Account();
        acc.Name = Name;
        GuestUserUtilityHelper.upsertSObjectList(new List<Account>{acc});
        return acc.Id;
    }
    
    private static Contact createContact(String Email,String Mobile,String Name){
        Contact newContact = new Contact();
        newContact.Email = Email;
        newContact.MobilePhone = Mobile;
        newContact.AccountId = createAccount(Name);
        newContact.LastName = Name;
        GuestUserUtilityHelper.upsertSObjectList(new List<Contact>{newContact});
        return newContact;
    }
    
    
    @future
    public static void updateCaseOwner(String CaseId,String ContactId,String recordtype){
        system.debug('enter update owner');
        list<Case> lstOfUpsertCase = new list<Case>(); 
        
        if(CaseId != null && !String.isBlank(CaseId) && ContactId != null && !String.isBlank(ContactId) ){
            list<Case> caseList = GuestUserUtilityHelper.querySobject('Case','id = \''+ CaseId + '\'');
            List<Contact> contactList = GuestUserUtilityHelper.querySobject('Contact','id = \''+ ContactId + '\'');
            Case objCase = caseList[0];
            CareUtility.OwnerAndDedupeWrapper objWrap;
            OneCareProcessHelper.OwnerAndDedupeWrapper oneCareObjWrap;
            
            oneCareObjWrap = OneCareProcessHelper.getDuplicacyAndOwnership(objCase.Merchant_Type__c, objCase.LP_Issue__c , objCase.LP_Sub_Issue__c, objCase.LP_Business_Vertical__c,objCase.LP_Category__c,'MerchantCare');
            if(oneCareObjWrap != NULL && oneCareObjWrap.ownerId != NULL){
                
                objCase.ownerId = oneCareObjWrap.ownerId;
                objCase.TicketId__c = objCase.CaseNumber;
                GuestUserUtilityHelper.upsertSObjectList(caseList);
                
                System.debug('oneCareObjWrap.ownerId'+oneCareObjWrap.ownerId);
            }
            
        }
        
    }
    
}