public class NeoBankingCaseTriggerHandler {
	
    public static void afterUpdateHandler(List<Case> triggerNew,Map<id,Case> triggerOldMap){
        
        List<String> fieldsToCheck = (Label.nBFieldsToCheck).split(',');
        List<Case> casesToUpdate = new List<case>();
        for(Case eachCase : triggerNew){
            Case OldCase = triggerOldMap.get(eachCase.id);
            for(string field : fieldsToCheck){
                if(eachCase.get(field) != OldCase.get(field)){
                    casesToUpdate.add(eachCase);
                }
            }
        }
        if(casesToUpdate.size() > 0 && casesToUpdate != null)
            Database.executeBatch(new Batch_updateNeoBankingAccounts('neoBankingRbl'));
    }
}