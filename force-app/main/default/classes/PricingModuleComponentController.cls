/*
* Name of the class : PricingModuleComponentController
* Author's Name     : Anas Yar Khan  
* Description       : Controller for the Pricing Module
* Version.          : 1  
*/
public class PricingModuleComponentController {
    /*
/***********************Members Variable*************************/
    public static Map<String,Object> mapPriorityToStatus = (Map<String,Object>)JSON.deserializeUntyped(Label.PricingStatusPriority);
    public static Map<String,Integer> mapStatusToPriority = getStatusToPriorityMap();
    public static Set<Id> setSuperUsersId = getUserIdFromGroup('Pricing_Module_Super_User');
    public static Map<String,Payment_Gateway2__c> mapIdentifierToPaymentGatewayId = getMapIdentifierToPaymentGatewayId();
    public static Map<String,Id> mapIdentifierToPricingSpecificationId = getMapIdentifierToPricingSpecificationId();
    public static Map<String,Master_Pricing_Data__c> mapIdentifierToMasterPricingDataId = getMapIdentifierToMasterPricingDataId();
    public static Set<String> setFlatFeeType = getValuesForFlatFee();
    public static String commercialId{get;set;} // added by rohit to get the commercial id from vf page
    public static List<Pricing__C> listPricingRecords {get;set;}// added by rohit to get the list of pricing records 
    /***********************Members Variable End*************************/
    
    /*
* Description       : This method is called internally to get the possible values of the Fixed Pricing fee type 
* Version.          : 1   
*/
    public static Set<String> getValuesForFlatFee() {
        Set<String> setFlatFeeType = new Set<String>();
        Schema.DescribeFieldResult fixedFlatFeeTypeDescribe = Fixed_Pricing1__c.Fee_Type__c.getDescribe();
        List<Schema.PicklistEntry> fixedFeeTypePaymentFrequencyPicklistValues = fixedFlatFeeTypeDescribe.getPickListValues();
        for (Schema.PicklistEntry objPickList : fixedFeeTypePaymentFrequencyPicklistValues) {
            setFlatFeeType.add(objPickList.getValue());
        }
        return setFlatFeeType;
    }
    
    
    /*
* Description       : This method is called internally to get the Map of Unique Combination of Values to Master Pricing Data records 
* Version.          : 1   
*/
    public static Map<String,Master_Pricing_Data__c> getMapIdentifierToMasterPricingDataId() {
        Map<String,Master_Pricing_Data__c> mapIdentifierToMasterPricingDataId = new Map<String,Master_Pricing_Data__c>();
        for(Master_Pricing_Data__c mpd : [SELECT Id,Salesforce_Primary_Key__c,Payment_Mode__c,Payment_Option__c,
                                          Payment_Gateway__c,Pricing_Specification__c,ONUS_OFFUS__c
                                          FROM Master_Pricing_Data__c WHERE Active_Instrument__c = true LIMIT 50000]) {
                                              mapIdentifierToMasterPricingDataId.put(mpd.Payment_Mode__c+'#'+mpd.Payment_Option__c+'#'+mpd.Pricing_Specification__c+'#'+mpd.Payment_Gateway__c+'#'+mpd.ONUS_OFFUS__c,mpd);	    
                                          }
        return mapIdentifierToMasterPricingDataId;
    }
    
    /*
* Description       : This method is called internally to get the Map of Pricing Specification Name to Payment Pricing Specification Id 
* Version.          : 1   
*/
    public static Map<String,Id> getMapIdentifierToPricingSpecificationId() {
        Map<String,Id> mapIdentifierToPricingSpecificationId = new Map<String,Id>();
        for(Pricing_Specification__c ps : [SELECT Id,Name FROM Pricing_Specification__c LIMIT 50000]) {
            mapIdentifierToPricingSpecificationId.put(ps.Name,ps.Id);     
        }
        return mapIdentifierToPricingSpecificationId;
    }
    
