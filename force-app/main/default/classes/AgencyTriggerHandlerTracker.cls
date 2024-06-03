/**
@author:            Surender Kumar
@company:           SaaSFocus
@description:       cover AgencyTriggerHandler
@history
<Date>        <Authors Name>        
11-Sep-19     Surender Kumar          
**/
@isTest(seealldata=false)
public class AgencyTriggerHandlerTracker {
    
    
    public static Trigger_Switch__c osetting;
    public static Agency__c oAgency;

    
    public static void LoadData()
    {
       
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Agency__c';
        insert osetting;
        
        
        oAgency=new Agency__c();
        oAgency.Name='test';
      
        insert oAgency;
        

        
        
    }
    
    @isTest
    public static void validateVerifiedTest(){
        LoadData();
        
    }  
    
}