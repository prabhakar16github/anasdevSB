public inherited sharing class EmailUtility {
    public static Messaging.SingleEmailMessage createSingleEmailMessageForInternalUser(String subject, String body, OrgWideEmailAddress owa, Id targetObjectId, List<String> toEmailAddresses){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSubject(subject);
        message.setPlainTextBody(body);
        message.setTargetObjectId(targetObjectId);
        message.setSaveAsActivity(false);

        // Set org wide email address 
        if(owa!=null){
            message.setOrgWideEmailAddressId(owa.Id);
        }

        if(toEmailAddresses != null && !toEmailAddresses.isEmpty()){
            message.setToAddresses(toEmailAddresses);
        }
        return message;
    }

    public static String getUserId(String email){
        List<User> userList = [SELECT Id,Name,Email FROM User WHERE Email =:email AND IsActive = true];

        if(!userList.isEmpty()){
            return userList[0].Id;
        }
        return NULL;
    }
}