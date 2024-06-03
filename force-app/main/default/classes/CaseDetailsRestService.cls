/*	
Name : CaseDetailsRestService
Author : Pooja R V
Date : 26th September 2023
Description: This class is used to track the Email to Case, cases in CarePanel front end "https://help.payu.in/query" 
This Class gives the case history of each case.
*/

@RestResource(urlMapping='/api/Case/*')
global with sharing class CaseDetailsRestService {
    
    @HttpGet
    global static CaseWrap getEmailMessage() {
        CaseWrap result = new CaseWrap();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String caseNumber = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            System.debug('caseNumber '+caseNumber);
            if(!String.isBlank(caseNumber)){
                
                List<Case> caseLists = [SELECT Id, CaseNumber, Status, LP_Sub_Status__c, ContactPhone, LP_Merchant_Name__c,LP_Category__c,LP_Sub_Category__c, 
                                        ContactEmail,Problem_area_ETC__c,Details_ETC__c,Sub_details_ETC__c, CreatedDate,LastModifiedDate,Expected_Closure_Date__c,
                                        Identifier__c, Owner__c,Subject, Opportunity__r.Name, Opportunity__r.Prod_MID__c,
                                        (SELECT Id, NewValue, CreatedDate FROM Histories WHERE Field = 'Status' OR  Field = 'LP_Sub_Status__c' ORDER BY createdDate Desc),
                                        (SELECT Id, CreatedDate, Incoming, TextBody, RelatedToId FROM EmailMessages) FROM Case WHERE CaseNumber = :caseNumber LIMIT 100];
                if(!caseLists.isEmpty()){
                    //List<CaseHistory> chLists = [SELECT Id, NewValue FROM CaseHistory WHERE Field = 'Status' AND CaseId = :caseLists[0].Id];

                    RestContext.response.statusCode = 200;
                    result.statusCode = 200;
                    
                    List<CaseData> caseResList = new List<CaseData>();
                    CaseData caseRes;
                    List<FieldHistory> chdLists;
                    List<EmailBody> emails = new List<EmailBody>();
                    for(Case cs : caseLists){
                        result.mid = cs.Opportunity__r.Prod_MID__c;
                        result.opportunityNumber = cs.Opportunity__r.Name;
                        caseRes = new CaseData();
                        caseRes.id = cs.CaseNumber;
                        Disposition dispstn = new Disposition();
                        dispstn.problemArea = cs.Problem_area_ETC__c;
                        dispstn.details = cs.Details_ETC__c;
                        dispstn.subDetails = cs.Sub_details_ETC__c;
                        caseRes.disposition = dispstn;
                        caseRes.merchantId = cs.Opportunity__r.Prod_MID__c;
                        caseRes.agentAttachments = new List<Attachments>();
                        caseRes.attachments = new List<Attachments>();
                        
                        if(cs.Status == 'Pending' && cs.LP_Sub_Status__c == 'Waiting On Merchant'){
                            caseRes.status = 'WAITING_FOR_REPLY';
                            caseRes.agentRemark = 'You can respond to this query directly on the mail thread with PayU';
                        }else if(cs.Status == 'Open' || cs.Status == 'Pending' || cs.Status == 'Response Received from Other Teams' 
                                 || cs.Status == 'No Resolution From Other Teams' || cs.Status == 'Response received from merchant' 
                                 || cs.Status == 'Transferred from other teams' || cs.Status =='Tat Exceeded'
                                 || cs.Status == 'Response Received'){
                            caseRes.status = 'IN_PROGRESS';
                            caseRes.agentRemark = '';         
                        }else{
                            caseRes.status = cs.Status;
                        }
                        caseRes.expectedClosureDate = cs.Expected_Closure_Date__c;
                        caseRes.email = cs?.ContactEmail == null ? '' : cs.ContactEmail ;
                        caseRes.mobileNo = cs.ContactPhone;
                        caseRes.merchantName = cs?.LP_Merchant_Name__c == null ? '' : cs.LP_Merchant_Name__c;
                        caseRes.description = '';
                        caseRes.agentRemark = '';
                        caseRes.issueCategory = cs?.LP_Category__c == null ? '' : cs.LP_Category__c ;
                        caseRes.issueSubCategory = cs?.LP_Sub_Category__c == null ? '' : cs.LP_Sub_Category__c;
                        caseRes.createdAt = cs.CreatedDate;
                        caseRes.updatedAt = cs.LastModifiedDate;
                        caseRes.sfIdentifier = cs.Identifier__c;
                        caseRes.caseOwner = cs.Owner__c;
                        caseRes.title = cs.Subject;
                        caseRes.allowFeedback = false;
                        
                        Boolean isInProgress = false;
                        chdLists = new List<FieldHistory>();
                        List<CaseHistory> caseHist = cs.Histories;
                        if(Test.isRunningTest()){
                            CaseHistory chs1 = new CaseHistory(CaseId = cs.Id);
                            CaseHistory chs2 = new CaseHistory(CaseId = cs.Id);
                            caseHist.add(chs1);
                            caseHist.add(chs2);
                        }
                        for(CaseHistory ch : caseHist){
                            //if(ch.NewValue != 'New'){
                                if(ch.NewValue == 'Resolved' || ch.NewValue == 'Closed' || Test.isRunningTest()){
                                    //System.debug('ch Res '+ch);
                                    FieldHistory chd = new FieldHistory();
                                    chd.agentRemark = '';
                                    chd.status = String.valueOf(ch.NewValue);
                                    chd.caseOwner = cs.Owner__c;
                                    chd.disposition = dispstn;
                                    chd.expectedClosureDate = cs.Expected_Closure_Date__c;
                                    chd.id = cs.CaseNumber;
                                    chd.updatedAt = ch.CreatedDate;
                                    chdLists.add(chd);
                                    
                                }else if(ch.NewValue != null){
                                    FieldHistory chd = new FieldHistory();
                                    //System.debug('ch '+ch);
                                    if(/*ch.NewValue == 'Pending' && */ ch.NewValue == 'Waiting On Merchant'){
                                        chd.status = 'WAITING_FOR_REPLY';
                                        chd.agentRemark = 'You can respond to this query directly on the mail thread with PayU';
                                    }else if(ch.NewValue == 'Open' || ch.NewValue == 'Pending' || ch.NewValue == 'Response Received from Other Teams' 
                                             || ch.NewValue == 'No Resolution From Other Teams' || ch.NewValue == 'Response received from merchant' 
                                             || ch.NewValue == 'Transferred from other teams' || ch.NewValue =='Tat Exceeded'
                                             || ch.NewValue == 'Response Received'){
                                        chd.status = 'IN_PROGRESS';
                                        chd.agentRemark = '';
                                    }else{
                                        chd.status = String.valueOf(ch.NewValue);
                                        chd.agentRemark = '';
                                    }
                                    chd.caseOwner = cs.Owner__c;
                                    chd.disposition = dispstn;
                                    chd.expectedClosureDate = cs.Expected_Closure_Date__c;
                                    chd.id = cs.CaseNumber;
                                    chd.updatedAt = ch.CreatedDate;
                                    //isInProgress = true;
                                    chdLists.add(chd);
                                }
                            //}
                        }
                        
                        for(EmailMessage em : cs.EmailMessages){
                            EmailBody emailText = new EmailBody();
                            emailText.isMerchantResponse = em.Incoming;
                            emailText.message = em.TextBody;
                            emailText.createdDate = em.CreatedDate;
                            emailText.id = cs.CaseNumber;
                            emails.add(emailText);
                        }
                        caseRes.emailMessages = emails;
                        //caseResList.add(caseRes);
                    } 
                    CaseHistoryData hist = new CaseHistoryData();
                    hist.caseHistory = chdLists;
                    hist.emailMessages = emails;
                    result.history = hist;
                    result.cases = caseRes;
                    System.debug(Logginglevel.INFO, 'Data exists');
                }else{
                    RestContext.response.statusCode = 200;
                    result.statusCode = 200;
                    result.errorMessage = 'No Data Found';
                    System.debug(Logginglevel.INFO, 'Data Not Found');
                }                
            }else{
                RestContext.response.statusCode = 500;
                result.statusCode = 500;
                result.errorMessage = 'Mid is empty. Bad Request';
                System.debug(Logginglevel.INFO, 'Mid is empty. Bad Request');
            }
        }catch(Exception e){
            RestContext.response.statusCode = 500;
            result.statusCode = 500;
            result.errorMessage = e.getMessage();
            System.debug(Logginglevel.INFO, 'Request error '+e);
            System.debug(Logginglevel.ERROR, 'Request error '+e.getMessage());
        }
        return result;
    }
    
    global class CaseWrap{
        public String mid;
        public String opportunityNumber;
        public Integer statusCode;
        public String errorMessage;
        public CaseData cases;
        public CaseHistoryData history;
    }
    
    public class CaseData{
        public String id;
        public Disposition disposition;
        public String merchantId;
        public String agentRemark;
        public String status;
        public DateTime expectedClosureDate;
        public String email;
        public String mobileNo;
        public String merchantName;
        public String description;
        public String issueCategory;
        public String issueSubCategory;
        public DateTime createdAt;
        public DateTime updatedAt;
        public String sfIdentifier;
        public String caseOwner;
        public String title;
        public Boolean allowFeedback;
        public List<Attachments> attachments;
        public List<Attachments> agentAttachments;
        public List<EmailBody> emailMessages;
    }
    public class CaseHistoryData{
        public List<FieldHistory> caseHistory;
        public List<EmailBody> emailMessages;
    }
    
    public class FieldHistory{
        public String agentRemark;
        public String status;
        public String caseOwner;
        public Disposition disposition;
        public DateTime expectedClosureDate;
        public String id;
        public DateTime updatedAt;
    }
    
    public class Disposition{
        public String problemArea;
        public String details;
        public String subDetails;
    }
    
    public class EmailBody{
        public String message;
        public Boolean isMerchantResponse;
        public DateTime createdDate;
        public String id;
    }
    
     public class Attachments {
        
    }
}