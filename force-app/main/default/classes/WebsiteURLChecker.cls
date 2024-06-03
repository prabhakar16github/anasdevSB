public class WebsiteURLChecker implements Queueable, Database.AllowsCallouts {
    
    Set<Id> OptyIdsList = new Set<Id>();
    String status = '';
    List<Website_Page_Master__c> wpmList = New List<Website_Page_Master__c>();
    
    public WebsiteURLChecker(Set<Id> OptyIdsList, String status, List<Website_Page_Master__c> wpmList){
        this.OptyIdsList = OptyIdsList;
        this.status = status;
        this.wpmList = wpmList;
    }
    
    public void execute(QueueableContext context){
        checkWebsiteLiveStatus(this.OptyIdsList, this.status, this.wpmList);
    }
    
    public static String getAuthorisationToken(){
        Http http = new Http();
        HttpResponse resp = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndPoint(Label.URLCheckerAuthToken);
        if(!test.isRunningTest())	resp = http.send(req);
        
        if(resp.getBody() != null && !String.isBlank(String.valueOf(resp.getBody()))){
            map<string,Object> mapOfResponse = (map<string,Object>)JSON.deserializeUntyped(resp.getBody());
        	return String.ValueOf(mapOfResponse.get('access_token'));
        }else	return null;
    }
    
    //@future(callout=true)
    public static void checkWebsiteLiveStatus(Set<Id> OptyIdsList, String status, List<Website_Page_Master__c> wpmList){
        system.debug('-->> status check Live '+status);
        String authToken = getAuthorisationToken();
        String endpt = Label.URLCheckerEndpoint;
        string finalEndPoint = '';
        List<Website_Page__c> webPageInserted = New List<Website_Page__c>();
        List<Website_Page__c> webPagesToInsert = New List<Website_Page__c>();
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //List<Website_Page_Master__c> wpmList = [SELECT Id, Name, Active__c, Page_Details__c FROM Website_Page_Master__c WHERE Active__c = true];
        
        if(test.isRunningTest())	authToken = 'test Authorization token';
        
        /*for(Opportunity opty: [SELECT Id, Name, Website_Status__c, Integration_Type__c, Website__c, Android_URL__c, iOS_URL__c, AccountId
                               FROM Opportunity WHERE Id IN :OptyIdsList]){*/
        List<Opportunity> opty= [SELECT Id, Name, Website_Status__c, Integration_Type__c, Website__c, Android_URL__c, iOS_URL__c, AccountId
                                 FROM Opportunity WHERE Id IN :OptyIdsList];
                                  /* if(string.isNotBlank(opty.Website__c)) finalEndPoint = endpt+opty.Website__c;
                                   else if(string.isNotBlank(opty.Android_URL__c)) finalEndPoint = endpt+opty.Android_URL__c;
                                   else if(string.isNotBlank(opty.iOS_URL__c)) finalEndPoint = endpt+opty.iOS_URL__c;
                                   //String endPoint = finalEndPoint;
                                   if(!String.isBlank(authToken)){
                                       Http http = new Http();
                                       HttpResponse resp = new HttpResponse();
                                       HttpRequest req = new HttpRequest();
                                       req.setMethod('GET');
                                       req.setTimeout(120000);
                                       req.setHeader('Authorization', 'Bearer '+authToken);
                                       req.setEndPoint(finalEndPoint);
                                       system.debug('-->> endpoint '+finalEndPoint);
                                       if(!test.isRunningTest())	resp = http.send(req);
                                       system.debug('-->> webste status response '+resp);
                                       if(resp.getStatusCode() == 200){
                                           	    system.debug('-->> status 200');
                                                //webPageInserted = WebsitePageTriggerHelper.createWebsitePageAfterOppInsert(opty,wpmList,status);
                                           		opty.Website_Remarks__c = Label.Website_Found_Live;
                                           		opty.Website_Status__c = 'Website OK';
                                           		opty.Risk_Level__c = 'High-Auto Approved';
                                           		//opportunities.add(opty);
                                           		//webPagesToInsert.addAll(webPageInserted);
                                       }else{
                                           //webPageInserted = WebsitePageTriggerHelper.createWebsitePageAfterOppInsert(opty,wpmList,'Pending');
                                           opty.Website_Remarks__c = Label.Website_Not_found_Live;
                                           //opportunities.add(opty);
                                           //webPagesToInsert.addAll(webPageInserted);
                                       }
                                       opportunities.add(opty);
                                   }
                               }
        //if(!webPageInserted.isEmpty()) insert webPageInserted;
        if(!opportunities.isEmpty())	update opportunities;*/
        if(string.isNotBlank(opty[0].Website__c)) finalEndPoint = endpt+opty[0].Website__c;
        else if(string.isNotBlank(opty[0].Android_URL__c)) finalEndPoint = endpt+opty[0].Android_URL__c;
        else if(string.isNotBlank(opty[0].iOS_URL__c)) finalEndPoint = endpt+opty[0].iOS_URL__c;
        //String endPoint = finalEndPoint;
        if(!String.isBlank(authToken)){
            Http http = new Http();
            HttpResponse resp = new HttpResponse();
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setTimeout(120000);
            req.setHeader('Authorization', 'Bearer '+authToken);
            req.setEndPoint(finalEndPoint);
            system.debug('-->> endpoint '+finalEndPoint);
            if(!test.isRunningTest())	resp = http.send(req);
            system.debug('-->> webste status response '+resp);
            if(resp.getStatusCode() == 200){
                system.debug('-->> status 200');
                //webPageInserted = WebsitePageTriggerHelper.createWebsitePageAfterOppInsert(opty,wpmList,status);
                opty[0].Website_Remarks__c = Label.Website_Found_Live;
                opty[0].Website_Status__c = 'Website OK';
                opty[0].Risk_Level__c = 'High-Auto Approved';
                //opportunities.add(opty);
                //webPagesToInsert.addAll(webPageInserted);
            }else{
                //webPageInserted = WebsitePageTriggerHelper.createWebsitePageAfterOppInsert(opty,wpmList,'Pending');
                opty[0].Website_Remarks__c = Label.Website_Not_found_Live;
                //opportunities.add(opty);
                //webPagesToInsert.addAll(webPageInserted);
            }
            update opty[0];
        }
    }
}