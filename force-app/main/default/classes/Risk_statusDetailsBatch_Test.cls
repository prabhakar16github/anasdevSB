@isTest
public class Risk_statusDetailsBatch_Test {
    private static String enforcedId='0050p000004N8X1';
    private static String fromAddress='rahul.pandey@payu.in';
     private static FINAL String PROCESS_NAME = 'Bulk_RiskHold';
    @isTest
    static void testMismatchMIDValidation() {
        
        // 1. Create an Opportunity with a known MID.
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.Prod_Merchant_Id__c = 123456;
        opp.StageName = 'Prospecting'; // assuming this or similar is a required field
        opp.CloseDate = Date.today();  // assuming this is a required field
        insert opp;
        
               
        // 2. Provide a CSV with a MID that does not match the created Opportunity.
        String csvHeader = 'MID__c,Opportunity__c,Hold_Type__c,Current_Status__c,Risk_Hold_Reason__c,Risk_Hold_Reason_Email_Content__c,Comments_By_Enforcer__c\r\n';
        String csvData = '123454,' + opp.Id + ',,Post Hold,On Hold,R10 - Suspicious Card decline Patterns,,,"Mismatch Test"';
        Blob csvBlob = Blob.valueOf(csvHeader + csvData);
        
        // 3. Execute the batch.
        Test.startTest();
        Database.executeBatch(new Risk_statusDetailsBatch(csvBlob,'testMismatchMID.csv',enforcedId,fromAddress));
        Test.stopTest();

    }
	
    @isTest
    static void test1(){
        
         Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test Opportunity';
        opp1.Prod_Merchant_Id__c = 1897456;
        opp1.StageName = 'Prospecting'; // assuming this or similar is a required field
        opp1.CloseDate = Date.today();  // assuming this is a required field
        insert opp1;
        String str1 = 'MID__c,Opportunity__c,Hold_Type__c,Current_Status__c,Risk_Hold_Reason__c,Risk_Hold_Reason_Email_Content__c,Comments_By_Enforcer__c,Enforced_By__c\r\n';
        String str2 = '8607270,0068o000004N,,,OB Hold,On Hold,R10 - Suspicious Card decline Patterns,,,"We request you to share the following information",Test PJ  20-July Anas,0050p000004LULXAA4\r\n ';
        Blob csvBlob = Blob.valueOf(str1 + str2);
         Test.startTest();
    	Database.executeBatch(new Risk_statusDetailsBatch(csvBlob,'testfile.csv',enforcedId,fromAddress));
         Test.stopTest();
    }
    
  
    
    @isTest
    static void test3(){
         Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.Prod_Merchant_Id__c = 1234566;
        opp.StageName = 'Prospecting'; // assuming this or similar is a required field
        opp.CloseDate = Date.today();  // assuming this is a required field
        insert opp;
        
        Risk_status_Detail__c rs = new Risk_status_Detail__c();
        rs.Opportunity__c = opp.Id;
        rs.RecordTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Post Risk').getRecordTypeId();
        rs.Hold_Type__c = 'Post Hold';
        rs.Unique_Identifier__c = rs.Hold_Type__c+'@@'+rs.Opportunity__c;
        
        Schema.SObjectField externalIdField = Risk_status_Detail__c.fields.Unique_Identifier__c ;
        Database.upsertResult result = Database.upsert(rs,externalIdField,false);
        
        
        system.debug('<<<<opp.Id>>>>>'+opp.Id);
        String str1 = 'MID__c,Opportunity__c,Hold_Type__c,Current_Status__c,Risk_Hold_Reason__c,Risk_Hold_Reason_Email_Content__c,Comments_By_Enforcer__c\r\n';
        String str2 = '8600101,'+ opp.Id +',,,Post Hold,On Hold,R10 - Suspicious Card decline Patterns,,,"We request you to share the following information",Test comment row\r\n';
        Blob csvBlob = Blob.valueOf(str1 + str2);
        Test.startTest();
        Risk_statusDetailsBatch obj = new Risk_statusDetailsBatch(csvBlob,'testfile.csv',enforcedId,fromAddress);
        obj.generateErrorLogsForFailedRecods(new List<Database.upsertResult>{result},new List<Risk_status_Detail__c>{rs});
        Database.executeBatch(obj,100); 
        Test.stopTest();
        
    }
   @isTest
static void testUpsertFailureDueToUniqueConstraint() {
    // Create an opportunity
    Opportunity opp = new Opportunity();
    opp.Name = 'Error Opportunity';
    opp.Prod_Merchant_Id__c = 999999;
    opp.StageName = 'Prospecting';
    opp.CloseDate = Date.today();
    insert opp;

    // Prepare a CSV that will cause a unique constraint error
    String csvHeader = 'MID__c,Opportunity__c,UniqueField__c,Current_Status__c,Risk_Hold_Reason__c,Risk_Hold_Reason_Email_Content__c,Comments_By_Enforcer__c\r\n';
    String csvData1 = '000000,' + opp.Id + ',SAME_UNIQUE_VALUE,Post Hold,On Hold,R10 - Suspicious Card decline Patterns,,,"Error Test"';
    String csvData2 = '000001,' + opp.Id + ',SAME_UNIQUE_VALUE,Post Hold,On Hold,R10 - Suspicious Card decline Patterns,,,"Error Test"';
    
    Blob csvBlob = Blob.valueOf(csvHeader + csvData1 + csvData2);
    
    Test.startTest();
    Database.executeBatch(new Risk_statusDetailsBatch(csvBlob,'errorScenario.csv',enforcedId,fromAddress));
    Test.stopTest();

    // Assert: Query your Error_Details__c object and check if the expected error was logged
    Error_Details__c[] logs = [SELECT Id, Message__c, Response__c FROM Error_Details__c WHERE Process__c = :PROCESS_NAME];
    System.assert(logs.size() > 0, 'Expected an error log to be created for the failed upsert.');
}

    @isTest
    static void generalTest() {
        // Creating test Opportunities
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++) {
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp ' + i;
            opp.Prod_Merchant_Id__c = i;
            opp.StageName = 'Prospecting';
            opp.CloseDate = Date.today();
            opps.add(opp);
        }
        insert opps;

        // Simulating various scenarios with a mix of correct and incorrect MID values, success and errors
        String csvHeader = 'MID__c,Opportunity__c,Hold_Type__c,Current_Status__c,Risk_Hold_Reason__c,Risk_Hold_Reason_Email_Content__c,Comments_By_Enforcer__c\r\n';
        String csvData = '';

        for (Opportunity opp : opps) {
            csvData += opp.Prod_Merchant_Id__c + ',' + opp.Id + ',HoldTypeX,StatusX,ReasonX,EmailContentX,CommentX\r\n'; // expected success
            csvData += (opp.Prod_Merchant_Id__c + 100) + ',' + opp.Id + ',HoldTypeY,StatusY,ReasonY,EmailContentY,CommentY\r\n'; // expected MID mismatch
        }

        Blob csvBlob = Blob.valueOf(csvHeader + csvData);
        
        // Execute batch
        Test.startTest();
        Database.executeBatch(new Risk_statusDetailsBatch(csvBlob, 'testfile.csv', enforcedId, fromAddress));
        Test.stopTest();
        
        // Assertions
        List<Error_Details__c> logs = [SELECT Id, Message__c, Response__c FROM Error_Details__c WHERE Process__c = :PROCESS_NAME];
        System.assert(logs.size() > 0, 'Expected error logs to be created.');

        // Further assertions can be made depending on the expected outcomes
    }
    


    

   
}