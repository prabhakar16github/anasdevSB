@isTest
public class LookupControllerTracker {
    
    public static testMethod void testLookupController(){
        
        test.startTest();
        LookupController.fetchRecords('User','Name','Sneha Sahi','');
        test.stopTest();
        
    }
    
    public static testMethod void testLookupControllerErr(){
        
        test.startTest();
        try{
            LookupController.fetchRecords('User','Name',null,'');
        }
       catch(Exception e){
            system.debug('###### '+e.getMessage());
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Script-thrown exception')) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        test.stopTest();
        
    }
}