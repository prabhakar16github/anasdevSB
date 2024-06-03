/*
* Name of the class : OtherProductPricingComponentController
* Author's Name     : Anas Yar Khan  
* Description       : Controller for the Other Product Pricing Module
* Version.          : 1  
*/
public class OtherProductPricingComponentController {
    /*
/***********************Members Variable*************************/
    public static Map<String,Id> mapRecordTypeNameToId = getmapRecordTypeNameToId();
    /***********************Members Variable End*************************/
    
    /*
* Description       : This method is called internally to get the map of record type name and id 
* Version.          : 1   
*/
    public static Map<String,Id> getmapRecordTypeNameToId() {
        Map<String,Id> mapRecordTypeNameToId = new Map<String,Id>();   
        for(RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Other_Product_Pricing__c']) {
            mapRecordTypeNameToId.put(rt.DeveloperName,rt.Id);	    
        }
        return mapRecordTypeNameToId;
    }
    
    /*
* Description       : This method is called from the LWC on load of the component
* Version.          : 1   
*/
    @AuraEnabled
    public static OnLoadWrapper getDetailsOnLoad(String opportunityId,String productName) {
        OnLoadWrapper wrpCls = new OnLoadWrapper();
        try{
            for(Other_Product_Pricing__c opp : [SELECT Id,Debit_Model__c,Amount_Slab__c,Valid_From__c,Valid_Till__c,Need_To_Publish__c,
                                                From_TIme__c,Till_TIme__c,Days_of_the_week__c,Valid_From_Time__c,Valid_Till_Time__c,
                                                Percent_Fee__c,Flat_Fee__c,Published__c,Last_Edited_On__c,Last_Published_On__c,Revenue_Model__c
                                                FROM Other_Product_Pricing__c 
                                                WHERE Opportunity__c =:opportunityId 
                                                AND RecordTypeId =:mapRecordTypeNameToId.get(productName) AND Deleted__c = false]) {
                                                    OnLoadWrapperInner obj = new OnLoadWrapperInner();
                                                    obj.recordId = opp.Id;
                                                    if(opp.Debit_Model__c != NULL) obj.debitModel = opp.Debit_Model__c;
                                                    if(opp.Amount_Slab__c != NULL) obj.amountSlab = String.valueOf(opp.Amount_Slab__c);
                                                    if(opp.Valid_From__c != NULL) obj.validFrom = opp.Valid_From__c.format();
                                                    if(opp.Valid_Till__c != NULL) obj.validTill = opp.Valid_Till__c.format();
                                                    if(opp.From_TIme__c != NULL) obj.fromTime = String.valueOf(opp.From_TIme__c);
                                                    if(opp.Till_TIme__c != NULL) obj.tillTime = String.valueOf(opp.Till_TIme__c);
                                                    if(opp.Days_of_the_week__c != NULL) obj.dayOfTheWeek = opp.Days_of_the_week__c;
                                                    if(opp.Valid_From_Time__c != NULL) obj.ValidFromTime = String.valueOf(opp.Valid_From_Time__c);
                                                    if(opp.Valid_Till_Time__c != NULL) obj.validTillTime = String.valueOf(opp.Valid_Till_Time__c);
                                                    if(opp.Need_to_Publish__c) wrpCls.disablePublishButton = false;
                                                    if(opp.Published__c) obj.published = true;
                                                    if(opp.Percent_Fee__c != NULL) obj.percentFee = String.valueOf(opp.Percent_Fee__c);
                                                    if(opp.Flat_Fee__c != NULL) obj.flatFee = String.valueOf(opp.Flat_Fee__c);
                                                    if(opp.Last_Edited_On__c != NULL) obj.lastEditedOn = opp.Last_Edited_On__c.format();
                                                    if(opp.Last_Published_On__c != NULL) obj.lastPublishedOn = opp.Last_Published_On__c.format();
                                                    if(opp.Revenue_Model__c != NULL) obj.revenueModel = opp.Revenue_Model__c;
                                                    wrpCls.listCommercials.add(obj);
                                                }	        
        }
        catch(Exception e) {
            wrpCls.message = e.getMessage();    
        }
        return wrpCls;
    }
    
