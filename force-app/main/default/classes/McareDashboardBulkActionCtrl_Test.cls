@isTest
public class McareDashboardBulkActionCtrl_Test {
    @testsetup
    static void testSetupMethod(){
        MCare_Dashboard_Case__c mcare = new MCare_Dashboard_Case__c();
        mcare.Status__c = 'New';
        mcare.Comments__c = 'test comment';
        insert mcare;
    }
	@isTest
    static void test1(){
        List<MCare_Dashboard_Case__c> mcareRecordList = [SELECT Id,Name,Status__c,Merchant_Id__c,Risk_Hold_Reason__c,Comments__c
                                    FROM MCare_Dashboard_Case__c LIMIT 1];
        if(!mcareRecordList.isEmpty()){
            McareDashboardBulkActionCtrl.getMcareRecords(mcareRecordList[0].Id);
            McareDashboardBulkActionCtrl.updateMcareRecords(mcareRecordList[0].Id,mcareRecordList[0].Status__c,mcareRecordList[0].Risk_Hold_Reason__c,mcareRecordList[0].Comments__c);
            McareDashboardBulkActionCtrl.deleteMcareRecords(mcareRecordList[0].Id);
            McareDashboardBulkActionCtrl.getPickListWrapper();
        }
        
    }
}