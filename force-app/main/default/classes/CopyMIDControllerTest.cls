@isTest
private class CopyMIDControllerTest {
    @isTest
    static void testCopyMIDHelper() {
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Open',CloseDate=System.Today()+10);
        insert opp;
        Opportunity opp2 = new Opportunity(Name = 'Test Opportunity2', StageName = 'Open',CloseDate=System.Today()+10);
        insert opp2;
        Product_Account_Detail__c padRec = new Product_Account_Detail__c(Opportunity__c = opp.Id);
        insert padRec;
        padRec.Copy_MID_Status__c = 'Initiated';
        update padRec;
        Integer result1 = CopyMIDController.CopyMIDHelper(opp.Id);
        System.assertEquals(1, result1, 'Expected return value 1 when CopyMID_Status__c is already Initiated');
        padRec.Copy_MID_Status__c = 'Completed';
        update padRec;
        Integer result2 = CopyMIDController.CopyMIDHelper(opp.Id);
        System.assertEquals(0, result2, 'Expected return value 0 when CopyMID_Status__c is not Initiated');
        Integer result3 = CopyMIDController.CopyMIDHelper(opp2.Id);
        System.assertEquals(0, result3, 'Expected return value 0 when CopyMID_Status__c is not Initiated');
        /*Product_Account_Detail__c updatedPadRec = [SELECT Copy_MID_Status__c, Copy_MID_Identifier__c FROM Product_Account_Detail__c WHERE Id = :padRec.Id];
        System.assertNotEquals(null, updatedPadRec.Copy_MID_Status__c, 'Copy_MID_Status__c should not be null');
        System.assertEquals('Initiated', updatedPadRec.Copy_MID_Status__c, 'Copy_MID_Status__c should be Initiated');
        System.assertNotEquals(null, updatedPadRec.Copy_MID_Identifier__c, 'Copy_MID_Identifier__c should not be null');*/
    }
}