public class testLiveChatTRans {
    
    public static void show(string str)
    {
        
        List<Opportunity> transcriptRecord = [SELECT Name,Settlement_Status__c ,Legal_Name_Account__c,Risk_Hold_Reason_Email_Content__c  FROM Opportunity WHERE Prod_MID__c=: str];
         
                //List<LiveChatTranscript> transcriptRecord = [SELECT Name,FirstName__c,Product__c,MID__c,pageName__c,MSAT__c, CreatedDate
                                               //FROM LiveChatTranscript
                                              // ORDER BY CreatedDate DESC
                                               //              LIMIT 10
                                               //];
         for(Opportunity opp : transcriptRecord)
          {
              System.debug(opp);
         }

    }
    
}