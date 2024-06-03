@isTest
public class consmrbatchSchTest {
    static testMethod void unitTest1() {
    
        Test.starttest();
        Test.setMock(HttpCalloutMock.class, new XMLMockClass());
        Database.executeBatch(new AWSConsumerBatch());
        
        for ( AsyncApexJob aJob : [ Select id ,Status, ApexClass.Name 
                                      from AsyncApexJob 
                                      where Status!='Aborted' 
                                      and Status!='Completed' ] ){

              System.AbortJob(aJob.Id);
        
        }
        consmrbatchSch.validateJob('AWSConsumerBatch', 'test@gmail.com');
        
        String CRON_EXP = '0 0 * * * ?';
        String jobId = System.schedule('consmrbatchSchTest', CRON_EXP, new consmrbatchSch());
        
        Test.stoptest();
        
    }
}