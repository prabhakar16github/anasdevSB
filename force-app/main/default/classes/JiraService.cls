public with sharing class JiraService {
    
    private static final String CALLOUT_JIRA = 'callout:JiraBoard';

    //get JIRA Url nd base url for the LWC component
    @AuraEnabled(cacheable=true) 
    public static CaseRiskAssignment__c getJIRASettings(){
        return CaseRiskAssignment__c.getOrgDefaults();
    }

    @AuraEnabled 
    public static String createJIRA(String json, String recordId){
        CaseRiskAssignment__c jiraSetup = getJIRASettings();

        JiraWrapper payload = JiraWrapper.parseLWCRequest(json);

        //generate the payload for all the remain fields
        //generatePayload(payload);
        System.debug(logginglevel.DEBUG, payload);

        //String endPoint = jiraSetup.JIRA_Base_URL__c + jiraSetup.Jira_Create__c;
        String endPoint = CALLOUT_JIRA + jiraSetup.Jira_Create__c;
            
        //send request to create jira
        System.debug(logginglevel.DEBUG, json);
        System.debug(logginglevel.DEBUG, endPoint);
        HTTPResponse response = PayUutils.sendRequest(endPoint, json, 'POST');
        Integer statusCode = response.getStatusCode();
        System.debug(logginglevel.DEBUG,'Response '+ response);

        //If success response then get the Jira Id
        if(statusCode == 201){
            JiraWrapper.JiraResponse result = JiraWrapper.parseResponse(response.getBody());
            Case cs = new Case(Id= recordId, Jira_Number__c = result.jiraId,
                              Jira_Status__c = result.status, Assignee_Email__c = result.assignee);
            UPDATE cs;
            return result.jiraId;
        }else{
            //only for testing hardcoded
           // String jiraId = 'PSAT-1231'; //result.jiraId  (hardcoded for testing)
            //Case cs = new Case(Id= recordId, Jira_Number__c = jiraId);
            //UPDATE cs;
            // Testing end

            //further to enhance error handling logic
            System.debug(logginglevel.ERROR, response.getBody());
            throw new CustomException(response.getBody());
        }
        //return null;
    }

    /*private static void generatePayload(JiraWrapper req){
        JiraWrapper.CustomField custmField = new JiraWrapper.CustomField();
        custmField.bugCategory = 0;
        custmField.bugSource = 0;
        custmField.productTeams = 1;
        req.customField = custmField;
        req.projectKey = 'PSAT';
        req.issueTypeId = 10004;
    }*/
    
    @AuraEnabled 
    public static String getJIRAStatus(String jiraNumber, String recordId){
        CaseRiskAssignment__c jiraSetup = getJIRASettings();

        System.debug(logginglevel.DEBUG, jiraNumber);

        //String endPoint = jiraSetup.JIRA_Base_URL__c + jiraSetup.Get_Jira__c + jiraNumber;
        String endPoint = CALLOUT_JIRA + jiraSetup.Get_Jira__c + jiraNumber;
        
        
        HTTPResponse response = PayUutils.sendRequest(endPoint, null, 'GET');
        Integer statusCode = response.getStatusCode();
        System.debug(logginglevel.INFO, response);
		System.debug(logginglevel.DEBUG, response.getBody());
        //If success response then get the Jira Id
        if(statusCode == 200){
            JiraWrapper.JiraResponse result = JiraWrapper.parseResponse(response.getBody());
            Case cs = new Case(Id= recordId, 
                               Jira_Tickets_Comment__c = String.valueOf(result.comments), 
                               Subject = result.summary,
                               Description = result.description,
                               Jira_Status__c = result.status, 
                               Assignee_Email__c = result.assignee,
                               JIRA_Reporter_Email__c =result.reporter);
            UPDATE cs;
            return result.jiraId;
        }else{
            //only for testing hardcoded
            /*String jiraComment = 'Assigned to QA '+System.now(); //result.jiraId  (hardcoded for testing)
            String jiraStatus = 'Inprogress';
            String assigneeEmail = 'test@payu.in';
            Case cs = new Case(Id= recordId, Jira_Tickets_Comment__c = jiraComment, Jira_Status__c = jiraStatus, Assignee_Email__c = assigneeEmail);
            UPDATE cs;
            // Testing end*/

            //further to enhance error handling logic
            System.debug(logginglevel.ERROR, response.getBody());
            throw new CustomException(response.getBody());
        }
        //return null;
    }
	public class CustomException extends Exception {}
}