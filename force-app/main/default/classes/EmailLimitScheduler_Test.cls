@isTest
public class EmailLimitScheduler_Test {
    @testSetup static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User testUser = new User(
            FirstName = 'test35562',
            LastName = 'user6546',
            Email = 'testemail@payu.in',
            Username = 'testuser3562643@test.com',
            Alias = 'tu19',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
    }
	public static testMethod void testschedule() {
		Test.StartTest();
        String testEmail='testemail@payu.in';
		EmailLimitSchedulerClass testsche = new EmailLimitSchedulerClass(testEmail);
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}
}