/*
* Name of the class : UltimateBeneficiaryOwnerTrigHandler
* Author's Name     : Kunal Raj  
* Description       : UBO Flow configuration on Salesforce
*/ 
public class UltimateBeneficiaryOwnerTrigHandler {
    public static void beforeInsertHandler(List<Ultimate_Beneficiary_Owner_UBO__c> triggerNew){ 
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Ultimate_Beneficiary_Owner_UBO__c');
        List<AggregateResult> aggResults = [SELECT SUM(Ownership_num__c) sumOwnership FROM Ultimate_Beneficiary_Owner_UBO__c WHERE Merchant_UUID__c =: triggerNew[0].Merchant_UUID__c];
        Decimal totalOwnership = 0;
        Decimal newOwnership = 0;
        if(aggResults != null && aggResults.size()>0){
                totalOwnership = (Decimal)aggResults[0].get('sumOwnership');
            }
        for(Ultimate_Beneficiary_Owner_UBO__c each : TriggerNew){  
            
            //SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj); 
            SystemUtility.getIdentifierUUID(each, 'UUID__c', enableUUIDObj); 
            if(each.uuid__c != null && each.Identifier__c == null) {
                each.Identifier__c = each.uuid__c;
            }
            if(each.Ownership_num__c != null){
                newOwnership += each.Ownership_num__c;  
            }
            
        	  
        	//newOwnership += each.Ownership_num__c;    
		}
       // System.debug('totalOwnershipSum :::::: '+totalOwnershipSum);
        if(totalOwnership != null && (totalOwnership + newOwnership > 100)){
        	for(Ultimate_Beneficiary_Owner_UBO__c uboRecord : TriggerNew){
                uboRecord.addError('Total ownership exceeds 100.');
            }
                
        }
    }
    
    public static void afterInsertHandler(List<Ultimate_Beneficiary_Owner_UBO__c> triggerNew){
        System.debug('On Line 36');
        for(Ultimate_Beneficiary_Owner_UBO__c ubo : triggerNew){
            System.debug('On Line 38');
            if(!system.isBatch() && ubo.Data_need_to_be_publish__c){ 
                System.debug('On Line 40');
                IntegrationUtility.sendPayLoadData(ubo, null, 'Ultimate_Beneficiary_Owner_UBO__c', 'Ultimate_Beneficiary_Owner_UBO__c'); 
            }
			}
    }
}