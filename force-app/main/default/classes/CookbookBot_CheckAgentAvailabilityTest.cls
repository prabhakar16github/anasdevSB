@isTest(SeeAllData = true)
public class CookbookBot_CheckAgentAvailabilityTest {

    @isTest
    static void testCheckAgentAvailability() {
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'Opp test',
            Email = 'sauser000@test.com',
            Username = 'sauser000@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            MobilePhone  = '9090909090',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        INSERT u;
        
       System.runAs(u){
            LiveChatTranscript oLCT = new LiveChatTranscript();
            
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());        
            
            LiveChatVisitor oLCV = [SELECT Id, Name FROM LiveChatVisitor LIMIT 1];
            LiveChatButton oLCB = [SELECT Id, DeveloperName FROM LiveChatButton LIMIT 1];
            LiveChatDeployment oLCD = [SELECT Id, DeveloperName FROM LiveChatDeployment LIMIT 1];
           
            oLCT.LiveChatButtonId = oLCB.Id;
            oLCT.LiveChatDeploymentId = oLCD.Id; 
            oLCT.ChatKey = 'TestChat123';
            oLCT.LiveChatVisitorId = oLCV.Id;
            INSERT oLCT;
            
            Test.startTest();
            // Create test data
            CookbookBot_CheckAgentAvailability.AgentAvailabilityInput input = new CookbookBot_CheckAgentAvailability.AgentAvailabilityInput();
            input.sLiveAgentSessionId = oLCT.ChatKey; 
            
            // Call the method to be tested
            List<CookbookBot_CheckAgentAvailability.AgentAvailabilityOutput> result = CookbookBot_CheckAgentAvailability.checkAgentAvailability(new List<CookbookBot_CheckAgentAvailability.AgentAvailabilityInput>{ input });
            
            // Perform assertions
            System.assertEquals(1, result.size(), 'Output list should contain one element');
            
            CookbookBot_CheckAgentAvailability.AgentAvailabilityOutput output = result[0];
            System.assert(output.bAgentTranserAvailability, 'Agent transfer availability should be true');
            
            Test.stopTest();
        }
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req){
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"messages":[{"type":"Availability", "message":{"results":[{"id":"573Bg000000SaYP","isAvailable":true}]}}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}