public class ChangeCaseStatus {
    public ApexPages.StandardSetController setCon;
    public list<selectoption> caseProblemArea {get 
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get('Case') ;
        Schema.DescribeSObjectResult sObjectTypeResult = sObjectType.getDescribe() ;
        Map<String,Schema.SObjectField> sObjectTypeFields = sObjectTypeResult.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = sObjectTypeFields.get('Problem_area_ETC__c').getDescribe();
        List<Schema.PicklistEntry> plEntry = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : plEntry){
            options.add(new SelectOption(pickListVal.getLabel(), pickListVal.getValue()));
        }          
        return options;           
    }
                                               private set;
                                              }
    
    public list<selectoption> caseDetails {get 
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get('Case') ;
        Schema.DescribeSObjectResult sObjectTypeResult = sObjectType.getDescribe() ;
        Map<String,Schema.SObjectField> sObjectTypeFields = sObjectTypeResult.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = sObjectTypeFields.get('Details_ETC__c').getDescribe();
        List<Schema.PicklistEntry> plEntry = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : plEntry){
            options.add(new SelectOption(pickListVal.getLabel(), pickListVal.getValue()));
        }          
        return options;           
    }
                                           private set;}
    
    public ChangeCaseStatus(ApexPages.StandardSetController controller) {
        setCon = controller;  
    }
    public integer getMySelectedSize() {
        
        return setCon.getSelected().size();
    }
    public list<case> caselst{get;set;}
        
    public list<selectoption> getcasestatus(){
        list<selectoption>selectopt = new list<selectoption>();
        selectopt.add(new selectoption('Resolved','Resolved'));
        return selectopt;
    }
    
    public List<Case> getSelectedCase(){
        List<Case> selectedCase = New List<Case>();
        
        List<Case> Case1= [Select ID,AccountId,status,Comments from Case where Id IN:setCon.getSelected()];
        
        for(Case cs : Case1)
        {
            selectedCase.add(cs);
        }
        return selectedCase;
    }
    
    @AuraEnabled
    public static List<String> getCaseStatus(string sObjectName,string field){
        if(String.isNotBlank(sObjectName) && String.isNotBlank(field)){
            List<String> pickListValuesList= new List<String>();
            Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(field).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            } 
            System.debug(pickListValuesList);
            return pickListValuesList;
        }else
            return null;
        
    }
}