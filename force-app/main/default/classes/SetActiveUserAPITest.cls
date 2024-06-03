@isTest
private class SetActiveUserAPITest {
    @isTest
    static void testSetActiveUserAPIWithValidData() {
        User testUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'SYSTEM ADMINISTRATOR'].Id,
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser02@example.com',
            Username = 'qwertyabcd643264@example.com',
            Alias = 'tu2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Make API call with activeStatus set to true
        String requestBody = '{"emailId": "' + testUser.Email + '", "activeStatus": true}';
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf(requestBody);
        RestContext.request = request;
        String response = ActiveUserRestAPI.setActiveUserAPI();
        
        // Verify API response
        System.assertEquals('1 user record/records updated sucessfully', response);
        User updatedUser = [SELECT Id, isActive FROM User WHERE Email = :testUser.Email];
        System.assertEquals(true, updatedUser.isActive);
        
        // Make API call with activeStatus set to false
        requestBody = '{"emailId": "' + testUser.Email + '", "activeStatus": false}';
        request.requestBody = Blob.valueOf(requestBody);
        RestContext.request = request;
        response = ActiveUserRestAPI.setActiveUserAPI();
        
        // Verify API response
        System.assertEquals('1 user record/records updated sucessfully', response);
        updatedUser = [SELECT Id, isActive FROM User WHERE Email = :testUser.Email];
        System.assertEquals(false, updatedUser.isActive);
    }
    
    @isTest
    static void testSetActiveUserAPIWithMissingEmailId() {
        // Make API call with missing emailId parameter
        String requestBody = '{"activeStatus": true}';
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf(requestBody);
        RestContext.request = request;
        String response = ActiveUserRestAPI.setActiveUserAPI();
        
        // Verify API response
        System.assertEquals('Pass Email Id(emailId) as a Parameter in the request', response);
    }
    
    @isTest
    static void testSetActiveUserAPIWithMissingActiveStatus() {
        // Create test data
        
        User testUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'SYSTEM ADMINISTRATOR'].Id,
            FirstName = 'TestUSER',
            LastName = 'User',
            Email = 'testuser01@example.com',
            Username = 'qwertyabcd643265@example.com',
            Alias = 'testuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Make API call with missing activeStatus parameter
        String requestBody = '{"emailId": "' + testUser.Email + '"}';
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf(requestBody);
        RestContext.request = request;
        String response = ActiveUserRestAPI.setActiveUserAPI();
        
        // Verify API response
        System.assertEquals('Pass Active Status(activeStatus) as a Parameter in the request', response);
    }
}