    public class OnLoadWrapper {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public Boolean disablePublishButton = true;
        @AuraEnabled public List<OnLoadWrapperInner> listCommercials = new List<OnLoadWrapperInner>();
        @AuraEnabled public Date todaysDate = System.today();
    }
    
    public class OnLoadWrapperInner {
        @AuraEnabled public String recordId = '';
        @AuraEnabled public String debitModel = '';
        @AuraEnabled public String amountSlab = '';
        @AuraEnabled public String validFrom = '';
        @AuraEnabled public String validFromTime = '';
        @AuraEnabled public String validTill = '';
        @AuraEnabled public String validTillTime = '';
        @AuraEnabled public String fromTime = '';
        @AuraEnabled public String tillTime = '';
        @AuraEnabled public String dayOfTheWeek = '';
        @AuraEnabled public String percentFee = '';
        @AuraEnabled public String flatFee = '';
        @AuraEnabled public Boolean published = false;
        @AuraEnabled public String lastEditedOn = '';
        @AuraEnabled public String lastPublishedOn = '';
        @AuraEnabled public String revenueModel = '';
    }
    
    /*
* Description       : This method is called from the LWC on click of add new commercial or edit commercial
* Version.          : 1   
*/
    @AuraEnabled 
    public static CommercialWrapper getCommercialDetails(String commercialId) {
        CommercialWrapper wrpCls = new CommercialWrapper();
        try {
            Schema.DescribeFieldResult debitModelDescribe = Other_Product_Pricing__c.Debit_Model__c.getDescribe();
            List<Schema.PicklistEntry> debitModelPicklistValues = debitModelDescribe.getPickListValues();
            for (Schema.PicklistEntry objPickList : debitModelPicklistValues) {
                PicklistValues pick = new PicklistValues();
                pick.label = objPickList.getLabel();
                pick.value = objPickList.getValue();
                wrpCls.listDebitModel.add(pick);
            } 
            
            Schema.DescribeFieldResult dayOfTheWeekDescribe = Other_Product_Pricing__c.Days_of_the_week__c.getDescribe();
            List<Schema.PicklistEntry> dayOfTheWeekPicklistValues = dayOfTheWeekDescribe.getPickListValues();
            PicklistValues pick1 = new PicklistValues();
            pick1.label = '--None--';
            pick1.value = '';
            wrpCls.listDaysOfTheWeek.add(pick1);
            for (Schema.PicklistEntry objPickList : dayOfTheWeekPicklistValues) {
                PicklistValues pick = new PicklistValues();
                pick.label = objPickList.getLabel();
                pick.value = objPickList.getValue();
                wrpCls.listDaysOfTheWeek.add(pick);
            } 
            
            if(String.isNotBlank(commercialId)) { 
                for(Other_Product_Pricing__c opp : [SELECT Id,Debit_Model__c,Amount_Slab__c,Valid_From__c,Valid_Till__c,Percent_Fee__c,Flat_Fee__c,
                                                    From_TIme__c,Till_TIme__c,Days_of_the_week__c,Valid_From_Time__c,Valid_Till_Time__c
                                                    FROM Other_Product_Pricing__c WHERE Id =:commercialId]) {
                                                        wrpCls.recordId = commercialId;	
                                                        wrpCls.selectedDebitModel = opp.Debit_Model__c;
                                                        wrpCls.amountSlab = opp.Amount_Slab__c != NULL ? String.valueOf(opp.Amount_Slab__c) : '';
                                                        wrpCls.percentage = opp.Percent_Fee__c != NULL ? String.valueOf(opp.Percent_Fee__c) : '';
                                                        wrpCls.flatFee = opp.Flat_Fee__c != NULL ? String.valueOf(opp.Flat_Fee__c) : '';
                                                        wrpCls.validFrom = opp.Valid_From__c != NULL ? String.valueOf(opp.Valid_From__c) : '';
                                                        wrpCls.validTill = opp.Valid_Till__c != NULL ? String.valueOf(opp.Valid_Till__c) : '';
                                                        wrpCls.validFromTime = opp.Valid_From_Time__c != NULL ? String.valueOf(opp.Valid_From_Time__c) : '';
                                                        wrpCls.validTillTime = opp.Valid_Till_Time__c != NULL ? String.valueOf(opp.Valid_Till_Time__c) : '';
                                                        wrpCls.fromTime = opp.From_TIme__c != NULL ? String.valueOf(opp.From_TIme__c) : '';
                                                        wrpCls.tillTime = opp.Till_TIme__c != NULL ? String.valueOf(opp.Till_TIme__c) : '';
                                                        wrpCls.selectedDayOfTheWeek = opp.Days_of_the_week__c != NULL ? String.valueOf(opp.Days_of_the_week__c) : '';
                                                    }		    
            }
        }
        catch(Exception e) {
            wrpCls.message = e.getMessage();    
        }
        return wrpCls;
    }
    
