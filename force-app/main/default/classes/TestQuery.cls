public class TestQuery {
    
    public static void desiredQuery()
    {
         List<LiveChatTranscript> listscript = new List<LiveChatTranscript>();
         listscript = [SELECT Name,FirstName__c,Product__c,MID__c,pageName__c,MSAT__c
                                                FROM LiveChatTranscript order by CreatedDate desc limit 1];
        FOR(LiveChatTranscript script : listscript)
        {
            System.debug(script);
        }

    }

}