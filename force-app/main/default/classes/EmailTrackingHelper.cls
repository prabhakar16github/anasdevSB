public class EmailTrackingHelper {
    /* 
public static string getEmailAlertData(string emailAlertUniqueName){
string sessionId= UserInfo.getSessionID();
string domainUrl=URL.getSalesforceBaseUrl().toExternalForm();
system.debug('********domainUrl:'+domainUrl);
HttpRequest req = new HttpRequest();
req.setHeader('Authorization', 'Bearer ' + sessionId);
req.setHeader('Content-Type', 'application/json');
req.setEndpoint(domainUrl+'/services/data/v47.0/tooling/query/?q=select+id,SenderType,templateId, DeveloperName+from+WorkflowAlert+where+DeveloperName=\''+emailAlertUniqueName+'\'');
req.setMethod('GET');
Http h = new Http();
HttpResponse res = h.send(req);
system.debug('##### ' +res.getBody());
return res.getBody();
}

public static EmailAlertJSONParserWrapper getEmailAlertWrapper(String emailAlertData){
List<string> workflowEmailAlertIds= new List<string>();
string sessionId= UserInfo.getSessionID();
string domainUrl=URL.getSalesforceBaseUrl().toExternalForm();

JSONParser  parser = JSON.createParser(emailAlertData);
while (parser.nextToken() != null) {
if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
String fieldName = parser.getText();
parser.nextToken();
String fieldValue=parser.getText();
if(fieldName == 'Id') {
workflowEmailAlertIds.add(fieldValue);
}
}
}

HttpRequest req = new HttpRequest();
req.setHeader('Authorization', 'Bearer ' +sessionId );
req.setHeader('Content-Type', 'application/json');
req.setEndPoint(domainUrl+'/services/data/v41.0/tooling/sobjects/WorkflowAlert/'+workflowEmailAlertIds[0]); 
req.setMethod('GET');
Http h = new Http();
HttpResponse res = h.send(req);
system.debug(res.getBody());
String response=res.getBody();
response = response.replace('type', 'type_z');
response = response.replace('protected','protected_z');
response = response.replaceAll(',\r\n','\r\n');

EmailAlertJSONParserWrapper emailAlertDetails = new EmailAlertJSONParserWrapper();

emailAlertDetails =(EmailAlertJSONParserWrapper) System.JSON.deserialize(response, EmailAlertJSONParserWrapper.class);
system.debug('******emailAlertDetails:'+emailAlertDetails);
return emailAlertDetails;
}

public static string getCCEmails(EmailAlertJSONParserWrapper emailAlertDetails){
string ccEmails ='';
if(emailAlertDetails.Metadata!=null){
if(emailAlertDetails.Metadata.ccEmails.size()>0){
ccEmails = string.join(emailAlertDetails.Metadata.ccEmails,',');

}
}
return ccEmails;
}

public static string getRecipientEmails(EmailAlertJSONParserWrapper emailAlertDetails){
string recString  ='';
if(emailAlertDetails.Metadata!=null){
if(emailAlertDetails.Metadata.recipients.size()>0){
for(EmailAlertJSONParserWrapper.Recipients rec : emailAlertDetails.Metadata.recipients){
recString = recString + rec.toString();
}

}
}
return recString ;
}

public static EmailTemplate getEmailTemplateObj(EmailAlertJSONParserWrapper emailAlertDetails){
EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body from 
EmailTemplate where Id =: emailAlertDetails.TemplateId];
return emailTemplate;
}
*/
    public static Map<String,String> getPopulatedMergeFields(string messageBody, Id recordId,Id emailTrackId){
        Map<String,Set<String>> fieldMap = new Map<String,Set<String>>();
        Map<String,String> templateBodyMap = new Map<String,String>();
        String objectName = '';
        String objWithFieldName = '';
        Set<String> fieldApiSet = new Set<String>();
        List<String> fieldList = new List<String>();
        
        pattern p = Pattern.compile('\\{[!a-zA-Z0-9_\\s\\.]*\\}');
        Matcher m = p.matcher(messageBody);
        
        if(recordId != null){
            objectName = recordId.getSObjectType().getDescribe().getName();
            fieldMap.put(objectName,new Set<String>{'Id'});
        }
        
        while(m.find()){
            objWithFieldName = messageBody.substring(m.start()+2,m.end()-1);
            
            //Spliting Object API and field API
            String[] apiArry = objWithFieldName.split('\\.');
            
            if(apiArry[0] == objectName){
                
                if(fieldMap.containsKey(apiArry[0])){
                    fieldMap.get(apiArry[0]).add(apiArry[1]);
                }
                else{
                    fieldMap.put(apiArry[0],new Set<String>{apiArry[1]});
                }  
                
            }else{
                //fieldMap.get(objectName).add(objWithFieldName);
            }
        }
        
        for(Set<String> fields : fieldMap.values()){
            for(String each: fields){
                fieldList.add(each);
            }
        }
        
        String queryString = ' SELECT ' + String.join( fieldList, ',' )+' FROM '+ objectName +' WHERE Id =:recordId';
        
        Database.QueryLocator queryLocator = Database.getQueryLocator(queryString);
        Database.QueryLocatorIterator queryIterator =  queryLocator.iterator();
        
        if(messageBody.containsIgnoreCase('emailTrackingId=')){
            messageBody = messageBody.replace('emailTrackingId=', 'emailTrackingId='+emailTrackId);
        }
        
        while (queryIterator.hasNext()) {
            sObject obj = (sObject)queryIterator.next();
            
            for(String field : fieldList){
                system.debug('####### field '+field);
                
                if(obj.get(field) != null && obj.get(field) != ''){
                    messageBody = messageBody.replace('{!' + objectName + '.' + field + '}', String.valueOf(obj.get(field))).trim();
                }else{
                    messageBody = messageBody.replace('{!' + objectName + '.' + field + '}','').trim();
                }
                
                if(obj.get('id') != null){
                    templateBodyMap.put(String.valueOf(obj.get('id')),messageBody);
                }
            }
        }
        
        return templateBodyMap; 
    }
}