    public class CommercialWrapper {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public String recordId = '';
        @AuraEnabled public List<PicklistValues> listDebitModel = new List<PicklistValues>();
        @AuraEnabled public String selectedDebitModel = 'Net';
        @AuraEnabled public String amountSlab = '0.00';
        @AuraEnabled public String percentage = '';
        @AuraEnabled public String flatFee = '';
        @AuraEnabled public String validFrom = '';
        @AuraEnabled public String validFromTime = '';
        @AuraEnabled public String validTill = '';
        @AuraEnabled public String validTillTime = '';
        @AuraEnabled public String fromTime = '';
        @AuraEnabled public String tillTime = '';
        @AuraEnabled public List<PicklistValues> listDaysOfTheWeek = new List<PicklistValues>();
        @AuraEnabled public String selectedDayOfTheWeek = '';
    }
    
    public class PicklistValues {
        @AuraEnabled public String label = '';
        @AuraEnabled public String value = '';
    }
    
    /*
* Description       : This method is called from the LWC on click of Save commercial
* Version.          : 1   
*/
    @AuraEnabled
    public static SaveCommercialWrapper saveCommercialChanges(String opportunityId,String commercialObj) {
        SaveCommercialWrapper wrpCls = new SaveCommercialWrapper();
        try {
            CommercialWrapper commercial = (CommercialWrapper)JSON.deserialize(commercialObj,CommercialWrapper.class);
            Other_Product_Pricing__c opp = new Other_Product_Pricing__c();
            opp.Debit_Model__c = commercial.selectedDebitModel;
            opp.Amount_Slab__c = Decimal.valueOf(commercial.amountSlab);
            if(String.isNotBlank(commercial.percentage)) opp.Percent_Fee__c = Decimal.valueOf(commercial.percentage);
            else opp.Percent_Fee__c = null;
            
            if(String.isNotBlank(commercial.flatFee)) opp.Flat_Fee__c = Decimal.valueOf(commercial.flatFee);
            else opp.Flat_Fee__c = null;
            
            if(String.isNotBlank(commercial.validFrom)) opp.Valid_From__c = Date.valueOf(commercial.validFrom);
            else opp.Valid_From__c = null;
            
            if(String.isNotBlank(commercial.validTill)) opp.Valid_Till__c = Date.valueOf(commercial.validTill);
            else opp.Valid_Till__c = null;
            
            if(String.isNotBlank(commercial.validFromTime)) {
                String[] validFromTimeList = commercial.validFromTime.split(':');
                Time validFromTime = Time.newInstance(Integer.valueOf(validFromTimeList[0]),Integer.valueOf(validFromTimeList[1]),0,0); 
                opp.Valid_From_Time__c = validFromTime;
            } 
            else opp.Valid_From_Time__c = null;
            
            if(String.isNotBlank(commercial.validTillTime)) {
                String[] validTillTimeList = commercial.validTillTime.split(':');
                Time validTillTime = Time.newInstance(Integer.valueOf(validTillTimeList[0]),Integer.valueOf(validTillTimeList[1]),0,0); 
                opp.Valid_Till_Time__c = validTillTime;
            }
            else opp.Valid_Till_Time__c = null;
            
            if(String.isNotBlank(commercial.fromTime)) {
                String[] fromTimeList = commercial.fromTime.split(':');
                Time fromTime = Time.newInstance(Integer.valueOf(fromTimeList[0]),Integer.valueOf(fromTimeList[1]),0,0); 
                opp.From_TIme__c = fromTime;
            } 
            else opp.From_TIme__c = null;
            
            if(String.isNotBlank(commercial.tillTime)) {
                String[] tillTimeList = commercial.tillTime.split(':');
                Time tillTime = Time.newInstance(Integer.valueOf(tillTimeList[0]),Integer.valueOf(tillTimeList[1]),0,0); 
                opp.Till_TIme__c = tillTime;
            }
            else opp.Till_TIme__c = null;
            
            if(String.isNotBlank(commercial.selectedDayOfTheWeek)) opp.Days_of_the_week__c = commercial.selectedDayOfTheWeek;
            else opp.Days_of_the_week__c = null;
            
            if(String.isBlank(commercial.recordId)) {
                opp.Client_Id__c = '1';
                opp.Revenue_Model__c = 'instantSettlementTdr';
                opp.Opportunity__c = opportunityId;
                opp.RecordTypeId = mapRecordTypeNameToId.get('Instant_Settlement');
                opp.Need_to_Publish__c = true;
                opp.Last_Edited_On__c = System.now();
                opp.Identifier__c = opportunityId+opp.Revenue_Model__c+opp.Debit_Model__c+opp.Amount_Slab__c.setScale(2)+opp.Valid_From__c+opp.Valid_From_Time__c+opp.Valid_Till__c+opp.Valid_Till_Time__c+opp.From_TIme__c+opp.Till_TIme__c+opp.Days_of_the_week__c;
                insert opp;
                wrpCls.disablePublishButton = false;
            }
            else {
                opp.Id = commercial.recordId;
                List<Other_Product_Pricing__c> listOpp = [SELECT Id,Debit_Model__c,Amount_Slab__c,Valid_From__c,Valid_Till__c,Percent_Fee__c,Flat_Fee__c,
                                                          From_TIme__c,Till_TIme__c,Days_of_the_week__c,Valid_From_Time__c,Valid_Till_Time__c,Revenue_Model__c,Published__c 
                                                          FROM Other_Product_Pricing__c WHERE Id =:commercial.recordId];
                if(opp.Debit_Model__c != listOpp[0].Debit_Model__c || opp.Amount_Slab__c != listOpp[0].Amount_Slab__c 
                   || opp.Percent_Fee__c != listOpp[0].Percent_Fee__c || opp.Flat_Fee__c != listOpp[0].Flat_Fee__c 
                   || opp.Valid_From__c != listOpp[0].Valid_From__c || opp.Valid_Till__c != listOpp[0].Valid_Till__c 
                   || opp.Valid_From_Time__c != listOpp[0].Valid_From_Time__c || opp.Valid_Till_Time__c != listOpp[0].Valid_Till_Time__c 
                   || opp.From_TIme__c != listOpp[0].From_TIme__c || opp.Till_TIme__c != listOpp[0].Till_TIme__c 
                   || opp.Days_of_the_week__c != listOpp[0].Days_of_the_week__c) {
                       //opp.Need_to_Publish__c = true; 
                       opp.Last_Edited_On__c = System.now(); 
                       opp.Identifier__c = opportunityId+listOpp[0].Revenue_Model__c+opp.Debit_Model__c+opp.Amount_Slab__c.setScale(2)+opp.Valid_From__c+opp.Valid_From_Time__c+opp.Valid_Till__c+opp.Valid_Till_Time__c+opp.From_TIme__c+opp.Till_TIme__c+opp.Days_of_the_week__c;
                       //wrpCls.disablePublishButton = false;
                       update opp;
                       if(listOpp[0].Published__c) {
                           PublishOtherProductApi_CTRL.editProductPricingFromTreasury(commercial.recordId);    
                       }
                   }
            }
        }
        catch(Exception e) {
            wrpCls.message = e.getMessage();	
            if(wrpCls.message.contains('DUPLICATE_VALUE, duplicate value found: Identifier__c')) {
                wrpCls.message = 'Commercial already exists with this combination of Data';  
            } 
        }
        return wrpCls;
    }
    
