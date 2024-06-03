@isTest
public class SendInformationToLazyPayTracker {

    @isTest
    public static void unitTest1(){

            List<Contact> newList = new List<Contact>();
            Map<Id,Contact> oldMap = new Map<Id,Contact>();
            
            // Create Case
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();    
            Case caseObj = new Case();
            caseObj.recordTypeId = recordTypeId ;
            //caseObj.LP_UUID__c = ocontact.Identifier__c ;
            
            insert caseObj;  
            
            Contact oContact=new contact();
            oContact.LastName='test';
            oContact.MobilePhone = '9988776655';
            oContact.LP_Pin_Code__c = '123222';
            oContact.Identifier__c = caseObj.LP_UUID__c;
            oContact.LP_ADDRESSLINE1_On_Passport__c=  'Passport Test';
            oContact.LP_ADDRESSLINE1_DL__c = 'DL Test';
            oContact.LP_ADDRESSLINE1_On_VoterId__c = 'VoterId Test';
            oContact.LP_ADDRESSLINE1_On_Aadhar__c = 'Aadhar Test';
            insert oContact;
            newList.add(oContact);
            
            
            system.assertNotEquals(oContact.Id, null);
            Contact objContact = [SELECT id,lastname , LP_ADDRESSLINE1_On_Aadhar__c,LP_PINCODE_On_Aadhar__c,LP_Name_On_Aadhar__c,LP_DOB_On_Aadhar__c,LP_Gender_On_Aadhar__c,LP_Aadhar_Number__c,LP_DL_Number__c,LP_ADDRESSLINE1_DL__c,LP_PINCODE_On_DL__c,LP_DOB_On_DL__c,LP_Gender_On_DL__c,LP_NAME_On_DL__c,LP_Passport_Number__c,LP_ADDRESSLINE1_On_Passport__c,LP_PINCODE_On_Passport__c,LP_DOB_On_Passport__c,LP_Gender_On_Passport__c,LP_NAME_On_Passport__c,LP_Voter_Id_Number__c,LP_ADDRESSLINE1_On_VoterId__c,LP_PINCODE_On_VoterId__c,LP_DOB_On_Voter_Id__c,LP_Gender_On_Voter_Id__c,LP_NAME_On_Voter_Id__c   FROM Contact limit 1];
            objContact.lastname = 'test1';
            objContact.LP_Pin_Code__c = '12345';
            objContact.LP_ADDRESSLINE1_On_Passport__c=  'Passport Test 2';
            objContact.LP_ADDRESSLINE1_DL__c = 'DL Test 2';
            objContact.LP_ADDRESSLINE1_On_VoterId__c = 'VoterId Test 2';
            objContact.LP_ADDRESSLINE1_On_Aadhar__c = 'Aadhar Test 2';
            update objContact ;
            oldMap.put(objContact.Id,objContact );
            

            
            SendInformationToLazyPay.sendContactInfoToLazyPay(newList , oldMap);
    }
}