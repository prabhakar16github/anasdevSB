global class GMVUploadEmailServiceController implements Messaging.InboundEmailHandler {
    
    public static List<String> failedResponseList = new List<String>();
    public static Map<String, Object> failureResponseMap = new Map<String, Object>();
    public static Map<String, Object> successResponseMap = new Map<String, Object>();
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try{
            
            
            string GMVSubject_PayUmoney = System.label.GMV_upload_subject_label ;
            string leadScoreSubject = System.Label.Lead_Score_Subject_Label;
            string NeoBankingRBLSubject = System.Label.NeoBankingRBL_Subject_Label;
            string CalendlyFromAddress = System.Label.CalendlyFromAddress_Label;
            string prospectNbSubject = System.Label.NeoBankingScope_Label ;
            string npsUploadSubject = System.Label.Upload_NPS_Data ;

            /** Added custom label PPI_customerOnboardingSubject - SFI-803 */
            String PPI_customerOnboardingSubject = System.Label.PPI_Customer_Onboarding_Subject;
            /** */
            
            /**** added custom label Bulk_RiskHoldSubject -SFI-871 **/
             String Bulk_RiskHoldSubject = System.Label.Bulk_RiskHoldSubject ;
            /** */

            Blob attachmentBody;
            String[] errorMessage = New List<String>();
            string GMVSubject_PayUBiz = System.label.GMV_upload_subject_label_Biz ;
            
            system.debug('####### email.subject '+email.subject);
            if(email.subject.equalsIgnoreCase(GMVSubject_PayUmoney)){
                uploadGMVData(email,attachmentBody,errorMessage);
            }
            else if(email.subject.equalsIgnoreCase(leadScoreSubject)){
                uploadLeadScoreData(email,attachmentBody,errorMessage);
            }
            else if(email.subject.startsWithIgnoreCase(NeoBankingRBLSubject)){
                uploadNeoBankingData(email,attachmentBody,errorMessage);
            }
            else if(email.fromAddress.equalsIgnoreCase(CalendlyFromAddress)){
                createCalendlyCases(email,attachmentBody,errorMessage);
            }
            else if(email.subject.equalsIgnoreCase(prospectNbSubject)){
                updateScopeforNeoBanking(email,attachmentBody,errorMessage);
            }else if(email.subject.equalsIgnoreCase(GMVSubject_PayUBiz)){
                uploadBizGMVData(email,attachmentBody,errorMessage);
            }else if(email.subject.equalsIgnoreCase(npsUploadSubject)){
                uploadNPSData(email,attachmentBody,errorMessage);
            }
            /** added for customer onboarding - SFI-803 */ 
            else if(email.subject.equalsIgnoreCase(PPI_customerOnboardingSubject)){
                
                //Database.executeBatch(new PPI_CustomerOnboardingBatch(email.binaryAttachments[0].body.toString(),email.binaryAttachments[0].fileName));
                String decryptedText = getDecryptedData(email.binaryAttachments[0].body);
                String fileName = email.binaryAttachments[0].fileName;
                if(String.isNotBlank(decryptedText)){
                    Database.executeBatch(new PPI_CustomerOnboardingBatch(decryptedText,fileName));
                }
            }/**  */
            
            /*** added for risk hold functionality- SFI-871****/
            else if(email.subject.equalsIgnoreCase(Bulk_RiskHoldSubject)){
                String fileName = email.binaryAttachments[0].fileName;
                String fromUserId = getUserIdFromEmail(email.fromAddress);
                Boolean isValidUser = false;
                
                if(String.isNotBlank(fromUserId)){
                    
                    if(fileName == 'Bulk_OB_Hold.csv' && System.Label.Hold_Users_For_OB.contains(fromUserId)){
                        isValidUser = true;
                    }else if(fileName == 'Bulk_Post_Hold.csv' && System.Label.Hold_Users_For_Post_risk.contains(fromUserId)){ 
                        isValidUser = true;
                    }else if(fileName == 'Bulk_Pre_Hold.csv' && System.Label.Hold_Users_For_Pre_risk.contains(fromUserId)){ 
                        isValidUser = true;
                    }else if(fileName == 'Bulk_OB_Hold_Release.csv' && System.Label.Hold_Users_From_OB.contains(fromUserId)){ 
                        isValidUser = true;
                    }else if(fileName == 'Bulk_Post_Hold_Release.csv' && System.Label.Hold_Users_From_Post_risk.contains(fromUserId)){ 
                        isValidUser = true;
                    }else if(fileName == 'Bulk_Pre_Hold_Release.csv' && System.Label.Hold_Users_From_Pre_risk.contains(fromUserId)){ 
                        isValidUser = true;
                    }
                }
                 
                else
                {
                    String body='The user associated with this email address is not found in our Salesforce system. Error: Invalid user.';
                    sendEmailForInvalidUser(body);
                    
                }
                
                if(isValidUser){
                    Blob fileContentBlob = email.binaryAttachments[0].body;
                    
                    if(fileContentBlob != NULL){
                        new ApexClassForTesting(fileContentBlob,fileName,fromUserId,email.fromAddress).processFile();
                        //Database.executeBatch(new Risk_StatusDetailsBatch(fileContentBlob,fileName,fromUserId,email.fromAddress),100);
                    }
                }else{
                    // send mail for invalid user
                    String body='Your email address was not recognized in our Salesforce system. Please verify and provide a valid email associated with an active user account.';
                    sendEmailForInvalidUser(body);
                }
            }/**  */
            result.success = true;
        }catch(Exception ex){
            result.success = false;
            result.message = ex.getMessage();
            
            Error_Details__c errorDetails = new Error_Details__c(Process__c = 'GMVUploadEmailService',Message__c = ex.getMessage(),Severity__c = 'High', Identifier__c = String.valueOf(ex.getLineNumber()));
            insert errorDetails;
        }
        return result;
    }
    
    
    public static void sendEmailForInvalidUser(String body){
       
        String emailSubject = 'Unrecognized Email Address in Salesforce System';
        String emailBody = body;
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        email.setTargetObjectId(userinfo.getUserId());
        email.setSubject(emailSubject);
        email.setPlainTextBody(emailBody);
        email.setSaveAsActivity(false);
        Messaging.sendEmail(new List<Messaging.Email>{email});
    }
    
    /** private method to get the user Id from email address - SFI-871 */
     private String getUserIdFromEmail(String email){
        List<User> userList = [SELECT Id,Name,Email FROM User WHERE Email = :email LIMIT 1];
        if(!userList.isEmpty()){
            return userList[0].Id;
        }
        return NULL;
	}/** END */
    
    /** Method to decrypt the data for PPI_Customer Onboarding. [SFI-803]
     * @param - Encrypted CSV data in blob.
     * return type - String - decrypted data for PPI_Custome Onboarding. 
    */
    private static String getDecryptedData(Blob fileBlob){
        
        Blob privateKey = EncodingUtil.base64Decode(System.label.PPI_Customer_Onboarding_Private_Key);
        Blob decrypted = Crypto.decryptWithManagedIV('AES256',privateKey, fileBlob);
        String decryptedText = decrypted.toString();
        System.debug('>>>>>decryptedText>>>>'+decryptedText); 
        return decryptedText;                                     
    }/** END */ 



    public static void uploadGMVData(Messaging.InboundEmail email,blob attachmentBody, list<string> errorMessage){
        try{
            if(email.binaryAttachments != null && !email.binaryAttachments.isEmpty()){
                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                    if(!Test.isRunningTest()){
                        attachmentBody = bAttachment.body;
                    }else{
                        attachmentBody = Blob.valueof(System.Label.GMVUploadEmailServiceBody);
                    }
                    
                    Utility_RowIterator r = New Utility_RowIterator(attachmentBody.toString(),'\n'); //Replace \n with whatever delineates your row
                    
                    String firstRow;
                    if(r.hasNext()) firstRow = r.next();
                    
                    String headers = firstRow; 
                    
                    string[] headerList = headers.split(',');
                    
                    if(headerList[0].equalsIgnoreCase('Platform') && headerList[1].equalsIgnoreCase('merchantId') && headerList[2].equalsIgnoreCase('Lifetime_GMV')
                       && headerList[3].equalsIgnoreCase('last_3_Months_GMV') && headerList[4].equalsIgnoreCase('last_6_Months_GMV') && headerList[5].equalsIgnoreCase('Chargeback_GMV')
                       && headerList[6].equalsIgnoreCase('CB Ratio') && headerList[7].equalsIgnoreCase('MTD_GMV') && headerList[8].replaceAll( '\\s+', '').equalsIgnoreCase('First_Txn_Date')
                       && headerList[9].replaceAll( '\\s+', '').equalsIgnoreCase('Last_Txn_Date') && headerList[10].replaceAll( '\\s+', '').equalsIgnoreCase('SE_Date') && headerList[11].equalsIgnoreCase('Last_1_month_GMV') && headerList[12].equalsIgnoreCase('Last_2_month_GMV') && headerList[13].replaceAll( '\\s+', '').startswith('uuid')){
                           
                           List<Opportunity> oppObjList = New List<Opportunity>();  
                           
                           GMVUploadEmailServiceBatch gmvBatch = New GMVUploadEmailServiceBatch();
                           gmvBatch.fileData = attachmentBody.toString();
                           gmvBatch.platformName = 'GMVMoneyUpload';
                           Database.executeBatch(gmvBatch);                          
                       }
                    else{
                        errorMessage.add('Column mismatch');
                    }
                    
                    // If error send an email
                    if(!errorMessage.isEmpty()){
                        // error email
                        Error_Details__c objErrorLog = new Error_Details__c();
                        objErrorLog.Message__c = 'Column mismatch - '+errorMessage;
                        objErrorLog.Process__c = 'Money-GMV upload Email Service failed';
                        insert objErrorLog;
                    }
                }
            }
        }catch(Exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'Money-GMV upload Email Service failed');
            insert erDetail;
        }
    }
    
    public static void uploadBizGMVData(Messaging.InboundEmail email,blob attachmentBody, list<string> errorMessage){
        try{
            if(email.binaryAttachments != null && !email.binaryAttachments.isEmpty()){
                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                    if(!Test.isRunningTest()){
                        attachmentBody = bAttachment.body;
                    }else{
                        attachmentBody = Blob.valueof(System.Label.GMVUploadEmailServiceBody_Biz);
                    }
                    //string fileData = blobToString( attachmentBody,'ISO-8859-1');
                    
                    Utility_RowIterator r = New Utility_RowIterator(attachmentBody.toString(),'\n'); //Replace \n with whatever delineates your row
                    
                    String firstRow;
                    if(r.hasNext()) firstRow = r.next();
                    
                    String headers = firstRow;                   
                    
                    string[] headerList = headers.split(',');
                    System.debug('headerList[0]--------->'+headerList[0].equalsIgnoreCase('Platform'));
                    if((headerList[0].equalsIgnoreCase('Platform') || headerList[0].equalsIgnoreCase('latform')) && headerList[1].equalsIgnoreCase('merchantId') && headerList[2].equalsIgnoreCase('YTD_GMV')
                       && headerList[3].equalsIgnoreCase('last_3_Months_GMV') && headerList[4].equalsIgnoreCase('last_6_Months_GMV') && headerList[5].equalsIgnoreCase('last_12_Months_GMV') && headerList[6].equalsIgnoreCase('Chargeback_GMV')
                       && headerList[7].equalsIgnoreCase('CB Ratio') && headerList[8].equalsIgnoreCase('MTD_GMV') && headerList[9].equalsIgnoreCase('merchantCreatedDate')
                       && headerList[10].replaceAll( '\\s+', '').equalsIgnoreCase('Last_Txn_Date_ThisYear') && headerList[11].equalsIgnoreCase('Last_1_month_GMV') && headerList[12].equalsIgnoreCase('Last_2_month_GMV')){
                          SYstem.debug('headerList ::--Inside If---->'+headerList);
                           Map<Integer,Opportunity> prodMerchantIdOppMap = New Map<Integer,Opportunity>();
                           List<Opportunity> oppObjList = New List<Opportunity>();  
                           Set<Integer> prodMids = New Set<Integer>();
                           GMVUploadEmailServiceBatch gmvBatch = New GMVUploadEmailServiceBatch();
                           gmvBatch.fileData = attachmentBody.toString();
                           gmvBatch.platformName = 'GMVBizUpload';
                           Database.executeBatch(gmvBatch);
                       }
                    else{
                        errorMessage.add('Column mismatch');
                    }
                    
                    // If error send an email
                    if(!errorMessage.isEmpty()){
                        // error email
                        Error_Details__c objErrorLog = new Error_Details__c();
                        objErrorLog.Message__c = 'Column mismatch '+errorMessage;
                        objErrorLog.Process__c = 'Biz-GMV upload Email Service failed';
                        insert objErrorLog;
                    }
                }
            }
        }catch(Exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'GMV upload Email Service failed');
            insert erDetail;
        }
    }
    
    
    public static void uploadLeadScoreData(Messaging.InboundEmail email,blob attachmentBody, list<string> errorMessage){
        
        try{
            if(email.binaryAttachments != null && !email.binaryAttachments.isEmpty()){
                
                List<Opportunity> oppObjList = New List<Opportunity>();  
                List<Lead> leadObjList = New List<Lead>();
                
                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                    if(!Test.isRunningTest()){
                        attachmentBody = bAttachment.body;
                    }else{
                        attachmentBody = Blob.valueof(System.Label.LeadScoreEmailServivceBody );
                    }
                    string fileData = blobToString( attachmentBody,'ISO-8859-1');
                    //Now sepatate every row of the excel file
                    String[] filelines = fileData.split('\n');                    
                    
                    String headers= filelines[0];                   
                    
                    string[] headerList = headers.split(',');
                    
                    if(headerList[0].equalsIgnoreCase('merchantid') && headerList[1].equalsIgnoreCase('label') 
                       && headerList[2].startswith('uuid')
                      ){
                          for (Integer i=1;i<filelines.size();i++){
                              String[] inputvalues = new String[]{};
                                  inputvalues = filelines[i].split(',');
                              inputvalues = filelines[i].split(',');
                              
                              Opportunity oppObj = New Opportunity(Identifier__c = inputvalues[2], Merchant_Lead_Score__c = Integer.ValueOf(inputvalues[1]));
                              oppObjList.add(oppObj);
                              
                              Lead leadObj = New Lead(Identifier__c = inputvalues[2], Merchant_Lead_Score__c = Integer.ValueOf(inputvalues[1]));
                              leadObjList.add(leadObj);
                          }
                          
                      }else{
                          errorMessage.add('Column mismatch');
                      }
                    
                    // If error send an email
                    if(!errorMessage.isEmpty()){
                        // error email
                        Error_Details__c objErrorLog = new Error_Details__c();
                        objErrorLog.Message__c = 'Column mismatch';
                        objErrorLog.Process__c = 'Lead Score email service failed';
                        insert objErrorLog;
                    }
                }
                
                if(!oppObjList.isEmpty() && oppObjList.size()>0) {
                    OpportunityTriggerHandler.publishUpdateFromApex = false;
                    Database.UpsertResult[] results = Database.upsert(oppObjList, Opportunity.Identifier__c.getDescribe().getSObjectField(), false);
                    
                    for(Integer i=0;i<results.size();i++){
                        if (!results.get(i).isSuccess()){
                            Database.Error err = results.get(i).getErrors().get(0);
                            errorMessage.add('Error - '+err.getMessage()+'\n Fields : '+err.getFields());
                            System.debug('Error - '+err.getMessage() + '\nStatus Code : '+err.getStatusCode()+'\n Fields : '+err.getFields());
                        }
                    }
                } 
                if(!leadObjList.isEmpty() && leadObjList.size()>0) {
                    Database.UpsertResult[] results = Database.upsert(leadObjList, Lead.Identifier__c.getDescribe().getSObjectField(), false);
                    
                    for(Integer i=0;i<results.size();i++){
                        if (!results.get(i).isSuccess()){
                            Database.Error err = results.get(i).getErrors().get(0);
                            errorMessage.add('Error - '+err.getMessage()+'\n Fields : '+err.getFields());
                            System.debug('Error - '+err.getMessage() + '\nStatus Code : '+err.getStatusCode()+'\n Fields : '+err.getFields());
                        }
                    }
                } 
                
            }
        }catch(Exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'Lead Score email service failed');
            insert erDetail;
        }
    }
    
    public static void uploadNeoBankingData(Messaging.InboundEmail email,blob attachmentBody, list<string> errorMessage){
        system.debug('####### email.textAttachments '+email.textAttachments); 
        system.debug('####### email.binaryAttachments '+email.binaryAttachments); 
        try{
            if(email.binaryAttachments != null && !email.binaryAttachments.isEmpty()){
                Email_Service_Settings__mdt neoBankingMdt = [select id,MasterLabel,fieldNameHeaderMap__c, feildIndexMap__c from Email_Service_Settings__mdt where MasterLabel = 'NeoBanking RBL Data' limit 1];
                Map<string,string> HeaderFieldMap = (Map<string,string>)JSON.deserialize(neoBankingMdt.fieldNameHeaderMap__c, Map<string,string>.class);
                Map<string,Integer> InputValuesMap = (Map<string,Integer>)JSON.deserialize(neoBankingMdt.feildIndexMap__c,Map<string,Integer>.class);
                Map<string,string> RBLOwnershipMap = (Map<string,string>)JSON.deserialize(System.Label.RBLOwnershipMap,Map<string,string>.class);
                Set<string> BankProcessingList = RBLOwnershipMap.keySet();
                
                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
                    if(!Test.isRunningTest()){
                        attachmentBody = bAttachment.body;
                    }else{
                        attachmentBody = Blob.valueof(System.Label.NeoBanking_Service_Body);
                    }
                    string fileData = attachmentBody.toString();
                    //string fileData = blobToString(attachmentBody,'ISO-8859-1');
                    system.debug('fileData=='+fileData);
                    String[] filelines = fileData.split('\n');
                    list<String> headers= filelines[0].split(',');
                    list<String> fieldsToCompare = new List<string>();
                    fieldsToCompare.addAll(HeaderFieldMap.keySet());
                    
                    for(integer i=0;i<fieldsToCompare.size();i++){
                        headers[i] = headers[i].trim();
                        if(headers[i].replaceAll( '\\s+', '').equalsIgnoreCase(fieldsToCompare[i].replaceAll( '\\s+', '')) || headers[0].replaceAll( '\\s+', '') == 'CustomerReferenceNumber' || i == 0){
                            continue;
                        }
                        else{
                            errorMessage.add('Column mismatch');
                            system.debug(headers[i]+'.  '+fieldsToCompare[i]+'===');
                        }
                        system.debug('headers=='+headers[i]+'==');
                    }
                    
                    List<Case> caseObjList = New List<Case>();  
                    for (Integer j=1;j<filelines.size();j++){
                        String[] inputvalues = new String[]{};
                            inputvalues = filelines[j].split(',');
                        Case caseObj = new Case(); 
                        for(String each : InputValuesMap.keySet()){
                            
                            Integer Index = InputValuesMap.get(each);
                            if(each == 'Account_Opening_Date__c' || each == 'Account_Login_Date__c'){
                                //system.debug('inputvalues[21]===='+inputvalues[21]+'====');
                                //system.debug('inputvalues[20]===='+inputvalues[20]+'====');
                                if(inputvalues.size() > headers.size() - 2)
                                    caseObj.Account_Login_Date__c = String.isNotBlank(inputvalues[20]) ? Date.parse(inputvalues[20].trim()) : caseObj.Account_Login_Date__c != null ? caseObj.Account_Login_Date__c : null;
                                if(inputvalues.size() > headers.size() - 1)
                                    caseObj.Account_Opening_Date__c = String.isNotBlank(inputvalues[21]) ? Date.parse(inputvalues[21].trim()) : caseObj.Account_Opening_Date__c != null ? caseObj.Account_Opening_Date__c : null;
                            }
                            else if(Index < inputvalues.size()){
                                system.debug('each=='+each);
                                system.debug('each Value=='+inputvalues[Index]);
                                if(each == 'LP_Sub_Status__c'){
                                    if(inputvalues[Index] != null && BankProcessingList.contains(inputvalues[Index]) && inputvalues[Index] != '')
                                        caseObj.Status = 'RBL has picked up the documents from the lead';
                                    String Owner = inputvalues[Index].trim();
                                    caseObj.Ownership__c = RBLOwnershipMap.get(Owner);
                                }
                                String inpValue = inputvalues[Index] != null && inputvalues[Index] != '' ? inputvalues[Index].trim() : inputvalues[Index];
                                caseObj.put(each,inpValue);
                            }
                            caseObj.isBulkUpdateSent__c = false;
                        }
                        caseObjList.add(caseObj);
                        
                    }
                    if(!caseObjList.isEmpty() && caseObjList.size()>0) {
                        Database.UpsertResult[] results = Database.upsert(caseObjList, Case.Identifier__c, false);
                        
                        for(Integer i=0;i<results.size();i++){
                            if (!results.get(i).isSuccess()){
                                Database.Error err = results.get(i).getErrors().get(0);
                                errorMessage.add('Error - '+err.getMessage()+'\n Fields : '+err.getFields());
                                System.debug('Error - '+err.getMessage() + '\nStatus Code : '+err.getStatusCode()+'\n Fields : '+err.getFields());
                            }
                        }
                    }
                }
            }
        }catch(Exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'Neo Banking Email Service failed');
            insert erDetail;
        }
    }
    
    
    public static void updateScopeforNeoBanking(Messaging.InboundEmail email,blob attachmentBody, list<string> errorMessage){
        system.debug('####### email.textAttachments '+email.textAttachments); 
        
        try{
            if(email.binaryAttachments != null && !email.binaryAttachments.isEmpty()){
                List<opportunity> oppList = new List<Opportunity>();
                Email_Service_Settings__mdt neoBankingProspectMdt = [select id,MasterLabel,fieldNameHeaderMap__c, feildIndexMap__c from Email_Service_Settings__mdt where MasterLabel = 'NeoBanking Prospect' limit 1];
                Map<string,string> HeaderFieldMap = (Map<string,string>)JSON.deserialize(neoBankingProspectMdt.fieldNameHeaderMap__c, Map<string,string>.class);
                Map<string,Integer> InputValuesMap = (Map<string,Integer>)JSON.deserialize(neoBankingProspectMdt.feildIndexMap__c,Map<string,Integer>.class);
                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
                    if(!Test.isRunningTest()){
                        attachmentBody = bAttachment.body;
                    }else{
                        attachmentBody = Blob.valueof(System.Label.NbScopeServiceData );
                    }
                    string fileData = attachmentBody.toString();
                    //string fileData = blobToString(attachmentBody,'ISO-8859-1');
                    system.debug('fileData=='+fileData);
                    String[] filelines = fileData.split('\n');
                    list<String> headers= filelines[0].split(',');
                    
                    list<String> feildsToCompare = new List<string>();
                    feildsToCompare.addAll(HeaderFieldMap.keySet());
                    
                    for(integer i=0;i<feildsToCompare.size();i++){
                        headers[i] = headers[i].trim();
                        if(headers[i].equalsIgnoreCase(feildsToCompare[i]) || i == 0){
                            continue;
                        }
                        else{
                            errorMessage.add('Column mismatch');
                            system.debug(headers[i]+'.  '+feildsToCompare[i]+'===');
                        }
                        system.debug('headers=='+headers[i]+'==');
                    }
                    
                    for (Integer j=1;j<filelines.size();j++){
                        String[] inputvalues = new String[]{};
                            inputvalues = filelines[j].split(',');
                        opportunity opp = new Opportunity();
                        opp.Identifier__c = inputvalues[1];
                        opp.NB_Eligible__c = true;
                        oppList.add(opp);
                    }
                    if(!oppList.isEmpty() && oppList.size()>0) 
                        Database.UpsertResult[] results = Database.upsert(oppList, Opportunity.Identifier__c, false);
                    
                }
            }
        }catch(Exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'Neo Banking Eligible Email Service failed');
            insert erDetail;
        }
    }
    
    public static void createCalendlyCases(Messaging.InboundEmail email,blob attachmentBody, list<string> errorMessage){
        system.debug('email.plainTextBody=='+email.plainTextBody);
        try{
            if(email.plainTextBody != Null && email.plainTextBody != ''){
                Case csObj = New Case();
                String emailBody;
                csObj.RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('ETC Web Integration').getRecordTypeId();
                csObj.OwnerId = [Select Id From Group Where DeveloperName=:'Waiting_On_Web_Integration' AND Type='Queue'].Id;
                if(!Test.isRunningTest()){
                    emailBody = email.plainTextBody;
                }else{
                    emailBody = 'Invitee:\n Parita parikh \n Invitee Email:\n paritaparikh.it@svitvasad.ac.in<mailto:paritaparikh.it@svitvasad.ac.in>\nEvent Date/Time:\n03:00pm - Tuesday, September 8, 2020 (India, Sri Lanka Time)\n Event Attendance:\n1 of 2 spots filled\n Description:\n Please book a slot as per your convenience!\n Invitee Time Zone:\n India Standard Time\n Questions:\n MID:\n 7219875\n Developer\'s Mobile Number\n 7567974394\n Integration\n Seamless Integration on Website (Bolt Checkout)\n Issue Description:\n Need technical support';
                }
                string conName = emailBody.substringBetween('Invitee:\n', 'Invitee Email:').replaceAll('\\s+', '');
                string emailWithName = emailBody.substringBetween('Invitee Email:\n','Event Date/Time:').replaceAll('\\s+', '');
                List<String> strList = emailWithName != null && emailWithName.contains('<') ? emailWithName.split('<') : new List<String>();
                String emailId = strList.size() > 0 && strList != null ? strList[0] : emailWithName;
                system.debug('emailId=='+emailId+'===');
                List<Contact> conObjList = [Select Id,AccountId From Contact WHERE Email=: emailId LIMIT 1];
                
                if(conObjList.size() > 0 && conObjList != null){
                    csObj.ContactId = conObjList[0].Id;
                    csObj.AccountId = conObjList[0].AccountId;
                }else{
                    Account accObj = New Account(Name = conName);
                    upsert accObj;
                    Contact newConObj = New Contact(LastName = conName,Email = emailId,AccountId = accObj.Id);
                    upsert newConObj;
                    
                    csObj.AccountId = accObj.Id;
                    csObj.ContactId = newConObj.Id;
                }
                csObj.Event_Type__c = emailBody.substringBetween('Event Type:\n', 'Invitee:') != null ? emailBody.substringBetween('Event Type:\n', 'Invitee:') : csObj.Event_Type__c;
                //csObj. = email.plainTextBody.substringBetween('Invitee:\n', 'Invitee Email:');
                //csObj. = email.plainTextBody.substringBetween('Invitee Email:\n','Event Date/Time:');
                csObj.Event_DateTime__c = emailBody.substringBetween('Event Date/Time:\n', 'Event Attendance:') != null ? emailBody.substringBetween('Event Date/Time:\n', 'Event Attendance:') : null;
                //csObj. = email.plainTextBody.substringBetween('Event Attendance:\n','Description:');
                //csObj. = email.plainTextBody.substringBetween('Description:\n', 'Invitee Time Zone:');
                //csObj. = email.plainTextBody.substringBetween('Invitee Time Zone:\n', 'Questions:');
                //csObj. = email.plainTextBody.substringBetween('Questions:\n', 'MID:');
                csObj.Merchant_Id__c = emailBody.substringBetween('MID:\n', 'Developer\'s Mobile Number') != null ? emailBody.substringBetween('MID:\n', 'Developer\'s Mobile Number') : csObj.Merchant_Id__c;
                csObj.Developer_Mobile__c  = emailBody.substringBetween('Developer\'s Mobile Number\n', 'Integration') != null ? emailBody.substringBetween('Developer\'s Mobile Number\n', 'Integration') : csObj.Developer_Mobile__c;
                //csObj. = email.plainTextBody.substringBetween('Integration\n', 'Issue Description:');
                csObj.LP_Issue_description__c = emailBody.substringBetween('Issue Description:\n', 'View invitee in Calendly') != null ? emailBody.substringBetween('Issue Description:\n', 'View invitee in Calendly') : csObj.LP_Issue_description__c;
                
                upsert csObj;
            }
        }catch(Exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'Calendly Email Service Failed');
            insert erDetail;
        }
    }
    
    public static void uploadNPSData(Messaging.InboundEmail email,blob attachmentBody, list<string> errorMessage){
        try{
            if(email.binaryAttachments != null && !email.binaryAttachments.isEmpty()){
                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                    if(!Test.isRunningTest()){
                        attachmentBody = bAttachment.body;
                    }else{
                        attachmentBody = Blob.valueof(System.Label.NPSUploadTestBody);
                    }
                    
                    //===========Replace \n with whatever delineates your row============
                    Utility_RowIterator r = New Utility_RowIterator(attachmentBody.toString(),'\n'); 
                    
                    String firstRow;
                    if(r.hasNext()) firstRow = r.next();
                    
                    String headers = firstRow;                   
                    
                    string[] headerList = headers.replaceAll('\\s+', '').split(',');
                    if(headerList[1].replaceAll('\\s+', '').equalsIgnoreCase('mid') && headerList[2].equalsIgnoreCase('Email_id')
						&& headerList[3].equalsIgnoreCase('NPS_Score') && headerList[4].equalsIgnoreCase('Comment') 
                       && headerList[5].replaceAll('\\s+', '').equalsIgnoreCase('Segment')){
                           
                           GMVUploadEmailServiceBatch gmvBatch = New GMVUploadEmailServiceBatch();
                           gmvBatch.fileData = attachmentBody.toString();
                            gmvBatch.platformName = 'NPSUpload';
                           Database.executeBatch(gmvBatch);
                       }
                    else{
                        errorMessage.add('Column mismatch');
                    }
                    
                    // If error send an email
                    if(!errorMessage.isEmpty()){
                        // error email
                        Error_Details__c objErrorLog = new Error_Details__c();
                        objErrorLog.Message__c = 'Column mismatch '+errorMessage;
                        objErrorLog.Process__c = 'NPS upload Email Service failed';
                        insert objErrorLog;
                    }
                }
            }
        }catch(Exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'NPS upload Email Service failed');
            insert erDetail;
        }
    }
    
    public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }
}