    public class SaveCommercialWrapper {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public Boolean disablePublishButton = true;
    }
    
    /*
* Description       : This method is called from the LWC on click of Publish commercial
* Version.          : 1   
*/
    @AuraEnabled
    public static SaveCommercialWrapper publishCommercial(String opportunityId,String productName) {
        SaveCommercialWrapper wrpCls = new SaveCommercialWrapper();
        try {
            PublishOtherProductApi_CTRL.otherProductPricingToTreasury(opportunityId,productName);	     
        }
        catch(Exception e) {
            wrpCls.message = e.getMessage();            
        }
        return wrpCls;
    }
    
    /*
* Description       : This method is called from the LWC on click of delete commercial 
* Version.          : 1   
*/
    @AuraEnabled
    public static String deleteCommercial(String commercialId) {
        String message = 'SUCCESS';
        try {
            Other_Product_Pricing__c opp = new Other_Product_Pricing__c();
            opp.Id = commercialId;
            opp.Deleted__c = true;
            opp.Identifier__c = commercialId;
            opp.Need_to_Publish__c = false;
            update opp;
            List<Other_Product_Pricing__c> listProductPricing = [SELECT Id,Published__c FROM Other_Product_Pricing__c WHERE Id = :commercialId];
            if(listProductPricing != NULL && listProductPricing.size() > 0 && listProductPricing[0].Published__c) {
                PublishOtherProductApi_CTRL.deleteProductPricingFromTreasury(commercialId);    
            }
        }
        catch(Exception e) {
            message = e.getMessage();        
        }
        return message;
    }
    
    
    /*
* Description       : This method is called from the LWC on click of Add New commercial for the Offer Engine
* Version.          : 1   
*/
    @AuraEnabled
    public static Boolean getExistingOfferEngineCommercial(String opportunityId,String productName,String revenueModel) {
        List<Other_Product_Pricing__c> listCommercial = [SELECT Id
                                                         FROM Other_Product_Pricing__c 
                                                         WHERE Opportunity__c =:opportunityId 
                                                         AND Revenue_Model__c = :revenueModel
                                                         AND RecordTypeId =:mapRecordTypeNameToId.get(productName) 
                                                         AND Deleted__c = false];
        if(listCommercial != NULL && listCommercial.size() > 0) return false;
        else return true;
    }
    
