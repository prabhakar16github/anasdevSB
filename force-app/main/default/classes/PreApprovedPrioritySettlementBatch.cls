/**
* @Name         :   PreApprovedPrioritySettlementBatch 
* @Author       :   Prabhakar Joshi
* @Created Date :   21-Mar-2023
* @Group        :   Settlement Approval
* @Description  :   This is a batch class to update the Merchant as prequalified and calculate the Approved Limit for Priority Settlement and generate the csv.
*/
public class PreApprovedPrioritySettlementBatch implements Database.Batchable<sObject>,Database.Stateful{ 
    public List<Opportunity> oppList = new List<Opportunity>();
    
    private static FINAL Date SIX_MONTH_OLD_Date = System.today().addMonths(-6); /** 6 month old date for Tools */
    private static FINAL Date THREE_MONTH_OLD_Date = System.today().addMonths(-3); /** 3 month old date for other than Tools */
    private static FINAL String INT_TYPE_VALUE_TOOLS = 'Tools'; /** Integration type value - Tools */
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Id,CTS__c,First_Txn_date__c,Last_3_months_GMV__c,Last_6_months_GMV__c,Priority_Settlement_Pre_Approved_Limit__c,Pre_Approved_for_priority_settlement__c,Integration_Type__c FROM Opportunity WHERE ';
        query += 'Integration_Type__c != NULL AND CTS__c != NULL Order By Integration_Type__c ';
        
        /** added for dev testing 
        String oppId = '0060p000009Gw54AAC'; 
        query += 'AND Id = :oppId Limit 1';
        /** */
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){ 
        Savepoint sp = Database.setSavepoint();
        try {
            for(sobject s : scope){
                Opportunity opp = (Opportunity)s;
                
                Boolean isValidOpp = validForPreApprovedLimit(opp);
                if(isValidOpp != NULL){
                    if(isValidOpp){
                        opp.Pre_Approved_for_priority_settlement__c = TRUE;
                        opp.Priority_Settlement_Pre_Approved_Limit__c = opp.Last_3_months_GMV__c != NULL ? (opp.Integration_Type__c.equals(INT_TYPE_VALUE_TOOLS) ? opp.Last_3_months_GMV__c/3 : 2 * (opp.Last_3_months_GMV__c/3)) : 0;
                        oppList.add(opp);
                        
                    }else{
                        opp.Pre_Approved_for_priority_settlement__c = FALSE;
                        opp.Priority_Settlement_Pre_Approved_Limit__c = 0;
                        oppList.add(opp);
                    }
                }
            }
        }catch(Exception e) {
            Database.rollback(sp);
            Error_Details__c errorDetails = new Error_Details__c(Process__c = 'PreApprovedPrioritySettlementBatch',Message__c = e.getMessage(),Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;
        }
    }
    public void finish(Database.BatchableContext BC){
        if(!oppList.isEmpty()){
            String generatedCSVFile ='Id,Pre_Approved_for_priority_settlement__c,Priority_Settlement_Pre_Approved_Limit__c'+'\n';
            for(Opportunity opp: oppList){
                String fileRow = '';
                fileRow = fileRow +','+ opp.Id;
                fileRow = fileRow +','+ opp.Pre_Approved_for_priority_settlement__c;
                fileRow = fileRow +','+ opp.Priority_Settlement_Pre_Approved_Limit__c;
                fileRow = fileRow.replaceFirst(',','');
                generatedCSVFile = generatedCSVFile + fileRow + '\n';
            }
            sendFileInAttachment(generatedCSVFile);
        }
    }
    
    /** 
    * Privte Method to send the email to the current user with csv attachment with all rows of merchants that needs to update for preApproved priority settlement .
    * @param - csv file row content.
    * */
    private void sendFileInAttachment(String csvFileStr){
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        Blob csvBlob = blob.valueOf(csvFileStr);
        String csvName = 'Pre-approvedPriority.csv';
            csvAttachment.setFileName(csvName);
        csvAttachment.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(UserInfo.getUserId());
        email.setSaveAsActivity(false);
        String subject = 'Monthly Pre Approved limit for Priority Settlement Notification';
        email.setSubject(subject);
        
        email.setPlainTextBody('Find the CSV file attached for Merchant update from dataloader ');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
    
    /** 
    * Privte Method to validate Merchant for PreApproved Settlement
    * @param - Opportunity object to validate the record.
    * */
    private Boolean validForPreApprovedLimit(Opportunity opp){
        
        if(
        (
        opp.CTS__c >= 1  /** Checking CTS */
        || opp.Last_6_months_GMV__c <= 0 /** Checking Last 6 Month GMV*/
        || (opp.Integration_Type__c.equals(INT_TYPE_VALUE_TOOLS) && opp.First_Txn_date__c < SIX_MONTH_OLD_Date) /** Checking Vintage for Tools */
        || (!opp.Integration_Type__c.equals(INT_TYPE_VALUE_TOOLS) && opp.First_Txn_date__c < THREE_MONTH_OLD_Date)/** Checking Vintage for other than Tools */
        ) 
        //&& opp.Pre_Approved_for_priority_settlement__c 
        ){
            
            return FALSE;
            
        }else if(
        opp.CTS__c < 1 /** Checking CTS */
        && opp.Last_6_months_GMV__c > 0 /** Checking Last 6 Month GMV*/
        && ( 
        (opp.Integration_Type__c.equals(INT_TYPE_VALUE_TOOLS) && opp.First_Txn_date__c >= SIX_MONTH_OLD_Date) /** Checking Vintage for Tools */
        ||(!opp.Integration_Type__c.equals(INT_TYPE_VALUE_TOOLS) && opp.First_Txn_date__c >= THREE_MONTH_OLD_Date) /** Checking Vintage for other than Tools */
        )
        ){
            
            return TRUE;
        }
        return NULL;
    }/** END */
}/** END */