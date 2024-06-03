public with sharing class ActionToCallPlatformAndFallBack_CTRL {
    public Id commId;
    public ActionToCallPlatformAndFallBack_CTRL(ApexPages.StandardController sc){
    }
    public pageReference executeDml(){
        commId = ApexPages.CurrentPage().getParameters().get('Id');
        List<Platform_Fee__c> platFromFeeList = [SELECT Id,Commercial__c,Start_Date__c,End_Date__c,Debit_Model__c ,Amount__c,Commercial__r.Opportunity__c,Commercial__r.Merchant_MID__c,Flat_Fee__c,Interval__c,Percentage__c,Name,Rule_Id__c,Type__c 
                                                 FROM Platform_Fee__c WHERE Commercial__c =:commId AND Need_To_Publish__c = TRUE];
        List<Fallback_Charge__c> fallbackFromFeeList = [SELECT Id,Commercial__c,Commercial__r.Merchant_MID__c,Commercial__r.Opportunity__c,Payment_Mode__c, Flat_Fee__c,Percentage__c,Rule_Id__c FROM Fallback_Charge__c WHERE Commercial__c =:commId AND Need_To_Publish__c = TRUE];
        List<Commercial2__c > commList = [SELECT Id FROM Commercial2__c  WHERE ID=:commId AND Status__c ='Live'];
        List<Fixed_Pricing1__c> fixedPricingList = [SELECT Id ,Amount__c,Debit_Model__c,End_Date__c,Fee_Type__c,Flat_Fee__c,Need_to_Publish__c,Payment_Frequency__c,Percentage__c,Published__c,Start_Date__c,Rule_Id__c ,Commercial__r.Merchant_MID__c,Commercial__r.Opportunity__c FROM Fixed_Pricing1__c WHERE Commercial__c   =:commId AND Need_To_Publish__c = TRUE];
        if(commList.size()>0 && commId !=NULL){
            if(platFromFeeList !=NULL && platFromFeeList.size()>0){
                callPlatform(commId);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Platform Fee Successfully Published'));  
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please check there are no Platform Fee need to  be published')) ;
            }
            if(fallbackFromFeeList !=NULL && fallbackFromFeeList.size()>0){
                callFallBack(commId);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Fallback Fee Successfully Published'));  
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please check there are no Fallback Fee need to  be published')) ;
            }
            if(fixedPricingList !=NULL && fixedPricingList.size()>0){
                String fixedFlag = System.label.Fixed_Pricing_Flag;
                SYstem.debug('fixedFlag:::::'+fixedFlag);
                if('TRUE'.EqualsIgnoreCase(fixedFlag)){
                    callFixedBack(commId); 
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Fixed Pricing Fee Successfully Published'));  
                }
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please check there are no Fixed Pricing Fee need to be published')) ;
            }
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please check there are no live commercial for the current MID')) ;
        }
        return null;
    }
    @future(callout=true)
    public static void callPlatform(String commId){
        PublishPlatformFeeToTreasury_CTRL.PricingToTreasury(commId) ;
    }
    @future(callout=true)
    public static void callFallBack(String commId){
        PublishFallbackToTreasury_CTRL.FallBackToTreasury(commId);
    }
    @future(callout=true)
    public static void callFixedBack(String commId){
        PublishFixedFeeToTreasury_CTRL.FixedFeeToTreasury(commId);
    }
}