/*	
Name : CaseEmailAPI
Author : Pooja R V
Date : 27th August 2023
Description: This class is used to track the Email to Case, cases in CarePanel front end "https://help.payu.in/query" 
This Class gives List of all cases for particular merchant
*/


@RestResource(urlMapping='/api/AllCases/*')
global with sharing class CaseEmailAPI {
    
    @HttpGet
    global static CaseWrap getEmailMessage() {
        CaseWrap result = new CaseWrap();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            //String mid = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            String pageNum = RestContext.request.params.get('pageNumber');
            String mid = RestContext.request.params.get('mid');
            //Integer noOfRecord = Integer.valueOf(RestContext.request.params.get('recordCount'));
            
            //Map<String,Object> requestJSONMap = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            //String pageNum = String.ValueOf(requestJSONMap.get('pageNumber'));
            //System.debug('>>>requestJSONMap'+requestJSONMap);
            
            System.debug('>>>pageNum'+pageNum);
            Integer pageNumber = Integer.valueOf(pageNum);//2;
            Integer endRange = (20*pageNumber); //10
            Integer startRange = (endRange-20)+1; // 6
            Integer totalResult = 0;
            System.debug('MID '+mid);
            if(!String.isBlank(mid)){
                
                List<Case> caseListsAll = [SELECT Id, CaseNumber, Status, LP_Sub_Status__c, ContactPhone, LP_Merchant_Name__c,LP_Category__c,LP_Sub_Category__c, 
                                        ContactEmail,Problem_area_ETC__c,Details_ETC__c,Sub_details_ETC__c, CreatedDate,LastModifiedDate,Expected_Closure_Date__c,
                                        Identifier__c, Owner__c,Subject, Opportunity__r.Name, (SELECT Id, CreatedDate, Incoming, TextBody, RelatedToId FROM EmailMessages) FROM Case 
                                        WHERE Opportunity__c != NULL 
                                        AND Origin != 'Web' 
                                        AND Opportunity__r.Prod_MID__c = :mid
                                        ORDER BY CreatedDate Desc];
                totalResult = caseListsAll.size();
                if(endRange > caseListsAll.size()){
                    endRange = caseListsAll.size();
                }
                
                List<Case> caseLists = new List<Case>();
                for(Integer i=startRange-1;i<endRange;i++){
                    //if(i >= startRange && i<=endRange ){
                        caseLists.add(caseListsAll[i]);
                    //}
                }
                                       	
                if(!caseLists.isEmpty()){
                    RestContext.response.statusCode = 200;
                    result.statusCode = 200;
                    result.mid = mid;
                    
                    List<CaseData> caseResList = new List<CaseData>();
                    for(Case cs : caseLists){
                        result.opportunityNumber = cs.Opportunity__r.Name;
                        CaseData caseRes = new CaseData();
                        caseRes.id = cs.CaseNumber;
                        Disposition dispstn = new Disposition();
                        dispstn.problemArea = cs.Problem_area_ETC__c;
                        dispstn.details = cs.Details_ETC__c;
                        dispstn.subDetails = cs.Sub_details_ETC__c;
                        caseRes.disposition = dispstn;
                        caseRes.merchantId = mid;
                        caseRes.agentAttachments = new List<Attachments>();
                        caseRes.attachments = new List<Attachments>();
                        
                        if(cs.Status == 'Pending' && cs.LP_Sub_Status__c == 'Waiting On Merchant'){
                            caseRes.status = 'WAITING_FOR_REPLY';
                            caseRes.agentRemark = 'You can respond to this query directly on the mail thread with PayU';
                        }else if(cs.Status == 'Open' || cs.Status == 'Pending' || cs.Status == 'Response Received from Other Teams' 
                                 || cs.Status == 'No Resolution From Other Teams' || cs.Status == 'Response received from merchant' 
                                 || cs.Status == 'Transferred from other teams' || cs.Status =='Tat Exceeded'
                                 || cs.Status == 'Transferred from other teams' || cs.Status == 'Response Received'){
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
                        List<EmailBody> emails = new List<EmailBody>();
                        
                        for(EmailMessage em : cs.EmailMessages){
                            EmailBody emailText = new EmailBody();
                            emailText.isMerchantResponse = em.Incoming;
                            emailText.message = em.TextBody;
                            emailText.createdDate = em.CreatedDate;
                            emails.add(emailText);
                        }
                        caseRes.emailMessages = emails;
                        caseResList.add(caseRes);
                    } 
                    
                    result.cases = caseResList;
                    
                    //Adding pagination details
                    result.count = totalResult;
                    result.pageNumber = pageNumber;
                    result.pages = Math.ceil(Decimal.valueOf(totalResult).divide(20,1)).intValue();
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
        public Integer count;
        public Integer pageNumber;
        public Integer pages;
        public List<CaseData> cases;
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
 
    public class Disposition{
        public String problemArea;
        public String details;
        public String subDetails;
    }
    
    public class EmailBody{
        public String message;
        public Boolean isMerchantResponse;
        public DateTime createdDate;
    }
    
    public class Attachments {
        
    }
    
}