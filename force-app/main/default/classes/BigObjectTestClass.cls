/*
 * Name of the class : BigObjectTestClass
 * Author's Name     : Anas Yar Khan  
 * Created Date      : 6th Sept, 2022
 * Description       : Test class for DataMigrationToBigObjectBatch
 * Version.          : 1   
 */
@isTest
public class BigObjectTestClass {

    @testSetup
    public static void testDataSetup() {
        Payload_Log__c pl = new Payload_Log__c();
        pl.Status__c = 'SUCCESS';
        insert pl;
        //Test.setCreatedDate(pl.Id,System.today());
        
        Attachment att = new Attachment();
        att.Name = 'TestAttachment';
        att.Body = Blob.valueOf('TestAttachmentBody');
        att.ParentId = pl.Id;
        att.ContentType = 'application/pdf';
        insert att;
        
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = 'TestFile';
        cv.Title = 'TestFile.csv';
        cv.VersionData = Blob.valueOf('TestFileBody');
        insert cv;
        
        ContentVersion insertedFile = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id];
        
        ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId=pl.Id, ContentDocumentId=insertedFile.ContentDocumentId);
        insert cdl;  
        
        Intermediate_Object__c io = new Intermediate_Object__c();
        io.Record_Id__c = pl.Id;
        io.Attachments_Files_name_in_the_one_drive__c = 'TestData1,TestData2';
        insert io;
    }
    
    @isTest
    public static void testDataMigrationToBigObjectBatch() {
        Test.startTest();
        Database.executeBatch(new DataMigrationToBigObjectBatch('Payload_Log__c'),200);
        Test.stopTest();
    }
    @isTest
    public static void testDataMigrationToBigObjectBatchMonitoring() {
        Test.startTest();
        //Database.executeBatch(new DataMigrationToBigObjectBatchMonitoring('Payload_Log__c'),200);
        Test.stopTest();
    }
    @isTest
    public static void testDataMigrationToBigObjectBatchCaseNull() {
        Test.startTest();
        //Database.executeBatch(new DataMigrationToBigObjectBatchCaseNull('Payload_Log__c'),200);
        Test.stopTest();
    }
    @isTest
    public static void testDataMigrationToNewBigObjectBatch() {
       
       Test.startTest();
        //Database.executeBatch(new DataMigrationToNewBigObjectBatch('Payload_Log__c'),10);
        Test.stopTest(); 
    }
    @isTest
    public static void testBatchClassToDeleteRecords() {
        Test.startTest();
        List<Payload_Log__c> listPayloadLogs = [SELECT Id,isArchived__c FROM Payload_Log__c LIMIT 1];
        listPayloadLogs[0].isArchived__c = true;
        update listPayloadLogs;
        Database.executeBatch(new BatchClassToDeleteRecords('Payload_Log__c'),200);
        Test.stopTest();
    }
    @isTest
    public static void testSchedulerClassToDeleteRecords() {
        Test.startTest();
        List<Payload_Log__c> listPayloadLogs = [SELECT Id,isArchived__c FROM Payload_Log__c LIMIT 1];
        listPayloadLogs[0].isArchived__c = true;
        update listPayloadLogs;
        SchedulerToDeleteRecords cls = new SchedulerToDeleteRecords ('Payload_Log__c');
		System.schedule('DeleteObjectRecord'+System.now(), '0 25 5 10 * ?', cls);
        Test.stopTest();
    }
    @isTest
    public static void testSchedulerClassToMigrateRecords() {
        Test.startTest();
        List<Payload_Log__c> listPayloadLogs = [SELECT Id,isArchived__c FROM Payload_Log__c LIMIT 1];
        listPayloadLogs[0].isArchived__c = true;
        update listPayloadLogs;
        //SchedulerToMigrateRecords cls = new SchedulerToMigrateRecords ('Payload_Log__c');
		//System.schedule('MigrateObjectRecord'+System.now(), '0 25 5 10 * ?', cls);
        Test.stopTest();
    }
    
    @isTest
    public static void testBigObjectDataViewerController() {
        Test.startTest();
        BigObjectDataViewerController.getDataOnLoad();
        BigObjectDataViewerController.getRecordsFromApex('Payload Log',String.valueOf(System.today()-1),String.valueOf(System.today()+1));
        Test.stopTest();
    }
    /*
    @isTest
    public static void testAttachmentsMigrationToS3Batch() {
        Test.setMock(HttpCalloutMock.class, new S3CalloutMockTestClass());
        Test.startTest();
        Database.executeBatch(new AttachmentsMigrationToS3Batch('Payload_Log__c'),1);
        Test.stopTest();
    }
    
    @isTest
    public static void testFilesMigrationToS3Batch() {
        Test.setMock(HttpCalloutMock.class, new S3CalloutMockTestClass());
        Test.startTest();
        Database.executeBatch(new FilesMigrationToS3Batch('Payload_Log__c'),1);
        Test.stopTest();
    }*/
    
    
    
    @isTest
    public static void testAttachmentsMigrationToOneDriveBatch() {
        Test.setMock(HttpCalloutMock.class, new S3CalloutMockTestClass());
        Test.startTest();
        Database.executeBatch(new AttachmentsMigrationToOneDriveBatch('Payload_Log__c'),1);
        Test.stopTest();
    }
    
    @isTest
    public static void testFilesMigrationToOneDriveBatch() {
        Test.setMock(HttpCalloutMock.class, new S3CalloutMockTestClass());
        Test.startTest();
        Database.executeBatch(new FilesMigrationToOneDriveBatch('Payload_Log__c'),1);
        Test.stopTest();
    }
    
    @isTest
    public static void testBatchClassToDeleteFiles() {
        Test.startTest();
        //List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
		Database.executeBatch(new BatchClassToDeleteFiles('Files'),200);
        Test.stopTest();
    }
    
    @isTest
    public static void testBatchClassToUndeleteRecords() {
        Test.startTest();
        List<Payload_Log__c> listPayLoadLog = [Select id from Payload_Log__c LIMIT 1];
        delete listPayLoadLog;
        String query ='Select id from Payload_Log__c ALL ROWS';
        Database.executeBatch(new BatchClassToUndeleteRecords(query),200);
        Test.stopTest();
    }
    
    @isTest
    public static void testBatchClassToDeleteAttachments() {
        Test.startTest();
        Database.executeBatch(new BatchClassToDeleteAttachments('Payload_Log__c'),200);
        Test.stopTest();
    }
    
    @isTest
    public static void testBatchToDeleteRecordsWithAttachmentFile() {
        Test.startTest();
        Database.executeBatch(new BatchToDeleteRecordsWithAttachmentFile('Payload_Log__c'),200);
        Test.stopTest();
    }
}