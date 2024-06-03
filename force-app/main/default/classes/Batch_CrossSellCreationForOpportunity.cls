/* Created By:- Akash Pandey.
* Created Date:- 25/08/2020.
* JiRa Ticket Id :- https://payuindia.atlassian.net/browse/SFPI-820
* */

public class Batch_CrossSellCreationForOpportunity implements Database.Batchable<sObject> {
    public Batch_Setting__mdt batchSetting = new Batch_Setting__mdt();
    public List<CrossSell_Creation_crit__mdt> crossSellCreationMetadataList = New List<CrossSell_Creation_crit__mdt>();
    public Map<string,CrossSell_Risk_Zone_Assignment__mdt> zoneAssignmentMCPMap = New Map<string,CrossSell_Risk_Zone_Assignment__mdt>();
    public Map<string,CrossSell_Risk_Zone_Assignment__mdt> zoneAssignmentEMIMap = New Map<string,CrossSell_Risk_Zone_Assignment__mdt>();
    
    public Boolean isTriggerExecute {get;set;}
    public Opportunity oppObj {get;set;}
    
    
    public Batch_CrossSellCreationForOpportunity(Boolean isTrigger, Opportunity eachOppObj){
        isTriggerExecute = isTrigger;
        oppObj = eachOppObj;
        
        batchSetting = [SELECT MasterLabel,Fields_To_Query__c,Cross_Sell_Creation_Criteria__c , Iteration_Count__c, Record_Limit__c,Active__c, Where_Clause__c 
                        FROM Batch_Setting__mdt WHERE MasterLabel = 'CrossSellCreationForOpportunity' AND Active__c = true LIMIT 1];
        
        crossSellCreationMetadataList = [SELECT Active__c  ,Creation_Criteria__c   ,Product_Name__c, ProductNameVsIdMap__c ,ProductVsRecordTypeMap__c  FROM CrossSell_Creation_crit__mdt ];
        
        for(CrossSell_Risk_Zone_Assignment__mdt assMDT : [Select Id,Business_Category__c,Product_Name__c,Sub_Category_Vs_Risk_Zone__c, MCC_Code__c
                                                          from CrossSell_Risk_Zone_Assignment__mdt]){
                                                              If(String.isNotBlank(assMDT.Business_Category__c) && assMDT.Product_Name__c == 'MCP'){
                                                                  zoneAssignmentMCPMap.put(assMDT.Business_Category__c,assMDT);
                                                              }
                                                              If(String.isNotBlank(assMDT.Business_Category__c) && assMDT.Product_Name__c == 'EMI'){
                                                                  zoneAssignmentEMIMap.put(assMDT.Business_Category__c,assMDT);
                                                              }
                                                          }
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(isTriggerExecute && oppObj != null){
            String oppId = oppObj.Id;
            String strQuery = batchSetting.Fields_To_Query__c+ ' FROM Opportunity Where Id=:oppId' ;
            return Database.getQueryLocator(strQuery);
        }else{
            String strQuery = batchSetting.Fields_To_Query__c+ ' FROM Opportunity ' ;
            strQuery += String.isNotBlank(batchSetting.Where_Clause__c) ?  batchSetting.Where_Clause__c : '';
            return Database.getQueryLocator(strQuery);
        }
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity> opList){
        List<Cross_Sell__c> csObjListToInsert = New List<Cross_Sell__c>();
        List<Cross_Sell__c> csObjListToUpdate = New List<Cross_Sell__c>();
        
        if(opList.size()>0){
            for(Opportunity eachOpp: opList){
                Set<String> productNameSet = new Set<String>();
                Map<String,Cross_Sell__c> csObjMap = New Map<String,Cross_Sell__c>();
                Boolean zoneCriteria = true;
                
                for(Cross_Sell__c cs: eachOpp.Cross_Sells__r){
                    productNameSet.add(cs.Custom_Product__r.Name);
                    csObjMap.put(cs.Custom_Product__r.Name,cs);
                }
                System.debug('@@@@@@@ productNameSet '+productNameSet);
                if(crossSellCreationMetadataList.size()>0){
                    for(CrossSell_Creation_crit__mdt mtd: crossSellCreationMetadataList){
                        if(productNameSet.isEmpty() || !productNameSet.contains(mtd.Product_Name__c)){
                            
                            Cross_Sell__c csObj = new Cross_Sell__c();
                            csObj = createCSObject(eachOpp,mtd);
                            if(mtd.Product_Name__c == 'T+0'){
                                csObj = getISCrossSellZone(csObj,eachOpp,mtd,zoneCriteria);
                            }
                            if(mtd.Product_Name__c == 'MCP'){
                                csObj = getMCPCrossSellZone(csObj,eachOpp,mtd,zoneAssignmentMCPMap);
                            }
                            if(mtd.Product_Name__c == 'EMI'){
                                csObj = getEMICrossSellZone(csObj,eachOpp,mtd,zoneAssignmentEMIMap);
                            }
                            csObjListToInsert.add(csObj);
                        }else if(productNameSet.contains(mtd.Product_Name__c) && csObjMap.containsKey(mtd.Product_Name__c)){
                            if(mtd.Product_Name__c == 'T+0' || mtd.Product_Name__c == 'MCP' || mtd.Product_Name__c == 'EMI'){
                                Cross_Sell__c csObjToUpdate = csObjMap.get(mtd.Product_Name__c);
                                if(mtd.Product_Name__c == 'T+0'){
                                    csObjToUpdate = getISCrossSellZone(csObjToUpdate,eachOpp,mtd,zoneCriteria);
                                }
                                if(mtd.Product_Name__c == 'MCP'){
                                    csObjToUpdate = getMCPCrossSellZone(csObjToUpdate,eachOpp,mtd,zoneAssignmentMCPMap);
                                }
                                if(mtd.Product_Name__c == 'EMI'){
                                    csObjToUpdate = getEMICrossSellZone(csObjToUpdate,eachOpp,mtd,zoneAssignmentEMIMap);
                                }
                                csObjToUpdate.Cross_Sell_Stop_Task_Creation__c = true;
                                csObjListToUpdate.add(csObjToUpdate);
                            }
                        }
                    }
                }
            }
            if(csObjListToInsert.size()>0){
                insert csObjListToInsert;
                System.debug('@@@@@@ csObjListToInsert '+csObjListToInsert);
            }
            if(csObjListToUpdate.size()> 0){
                update csObjListToUpdate;
                System.debug('@@@@@@ csObjListToUpdate '+csObjListToUpdate);
            }
        }
    }    
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    } 
    
    public static cross_Sell__c getISCrossSellZone(Cross_Sell__c csObj, Opportunity eachOpp,CrossSell_Creation_crit__mdt mtd, Boolean zoneCriteria){
        if(eachOpp.Website_Status__c == 'Website OK' && eachOpp.Settlement_Status__c == 'Active' && eachOpp.Aging__c >= 90 
           && eachOpp.CB_Ratio__c < 0.5 && eachOpp.Last_6_months_GMV__c >= 200000.00 && mtd.Product_Name__c == 'T+0'){
               csObj.Risk_Zone__c = 'Green Zone';
               csobj.Risk_Status__c = 'Approved';
               zoneCriteria = false;
           }else if(mtd.Product_Name__c == 'T+0' && zoneCriteria){
               csObj.Risk_Zone__c = 'Amber Zone';
               if(csObj.Kam_Status__c == ''){
                   csObj.Risk_Status__c = 'Pending';
               }
           }
        return csObj;
    }
    
    public static cross_Sell__c getMCPCrossSellZone(Cross_Sell__c csObj, Opportunity eachOpp,CrossSell_Creation_crit__mdt mtd,Map<string,CrossSell_Risk_Zone_Assignment__mdt> zoneAssignmentMap){
        
        if((zoneAssignmentMap.containsKey(eachOpp.BusinessCategory__r.Name) && zoneAssignmentMap.get(eachOpp.BusinessCategory__r.Name).Product_Name__c== mtd.Product_Name__c)
           || (zoneAssignmentMap.containsKey(eachOpp.Business_Category__c) && zoneAssignmentMap.get(eachOpp.Business_Category__c).Product_Name__c == mtd.Product_Name__c)){
               Map<String,String> SubCategoryVsRiskZoneForOpp = New Map<String,String>();
               Map<String,String> SubCategoryVsRiskZoneForAccount = New Map<String,String>();
               if(String.isNotBlank(eachOpp.BusinessCategory__c) && zoneAssignmentMap.containsKey(eachOpp.BusinessCategory__r.Name))
                   SubCategoryVsRiskZoneForOpp = (Map<String,String>)JSON.deserialize(zoneAssignmentMap.get(eachOpp.BusinessCategory__r.Name).Sub_Category_Vs_Risk_Zone__c, Map<String, String>.class);
               if(String.isNotBlank(eachOpp.Business_Category__c) && zoneAssignmentMap.containsKey(eachOpp.Business_Category__c))
                   SubCategoryVsRiskZoneForAccount = (Map<String,String>)JSON.deserialize(zoneAssignmentMap.get(eachOpp.Business_Category__c).Sub_Category_Vs_Risk_Zone__c, Map<String, String>.class);
               
               If(!SubCategoryVsRiskZoneForAccount.isEmpty() || !SubCategoryVsRiskZoneForOpp.isEmpty()){
                   If(zoneAssignmentMap.containsKey(eachOpp.BusinessCategory__r.Name) && String.isNotBlank(eachOpp.Sub_Category__r.Name) && SubCategoryVsRiskZoneForOpp.containsKey(eachOpp.Sub_Category__r.Name)){
                       if(SubCategoryVsRiskZoneForOpp.get(eachOpp.Sub_Category__r.Name) == 'Red Zone'){
                           csObj.Risk_Zone__c = 'Red Zone';
                           csObj.Risk_Status__c = 'Rejected';
                           csObj.Risk_Comment__c = 'Rejected by System.';
                           csObj.KAM_Status__c = 'Rejected by System';
                       }else{
                           csObj.Risk_Zone__c = 'Amber Zone';
                       }
                   }else if(zoneAssignmentMap.containsKey(eachOpp.Business_Category__c) && String.isNotBlank(eachOpp.Account.SubCategoryName__c) && SubCategoryVsRiskZoneForAccount.containsKey(eachOpp.Account.SubCategoryName__c)){
                       
                       if(SubCategoryVsRiskZoneForAccount.get(eachOpp.Account.SubCategoryName__c) == 'Red Zone'){
                           csObj.Risk_Zone__c = 'Red Zone';
                           csObj.Risk_Status__c = 'Rejected';
                           csObj.Risk_Comment__c = 'Rejected by System.';
                           csObj.KAM_Status__c = 'Rejected by System';
                       }else{
                           csObj.Risk_Zone__c = 'Amber Zone';
                       }
                   }
               }
           }
        return csObj;
    }
    
    public static cross_Sell__c getEMICrossSellZone(Cross_Sell__c csObj, Opportunity eachOpp,CrossSell_Creation_crit__mdt mtd,Map<string,CrossSell_Risk_Zone_Assignment__mdt> zoneAssignmentMap){
        
        if((zoneAssignmentMap.containsKey(eachOpp.BusinessCategory__r.Name) && zoneAssignmentMap.get(eachOpp.BusinessCategory__r.Name).Product_Name__c== mtd.Product_Name__c)
           || (zoneAssignmentMap.containsKey(eachOpp.Business_Category__c) && zoneAssignmentMap.get(eachOpp.Business_Category__c).Product_Name__c == mtd.Product_Name__c)){
               Map<String,String> SubCategoryVsRiskZoneForOpp = New Map<String,String>();
               Map<String,String> SubCategoryVsRiskZoneForAccount = New Map<String,String>();
               if(String.isNotBlank(eachOpp.BusinessCategory__c) && zoneAssignmentMap.containsKey(eachOpp.BusinessCategory__r.Name))
                   SubCategoryVsRiskZoneForOpp = (Map<String,String>)JSON.deserialize(zoneAssignmentMap.get(eachOpp.BusinessCategory__r.Name).Sub_Category_Vs_Risk_Zone__c, Map<String, String>.class);
               if(String.isNotBlank(eachOpp.Business_Category__c) && zoneAssignmentMap.containsKey(eachOpp.Business_Category__c))
                   SubCategoryVsRiskZoneForAccount = (Map<String,String>)JSON.deserialize(zoneAssignmentMap.get(eachOpp.Business_Category__c).Sub_Category_Vs_Risk_Zone__c, Map<String, String>.class);
               
               
               If(!SubCategoryVsRiskZoneForAccount.isEmpty() || !SubCategoryVsRiskZoneForOpp.isEmpty()){
                   If(zoneAssignmentMap.containsKey(eachOpp.BusinessCategory__r.Name) && String.isNotBlank(eachOpp.Sub_Category__r.Name) && SubCategoryVsRiskZoneForOpp.containsKey(eachOpp.Sub_Category__r.Name)){
                       if(SubCategoryVsRiskZoneForOpp.get(eachOpp.Sub_Category__r.Name) == 'Red Zone' || String.isBlank(eachOpp.MCC_Code__c)){
                           csObj.Risk_Zone__c = 'Red Zone';
                           csObj.Risk_Status__c = 'Rejected';
                           csObj.Risk_Comment__c = 'Rejected by System.';
                           csObj.KAM_Status__c = 'Rejected by System';
                       }else{
                           List<String> mccCodeList = New List<String>();
                           If(String.isNotBlank(eachOpp.MCC_Code__c) && zoneAssignmentMap.containsKey(eachOpp.BusinessCategory__r.Name) &&
                              zoneAssignmentMap.get(eachOpp.BusinessCategory__r.Name).MCC_Code__c != null){
                                  mccCodeList = zoneAssignmentMap.get(eachOpp.BusinessCategory__r.Name).MCC_Code__c.split(',');
                              }else If(String.isNotBlank(eachOpp.MCC_Code__c) && zoneAssignmentMap.containsKey(eachOpp.Business_Category__c) &&
                                       zoneAssignmentMap.get(eachOpp.Business_Category__c).MCC_Code__c != null){
                                           mccCodeList = zoneAssignmentMap.get(eachOpp.BusinessCategory__r.Name).MCC_Code__c.split(',');
                                       }
                           
                           If(String.isNotBlank(eachOpp.MCC_Code__c) && mccCodeList.contains(eachOpp.MCC_Code__c)){
                               csObj.Risk_Zone__c = 'Red Zone';
                               csObj.Risk_Zone__c = 'Red Zone';
                               csObj.Risk_Status__c = 'Rejected';
                               csObj.Risk_Comment__c = 'Rejected by System.';
                               csObj.KAM_Status__c = 'Rejected by System';
                           }else If(String.isNotBlank(eachOpp.MCC_Code__c) && !mccCodeList.contains(eachOpp.MCC_Code__c)){
                               csObj.Risk_Zone__c = 'Green Zone';
                               csObj.Risk_Status__c = 'Approved';
                               csObj.Risk_Comment__c = 'Approved by System.';
                           }
                       }
                   }else if(zoneAssignmentMap.containsKey(eachOpp.Business_Category__c) && String.isNotBlank(eachOpp.Account.SubCategoryName__c) && SubCategoryVsRiskZoneForAccount.containsKey(eachOpp.Account.SubCategoryName__c)){
                       
                       if(SubCategoryVsRiskZoneForAccount.get(eachOpp.Account.SubCategoryName__c) == 'Red Zone' || String.isBlank(eachOpp.MCC_Code__c)){
                           csObj.Risk_Zone__c = 'Red Zone';
                           csObj.Risk_Status__c = 'Rejected';
                           csObj.Risk_Comment__c = 'Rejected by System.';
                           csObj.KAM_Status__c = 'Rejected by System';
                       }else{
                           List<String> mccCodeList = New List<String>();
                           If(String.isNotBlank(eachOpp.MCC_Code__c) && zoneAssignmentMap.containsKey(eachOpp.BusinessCategory__r.Name) &&
                              zoneAssignmentMap.get(eachOpp.BusinessCategory__r.Name).MCC_Code__c != null){
                                  mccCodeList = zoneAssignmentMap.get(eachOpp.BusinessCategory__r.Name).MCC_Code__c.split(',');
                              }else If(String.isNotBlank(eachOpp.MCC_Code__c) && zoneAssignmentMap.containsKey(eachOpp.Business_Category__c) &&
                                       zoneAssignmentMap.get(eachOpp.Business_Category__c).MCC_Code__c != null){
                                           mccCodeList = zoneAssignmentMap.get(eachOpp.BusinessCategory__r.Name).MCC_Code__c.split(',');
                                       }
                           
                           If(String.isNotBlank(eachOpp.MCC_Code__c) && mccCodeList.contains(eachOpp.MCC_Code__c)){
                               csObj.Risk_Zone__c = 'Red Zone';
                               csObj.Risk_Zone__c = 'Red Zone';
                               csObj.Risk_Status__c = 'Rejected';
                               csObj.Risk_Comment__c = 'Rejected by System.';
                               csObj.KAM_Status__c = 'Rejected by System';
                           }else If(String.isNotBlank(eachOpp.MCC_Code__c) && !mccCodeList.contains(eachOpp.MCC_Code__c)){
                               csObj.Risk_Zone__c = 'Green Zone';
                               csObj.Risk_Status__c = 'Approved';
                               csObj.Risk_Comment__c = 'Approved by System.';
                           }
                       }
                   }
               }
           }
        return csObj;
    }
    
    public static Cross_Sell__c createCSObject(Opportunity eachOpp, CrossSell_Creation_crit__mdt mtd){
        Map<String,String> 	CrossSell_ProductNameVsIdMap =(Map<String, String>)JSON.deserialize(mtd.ProductNameVsIdMap__c, Map<String, String>.class);
        Map<String,String> 	CrossSell_ProductNameVsRecordTypeIdMap =(Map<String, String>)JSON.deserialize(mtd.ProductVsRecordTypeMap__c , Map<String, String>.class);
        
        Cross_Sell__c csObj = new Cross_Sell__c();
        csObj.Source__c = 'Uploaded by System';
        csObj.Custom_Product__c = CrossSell_ProductNameVsIdMap.get(mtd.Product_Name__c);
        csObj.RecordTypeId = CrossSell_ProductNameVsRecordTypeIdMap.get(mtd.Product_Name__c);
        csObj.Opportunity__c = eachOpp.Id;
        csObj.Cross_Sell_Stop_Task_Creation__c = true;
        csObj.Active__c = true;
        csObj.Name = mtd.Product_Name__c;
        return csObj;
    }
    
    public static List<Cross_Sell__c> getCSObjList(List<Opportunity> triggerNew){
        List<String> leadTypeList = New List<String>{'Merchant','Seller','Aggregator'};
            List<Cross_Sell__c> csObjListToInsert = New List<Cross_Sell__c>();
        Map<string,CrossSell_Risk_Zone_Assignment__mdt> zoneAssignmentMCPMap = New Map<string,CrossSell_Risk_Zone_Assignment__mdt>();
        Map<string,CrossSell_Risk_Zone_Assignment__mdt> zoneAssignmentEMIMap = New Map<string,CrossSell_Risk_Zone_Assignment__mdt>();
        
        List<CrossSell_Creation_crit__mdt> crossSellCreationMetadataList = [SELECT Active__c  ,Creation_Criteria__c   ,Product_Name__c, ProductNameVsIdMap__c ,ProductVsRecordTypeMap__c  FROM CrossSell_Creation_crit__mdt ];
        
        for(CrossSell_Risk_Zone_Assignment__mdt assMDT : [Select Id,Business_Category__c,Product_Name__c,Sub_Category_Vs_Risk_Zone__c, MCC_Code__c
                                                          from CrossSell_Risk_Zone_Assignment__mdt]){
                                                              If(String.isNotBlank(assMDT.Business_Category__c) && assMDT.Product_Name__c == 'MCP'){
                                                                  zoneAssignmentMCPMap.put(assMDT.Business_Category__c,assMDT);
                                                              }
                                                              If(String.isNotBlank(assMDT.Business_Category__c) && assMDT.Product_Name__c == 'EMI'){
                                                                  zoneAssignmentEMIMap.put(assMDT.Business_Category__c,assMDT);
                                                              }
                                                          }
        if(triggerNew.size()>0){
            for(Opportunity eachOpp: triggerNew){
                If(leadTypeList.contains(eachOpp.Lead_Type__c)){
                    Set<String> productNameSet = new Set<String>();
                    Map<String,Cross_Sell__c> csObjMap = New Map<String,Cross_Sell__c>();
                    Boolean zoneCriteria = true;
                    
                    if(crossSellCreationMetadataList.size()>0){
                        for(CrossSell_Creation_crit__mdt mtd: crossSellCreationMetadataList){
                            
                            Cross_Sell__c csObj = new Cross_Sell__c();
                            csObj = createCSObject(eachOpp,mtd);
                            if(mtd.Product_Name__c == 'T+0'){
                                csObj = getISCrossSellZone(csObj,eachOpp,mtd,zoneCriteria);
                            }
                            if(mtd.Product_Name__c == 'MCP'){
                                csObj = getMCPCrossSellZone(csObj,eachOpp,mtd,zoneAssignmentMCPMap);
                            }
                            if(mtd.Product_Name__c == 'EMI'){
                                csObj = getEMICrossSellZone(csObj,eachOpp,mtd,zoneAssignmentEMIMap);
                            }
                            csObjListToInsert.add(csObj);
                        }
                    }
                }
            }
        }
        return csObjListToInsert;
    }
}