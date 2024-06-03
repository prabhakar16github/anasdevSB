/*
 * Name of the class : EmailLimitSchedulerClass
 * Author's Name     : Rahul Pandey & Saksham Rohila 
 * Created Date      : 24th March, 2023
 * Description       : Scheduler class to send email to Salesforce team 
 * 					   with the count of remaining email messages in the org
 * Version.          : 1   
 */ 
public class EmailLimitSchedulerClass implements Schedulable {
    //------Member variable declaration--------
    public String email = '';
    //------Member variable declaration | End--------
    
    //------Constructor------------------
    public EmailLimitSchedulerClass(String email) {
    	this.email = email;    
    }
    //------Constructor | End------------------
    
    //-----------------Execute Method-----------
    public void execute(SchedulableContext sc) {
        // Get the available limit for email messages
        Map<String,System.OrgLimit> limitsMap=new Map<String,System.OrgLimit>();
        System.OrgLimit emailLimit;
        Integer remainingLimit=0,usedLimit=0,totalLimit=0;
        if(!test.isRunningTest()) {
            limitsMap = OrgLimits.getMap();
        	emailLimit = limitsMap.get('SingleEmail');
            remainingLimit = emailLimit.getLimit() - emailLimit.getValue();
            usedLimit = emailLimit.getValue();
            totalLimit = emailLimit.getLimit();
        }
        else {
            remainingLimit=100;
            usedLimit=0;
            totalLimit=100;
        }
        // SOQL for emails where created date=today
        Integer numEmailsToday=0;
        AggregateResult[] aggResultToday = [SELECT Count(Id) cntId,Parent.RecordType.Name parentCategory FROM EmailMessage WHERE CreatedDate = Today AND Incoming = false GROUP BY Parent.RecordType.Name];
        
        // SOQL for emails where datetime > 5:30 am of yesterday
        Date yesterday = System.today()-1;
        Integer year = yesterday.year();
        Integer month = yesterday.month();
        Integer day = yesterday.day();
    	Datetime dt = Datetime.newInstance(year,month,day,5,30,0);
        System.debug('dt-->'+dt);
        Integer numEmailsYesterday=0;
        AggregateResult[] aggResultYesterday = [SELECT Count(Id) cntId,Parent.RecordType.Name parentCategory FROM EmailMessage WHERE CreatedDate >:dt AND Incoming = false GROUP BY Parent.RecordType.Name];
        
        // Create the email message to be sent
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<User> listUser = [SELECT Id FROM User WHERE email= :email];
        if(listUser != NULL && listUser.size() > 0) {
			mail.setTargetObjectId(listUser[0].Id);  
            mail.setSubject('Email Usage Status');
            mail.saveAsActivity = false;
            // Body of email
            String body='';
            // org limits parameters
            body += 'From Org Limits '+'<br>';
            body += 'Total email limit :--> ' + totalLimit + '<br>';
            body += 'Email limit remaining :--> '+ remainingLimit + '<br>';
            body += 'Used limit :--> ' + usedLimit + '<br><br>';
            // SOQL query result
            body += 'From SOQL Query '+'<br><br>';
            body += '<table border="1" style="border-collapse:collapse, width:100%"><caption><b>Category wise count with CreatedDate = TODAY</caption><tr><th>Parent Record Type</b></th><th>Count</th></tr>';
            for (AggregateResult ar : aggResultToday)  {
                	Integer countToday = (Integer)(ar.get('cntId'));
                	numEmailsToday += countToday;
                	body += '<tr><td>' + ar.get('parentCategory') + '</td><td>' + countToday + '</td></tr>';
			}
            body += '</table><br>';
      		body += 'Total emails with CreatedDate = TODAY :--> '+ numEmailsToday+'<br><br>';
            body += '<table border="1" style="border-collapse: collapse,width:100%"><caption><b>Category wise count with CreatedDate > 5:30 AM of Yesterday</b></caption><tr><th>Parent Record Type</th><th>Count</th></tr>';
            for (AggregateResult ar : aggResultYesterday)  {
                	Integer countYesterday = (Integer)ar.get('cntId');
                	numEmailsYesterday += countYesterday;
                	body += '<tr><td>' + ar.get('parentCategory') + '</td><td>' + countYesterday + '</td></tr>';
			}
            body += '</table>';
            body += '<br>' + 'Total emails with CreatedDate > 5:30 AM of Yesterday :--> ' + numEmailsYesterday+'<br>';
            mail.setHTMLBody(body);
            // Send the email message
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
		}  
    }
    //-----------------Execute Method | End-----------
}