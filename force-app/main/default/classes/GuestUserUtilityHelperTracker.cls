@isTest
public class GuestUserUtilityHelperTracker {
    
    @isTest
    public static void testUpdateSingleRecord(){
        
        Account acc = new Account();
        acc.Name = 'test';
        
        test.startTest();
        GuestUserUtilityHelper.updateObject(acc);
        test.stopTest();
        
    }

    
    @isTest
    public static void testUpdateListRecord(){
        
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'test';
        
        Account acc1 = new Account();
        acc1.Name = 'test1';
        
        accList.add(acc);
        accList.add(acc1);
        
        test.startTest();
        GuestUserUtilityHelper.upsertSObjectList(accList);
        test.stopTest();
        
    }
    
    @isTest
    public static void testQueryRecord(){
        
        String mobile = '9999999999';
        
        test.startTest();
        List<Lead> leadList = GuestUserUtilityHelper.querySobject('Lead','mobilePhone = \''+ mobile + '\''+ ' And IsConverted = false order by lastmodifieddate desc limit 10');
        test.stopTest();
        
    }


}