    /*
* Description       : This method is called from the LWC on click of add new commercial or edit commercial for Offer Engine
* Version.          : 1   
*/
    @AuraEnabled
    public static SaveCommercialWrapper saveCommercialChangesOfferEngine(String opportunityId,String commercialObj,String revenueModel) {
        SaveCommercialWrapper wrpCls = new SaveCommercialWrapper();
        try {
            CommercialWrapper commercial = (CommercialWrapper)JSON.deserialize(commercialObj,CommercialWrapper.class);
            Other_Product_Pricing__c opp = new Other_Product_Pricing__c();
            opp.Debit_Model__c = commercial.selectedDebitModel;
            if(String.isNotBlank(commercial.percentage)) opp.Percent_Fee__c = Decimal.valueOf(commercial.percentage);
            else opp.Percent_Fee__c = null;
            
            if(String.isNotBlank(commercial.flatFee)) opp.Flat_Fee__c = Decimal.valueOf(commercial.flatFee);
            else opp.Flat_Fee__c = null;
            
            if(String.isNotBlank(commercial.validFrom)) opp.Valid_From__c = Date.valueOf(commercial.validFrom);
            else opp.Valid_From__c = null;
            
            if(String.isNotBlank(commercial.validTill)) opp.Valid_Till__c = Date.valueOf(commercial.validTill);
            else opp.Valid_Till__c = null;
            
            if(String.isNotBlank(commercial.validFromTime)) {
                String[] validFromTimeList = commercial.validFromTime.split(':');
                Time validFromTime = Time.newInstance(Integer.valueOf(validFromTimeList[0]),Integer.valueOf(validFromTimeList[1]),0,0); 
                opp.Valid_From_Time__c = validFromTime;
            } 
            else opp.Valid_From_Time__c = null;
            
            if(String.isNotBlank(commercial.validTillTime)) {
                String[] validTillTimeList = commercial.validTillTime.split(':');
                Time validTillTime = Time.newInstance(Integer.valueOf(validTillTimeList[0]),Integer.valueOf(validTillTimeList[1]),0,0); 
                opp.Valid_Till_Time__c = validTillTime;
            }
            else opp.Valid_Till_Time__c = null;
            
            if(String.isNotBlank(commercial.fromTime)) {
                String[] fromTimeList = commercial.fromTime.split(':');
                Time fromTime = Time.newInstance(Integer.valueOf(fromTimeList[0]),Integer.valueOf(fromTimeList[1]),0,0); 
                opp.From_TIme__c = fromTime;
            } 
            else opp.From_TIme__c = null;
            
            if(String.isNotBlank(commercial.tillTime)) {
                String[] tillTimeList = commercial.tillTime.split(':');
                Time tillTime = Time.newInstance(Integer.valueOf(tillTimeList[0]),Integer.valueOf(tillTimeList[1]),0,0); 
                opp.Till_TIme__c = tillTime;
            }
            else opp.Till_TIme__c = null;
            
            if(String.isNotBlank(commercial.selectedDayOfTheWeek)) opp.Days_of_the_week__c = commercial.selectedDayOfTheWeek;
            else opp.Days_of_the_week__c = null;
            
            if(String.isBlank(commercial.recordId)) {
                opp.Client_Id__c = '1';
                opp.Revenue_Model__c = revenueModel;
                opp.Opportunity__c = opportunityId;
                opp.RecordTypeId = mapRecordTypeNameToId.get('Offer_Engine');
                opp.Need_to_Publish__c = true;
                opp.Last_Edited_On__c = System.now();
                opp.Identifier__c = opportunityId+opp.Revenue_Model__c;
                if(revenueModel == 'offerActivationFee') {
                    opp.Frequency__c = 'Daily';
                    //opp.Aggregation_Period__c = 'Daily';
                    opp.Valid_Till__c = opp.Valid_From__c.addDays(1);
                    String tillTime = '03:00:00.000';
                    String[] tillTimeList = tillTime.split(':');
                    Time validTillTime = Time.newInstance(Integer.valueOf(tillTimeList[0]),Integer.valueOf(tillTimeList[1]),0,0); 
                    opp.Valid_Till_Time__c = validTillTime;
                }
                else if(revenueModel == 'MIN_BILL_OFFER_TDR') {
                    opp.Frequency__c = 'Monthly';	
                    opp.Aggregation_Period__c = 'Monthly';
                    opp.Aggregation_Required__c = 'true';
                    //opp.GMV_Slab__c = 0; As confirmed by Suyash and Ayushi
                    opp.Attributes__c = '[{"pricingRuleKey":"gmvSlab","pricingRuleValue":"0"}]';
                }
                insert opp;
                wrpCls.disablePublishButton = false;
            }
            else {
                opp.Id = commercial.recordId;
                List<Other_Product_Pricing__c> listOpp = [SELECT Id,Debit_Model__c,Amount_Slab__c,Valid_From__c,Valid_Till__c,Percent_Fee__c,Flat_Fee__c,
                                                          From_TIme__c,Till_TIme__c,Days_of_the_week__c,Valid_From_Time__c,Valid_Till_Time__c,Revenue_Model__c,Published__c 
                                                          FROM Other_Product_Pricing__c WHERE Id =:commercial.recordId];
                if(opp.Debit_Model__c != listOpp[0].Debit_Model__c || opp.Amount_Slab__c != listOpp[0].Amount_Slab__c 
                   || opp.Percent_Fee__c != listOpp[0].Percent_Fee__c || opp.Flat_Fee__c != listOpp[0].Flat_Fee__c 
                   || opp.Valid_From__c != listOpp[0].Valid_From__c || opp.Valid_Till__c != listOpp[0].Valid_Till__c 
                   || opp.Valid_From_Time__c != listOpp[0].Valid_From_Time__c || opp.Valid_Till_Time__c != listOpp[0].Valid_Till_Time__c 
                   || opp.From_TIme__c != listOpp[0].From_TIme__c || opp.Till_TIme__c != listOpp[0].Till_TIme__c 
                   || opp.Days_of_the_week__c != listOpp[0].Days_of_the_week__c) {
                       opp.Last_Edited_On__c = System.now(); 
                       //wrpCls.disablePublishButton = false;
                       if(revenueModel == 'offerActivationFee') {
                           opp.Valid_Till__c = opp.Valid_From__c.addDays(1);
                       }
                       update opp;
                       if(listOpp[0].Published__c) {
                           PublishOtherProductApi_CTRL.editProductPricingFromTreasury(commercial.recordId);   
                       }
                   }
            }
        }
        catch(Exception e) {
            wrpCls.message = e.getMessage();	
            if(wrpCls.message.contains('DUPLICATE_VALUE, duplicate value found: Identifier__c')) {
                wrpCls.message = 'Commercial already exists for this Revenue Model';  
            } 
        }
        return wrpCls;
    }
    
