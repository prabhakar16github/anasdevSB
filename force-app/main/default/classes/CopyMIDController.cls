/**
* @Name         CopyMIDController 
* @Author       Saksham Rohilla
* @Description  Class to upsert Copy MID details in Product Account Detail on click of COPY MID button
**/
public class CopyMIDController {
    @AuraEnabled
    public static Integer CopyMIDHelper(String oppId){
        System.debug('****OppId is ****'+oppId);
        Product_Account_Detail__c obj;
        List<Product_Account_Detail__c> padRecs= [SELECT Id, Copy_MID_Identifier__c, Copy_MID_Status__c  FROM Product_Account_Detail__c where Opportunity__c=:oppId LIMIT 1];
        if(padRecs.size() > 0) {
            obj = padRecs[0];
        } else {
            obj = new Product_Account_Detail__c(Opportunity__c = oppId);
            insert obj;
        }
        if(obj.Copy_MID_Status__c != null && obj.Copy_MID_Status__c == 'Initiated'){
                return 1;
            }
        else{
            System.debug('Before ******'+obj.Copy_MID_Status__c);
            obj.Copy_MID_Identifier__c = oppId+'@'+System.now();
            obj.Copy_MID_Status__c = 'Initiated';
            update obj;
            System.debug('After ******'+obj.Copy_MID_Status__c); 
            return 0;
        }
        
    }

}