@istest 
public class LazyPayConsumerUtilityTracker {
    
    public static void LoadData()
    { 
    }
    @isTest
    public static void LazyPayConsumerUtilityTrackerMethod(){
        LoadData(); 
        LazyPayConsumerUtility.encode('theParam');
    }

}