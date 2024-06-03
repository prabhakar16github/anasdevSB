/*
* Name of the class : ActiveUserRestAPI
* Author's Name     : Saksham & Rahul  
* Created Date      : 22th Feb, 2023
* Description       : API Controller to enable user mark as Active or Inactive based on the email Id and alias
* Version.          : 1   
*/ 
@RestResource(urlMapping='/setActiveUserAPI/*')
global class ActiveUserRestAPI {
    /*
    * Name of the class : setActiveUserAPI
    * Description       : This is the POST method 
    * Version.          : 1   
    */ 
    @HttpPost
    global static String setActiveUserAPI(){
        try {
            RestRequest req = RestContext.request;
            String jsonBody = req.requestBody.toString();
            RequestWrapper requestWrapper=((RequestWrapper) JSON.deserialize(jsonBody,RequestWrapper.class));
            if(requestWrapper.activeStatus == null && requestWrapper.emailId == null && requestWrapper.alias == null){
                return 'Pass Email Id(emailId), Alias(alias) and Active Status(activeStatus) as Parameters in the request';
            }
            else if(requestWrapper.activeStatus == null && requestWrapper.alias == null) {
                return 'Pass ActiveStatus(activeStatus) and Alias(alias) as Parameters in the request';
            }
            else if(requestWrapper.activeStatus == null && requestWrapper.emailId == null) {
                return 'Pass Active Status(activeStatus) and Email Id(emailId) as Parameters in the request';
            }
            else if(requestWrapper.alias == null && requestWrapper.emailId == null) {
                return 'Pass Alias(alias) and Email ID(emailId) as Parameters in the request';
            }
            else if(requestWrapper.emailId == null || requestWrapper.emailId.length()==0) {
                return 'Pass Email Id(emailId) as a Parameter in the request';
            }
            else if(requestWrapper.activeStatus == null) {
                return 'Pass Active Status(activeStatus) as a Parameter in the request';
            }
            else if(requestWrapper.alias == null || requestWrapper.alias.length() ==0 ) {
                return 'Pass Alias(alias) as a Parameter in the request';
            }
            
            List<User> listUsers = [SELECT Id,Alias,isActive FROM User WHERE Email = :requestWrapper.emailId AND Alias = :requestWrapper.alias];
            if(listUsers != NULL && listUsers.size() > 0) {
                for(User usr : listUsers) {
                    usr.isActive = requestWrapper.activeStatus;
                }
                update listUsers;
                return String.valueOf(listUsers.size()) + ' user record/records updated sucessfully';
            }
            else {
                return 'No User record found with the passed email Id and alias';
            }    
        }
        catch(exception e) {
            return e.getMessage();
        }        
    }
    
    //Wrapper class to parse the request
    global class RequestWrapper {
        public String emailId;
        public Boolean activeStatus;
        public String alias;
    }
}