    /*
* Description       : This method is called internally to get the Map of Payment Gateway Name to Payment Gateway 
* Version.          : 1   
*/
    public static Map<String,Payment_Gateway2__c> getMapIdentifierToPaymentGatewayId() {
        Map<String,Payment_Gateway2__c> mapIdentifierToPaymentGatewayId = new Map<String,Payment_Gateway2__c>();
        for(Payment_Gateway2__c pg : [SELECT Id,Name,Type__c FROM Payment_Gateway2__c LIMIT 50000]) {
            mapIdentifierToPaymentGatewayId.put(pg.Name,pg);    
        }
        return mapIdentifierToPaymentGatewayId;
    }
    /*
* Description       : This method is called internally to get the users id from the group 
* Version.          : 1   
*/
    public static Set<Id> getUserIdFromGroup(String groupApiName) {
        Set<Id> setUsersId = new Set<Id>();
        List<Group> listGroup = [SELECT Id FROM GROUP WHERE DeveloperName = :groupApiName];
        if(listGroup != NULL && listGroup.size() > 0) {
            for(GroupMember grpMem : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :listGroup[0].Id]) {
                setUsersId.add(grpMem.UserOrGroupId);    
            }
        }
        return setUsersId;
    }
    /*
* Description       : This method is called internally to get the mapStatusToPriority 
* Version.          : 1   
*/
    private static Map<String,Integer> getStatusToPriorityMap() {
        Map<String,Integer> mapStatusToPriority = new Map<String,Integer>();
        If(mapPriorityToStatus != NULL && mapPriorityToStatus.keySet().size() > 0) {
            for(String key : mapPriorityToStatus.keySet()) {
                mapStatusToPriority.put((String)mapPriorityToStatus.get(key),Integer.valueOf(key));    
            }
        }
        return mapStatusToPriority;
    } 
    
    /*
* Description       : This method is called internally to get the MapBankAndPORTypeToStatus 
* Version.          : 1   
*/
    public static Map<String,Integer> getMapBankAndPORTypeToStatus(String opportunityId) {
        Map<String,Integer> mapBankAndPORTypeToStatus = new Map<String,Integer>();
        for(Pricing__c price : [SELECT Bank_Name__c,POR_Type_Name__c,Banking_Ops_Status__c FROM Pricing__c 
                                WHERE Commercial2__r.Opportunity__c = :opportunityId 
                                AND Payment_Gateway2__r.Type__c = 'PostApproved' 
                                AND Deleted__c = false
                                AND Invisible__c = false
                                AND Banking_Ops_Status__c IN ('Approved','Rejected','Pending with Bank','Pending with KAM','Pending with Banking ops') 
                                LIMIT 50000]) {
                                    String key = price.Bank_Name__c + '#'+price.POR_Type_Name__c;
                                    if(mapBankAndPORTypeToStatus.containsKey(key)) {
                                        Integer currentPriority = mapBankAndPORTypeToStatus.get(key);
                                        Integer priorityToBeCheck = mapStatusToPriority.get(price.Banking_Ops_Status__c);
                                        if(priorityToBeCheck < currentPriority) {
                                            mapBankAndPORTypeToStatus.put(key,mapStatusToPriority.get(price.Banking_Ops_Status__c));    
                                        }
                                    }   
                                    else {
                                        mapBankAndPORTypeToStatus.put(key,mapStatusToPriority.get(price.Banking_Ops_Status__c));	    
                                    }
                                }
        return mapBankAndPORTypeToStatus;
    }
    
    /*
* Description       : This method is called internally to get the status 
* Version.          : 1   
*/
    private static String getStatus(Pricing__c pricing,Map<String,Integer> mapBankAndPORTypeToStatus,Map<String,Object> mapPriorityToStatus) {
        String keyNew = pricing.Bank_Name__c + '#' + pricing.POR_Type_Name__c;
        if(mapBankAndPORTypeToStatus.containsKey(keyNew)) {
            Integer priority = mapBankAndPORTypeToStatus.get(keyNew);
            return (String)mapPriorityToStatus.get(String.valueOf(priority));
        }
        else {
            return 'Pending with Banking ops';    
        }
    }
    
    /*
* Description       : This method is called from the LWC on load of the component
* Version.          : 1   
*/
    @AuraEnabled/*(cacheable=true) ## To get the real time data*/
    public static WrapperClassOnLoad getPlanDetailsOnLoad() {
        WrapperClassOnLoad wrpCls = new WrapperClassOnLoad();
        try{
            Set<Id> setPlanId = new Set<Id>();
            wrpCls.jsonPlanMaster = '[';
            for(Template_Mapping__c pm : [SELECT Plan__c,Plan__r.Name FROM Template_Mapping__c WHERE Plan__c != NULL 
                                          AND (Template__r.Public_Template__c = true OR Template__r.CreatedById = :UserInfo.getUserId()) 
                                          LIMIT 50000]) {
                                              if(!setPlanId.contains(pm.Plan__c)) {
                                                  wrpCls.jsonPlanMaster += '{"label":"'+pm.Plan__r.Name+'","value":"'+pm.Plan__c+'"},'; 
                                                  setPlanId.add(pm.Plan__c);
                                              }
                                              
                                          } 
            wrpCls.jsonPlanMaster = wrpCls.jsonPlanMaster.removeEnd(',');
            wrpCls.jsonPlanMaster += ']';
            
            Schema.DescribeFieldResult pricingFeeModelDescribe = Pricing__c.Fee_Model__c.getDescribe();
            List<Schema.PicklistEntry> feeModelPicklistValues = pricingFeeModelDescribe.getPickListValues();
            for (Schema.PicklistEntry objPickList : feeModelPicklistValues) {
                PicklistValues pick = new PicklistValues();
                pick.label = objPickList.getLabel();
                pick.value = objPickList.getValue();
                wrpCls.listFeeModel.add(pick);
            }
            
            Schema.DescribeFieldResult pricingTransactionTypeDescribe = Pricing__c.Transaction_Type__c.getDescribe();
            List<Schema.PicklistEntry> transactionTypePicklistValues = pricingTransactionTypeDescribe.getPickListValues();
            for (Schema.PicklistEntry objPickList : transactionTypePicklistValues) {
                PicklistValues pick = new PicklistValues();
                pick.label = objPickList.getLabel();
                pick.value = objPickList.getValue();
                wrpCls.listTransactionType.add(pick);
            }
        }
        catch(exception e) {
            wrpCls.message = e.getMessage();   
        }
        return wrpCls;
    }
    
    //Wrapper class to return data on load of the component
    public class WrapperClassOnLoad {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public String jsonPlanMaster  = '[]';
        @AuraEnabled public List<PicklistValues> listFeeModel = new List<PicklistValues>();
        @AuraEnabled public List<PicklistValues> listTransactionType = new List<PicklistValues>();
    }
    /*
* Description       : This method is called on change of the plan to get all its Sub Plan, Screen 2
* Version.          : 1   
*/
    @AuraEnabled/*(cacheable=true) ## To get the real time data*/
    public static WrapperClassOnLoad getSubPlanDetails(String planId) {
        WrapperClassOnLoad wrpCls = new WrapperClassOnLoad();
        try{
            Set<Id> setSubPlanId = new Set<Id>();
            wrpCls.jsonPlanMaster = '[';
            for(Template_Mapping__c pm : [SELECT Sub_Plan__c,Sub_Plan__r.Name FROM Template_Mapping__c WHERE Plan__c =:planId AND Sub_Plan__c != NULL 
                                          AND (Template__r.Public_Template__c = true OR Template__r.CreatedById = :UserInfo.getUserId()) 
                                          LIMIT 50000]) {
                                              if(!setSubPlanId.contains(pm.Sub_Plan__c)) {
                                                  wrpCls.jsonPlanMaster += '{"label":"'+pm.Sub_Plan__r.Name+'","value":"'+pm.Sub_Plan__c+'"},'; 
                                                  setSubPlanId.add(pm.Sub_Plan__c);
                                              }    
                                          }
            wrpCls.jsonPlanMaster = wrpCls.jsonPlanMaster.removeEnd(',');
            wrpCls.jsonPlanMaster += ']';
        }
        catch(exception e) {
            wrpCls.message = e.getMessage();   
        }
        return wrpCls;    
    }
    
    /*
* Description       : This method is called on rendering of the Screen 3 Part 1
* Version.          : 1   
*/
    @AuraEnabled
    public static WrapperClassPaymentData getPaymentDetails(String templateId,String commercialId) {
        WrapperClassPaymentData wrpClsPaymentData = new WrapperClassPaymentData();
        try{
            if(String.isNotBlank(commercialId)) {
                List<Publish_Pricing_Detail__c> listPublishPricingDetails = [SELECT Id FROM Publish_Pricing_Detail__c
                                                                             WHERE Commercial__c = :commercialId 
                                                                             AND Type__c = 'TDR' 
                                                                             AND Sync_Status__c = 'Processing']; 
                if(listPublishPricingDetails != NULL && listPublishPricingDetails.size() > 0) {
                    wrpClsPaymentData.editAllowed = false;
                    return wrpClsPaymentData;
                }
            }
            
            List<PicklistValues> listOnusOffus = new List<PicklistValues>();
            PicklistValues pick1 = new PicklistValues();
            pick1.label = 'ONUS';
            pick1.value = 'ONUS';
            
            PicklistValues pick2 = new PicklistValues();
            pick2.label = 'OFFUS';
            pick2.value = 'OFFUS';
            
            listOnusOffus.add(pick2);
            listOnusOffus.add(pick1);
            
            
            
            //Added by Anas Yar Khan | To enable the data load from the template 
            Map<Id,List<PaymentDataInner>> mapPaymentModeToListDataFromTemplate = new Map<Id,List<PaymentDataInner>>();
            if(String.isNotBlank(templateId) || String.isNotBlank(commercialId)) {
                Map<String,List<PicklistValues>> mapPaymentModeAndPaymentOptionsToAvailableSpecifications = new Map<String,List<PicklistValues>>();
                Map<String,Set<Id>> mapPaymentModeAndPaymentOptionsToUniqueSpecifications = new Map<String,Set<Id>>();
                Map<String,List<PicklistValues>> mapPaymentModeOptionsSpecificationToAvailableGateways = new Map<String,List<PicklistValues>>();
                Map<String,Set<Id>> mapPaymentModeOptionsSpecificationToUniqueGateways = new Map<String,Set<Id>>();
                for(Master_Pricing_Data__c mpd : [SELECT Id,Pricing_Specification__c,Pricing_Specification__r.Name,Payment_Mode__c,Payment_Option__c,Payment_Gateway__c,Payment_Gateway__r.Name FROM Master_Pricing_Data__c WHERE Payment_Mode__c != NULL AND Payment_Option__c != NULL AND Active_Instrument__c = true ORDER BY Pricing_Specification__r.Default__c DESC,Payment_Gateway__r.Default__c DESC LIMIT 50000]) {
                    String key = mpd.Payment_Mode__c+'#'+mpd.Payment_Option__c;
                    String key2 = mpd.Payment_Mode__c+'#'+mpd.Payment_Option__c+'#'+mpd.Pricing_Specification__c;
                    List<PicklistValues> listPicklistValues = new List<PicklistValues>();
                    Set<Id> setSpecificationId = new Set<Id>();
                    List<PicklistValues> listPicklistValuesGateways = new List<PicklistValues>();
                    Set<Id> setGatewayId = new Set<Id>();
                    //Specification for the combinations
                    if(mapPaymentModeAndPaymentOptionsToAvailableSpecifications.containsKey(key)) {
                        listPicklistValues = mapPaymentModeAndPaymentOptionsToAvailableSpecifications.get(key);
                        setSpecificationId = mapPaymentModeAndPaymentOptionsToUniqueSpecifications.get(key);
                    }
                    if(!setSpecificationId.contains(mpd.Pricing_Specification__c)) {
                        PicklistValues pick = new PicklistValues();
                        pick.label = mpd.Pricing_Specification__r.Name;
                        pick.value = mpd.Pricing_Specification__r.Name;
                        listPicklistValues.add(pick);
                        setSpecificationId.add(mpd.Pricing_Specification__c);
                    }
                    mapPaymentModeAndPaymentOptionsToAvailableSpecifications.put(key,listPicklistValues);
                    mapPaymentModeAndPaymentOptionsToUniqueSpecifications.put(key,setSpecificationId);
                    
                    //Gateways for the combination
                    if(mapPaymentModeOptionsSpecificationToAvailableGateways.containsKey(key2)) {
                        listPicklistValuesGateways = mapPaymentModeOptionsSpecificationToAvailableGateways.get(key2);
                        setGatewayId = mapPaymentModeOptionsSpecificationToUniqueGateways.get(key2);
                    }
                    if(!setGatewayId.contains(mpd.Payment_Gateway__c)) {
                        PicklistValues pick = new PicklistValues();
                        pick.label = mpd.Payment_Gateway__r.Name;
                        pick.value = mpd.Payment_Gateway__r.Name;
                        listPicklistValuesGateways.add(pick);
                        setGatewayId.add(mpd.Payment_Gateway__c);
                    }
                    mapPaymentModeOptionsSpecificationToAvailableGateways.put(key2,listPicklistValuesGateways);
                    mapPaymentModeOptionsSpecificationToUniqueGateways.put(key2,setGatewayId);
                    
                }
                
                List<FixedPricing> listFixedPricing = new List<FixedPricing>();
                List<FallbackCharges> listFallbackCharges = new List<FallbackCharges>();
                List<PlatformFee> listPlatformFee = new List<PlatformFee>();
                List<FixedPricing2> listFixedPricing2 = new List<FixedPricing2>();
                
                if(String.isNotBlank(templateId)) {
                    for(Pricing_Template__c template : [SELECT Id,Setup_Fee__c,Setup_Deposit__c,AMC_Fee__c,AMC_Interval__c FROM Pricing_Template__c WHERE Id =:templateId]) {
                        FixedPricing fpNew = new FixedPricing();
                        fpNew.key = template.Id;
                        fpNew.setupFee = template.Setup_Fee__c != NULL ? String.valueOf(template.Setup_Fee__c) : '';
                        fpNew.securityDeposit = template.Setup_Deposit__c != NULL ? String.valueOf(template.Setup_Deposit__c) : '';
                        fpNew.amcFee = template.AMC_Fee__c != NULL ? String.valueOf(template.AMC_Fee__c) : '';
                        fpNew.amcInterval = template.AMC_Interval__c != NULL ? String.valueOf(template.AMC_Interval__c) : '';
                        listFixedPricing.add(fpNew);    
                    }
                    
                    for(String feeType : setFlatFeeType) {
                        FixedPricing2 fp = new FixedPricing2();
                        fp.flatFeeType = feeType;
                        listFixedPricing2.add(fp);
                    }
                }
                else if(String.isNotBlank(CommercialId)) {
                    for(Fixed_Pricing__c fp : [SELECT Id,Setup_Fee__c,Setup_Deposit__c,AMC_Fee__c,AMC_Interval__c FROM Fixed_Pricing__c WHERE Commercial2__c = :commercialId]) {
                        FixedPricing fpNew = new FixedPricing();
                        fpNew.key = fp.Id;
                        fpNew.setupFee = fp.Setup_Fee__c != NULL ? String.valueOf(fp.Setup_Fee__c) : '';
                        fpNew.securityDeposit = fp.Setup_Deposit__c != NULL ? String.valueOf(fp.Setup_Deposit__c) : '';
                        fpNew.amcFee = fp.AMC_Fee__c != NULL ? String.valueOf(fp.AMC_Fee__c) : '';
                        fpNew.amcInterval = fp.AMC_Interval__c != NULL ? String.valueOf(fp.AMC_Interval__c) : '';
                        listFixedPricing.add(fpNew);      
                    }
                    Set<String> setInsertedFeeType = new Set<String>();
                    for(Fixed_Pricing1__c fp1 : [SELECT Id,Amount__c,Debit_Model__c,End_Date__c,Fee_Type__c,Flat_Fee__c,Payment_Frequency__c,Percentage__c,Start_Date__c FROM Fixed_Pricing1__c WHERE Commercial__c = :commercialId]) {
                        FixedPricing2 fpNew = new FixedPricing2();
                        fpNew.recordId = fp1.Id;
                        fpNew.endDate = fp1.End_Date__c != NULL ? String.valueOf(fp1.End_Date__c) : '';
                        fpNew.startDate = fp1.Start_Date__c != NULL ? String.valueOf(fp1.Start_Date__c) : '';
                        fpNew.amount = fp1.Amount__c != NULL ? String.valueOf(fp1.Amount__c) : '';
                        fpNew.flatFee = fp1.Flat_Fee__c != NULL ? String.valueOf(fp1.Flat_Fee__c) : '';
                        fpNew.percentage = fp1.Percentage__c != NULL ? String.valueOf(fp1.Percentage__c) : '';
                        fpNew.flatFeeType = fp1.Fee_Type__c;
                        fpNew.paymentFrequency = fp1.Payment_Frequency__c != NULL ? String.valueOf(fp1.Payment_Frequency__c) : '';
                        fpNew.debitModel = fp1.Debit_Model__c != NULL ? String.valueOf(fp1.Debit_Model__c) : '';
                        fpNew.showDeleteButton = false;
                        listFixedPricing2.add(fpNew);    
                        setInsertedFeeType.add(fp1.Fee_Type__c);
                    }
                    
                    for(String feeType : setFlatFeeType) {
                        if(!setInsertedFeeType.contains(feeType)) {
                            FixedPricing2 fp = new FixedPricing2();
                            fp.flatFeeType = feeType;
                            listFixedPricing2.add(fp);    
                        }
                    }
                    
                    for(Fallback_Charge__c fc : [SELECT Id,Payment_Mode__c,Flat_Fee__c,Percentage__c FROM Fallback_Charge__c WHERE Commercial__c =:commercialId]) {
                        FallbackCharges fcObj = new FallbackCharges();
                        fcObj.Id = fc.Id;
                        fcObj.paymentModeName = fc.Payment_Mode__c;
                        fcObj.flatFee = fc.Flat_Fee__c != NULL ? String.valueOf(fc.Flat_Fee__c) : '';
                        fcObj.percentage = fc.Percentage__c != NULL ? String.valueOf(fc.Percentage__c) : '';
                        listFallbackCharges.add(fcObj);
                    }
                    Integer count = 1;
                    for(Platform_Fee__c pf : [SELECT Id,Amount__c,Flat_Fee__c,Percentage__c,Type__c,Interval__c,Start_Date__c,End_Date__c,Debit_Model__c FROM Platform_Fee__c WHERE Commercial__c = :commercialId ORDER BY Amount__c]) {
                        PlatformFee pfObj = new PlatformFee();
                        pfObj.Id = pf.Id;
                        pfObj.amount = pf.Amount__c != NULL ? String.valueOf(pf.Amount__c) : '';
                        pfObj.flatFee = pf.Flat_Fee__c != NULL ? String.valueOf(pf.Flat_Fee__c) : '';
                        pfObj.percentage = pf.Percentage__c != NULL ? String.valueOf(pf.Percentage__c) : '';
                        wrpClsPaymentData.selectedType = pf.Type__c;
                        wrpClsPaymentData.selectedInterval= pf.Interval__c;
                        wrpClsPaymentData.selectedStartDate = pf.Start_Date__c;
                        wrpClsPaymentData.selectedEndDate = pf.End_Date__c;
                        wrpClsPaymentData.selectedDebitModel = pf.Debit_Model__c;
                        if(count == 1) pfObj.disabledAmount = true;
                        count++;
                        listPlatformFee.add(pfObj);    
                    }
                }
                
                wrpClsPaymentData.listFixedPricingString = JSON.serialize(listFixedPricing);
                wrpClsPaymentData.listFallbackChargesString = JSON.serialize(listFallbackCharges);
                wrpClsPaymentData.listPlatformFeeString = JSON.serialize(listPlatformFee);
                wrpClsPaymentData.listFixedPricing2String = JSON.serialize(listFixedPricing2);
                
                Map<String,PaymentDataInner> mapKeyToPaymentDataInner = new Map<String,PaymentDataInner>();
                if(String.isNotBlank(templateId)) {
                    for(Template_Details__c td : [SELECT Id,Payment_Mode__c,Payment_Option__c,Payment_Option__r.Name,Pricing_Specification__c,
                                                  Payment_Gateway2__c,ONUS_OFFUS__c,Pricing_Specification__r.Name,Payment_Gateway2__r.Name,
                                                  Fee_Model__c,Transaction_Type__c,TDR__c,TDR_Amount__c,TDR_Flat_Fee__c,Convenience__c,
                                                  Convenience_Amount__c,Convenience_Flat_Fee__c
                                                  FROM Template_Details__c 
                                                  WHERE Template__c = :templateId AND Deleted__c = false]) {
                                                      //To show multiselect combination in Select Payment Option screen
                                                      String key = td.Payment_Mode__c+'#'+td.Payment_Option__c+'#'+td.Pricing_Specification__c+'#'+td.ONUS_OFFUS__c;
                                                      Boolean isExisting = false;
                                                      List<PaymentDataInner> listDataInner = new List<PaymentDataInner>();
                                                      PaymentDataInner pdi = new PaymentDataInner();
                                                      if(mapKeyToPaymentDataInner.containsKey(key)) {
                                                          pdi = mapKeyToPaymentDataInner.get(key); 
                                                          isExisting = true;  
                                                      }
                                                      if(mapPaymentModeToListDataFromTemplate.containsKey(td.Payment_Mode__c)) {
                                                          if(isExisting) {
                                                              pdi.selectedPaymentGateway += ','+td.Payment_Gateway2__r.Name;  
                                                              if(!pdi.selectedPaymentGatewayList.contains(td.Payment_Gateway2__r.Name)) {
                                                                  pdi.selectedPaymentGatewayList.add(td.Payment_Gateway2__r.Name);    
                                                              }
                                                          }
                                                          else {
                                                              listDataInner = mapPaymentModeToListDataFromTemplate.get(td.Payment_Mode__c);
                                                              pdi.showDeleteButton = true;
                                                              pdi.key = td.Payment_Mode__c+'#'+String.valueOf(listDataInner.size());    
                                                          }
                                                      }	  
                                                      else {
                                                          pdi.key = td.Payment_Mode__c+'#0';
                                                      } 
                                                      
                                                      if(!isExisting) {
                                                          pdi.selectedPaymentOption = td.Payment_Option__r.Name+'#'+td.Payment_Option__c;
                                                          pdi.selectedPaymentOptionId = td.Payment_Option__c;
                                                          pdi.selectedOnusOffus = td.ONUS_OFFUS__c;
                                                          pdi.disablePicklistValues = false;
                                                          pdi.disableSpecificationPicklist = false;
                                                          pdi.selectedSpecifications = td.Pricing_Specification__r.Name;
                                                          pdi.selectedSpecificationsList.add(td.Pricing_Specification__r.Name);
                                                          pdi.disablePaymentGatewayPicklist = false;
                                                          pdi.selectedPaymentGateway = td.Payment_Gateway2__r.Name;
                                                          pdi.selectedPaymentGatewayList.add(td.Payment_Gateway2__r.Name);
                                                          if(mapPaymentModeAndPaymentOptionsToAvailableSpecifications.containsKey(td.Payment_Mode__c+'#'+td.Payment_Option__c)) {
                                                              pdi.listSpecificationToShow = mapPaymentModeAndPaymentOptionsToAvailableSpecifications.get(td.Payment_Mode__c+'#'+td.Payment_Option__c);  
                                                          }
                                                          if(mapPaymentModeOptionsSpecificationToAvailableGateways.containsKey(td.Payment_Mode__c+'#'+td.Payment_Option__c+'#'+td.Pricing_Specification__c)) {
                                                              pdi.listPaymentGatewayToShow = mapPaymentModeOptionsSpecificationToAvailableGateways.get(td.Payment_Mode__c+'#'+td.Payment_Option__c+'#'+td.Pricing_Specification__c);  
                                                          }
                                                          listDataInner.add(pdi);
                                                          mapPaymentModeToListDataFromTemplate.put(td.Payment_Mode__c,listDataInner);    
                                                          mapKeyToPaymentDataInner.put(key,pdi);    
                                                      }
                                                      //End | To show multiselect combination in Select Payment Option screen
                                                      //TDR & Convenience Data to show on the enter TDR screen
                                                      String key1 = td.Payment_Mode__c+'#'+td.Payment_Option__c+'#'+td.Pricing_Specification__r.Name+'#'+td.Payment_Gateway2__r.Name+'#'+td.ONUS_OFFUS__c;
                                                      if(wrpClsPaymentData.mapTDRConvenienceData.containsKey(key1)) {
                                                          Map<String,WrapperClassWithIdentifierToEnableFields> mapInnerMap = wrpClsPaymentData.mapTDRConvenienceData.get(key1);
                                                          String innerKey = td.Fee_Model__c + '#'+td.Transaction_Type__c;
                                                          WrapperClassWithIdentifierToEnableFields wrpClassInner = new WrapperClassWithIdentifierToEnableFields();  
                                                          if(mapInnerMap.containsKey(innerKey)) {
                                                              wrpClassInner = mapInnerMap.get(innerKey);
                                                          }  
                                                          TDRConvenienceData data = getTDRConvenienceData(td);
                                                          wrpClassInner.listTDRConvenienceData.add(data);
                                                          mapInnerMap.put(innerKey,wrpClassInner);
                                                          wrpClsPaymentData.mapTDRConvenienceData.put(key1,mapInnerMap);
                                                      }
                                                      else {
                                                          String innerKey = td.Fee_Model__c + '#' + td.Transaction_Type__c;
                                                          TDRConvenienceData data = getTDRConvenienceData(td);
                                                          List<TDRConvenienceData> listTDRConvenienceData = new List<TDRConvenienceData>();
                                                          listTDRConvenienceData.add(data);
                                                          WrapperClassWithIdentifierToEnableFields wrpClassInner = new WrapperClassWithIdentifierToEnableFields();
                                                          wrpClassInner.listTDRConvenienceData = listTDRConvenienceData;
                                                          Map<String,WrapperClassWithIdentifierToEnableFields> mapInnerMap = new Map<String,WrapperClassWithIdentifierToEnableFields>();
                                                          mapInnerMap.put(innerKey,wrpClassInner);
                                                          wrpClsPaymentData.mapTDRConvenienceData.put(key1,mapInnerMap);  
                                                      }
                                                      //END | TDR & Convenience Data to show on the enter TDR screen
                                                  }    
                }
                else if(String.isNotBlank(commercialId)) {
                    /******added by Rohit :::from below code calling the get api treasury******/
                    List<Commercial2__c> commList  = new   List<Commercial2__c>();
                    commList = [SELECT Id,Opportunity__r.Prod_MID__c,
                                (SELECT Id,Amount__c,Debit_Model__c,End_Date__c,Fee_Type__c,
                                 Flat_Fee__c,Payment_Frequency__c,Percentage__c,Start_Date__c,Rule_Id__c,
                                 Version_Number__c,Source__c FROM Fixed_Pricings__r),
                                (SELECT Id,Amount__c,Rule_Id__c,Flat_Fee__c,Percentage__c,Type__c,
                                 Interval__c,Start_Date__c,Source__c,Version_Number__c,End_Date__c,Debit_Model__c FROM Platform_Fees__r)
                                FROM Commercial2__c WHERE Id=:commercialId LIMIT 1];
                    GetApiTreasuryDataController.PricingWrapper tranformData = GetApiTreasuryDataController.processTreasuryData(commList[0].Opportunity__r.Prod_MID__c,'Conv Fee,tdr,SETUP_FEE,Platform fees');
                    if(tranformData !=NULL){
                        Map<String,Platform_Fee__c> mapOfExistingPlatformFee = new Map<String,Platform_Fee__c>();
                        Map<String,Fixed_Pricing1__c> mapOfExistingFixedPricing = new Map<String,Fixed_Pricing1__c>();
                        if(commList !=NULL && commList.size()>0){
                            for(Commercial2__c comm : commList){
                                if(comm.Fixed_Pricings__r !=null && comm.Fixed_Pricings__r.size()>0){
                                    for(Fixed_Pricing1__c fixedData : comm.Fixed_Pricings__r){
                                        if(fixedData.Rule_Id__c !=NULL)
                                            mapOfExistingFixedPricing.put(fixedData.Rule_Id__c,fixedData);
                                    }
                                }
                                if(comm.Platform_Fees__r !=null && comm.Platform_Fees__r.size()>0){
                                    for(Platform_Fee__c platformFeeData : comm.Platform_Fees__r){
                                        if(platformFeeData.Rule_Id__c !=NULL)
                                            mapOfExistingPlatformFee.put(platformFeeData.Rule_Id__c,platformFeeData);
                                    }
                                }
                            } 
                        }
                        /******added by Rohit ::In this below logic we are checking If fixed pricing is not in salesforce then
get the data nad insert other wise updating the existing recrods*******/
                        List<Fixed_Pricing1__c> fixedPricingList = new  List<Fixed_Pricing1__c>();
                        if(!tranformData.fixedWrapperList.isEmpty()){
                            for(GetApiTreasuryDataController.fixedPricingWrapper fixedDataTreasury : tranformData.fixedWrapperList){
                                Fixed_Pricing1__c fixedPricing;
                                if(mapOfExistingFixedPricing.containsKey(fixedDataTreasury.ruleId)){
                                    fixedPricing = mapOfExistingFixedPricing.get(fixedDataTreasury.ruleId);
                                    if(fixedPricing.Version_Number__c !=fixedDataTreasury.versionNumber){
                                        fixedPricing.Debit_Model__c = fixedDataTreasury.debitModel !=null ? fixedDataTreasury.debitModel :null;
                                        fixedPricing.Version_Number__c = fixedDataTreasury.versionNumber;
                                        fixedPricing.Payment_Frequency__c = fixedDataTreasury.paymentFrequency !=null ? fixedDataTreasury.paymentFrequency:null;
                                        fixedPricing.Source__c = fixedDataTreasury.source !=null ? fixedDataTreasury.source :null;
                                        fixedPricing.Flat_Fee__c = fixedDataTreasury.flatfee !=null ? fixedDataTreasury.flatfee :null;
                                        fixedPricing.Start_Date__c =fixedDataTreasury.startDate !=null ? Date.valueOf(fixedDataTreasury.startDate) :null;
                                        fixedPricing.End_Date__c = fixedDataTreasury.endDate !=null ? Date.valueOf(fixedDataTreasury.endDate) :null;
                                        fixedPricingList.add(fixedPricing);
                                    }
                                }
                                else{
                                    fixedPricing = new Fixed_Pricing1__c();
                                    fixedPricing.Debit_Model__c = fixedDataTreasury.debitModel;
                                    fixedPricing.Version_Number__c = fixedDataTreasury.versionNumber;
                                    fixedPricing.Payment_Frequency__c = fixedDataTreasury.paymentFrequency !=null ? fixedDataTreasury.paymentFrequency:null;
                                    fixedPricing.Published__c = True;
                                    fixedPricing.Rule_Id__c = fixedDataTreasury.ruleId;
                                    fixedPricing.Commercial__c = commercialId;
                                    fixedPricing.Source__c = fixedDataTreasury.source !=null ? fixedDataTreasury.source :null;
                                    fixedPricing.Fee_Type__c = fixedDataTreasury.feeType !=null ? fixedDataTreasury.feeType :null;
                                    fixedPricing.Flat_Fee__c = fixedDataTreasury.flatfee !=null ? fixedDataTreasury.flatfee :null;
                                    fixedPricing.Start_Date__c =fixedDataTreasury.startDate !=null ? Date.valueOf(fixedDataTreasury.startDate) :null;
                                    fixedPricing.End_Date__c = fixedDataTreasury.endDate !=null ? Date.valueOf(fixedDataTreasury.endDate) :null;
                                    fixedPricingList.add(fixedPricing);
                                }
                            }
                            if(fixedPricingList !=NULL && fixedPricingList.size()>0){
                                upsert fixedPricingList;
                            }
                        }
                        /************/
                        /******added by Rohit ::Platform fee In this below logic we are checking If platform pricing is not in salesforce then
using get api treasury we will get the data if data available then  insert other wise updating the existing recrods*******/
                        List<Platform_Fee__c> platformFeeList = new  List<Platform_Fee__c>();
                        if(!tranformData.platformWrapperList.isEmpty()){
                            for(GetApiTreasuryDataController.platFormWrapper platformData : tranformData.platformWrapperList){
                                Platform_Fee__c platformFee;
                                if(mapOfExistingPlatformFee.containsKey(platformData.ruleId)){
                                    platformFee = mapOfExistingPlatformFee.get(platformData.ruleId);
                                    if(platformFee.Version_Number__c != platformData.versionNumber){
                                        platformFee.Debit_Model__c = platformData.debitModel;
                                        platformFee.Amount__c  = platformData.amount !=null ? platformData.amount :null;
                                        platformFee.Version_Number__c = platformData.versionNumber;
                                        platformFee.Interval__c  = platformData.paymentFrequency !=null ? platformData.paymentFrequency : null;
                                        platformFee.Source__c = platformData.source !=null ? platformData.source :null;
                                        platformFee.Flat_Fee__c = platformData.flatfee !=null ? platformData.flatfee : null;
                                        platformFee.Percentage__c = platformData.percentage !=null ? platformData.percentage : null;
                                        platformFee.Start_Date__c = platformData.startDate !=null ? Date.valueOf(platformData.startDate) : null;
                                        platformFee.End_Date__c = platformData.endDate != null ? Date.valueOf(platformData.endDate) :null;
                                        platformFeeList.add(platformFee);
                                    }
                                }
                                else{
                                    platformFee = new Platform_Fee__c();
                                    platformFee.Type__c = 'GMV';
                                    platformFee.Debit_Model__c = platformData.debitModel;
                                    platformFee.Version_Number__c = platformData.versionNumber;
                                    platformFee.Interval__c  = platformData.paymentFrequency !=null ? platformData.paymentFrequency : null;
                                    platformFee.Amount__c  = platformData.amount !=null ? platformData.amount :null;
                                    platformFee.Published__c = True;
                                    platformFee.Rule_Id__c = platformData.ruleId;
                                    platformFee.Commercial__c = commercialId;
                                    platformFee.Source__c = platformData.source !=null ? platformData.source :null;
                                    platformFee.Flat_Fee__c = platformData.flatfee !=null ? platformData.flatfee : null;
                                    platformFee.Percentage__c = platformData.percentage !=null ? platformData.percentage : null;
                                    platformFee.Start_Date__c = platformData.startDate !=null ? Date.valueOf(platformData.startDate) : null;
                                    platformFee.End_Date__c = platformData.endDate != null ? Date.valueOf(platformData.endDate) :null;
                                    platformFeeList.add(platformFee);
                                }
                            }
                            if(platformFeeList !=NULL && platformFeeList.size()>0){
                                upsert platformFeeList;
                            }
                        }
                        /************/
                        if(!tranformData.transformedPricingWrapperPricingList.isEmpty()){
                            Map<String,Pricing__c> mapOfExistingPricingData = new Map<String,Pricing__c>();
                            for(Pricing__c pricingRecord : [SELECT Id,Payment_Mode__c,Payment_Option2__c,Payment_Option2__r.Name,Pricing_Specification__c,
                                                            Payment_Gateway2__c,ONUS__c,Pricing_Specification__r.Name,Payment_Gateway2__r.Name,
                                                            Fee_Model__c,Transaction_Type__c,TDR__c,TDR_Amount__c,TDR_Flat_Fee__c,Convenience__c,
                                                            Convenience_Amount__c,Convenience_Flat_Fee__c,Rule_Id__c,Rule_Id_Conv__c,
                                                            Temp_Id_TDR__c,Temp_Id_Conv__c,Version_Number__c, Banking_Ops_Status__c, 
                                                            Is_Active__c  FROM Pricing__c WHERE Commercial2__c =: commercialId AND (Deleted__c = false OR 
                                                                                                                                    (Deleted__c = true AND (Temp_Id_TDR__c = '' OR Temp_Id_Conv__c = '') ))]){
                                                                                                                                        if(pricingRecord.Rule_Id__c != NULL)
                                                                                                                                            mapOfExistingPricingData.put(pricingRecord.Rule_Id__c,pricingRecord);
                                                                                                                                        if(pricingRecord.Rule_Id_Conv__c != NULL)
                                                                                                                                            mapOfExistingPricingData.put(pricingRecord.Rule_Id_Conv__c,pricingRecord);
                                                                                                                                    }
                            
                            Map<Id,Pricing__c> mapOfpricingToUPdate = new Map<Id,Pricing__c>();
                            List<Pricing__c> newPricingRecordList = new List<Pricing__c>();
                            for(GetApiTreasuryDataController.transformedPricingWrapper tranformDataTreasury : tranformData.transformedPricingWrapperPricingList){
                                Pricing__c pricingExist;
                                if(mapOfExistingPricingData.containsKey(tranformDataTreasury.pricingRuleConfigId)){
                                    pricingExist  = mapOfExistingPricingData.get(tranformDataTreasury.pricingRuleConfigId);
                                    if(pricingExist !=NULL){
                                        if(tranformDataTreasury.revenueModel == 'TDR'){
                                            pricingExist.TDR_Flat_Fee__c  = tranformDataTreasury.tdrFlatFee !=null ? tranformDataTreasury.tdrFlatFee : null;
                                            pricingExist.TDR_Amount__c = tranformDataTreasury.tdrAmount !=null ?  tranformDataTreasury.tdrAmount :null;
                                            pricingExist.TDR__c   = tranformDataTreasury.tdrPercentFee !=null ? Decimal.valueOf(tranformDataTreasury.tdrPercentFee) : null;
                                        }
                                        if(tranformDataTreasury.revenueModel == 'Conv Fee'){
                                            pricingExist.Convenience_Flat_Fee__c   = tranformDataTreasury.convenienceFlatFee !=null ?  tranformDataTreasury.convenienceFlatFee : null;
                                            pricingExist.Convenience_Amount__c  = tranformDataTreasury.convenienceAmount !=null ? tranformDataTreasury.convenienceAmount : null;
                                            pricingExist.Convenience__c   = tranformDataTreasury.conveniencePercentFee !=null ? Decimal.valueOf(tranformDataTreasury.conveniencePercentFee) : null;
                                        }
                                        pricingExist.ONUS__c = tranformDataTreasury.onusOffus !=null ?  tranformDataTreasury.onusOffus :null;
                                        pricingExist.Fee_Model__c = tranformDataTreasury.debitModel !=null ? tranformDataTreasury.debitModel : null;
                                        pricingExist.Version_Number__c  = Decimal.valueOf(tranformDataTreasury.versionNumber);
                                        pricingExist.Published__c = True;
                                        pricingExist.Source__c = tranformDataTreasury.source;
                                        pricingExist.Valid_From__c = tranformDataTreasury.validFrom !=null ? tranformDataTreasury.validFrom : null;
                                        pricingExist.ValidTill__c = tranformDataTreasury.validTill !=null ? tranformDataTreasury.validTill : null;
                                        pricingExist.FromTime__c = tranformDataTreasury.fromTime !=null ? tranformDataTreasury.fromTime : null;
                                        pricingExist.TillTime__c = tranformDataTreasury.tillTime !=null ? tranformDataTreasury.tillTime : null;
                                    }
                                    if((pricingExist.Banking_Ops_Status__c =='Rejected' || pricingExist.Banking_Ops_Status__c =='Rejected with BH') 
                                       && (pricingExist.Rule_Id__c !=NULL || pricingExist.Rule_Id_Conv__c !=NULL)){
                                           pricingExist.Banking_Ops_Status__c = 'Approved';
                                           mapOfpricingToUPdate.put(pricingExist.Id,pricingExist); 
                                       }
                                    else if((pricingExist.Banking_Ops_Status__c =='Approved' || pricingExist.Banking_Ops_Status__c =='Approved with BH') &&
                                            pricingExist.Version_Number__c != Decimal.valueOf(tranformDataTreasury.versionNumber)){
                                                mapOfpricingToUPdate.put(pricingExist.Id,pricingExist); 
                                            }
                                }
                                else{
                                    pricingExist = new Pricing__c();
                                    if(tranformDataTreasury.revenueModel == 'TDR'){
                                        pricingExist.TDR_Flat_Fee__c  = tranformDataTreasury.tdrFlatFee !=null ? tranformDataTreasury.tdrFlatFee : null;
                                        pricingExist.TDR_Amount__c = tranformDataTreasury.tdrAmount !=null ?  tranformDataTreasury.tdrAmount :null;
                                        pricingExist.TDR__c   =tranformDataTreasury.tdrPercentFee !=null ? Decimal.valueOf(tranformDataTreasury.tdrPercentFee) : null;
                                        pricingExist.Transaction_Type__c = 'TDR';
                                        pricingExist.Rule_Id__c = tranformDataTreasury.ruleId;
                                    }
                                    if(tranformDataTreasury.revenueModel == 'Conv Fee'){
                                        pricingExist.Convenience_Flat_Fee__c   = tranformDataTreasury.convenienceFlatFee !=null ?  tranformDataTreasury.convenienceFlatFee : null;
                                        pricingExist.Convenience_Amount__c  = tranformDataTreasury.convenienceAmount !=null ? tranformDataTreasury.convenienceAmount : null;
                                        pricingExist.Convenience__c   = tranformDataTreasury.conveniencePercentFee !=null ? Decimal.valueOf(tranformDataTreasury.conveniencePercentFee) : null;
                                        pricingExist.Transaction_Type__c = 'Convenience';
                                        pricingExist.Rule_Id_Conv__c = tranformDataTreasury.ruleIdConv;
                                    }
                                    pricingExist.Payment_Mode__c = tranformDataTreasury.paymentMode !=null ? tranformDataTreasury.paymentMode :null;
                                    pricingExist.Payment_Option2__c = tranformDataTreasury.paymentOptions !=null ? tranformDataTreasury.paymentOptions : null;
                                    pricingExist.Pricing_Specification__c = tranformDataTreasury.specifications !=null ? tranformDataTreasury.specifications :null;
                                    pricingExist.Payment_Gateway2__c = tranformDataTreasury.paymentGateway !=null ? tranformDataTreasury.paymentGateway :null;
                                    pricingExist.Published__c = True;
                                    pricingExist.Opportunity__c = tranformDataTreasury.recordId;
                                    pricingExist.ONUS__c = tranformDataTreasury.onusOffus !=null ?  tranformDataTreasury.onusOffus :null;
                                    pricingExist.Commercial2__c = commercialId; 
                                    pricingExist.Master_Pricing_Data__c = tranformDataTreasury.mpdId;
                                    pricingExist.Valid_From__c = tranformDataTreasury.validFrom !=null ? tranformDataTreasury.validFrom : null;
                                    pricingExist.ValidTill__c = tranformDataTreasury.validTill !=null ? tranformDataTreasury.validTill : null;
                                    pricingExist.FromTime__c = tranformDataTreasury.fromTime !=null ? tranformDataTreasury.fromTime : null;
                                    pricingExist.TillTime__c = tranformDataTreasury.tillTime !=null ? tranformDataTreasury.tillTime : null; 
                                    pricingExist.Fee_Model__c = tranformDataTreasury.debitModel !=null ? tranformDataTreasury.debitModel : null;
                                    pricingExist.Banking_Ops_Status__c = 'Approved';
                                    pricingExist.Version_Number__c  = Decimal.valueOf(tranformDataTreasury.versionNumber);
                                    pricingExist.Source__c = tranformDataTreasury.source;
                                    newPricingRecordList.add(pricingExist);
                                }
                            }
                            
                            if((newPricingRecordList !=NULL && newPricingRecordList.size()>0) || mapOfpricingToUPdate !=NULL && mapOfpricingToUPdate.size()>0){
                                if(newPricingRecordList !=NULL)
                                    insert newPricingRecordList;
                                if(mapOfpricingToUPdate !=null)
                                    update mapOfpricingToUPdate.values();
                                if(tranformData.publishDetails !=NULL){
                                    Publish_Pricing_Detail__c  pulishPricingDetails = new Publish_Pricing_Detail__c();
                                    pulishPricingDetails.Merchant__c = tranformData.publishDetails.mId ;
                                    pulishPricingDetails.Commercial__c = tranformData.publishDetails.commId ;
                                    pulishPricingDetails.Process__c = tranformData.publishDetails.process ;
                                    pulishPricingDetails.Status__c =  tranformData.publishDetails.status;                             
                                    pulishPricingDetails.Message__c = tranformData.publishDetails.message;
                                    pulishPricingDetails.Response_Body__c = tranformData.publishDetails.responseBody;
                                    pulishPricingDetails.Request_Body__c =  tranformData.publishDetails.requestBody ;
                                    pulishPricingDetails.Request_Count__c = tranformData.publishDetails.requestCount ;
                                    Insert pulishPricingDetails;  
                                }
                            }
                        }
                    }
                    /***********/
                    for(Pricing__c pricing : [SELECT Id,Payment_Mode__c,Payment_Option2__c,Payment_Option2__r.Name,Pricing_Specification__c,
                                              Payment_Gateway2__c,ONUS__c,Pricing_Specification__r.Name,Payment_Gateway2__r.Name,
                                              Fee_Model__c,Transaction_Type__c,TDR__c,TDR_Amount__c,TDR_Flat_Fee__c,Convenience__c,
                                              Convenience_Amount__c,Convenience_Flat_Fee__c,Rule_Id__c,Rule_Id_Conv__c,
                                              Temp_Id_TDR__c,Temp_Id_Conv__c
                                              FROM Pricing__c 
                                              WHERE Commercial2__c	 = :commercialId AND Deleted__c = false AND Invisible__c = false ORDER BY TDR_Amount__c,Convenience_Amount__c]) {
                                                  //To show multiselect combination in Select Payment Option screen
                                                  String key = pricing.Payment_Mode__c+'#'+pricing.Payment_Option2__c+'#'+pricing.Pricing_Specification__c+'#'+pricing.ONUS__c;
                                                  Boolean isExisting = false;
                                                  List<PaymentDataInner> listDataInner = new List<PaymentDataInner>();
                                                  PaymentDataInner pdi = new PaymentDataInner();
                                                  //Addition of Pricing Id to support edit of the commercial
                                                  pdi.pricingId = pricing.Id;
                                                  if(mapKeyToPaymentDataInner.containsKey(key)) {
                                                      pdi = mapKeyToPaymentDataInner.get(key); 
                                                      isExisting = true;  
                                                  }
                                                  if(mapPaymentModeToListDataFromTemplate.containsKey(pricing.Payment_Mode__c)) {
                                                      if(isExisting) {
                                                          pdi.selectedPaymentGateway += ','+pricing.Payment_Gateway2__r.Name;  
                                                          if(!pdi.selectedPaymentGatewayList.contains(pricing.Payment_Gateway2__r.Name)) {
                                                              pdi.selectedPaymentGatewayList.add(pricing.Payment_Gateway2__r.Name);    
                                                          }
                                                      }
                                                      else {
                                                          listDataInner = mapPaymentModeToListDataFromTemplate.get(pricing.Payment_Mode__c);
                                                          pdi.showDeleteButton = true;
                                                          pdi.key = pricing.Payment_Mode__c+'#'+String.valueOf(listDataInner.size());    
                                                      }
                                                  }	  
                                                  else {
                                                      pdi.key = pricing.Payment_Mode__c+'#0';
                                                  } 
                                                  
                                                  if(!isExisting) {
                                                      pdi.selectedPaymentOption = pricing.Payment_Option2__r.Name+'#'+pricing.Payment_Option2__c;
                                                      pdi.selectedPaymentOptionId = pricing.Payment_Option2__c;
                                                      pdi.selectedOnusOffus = pricing.ONUS__c;
                                                      pdi.disablePicklistValues = false;
                                                      pdi.disableSpecificationPicklist = false;
                                                      pdi.selectedSpecifications = pricing.Pricing_Specification__r.Name;
                                                      pdi.selectedSpecificationsList.add(pricing.Pricing_Specification__r.Name);
                                                      pdi.disablePaymentGatewayPicklist = false;
                                                      pdi.selectedPaymentGateway = pricing.Payment_Gateway2__r.Name;
                                                      pdi.selectedPaymentGatewayList.add(pricing.Payment_Gateway2__r.Name);
                                                      if(mapPaymentModeAndPaymentOptionsToAvailableSpecifications.containsKey(pricing.Payment_Mode__c+'#'+pricing.Payment_Option2__c)) {
                                                          pdi.listSpecificationToShow = mapPaymentModeAndPaymentOptionsToAvailableSpecifications.get(pricing.Payment_Mode__c+'#'+pricing.Payment_Option2__c);  
                                                      }
                                                      if(mapPaymentModeOptionsSpecificationToAvailableGateways.containsKey(pricing.Payment_Mode__c+'#'+pricing.Payment_Option2__c+'#'+pricing.Pricing_Specification__c)) {
                                                          pdi.listPaymentGatewayToShow = mapPaymentModeOptionsSpecificationToAvailableGateways.get(pricing.Payment_Mode__c+'#'+pricing.Payment_Option2__c+'#'+pricing.Pricing_Specification__c);  
                                                      }
                                                      listDataInner.add(pdi);
                                                      mapPaymentModeToListDataFromTemplate.put(pricing.Payment_Mode__c,listDataInner);    
                                                      mapKeyToPaymentDataInner.put(key,pdi);    
                                                  }
                                                  //End | To show multiselect combination in Select Payment Option screen
                                                  //TDR & Convenience Data to show on the enter TDR screen
                                                  String key1 = pricing.Payment_Mode__c+'#'+pricing.Payment_Option2__c+'#'+pricing.Pricing_Specification__r.Name+'#'+pricing.Payment_Gateway2__r.Name+'#'+pricing.ONUS__c;
                                                  if(wrpClsPaymentData.mapTDRConvenienceData.containsKey(key1)) {
                                                      Map<String,WrapperClassWithIdentifierToEnableFields> mapInnerMap = wrpClsPaymentData.mapTDRConvenienceData.get(key1);
                                                      String innerKey = pricing.Fee_Model__c + '#'+pricing.Transaction_Type__c;
                                                      WrapperClassWithIdentifierToEnableFields wrpClassInner = new WrapperClassWithIdentifierToEnableFields(); 
                                                      if(mapInnerMap.containsKey(innerKey)) {
                                                          wrpClassInner = mapInnerMap.get(innerKey);
                                                      }  
                                                      TDRConvenienceData data = getTDRConvenienceDataPricing(pricing,wrpClassInner);
                                                      wrpClassInner.listTDRConvenienceData.add(data);
                                                      mapInnerMap.put(innerKey,wrpClassInner);
                                                      wrpClsPaymentData.mapTDRConvenienceData.put(key1,mapInnerMap);
                                                  }
                                                  else {
                                                      String innerKey = pricing.Fee_Model__c + '#' + pricing.Transaction_Type__c;
                                                      WrapperClassWithIdentifierToEnableFields wrpClassInner = new WrapperClassWithIdentifierToEnableFields();
                                                      TDRConvenienceData data = getTDRConvenienceDataPricing(pricing,wrpClassInner);
                                                      List<TDRConvenienceData> listTDRConvenienceData = new List<TDRConvenienceData>();
                                                      listTDRConvenienceData.add(data);
                                                      //WrapperClassWithIdentifierToEnableFields wrpClassInner = new WrapperClassWithIdentifierToEnableFields();
                                                      wrpClassInner.listTDRConvenienceData = listTDRConvenienceData;
                                                      Map<String,WrapperClassWithIdentifierToEnableFields> mapInnerMap = new Map<String,WrapperClassWithIdentifierToEnableFields>();
                                                      mapInnerMap.put(innerKey,wrpClassInner);
                                                      wrpClsPaymentData.mapTDRConvenienceData.put(key1,mapInnerMap);  
                                                  }
                                                  //END | TDR & Convenience Data to show on the enter TDR screen
                                              }     
                }
            }
            //---------------------End | To enable the data load from the template
            
            Set<Id> setPaymentModeId =new Set<Id>();
            for(Master_Pricing_Data__c mpd : [SELECT Id,Name,Payment_Mode__c,Payment_Mode__r.Name FROM Master_Pricing_Data__c WHERE Payment_Mode__c != NULL AND Active_Instrument__c = true LIMIT 50000]) {
                if(!setPaymentModeId.contains(mpd.Payment_Mode__c)) {
                    PaymentData pd = new PaymentData();
                    //Added by Anas Yar Khan | To Load the data from Template
                    if(mapPaymentModeToListDataFromTemplate.containsKey(mpd.Payment_Mode__c)) {
                        pd.isChecked = true; 
                        pd.listPaymentDataInner = mapPaymentModeToListDataFromTemplate.get(mpd.Payment_Mode__c);
                    }
                    //--------------------End | To Load the data from Template
                    //PaymentDataInner paymentDataInner = new PaymentDataInner();
                    //Added by Anas Yar Khan | To enable the load of the data from the template
                    if(!pd.isChecked) {
                        PaymentDataInner paymentDataInner = new PaymentDataInner();
                        paymentDataInner.key = mpd.Payment_Mode__c+'#0';
                        pd.listPaymentDataInner.add(paymentDataInner);
                    }
                    //------------------End------------------------------
                    //paymentDataInner.key = mpd.Payment_Mode__c+'#0';//Commented for loading of the data from the template
                    //pd.listPaymentDataInner.add(paymentDataInner);
                    wrpClsPaymentData.listPaymentData.add(pd);
                    pd.paymentMode = mpd.Payment_Mode__r.Name;    
                    pd.key = mpd.Payment_Mode__c;
                    wrpClsPaymentData.mapPaymentModeIdToPaymentDataWrapper.put(mpd.Payment_Mode__c,pd); 
                    setPaymentModeId.add(mpd.Payment_Mode__c);    
                }
            }
            
            Map<Id,Payment_Option2__c> mapIdToPaymentOption = new Map<Id,Payment_Option2__c>([SELECT Id,Name FROM Payment_Option2__c LIMIT 50000]);
            
            for(Master_Pricing_Data__c mpd : [SELECT Id,Name,Payment_Mode__c,Payment_Option__c FROM Master_Pricing_Data__c WHERE Payment_Mode__c != NULL AND Payment_Option__c != NULL AND Active_Instrument__c = true ORDER BY Payment_Option__r.Default__c DESC LIMIT 50000]) {
                if(wrpClsPaymentData.mapPaymentModeIdToPaymentDataWrapper.keySet().size() > 0 && wrpClsPaymentData.mapPaymentModeIdToPaymentDataWrapper.containsKey(mpd.Payment_Mode__c)) {
                    PaymentData paymentData = wrpClsPaymentData.mapPaymentModeIdToPaymentDataWrapper.get(mpd.Payment_Mode__c);
                    if(!paymentData.listPaymentDataInner[0].listPaymentOptions.contains(mapIdToPaymentOption.get(mpd.Payment_Option__c))) {
                        paymentData.listPaymentDataInner[0].listPaymentOptions.add(mapIdToPaymentOption.get(mpd.Payment_Option__c));    
                    }
                }	    
            }
            
            if(wrpClsPaymentData.mapPaymentModeIdToPaymentDataWrapper.keySet().size() > 0) {
                for(Id paymentModeId : wrpClsPaymentData.mapPaymentModeIdToPaymentDataWrapper.keySet()) {
                    PaymentData paymentData = wrpClsPaymentData.mapPaymentModeIdToPaymentDataWrapper.get(paymentModeId);
                    if(paymentData.listPaymentDataInner[0].listPaymentOptions.size() > 0) {
                        for(Payment_Option2__c paymentOption : paymentData.listPaymentDataInner[0].listPaymentOptions) {
                            PicklistValues pick = new PicklistValues();
                            pick.label = paymentOption.Name;
                            pick.value = paymentOption.Name+'#'+paymentOption.Id;
                            //paymentData.listPaymentDataInner[0].listPaymentOptionsToShow.add(pick);//Commented by Anas Yar Khan | To enabled the load of the data from the template
                            
                            //Added by Anas Yar Khan | To enabled the load of the data from the template
                            for(Integer i=0;i<paymentData.listPaymentDataInner.size();i++) {
                                paymentData.listPaymentDataInner[i].listPaymentOptionsToShow.add(pick); 
                                paymentData.listPaymentDataInner[i].listOnusOffusToShow = listOnusOffus;
                            }
                            //----------------------------End-------------------------------------------
                        }
                    }
                    
                    //paymentData.listPaymentDataInner[0].listOnusOffusToShow = listOnusOffus; //Commented by Anas Yar Khan | To enabled the load of the data from the template
                }
            }
        }
        catch(Exception e) {
            wrpClsPaymentData.message = e.getMessage(); 
        }
        return wrpClsPaymentData;
    }
    
    /*
* Description       : Wrapper class to return data for Screen 3 Part 1
* Version.          : 1   
*/
    public class WrapperClassPaymentData {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public List<PaymentData> listPaymentData = new List<PaymentData>();
        @AuraEnabled public Map<Id,PaymentData> mapPaymentModeIdToPaymentDataWrapper = new Map<Id,PaymentData>();
        //Enable loading of TDR and Convenience from the template
        @AuraEnabled public Map<String,Map<String,WrapperClassWithIdentifierToEnableFields>> mapTDRConvenienceData = new Map<String,Map<String,WrapperClassWithIdentifierToEnableFields>>();
        @AuraEnabled public String listFixedPricingString = '';
        @AuraEnabled public String listFixedPricing2String = '';
        @AuraEnabled public String listPlatformFeeString = '';
        @AuraEnabled public String listFallbackChargesString = '';
        @AuraEnabled public String selectedType = '';
        @AuraEnabled public String selectedInterval = '';
        @AuraEnabled public Date selectedStartDate = Date.today(); 
        @AuraEnabled public Date selectedEndDate = Date.today(); 
        @AuraEnabled public String selectedDebitModel = '';
        @AuraEnabled public Boolean editAllowed = true;
        //End | Enable loading of TDR and Convenience from the template
    }
    
    //Wrapper class to return data for Screen 3 Part 1
    public class PaymentData {
        @AuraEnabled public String key = '';
        @AuraEnabled public Boolean isChecked = false;
        @AuraEnabled public String paymentMode = '';
        @AuraEnabled public List<PaymentDataInner> listPaymentDataInner = new List<PaymentDataInner>();
    }
    
    //Wrapper class to return data for Screen 3 Part 1
    public class PaymentDataInner {
        @AuraEnabled public String key = '';
        @AuraEnabled public List<PicklistValues> listPaymentOptionsToShow = new List<PicklistValues>();
        @AuraEnabled public List<Payment_Option2__c> listPaymentOptions = new List<Payment_Option2__c>();
        @AuraEnabled public List<PicklistValues> listPaymentGatewayToShow = new List<PicklistValues>();
        @AuraEnabled public List<PicklistValues> listOnusOffusToShow = new List<PicklistValues>();
        @AuraEnabled public List<Payment_Gateway_To_Mode_mapping__c> listPaymentModeToPaymentGateways = new List<Payment_Gateway_To_Mode_mapping__c>();
        @AuraEnabled public Boolean disablePicklistValues = true;
        @AuraEnabled public Boolean disableSpecificationPicklist = true;
        @AuraEnabled public Boolean disablePaymentGatewayPicklist = true;
        @AuraEnabled public String selectedPaymentOption = '';
        @AuraEnabled public String selectedPaymentOptionId = '';
        @AuraEnabled public String selectedPaymentGateway = '';
        @AuraEnabled public String selectedOnusOffus = '';
        @AuraEnabled public List<PicklistValues> listSpecificationToShow = new List<PicklistValues>();
        @AuraEnabled public String selectedSpecifications = '';
        @AuraEnabled public Boolean showDeleteButton = false;
        @AuraEnabled public List<String> selectedSpecificationsList = new List<String>();
        @AuraEnabled public List<String> selectedPaymentGatewayList = new List<String>();
        //Addition of new attribute to support edit of the commercial
        @AuraEnabled public String pricingId = '';
    }
    
    //Wrapper class to return data for Screen 3 Part 1
    public class PicklistValues {
        @AuraEnabled public String label = '';
        @AuraEnabled public String value = '';
        @AuraEnabled public String type = '';// added by rohit
    }
    
    //Wrapper class to identify the enable of edit of the fields
    public class WrapperClassWithIdentifierToEnableFields {
        @AuraEnabled public Boolean restrictTransactionTypeAndFeeModel = false;
        @AuraEnabled public List<TDRConvenienceData> listTDRConvenienceData = new List<TDRConvenienceData>();
    }
    
    //Wrapper clas to return data of TDR and Convenience if the data is loading from the template
    public class TDRConvenienceData {
        @AuraEnabled public Decimal tdrPercentage = 0;
        @AuraEnabled public Decimal tdrAmount = 0;
        @AuraEnabled public Decimal tdrFlatFee = 0;
        @AuraEnabled public Decimal conveniencePercentage = 0;
        @AuraEnabled public Decimal convenienceAmount = 0;
        @AuraEnabled public Decimal convenienceFlatFee = 0;
        //Addition to support the edit of the Commercial
        @AuraEnabled public String pricingId = '';
        //Added to make allow edit of the few fields on the enter tdr components - UI Changes New
        @AuraEnabled public Boolean isSelectPaymentOption = false;// added by rohit 23rd may
        @AuraEnabled public Boolean restrictFlatFeeAndPercentageToBeEdited = false;
        @AuraEnabled public Boolean restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited = false;
        @AuraEnabled public String ruleStatus = 'D';
        @AuraEnabled public String textColor = 'color:yellow;';
    }
    
    //This method is called internally to get the instance of the
    private static TDRConvenienceData getTDRConvenienceData(Template_Details__c td) {
        TDRConvenienceData data = new TDRConvenienceData();
        data.tdrPercentage = td.TDR__c;
        data.tdrAmount = td.TDR_Amount__c;
        data.tdrFlatFee = td.TDR_Flat_Fee__c;
        data.conveniencePercentage = td.Convenience__c;
        data.convenienceAmount = td.Convenience_Amount__c;
        data.convenienceFlatFee = td.Convenience_Flat_Fee__c;
        return data;
    }
    
    //This method is called internally to get the instance of the
    private static TDRConvenienceData getTDRConvenienceDataPricing(Pricing__c pricing,WrapperClassWithIdentifierToEnableFields wrpClassInner) {
        TDRConvenienceData data = new TDRConvenienceData();
        data.tdrPercentage = pricing.TDR__c;
        data.tdrAmount = pricing.TDR_Amount__c;
        data.tdrFlatFee = pricing.TDR_Flat_Fee__c;
        data.conveniencePercentage = pricing.Convenience__c;
        data.convenienceAmount = pricing.Convenience_Amount__c;
        data.convenienceFlatFee = pricing.Convenience_Flat_Fee__c;
        //Addition of the pricingId to support the edit of the commercial
        data.pricingId = pricing.Id;
        //Added to make allow edit of the few fields on the enter tdr components - UI Changes New
        if(pricing.Transaction_Type__c == 'TDR' || pricing.Transaction_Type__c == 'TDR + Convenience') {
            if(String.isNotBlank(pricing.Rule_Id__c) && String.isBlank(pricing.Temp_Id_TDR__c)) {
                data.restrictFlatFeeAndPercentageToBeEdited = false;
                data.restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited = true;
                data.ruleStatus = 'P';
                data.textColor = 'color:rgb(144, 238, 144);';
                if(!wrpClassInner.restrictTransactionTypeAndFeeModel){
                    wrpClassInner.restrictTransactionTypeAndFeeModel = true;	    
                }
            }   
            else if(String.isNotBlank(pricing.Temp_Id_TDR__c)) {
                data.restrictFlatFeeAndPercentageToBeEdited = true;
                data.restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited = true; 
                data.ruleStatus = 'AA';
                data.textColor = 'color:orange;';
                if(!wrpClassInner.restrictTransactionTypeAndFeeModel){
                    wrpClassInner.restrictTransactionTypeAndFeeModel = true;	    
                }
            }
        }
        else if(pricing.Transaction_Type__c == 'Convenience') {
            if(String.isNotBlank(pricing.Rule_Id_Conv__c) && String.isBlank(pricing.Temp_Id_Conv__c)) {
                data.restrictFlatFeeAndPercentageToBeEdited = false;
                data.restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited = true;
                data.ruleStatus = 'P';
                data.textColor = 'color:rgb(144, 238, 144);';
                if(!wrpClassInner.restrictTransactionTypeAndFeeModel){
                    wrpClassInner.restrictTransactionTypeAndFeeModel = true;	    
                }
            }   
            else if(String.isNotBlank(pricing.Temp_Id_Conv__c)) {
                data.restrictFlatFeeAndPercentageToBeEdited = true;
                data.restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited = true;  
                data.ruleStatus = 'AA';
                data.textColor = 'color:orange;';
                if(!wrpClassInner.restrictTransactionTypeAndFeeModel){
                    wrpClassInner.restrictTransactionTypeAndFeeModel = true;	    
                }
            }    
        }
        return data;
    }
    
    //This method is called on change of the payment options to get all its related specifications, Screen 3 Part 1
    @AuraEnabled(cacheable=true)
    public static WrapperSpecification getSpecificationDetails(String paymentModeId,String paymentOptionId) {
        WrapperSpecification wrpSpc = new WrapperSpecification();
        try {
            Set<Id> setSpecificationId = new Set<Id>();
            for(Master_Pricing_Data__c mpd : [SELECT Id,Pricing_Specification__c,Pricing_Specification__r.Name FROM Master_Pricing_Data__c WHERE Payment_Mode__c = :paymentModeId AND Payment_Option__c =:paymentOptionId AND Active_Instrument__c = true ORDER BY Pricing_Specification__r.Default__c DESC LIMIT 50000]) {
                if(!setSpecificationId.contains(mpd.Pricing_Specification__c)) {
                    PicklistValues pick = new PicklistValues();
                    pick.label = mpd.Pricing_Specification__r.Name;
                    pick.value = mpd.Pricing_Specification__r.Name;
                    wrpSpc.listSpecifications.add(pick); 
                    setSpecificationId.add(mpd.Pricing_Specification__c);
                }
            }
            /************Added By Rohit**********/
            PicklistValues selectAll = new PicklistValues();
            selectAll.label = 'Select All';
            selectAll.value = 'Select All';
            wrpSpc.listSpecifications.add(0,selectAll); 
            /*****************END*******************/
        }
        catch(exception e) {
            wrpSpc.message = e.getMessage();    
        }
        return wrpSpc;
    }
    
    //Wrapper class to return Specifications for a particular Payment Options
    public class WrapperSpecification {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public List<PicklistValues> listSpecifications = new List<PicklistValues>();
    }
    
    /*
* Description       : This method is called on click of Save Pricing to save the records in the database
* Version.          : 1   
*/
    @AuraEnabled
    public static SavePricingWrapper savePricingApex(String selectedListPaymentData,String recordId,String commercialName,String selectedTemplate,String commercialId) {
        SavePricingWrapper wrpCls = new SavePricingWrapper();
        wrpCls.message = 'SUCCESS';
        try{
            Set<Id> setAllPricingIds = new Set<Id>();
            Set<Id> setPricingIdsNeedsToBeRetain = new Set<Id>();
            Map<Id,Pricing__c> mapIdToPricing;
            if(String.isNotBlank(commercialId)) mapIdToPricing = new Map<Id,Pricing__c>([SELECT Id,Banking_Ops_Status__c,TDR__c,TDR_Flat_Fee__c,Convenience__c,Convenience_Flat_Fee__c FROM Pricing__c WHERE Commercial2__c = :commercialId AND Invisible__c = false AND Deleted__c = false]); 
            if(mapIdToPricing != NULL && mapIdToPricing.keySet().size() > 0) setAllPricingIds =  mapIdToPricing.keySet();
            String source = 'Scratch';
            if(String.isNotBlank(selectedTemplate)) {
                List<Pricing_Template__c> listTemplate = [SELECT Name FROM Pricing_Template__c WHERE Id = :selectedTemplate];
                source = listTemplate[0].Name;
            }
            List<Opportunity> listOpportunity = [SELECT Id,Bank_Category__c,Bank_Category__r.Name FROM Opportunity WHERE Id =:recordId];
            String bankCategory = 'Default';
            if(listOpportunity != NULL && listOpportunity.size() > 0) if(listOpportunity[0].Bank_Category__c != NULL) {
                if(listOpportunity[0].Bank_Category__r.Name == 'Credit Card Bill Payment') {
                    bankCategory = 'CCBP';     
                }
                else {
                    bankCategory = listOpportunity[0].Bank_Category__r.Name;     
                }
            }
            
            //Enable the last status of the post approved records
            Map<String,Integer> mapBankAndPORTypeToStatus = getMapBankAndPORTypeToStatus(recordId);
            //------------End | Enable the last status of the post approved records
            
            Map<String,Bank_Category_Mapping_With_Master_Fields__mdt> mapUniqueIdentifierToCustomMetadataRecords = new Map<String,Bank_Category_Mapping_With_Master_Fields__mdt>();
            for(Bank_Category_Mapping_With_Master_Fields__mdt customMetadataRecord : [SELECT Label,Percentage__c,Flat_Fee__c FROM Bank_Category_Mapping_With_Master_Fields__mdt]) {
                mapUniqueIdentifierToCustomMetadataRecords.put(customMetadataRecord.Label,customMetadataRecord);    
            }
            
            Map<String,Payment_Gateway2__c> mapIdentifierToPaymentGatewayId = new Map<String,Payment_Gateway2__c>();
            for(Payment_Gateway2__c pg : [SELECT Id,Name,Type__c FROM Payment_Gateway2__c LIMIT 50000]) {
                mapIdentifierToPaymentGatewayId.put(pg.Name,pg);    
            }
            
            Map<String,Id> mapIdentifierToPricingSpecificationId = new Map<String,Id>();
            for(Pricing_Specification__c ps : [SELECT Id,Name FROM Pricing_Specification__c LIMIT 50000]) {
                mapIdentifierToPricingSpecificationId.put(ps.Name,ps.Id);     
            }
            
            Map<String,Master_Pricing_Data__c> mapIdentifierToMasterPricingDataId = new Map<String,Master_Pricing_Data__c>();
            for(Master_Pricing_Data__c mpd : [SELECT Id,Salesforce_Primary_Key__c,Payment_Mode__c,Payment_Option__c,Payment_Gateway__c,Pricing_Specification__c,
                                              Donation_0_Flat__c,Donation_0_Percentage__c,Payment_Gateway_Type__c,Default_Reck_Rate_Flat__c,Default_Reck_Rate_Percentage__c,
                                              E_Commerce_0_Flat__c,E_Commerce_2000_Flat__c,E_Commerce_0_Percentage__c,E_Commerce_2000_Percentage__c,B2B_0_Flat__c,B2B_0_Percentage__c,
                                              B2B_2000_Flat__c,B2B_2000_Percentage__c,CCBill_Payment_0_Flat__c,CCBill_Payment_0_Percentage__c,CCBill_Payment_2000_Flat__c,
                                              CCBill_Payment_2000_Percentage__c, Financial_0_Flat__c, Financial_0_Percentage__c, Financial_2000_Flat__c, Financial_2000_Percentage__c, 
                                              Govt_0_Flat__c, Govt_0_Percentage__c, Govt_2000_Flat__c, Govt_2000_Percentage__c, Govt_Education_0_Flat__c, Govt_Education_0_Percentage__c, 
                                              Govt_Education_2000_Flat__c, Govt_Education_2000_Percentage__c, Govt_Utility_0_Flat__c, Govt_Utility_0_Percentage__c, Govt_Utility_2000_Flat__c, 
                                              Govt_Utility_2000_Percentage__c, Grocery_0_Flat__c, Grocery_0_Percentage__c, Grocery_2000_Flat__c, Grocery_2000_Percentage__c, 
                                              Housing_Societies_0_Flat__c, Housing_Societies_0_Percentage__c, Housing_Societies_2000_Flat__c, Housing_Societies_2000_Percentage__c, 
                                              Insurance_0_Flat__c, Insurance_0_Percentage__c, Insurance_2000_Flat__c, Insurance_2000_Percentage__c, 
                                              Private_Education_0_Flat__c, Private_Education_0_Percentage__c, Private_Education_2000_Flat__c, 
                                              Private_Education_2000_Percentage__c, Pvt_Utility_0_Flat__c, Pvt_Utility_0_Percentage__c, Pvt_Utility_2000_Flat__c, Pvt_Utility_2000_Percentage__c, 
                                              Recharge_0_Flat__c, Recharge_0_Percentage__c, Recharge_2000_Flat__c, Recharge_2000_Percentage__c, Travel_0_Flat__c, Travel_0_Percentage__c, 
                                              Travel_2000_Flat__c, Travel_2000_Percentage__c, Wallet_0_Flat__c, Wallet_0_Percentage__c, Wallet_2000_Flat__c, Wallet_2000_Percentage__c, 
                                              Donation_2000_Flat__c, Donation_2000_Percentage__c, Loan_0_Flat__c, Loan_0_Percentage__c, Loan_2000_Flat__c, Loan_2000_Percentage__c, 
                                              Mutual_Funds_0_Flat__c, Mutual_Funds_0_Percentage__c, Mutual_Funds_2000_Flat__c, Mutual_Funds_2000_Percentage__c, ONUS_OFFUS__c,
                                              Bank__c,POR_Type__c
                                              FROM Master_Pricing_Data__c WHERE Active_Instrument__c = true LIMIT 50000]) {
                                                  mapIdentifierToMasterPricingDataId.put(mpd.Payment_Mode__c+'#'+mpd.Payment_Option__c+'#'+mpd.Pricing_Specification__c+'#'+mpd.Payment_Gateway__c+'#'+mpd.ONUS_OFFUS__c,mpd);	    
                                              }
            
            if(String.isBlank(commercialId)) {
                Commercial2__c commercial = new Commercial2__c();
                commercial.Name = commercialName;
                commercial.Opportunity__c = recordId;
                commercial.Status__c = 'Draft';
                commercial.Source__c = source;
                commercial.TemplateId__c = selectedTemplate;
                commercial.Last_Edited_On__c = System.now();
                insert commercial;
                commercialId = commercial.Id;
                
                List<Fallback_Charge__c> listFallbackCharges = new List<Fallback_Charge__c>();
                for(Fallback_Payment_Mode__c  pm : [SELECT Id,Name FROM Fallback_Payment_Mode__c]) {
                    Fallback_Charge__c fc = new Fallback_Charge__c();
                    fc.Payment_Mode__c = pm.Name;
                    fc.Commercial__c = commercialId;
                    listFallbackCharges.add(fc);
                }
                
                //if(listFallbackCharges.size() > 0) insert listFallbackCharges;
                
                Platform_Fee__c pf = new Platform_Fee__c();
                pf.Amount__c = 0;
                pf.Commercial__c = commercialId;
                insert pf;
            }
            else {
                Commercial2__c commercial = new Commercial2__c();
                commercial.Id = commercialId;
                commercial.Last_Edited_On__c = System.now();
                commercial.Edited__c = true;
                update commercial;
            }
            
            List<FallbackCharges> listFallbackCharges = new List<FallbackCharges>();        
            List<PlatformFee> listPlatformFee = new List<PlatformFee>(); 
            List<FixedPricing2> listFixedPricing2 = new List<FixedPricing2>();
            
            Set<String> setInsertedFeeType = new Set<String>();
            for(Fixed_Pricing1__c fp1 : [SELECT Id,Amount__c,Debit_Model__c,End_Date__c,Fee_Type__c,Flat_Fee__c,Payment_Frequency__c,Percentage__c,Start_Date__c FROM Fixed_Pricing1__c WHERE Commercial__c = :commercialId]) {
                FixedPricing2 fpNew = new FixedPricing2();
                fpNew.recordId = fp1.Id;
                fpNew.endDate = fp1.End_Date__c != NULL ? String.valueOf(fp1.End_Date__c) : '';
                fpNew.startDate = fp1.Start_Date__c != NULL ? String.valueOf(fp1.Start_Date__c) : '';
                fpNew.amount = fp1.Amount__c != NULL ? String.valueOf(fp1.Amount__c) : '';
                fpNew.flatFee = fp1.Flat_Fee__c != NULL ? String.valueOf(fp1.Flat_Fee__c) : '';
                fpNew.percentage = fp1.Percentage__c != NULL ? String.valueOf(fp1.Percentage__c) : '';
                fpNew.flatFeeType = fp1.Fee_Type__c;
                fpNew.paymentFrequency = fp1.Payment_Frequency__c != NULL ? String.valueOf(fp1.Payment_Frequency__c) : '';
                fpNew.debitModel = fp1.Debit_Model__c != NULL ? String.valueOf(fp1.Debit_Model__c) : '';
                fpNew.showDeleteButton = false;
                listFixedPricing2.add(fpNew);    
                setInsertedFeeType.add(fp1.Fee_Type__c);
            }
            
            for(String feeType : setFlatFeeType) {
                if(!setInsertedFeeType.contains(feeType)) {
                    FixedPricing2 fp = new FixedPricing2();
                    fp.flatFeeType = feeType;
                    listFixedPricing2.add(fp);    
                }
            }
            
            for(Fallback_Charge__c fc : [SELECT Id,Payment_Mode__c,Flat_Fee__c,Percentage__c FROM Fallback_Charge__c WHERE Commercial__c =:commercialId]) {
                FallbackCharges fcObj = new FallbackCharges();
                fcObj.Id = fc.Id;
                fcObj.paymentModeName = fc.Payment_Mode__c;
                fcObj.flatFee = fc.Flat_Fee__c != NULL ? String.valueOf(fc.Flat_Fee__c) : '';
                fcObj.percentage = fc.Percentage__c != NULL ? String.valueOf(fc.Percentage__c) : '';
                listFallbackCharges.add(fcObj);
            }
            
            Integer count1 = 1;
            for(Platform_Fee__c pf : [SELECT Id,Amount__c,Flat_Fee__c,Percentage__c,Type__c,Interval__c,Start_Date__c,End_Date__c,Debit_Model__c FROM Platform_Fee__c WHERE Commercial__c = :commercialId ORDER BY Amount__c]) {
                PlatformFee pfObj = new PlatformFee();
                pfObj.Id = pf.Id;
                pfObj.amount = pf.Amount__c != NULL ? String.valueOf(pf.Amount__c) : '';
                pfObj.flatFee = pf.Flat_Fee__c != NULL ? String.valueOf(pf.Flat_Fee__c) : '';
                pfObj.percentage = pf.Percentage__c != NULL ? String.valueOf(pf.Percentage__c) : '';
                wrpCls.selectedType = pf.Type__c;
                wrpCls.selectedInterval= pf.Interval__c;
                wrpCls.selectedStartDate = pf.Start_Date__c;
                wrpCls.selectedEndDate = pf.End_Date__c;
                wrpCls.selectedDebitModel = pf.Debit_Model__c;
                if(count1 == 1) pfObj.disabledAmount = true;
                count1++;
                listPlatformFee.add(pfObj);    
            }
            
            wrpCls.listFallbackChargesString = JSON.serialize(listFallbackCharges);
            wrpCls.listPlatformFeeString = JSON.serialize(listPlatformFee);
            wrpCls.listFixedPricing2String = JSON.serialize(listFixedPricing2);
            
            Schema.DescribeFieldResult platformFeeIntervalDescribe = Platform_Fee__c.Interval__c.getDescribe();
            List<Schema.PicklistEntry> platformFeeIntervalPicklistValues = platformFeeIntervalDescribe.getPickListValues();
            for (Schema.PicklistEntry objPickList : platformFeeIntervalPicklistValues) {
                PicklistValues pick = new PicklistValues();
                pick.label = objPickList.getLabel();
                pick.value = objPickList.getValue();
                wrpCls.listPlatformFeeInterval.add(pick);
            }
            
            Schema.DescribeFieldResult platformFeeTypeDescribe = Platform_Fee__c.Type__c.getDescribe();
            List<Schema.PicklistEntry> platformFeeTypePicklistValues = platformFeeTypeDescribe.getPickListValues();
            for (Schema.PicklistEntry objPickList : platformFeeTypePicklistValues) {
                PicklistValues pick = new PicklistValues();
                pick.label = objPickList.getLabel();
                pick.value = objPickList.getValue();
                wrpCls.listPlatformFeeType.add(pick);
            }
            
            Schema.DescribeFieldResult platformFeeDebitModelDescribe = Platform_Fee__c.Debit_Model__c.getDescribe();
            List<Schema.PicklistEntry> platformFeeDebitModelPicklistValues = platformFeeDebitModelDescribe.getPickListValues();
            for (Schema.PicklistEntry objPickList : platformFeeDebitModelPicklistValues) {
                PicklistValues pick = new PicklistValues();
                pick.label = objPickList.getLabel();
                pick.value = objPickList.getValue();
                wrpCls.listPlatformFeeDebitModel.add(pick);
            }
            
            Schema.DescribeFieldResult fixedFeeDebitModelDescribe = Fixed_Pricing1__c.Debit_Model__c.getDescribe();
            List<Schema.PicklistEntry> fixedFeeDebitModelPicklistValues = fixedFeeDebitModelDescribe.getPickListValues();
            for (Schema.PicklistEntry objPickList : fixedFeeDebitModelPicklistValues) {
                PicklistValues pick = new PicklistValues();
                pick.label = objPickList.getLabel();
                pick.value = objPickList.getValue();
                wrpCls.listFixedFeeDebitModel.add(pick);
            }
            
            Schema.DescribeFieldResult fixedFeePaymentFrequencyDescribe = Fixed_Pricing1__c.Payment_Frequency__c.getDescribe();
            List<Schema.PicklistEntry> fixedFeePaymentFrequencyPicklistValues = fixedFeePaymentFrequencyDescribe.getPickListValues();
            for (Schema.PicklistEntry objPickList : fixedFeePaymentFrequencyPicklistValues) {
                PicklistValues pick = new PicklistValues();
                pick.label = objPickList.getLabel();
                pick.value = objPickList.getValue();
                wrpCls.listFixedPricingFeeInterval.add(pick);
            }
            
            wrpCls.message += '#'+commercialId;
            Integer count = 0;
            List<Pricing__c> listPricingToInsert = new List<Pricing__c>();
            List<SelectedPaymentData> listSelectedPaymentData = (List<SelectedPaymentData>)JSON.deserialize(selectedListPaymentData,List<SelectedPaymentData>.class);
            
            /** added to bypass records which is added from get API response, Added by Prabhakar */
            /* Map<Id,Pricing__c> pricingIdMap = new Map<Id,Pricing__c>([SELECT Id,Source__c,Need_To_Publish__c FROM Pricing__c 
WHERE Opportunity__c = :recordId 
AND Deleted__c = false 
AND Invisible__c = false]); */
            /** */
            
            for(SelectedPaymentData spd : listSelectedPaymentData) {
                for(SelectedPaymentOptions spo : spd.selectedPaymentOptionsList) {
                    for(SelectedPaymentDataSingleRecord spdsr : spo.selectedPaymentIndividualList) {
                        /** added to bypass records which is added from get API response, Added by Prabhakar */
                        /* if(pricingIdMap != NULL && pricingIdMap.keySet().size() > 0 && pricingIdMap.containsKey(spdsr.pricingId) && pricingIdMap.get(spdsr.pricingId).Source__c != 'Salesforce' && pricingIdMap.get(spdsr.pricingId).Need_To_Publish__c == false){
setPricingIdsNeedsToBeRetain.add(spdsr.pricingId);
continue;
} */
                        /** */
                        String identifier = spd.paymentModeId+'#'+spdsr.selectedPaymentOptionId+'#'+mapIdentifierToPricingSpecificationId.get(spdsr.selectedSpecification)+'#'+mapIdentifierToPaymentGatewayId.get(spdsr.selectedPaymentGatewayName).Id+'#'+spdsr.selectedOnusOffus;
                        Boolean belowRackRate = false;
                        if(mapIdentifierToMasterPricingDataId.containsKey(identifier)) {
                            Pricing__c pricing = new Pricing__c();
                            if(String.isNotBlank(spdsr.pricingId)) {
                                pricing.Id = spdsr.pricingId;
                                setPricingIdsNeedsToBeRetain.add(spdsr.pricingId);
                            }
                            else {
                                pricing.Need_to_Publish__c = true;
                            }
                            pricing.Opportunity__c = recordId;
                            pricing.Commercial2__c = commercialId;
                            pricing.Payment_Mode__c = spd.paymentModeId;
                            pricing.Payment_Option2__c = spdsr.selectedPaymentOptionId;
                            pricing.Specifcation__c = spdsr.selectedSpecification;
                            pricing.Pricing_Specification__c = mapIdentifierToPricingSpecificationId.get(spdsr.selectedSpecification);
                            pricing.Payment_Gateway_Text__c = spdsr.selectedPaymentGatewayName;
                            pricing.Payment_Gateway2__c =  mapIdentifierToPaymentGatewayId.get(spdsr.selectedPaymentGatewayName).Id;   
                            pricing.ONUS__c = spdsr.selectedOnusOffus;
                            pricing.Fee_Model__c = spdsr.selectedFeeModel;
                            pricing.Transaction_Type__c = spdsr.selectedTransactionType;
                            pricing.Master_Pricing_Data__c = mapIdentifierToMasterPricingDataId.get(identifier).Id;
                            if(pricing.Transaction_Type__c == 'TDR') {
                                pricing.TDR_Amount__c = String.isNotBlank(spdsr.tdrAmount) ? Decimal.valueOf(spdsr.tdrAmount) : 0;
                                pricing.TDR_Flat_Fee__c = String.isNotBlank(spdsr.tdrFee) ? Decimal.valueOf(spdsr.tdrFee) : 0;
                                pricing.TDR__c = String.isNotBlank(spdsr.tdrPercentage) ? Decimal.valueOf(spdsr.tdrPercentage) : 0;
                                String key = bankCategory;
                                if(pricing.TDR_Amount__c <= 2000) key += 'LessThanOrEqualTo2000';
                                else key += 'GreaterThan2000';
                                if(mapUniqueIdentifierToCustomMetadataRecords.containsKey(key)) {
                                    pricing.TDR_Percentage_Reference__c = (Decimal)mapIdentifierToMasterPricingDataId.get(identifier).get((String)mapUniqueIdentifierToCustomMetadataRecords.get(key).Percentage__c);
                                    pricing.TDR_Amount_Reference__c = (Decimal)mapIdentifierToMasterPricingDataId.get(identifier).get((String)mapUniqueIdentifierToCustomMetadataRecords.get(key).Flat_Fee__c);
                                    if(pricing.TDR_Flat_Fee__c != 0 && pricing.TDR_Flat_Fee__c < pricing.TDR_Amount_Reference__c) {
                                        pricing.Below_Rack_Rates__c = true;
                                        belowRackRate = true;
                                        if(String.isBlank(commercialId)) pricing.Banking_Ops_Status__c = '';
                                        else if(String.isNotBlank(commercialId) && String.isBlank(spdsr.pricingId)) pricing.Banking_Ops_Status__c = '';
                                        else if(String.isNotBlank(commercialId) && String.isNotBlank(spdsr.pricingId) && mapIdToPricing.containsKey(spdsr.pricingId) && pricing.TDR_Flat_Fee__c != mapIdToPricing.get(pricing.Id).TDR_Flat_Fee__c) {
                                            pricing.BH_Status__c = '';
                                            pricing.Banking_Ops_Status__c = ''; 
                                        }  
                                    }
                                    else if(pricing.TDR__c != 0 && pricing.TDR__c < pricing.TDR_Percentage_Reference__c) {
                                        pricing.Below_Rack_Rates__c = true;  
                                        belowRackRate = true;
                                        if(String.isBlank(commercialId)) pricing.Banking_Ops_Status__c = '';
                                        else if(String.isNotBlank(commercialId) && String.isBlank(spdsr.pricingId)) pricing.Banking_Ops_Status__c = '';
                                        else if(String.isNotBlank(commercialId) && String.isNotBlank(spdsr.pricingId) && mapIdToPricing.containsKey(spdsr.pricingId) && (pricing.TDR__c != mapIdToPricing.get(pricing.Id).TDR__c || pricing.TDR_Flat_Fee__c != mapIdToPricing.get(pricing.Id).TDR_Flat_Fee__c)) {
                                            pricing.BH_Status__c = '';
                                            pricing.Banking_Ops_Status__c = ''; 
                                        }   
                                    }
                                    else {
                                        Payment_Gateway2__c paymemtGateway = mapIdentifierToPaymentGatewayId.get(spdsr.selectedPaymentGatewayName);
                                        if(paymemtGateway.Type__c == 'PreApproved') {
                                            pricing.Banking_Ops_Status__c = 'Approved';    
                                        }
                                        else if(paymemtGateway.Type__c == 'PostApproved') {
                                            pricing.Banking_Ops_Status__c = getStatusForPostPaymentPricing(mapIdentifierToMasterPricingDataId.get(identifier),mapBankAndPORTypeToStatus,mapPriorityToStatus);
                                        }
                                        pricing.Below_Rack_Rates__c = false;
                                    }
                                }
                            }
                            else if(pricing.Transaction_Type__c == 'Convenience') {
                                pricing.Convenience_Amount__c = String.isNotBlank(spdsr.convenienceAmount) ? Decimal.valueOf(spdsr.convenienceAmount) : 0;
                                pricing.Convenience_Flat_Fee__c = String.isNotBlank(spdsr.convenienceFee) ? Decimal.valueOf(spdsr.convenienceFee) : 0;
                                pricing.Convenience__c = String.isNotBlank(spdsr.conveniencePercentage) ? Decimal.valueOf(spdsr.conveniencePercentage) : 0; 
                                String key = bankCategory;
                                if(pricing.Convenience_Amount__c <= 2000) key += 'LessThanOrEqualTo2000';
                                else key += 'GreaterThan2000';
                                if(mapUniqueIdentifierToCustomMetadataRecords.containsKey(key)) {
                                    pricing.Convenience_Percentage_Reference__c = (Decimal)mapIdentifierToMasterPricingDataId.get(identifier).get((String)mapUniqueIdentifierToCustomMetadataRecords.get(key).Percentage__c);
                                    pricing.Convenience_Amount_Reference__c = (Decimal)mapIdentifierToMasterPricingDataId.get(identifier).get((String)mapUniqueIdentifierToCustomMetadataRecords.get(key).Flat_Fee__c);
                                    if(pricing.Convenience_Flat_Fee__c != 0 && pricing.Convenience_Flat_Fee__c < pricing.Convenience_Amount_Reference__c) {
                                        pricing.Below_Rack_Rates__c = true;
                                        belowRackRate = true;
                                        if(String.isBlank(commercialId)) pricing.Banking_Ops_Status__c = '';
                                        else if(String.isNotBlank(commercialId) && String.isBlank(spdsr.pricingId)) pricing.Banking_Ops_Status__c = '';
                                        else if(String.isNotBlank(commercialId) && String.isNotBlank(spdsr.pricingId) && mapIdToPricing.containsKey(spdsr.pricingId) && pricing.Convenience_Flat_Fee__c != mapIdToPricing.get(pricing.Id).Convenience_Flat_Fee__c) {
                                            pricing.BH_Status__c = '';
                                            pricing.Banking_Ops_Status__c = ''; 
                                        }   
                                    }
                                    else if(pricing.Convenience__c != 0 && pricing.Convenience__c < pricing.Convenience_Percentage_Reference__c) {
                                        pricing.Below_Rack_Rates__c = true; 
                                        belowRackRate = true;
                                        if(String.isBlank(commercialId)) pricing.Banking_Ops_Status__c = '';
                                        else if(String.isNotBlank(commercialId) && String.isBlank(spdsr.pricingId)) pricing.Banking_Ops_Status__c = '';
                                        else if(String.isNotBlank(commercialId) && String.isNotBlank(spdsr.pricingId) && mapIdToPricing.containsKey(spdsr.pricingId) && (pricing.Convenience__c != mapIdToPricing.get(pricing.Id).Convenience__c || pricing.Convenience_Flat_Fee__c != mapIdToPricing.get(pricing.Id).Convenience_Flat_Fee__c)) {
                                            pricing.BH_Status__c = '';
                                            pricing.Banking_Ops_Status__c = ''; 
                                        }  
                                    }
                                    else {
                                        Payment_Gateway2__c paymemtGateway = mapIdentifierToPaymentGatewayId.get(spdsr.selectedPaymentGatewayName);
                                        if(paymemtGateway.Type__c == 'PreApproved') {
                                            pricing.Banking_Ops_Status__c = 'Approved';    
                                        }
                                        else if(paymemtGateway.Type__c == 'PostApproved') {
                                            pricing.Banking_Ops_Status__c = getStatusForPostPaymentPricing(mapIdentifierToMasterPricingDataId.get(identifier),mapBankAndPORTypeToStatus,mapPriorityToStatus); 
                                        }
                                        pricing.Below_Rack_Rates__c = false;
                                    }
                                }
                            }
                            else {
                                pricing.TDR_Amount__c = String.isNotBlank(spdsr.tdrAmount) ? Decimal.valueOf(spdsr.tdrAmount) : 0;
                                pricing.TDR_Flat_Fee__c = String.isNotBlank(spdsr.tdrFee) ? Decimal.valueOf(spdsr.tdrFee) : 0;
                                pricing.TDR__c = String.isNotBlank(spdsr.tdrPercentage) ? Decimal.valueOf(spdsr.tdrPercentage) : 0;
                                pricing.Convenience_Amount__c = String.isNotBlank(spdsr.convenienceAmount) ? Decimal.valueOf(spdsr.convenienceAmount) : 0;
                                pricing.Convenience_Flat_Fee__c = String.isNotBlank(spdsr.convenienceFee) ? Decimal.valueOf(spdsr.convenienceFee) : 0;
                                pricing.Convenience__c = String.isNotBlank(spdsr.conveniencePercentage) ? Decimal.valueOf(spdsr.conveniencePercentage) : 0;
                                String key = bankCategory;
                                if(pricing.TDR_Amount__c <= 2000) key += 'LessThanOrEqualTo2000';
                                else key += 'GreaterThan2000';
                                if(mapUniqueIdentifierToCustomMetadataRecords.containsKey(key)) {
                                    pricing.TDR_Percentage_Reference__c = (Decimal)mapIdentifierToMasterPricingDataId.get(identifier).get((String)mapUniqueIdentifierToCustomMetadataRecords.get(key).Percentage__c);
                                    pricing.TDR_Amount_Reference__c = (Decimal)mapIdentifierToMasterPricingDataId.get(identifier).get((String)mapUniqueIdentifierToCustomMetadataRecords.get(key).Flat_Fee__c);
                                    if(pricing.TDR_Flat_Fee__c != 0 && pricing.TDR_Flat_Fee__c < pricing.TDR_Amount_Reference__c) {
                                        pricing.Below_Rack_Rates__c = true;
                                        belowRackRate = true;
                                        if(String.isBlank(commercialId)) pricing.Banking_Ops_Status__c = '';
                                        else if(String.isNotBlank(commercialId) && String.isBlank(spdsr.pricingId)) pricing.Banking_Ops_Status__c = '';
                                        else if(String.isNotBlank(commercialId) && String.isNotBlank(spdsr.pricingId) && mapIdToPricing.containsKey(spdsr.pricingId) && pricing.TDR_Flat_Fee__c != mapIdToPricing.get(pricing.Id).TDR_Flat_Fee__c) {
                                            pricing.BH_Status__c = '';
                                            pricing.Banking_Ops_Status__c = ''; 
                                        }  
                                    }
                                    else if(pricing.TDR__c != 0 && pricing.TDR__c < pricing.TDR_Percentage_Reference__c) {
                                        pricing.Below_Rack_Rates__c = true;  
                                        belowRackRate = true;
                                        if(String.isBlank(commercialId)) pricing.Banking_Ops_Status__c = '';
                                        else if(String.isNotBlank(commercialId) && String.isBlank(spdsr.pricingId)) pricing.Banking_Ops_Status__c = '';
                                        else if(String.isNotBlank(commercialId) && String.isNotBlank(spdsr.pricingId) && mapIdToPricing.containsKey(spdsr.pricingId) && (pricing.TDR__c != mapIdToPricing.get(pricing.Id).TDR__c || pricing.TDR_Flat_Fee__c != mapIdToPricing.get(pricing.Id).TDR_Flat_Fee__c)) {
                                            pricing.BH_Status__c = '';
                                            pricing.Banking_Ops_Status__c = ''; 
                                        } 
                                    }
                                    else {
                                        if(String.isBlank(commercialId) ||(String.isNotBlank(CommercialId) && String.isBlank(spdsr.pricingId))) {
                                            Payment_Gateway2__c paymemtGateway = mapIdentifierToPaymentGatewayId.get(spdsr.selectedPaymentGatewayName);
                                            if(paymemtGateway.Type__c == 'PreApproved') {
                                                pricing.Banking_Ops_Status__c = 'Approved';    
                                            }
                                            else if(paymemtGateway.Type__c == 'PostApproved') {
                                                pricing.Banking_Ops_Status__c = getStatusForPostPaymentPricing(mapIdentifierToMasterPricingDataId.get(identifier),mapBankAndPORTypeToStatus,mapPriorityToStatus);   
                                            }    
                                        } 
                                        pricing.Below_Rack_Rates__c = false;
                                    }
                                }
                                String key1 = bankCategory;
                                if(pricing.Convenience_Amount__c <= 2000) key1 += 'LessThanOrEqualTo2000';
                                else key1 += 'GreaterThan2000';
                                if(mapUniqueIdentifierToCustomMetadataRecords.containsKey(key1)) {
                                    pricing.Convenience_Percentage_Reference__c = (Decimal)mapIdentifierToMasterPricingDataId.get(identifier).get((String)mapUniqueIdentifierToCustomMetadataRecords.get(key1).Percentage__c);
                                    pricing.Convenience_Amount_Reference__c = (Decimal)mapIdentifierToMasterPricingDataId.get(identifier).get((String)mapUniqueIdentifierToCustomMetadataRecords.get(key1).Flat_Fee__c);
                                    if(pricing.Convenience_Flat_Fee__c != 0 && pricing.Convenience_Flat_Fee__c < pricing.Convenience_Amount_Reference__c) {
                                        pricing.Below_Rack_Rates__c = true;
                                        belowRackRate = true;
                                        if(String.isBlank(commercialId)) pricing.Banking_Ops_Status__c = '';
                                        else if(String.isNotBlank(commercialId) && String.isBlank(spdsr.pricingId)) pricing.Banking_Ops_Status__c = '';
                                        else if(String.isNotBlank(commercialId) && String.isNotBlank(spdsr.pricingId) && mapIdToPricing.containsKey(spdsr.pricingId) && pricing.Convenience_Flat_Fee__c != mapIdToPricing.get(pricing.Id).Convenience_Flat_Fee__c) {
                                            pricing.BH_Status__c = '';
                                            pricing.Banking_Ops_Status__c = ''; 
                                        }   
                                    }
                                    else if( pricing.Convenience__c!= 0 && pricing.Convenience__c < pricing.Convenience_Percentage_Reference__c) {
                                        pricing.Below_Rack_Rates__c = true;
                                        belowRackRate = true;
                                        if(String.isBlank(commercialId)) pricing.Banking_Ops_Status__c = '';
                                        else if(String.isNotBlank(commercialId) && String.isBlank(spdsr.pricingId)) pricing.Banking_Ops_Status__c = '';
                                        else if(String.isNotBlank(commercialId) && String.isNotBlank(spdsr.pricingId) && mapIdToPricing.containsKey(spdsr.pricingId) && (pricing.Convenience__c != mapIdToPricing.get(pricing.Id).Convenience__c || pricing.Convenience_Flat_Fee__c != mapIdToPricing.get(pricing.Id).Convenience_Flat_Fee__c)) {
                                            pricing.BH_Status__c = '';
                                            pricing.Banking_Ops_Status__c = ''; 
                                        }   
                                    }
                                    else {
                                        if(!pricing.Below_Rack_Rates__c) {
                                            pricing.Below_Rack_Rates__c = false; 
                                            Payment_Gateway2__c paymemtGateway = mapIdentifierToPaymentGatewayId.get(spdsr.selectedPaymentGatewayName);
                                            if(paymemtGateway.Type__c == 'PreApproved') {
                                                pricing.Banking_Ops_Status__c = 'Approved';    
                                            }
                                            else if(paymemtGateway.Type__c == 'PostApproved') {
                                                pricing.Banking_Ops_Status__c = getStatusForPostPaymentPricing(mapIdentifierToMasterPricingDataId.get(identifier),mapBankAndPORTypeToStatus,mapPriorityToStatus);
                                            }
                                        }
                                    }
                                }
                            }
                            listPricingToInsert.add(pricing);   
                            if(belowRackRate) count++;
                        }
                        else {
                            //spo.selectedPaymentIndividualList.remove(index);	    
                        }
                        //index++;
                    }
                }
            }
            
            if(String.isNotBlank(commercialId) && setAllPricingIds.size() > 0 && setPricingIdsNeedsToBeRetain.size() > 0) {
                List<Pricing__c> listPricingRecordToUpdateDelete = new List<Pricing__c>();
                if(setAllPricingIds.removeAll(setPricingIdsNeedsToBeRetain)) {
                    for(Id pricingId : setAllPricingIds) {
                        Pricing__c pricing = new Pricing__c();
                        pricing.Id = pricingId;
                        pricing.Deleted__c = true;
                        pricing.Need_to_Publish__c = false;
                        
                        //pricing.BH_Status__c = 
                        listPricingRecordToUpdateDelete.add(pricing);
                    }
                    if(listPricingRecordToUpdateDelete.size() > 0) update listPricingRecordToUpdateDelete;    
                }
            }
            
            if(listPricingToInsert.size() > 0) {
                upsert listPricingToInsert;
            }
            if(count > 0) wrpCls.message += '#There are '+count+' pricing records which are below rack rates.';
            //Return inserted data on UI
            wrpCls.selectedListPaymentData = getInsertedPricingRecords(commercialId);
        }
        catch(Exception e) {
            wrpCls.message = e.getMessage();
        }
        return wrpCls;
    }
    
    //Wrapper Class for the Save Pricing
    public class SavePricingWrapper {
        @AuraEnabled public String message = '';
        @AuraEnabled public String selectedListPaymentData = '';
        @AuraEnabled public String listFallbackChargesString = '';
        @AuraEnabled public String listPlatformFeeString = '';
        @AuraEnabled public String listFixedPricing2String = '';
        @AuraEnabled public List<PicklistValues> listPlatformFeeType = new List<PicklistValues>();
        @AuraEnabled public List<PicklistValues> listPlatformFeeInterval = new List<PicklistValues>();
        @AuraEnabled public List<PicklistValues> listPlatformFeeDebitModel = new List<PicklistValues>();
        @AuraEnabled public List<PicklistValues> listFixedPricingFeeInterval = new List<PicklistValues>();
        @AuraEnabled public List<PicklistValues> listFixedFeeDebitModel = new List<PicklistValues>();
        @AuraEnabled public String selectedInterval = '';
        @AuraEnabled public String selectedType = '';
        @AuraEnabled public Date selectedStartDate = Date.today(); 
        @AuraEnabled public Date selectedEndDate = Date.today(); 
        @AuraEnabled public String selectedDebitModel = '';
    }
    
    //Wrapper Class to return inserted pricing records
    public class SelectedPaymentData {
        @AuraEnabled public String paymentModeId = '';
        @AuraEnabled public String paymentModeName = '';
        @AuraEnabled public List<SelectedPaymentOptions> selectedPaymentOptionsList = new List<SelectedPaymentOptions>();
    }
    
    //Wrapper Class to return inserted pricing records
    public class SelectedPaymentOptions {
        @AuraEnabled public String key = '';
        @AuraEnabled public List<SelectedPaymentDataSingleRecord> selectedPaymentIndividualList = new List<SelectedPaymentDataSingleRecord>(); 
    }
    
    //Wrapper Class to return inserted pricing records
    public class SelectedPaymentDataSingleRecord {
        @AuraEnabled public String key = '';
        @AuraEnabled public String selectedPaymentOptionName = ''; 
        @AuraEnabled public String selectedPaymentOptionId = ''; 
        @AuraEnabled public String selectedSpecification = '';
        @AuraEnabled public String selectedPaymentGatewayName = '';
        @AuraEnabled public String selectedOnusOffus = ''; 
        @AuraEnabled public String selectedFeeModel = ''; 
        @AuraEnabled public String selectedTransactionType = ''; 
        @AuraEnabled public String tdrAmount = ''; 
        @AuraEnabled public String tdrFee = ''; 
        @AuraEnabled public String tdrPercentage = ''; 
        @AuraEnabled public String convenienceAmount = ''; 
        @AuraEnabled public String convenienceFee = ''; 
        @AuraEnabled public String conveniencePercentage = '';
        @AuraEnabled public String status = '';
        //Added by Anas | To show Payment Gateway type on the Screen 7
        @AuraEnabled public String gatewayType = '';
        //Added by Anas | To enable Chatter functionality on the screen 7
        @AuraEnabled public Boolean showChatter = false;
        @AuraEnabled public String bankingOpsStatus = '';
        @AuraEnabled public String bankName = '';
        @AuraEnabled public String porType = '';
        @AuraEnabled public String currentUserProfileName = '';
        //Added by Anas | To show color coding on the status column
        @AuraEnabled public String className = '';
        //Adding to support edit of the existing pricing records
        @AuraEnabled public String pricingId = '';
        @AuraEnabled public Boolean showRejectionReason = false;
        @AuraEnabled public Boolean showRejectionReasonDelete = false;
        @AuraEnabled public String rejectionReason = '';
        @AuraEnabled public String rejectionReasonDelete = '';

    }
    
    /*
* Description       : This method is called from SavePricingApex Function to get the lastest status for the post approved pricing
* Version.          : 1   
*/
    private static String getStatusForPostPaymentPricing(Master_Pricing_Data__c mpd,Map<String,Integer> mapBankAndPORTypeToStatus,Map<String,Object> mapPriorityToStatus) {
        String keyNew = mpd.Bank__c + '#' + mpd.POR_Type__c;
        if(mapBankAndPORTypeToStatus.containsKey(keyNew)) {
            Integer priority = mapBankAndPORTypeToStatus.get(keyNew);
            return (String)mapPriorityToStatus.get(String.valueOf(priority));
        }
        else {
            return 'Pending with Banking ops';    
        } 
    }
    
    /*
* Description       : This method is called on load of this component
* Version.          : 1   
*/
    @AuraEnabled/*(cacheable=true) To reload the component on click of Home button*/
    public static CommercialWrapper existingCommercial(String recordId) {
        CommercialWrapper comWrpCls = new CommercialWrapper();
        try {
            /*******Ticket 3.2 (SFI-1486)If Commercial does not exist in SF and we are clicking on Commercial Tab on Oportuntiy then we need
to call the treasury API and check If any pricing record exist in treasury and revenue model is TDR then 
we need to create  commercial in SF side  
********/
            List<Opportunity> oppList= [SELECT Id,Prod_MID__c,(SELECT Id FROM Commercial2__r) FROM Opportunity WHERE  Id=:recordId LIMIT 1 ];
            if(oppList[0].Commercial2__r.isEmpty() && oppList[0].Commercial2__r.size()==0){
                GetApiTreasuryDataController.PricingWrapper tranformData = GetApiTreasuryDataController.processTreasuryData(oppList[0].Prod_MID__c,'TDR,Conv Fee');
                if(tranformData.transformedPricingWrapperPricingList !=NULL && tranformData.transformedPricingWrapperPricingList.size()>0){
                    Commercial2__c  comm = new Commercial2__c ();
                    comm.Name =  System.label.Commercial2_Name+oppList[0].Prod_MID__c;
                    comm.Source__c  = 'Treasury(System_Generated)';
                    comm.Opportunity__c = recordId;
                    comm.Status__c = 'Live';
                    Insert comm;
                }
            }
            /*******END******/
            for(Commercial2__c comm : [SELECT Id,Name,Status__c,CreatedDate,Source__c,CreatedBy.Name,Last_Edited_On__c,
                                       Last_Published_On__c FROM Commercial2__c WHERE Opportunity__c = :recordId]) {
                                           ExistingCommercialWrapper commWrp = new ExistingCommercialWrapper();
                                           commWrp.Id = comm.Id;
                                           commWrp.name = comm.Name;
                                           commWrp.status = comm.Status__c;
                                           commWrp.createdDate = comm.CreatedDate.format();
                                           commWrp.createdBy = comm.CreatedBy.Name;
                                           if(comm.Status__c == 'Live') commWrp.textColor = 'colorPillsOptionsPurple';
                                           else if(comm.Status__c == 'Draft') commWrp.textColor = 'colorPillsOptionsPink';
                                           else commWrp.textColor = 'colorPillsOptionsOrange';
                                           if(comm.Last_Edited_On__c != NULL) commWrp.lastEditedOn = comm.Last_Edited_On__c.format();
                                           if(comm.Last_Published_On__c != NULL) commWrp.lastPublishedOn = comm.Last_Published_On__c.format();
                                           if(comm.Source__c == 'Scratch') commWrp.source = comm.Source__c;  
                                           /*****Added by rohit SFI-1486******/
                                           else if(comm.Source__c == 'Treasury(System_Generated)'){
                                               commWrp.source = comm.Source__c; 
                                               commWrp.templateName = ''; 
                                           } 
                                           /******/  
                                           else {
                                               commWrp.source = 'Template'; 
                                               commWrp.templateName = comm.Source__c;  	    
                                           }
                                           comWrpCls.listExistingCommercial.add(commWrp);
                                           
                                       }
            if(setSuperUsersId.contains(UserInfo.getUserId())) {
                comWrpCls.isSuperUser = true;    
            }
            
            Schema.DescribeFieldResult platformFeeIntervalDescribe = Platform_Fee__c.Interval__c.getDescribe();
            List<Schema.PicklistEntry> platformFeeIntervalPicklistValues = platformFeeIntervalDescribe.getPickListValues();
            for (Schema.PicklistEntry objPickList : platformFeeIntervalPicklistValues) {
                PicklistValues pick = new PicklistValues();
                pick.label = objPickList.getLabel();
                pick.value = objPickList.getValue();
                comWrpCls.listPlatformFeeInterval.add(pick);
            }
            
            Schema.DescribeFieldResult platformFeeTypeDescribe = Platform_Fee__c.Type__c.getDescribe();
            List<Schema.PicklistEntry> platformFeeTypePicklistValues = platformFeeTypeDescribe.getPickListValues();
            for (Schema.PicklistEntry objPickList : platformFeeTypePicklistValues) {
                PicklistValues pick = new PicklistValues();
                pick.label = objPickList.getLabel();
                pick.value = objPickList.getValue();
                comWrpCls.listPlatformFeeType.add(pick);
            }
            
            Schema.DescribeFieldResult platformFeeDebitModelDescribe = Platform_Fee__c.Debit_Model__c.getDescribe();
            List<Schema.PicklistEntry> platformFeeDebitModelPicklistValues = platformFeeDebitModelDescribe.getPickListValues();
            for (Schema.PicklistEntry objPickList : platformFeeDebitModelPicklistValues) {
                PicklistValues pick = new PicklistValues();
                pick.label = objPickList.getLabel();
                pick.value = objPickList.getValue();
                comWrpCls.listPlatformFeeDebitModel.add(pick);
            }
            
            Schema.DescribeFieldResult fixedFeeDebitModelDescribe = Fixed_Pricing1__c.Debit_Model__c.getDescribe();
            List<Schema.PicklistEntry> fixedFeeDebitModelPicklistValues = fixedFeeDebitModelDescribe.getPickListValues();
            for (Schema.PicklistEntry objPickList : fixedFeeDebitModelPicklistValues) {
                PicklistValues pick = new PicklistValues();
                pick.label = objPickList.getLabel();
                pick.value = objPickList.getValue();
                comWrpCls.listFixedFeeDebitModel.add(pick);
            }
            
            Schema.DescribeFieldResult fixedFeePaymentFrequencyDescribe = Fixed_Pricing1__c.Payment_Frequency__c.getDescribe();
            List<Schema.PicklistEntry> fixedFeePaymentFrequencyPicklistValues = fixedFeePaymentFrequencyDescribe.getPickListValues();
            for (Schema.PicklistEntry objPickList : fixedFeePaymentFrequencyPicklistValues) {
                PicklistValues pick = new PicklistValues();
                pick.label = objPickList.getLabel();
                pick.value = objPickList.getValue();
                comWrpCls.listFixedPricingFeeInterval.add(pick);
            }
        }
        catch(Exception e){
            comWrpCls.message = e.getMessage();
        }
        return comWrpCls;
    }
    
    //Wrapper Class to return commercial data
    public class CommercialWrapper {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public List<ExistingCommercialWrapper> listExistingCommercial = new List<ExistingCommercialWrapper>();
        @AuraEnabled public Boolean isSuperUser = false;
        @AuraEnabled public List<PicklistValues> listPlatformFeeInterval = new List<PicklistValues>();
        @AuraEnabled public List<PicklistValues> listPlatformFeeType = new List<PicklistValues>();
        @AuraEnabled public List<PicklistValues> listPlatformFeeDebitModel = new List<PicklistValues>();
        @AuraEnabled public List<PicklistValues> listFixedPricingFeeInterval = new List<PicklistValues>();
        @AuraEnabled public List<PicklistValues> listFixedFeeDebitModel = new List<PicklistValues>();
    }
    
    //Wrapper Class to return Commercials 
    public class ExistingCommercialWrapper {
        @AuraEnabled public String Id = '';
        @AuraEnabled public String name = '';
        @AuraEnabled public String status = '';
        @AuraEnabled public String createdDate = '';
        @AuraEnabled public String templateName = '';
        @AuraEnabled public String createdBy = '';
        @AuraEnabled public String lastEditedOn = '';
        @AuraEnabled public String lastPublishedOn = '';
        @AuraEnabled public String source = '';
        @AuraEnabled public String textColor = 'color:black;';
    }
    
    /*
* Description       : This method is called from Screen 1 to get all the pricing records for an existing commercials
* Version.          : 1   
*/
    @AuraEnabled 
    public static PricingWrapper getPricingRecordsForCommercial(String commercialId,String commercialName) {
        PricingWrapper pricingWrapper = new PricingWrapper();
        try {
            pricingWrapper.selectedListPaymentData = getInsertedPricingRecords(commercialId);
            List<Pricing__c> listPricing = [SELECT Id,Commercial2__r.Is_Updated__c,Commercial2__r.Status__c,Commercial2__r.Edited__c,
                                            Commercial2__r.Source__c,Commercial2__r.TemplateId__c,Banking_Ops_Status__c,Checker_Rejection_Reason__c,
                                            Checker_Delete_Rejection_Reason__c 
                                            FROM Pricing__c 
                                            WHERE Commercial2__c = :commercialId AND Deleted__c = false AND Invisible__c = false/*AND Below_Rack_Rates__c = true*/];
            if(listPricing != NULL && listPricing.size() > 0) {
                pricingWrapper.status = listPricing[0].Commercial2__r.Status__c;
                Boolean edited = listPricing[0].Commercial2__r.Edited__c;
                if(listPricing[0].Commercial2__r.Is_Updated__c) pricingWrapper.disabledBHButton = false;
                List<Pricing__c> listPricingBelowRackRatesRecords = [SELECT Id,Banking_Ops_Status__c FROM Pricing__c WHERE Commercial2__c = :commercialId AND Below_Rack_Rates__c = true AND Deleted__c = false AND Invisible__c = false];
                if(listPricingBelowRackRatesRecords != NULL && listPricingBelowRackRatesRecords.size() > 0) {
                    if(String.isNotBlank(listPricingBelowRackRatesRecords[0].Banking_Ops_Status__c)) pricingWrapper.showBelowRackRateRecords = false;
                    pricingWrapper.showBelowRackRateMessage = true;
                    pricingWrapper.belowRackRateMessage = 'There are '+listPricingBelowRackRatesRecords.size()+' pricing records which are below rack rates.';    
                }
                if(pricingWrapper.status == 'Draft' || edited) {
                    pricingWrapper.respectiveScreen = 'Draft';    
                }
                else {
                    pricingWrapper.respectiveScreen = 'Not Draft';      
                }
                
                List<FallbackCharges> listFallbackCharges = new List<FallbackCharges>();
                List<PlatformFee> listPlatformFee = new List<PlatformFee>();
                List<FixedPricing2> listFixedPricing2 = new List<FixedPricing2>();
                
                Set<String> setInsertedFeeType = new Set<String>();
                for(Fixed_Pricing1__c fp1 : [SELECT Id,Amount__c,Debit_Model__c,End_Date__c,Fee_Type__c,Flat_Fee__c,Payment_Frequency__c,Percentage__c,Start_Date__c FROM Fixed_Pricing1__c WHERE Commercial__c = :commercialId]) {
                    FixedPricing2 fpNew = new FixedPricing2();
                    fpNew.recordId = fp1.Id;
                    fpNew.endDate = fp1.End_Date__c != NULL ? String.valueOf(fp1.End_Date__c) : '';
                    fpNew.startDate = fp1.Start_Date__c != NULL ? String.valueOf(fp1.Start_Date__c) : '';
                    fpNew.amount = fp1.Amount__c != NULL ? String.valueOf(fp1.Amount__c) : '';
                    fpNew.flatFee = fp1.Flat_Fee__c != NULL ? String.valueOf(fp1.Flat_Fee__c) : '';
                    fpNew.percentage = fp1.Percentage__c != NULL ? String.valueOf(fp1.Percentage__c) : '';
                    fpNew.flatFeeType = fp1.Fee_Type__c;
                    fpNew.paymentFrequency = fp1.Payment_Frequency__c != NULL ? String.valueOf(fp1.Payment_Frequency__c) : '';
                    fpNew.debitModel = fp1.Debit_Model__c != NULL ? String.valueOf(fp1.Debit_Model__c) : '';
                    fpNew.showDeleteButton = false;
                    listFixedPricing2.add(fpNew);    
                    setInsertedFeeType.add(fp1.Fee_Type__c);
                }
                
                if(pricingWrapper.respectiveScreen == 'Draft') {
                    for(String feeType : setFlatFeeType) {
                        if(!setInsertedFeeType.contains(feeType)) {
                            FixedPricing2 fp = new FixedPricing2();
                            fp.flatFeeType = feeType;
                            listFixedPricing2.add(fp);    
                        }    
                    }
                    
                }
                
                for(Fallback_Charge__c fc : [SELECT Id,Payment_Mode__c,Flat_Fee__c,Percentage__c FROM Fallback_Charge__c WHERE Commercial__c =:commercialId]) {
                    FallbackCharges fcObj = new FallbackCharges();
                    fcObj.Id = fc.Id;
                    fcObj.paymentModeName = fc.Payment_Mode__c;
                    fcObj.flatFee = fc.Flat_Fee__c != NULL ? String.valueOf(fc.Flat_Fee__c) : '';
                    fcObj.percentage = fc.Percentage__c != NULL ? String.valueOf(fc.Percentage__c) : '';
                    listFallbackCharges.add(fcObj);
                }
                
                Integer count = 1;
                for(Platform_Fee__c pf : [SELECT Id,Amount__c,Flat_Fee__c,Percentage__c,Type__c,Interval__c,Start_Date__c,End_Date__c,Debit_Model__c FROM Platform_Fee__c WHERE Commercial__c = :commercialId ORDER BY Amount__c]) {
                    PlatformFee pfObj = new PlatformFee();
                    pfObj.Id = pf.Id;
                    pfObj.amount = pf.Amount__c != NULL ? String.valueOf(pf.Amount__c) : '';
                    pfObj.flatFee = pf.Flat_Fee__c != NULL ? String.valueOf(pf.Flat_Fee__c) : '';
                    pfObj.percentage = pf.Percentage__c != NULL ? String.valueOf(pf.Percentage__c) : '';
                    pricingWrapper.selectedType = pf.Type__c;
                    pricingWrapper.selectedInterval= pf.Interval__c;
                    pricingWrapper.selectedStartDate = pf.Start_Date__c;
                    pricingWrapper.selectedEndDate = pf.End_Date__c;
                    pricingWrapper.selectedDebitModel = pf.Debit_Model__c;
                    if(count == 1) pfObj.disabledAmount = true;
                    count++;
                    listPlatformFee.add(pfObj);    
                }
                
                if(listFallbackCharges.size() > 0) pricingWrapper.listFallbackChargesString = JSON.serialize(listFallbackCharges);
                if(listPlatformFee.size() > 0) pricingWrapper.listPlatformFeeString = JSON.serialize(listPlatformFee);
                if(listFixedPricing2.size() > 0) pricingWrapper.listFixedPricing2String = JSON.serialize(listFixedPricing2);
                
                if(pricingWrapper.status != 'Draft'/*pricingWrapper.status == 'Published'*/) {
                    List<FixedPricing> listFixedPricing = new List<FixedPricing>();
                    for(Fixed_Pricing__c fp : [SELECT Id,Setup_Fee__c,Setup_Deposit__c,AMC_Fee__c,AMC_Interval__c FROM Fixed_Pricing__c WHERE Commercial2__c =:commercialId]) {
                        FixedPricing fpNew = new FixedPricing();
                        fpNew.key = fp.Id;
                        fpNew.setupFee = String.valueOf(fp.Setup_Fee__c);
                        fpNew.securityDeposit = String.valueOf(fp.Setup_Deposit__c);
                        fpNew.amcFee = String.valueOf(fp.AMC_Fee__c);
                        fpNew.amcInterval = String.valueOf(fp.AMC_Interval__c);
                        listFixedPricing.add(fpNew);
                    }
                    if(listFixedPricing.size() > 0) pricingWrapper.listFixedPricingString = JSON.serialize(listFixedPricing);
                }
                else if(listPricing[0].Commercial2__r.Source__c != 'Scratch' && String.isNotBlank(listPricing[0].Commercial2__r.TemplateId__c)) {
                    List<FixedPricing> listFixedPricing = new List<FixedPricing>();
                    for(Pricing_Template__c template : [SELECT Id,Setup_Fee__c,Setup_Deposit__c,AMC_Fee__c,AMC_Interval__c FROM Pricing_Template__c WHERE Id =:listPricing[0].Commercial2__r.TemplateId__c]) {
                        FixedPricing fpNew = new FixedPricing();
                        fpNew.key = template.Id;
                        fpNew.setupFee = template.Setup_Fee__c != NULL ? String.valueOf(template.Setup_Fee__c) : '';
                        fpNew.securityDeposit = template.Setup_Deposit__c != NULL ? String.valueOf(template.Setup_Deposit__c) : '';
                        fpNew.amcFee = template.AMC_Fee__c != NULL ? String.valueOf(template.AMC_Fee__c) : '';
                        fpNew.amcInterval = template.AMC_Interval__c != NULL ? String.valueOf(template.AMC_Interval__c) : '';
                        listFixedPricing.add(fpNew);    
                    }
                    pricingWrapper.listFixedPricingString = JSON.serialize(listFixedPricing);    
                }    
            }
        }
        catch(Exception e) {
            pricingWrapper.message = e.getMessage();    
        }
        return pricingWrapper;
    }
    
    //Wrapper Class to return data to component for the pricing records for the existing commercial
    public class PricingWrapper{
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public String selectedListPaymentData = ''; 
        @AuraEnabled public Boolean showBelowRackRateMessage = false;
        @AuraEnabled public String belowRackRateMessage = ''; 
        @AuraEnabled public Boolean disabledBHButton = true;
        @AuraEnabled public Boolean showBelowRackRateRecords = true;
        @AuraEnabled public String listFixedPricingString = '';
        @AuraEnabled public String status = '';
        @AuraEnabled public String respectiveScreen = '';
        @AuraEnabled public String listFallbackChargesString = '';
        @AuraEnabled public String listPlatformFeeString = '';
        @AuraEnabled public String listFixedPricing2String = '';
        @AuraEnabled public String selectedType = '';
        @AuraEnabled public String selectedInterval = '';
        @AuraEnabled public Date selectedStartDate = Date.today();
        @AuraEnabled public Date selectedEndDate = Date.today();
        @AuraEnabled public String selectedDebitModel = '';
    } 
    
    /*
* Description       : Get inserted pricing records for the commercial
* Version.          : 1   
*/
    public static String getInsertedPricingRecords(String commercialId) {
        //-----Added by Anas Yar Khan | To enable chatter functionality in pricing module--------
        String currentUserProfileName = '';
        List<User> listUser = [SELECT Id,Profile.Name FROM User WHERE Id =:UserInfo.getUserId()];
        if(listUser != NULL && listUser.size() > 0) currentUserProfileName = listUser[0].Profile.Name;
        //---------------------------------------------------------------------------------------
        String selectedListPaymentData = '';
        List<SelectedPaymentData> listSelectedPaymentData = new List<SelectedPaymentData>();
        Map<Id,SelectedPaymentData> mapPaymentModeIdToSelectedPaymentData = new Map<Id,SelectedPaymentData>();
        for(Pricing__c pricing : [SELECT Id,Payment_Mode__c,Payment_Mode_Text__c,Payment_Option2__c,Payment_Option_Text__c,
                                  Specifcation__c,Payment_Gateway_Text__c,ONUS__c,Fee_Model__c,Transaction_Type__c,TDR_Amount__c,
                                  TDR_Flat_Fee__c,TDR__c,Convenience_Amount__c,Convenience_Flat_Fee__c,Convenience__c,
                                  Banking_Ops_Status__c,Below_Rack_Rates__c,Payment_Gateway2__r.Type__c,Bank_Name__c,POR_Type_Name__c,
                                  Checker_Rejection_Reason__c,Checker_Delete_Rejection_Reason__c 
                                  FROM Pricing__c 
                                  WHERE Commercial2__c = :commercialId AND Deleted__c = false AND Invisible__c = false]) {
                                      SelectedPaymentData spd = new SelectedPaymentData();
                                      if(mapPaymentModeIdToSelectedPaymentData.containsKey(pricing.Payment_Mode__c)) {
                                          spd = mapPaymentModeIdToSelectedPaymentData.get(pricing.Payment_Mode__c);	    
                                      }	  
                                      
                                      spd.paymentModeId = pricing.Payment_Mode__c;
                                      spd.paymentModeName = pricing.Payment_Mode_Text__c;
                                      
                                      String key = pricing.Payment_Mode__c+'#'+pricing.Payment_Option2__c+'#'+pricing.Specifcation__c+'#'+pricing.Payment_Gateway_Text__c+'#'+pricing.ONUS__c;  
                                      //Create single record
                                      SelectedPaymentDataSingleRecord spdsr = new SelectedPaymentDataSingleRecord();
                                      spdsr.key = pricing.Id;//=key | Commented to enable chatter functioinality;
                                      spdsr.selectedPaymentOptionName = pricing.Payment_Option_Text__c;
                                      spdsr.selectedPaymentOptionId = pricing.Payment_Option2__c;
                                      spdsr.selectedSpecification = pricing.Specifcation__c;
                                      spdsr.selectedPaymentGatewayName = pricing.Payment_Gateway_Text__c;
                                      spdsr.selectedOnusOffus = pricing.ONUS__c;
                                      spdsr.selectedFeeModel = pricing.Fee_Model__c;
                                      spdsr.selectedTransactionType = pricing.Transaction_Type__c;
                                      spdsr.tdrAmount = String.valueOf(pricing.TDR_Amount__c);
                                      spdsr.tdrFee = String.valueOf(pricing.TDR_Flat_Fee__c);
                                      spdsr.tdrPercentage = String.valueOf(pricing.TDR__c);
                                      spdsr.convenienceAmount  = String.valueOf(pricing.Convenience_Amount__c);
                                      spdsr.convenienceFee  = String.valueOf(pricing.Convenience_Flat_Fee__c);
                                      spdsr.conveniencePercentage  = String.valueOf(pricing.Convenience__c);
                                      //-----Added by Anas Yar Khan | To add gateway type on screen 6 and screen 7
                                      spdsr.gatewayType = pricing.Payment_Gateway2__r.Type__c;
                                      //---------------End--------------------------------------------------------
                                      //-----Added by Anas Yar Khan | To enable chatter functionality in pricing module
                                      if(String.isNotBlank(pricing.Payment_Gateway2__r.Type__c) && pricing.Payment_Gateway2__r.Type__c == 'PostApproved' && pricing.Banking_Ops_Status__c != 'Pending with BH' && pricing.Banking_Ops_Status__c != 'Rejected with BH') {
                                          spdsr.showChatter = true;
                                      }
                                      spdsr.bankingOpsStatus = pricing.Banking_Ops_Status__c;
                                      if(spdsr.bankingOpsStatus == 'Checker Rejected'){
                                        if(String.isNotBlank(pricing.Checker_Rejection_Reason__c)){
                                            spdsr.showRejectionReason = true;
                                            spdsr.rejectionReason = pricing.Checker_Rejection_Reason__c;
                                        }
                                        if(String.isNotBlank(pricing.Checker_Delete_Rejection_Reason__c)){
                                            spdsr.showRejectionReasonDelete = true;
                                            spdsr.rejectionReasonDelete = pricing.Checker_Delete_Rejection_Reason__c;
                                        }
                                      }
                                      spdsr.bankName = pricing.Bank_Name__c;
                                      spdsr.porType = pricing.POR_Type_Name__c;
                                      spdsr.currentUserProfileName = currentUserProfileName;
                                      //-------------End-----------------------------------------------------------------
                                      if(String.isNotBlank(pricing.Banking_Ops_Status__c)) {
                                          spdsr.status = pricing.Banking_Ops_Status__c;
                                          if(pricing.Banking_Ops_Status__c.containsIgnoreCase('Approved')) {
                                              spdsr.className = 'colorPillsOptions2';    
                                          }
                                          else if(pricing.Banking_Ops_Status__c.containsIgnoreCase('Pending')) {
                                              spdsr.className = 'colorPillsOptions3';     
                                          }
                                          else if(pricing.Banking_Ops_Status__c.containsIgnoreCase('Rejected')) {
                                              spdsr.className = 'colorPillsOptions4';     
                                          }
                                          else {
                                              spdsr.className = 'colorPillsOptions';     
                                          }
                                      }
                                      
                                      if(pricing.Below_Rack_Rates__c) spdsr.status += ' (below rack rate)';
                                      
                                      SelectedPaymentOptions spo = new SelectedPaymentOptions();
                                      spo.key = key;
                                      spo.selectedPaymentIndividualList.add(spdsr);
                                      
                                      spd.selectedPaymentOptionsList.add(spo);
                                      mapPaymentModeIdToSelectedPaymentData.put(pricing.Payment_Mode__c,spd);
                                  }   
        
        if(mapPaymentModeIdToSelectedPaymentData.keySet().size() > 0) {
            for(SelectedPaymentData spd : mapPaymentModeIdToSelectedPaymentData.values()) {
                listSelectedPaymentData.add(spd);    
            }
        }
        return JSON.serialize(listSelectedPaymentData);
    }
    
    //Wrapper class to return Payment Gateway for a particular Payment Mode,Options and Specifications
    public class WrapperPaymentGateway {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public List<PicklistValues> listPaymentGateway = new List<PicklistValues>();
    }
    
    /*
* Description       : This method is called on change of the Specification
* Version.          : 1   
*/
    @AuraEnabled(cacheable=true)
    public static WrapperPaymentGateway getPaymentGatewayData(String paymentModeId,String paymentOptionId,List<String> selectedSpecifications) {
        WrapperPaymentGateway wrpPayG = new WrapperPaymentGateway();
        try {
            Map<Id,Pricing_Specification__c> mapIdToSpecification = new Map<Id,Pricing_Specification__c>([SELECT Id,Name FROM Pricing_Specification__c WHERE Name IN :selectedSpecifications]);
            Set<String> setPaymentGatewayName = new Set<String>();
            for(Master_Pricing_Data__c mpd : [SELECT Id,Payment_Gateway__r.Type__c,Payment_Gateway__c,Payment_Gateway__r.Name FROM Master_Pricing_Data__c WHERE Payment_Mode__c = :paymentModeId AND Payment_Option__c =:paymentOptionId AND Pricing_Specification__c IN :mapIdToSpecification.keySet() AND Active_Instrument__c = true ORDER BY Payment_Gateway__r.Default__c DESC LIMIT 50000]) {
                if(!setPaymentGatewayName.contains(mpd.Payment_Gateway__r.Name)) {
                    PicklistValues pick = new PicklistValues();
                    pick.label = mpd.Payment_Gateway__r.Name;
                    pick.value = mpd.Payment_Gateway__r.Name;
                    pick.type = mpd.Payment_Gateway__r.Type__c;
                    wrpPayG.listPaymentGateway.add(pick);  
                    setPaymentGatewayName.add(mpd.Payment_Gateway__r.Name);
                }
            }
            /************Added By Rohit**********/
            PicklistValues selectAll = new PicklistValues();
            selectAll.label = 'Select All';
            selectAll.value = 'Select All';
            wrpPayG.listPaymentGateway.add(0,selectAll); 
            PicklistValues selectAllPreApp = new PicklistValues();
            selectAllPreApp.label = 'Select All PreApproved';
            selectAllPreApp.value = 'Select All PreApproved';
            wrpPayG.listPaymentGateway.add(1,selectAllPreApp); 
            /*****************END*******************/
        }
        catch(exception e) {
            wrpPayG.message = e.getMessage();    
        }
        return wrpPayG;
    }
    
    /*
* Description       : This method is called on the click of Update Below Rack rates records
* Version.          : 1   
*/
    @AuraEnabled 
    public static BelowRackRatesRecordsWrapper getBelowRackRatesRecords(String commercialId) {
        BelowRackRatesRecordsWrapper wrpCls = new BelowRackRatesRecordsWrapper();
        try {
            for(Pricing__c pricing : [SELECT Id,Payment_Mode_Text__c,Payment_Option_Text__c,Specifcation__c,Payment_Gateway_Text__c ,TDR_Percentage_Reference__c,
                                      TDR_Amount_Reference__c,TDR_Amount__c,TDR_Flat_Fee__c,TDR__c,Convenience_Percentage_Reference__c,Convenience_Amount_Reference__c,
                                      Convenience_Amount__c,Convenience_Flat_Fee__c,Convenience__c FROM Pricing__c WHERE Commercial2__c = :commercialId AND Below_Rack_Rates__c = true AND Banking_Ops_Status__c = NULL AND Deleted__c = false AND Invisible__c = false]) {
                                          BelowRackRateRecord record = new BelowRackRateRecord();
                                          wrpCls.listPricingIds.add(pricing.Id);
                                          record.pricingRecordId = pricing.Id;
                                          record.paymentMode = pricing.Payment_Mode_Text__c;    
                                          record.paymentOption = pricing.Payment_Option_Text__c;
                                          record.paymentSpecification = pricing.Specifcation__c;
                                          record.paymentGateway = pricing.Payment_Gateway_Text__c;
                                          if(pricing.TDR_Amount_Reference__c != NULL) record.tdrAmountReference = pricing.TDR_Amount_Reference__c;
                                          if(pricing.TDR_Percentage_Reference__c != NULL) record.tdrPercentageReference = pricing.TDR_Percentage_Reference__c;
                                          if(pricing.TDR_Amount__c != NULL) record.tdrAmount = pricing.TDR_Amount__c;
                                          if(pricing.TDR_Flat_Fee__c != NULL) record.tdrFlatFee = pricing.TDR_Flat_Fee__c;
                                          if(pricing.TDR__c != NULL) record.tdrPercentage = pricing.TDR__c;
                                          if(pricing.Convenience_Amount_Reference__c != NULL) record.convenienceAmountReference = pricing.Convenience_Amount_Reference__c;
                                          if(pricing.Convenience_Percentage_Reference__c != NULL) record.conveniencePercentageReference = pricing.Convenience_Percentage_Reference__c;
                                          if(pricing.Convenience_Amount__c != NULL) record.convenienceAmount = pricing.Convenience_Amount__c;
                                          if(pricing.Convenience_Flat_Fee__c != NULL)record.convenienceFlatFee = pricing.Convenience_Flat_Fee__c;
                                          if(pricing.Convenience__c != NULL) record.conveniencePercentage = pricing.Convenience__c;
                                          wrpCls.listBelowRackRateRecords.add(record);
                                      }		    
        }
        catch(exception e) {
            wrpCls.message = e.getMessage();    
        }
        return wrpCls;
    }
    
    //Wrapper class to return on getBelowRackRatesRecords
    public class BelowRackRatesRecordsWrapper {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public List<BelowRackRateRecord> listBelowRackRateRecords = new List<BelowRackRateRecord>();
        @AuraEnabled public List<String> listPricingIds = new List<String>();
    }
    
    //Wrapper class to return on getBelowRackRatesRecords
    public class BelowRackRateRecord {
        @AuraEnabled public String pricingRecordId = '';
        @AuraEnabled public String paymentMode = '';
        @AuraEnabled public String paymentOption = '';
        @AuraEnabled public String paymentSpecification = '';
        @AuraEnabled public String paymentGateway = '';
        @AuraEnabled public Decimal tdrAmountReference = 0;
        @AuraEnabled public Decimal tdrPercentageReference = 0;
        @AuraEnabled public Decimal tdrAmount = 0;
        @AuraEnabled public Decimal tdrFlatFee = 0;
        @AuraEnabled public Decimal tdrPercentage = 0;
        @AuraEnabled public Decimal convenienceAmountReference = 0;
        @AuraEnabled public Decimal conveniencePercentageReference = 0;
        @AuraEnabled public Decimal convenienceAmount = 0;
        @AuraEnabled public Decimal convenienceFlatFee = 0;
        @AuraEnabled public Decimal conveniencePercentage = 0;
    }
    
    /*
* Description       : This method is called to update the below rack rates records
* Version.          : 1   
*/
    @AuraEnabled
    public static updatePricingRecordsWrapper updateBelowRackRatesRecords(String commercialId,String belowRackRatesRecords,List<String> listPricingIds) {
        updatePricingRecordsWrapper wrpCls = new updatePricingRecordsWrapper();
        try {
            //Enable the last status of the post approved records
            List<Commercial2__c> listCommercial = [SELECT Opportunity__c FROM Commercial2__c WHERE Id =:commercialId];
            Map<String,Integer> mapBankAndPORTypeToStatus = getMapBankAndPORTypeToStatus(listCommercial[0].Opportunity__c);
            //------------End | Enable the last status of the post approved records
            List<BelowRackRateRecord> listBelowRackRateRecords = (List<BelowRackRateRecord>)JSON.deserialize(belowRackRatesRecords, List<BelowRackRateRecord>.class);
            List<Pricing__c> listPricingToUpdate = new List<Pricing__c>();
            Map<Id,Pricing__c> mapIdToPricing = new Map<Id,Pricing__c>([SELECT Id,TDR_Percentage_Reference__c,TDR_Amount_Reference__c,TDR_Amount__c,TDR_Flat_Fee__c,
                                                                        TDR__c,Convenience_Percentage_Reference__c,Convenience_Amount_Reference__c,Type__c,Banking_Ops_Status__c, 
                                                                        Convenience_Amount__c,Convenience_Flat_Fee__c,Convenience__c,Transaction_Type__c,Below_Rack_Rates__c,
                                                                        Bank_Name__c,POR_Type_Name__c
                                                                        FROM Pricing__c 
                                                                        WHERE Id IN :listPricingIds AND Invisible__c = false]);
            
            for(BelowRackRateRecord record : listBelowRackRateRecords) {
                if(mapIdToPricing.containsKey(record.pricingRecordId)) {
                    Boolean isUpdate = false,isBelowRackRate = false;
                    Pricing__c pricing = mapIdToPricing.get(record.pricingRecordId);
                    if(pricing.Transaction_Type__c == 'TDR') {
                        if(pricing.TDR__c != record.tdrPercentage) {
                            pricing.TDR__c = record.tdrPercentage;	
                            isUpdate = true;
                        }
                        if(pricing.TDR_Flat_Fee__c != record.tdrFlatFee) {
                            pricing.TDR_Flat_Fee__c = record.tdrFlatFee;
                            isUpdate = true;
                        }
                        
                        if(isUpdate) {
                            if(pricing.TDR__c != 0 && pricing.TDR_Flat_Fee__c != 0 && pricing.TDR__c >= pricing.TDR_Percentage_Reference__c && pricing.TDR_Flat_Fee__c >= pricing.TDR_Amount_Reference__c) {
                                isBelowRackRate = true; 	    
                            }
                            else if(pricing.TDR__c == 0 && pricing.TDR_Flat_Fee__c != 0 && pricing.TDR_Flat_Fee__c >= pricing.TDR_Amount_Reference__c) {
                                isBelowRackRate = true;    
                            }
                            else if(pricing.TDR_Flat_Fee__c == 0 && pricing.TDR__c != 0 && pricing.TDR__c >= pricing.TDR_Percentage_Reference__c) {
                                isBelowRackRate = true;
                            }
                            if(isBelowRackRate) {
                                pricing.Below_Rack_Rates__c = false;
                                if(pricing.Type__c == 'PreApproved') {
                                    pricing.Banking_Ops_Status__c = 'Approved';    
                                }
                                else if(pricing.Type__c == 'PostApproved') {
                                    pricing.Banking_Ops_Status__c = getStatus(pricing,mapBankAndPORTypeToStatus,mapPriorityToStatus);    
                                }    
                            }
                            listPricingToUpdate.add(pricing);
                        }    
                    }
                    else if(pricing.Transaction_Type__c == 'Convenience') {
                        if(pricing.Convenience__c  != record.conveniencePercentage) {
                            pricing.Convenience__c = record.conveniencePercentage;	
                            isUpdate = true;
                        }
                        if(pricing.Convenience_Flat_Fee__c  != record.convenienceFlatFee) {
                            pricing.Convenience_Flat_Fee__c  = record.convenienceFlatFee;
                            isUpdate = true;
                        }
                        
                        if(isUpdate) {
                            if(pricing.Convenience__c != 0 && pricing.Convenience_Flat_Fee__c != 0 && pricing.Convenience__c >= pricing.Convenience_Percentage_Reference__c  && pricing.Convenience_Flat_Fee__c >= pricing.Convenience_Amount_Reference__c) {
                                isBelowRackRate = true; 	    
                            }
                            else if(pricing.Convenience__c == 0 && pricing.Convenience_Flat_Fee__c != 0 && pricing.Convenience_Flat_Fee__c >= pricing.Convenience_Amount_Reference__c) {
                                isBelowRackRate = true;    
                            }
                            else if(pricing.Convenience_Flat_Fee__c == 0 && pricing.Convenience__c != 0 && pricing.Convenience__c >= pricing.Convenience_Percentage_Reference__c) {
                                isBelowRackRate = true;
                            }
                            if(isBelowRackRate) {
                                pricing.Below_Rack_Rates__c = false;
                                if(pricing.Type__c == 'PreApproved') {
                                    pricing.Banking_Ops_Status__c = 'Approved';    
                                }
                                else if(pricing.Type__c == 'PostApproved') {
                                    pricing.Banking_Ops_Status__c = getStatus(pricing,mapBankAndPORTypeToStatus,mapPriorityToStatus);    
                                }    
                            }
                            listPricingToUpdate.add(pricing);
                        }
                    }
                    else {
                        if(pricing.TDR__c != record.tdrPercentage) {
                            pricing.TDR__c = record.tdrPercentage;	
                            isUpdate = true;
                        }
                        if(pricing.TDR_Flat_Fee__c != record.tdrFlatFee) {
                            pricing.TDR_Flat_Fee__c = record.tdrFlatFee;
                            isUpdate = true;
                        }   
                        if(pricing.Convenience__c  != record.conveniencePercentage) {
                            pricing.Convenience__c = record.conveniencePercentage;	
                            isUpdate = true;
                        }
                        if(pricing.Convenience_Flat_Fee__c  != record.convenienceFlatFee) {
                            pricing.Convenience_Flat_Fee__c  = record.convenienceFlatFee;
                            isUpdate = true;
                        }
                        
                        if(isUpdate) {
                            if(pricing.TDR__c != 0 && pricing.TDR_Flat_Fee__c != 0 && pricing.TDR__c >= pricing.TDR_Percentage_Reference__c 
                               && pricing.TDR_Flat_Fee__c >= pricing.TDR_Amount_Reference__c && pricing.Convenience__c != 0 
                               && pricing.Convenience_Flat_Fee__c != 0 && pricing.Convenience__c >= pricing.Convenience_Percentage_Reference__c  
                               && pricing.Convenience_Flat_Fee__c >= pricing.Convenience_Amount_Reference__c) {
                                   isBelowRackRate = true;    
                               }
                            else if(pricing.TDR__c != 0 && pricing.TDR_Flat_Fee__c != 0 && pricing.TDR__c >= pricing.TDR_Percentage_Reference__c 
                                    && pricing.TDR_Flat_Fee__c >= pricing.TDR_Amount_Reference__c && pricing.Convenience__c != 0 
                                    && pricing.Convenience_Flat_Fee__c == 0 && pricing.Convenience__c >= pricing.Convenience_Percentage_Reference__c) {
                                        isBelowRackRate = true;    
                                    }
                            else if(pricing.TDR__c != 0 && pricing.TDR_Flat_Fee__c != 0 && pricing.TDR__c >= pricing.TDR_Percentage_Reference__c 
                                    && pricing.TDR_Flat_Fee__c >= pricing.TDR_Amount_Reference__c && pricing.Convenience__c == 0 
                                    && pricing.Convenience_Flat_Fee__c != 0 && pricing.Convenience_Flat_Fee__c >= pricing.Convenience_Amount_Reference__c) {
                                        isBelowRackRate = true;    
                                    }
                            else if(pricing.TDR__c != 0 && pricing.TDR_Flat_Fee__c == 0 && pricing.TDR__c >= pricing.TDR_Percentage_Reference__c 
                                    && pricing.Convenience__c != 0 && pricing.Convenience_Flat_Fee__c != 0 && pricing.Convenience__c >= pricing.Convenience_Percentage_Reference__c  
                                    && pricing.Convenience_Flat_Fee__c >= pricing.Convenience_Amount_Reference__c) {
                                        isBelowRackRate = true;    
                                    }
                            else if(pricing.TDR__c != 0 && pricing.TDR_Flat_Fee__c == 0 && pricing.TDR__c >= pricing.TDR_Percentage_Reference__c 
                                    && pricing.Convenience__c != 0 && pricing.Convenience_Flat_Fee__c == 0 
                                    && pricing.Convenience__c >= pricing.Convenience_Percentage_Reference__c) {
                                        isBelowRackRate = true;    
                                    }
                            else if(pricing.TDR__c != 0 && pricing.TDR_Flat_Fee__c == 0 && pricing.TDR__c >= pricing.TDR_Percentage_Reference__c 
                                    && pricing.Convenience__c == 0 && pricing.Convenience_Flat_Fee__c != 0   
                                    && pricing.Convenience_Flat_Fee__c >= pricing.Convenience_Amount_Reference__c) {
                                        isBelowRackRate = true;    
                                    }
                            else if(pricing.TDR__c == 0 && pricing.TDR_Flat_Fee__c != 0 
                                    && pricing.TDR_Flat_Fee__c >= pricing.TDR_Amount_Reference__c && pricing.Convenience__c != 0 
                                    && pricing.Convenience_Flat_Fee__c != 0 && pricing.Convenience__c >= pricing.Convenience_Percentage_Reference__c  
                                    && pricing.Convenience_Flat_Fee__c >= pricing.Convenience_Amount_Reference__c) {
                                        isBelowRackRate = true;    
                                    }
                            else if(pricing.TDR__c == 0 && pricing.TDR_Flat_Fee__c != 0
                                    && pricing.TDR_Flat_Fee__c >= pricing.TDR_Amount_Reference__c && pricing.Convenience__c != 0 
                                    && pricing.Convenience_Flat_Fee__c == 0 && pricing.Convenience__c >= pricing.Convenience_Percentage_Reference__c) {
                                        isBelowRackRate = true;   
                                    }
                            else if(pricing.TDR__c == 0 && pricing.TDR_Flat_Fee__c != 0 
                                    && pricing.TDR_Flat_Fee__c >= pricing.TDR_Amount_Reference__c && pricing.Convenience__c == 0 
                                    && pricing.Convenience_Flat_Fee__c != 0   
                                    && pricing.Convenience_Flat_Fee__c >= pricing.Convenience_Amount_Reference__c) {
                                        isBelowRackRate = true;	    
                                    }
                            if(isBelowRackRate) {
                                pricing.Below_Rack_Rates__c = false;
                                if(pricing.Type__c == 'PreApproved') {
                                    pricing.Banking_Ops_Status__c = 'Approved';    
                                }
                                else if(pricing.Type__c == 'PostApproved') {
                                    pricing.Banking_Ops_Status__c = getStatus(pricing,mapBankAndPORTypeToStatus,mapPriorityToStatus);   
                                }    
                            }
                            listPricingToUpdate.add(pricing);
                        }
                    }
                }
            }
            if(listPricingToUpdate.size() > 0) {
                update listPricingToUpdate; 
            }
            List<Pricing__c> listPricing = [SELECT Id FROM Pricing__c WHERE Id IN :listPricingIds AND Below_Rack_Rates__c = true AND Deleted__c = false AND Invisible__c = false];
            if(listPricing != NULL && listPricing.size() > 0) {
                wrpCls.showBelowRackRateMessage = true;
                wrpCls.belowRackRateMessage = 'There are '+listPricing.size()+' pricing records which are below rack rates.';
            }
            Commercial2__c commercial = new Commercial2__c();
            commercial.Id = commercialId;
            commercial.Is_Updated__c = true;
            update commercial; 
            wrpCls.disabledBHButton = false;
            wrpCls.selectedListPaymentData = getInsertedPricingRecords(commercialId);
        } 
        catch(exception e) {
            wrpCls.message = e.getMessage();
        }
        return wrpCls;
    }
    
    //Wrapper class to return data to component after the update of Below rack rates records
    public class updatePricingRecordsWrapper {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public Boolean showBelowRackRateMessage = false;
        @AuraEnabled public String belowRackRateMessage = '';
        @AuraEnabled public Boolean disabledBHButton = true;
        @AuraEnabled public String selectedListPaymentData = '';
    }
    
    /*
* Description       : This method is used to load data on the modal for sending for BH Approval
* Version.          : 1   
*/
    @AuraEnabled
    public static SendToBHWrapper getSendToBHRecords(String commercialId) {
        SendToBHWrapper wrpCls = new SendToBHWrapper();
        try {
            List<User> listUser = [SELECT Name FROM USER WHERE Id = :UserInfo.getUserId()];
            List<Commercial2__c> listCommercial = [SELECT Id,Merchant_MID__c,Opportunity__r.Account.Name FROM Commercial2__C WHERE Id = :commercialId];
            //wrpCls.bhAddress = Label.BH_Email_Id;
            PicklistValues p1 = new PicklistValues();
            p1.label = '--None--';
            p1.value = '';
            wrpCls.listBHAddress.add(p1);
            for(String bhAddress : Label.BH_Email_Id.split(',')) {
                PicklistValues p2 = new PicklistValues();
                p2.label = bhAddress;
                p2.value = bhAddress; 
                wrpCls.listBHAddress.add(p2);
            }
            wrpCls.subject = Label.BH_Approval_Email_Subject + '-' + String.valueOf(listCommercial[0].Merchant_MID__c);
            String body = String.valueof(Label.BH_Approval_Email_Body);
            body = body.replace('<MerchantName>',String.valueOf(listCommercial[0].Opportunity__r.Account.Name));
            body = body.replace('<MID>',String.valueOf(listCommercial[0].Merchant_MID__c));
            body = body.replace('<KAMName>',String.valueOf(listUser[0].Name));
            //wrpCls.body = String.valueof(Label.BH_Approval_Email_Body);
            wrpCls.body = body;
            BelowRackRatesRecordsWrapper belowWrpCls = getBelowRackRatesRecords(commercialId);
            wrpCls.listBelowRackRatesRecords = belowWrpCls.listBelowRackRateRecords;
            wrpCls.listPricingIds = belowWrpCls.listPricingIds;
        }   
        catch(exception e) {
            wrpCls.message = e.getMessage();    
        }
        return wrpCls;
    }
    
    //Wrapper Class to return data on opening of Modal - BH Approval
    public class SendToBHWrapper {
        @AuraEnabled public String message ='SUCCESS';
        @AuraEnabled public List<PicklistValues> listBHAddress = new List<PicklistValues>();
        //@AuraEnabled public String bhAddress = '';
        @AuraEnabled public String subject = '';
        @AuraEnabled public String body = '';
        @AuraEnabled public List<BelowRackRateRecord> listBelowRackRatesRecords = new List<BelowRackRateRecord>();
        @AuraEnabled public List<String> listPricingIds = new List<String>();
    }
    
    /*
* Description       : This method is used to send below rack rates records for the BH Approval
* Version.          : 1   
*/
    @AuraEnabled
    public static String sendToBHEmail(String commercialId,String body,String subject,List<String> listPricingIds,String bhAddress) {
        try {
            List<Pricing__c> listPricingToUpdate = new List<Pricing__c>();
            for(Id pricingId : listPricingIds) {
                Pricing__c pricing = new Pricing__c();
                pricing.Id = pricingId;
                pricing.Banking_Ops_Status__c = 'Pending with BH';
                pricing.BH_Status__c = 'Pending with BH';
                listPricingToUpdate.add(pricing);
            }
            if(listPricingToUpdate.size() > 0) {
                update listPricingToUpdate;
            }
            
            //Send Email to BH
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            List<String> listToAddress = new List<String>();
            listToAddress.add(bhAddress);
            email.setToAddresses(listToAddress);
            email.setSubject(subject);
            body = body.replace('ClickHere',String.valueOf('<a href="'+Label.BH_Site_URL+commercialId+'">Click here to view records</a>'));
            //String htmlBody = body + '<br/><a href="'+Label.BH_Site_URL+commercialId+'">Click here to view records</a>';
            String htmlBody = body;
            email.setHtmlBody(htmlBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            return 'SUCCESS';    
        }
        catch(Exception e) {
            return e.getMessage();
        }
    }
    
    /*
* Description       : This method is used to publish the commercial and insert fixed pricing
* Version.          : 1   
*/
    @AuraEnabled 
    public static String insertFixedPricingAndPublishCommercial(String commercialId,String listFixedPricingString,
                                                                String listPlatformFee,String listFallbackCharges,
                                                                String selectedType,String selectedInterval,String selectedStartDate,
                                                                String selectedEndDate,String selectedDebitModel,String listFixedPricing2) {
                                                                    try {
                                                                        //Make only one commercial Active
                                                                        /*List<Commercial2__c> listCommercial = [SELECT Opportunity__c,Merchant_MID__c FROM Commercial2__c WHERE Id = :commercialId];
if(listCommercial != NULL && listCommercial.size() > 0) {
List<Commercial2__c> listLiveCommercial = [SELECT Id FROM Commercial2__c WHERE Opportunity__c = :listCommercial[0].Opportunity__c AND Status__c = 'Live'];
if(listLiveCommercial != NULL && listLiveCommercial.size() > 0 && listLiveCommercial[0].Id != commercialId) {
Set<String> setRuleIdsNotLive = new Set<String>();
List<Pricing__c> listPricingToUpdate = new List<Pricing__c>();
for(Pricing__c price: [SELECT Id,Rule_Id__c,Rule_Id_Conv__c,Need_to_Publish__c 
FROM Pricing__c 
WHERE Commercial2__c = :listLiveCommercial[0].Id 
AND (Rule_Id__c != NULL OR Rule_Id_Conv__c != NULL)]) {
if(String.isNotBlank(price.Rule_Id__c)) setRuleIdsNotLive.add(price.Rule_Id__c); 
if(String.isNotBlank(price.Rule_Id_Conv__c)) setRuleIdsNotLive.add(price.Rule_Id_Conv__c);
price.Need_to_Publish__c = true;
listPricingToUpdate.add(price);
}
if(setRuleIdsNotLive.size() > 0 && String.isNotBlank(listCommercial[0].Merchant_MID__c) && String.isNotBlank(listCommercial[0].Opportunity__c)) {
List<String> listRuleIdsNotLive = new List<String>(setRuleIdsNotLive);
RemovePricingFromTreasury.deletePricing(String.join(listRuleIdsNotLive,','),listCommercial[0].Merchant_MID__c,listCommercial[0].Opportunity__c); 
}	

if(listPricingToUpdate.size() > 0) update listPricingToUpdate;
Commercial2__c commNotLive = new Commercial2__c();
commNotLive.Id = listLiveCommercial[0].Id;
commNotLive.Status__c = 'Not Live';
update commNotLive;
}
}*/
                                                                        //End of make only one commercial active
                                                                        
                                                                        List<FixedPricing> listFixedPricing = (List<FixedPricing>)JSON.deserialize(listFixedPricingString,List<FixedPricing>.class);
                                                                        List<Fixed_Pricing__c> listFixedPricingToInsert = new List<Fixed_Pricing__c>();
                                                                        for(FixedPricing fp : listFixedPricing) {
                                                                            Fixed_Pricing__c fpNew = new Fixed_Pricing__c();
                                                                            fpNew.Setup_Fee__c = Decimal.valueOf(fp.setupFee);
                                                                            fpNew.Setup_Deposit__c = Decimal.valueOf(fp.securityDeposit);
                                                                            fpNew.AMC_Fee__c = Decimal.valueOf(fp.amcFee);
                                                                            fpNew.AMC_Interval__c = Decimal.valueOf(fp.amcInterval);
                                                                            fpNew.Commercial2__c = commercialId;
                                                                            listFixedPricingToInsert.add(fpNew);
                                                                        }
                                                                        
                                                                        List<Fixed_Pricing__c> listFixedPricingWithCommercialId = new List<Fixed_Pricing__c>();
                                                                        listFixedPricingWithCommercialId = [SELECT Id,Commercial2__r.Status__c FROM Fixed_Pricing__c WHERE Commercial2__c = :commercialId];
                                                                        if(listFixedPricingToInsert.size() > 0 && listFixedPricingWithCommercialId.size() == 0) {
                                                                            //insert listFixedPricingToInsert;
                                                                        }
                                                                        else if(listFixedPricingToInsert.size() > 0 && listFixedPricingWithCommercialId.size() == 1 && listFixedPricingWithCommercialId[0].Commercial2__r.Status__c != 'Draft'/*'Published'*/) {
                                                                            listFixedPricingToInsert[0].Id = listFixedPricingWithCommercialId[0].Id;
                                                                            //update listFixedPricingToInsert;
                                                                        }
                                                                        
                                                                        Commercial2__c commercial = new Commercial2__c();
                                                                        commercial.Id = commercialId;
                                                                        commercial.Status__c = 'Live';//'Published'
                                                                        commercial.Edited__c = false;
                                                                        commercial.Last_Published_On__c = System.now();
                                                                        update commercial;
                                                                        
                                                                        //Fixed Pricing 2 Logic
                                                                        Map<Id,Fixed_Pricing1__c> mapIdToFixedPricing2 = new Map<Id,Fixed_Pricing1__c>();
                                                                        for(Fixed_Pricing1__c fp : [SELECT Id,Start_Date__c,End_Date__c,Debit_Model__c,Fee_Type__c,Payment_Frequency__c,Flat_Fee__c,Percentage__c,Amount__c 
                                                                                                    FROM Fixed_Pricing1__c WHERE Commercial__c = :commercialId]) {
                                                                                                        mapIdToFixedPricing2.put(fp.Id,fp);	    
                                                                                                    }
                                                                        
                                                                        // if(mapIdToFixedPricing2.keySet().size() > 0) {
                                                                        List<Fixed_Pricing1__c> listFixedPricing1ToUpsert = new List<Fixed_Pricing1__c>();
                                                                        List<FixedPricing2> listFixedPricing2Latest = (List<FixedPricing2>)JSON.deserialize(listFixedPricing2,List<FixedPricing2>.class);
                                                                        for(FixedPricing2 fpObj : listFixedPricing2Latest) {
                                                                            if(String.isNotBlank(fpObj.recordId) && mapIdToFixedPricing2.keySet().size() > 0 && mapIdToFixedPricing2.containsKey(fpObj.recordId)) {
                                                                                Fixed_Pricing1__c fpExisting = mapIdToFixedPricing2.get(fpObj.recordId);
                                                                                Fixed_Pricing1__c fp = new Fixed_Pricing1__c();
                                                                                fp.Id = fpObj.recordId;
                                                                                fp.Payment_Frequency__c = String.isNotBlank(fpObj.paymentFrequency) ? fpObj.paymentFrequency : null;
                                                                                fp.Debit_Model__c = String.isNotBlank(fpObj.debitModel) ? fpObj.debitModel : null;
                                                                                fp.Start_Date__c = String.isNotBlank(fpObj.startDate) ? Date.valueOf(fpObj.startDate) : null;
                                                                                fp.End_Date__c = String.isNotBlank(fpObj.endDate) ? Date.valueOf(fpObj.endDate) : null;
                                                                                fp.Amount__c = String.isNotBlank(fpObj.amount) ? Decimal.valueOf(fpObj.amount) : null;
                                                                                fp.Flat_Fee__c = String.isNotBlank(fpObj.flatFee) ? Decimal.valueOf(fpObj.flatFee) : null;
                                                                                fp.Percentage__c = String.isNotBlank(fpObj.percentage) ? Decimal.valueOf(fpObj.percentage) : null;
                                                                                if(fp.Debit_Model__c != fpExisting.Debit_Model__c ||
                                                                                   fp.Payment_Frequency__c != fpExisting.Payment_Frequency__c || fp.Start_Date__c != fpExisting.Start_Date__c ||
                                                                                   fp.End_Date__c != fpExisting.End_Date__c || fp.Amount__c != fpExisting.Amount__c ||
                                                                                   fp.Flat_Fee__c != fpExisting.Flat_Fee__c || fp.Percentage__c != fpExisting.Percentage__c) {
                                                                                       fp.Need_to_Publish__c = true;
                                                                                       listFixedPricing1ToUpsert.add(fp);
                                                                                   }
                                                                            }
                                                                            else {
                                                                                Fixed_Pricing1__c fp = new Fixed_Pricing1__c();
                                                                                fp.Commercial__c = commercialId;
                                                                                fp.Need_to_Publish__c = true;
                                                                                if(String.isNotBlank(fpObj.flatFeeType)) fp.Fee_Type__c = fpObj.flatFeeType;
                                                                                if(String.isNotBlank(fpObj.paymentFrequency)) fp.Payment_Frequency__c = fpObj.paymentFrequency;
                                                                                if(String.isNotBlank(fpObj.debitModel)) fp.Debit_Model__c = fpObj.debitModel;
                                                                                if(String.isNotBlank(fpObj.startDate)) fp.Start_Date__c = Date.valueOf(fpObj.startDate);
                                                                                if(String.isNotBlank(fpObj.endDate)) fp.End_Date__c = Date.valueOf(fpObj.endDate);
                                                                                if(String.isNotBlank(fpObj.amount)) fp.Amount__c = Decimal.valueOf(fpObj.amount);
                                                                                if(String.isNotBlank(fpObj.flatFee)) fp.Flat_Fee__c = Decimal.valueOf(fpObj.flatFee);
                                                                                if(String.isNotBlank(fpObj.percentage)) fp.Percentage__c = Decimal.valueOf(fpObj.percentage);
                                                                                listFixedPricing1ToUpsert.add(fp);
                                                                            }
                                                                        }
                                                                        if(listFixedPricing1ToUpsert.size() > 0) upsert listFixedPricing1ToUpsert;
                                                                        //}
                                                                        
                                                                        
                                                                        //Platform Fee Logic
                                                                        Map<Id,Platform_Fee__c> mapIdToPlatformFee = new Map<Id,Platform_Fee__c>();
                                                                        for(Platform_Fee__c pf : [SELECT Id,Start_Date__c,End_Date__c,Debit_Model__c,Type__c,Interval__c,Flat_Fee__c,Percentage__c,Amount__c 
                                                                                                  FROM Platform_Fee__c WHERE Commercial__c = :commercialId ORDER BY Amount__c]) {
                                                                                                      mapIdToPlatformFee.put(pf.Id,pf);	    
                                                                                                  }
                                                                        
                                                                        if(mapIdToPlatformFee.keySet().size() > 0) {
                                                                            List<Platform_Fee__c> listPlatformFeeToUpsert = new List<Platform_Fee__c>();
                                                                            List<PlatformFee> listPlatformFeeLatest = (List<PlatformFee>)JSON.deserialize(listPlatformFee,List<PlatformFee>.class);
                                                                            for(PlatformFee pfObj : listPlatformFeeLatest) {
                                                                                if(String.isNotBlank(pfObj.Id)) {
                                                                                    Platform_Fee__c pfExisting = mapIdToPlatformFee.get(pfObj.Id);
                                                                                    Platform_Fee__c pf = new Platform_Fee__c();
                                                                                    pf.Id = pfObj.Id;
                                                                                    pf.Commercial__c = commercialId;
                                                                                    pf.Type__c = String.isNotBlank(selectedType) ? selectedType : null;
                                                                                    pf.Interval__c = String.isNotBlank(selectedInterval) ? selectedInterval : null;
                                                                                    pf.Debit_Model__c = String.isNotBlank(selectedDebitModel) ? selectedDebitModel : null;
                                                                                    pf.Start_Date__c = String.isNotBlank(selectedStartDate) ? Date.valueOf(selectedStartDate) : null;
                                                                                    pf.End_Date__c = String.isNotBlank(selectedEndDate) ? Date.valueOf(selectedEndDate) : null;
                                                                                    pf.Amount__c = String.isNotBlank(pfObj.amount) ? Decimal.valueOf(pfObj.amount) : null;
                                                                                    pf.Flat_Fee__c = String.isNotBlank(pfObj.flatFee) ? Decimal.valueOf(pfObj.flatFee) : null;
                                                                                    pf.Percentage__c = String.isNotBlank(pfObj.percentage) ? Decimal.valueOf(pfObj.percentage) : null;
                                                                                    if(pf.Debit_Model__c != pfExisting.Debit_Model__c || pf.Type__c != pfExisting.Type__c ||
                                                                                       pf.Interval__c != pfExisting.Interval__c || pf.Start_Date__c != pfExisting.Start_Date__c ||
                                                                                       pf.End_Date__c != pfExisting.End_Date__c || pf.Amount__c != pfExisting.Amount__c ||
                                                                                       pf.Flat_Fee__c != pfExisting.Flat_Fee__c || pf.Percentage__c != pfExisting.Percentage__c) {
                                                                                           pf.Need_to_Publish__c = true;
                                                                                           listPlatformFeeToUpsert.add(pf);
                                                                                       }
                                                                                }
                                                                                else {
                                                                                    Platform_Fee__c pf = new Platform_Fee__c();
                                                                                    pf.Commercial__c = commercialId;
                                                                                    pf.Need_to_Publish__c = true;
                                                                                    if(String.isNotBlank(selectedType)) pf.Type__c = selectedType;
                                                                                    if(String.isNotBlank(selectedInterval)) pf.Interval__c = selectedInterval;
                                                                                    if(String.isNotBlank(selectedDebitModel)) pf.Debit_Model__c = selectedDebitModel;
                                                                                    if(String.isNotBlank(selectedStartDate)) pf.Start_Date__c = Date.valueOf(selectedStartDate);
                                                                                    if(String.isNotBlank(selectedEndDate)) pf.End_Date__c = Date.valueOf(selectedEndDate);
                                                                                    if(String.isNotBlank(pfObj.amount)) pf.Amount__c = Decimal.valueOf(pfObj.amount);
                                                                                    if(String.isNotBlank(pfObj.flatFee)) pf.Flat_Fee__c = Decimal.valueOf(pfObj.flatFee);
                                                                                    if(String.isNotBlank(pfObj.percentage)) pf.Percentage__c = Decimal.valueOf(pfObj.percentage);
                                                                                    listPlatformFeeToUpsert.add(pf);
                                                                                }
                                                                            }
                                                                            if(listPlatformFeeToUpsert.size() > 0) upsert listPlatformFeeToUpsert;
                                                                        }
                                                                        
                                                                        //Fallback Charges Change
                                                                        Map<Id,Fallback_Charge__c> mapIdToFallbackCharges = new Map<Id,Fallback_Charge__c>();
                                                                        for(Fallback_Charge__c fc : [SELECT Id,Flat_Fee__c,Percentage__c FROM Fallback_Charge__c WHERE Commercial__c = :commercialId]) {
                                                                            mapIdToFallbackCharges.put(fc.Id,fc);	     
                                                                        }
                                                                        
                                                                        if(mapIdToFallbackCharges.keySet().size() > 0) {
                                                                            List<Fallback_Charge__c> listFallBackChargesToUpdate = new List<Fallback_Charge__c>();
                                                                            List<FallbackCharges> listFallbackChargesLatest = (List<FallbackCharges>)JSON.deserialize(listFallbackCharges,List<FallbackCharges>.class);
                                                                            for(FallbackCharges fc : listFallbackChargesLatest) {
                                                                                Fallback_Charge__c fcExisting = mapIdToFallbackCharges.get(fc.Id);
                                                                                Fallback_Charge__c fcNew = new Fallback_Charge__c();
                                                                                fcNew.Id = fc.Id;
                                                                                fcNew.Flat_Fee__c = String.isNotBlank(fc.flatFee) ? Decimal.valueOf(fc.flatFee) : null;
                                                                                fcNew.Percentage__c = String.isNotBlank(fc.percentage) ? Decimal.valueOf(fc.percentage) : null;
                                                                                if(fcNew.Flat_Fee__c != fcExisting.Flat_Fee__c || fcNew.Percentage__c != fcExisting.Percentage__c) {
                                                                                    fcNew.Need_to_Publish__c = true;
                                                                                    listFallBackChargesToUpdate.add(fcNew);
                                                                                }
                                                                            }
                                                                            
                                                                            if(listFallBackChargesToUpdate.size() > 0) update listFallBackChargesToUpdate;
                                                                        }
                                                                        
                                                                        
                                                                        //Call API Class to send data to treasury
                                                                        callTreasuryToPushRecords(commercialId);
                                                                        
                                                                        //Call Class to delete records from Tresury
                                                                        String opportunityId = '';
                                                                        Integer count = 0;
                                                                        Set<String> setPricingWithRuleId = new Set<String>();
                                                                        //Set<String> setRuleIds = new Set<String>();
                                                                        Set<String> setPricingIds = new Set<String>();
                                                                        for(Pricing__c price: [SELECT Id,Rule_Id__c,Rule_Id_Conv__c,Commercial2__r.Opportunity__c,Commercial2__r.Merchant_MID__c,
                                                                                               Temp_Id_TDR__c,Temp_Id_Conv__c,Transaction_Type__c
                                                                                               FROM Pricing__c 
                                                                                               WHERE Commercial2__c = :commercialId 
                                                                                               AND Commercial2__r.Status__c = 'Live'
                                                                                               AND Deleted__c = true
                                                                                               AND Invisible__c = false
                                                                                               AND Temp_Id_Delete_TDR__c = NULL 
                                                                                               AND Temp_Id_Delete_Conv__c = NULL]) {
                                                                                                   System.debug('>>>>>>priceId>>>>'+price.Id);
                                                                                                   if(count == 0) {
                                                                                                       opportunityId = price.Commercial2__r.Opportunity__c;
                                                                                                       count = 1;
                                                                                                   }
                                                                                                   if(price.Transaction_Type__c == 'TDR') {
                                                                                                       if(String.isNotBlank(price.Rule_Id__c) && String.isBlank(price.Temp_Id_TDR__c)) {
                                                                                                           //setRuleIds.add(price.Rule_Id__c);    
                                                                                                           setPricingWithRuleId.add(price.Id);
                                                                                                       }
                                                                                                       else if(String.isNotBlank(price.Temp_Id_TDR__c)) {
                                                                                                           setPricingIds.add(price.Id);	    
                                                                                                       }
                                                                                                   }
                                                                                                   else if(price.Transaction_Type__c == 'Convenience') {
                                                                                                       if(String.isNotBlank(price.Rule_Id_Conv__c) && String.isBlank(price.Temp_Id_Conv__c)) {
                                                                                                           //setRuleIds.add(price.Rule_Id_Conv__c);  
                                                                                                           setPricingWithRuleId.add(price.Id);
                                                                                                       }	
                                                                                                       else if(String.isNotBlank(price.Temp_Id_Conv__c)) {
                                                                                                           setPricingIds.add(price.Id);	    
                                                                                                       }
                                                                                                   }
                                                                                                   else {
                                                                                                       if(String.isNotBlank(price.Rule_Id__c) && String.isBlank(price.Temp_Id_TDR__c)) {
                                                                                                           //setRuleIds.add(price.Rule_Id__c);  
                                                                                                           setPricingWithRuleId.add(price.Id);
                                                                                                       }
                                                                                                       else if(String.isNotBlank(price.Temp_Id_TDR__c)) {
                                                                                                           setPricingIds.add(price.Id);	    
                                                                                                       }
                                                                                                       if(String.isNotBlank(price.Rule_Id_Conv__c) && String.isBlank(price.Temp_Id_Conv__c)) {
                                                                                                           //setRuleIds.add(price.Rule_Id_Conv__c);   
                                                                                                           setPricingWithRuleId.add(price.Id);
                                                                                                       }
                                                                                                       else if(String.isNotBlank(price.Temp_Id_Conv__c)) {
                                                                                                           setPricingIds.add(price.Id);	    
                                                                                                       }
                                                                                                   }
                                                                                               }
                                                                        //Delete data from Main table
                                                                        /*if(setRuleIds.size() > 0 && String.isNotBlank(commercialId) && String.isNotBlank(opportunityId)) {
String ruleIds = '[';
for(String ruleId : setRuleIds) {
ruleIds += '\"'+ruleId+'\",';
}
ruleIds = ruleIds.removeEnd(',');
ruleids += ']';
callTreasuryToDeleteRecords(ruleids,commercialId,opportunityId);    
}*/
                                                                        System.debug('>>>>>>setPricingWithRuleId>>>>>'+setPricingWithRuleId);
                                                                        if(setPricingWithRuleId.size() > 0 && String.isNotBlank(commercialId) && String.isNotBlank(opportunityId)){
                                                                            System.debug('>>>>>setPricingWithRuleId>>>>>'+setPricingWithRuleId);
                                                                            Database.executeBatch(new PublishPricingToTreasuryTempTable(setPricingWithRuleId,'DeleteBulkRules-CheckerFalseActionDelete',true),50);   
                                                                        }
                                                                        System.debug('>>>>>>setPricingIds>>>>>'+setPricingIds);
                                                                        //Delete data from Main table
                                                                        if(setPricingIds.size() > 0) {
                                                                            System.debug('>>>>>setPricingIds>>>>>'+setPricingIds);
                                                                            Database.executeBatch(new PublishPricingToTreasuryTempTableReject(setPricingIds,'SaveBulkRules-CheckerTrueActionRejectDelete',false),50);   
                                                                        }
                                                                        
                                                                        // End : Call Class to delete records from Tresury
                                                                        return 'SUCCESS';
                                                                    }
                                                                    catch(Exception e) {
                                                                        return e.getMessage();
                                                                    }    
                                                                }
    
    //Fixed Pricing Class
    public class FixedPricing {
        public String key;
        public String setupFee;
        public String securityDeposit;
        public String amcFee;
        public String amcInterval;
    }
    
    //Fixed Pricing2 Class
    public class FixedPricing2 {
        public String recordId = '';
        public String endDate = '';
        public String startDate = '';
        public String amount = '';
        public String flatFee = '';
        public String percentage = '';
        public String flatFeeType = '';
        public String paymentFrequency = '';
        public String debitModel = '';
        public Boolean showDeleteButton = true;
    }
    
    //Platform Fee Class
    public class PlatformFee {
        public String Id;
        public String amount;
        public String flatFee;
        public String percentage;
        public Boolean showRemoveButton = false;
        public Boolean disabledAmount = false;
        public String backgroundColor = 'background-color:white;';
    }
    
    //Fallback Charges Class
    public class FallbackCharges {
        public String Id;
        public String paymentModeName;
        public String flatFee;
        public String percentage;
    }
    
    
    /*
* Description       : This method is used to call the class to push pricing records to Treasury
* Version.          : 1   
*/
    public static void callTreasuryToPushRecords(String commercialId) {
        //Database.executeBatch(new PublishPricingToTreasuryMainTable(commercialId),100); not needed
        System.debug('>>>>>commercialId>>>>>'+commercialId);
        Database.executeBatch(new PublishPricingToTreasuryTempTable(commercialId,'SaveBulkRules-CheckerFalseActionSave',false),50);
        if(Label.StopPlatformFeeFlowToTreasury.toLowerCase() == 'false') {
            callTreasuryForPlatform(commercialId);    
        }
        if(Label.StopFallbackChargesFlowToTreasury.toLowerCase() == 'false') {
            callTreasuryForFallback(commercialId);    
        }
        if(Label.StopFixedPricingFlowToTreasury.toLowerCase() == 'false') {
            callTreasuryForFixed(commercialId);    
        }
    }
    
    @future(callout=true)
    public static void callTreasuryForPlatform(String commercialId) {
        PublishPlatformFeeToTreasury_CTRL.PricingToTreasury(commercialId);
    }
    
    @future(callout=true)
    public static void callTreasuryForFallback(String commercialId) {
        PublishFallbackToTreasury_CTRL.FallBackToTreasury(commercialId);
    }
    
    @future(callout=true)
    public static void callTreasuryForFixed(String commercialId) {
        PublishFixedFeeToTreasury_CTRL.FixedFeeToTreasury(commercialId);
    }
    
    /*
* Description       : This method is used to call the class to delete pricing records from Treasury
* Version.          : 1   
*/
    @future(callout=true)
    public static void callTreasuryToDeleteRecords(String ruleIds,String commercialId,String opportunityId) {
        //RemovePricingFromTreasuryNew.deletePricing(ruleIds,commercialId,opportunityId);		    
    }
    
    /*
* Description       : This method is used to pass informatio of the commercial before validating the pricing 
* Version.          : 1   
*/
    @AuraEnabled
    public static CommercialInformation getCommercialInformationBeforeValidatePricing(String commercialId) {
        CommercialInformation wrpCls = new CommercialInformation();
        try {
            List<AggregateResult> listTotalPricing = [SELECT Count(Id) totCon FROM Pricing__c WHERE Commercial2__c = :commercialId AND Deleted__c = false AND Invisible__c = false];    
            List<AggregateResult> listAboveAndBHPricing = [SELECT Count(Id) con FROM Pricing__c WHERE Commercial2__c = :commercialId AND Deleted__c = false AND Invisible__c = false AND (Below_Rack_Rates__c = false OR BH_Status__c IN ('Pending with BH','Rejected with BH','Approved with BH'))];
            if(listTotalPricing != NULL && listAboveAndBHPricing != NULL) {
                if((Integer)listTotalPricing[0].get('totCon') == (Integer)listAboveAndBHPricing[0].get('con')) {
                    wrpCls.allowValidation = true; 
                    wrpCls.selectedListPaymentData = getInsertedPricingRecords(commercialId);
                }
            }
        }
        catch(Exception e) {
            wrpCls.message = e.getMessage()+'#'+e.getLineNumber();
        }
        return wrpCls;
    }
    
    //Wrapper Class to return on call of getCommercialInformationBeforeValidatePricing
    public class CommercialInformation {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public Boolean allowValidation = false;
        @AuraEnabled public String selectedListPaymentData = '';
    }
    
    
    /*
* Description       : This method is called on change of the plan and sub plan to get the template details
* Version.          : 1   
*/
    @AuraEnabled/*(cacheable=true) ## To get the real time data*/
    public static WrapperClassOnLoad getTemplateDetails(String planId,String subPlanId) {
        WrapperClassOnLoad wrpCls = new WrapperClassOnLoad();
        try{
            wrpCls.jsonPlanMaster = '[';
            for(Template_Mapping__c pm : [SELECT Template__c,Template__r.Name FROM Template_Mapping__c 
                                          WHERE Plan__c =:planId AND Sub_Plan__c = :subPlanId 
                                          AND Template__c != NULL 
                                          AND (Template__r.Public_Template__c = true OR Template__r.CreatedById = :UserInfo.getUserId()) 
                                          LIMIT 50000]) {
                                              wrpCls.jsonPlanMaster += '{"label":"'+pm.Template__r.Name+'","value":"'+pm.Template__c+'"},';    
                                          } 
            wrpCls.jsonPlanMaster = wrpCls.jsonPlanMaster.removeEnd(',');
            wrpCls.jsonPlanMaster += ']';
        }
        catch(exception e) {
            wrpCls.message = e.getMessage();   
        }
        return wrpCls;    
    }
    
    /*
* Description       : This method is called on click of the Save as Template Button
* Version.          : 1   
*/
    @AuraEnabled 
    public static String createTemplateForOrdinaryUser(String templateName,String selectedListPaymentData,String listFixedPricingString,String commercialId) {
        String message = 'SUCCESS';
        Savepoint sp = Database.setSavepoint();
        try {
            List<Plan_Master__c> listPlan = [SELECT Id FROM Plan_Master__c WHERE Visible_for_Template_Creation__c = true LIMIT 1]; 
            List<Sub_Plan_Master__c> listSubPlan = [SELECT Id FROM Sub_Plan_Master__c WHERE Visible_for_Template_Creation__c = true LIMIT 1];  
            if(listPlan != NULL && listPlan.size() > 0 && listSubPlan != NULL && listSubPlan.size() > 0) {
                String source = 'Scratch';
                if(String.isNotBlank(commercialId)) {
                    List<Commercial2__c> listCommercial = [SELECT Source__c FROM Commercial2__c WHERE Id = :commercialId];
                    source = listCommercial[0].Source__c;
                }
                
                List<Pricing_Template__c> listTemplate = [SELECT Id FROM Pricing_Template__c WHERE Id = :templateName];
                Boolean isExistingTemplate = false;
                if(listTemplate != NULL && listTemplate.size() > 0) {
                    isExistingTemplate = true;
                    DELETE [SELECT Id FROM Template_Details__c WHERE Template__c = :listTemplate[0].Id];
                }
                
                Pricing_Template__c template = new Pricing_Template__c();
                if(!isExistingTemplate) template.Name = templateName;
                template.Source__c = source;
                if(isExistingTemplate) template.Id = listTemplate[0].Id;
                /* These lines are commented by Anas : To handle multiple fixed pricing records under commercials
List<FixedPricing> listFixedPricing = (List<FixedPricing>)JSON.deserialize(listFixedPricingString,List<FixedPricing>.class);
for(FixedPricing fp : listFixedPricing) {
if(String.isNotBlank(fp.setupFee)) template.Setup_Fee__c = Decimal.valueOf(fp.setupFee);
else template.Setup_Fee__c = null;
if(String.isNotBlank(fp.securityDeposit)) template.Setup_Deposit__c = Decimal.valueOf(fp.securityDeposit);
else template.Setup_Deposit__c = null;
if(String.isNotBlank(fp.amcFee)) template.AMC_Fee__c = Decimal.valueOf(fp.amcFee);
else template.AMC_Fee__c = null;
if(String.isNotBlank(fp.amcInterval)) template.AMC_Interval__c = Decimal.valueOf(fp.amcInterval);
else template.AMC_Interval__c = null;
}
*/
                if(isExistingTemplate) update template;
                else {
                    template.Sub_Plan_Master__c = listSubPlan[0].Id; //Added to incorporate the new changes in the Template
                    insert template;    
                }
                
                if(!isExistingTemplate) {
                    Template_Mapping__c templateMapping = new Template_Mapping__c();
                    templateMapping.Plan__c = listPlan[0].Id;
                    templateMapping.Sub_Plan__c = listSubPlan[0].Id;
                    templateMapping.Template__c = template.Id;
                    insert templateMapping;    
                }
                
                
                List<Template_Details__c> listTemplateDetailsToInsert = new List<Template_Details__c>(); 
                List<SelectedPaymentData> listSelectedPaymentData = (List<SelectedPaymentData>)JSON.deserialize(selectedListPaymentData,List<SelectedPaymentData>.class);
                for(SelectedPaymentData spd : listSelectedPaymentData) {
                    for(SelectedPaymentOptions spo : spd.selectedPaymentOptionsList) {
                        for(SelectedPaymentDataSingleRecord spdsr : spo.selectedPaymentIndividualList) {
                            String identifier = spd.paymentModeId+'#'+spdsr.selectedPaymentOptionId+'#'+mapIdentifierToPricingSpecificationId.get(spdsr.selectedSpecification)+'#'+mapIdentifierToPaymentGatewayId.get(spdsr.selectedPaymentGatewayName).Id+'#'+spdsr.selectedOnusOffus;
                            if(mapIdentifierToMasterPricingDataId.containsKey(identifier)) {
                                Template_Details__c td = new Template_Details__c();
                                td.Template__c = template.Id;
                                td.Payment_Mode__c = spd.paymentModeId;
                                td.Payment_Option__c = spdsr.selectedPaymentOptionId;
                                td.Pricing_Specification__c = mapIdentifierToPricingSpecificationId.get(spdsr.selectedSpecification);
                                td.Payment_Gateway2__c = mapIdentifierToPaymentGatewayId.get(spdsr.selectedPaymentGatewayName).Id; 
                                td.ONUS_OFFUS__c = spdsr.selectedOnusOffus;
                                td.Fee_Model__c = spdsr.selectedFeeModel;
                                td.Transaction_Type__c = spdsr.selectedTransactionType;
                                td.Master_Pricing_Data__c = mapIdentifierToMasterPricingDataId.get(identifier).Id;
                                if(td.Transaction_Type__c == 'TDR') {
                                    td.TDR_Amount__c = String.isNotBlank(spdsr.tdrAmount) ? Decimal.valueOf(spdsr.tdrAmount) : 0;
                                    td.TDR_Flat_Fee__c = String.isNotBlank(spdsr.tdrFee) ? Decimal.valueOf(spdsr.tdrFee) : 0;
                                    td.TDR__c = String.isNotBlank(spdsr.tdrPercentage) ? Decimal.valueOf(spdsr.tdrPercentage) : 0;
                                }
                                else if(td.Transaction_Type__c == 'Convenience') {
                                    td.Convenience_Amount__c = String.isNotBlank(spdsr.convenienceAmount) ? Decimal.valueOf(spdsr.convenienceAmount) : 0;
                                    td.Convenience_Flat_Fee__c = String.isNotBlank(spdsr.convenienceFee) ? Decimal.valueOf(spdsr.convenienceFee) : 0;
                                    td.Convenience__c = String.isNotBlank(spdsr.conveniencePercentage) ? Decimal.valueOf(spdsr.conveniencePercentage) : 0;	    
                                }
                                else {
                                    td.TDR_Amount__c = String.isNotBlank(spdsr.tdrAmount) ? Decimal.valueOf(spdsr.tdrAmount) : 0;
                                    td.TDR_Flat_Fee__c = String.isNotBlank(spdsr.tdrFee) ? Decimal.valueOf(spdsr.tdrFee) : 0;
                                    td.TDR__c = String.isNotBlank(spdsr.tdrPercentage) ? Decimal.valueOf(spdsr.tdrPercentage) : 0;
                                    td.Convenience_Amount__c = String.isNotBlank(spdsr.convenienceAmount) ? Decimal.valueOf(spdsr.convenienceAmount) : 0;
                                    td.Convenience_Flat_Fee__c = String.isNotBlank(spdsr.convenienceFee) ? Decimal.valueOf(spdsr.convenienceFee) : 0;
                                    td.Convenience__c = String.isNotBlank(spdsr.conveniencePercentage) ? Decimal.valueOf(spdsr.conveniencePercentage) : 0;
                                }
                                listTemplateDetailsToInsert.add(td);
                            }
                        }
                    }
                }
                if(listTemplateDetailsToInsert.size() > 0) {
                    insert listTemplateDetailsToInsert;
                }
            }
            else {
                return 'Plan and Sub Plan not found';
            }
        }
        catch(Exception e) {
            message = e.getMessage();
            Database.rollback(sp);
        }
        return message;
    }
    
    /*
* Description       : This method is called on click of Update Exisiting Plan for the Ordinary User
* Version.          : 1   
*/
    @AuraEnabled/*(cacheable=true) ## To get the real time data*/
    public static WrapperClassOnLoad getPrivateTemplateDetails() {
        WrapperClassOnLoad wrpCls = new WrapperClassOnLoad();
        try{
            Set<Id> setTemplateId = new Set<Id>();
            wrpCls.jsonPlanMaster = '[';
            for(Template_Mapping__c pm : [SELECT Template__c,Template__r.Name FROM Template_Mapping__c 
                                          WHERE Template__c != NULL 
                                          AND Template__r.CreatedById = :UserInfo.getUserId() LIMIT 50000]) {
                                              if(!setTemplateId.contains(pm.Template__c)) {
                                                  wrpCls.jsonPlanMaster += '{"label":"'+pm.Template__r.Name+'","value":"'+pm.Template__c+'"},'; 
                                                  setTemplateId.add(pm.Template__c);  
                                              } 
                                          } 
            wrpCls.jsonPlanMaster = wrpCls.jsonPlanMaster.removeEnd(',');
            wrpCls.jsonPlanMaster += ']';
        }
        catch(exception e) {
            wrpCls.message = e.getMessage();   
        }
        return wrpCls;    
    }
    
    /*
* Description       : This method is called on choosing of Choose existing plan, sub plan and create new template for super user
* Version.          : 1   
*/
    @AuraEnabled/*(cacheable=true) ## To get the real time data*/
    public static WrapperClassToReturnPlanAndSubPlan getPlanAndSubPlanDetails() {
        WrapperClassToReturnPlanAndSubPlan wrpCls = new WrapperClassToReturnPlanAndSubPlan();
        try {
            wrpCls.jsonPlanMaster = '[';
            for(Plan_Master__c pm : [SELECT Id,Name FROM Plan_Master__c LIMIT 50000]) {
                wrpCls.jsonPlanMaster += '{"label":"'+pm.Name+'","value":"'+pm.Id+'"},';    
            } 
            wrpCls.jsonPlanMaster = wrpCls.jsonPlanMaster.removeEnd(',');
            wrpCls.jsonPlanMaster += ']'; 
            
            /*wrpCls.jsonSubPlanMaster = '[';
for(Sub_Plan_Master__c spm : [SELECT Id,Name FROM Sub_Plan_Master__c LIMIT 50000]) {
wrpCls.jsonSubPlanMaster += '{"label":"'+spm.Name+'","value":"'+spm.Id+'"},';    
} 
wrpCls.jsonSubPlanMaster = wrpCls.jsonSubPlanMaster.removeEnd(',');
wrpCls.jsonSubPlanMaster += ']'; */
        }
        catch(Exception e) {
            wrpCls.message = e.getMessage();            
        }
        return wrpCls;
    }
    
    /*
* Description       : This method is called on change of plan name 
* Version.          : 1  
* Added to incorporate the changes in Template architecture
*/
    @AuraEnabled/*(cacheable=true) ## To get the real time data*/
    public static WrapperClassToReturnPlanAndSubPlan getSubPlanDetailsForSelectedPlan(String planId) {
        WrapperClassToReturnPlanAndSubPlan wrpCls = new WrapperClassToReturnPlanAndSubPlan();
        try {
            wrpCls.jsonSubPlanMaster = '[';
            for(Sub_Plan_Master__c spm : [SELECT Id,Name FROM Sub_Plan_Master__c WHERE Plan_Master__c = :planId LIMIT 50000]) {
                wrpCls.jsonSubPlanMaster += '{"label":"'+spm.Name+'","value":"'+spm.Id+'"},';    
            } 
            wrpCls.jsonSubPlanMaster = wrpCls.jsonSubPlanMaster.removeEnd(',');
            wrpCls.jsonSubPlanMaster += ']'; 
        }
        catch(Exception e) {
            wrpCls.message = e.getMessage();            
        }
        return wrpCls;
    }
    
    //Wrapper class to return Plan and Sub Plan Details
    public class WrapperClassToReturnPlanAndSubPlan {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public String jsonPlanMaster = '[]';
        @AuraEnabled public String jsonSubPlanMaster = '[]';
    }
    
    
    /*
* Description       : This method is called on click of Save from different modals for the Super User
* Version.          : 1   
*/   
    @AuraEnabled 
    public static String createTemplateForSuperUser(String templateName,String selectedListPaymentData,String listFixedPricingString,String commercialId,Boolean publicTemplateCheckbox,String planName,String subPlanName,String action) {
        String message = 'SUCCESS';
        Savepoint sp = Database.setSavepoint();
        try {
            String planId = planName;
            String subPlanId = subPlanName;
            if(action == 'option4' || action == 'option3') {
                Plan_Master__c plan = new Plan_Master__c();
                plan.Name = planName;
                insert plan;
                planId = plan.Id;
                
                Sub_Plan_Master__c subPlan = new Sub_Plan_Master__c();
                subPlan.Name = subPlanName;
                subPlan.Plan_Master__c = planId;
                insert subPlan;
                subPlanId = subPlan.Id;
            }
            
            if(action == 'option5') {
                Sub_Plan_Master__c subPlan = new Sub_Plan_Master__c();
                subPlan.Name = subPlanName;
                subPlan.Plan_Master__c = planId;
                insert subPlan;
                subPlanId = subPlan.Id;    
            }
            
            if(action == 'option1' || action == 'option3') {
                DELETE [SELECT Id FROM Template_Details__c WHERE Template__c = :templateName];
            }
            
            String source = 'Scratch';
            if(String.isNotBlank(commercialId)) {
                List<Commercial2__c> listCommercial = [SELECT Source__c FROM Commercial2__c WHERE Id = :commercialId];
                source = listCommercial[0].Source__c;
            }
            
            Pricing_Template__c template = new Pricing_Template__c();
            if(action == 'option1' || action == 'option3') template.Id = templateName;
            else if(action == 'option4' || action == 'option2' || action == 'option5') template.Name = templateName;
            template.Source__c = source;
            template.Public_Template__c = publicTemplateCheckbox;
            /* These lines are commented by Anas : to handle multiple fixed pricing records under the commercials
List<FixedPricing> listFixedPricing = (List<FixedPricing>)JSON.deserialize(listFixedPricingString,List<FixedPricing>.class);
for(FixedPricing fp : listFixedPricing) {
if(String.isNotBlank(fp.setupFee)) template.Setup_Fee__c = Decimal.valueOf(fp.setupFee);
else template.Setup_Fee__c = null;
if(String.isNotBlank(fp.securityDeposit)) template.Setup_Deposit__c = Decimal.valueOf(fp.securityDeposit);
else template.Setup_Deposit__c = null;
if(String.isNotBlank(fp.amcFee)) template.AMC_Fee__c = Decimal.valueOf(fp.amcFee);
else template.AMC_Fee__c = null;
if(String.isNotBlank(fp.amcInterval)) template.AMC_Interval__c = Decimal.valueOf(fp.amcInterval);
else template.AMC_Interval__c = null;
}
*/
            if(action == 'option1' || action == 'option3') update template;
            else if(action == 'option4' || action == 'option2' || action == 'option5') {
                template.Sub_Plan_Master__c = subPlanId;
                insert template;    
            }
            
            if(action != 'option1') {
                Template_Mapping__c templateMapping = new Template_Mapping__c();
                templateMapping.Plan__c = planId;
                templateMapping.Sub_Plan__c = subPlanId;
                templateMapping.Template__c = template.Id;
                insert templateMapping;
            }
            
            List<Template_Details__c> listTemplateDetailsToInsert = new List<Template_Details__c>(); 
            List<SelectedPaymentData> listSelectedPaymentData = (List<SelectedPaymentData>)JSON.deserialize(selectedListPaymentData,List<SelectedPaymentData>.class);
            for(SelectedPaymentData spd : listSelectedPaymentData) {
                for(SelectedPaymentOptions spo : spd.selectedPaymentOptionsList) {
                    for(SelectedPaymentDataSingleRecord spdsr : spo.selectedPaymentIndividualList) {
                        String identifier = spd.paymentModeId+'#'+spdsr.selectedPaymentOptionId+'#'+mapIdentifierToPricingSpecificationId.get(spdsr.selectedSpecification)+'#'+mapIdentifierToPaymentGatewayId.get(spdsr.selectedPaymentGatewayName).Id+'#'+spdsr.selectedOnusOffus;
                        if(mapIdentifierToMasterPricingDataId.containsKey(identifier)) {
                            Template_Details__c td = new Template_Details__c();
                            td.Template__c = template.Id;
                            td.Payment_Mode__c = spd.paymentModeId;
                            td.Payment_Option__c = spdsr.selectedPaymentOptionId;
                            td.Pricing_Specification__c = mapIdentifierToPricingSpecificationId.get(spdsr.selectedSpecification);
                            td.Payment_Gateway2__c = mapIdentifierToPaymentGatewayId.get(spdsr.selectedPaymentGatewayName).Id; 
                            td.ONUS_OFFUS__c = spdsr.selectedOnusOffus;
                            td.Fee_Model__c = spdsr.selectedFeeModel;
                            td.Transaction_Type__c = spdsr.selectedTransactionType;
                            td.Master_Pricing_Data__c = mapIdentifierToMasterPricingDataId.get(identifier).Id;
                            if(td.Transaction_Type__c == 'TDR') {
                                td.TDR_Amount__c = String.isNotBlank(spdsr.tdrAmount) ? Decimal.valueOf(spdsr.tdrAmount) : 0;
                                td.TDR_Flat_Fee__c = String.isNotBlank(spdsr.tdrFee) ? Decimal.valueOf(spdsr.tdrFee) : 0;
                                td.TDR__c = String.isNotBlank(spdsr.tdrPercentage) ? Decimal.valueOf(spdsr.tdrPercentage) : 0;
                            }
                            else if(td.Transaction_Type__c == 'Convenience') {
                                td.Convenience_Amount__c = String.isNotBlank(spdsr.convenienceAmount) ? Decimal.valueOf(spdsr.convenienceAmount) : 0;
                                td.Convenience_Flat_Fee__c = String.isNotBlank(spdsr.convenienceFee) ? Decimal.valueOf(spdsr.convenienceFee) : 0;
                                td.Convenience__c = String.isNotBlank(spdsr.conveniencePercentage) ? Decimal.valueOf(spdsr.conveniencePercentage) : 0;	    
                            }
                            else {
                                td.TDR_Amount__c = String.isNotBlank(spdsr.tdrAmount) ? Decimal.valueOf(spdsr.tdrAmount) : 0;
                                td.TDR_Flat_Fee__c = String.isNotBlank(spdsr.tdrFee) ? Decimal.valueOf(spdsr.tdrFee) : 0;
                                td.TDR__c = String.isNotBlank(spdsr.tdrPercentage) ? Decimal.valueOf(spdsr.tdrPercentage) : 0;
                                td.Convenience_Amount__c = String.isNotBlank(spdsr.convenienceAmount) ? Decimal.valueOf(spdsr.convenienceAmount) : 0;
                                td.Convenience_Flat_Fee__c = String.isNotBlank(spdsr.convenienceFee) ? Decimal.valueOf(spdsr.convenienceFee) : 0;
                                td.Convenience__c = String.isNotBlank(spdsr.conveniencePercentage) ? Decimal.valueOf(spdsr.conveniencePercentage) : 0;
                            }
                            listTemplateDetailsToInsert.add(td);
                        }
                    }
                }
            }
            if(listTemplateDetailsToInsert.size() > 0) {
                insert listTemplateDetailsToInsert;
            }
            
        }
        catch(Exception e) {
            Database.rollback(sp);
            message = e.getMessage();
        }
        return message;
    }
    
    @AuraEnabled/*(cacheable=true) ## Removed Cacheable = true as It is not getting real time data*/ 
    public static Boolean getPublicCheckboxForTemplate(String templateId) {
        return [SELECT Id,Public_Template__c FROM Pricing_Template__c WHERE Id = :templateId LIMIT 1][0].Public_Template__c;
    }
    
    
    /*
* Description       : This method is called on click of Live Commercial Tab
* Version.          : 1   
*/  
    @AuraEnabled
    public static LiveCommercialWrapper getNewAPILiveDetailsFromTreasury(String recordId) {
        LiveCommercialWrapper wrpCls = new LiveCommercialWrapper();
        try {
            String accessToken = PricingIntegrationUtility.getAccessToken('Get_Treasury_Api_For_Paas_Token');
            if(String.isNotBlank(accessToken)) {
                List<Opportunity> listOpportunity = [SELECT Prod_Merchant_Id__c FROM Opportunity WHERE Id = :recordId AND Prod_Merchant_Id__c != NULL];
                if(listOpportunity != NULL && listOpportunity.size() > 0) {
                    //String body = '{"clientId" : "1","entityId" : "'+listOpportunity[0].Prod_Merchant_Id__c+'"}';
                    String body = '{"clientId" : "1","entityId" : "2"}';
                    
                    Map<String,String> mapSFTreasuryTransformerToPayUPGId = new Map<String,String>();
                    String paymentScheme = '';
                    String cardType = '';
                    String key = '';
                    for(SF_Treasury_Transformer__c sfTrans : [SELECT SF_ID__c,Payment_Mode__c,Sub_Payment_Mode__c,Payment_Scheme__c,Payment_Entity__c,Card_Type__c,IsOnus__c FROM SF_Treasury_Transformer__c]) {
                        paymentScheme = String.isNotBlank(sfTrans.Payment_Scheme__c) ? sfTrans.Payment_Scheme__c.toUpperCase() : 'BLANK';
                        cardType = String.isNotBlank(sfTrans.Card_Type__c) ? sfTrans.Card_Type__c.toUpperCase() : 'BLANK';
                        key = sfTrans.Payment_Mode__c.toUpperCase()+'#'+sfTrans.Sub_Payment_Mode__c.toUpperCase()+'#'+paymentScheme+'#'+sfTrans.Payment_Entity__c+'#'+cardType+'#'+sfTrans.IsOnus__c;
                        mapSFTreasuryTransformerToPayUPGId.put(key,sfTrans.SF_ID__c);
                    }
                    
                    Map<String,Master_Pricing_Data__c> mapPayUPGIdToMasterPricingData = new Map<String,Master_Pricing_Data__c>();
                    for(Master_Pricing_Data__c mpd : [SELECT Salesforce_Primary_Key__c,Payment_Mode__c,Payment_Mode__r.Name,Payment_Option__c,Payment_Option__r.Name,Pricing_Specification__c,Pricing_Specification__r.Name,Payment_Gateway__c,Payment_Gateway__r.Name,ONUS_OFFUS__c FROM Master_Pricing_Data__c]) {
                        mapPayUPGIdToMasterPricingData.put(mpd.Salesforce_Primary_Key__c,mpd);		    
                    }
                    
                    HttpResponse response = PricingIntegrationUtility.doCallout('API_Callout_TreasuryPaas',accessToken,body,'Get API For Paas');
                    if(response.getStatus() == 'OK' && response.getStatusCode() == 200) {
                        Map<String,Object> mapKeyToValue = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                        if(mapKeyToValue != NULL && mapKeyToValue.keySet().size() > 0 && mapKeyToValue.containsKey('result')) {
                            List<Object> listPricingRecords = (List<Object>)mapKeyToValue.get('result');
                            if(listPricingRecords != NULL && listPricingRecords.size() > 0) {
                                Map<String,Object> mapKeyValuePricingRecord = new Map<String,Object>();
                                Map<String,Object> mapKeyValueAttributes = new Map<String,Object>();
                                Map<String,String> mapKeyValueAttributesString = new Map<String,String>();
                                String cardType1 = '';
                                String paymentScheme1 = '';
                                String onus = '';
                                String key1 = '';
                                List<SelectedPaymentData> listSelectedPaymentData = new List<SelectedPaymentData>();
                                Map<Id,SelectedPaymentData> mapPaymentModeIdToSelectedPaymentData = new Map<Id,SelectedPaymentData>();
                                for(Object obj : listPricingRecords) {
                                    mapKeyValuePricingRecord.clear();
                                    mapKeyValuePricingRecord = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                                    if(mapKeyValuePricingRecord.keySet().size() > 0 && mapKeyValuePricingRecord.containsKey('revenueModel') && ((String)mapKeyValuePricingRecord.get('revenueModel') == 'TDR' || (String)mapKeyValuePricingRecord.get('revenueModel') == 'Conv Fee')) {
                                        List<Object> listAttributes = new List<Object>();
                                        mapKeyValueAttributes.clear();
                                        mapKeyValueAttributesString.clear();
                                        if(mapKeyValuePricingRecord.containsKey('attributes')) {
                                            listAttributes.clear();
                                            listAttributes = (List<Object>)mapKeyValuePricingRecord.get('attributes');
                                            if(listAttributes.size() > 0) {
                                                for(Object obj1 : listAttributes) {
                                                    mapKeyValueAttributes = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj1));
                                                    if(mapKeyValueAttributes.containsKey('pricingRuleKey') && mapKeyValueAttributes.containsKey('pricingRuleValue')) {
                                                        mapKeyValueAttributesString.put((String)mapKeyValueAttributes.get('pricingRuleKey'),(String)mapKeyValueAttributes.get('pricingRuleValue'));    
                                                    }
                                                }
                                            }
                                        } 
                                        cardType1 = '';
                                        paymentScheme1 = '';
                                        onus = '';
                                        key1 = '';
                                        if(mapKeyValueAttributesString.containsKey('mode') && mapKeyValueAttributesString.containsKey('ibiboCode') && mapKeyValueAttributesString.containsKey('pgId')) {
                                            cardType1 = mapKeyValueAttributesString.containsKey('cardType') ? mapKeyValueAttributesString.get('cardType').toUpperCase() : 'BLANK';	
                                            paymentScheme1 = mapKeyValueAttributesString.containsKey('scheme') ? mapKeyValueAttributesString.get('scheme').toUpperCase() : 'BLANK';	
                                            onus = mapKeyValueAttributesString.containsKey('onus') ? '1' : '0';
                                            key1 = mapKeyValueAttributesString.get('mode').toUpperCase()+'#'+mapKeyValueAttributesString.get('ibiboCode').toUpperCase()+'#'+paymentScheme1+'#'+mapKeyValueAttributesString.get('pgId')+'#'+cardType+'#'+onus;
                                            if(mapSFTreasuryTransformerToPayUPGId.containsKey(key1)) {
                                                Master_Pricing_Data__c mpd = mapPayUPGIdToMasterPricingData.get(mapSFTreasuryTransformerToPayUPGId.get(key1)); 
                                                SelectedPaymentData spd = new SelectedPaymentData();
                                                if(mapPaymentModeIdToSelectedPaymentData.containsKey(mpd.Payment_Mode__c)) {
                                                    spd = mapPaymentModeIdToSelectedPaymentData.get(mpd.Payment_Mode__c);	    
                                                }	  
                                                spd.paymentModeId = mpd.Payment_Mode__c;
                                                spd.paymentModeName = mpd.Payment_Mode__r.Name;
                                                String key2 = mpd.Payment_Mode__c+'#'+mpd.Payment_Option__c+'#'+mpd.Pricing_Specification__c+'#'+mpd.Payment_Gateway__r.Name+'#'+mpd.ONUS_OFFUS__c;  
                                                //Create single record
                                                SelectedPaymentDataSingleRecord spdsr = new SelectedPaymentDataSingleRecord();
                                                if(String.valueOf(mapKeyValuePricingRecord.get('revenueModel')) == 'TDR') {
                                                    spdsr.tdrAmount = String.valueOf(mapKeyValuePricingRecord.get('amountSlab'));
                                                    spdsr.tdrFee = String.valueOf(mapKeyValuePricingRecord.get('flatFee'));
                                                    spdsr.tdrPercentage = String.valueOf(mapKeyValuePricingRecord.get('percentFee'));
                                                }
                                                else if(String.valueOf(mapKeyValuePricingRecord.get('revenueModel')) == 'Conv Fee') {
                                                    spdsr.convenienceAmount = String.valueOf(mapKeyValuePricingRecord.get('amountSlab'));
                                                    spdsr.convenienceFee = String.valueOf(mapKeyValuePricingRecord.get('flatFee'));
                                                    spdsr.conveniencePercentage = String.valueOf(mapKeyValuePricingRecord.get('percentFee'));
                                                }  
                                                spdsr.selectedPaymentOptionName = mpd.Payment_Option__r.Name;
                                                spdsr.selectedPaymentOptionId = mpd.Payment_Option__c;
                                                spdsr.selectedSpecification = mpd.Pricing_Specification__r.Name;
                                                spdsr.selectedPaymentGatewayName = mpd.Payment_Gateway__r.Name;
                                                spdsr.selectedOnusOffus = mpd.ONUS_OFFUS__c;
                                                SelectedPaymentOptions spo = new SelectedPaymentOptions();
                                                spo.key = key2;
                                                spo.selectedPaymentIndividualList.add(spdsr);
                                                spd.selectedPaymentOptionsList.add(spo);
                                                mapPaymentModeIdToSelectedPaymentData.put(mpd.Payment_Mode__c,spd);
                                            }
                                            else {
                                                UntransformedData ud = new UntransformedData();
                                                ud.debitModel = String.valueOf(mapKeyValuePricingRecord.get('debitModel'));
                                                ud.type = String.valueOf(mapKeyValuePricingRecord.get('revenueModel'));
                                                ud.paymentMode = String.valueOf(mapKeyValueAttributesString.get('mode'));
                                                ud.subPaymentMode = String.valueOf(mapKeyValueAttributesString.get('ibiboCode'));
                                                ud.paymentScheme = mapKeyValueAttributesString.containsKey('scheme') ? String.valueOf(mapKeyValueAttributesString.get('scheme')) : '';
                                                ud.paymentEntity = String.valueOf(mapKeyValueAttributesString.get('pgId'));
                                                ud.cardType = mapKeyValueAttributesString.containsKey('cardType') ? String.valueOf(mapKeyValueAttributesString.get('cardType')) : '';
                                                ud.isOnus = mapKeyValueAttributesString.containsKey('onus') ? '1' : '0';
                                                ud.moreThanAmount = String.valueOf(mapKeyValuePricingRecord.get('amountSlab'));
                                                ud.flatFee = String.valueOf(mapKeyValuePricingRecord.get('flatFee'));
                                                ud.percentageFee = String.valueOf(mapKeyValuePricingRecord.get('percentFee'));
                                                wrpCls.listUntransformedData.add(ud);
                                            }
                                        }
                                        else {
                                            UntransformedData ud = new UntransformedData();
                                            ud.debitModel = String.valueOf(mapKeyValuePricingRecord.get('debitModel'));
                                            ud.type = String.valueOf(mapKeyValuePricingRecord.get('revenueModel'));
                                            ud.paymentMode = mapKeyValueAttributesString.containsKey('mode') ? String.valueOf(mapKeyValueAttributesString.get('mode')) : '';
                                            ud.subPaymentMode = mapKeyValueAttributesString.containsKey('ibiboCode') ? String.valueOf(mapKeyValueAttributesString.get('ibiboCode')) : '';
                                            ud.paymentScheme = mapKeyValueAttributesString.containsKey('scheme') ? String.valueOf(mapKeyValueAttributesString.get('scheme')) : '';
                                            ud.paymentEntity = mapKeyValueAttributesString.containsKey('pgId') ? String.valueOf(mapKeyValueAttributesString.get('pgId')) : '';
                                            ud.cardType = mapKeyValueAttributesString.containsKey('cardType') ? String.valueOf(mapKeyValueAttributesString.get('cardType')) : '';
                                            ud.isOnus = mapKeyValueAttributesString.containsKey('onus') ? '1' : '0';
                                            ud.moreThanAmount = String.valueOf(mapKeyValuePricingRecord.get('amountSlab'));
                                            ud.flatFee = String.valueOf(mapKeyValuePricingRecord.get('flatFee'));
                                            ud.percentageFee = String.valueOf(mapKeyValuePricingRecord.get('percentFee'));
                                            wrpCls.listUntransformedData.add(ud); 
                                        }
                                    }
                                }
                                if(mapPaymentModeIdToSelectedPaymentData.keySet().size() > 0) {
                                    for(SelectedPaymentData spd : mapPaymentModeIdToSelectedPaymentData.values()) {
                                        listSelectedPaymentData.add(spd);    
                                    }
                                }
                                wrpCls.selectedListPaymentDataLiveFromTreasury = JSON.serialize(listSelectedPaymentData);
                            }
                        } 	    
                    }
                    else {
                        wrpCls.message = String.valueOf(response);    
                    }                    
                }
                else {
                    wrpCls.message = 'Merchant Id is not available on the merchant';    
                } 	    
            }	
            else {
                wrpCls.message = 'Error in Authentication';    
            }
        }
        catch(Exception e) {
            wrpCls.message = e.getMessage();
        }
        return wrpCls;
    }
    
    /*
* Description       : This method is called on click of Live Commercial Tab
* Version.          : 1   
*/   
    @AuraEnabled
    public static LiveCommercialWrapper getLiveDetailsFromTreasury(String recordId) {
        LiveCommercialWrapper wrpCls = new LiveCommercialWrapper();
        try {
            String accessToken = PricingIntegrationUtility.getAccessToken('Get_Access_Token_Fetch');
            if(String.isNotBlank(accessToken)) {
                List<Opportunity> listOpportunity = [SELECT Prod_Merchant_Id__c FROM Opportunity WHERE Id = :recordId AND Prod_Merchant_Id__c != NULL];
                if(listOpportunity != NULL && listOpportunity.size() > 0) {
                    String body = '{"clientId" : "1","merchantId" : "'+listOpportunity[0].Prod_Merchant_Id__c+'"}';
                    //String body = '{"clientId" : "1","merchantId" : "22704"}'; 
                    //String body = '{"clientId" : "1","merchantId" : "7200612"}';
                    HttpResponse response = PricingIntegrationUtility.doCallout('API_Callout_Fetch',accessToken,body,'FetchAPI');
                    if(response.getStatus() == 'OK' && response.getStatusCode() == 200) {
                        Map<String,Object> mapKeyToValue = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                        if(mapKeyToValue != NULL && mapKeyToValue.keySet().size() > 0 && mapKeyToValue.containsKey('result')) {
                            Map<String,Map<String,Object>> mapRuleIdToObject = new Map<String,Map<String,Object>>();
                            List<Object> listPricingRecords = (List<Object>)mapKeyToValue.get('result');
                            if(listPricingRecords != NULL && listPricingRecords.size() > 0) {
                                for(Object obj : listPricingRecords) {
                                    String jsonString = JSON.serialize(obj);
                                    Map<String,Object> mapRecordValues = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
                                    mapRuleIdToObject.put(String.valueOf(mapRecordValues.get('ruleId')),mapRecordValues);
                                }
                                if(mapRuleIdToObject.keySet().size() > 0) {
                                    Set<String> setTransformedRuleIds = new Set<String>();
                                    Set<String> setAllRuleIds = mapRuleIdToObject.keySet(); 
                                    List<SelectedPaymentData> listSelectedPaymentData = new List<SelectedPaymentData>();
                                    Map<Id,SelectedPaymentData> mapPaymentModeIdToSelectedPaymentData = new Map<Id,SelectedPaymentData>();
                                    for(Pricing__c pricing : [SELECT Id,Rule_Id__c,Rule_Id_Conv__c,Payment_Mode__c,Payment_Mode_Text__c,Payment_Option2__c,Payment_Option_Text__c,
                                                              Specifcation__c,Payment_Gateway_Text__c,ONUS__c,Fee_Model__c,Transaction_Type__c,TDR_Amount__c,
                                                              TDR_Flat_Fee__c,TDR__c,Convenience_Amount__c,Convenience_Flat_Fee__c,Convenience__c,
                                                              Banking_Ops_Status__c,Below_Rack_Rates__c,Payment_Gateway2__r.Type__c,Bank_Name__c,POR_Type_Name__c 
                                                              FROM Pricing__c 
                                                              WHERE Opportunity__c = :recordId 
                                                              AND Deleted__c = false
                                                              AND Invisible__c = false
                                                              AND (Rule_Id__c IN :mapRuleIdToObject.keySet() 
                                                                   OR Rule_Id_Conv__c IN :mapRuleIdToObject.keySet())]) {
                                                                       SelectedPaymentData spd = new SelectedPaymentData();
                                                                       if(mapPaymentModeIdToSelectedPaymentData.containsKey(pricing.Payment_Mode__c)) {
                                                                           spd = mapPaymentModeIdToSelectedPaymentData.get(pricing.Payment_Mode__c);	    
                                                                       }	  
                                                                       spd.paymentModeId = pricing.Payment_Mode__c;
                                                                       spd.paymentModeName = pricing.Payment_Mode_Text__c;
                                                                       String key = pricing.Payment_Mode__c+'#'+pricing.Payment_Option2__c+'#'+pricing.Specifcation__c+'#'+pricing.Payment_Gateway_Text__c+'#'+pricing.ONUS__c;  
                                                                       //Create single record
                                                                       SelectedPaymentDataSingleRecord spdsr = new SelectedPaymentDataSingleRecord();
                                                                       if(pricing.Transaction_Type__c == 'TDR' && String.isNotBlank(pricing.Rule_Id__c) && mapRuleIdToObject.containsKey(pricing.Rule_Id__c)) {
                                                                           spdsr.key = pricing.Rule_Id__c;
                                                                           setTransformedRuleIds.add(pricing.Rule_Id__c);
                                                                           Map<String,Object> mapRecordValues = mapRuleIdToObject.get(pricing.Rule_Id__c);
                                                                           spdsr.tdrAmount = String.valueOf(mapRecordValues.get('moreThanAmount'));
                                                                           spdsr.tdrFee = String.valueOf(mapRecordValues.get('flatFee'));
                                                                           spdsr.tdrPercentage = String.valueOf(mapRecordValues.get('percentageFee'));
                                                                       }
                                                                       else if(pricing.Transaction_Type__c == 'Convenience' && String.isNotBlank(pricing.Rule_Id_Conv__c) && mapRuleIdToObject.containsKey(pricing.Rule_Id_Conv__c)) {
                                                                           spdsr.key = pricing.Rule_Id_Conv__c; 
                                                                           setTransformedRuleIds.add(pricing.Rule_Id_Conv__c);
                                                                           Map<String,Object> mapRecordValues = mapRuleIdToObject.get(pricing.Rule_Id_Conv__c);
                                                                           spdsr.convenienceAmount  = String.valueOf(mapRecordValues.get('moreThanAmount'));
                                                                           spdsr.convenienceFee  = String.valueOf(mapRecordValues.get('flatFee'));
                                                                           spdsr.conveniencePercentage  = String.valueOf(mapRecordValues.get('percentageFee'));
                                                                       }  
                                                                       else if(pricing.Transaction_Type__c == 'TDR + Convenience') {
                                                                           if(String.isNotBlank(pricing.Rule_Id__c) && mapRuleIdToObject.containsKey(pricing.Rule_Id__c)) {
                                                                               spdsr.key = pricing.Rule_Id__c;
                                                                               setTransformedRuleIds.add(pricing.Rule_Id__c);
                                                                               Map<String,Object> mapRecordValues = mapRuleIdToObject.get(pricing.Rule_Id__c);
                                                                               spdsr.tdrAmount = String.valueOf(mapRecordValues.get('moreThanAmount'));
                                                                               spdsr.tdrFee = String.valueOf(mapRecordValues.get('flatFee'));
                                                                               spdsr.tdrPercentage = String.valueOf(mapRecordValues.get('percentageFee'));    
                                                                           }
                                                                           if(String.isNotBlank(pricing.Rule_Id_Conv__c) && mapRuleIdToObject.containsKey(pricing.Rule_Id_Conv__c)) {
                                                                               spdsr.key = pricing.Rule_Id_Conv__c; 
                                                                               setTransformedRuleIds.add(pricing.Rule_Id_Conv__c);
                                                                               Map<String,Object> mapRecordValues = mapRuleIdToObject.get(pricing.Rule_Id_Conv__c);
                                                                               spdsr.convenienceAmount  = String.valueOf(mapRecordValues.get('moreThanAmount'));
                                                                               spdsr.convenienceFee  = String.valueOf(mapRecordValues.get('flatFee'));
                                                                               spdsr.conveniencePercentage  = String.valueOf(mapRecordValues.get('percentageFee'));    
                                                                           }
                                                                       }
                                                                       
                                                                       spdsr.selectedPaymentOptionName = pricing.Payment_Option_Text__c;
                                                                       spdsr.selectedPaymentOptionId = pricing.Payment_Option2__c;
                                                                       spdsr.selectedSpecification = pricing.Specifcation__c;
                                                                       spdsr.selectedPaymentGatewayName = pricing.Payment_Gateway_Text__c;
                                                                       spdsr.selectedOnusOffus = pricing.ONUS__c;
                                                                       SelectedPaymentOptions spo = new SelectedPaymentOptions();
                                                                       spo.key = key;
                                                                       spo.selectedPaymentIndividualList.add(spdsr);
                                                                       spd.selectedPaymentOptionsList.add(spo);
                                                                       mapPaymentModeIdToSelectedPaymentData.put(pricing.Payment_Mode__c,spd);	    
                                                                   }
                                    if(mapPaymentModeIdToSelectedPaymentData.keySet().size() > 0) {
                                        for(SelectedPaymentData spd : mapPaymentModeIdToSelectedPaymentData.values()) {
                                            listSelectedPaymentData.add(spd);    
                                        }
                                    }
                                    wrpCls.selectedListPaymentDataLiveFromTreasury = JSON.serialize(listSelectedPaymentData);
                                    
                                    setAllRuleIds.removeAll(setTransformedRuleIds);
                                    if(setAllRuleIds.size() > 0) {
                                        Integer count = 0;
                                        for(String untransformedRuleId : setAllRuleIds) {
                                            UntransformedData ud = new UntransformedData();
                                            ud.ruleId = untransformedRuleId;
                                            Map<String,Object> mapRecordValues = mapRuleIdToObject.get(untransformedRuleId);
                                            ud.debitModel = String.valueOf(mapRecordValues.get('debitModel'));
                                            ud.type = String.valueOf(mapRecordValues.get('type'));
                                            ud.paymentMode = String.valueOf(mapRecordValues.get('paymentMode'));
                                            ud.subPaymentMode = String.valueOf(mapRecordValues.get('subPaymentMode'));
                                            ud.paymentScheme = String.valueOf(mapRecordValues.get('paymentScheme'));
                                            ud.paymentEntity = String.valueOf(mapRecordValues.get('paymentEntity'));
                                            ud.cardType = String.valueOf(mapRecordValues.get('cardType'));
                                            ud.isOnus = String.valueOf(mapRecordValues.get('isOnus'));
                                            ud.moreThanAmount = String.valueOf(mapRecordValues.get('moreThanAmount'));
                                            ud.flatFee = String.valueOf(mapRecordValues.get('flatFee'));
                                            ud.percentageFee = String.valueOf(mapRecordValues.get('percentageFee'));
                                            wrpCls.listUntransformedData.add(ud);    
                                        }
                                    }
                                }
                            }
                            else {
                                wrpCls.message = 'No Pricing records found';    
                            }
                        }
                        else {
                            wrpCls.message = 'Pricing records are not available in the response';      
                        }
                    }
                    else {
                        wrpCls.message = String.valueOf(response);    
                    }                    
                }
                else {
                    wrpCls.message = 'Merchant Id is not available on the merchant';    
                } 	    
            }	
            else {
                wrpCls.message = 'Error in Authentication';    
            }
        }
        catch(Exception e) {
            wrpCls.message = e.getMessage();
        }
        return wrpCls;
    }
    
    public class LiveCommercialWrapper {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public String selectedListPaymentDataLiveFromTreasury = '';
        @AuraEnabled public List<UntransformedData> listUntransformedData = new List<UntransformedData>();
    }
    
    public class UntransformedData {
        @AuraEnabled public String debitModel = '';
        @AuraEnabled public String type = '';
        @AuraEnabled public String paymentMode = '';
        @AuraEnabled public String subPaymentMode = '';
        @AuraEnabled public String paymentScheme = '';
        @AuraEnabled public String paymentEntity = '';
        @AuraEnabled public String cardType = '';
        @AuraEnabled public String isOnus = '';
        @AuraEnabled public String moreThanAmount = '';
        @AuraEnabled public String flatFee = '';
        @AuraEnabled public String percentageFee = '';
        @AuraEnabled public String ruleId = '';
    }
    
    
    /*
* Description       : This method is called on change of Sub Plan for Super User : Option 1, Update Existing template
* Version.          : 1   
*/
    @AuraEnabled/*(cacheable=true) ## To get the real time data*/
    public static WrapperClassOnLoad getPrivateTemplateDetailsForPlanAndSubPlan(String planId,String subPlanId) {
        WrapperClassOnLoad wrpCls = new WrapperClassOnLoad();
        try{
            Set<Id> setTemplateId = new Set<Id>();
            wrpCls.jsonPlanMaster = '[';
            for(Template_Mapping__c pm : [SELECT Template__c,Template__r.Name FROM Template_Mapping__c 
                                          WHERE Template__c != NULL 
                                          AND Plan__c = :planId
                                          AND Sub_Plan__c = :subPlanId
                                          AND Template__r.CreatedById = :UserInfo.getUserId() LIMIT 50000]) {
                                              if(!setTemplateId.contains(pm.Template__c)) {
                                                  wrpCls.jsonPlanMaster += '{"label":"'+pm.Template__r.Name+'","value":"'+pm.Template__c+'"},'; 
                                                  setTemplateId.add(pm.Template__c);  
                                              } 
                                          } 
            wrpCls.jsonPlanMaster = wrpCls.jsonPlanMaster.removeEnd(',');
            wrpCls.jsonPlanMaster += ']';
        }
        catch(exception e) {
            wrpCls.message = e.getMessage();   
        }
        return wrpCls;    
    }
    
    /*
* Description       : This method is called on click of Publish Commercial button from the PublishPricingComponent
* Version.          : 1   
*/
    
    @AuraEnabled
    public static WrapperClassPublishComponent getModalInformation(String commercialId) {
        WrapperClassPublishComponent wrpCls = new WrapperClassPublishComponent();
        try {
            List<Commercial2__c> listCommercial2 = [SELECT Name,Opportunity__c FROM Commercial2__c WHERE Id = :commercialId];
            List<Commercial2__c> listCommercial = [SELECT Id,Name FROM Commercial2__c WHERE Opportunity__c = :listCommercial2[0].Opportunity__c AND Status__c = 'Live'];
            if(listCommercial != NULL && listCommercial.size() > 0) {
                if(listCommercial[0].Id != commercialId) {
                    wrpCls.showModal = true;
                    wrpCls.oldLiveCommercialName = listCommercial[0].Name;
                    wrpCls.newLiveCommercialName = listCommercial2[0].Name;
                }
            }
        }
        catch(exception e) {
            wrpCls.message = e.getMessage();
        }
        return wrpCls;
    }
    
    public class WrapperClassPublishComponent {
        @AuraEnabled public String message = 'SUCCESS';
        @AuraEnabled public Boolean showModal = false;
        @AuraEnabled public String newLiveCommercialName = '';
        @AuraEnabled public String oldLiveCommercialName = '';
    }
    
    
    @AuraEnabled
    public static List<PricingHistory> getAuditTrailRecordsForCommercial(String commercialId) {
        List<PricingHistory> listPricingHistory = new List<PricingHistory>();
        for(Pricing__History phObj : [SELECT Id,Parent.Name,Field,OldValue,NewValue,CreatedBy.Name,CreatedDate,ParentId 
                                      FROM Pricing__History 
                                      WHERE Parent.Commercial2__c = :commercialId 
                                      AND Field IN ('created','TDR__c','TDR_Amount__c','TDR_Flat_Fee__c','Convenience__c','Convenience_Amount__c','Convenience_Flat_Fee__c','Fee_Model__c')
                                      ORDER BY ParentId,CreatedDate]) {
                                          PricingHistory ph = new PricingHistory();
                                          ph.Id = phObj.ParentId;
                                          ph.pricingName = phObj.Parent.Name;
                                          ph.field = phObj.Field; 
                                          ph.oldValue = String.valueOf(phObj.OldValue);
                                          ph.newValue = String.valueOf(phObj.NewValue);
                                          ph.createdBy = phObj.CreatedBy.Name;
                                          ph.createdDate = phObj.CreatedDate.format();
                                          if(phObj.Field == 'created') {
                                              ph.backgroundColor = 'background-color:#FFE3DD;';
                                              ph.showLink = true;
                                          }
                                          listPricingHistory.add(ph);
                                      }
        return listPricingHistory;
    }
    
    public class PricingHistory {
        @AuraEnabled public String Id = '';
        @AuraEnabled public String pricingName = '';
        @AuraEnabled public String field = '';
        @AuraEnabled public String oldValue = '';
        @AuraEnabled public String newValue = '';
        @AuraEnabled public String createdBy = '';
        @AuraEnabled public String createdDate = '';
        @AuraEnabled public String backgroundColor = 'background-color:white;';
        @AuraEnabled public Boolean showLink = false;
    }
    @AuraEnabled(cacheable=true)
    public static PricingWrapperDialog getPricingData(String pricingId) {
        PricingWrapperDialog pricingWrapper = new PricingWrapperDialog();
        for(Pricing__c price : [SELECT Payment_Mode__r.Name,Payment_Option2__r.Name,Pricing_Specification__r.Name,
                                Payment_Gateway2__r.Name,ONUS__C,Transaction_Type__c,Fee_Model__c 
                                FROM Pricing__c WHERE Id =:pricingId AND Invisible__c = false]) {
                                    pricingWrapper.paymentModeName = price.Payment_Mode__r.Name;    
                                    pricingWrapper.paymentOptionName = price.Payment_Option2__r.Name; 
                                    pricingWrapper.paymentSpecficationName = price.Pricing_Specification__r.Name; 
                                    pricingWrapper.paymentGatewayName = price.Payment_Gateway2__r.Name; 
                                    pricingWrapper.onusOffus = price.ONUS__C; 
                                    pricingWrapper.transactionType = price.Transaction_Type__c; 
                                    pricingWrapper.feeModel = price.Fee_Model__c; 
                                }
        return pricingWrapper;
    }
    
    public class PricingWrapperDialog {
        @AuraEnabled public String paymentModeName = '';
        @AuraEnabled public String paymentOptionName = '';
        @AuraEnabled public String paymentSpecficationName = '';
        @AuraEnabled public String paymentGatewayName = '';
        @AuraEnabled public String onusOffus = '';
        @AuraEnabled public String transactionType = '';
        @AuraEnabled public String feeModel = '';
    }
    
    @AuraEnabled 
    public static List<PricingHistory> getOverallAuditTrail(String opportunityId) {
        List<PricingHistory> listCommercialHistory = new List<PricingHistory>();
        Map<String,String> mapFieldApiNameToLabel = new Map<String,String>();
        Map<String,Schema.SObjectField> commercialfields = Schema.Commercial2__c.SObjectType.getDescribe().fields.getMap();
        for(Schema.SObjectField apiName : commercialfields.values()) {
            Schema.DescribeFieldResult fieldResult = commercialfields.get(String.valueOf(apiName)).getDescribe(); 
            mapFieldApiNameToLabel.put(String.valueOf(apiName),String.valueOf(fieldResult.getLabel()));
        }
        
        for(Commercial2__History ch : [SELECT Id,Parent.Name,Field,OldValue,NewValue,CreatedBy.Name,CreatedDate 
                                       FROM Commercial2__History 
                                       WHERE Parent.Opportunity__c= :opportunityId
                                       AND Field IN ('created','Status__c','Last_Edited_On__c','Last_Published_On__c') 
                                       ORDER BY CreatedDate DESC]) {
                                           PricingHistory ph = new PricingHistory();
                                           ph.Id = ch.Id;
                                           ph.pricingName = ch.Parent.Name;
                                           if(mapFieldApiNameToLabel.containsKey(ch.Field)) {
                                               ph.field = mapFieldApiNameToLabel.get(ch.Field);    
                                           }
                                           else {
                                               ph.field = ch.Field;    
                                           }
                                           
                                           if(ch.Field == 'created' || ch.Field == 'Status__c') {
                                               ph.oldValue = String.valueOf(ch.OldValue);
                                               ph.newValue = String.valueOf(ch.NewValue);    
                                           }
                                           else {
                                               if(ch.OldValue != NULL) ph.oldValue = Datetime.valueOf(ch.OldValue).format();
                                               if(ch.NewValue != NULL) ph.newValue = DateTime.valueOf(ch.NewValue).format();      
                                           }
                                           ph.createdBy = ch.CreatedBy.Name;
                                           ph.createdDate = ch.CreatedDate.format();
                                           listCommercialHistory.add(ph);    
                                       }
        return listCommercialHistory;
    }
    public class OtherPricingHistory {
        @AuraEnabled public String Id = '';
        @AuraEnabled public Decimal amountSlab;
        @AuraEnabled public String revenueModelName = '';
        @AuraEnabled public String field = '';
        @AuraEnabled public String oldValue = '';
        @AuraEnabled public String newValue = '';
        @AuraEnabled public String createdBy = '';
        @AuraEnabled public String createdDate = '';
        @AuraEnabled public String backgroundColor = 'background-color:white;';
        @AuraEnabled public Boolean showLink = false;
    }
    /*
* Description       : This method is to get the History of other pricing record for a particular Merchant
* Version.          : 1 
* Created By 		: Rohit Gupta
*/
    @AuraEnabled 
    public static List<OtherPricingHistory> getOverallAuditForStackTrail(String opportunityId) {
        List<OtherPricingHistory> listOtherCommercialHistory = new List<OtherPricingHistory>();
        Map<String,String> mapFieldApiNameToLabel = new Map<String,String>();
        Map<String,Schema.SObjectField> otherCommercialfields = Schema.Other_Product_Pricing__c.SObjectType.getDescribe().fields.getMap();
        for(Schema.SObjectField apiName : otherCommercialfields.values()) {
            Schema.DescribeFieldResult fieldResult = otherCommercialfields.get(String.valueOf(apiName)).getDescribe(); 
            mapFieldApiNameToLabel.put(String.valueOf(apiName),String.valueOf(fieldResult.getLabel()));
        }
        for(Other_Product_Pricing__History ch : [SELECT Id,Parent.Name,Parent.Last_Edited_On__c,Parent.Amount_Slab__c,Parent.Revenue_Model__c,Parent.Last_Published_On__c,Field,OldValue,NewValue,CreatedBy.Name,CreatedDate 
                                                 FROM Other_Product_Pricing__History 
                                                 WHERE Parent.Opportunity__c= :opportunityId
                                                 AND Field IN ('created','Flat_Fee__c','Valid_From__c','Last_Edited_On__c','Last_Published_On__c','Valid_From_Time__c','Valid_Till__c','Valid_Till_Time__c','Percent_Fee__c','Need_to_Publish__c','Amount_Slab__c','Days_of_the_week__c') 
                                                 ORDER BY CreatedDate DESC]) {
                                                     OtherPricingHistory ph = new OtherPricingHistory();
                                                     ph.Id = ch.Id;
                                                     ph.amountSlab = ch.Parent.Amount_Slab__c;
                                                     ph.revenueModelName =  String.valueOf(ch.Parent.Revenue_Model__c); 
                                                     if(mapFieldApiNameToLabel.containsKey(ch.Field)) {
                                                         ph.field = mapFieldApiNameToLabel.get(ch.Field);    
                                                     }
                                                     else {
                                                         ph.field = ch.Field;    
                                                     }
                                                     
                                                     if(ch.Field == 'created') {
                                                         ph.oldValue = String.valueOf(ch.OldValue);
                                                         ph.newValue = String.valueOf(ch.NewValue);    
                                                     }
                                                     else {
                                                         if(ch.OldValue != NULL) ph.oldValue =String.valueOf(ch.OldValue);// Datetime.valueOf(ch.OldValue).format();
                                                         if(ch.NewValue != NULL) ph.newValue =String.valueOf(ch.NewValue);// DateTime.valueOf(ch.NewValue).format();      
                                                     }
                                                     ph.createdBy = ch.CreatedBy.Name;
                                                     ph.createdDate = ch.CreatedDate.format();
                                                     listOtherCommercialHistory.add(ph); 
                                                 }
        return listOtherCommercialHistory;
    }
    
    /*
* Description       : This method is called internally to get the List of Pricing  records for a particular Commercial
* Version.          : 1   
*/
    public static PageReference getPricingRecordForParticularComm() {
        commercialId = ApexPages.currentPage().getParameters().get('id');
        List<Pricing__c> pricingList = [SELECT Id,Payment_Option2__r.Name,Opportunity__r.Prod_MID__c ,Opportunity__r.Merchant_Name__c ,Commercial2__r.Name,Opportunity__r.Owner.Name, Opportunity__r.Merchant_Business_Type__c , Pricing_Specification__r.Name,Payment_Gateway2__r.Name,
                                        Payment_Mode__r.Name,ONUS__c,TDR_Amount__c,TDR_Flat_Fee__c,Flat_Percentage__c ,TDR__c,Convenience_Amount__c,
                                        Convenience_Flat_Fee__c,Convenience__c ,Type__c FROM Pricing__c WHERE Commercial2__c=:commercialId AND Invisible__c = false];
        
        
        if(pricingList !=NULL){
            listPricingRecords = pricingList;
        }
        return null;
    }
    
    /** Added for SFI-1640 */
    @AuraEnabled
    public static String getFixedPricing(String listFixedPricing2){
        try {
            
            List<FixedPricing2> newListToReturn = new List<FixedPricing2>();
            if(String.isNotBlank(listFixedPricing2)){
                List<FixedPricing2> listFixedPricing2New = (List<FixedPricing2>)JSON.deserialize(listFixedPricing2, List<FixedPricing2>.class);
                
                Set<String> setInsertedFeeType = new Set<String>();
                for(FixedPricing2 fp1 : listFixedPricing2New) {
                    System.debug('>>>>>>fp1>>>>>>'+fp1);
                    FixedPricing2 fpNew = new FixedPricing2();
                    fpNew.recordId = fp1.recordId;
                    fpNew.endDate = fp1.endDate;
                    fpNew.startDate = fp1.startDate;
                    fpNew.amount = fp1.amount;
                    fpNew.flatFee = fp1.flatFee;
                    fpNew.percentage = fp1.percentage;
                    fpNew.flatFeeType = fp1.flatFeeType;
                    fpNew.paymentFrequency = fp1.paymentFrequency;
                    fpNew.debitModel = fp1.debitModel;
                    fpNew.showDeleteButton = fp1.showDeleteButton;
                    newListToReturn.add(fpNew);    
                    setInsertedFeeType.add(fp1.flatFeeType);
                }
                
                for(String feeType : setFlatFeeType) {
                    if(!setInsertedFeeType.contains(feeType)) {
                        FixedPricing2 fp = new FixedPricing2();
                        fp.flatFeeType = feeType;
                        newListToReturn.add(fp);    
                    }
                }
            }else{
                for(String feeType : setFlatFeeType) {
                    FixedPricing2 fp = new FixedPricing2();
                    fp.flatFeeType = feeType;
                    newListToReturn.add(fp);    
                    
                }
            }
            System.debug('>>>>>>newListToReturn>>>>>'+newListToReturn);
            return JSON.serialize(newListToReturn);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
}