    /*
* Description       : This method is called from the LWC on click of edit commercial for offer engine
* Version.          : 1   
*/
    @AuraEnabled 
    public static Boolean getPublishedInformation(String opportunityId,String productName,String revenueModel) {
        List<Other_Product_Pricing__c> listCommercial = [SELECT Id,Valid_From__c
                                                         FROM Other_Product_Pricing__c 
                                                         WHERE Opportunity__c =:opportunityId 
                                                         AND Revenue_Model__c = :revenueModel
                                                         AND RecordTypeId =:mapRecordTypeNameToId.get(productName) 
                                                         AND Deleted__c = false 
                                                         AND Published__c = true];
        if(listCommercial != NULL && listCommercial.size() > 0) {
            if(listCommercial[0].Valid_From__c > System.today()) return true;	    
            else return false;
        }
        else return true;
    }
    
    /*
* Description       : This method is called from the LWC on click of Save commercial of Checkout Express
* Version.          : 1   
*/
    @AuraEnabled
    public static SaveCommercialWrapper saveCommercialChangesForCheckOut(String opportunityId,String commercialObj) {
        SaveCommercialWrapper wrpCls = new SaveCommercialWrapper();
        try {
            CommercialWrapper commercial = (CommercialWrapper)JSON.deserialize(commercialObj,CommercialWrapper.class);
            Other_Product_Pricing__c opp = new Other_Product_Pricing__c();
            opp.Debit_Model__c = commercial.selectedDebitModel;
            opp.Amount_Slab__c = Decimal.valueOf(commercial.amountSlab);
            if(String.isNotBlank(commercial.percentage)) opp.Percent_Fee__c = Decimal.valueOf(commercial.percentage);
            else opp.Percent_Fee__c = null;
            
            if(String.isNotBlank(commercial.flatFee)) opp.Flat_Fee__c = Decimal.valueOf(commercial.flatFee);
            else opp.Flat_Fee__c = null;
            
            if(String.isBlank(commercial.recordId)) {
                opp.Client_Id__c = '1';
                opp.Revenue_Model__c = 'CHECKOUT_EXPRESS_TDR';
                opp.Opportunity__c = opportunityId;
                opp.RecordTypeId = mapRecordTypeNameToId.get('Checkout_Express');
                opp.Need_to_Publish__c = true;
                opp.Last_Edited_On__c = System.now();
                opp.Identifier__c = opp.Opportunity__c + opp.Revenue_Model__c;
                insert opp;
                wrpCls.disablePublishButton = false;
            }
            else {
                opp.Id = commercial.recordId;
                List<Other_Product_Pricing__c> listOpp = [SELECT Id,Debit_Model__c,Percent_Fee__c,Flat_Fee__c,Published__c
                                                          FROM Other_Product_Pricing__c WHERE Id =:commercial.recordId];
                if(opp.Debit_Model__c != listOpp[0].Debit_Model__c  
                   || opp.Percent_Fee__c != listOpp[0].Percent_Fee__c 
                   || opp.Flat_Fee__c != listOpp[0].Flat_Fee__c ) {
                       opp.Last_Edited_On__c = System.now();
                       update opp;
                       if( listOpp[0].Published__c) {
                           PublishOtherProductApi_CTRL.editProductPricingFromTreasury(commercial.recordId);    
                       }
                   }
            }
        }
        catch(Exception e) {
            wrpCls.message = e.getMessage();	
            if(wrpCls.message.contains('DUPLICATE_VALUE, duplicate value found: Identifier__c')) {
                wrpCls.message = 'Commercial already exists with this combination of Data';  
            } 
        }
        return wrpCls;
    }
    
    @AuraEnabled
    public static Boolean getPublishedInfoDelete(String commercialId) {
        List<Other_Product_Pricing__c> listCommercial = [SELECT Id,Valid_From__c
                                                         FROM Other_Product_Pricing__c 
                                                         WHERE Id = :commercialId 
                                                         AND Deleted__c = false 
                                                         AND Published__c = true];
        if(listCommercial != NULL && listCommercial.size() > 0) {
            if(listCommercial[0].Valid_From__c < System.today()) return true;	    
            else return false;
        }
        else return true;
    }
    
    
}