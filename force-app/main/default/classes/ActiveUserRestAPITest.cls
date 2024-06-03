@isTest
private class ActiveUserRestAPITest {
    @testSetup static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User testUser = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@test.com',
            Username = 'johndoe3562643@test.com',
            Alias = 'jdoe',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
    }
    
    @isTest static void testSetActiveUserAPIWithInvalidParams() {
        // Test case where both emailId and activeStatus are missing
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"foo": "bar"}');
        RestContext.request = req;
        String result = ActiveUserRestAPI.setActiveUserAPI();
        System.assertEquals('Pass Email Id(emailId), Alias(alias) and Active Status(activeStatus) as Parameters in the request', result);
        
        // Test case where emailId is missing
        req.requestBody = Blob.valueOf('{"activeStatus": true,"alias":"jdoe"}');
        RestContext.request = req;
        result = ActiveUserRestAPI.setActiveUserAPI();
        System.assertEquals('Pass Email Id(emailId) as a Parameter in the request', result);
        
        // Test case where activeStatus is missing
        req.requestBody = Blob.valueOf('{"emailId": "johndoe@test.com","alias":"jdoe"}');
        RestContext.request = req;
        result = ActiveUserRestAPI.setActiveUserAPI();
        System.assertEquals('Pass Active Status(activeStatus) as a Parameter in the request', result);
        
        // Test case where alias is missing
        req.requestBody = Blob.valueOf('{"emailId": "johndoe@test.com","activeStatus":true}');
        RestContext.request = req;
        result = ActiveUserRestAPI.setActiveUserAPI();
        System.assertEquals('Pass Alias(alias) as a Parameter in the request', result);
    }
    
    @isTest static void testSetActiveUserAPIWithInvalidEmailId() {
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"emailId": "nonexistent@test.com", "activeStatus": true,"alias":"jdoe"}');
        RestContext.request = req;
        String result = ActiveUserRestAPI.setActiveUserAPI();
        System.assertEquals('No User record found with the passed email Id and alias', result);
    }
    
    @isTest static void testSetActiveUserAPIWithValidParams() {
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"emailId": "johndoe@test.com", "activeStatus": true,"alias":"jdoe"}');
        RestContext.request = req;
        String result = ActiveUserRestAPI.setActiveUserAPI();
        System.assertEquals('1 user record/records updated sucessfully', result);
        
        User updatedUser = [SELECT IsActive FROM User WHERE Email = 'johndoe@test.com' AND Alias = 'jdoe' LIMIT 1];
        System.assertEquals(true, updatedUser.IsActive);
        
        req.requestBody = Blob.valueOf('{"emailId": "johndoe@test.com", "activeStatus": false, "alias":"jdoe"}');
        RestContext.request = req;
        result = ActiveUserRestAPI.setActiveUserAPI();
        System.assertEquals('1 user record/records updated sucessfully', result);
        
        updatedUser = [SELECT IsActive FROM User WHERE Email = 'johndoe@test.com' AND Alias = 'jdoe' LIMIT 1];
        System.assertEquals(false, updatedUser.IsActive);
    }
}