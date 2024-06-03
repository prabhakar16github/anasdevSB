public class OpportunityTriggerHelper{
    
    static Map<String, String> relationShipFieldMap = (Map<String, String>)JSON.deserialize(Label.RelationShipFieldMap, Map<String, String>.class);
    static Map<String, Map<String, String>> soqlMap = (Map<String, Map<String, String>>)JSON.deserialize(Label.ReverseProcessCloneChilds, Map<String, Map<String, String>>.class);
    static Map<String, String> commercialPlanFieldMap = (Map<String, String>)JSON.deserialize(Label.CommercialPlanFieldMap, Map<String, String>.class);
    static Map<String, String> mpoPpoFieldMap = (Map<String, String>)JSON.deserialize(Label.MpoPpoFieldMap, Map<String, String>.class);
    static Map<String, String> tdrPricingFieldMap = (Map<String, String>)JSON.deserialize(Label.TdrPricingFieldMap, Map<String, String>.class);
    
    public static void checkInsertCommercial(Opportunity newRec, List<Opportunity> oppToOperate, Map<String, List<Plan__c>> productPlanMap){
        
        if(!MaintenanceCtrl.restPlanOppIds.contains(newRec.Id) && Trigger.isInsert && newRec.Product__c != null && newRec.isConverted__c && 'PayUmoney'.equals(newRec.ProductLabel__c)){            
            oppToOperate.add(newRec);
            productPlanMap.put(newRec.Product__c, null);            
        }        
    }
        
    public static void checkLiveAndTrans(Opportunity newRec, Opportunity oldRec, Map<String, String> oppIdMap){        
        if(newRec.AccountId != null && ('NEW MID'.equals(newRec.Maintenance_Status__c) || 'OLD MID'.equals(newRec.Maintenance_Status__c)) && String.isNotBlank(newRec.StageName) && !newRec.StageName.equals(oldRec.StageName) && 'Live & Transacting'.equals(newRec.StageName)){
            oppIdMap.put(newRec.Id, newRec.AccountId);
        }
    }        
    
    public static void processLiveAndTransOpps(Map<String, String> oppIdMap){        
        if(!oppIdMap.isEmpty()){
            List<SObject> accToUpdate = new List<SObject>();
            List<SObject> oppToUpdate = new List<SObject>();
            Map<String, List<SObject>> relatedRecUpdateMap = new Map<String, List<SObject>>();
            
            for(String eachRelatedKey : soqlMap.keySet()){
                
                String relationshipField = relationShipFieldMap.get(eachRelatedKey);                               
                Map<String, SObject> recordMap = new Map<String, SObject>();
                getRecords(eachRelatedKey, recordMap, ('Account'.equals(eachRelatedKey)) ? new Set<String>(oppIdMap.values()) : oppIdMap.keySet(), true);            
                Map<String, SObject> parentRecordMap = new Map<String, SObject>();
                
                if(!recordMap.isEmpty()){
                    for(SObject each : recordMap.values()){   
                        system.debug('-->> recordMap >> '+each.get(relationshipField) + relationshipField);
                        if(each.get(relationshipField) != null){
                            parentRecordMap.put(String.valueOf(each.get(relationshipField)), null);
                        }
                    }
                    
                    if(!parentRecordMap.isEmpty()){
                        getRecords(eachRelatedKey, parentRecordMap, parentRecordMap.keySet(), false);            
                    }
                }
                
                Map<String, String> objectMap = soqlMap.get(eachRelatedKey);
                
                for(SObject each : recordMap.values()){                                   
                    
                    if(each.get(relationshipField) != null && parentRecordMap.containsKey(String.valueOf(each.get(relationshipField)))){                        
                        
                        String clonedId = String.valueOf(each.get('Id'));
                        String maintenanceStat = String.valueOf(each.get('Maintenance_Status__c'));
                        SObject eachParent = parentRecordMap.get(String.valueOf(each.get(relationshipField)));
                        each.put('Id', each.get(relationshipField));
                        each.put(relationshipField, null);                                                
                        each.put('Maintenance_Status__c', null);
                                                                        
                        for(String eachStr : objectMap.keySet()){
                            Map<String, SObject> tempMap = new Map<String, SObject>();
                            Map<String, String> oldSobMap = new Map<String, String>();
                            
                            for(SObject eachParentSob : eachParent.getSObjects(objectMap.get(eachStr))){
                                oldSobMap.put(String.valueOf(eachParentSob.get('Identifier__c')), String.valueOf(eachParentSob.get('Id')));
                            }
                                                        
                            for(SObject eachSob : each.getSObjects(objectMap.get(eachStr))){
                                eachSob.put(relationShipFieldMap.get(eachStr), each.get('Id'));
                                String identifier = String.valueOf(eachSob.get('Identifier__c'));
                                
                                if(oldSobMap.containsKey(identifier)){
                                    eachSob.put('Id', oldSobMap.get(identifier));
                                    tempMap.put(identifier, eachSob);
                                }else{                                
                                    tempMap.put(identifier, eachSob.clone());
                                }                            
                            }
                            
                            if(!tempMap.isEmpty()) relatedRecUpdateMap.put(eachStr, tempMap.values());
                        } 
                        
                        if('Account'.equals(eachRelatedKey)){
                            accToUpdate.add(new Account(Id = clonedId, Maintenance_Status__c = 'Archived'));
                            each.put('RecordTypeId', eachParent.get('RecordTypeId'));
                            each.put('Name', eachParent.get('Name'));
                            accToUpdate.add(each);
                        }
                        else if('Opportunity'.equals(eachRelatedKey)){
                            Opportunity theNewOpp = new Opportunity(Id = clonedId, Maintenance_Status__c = (maintenanceStat.equals('OLD MID')) ? 'Archived' : null);                        
                            if('NEW MID'.equals(maintenanceStat)){
                                theNewOpp.put('AccountId', eachParent.get('AccountId'));
                            }
                            each.put('AccountId', eachParent.get('AccountId'));                            
                            each.put('RecordTypeId', eachParent.get('RecordTypeId'));
                            each.put('Name', eachParent.get('Name'));                            
                            oppToUpdate.add(theNewOpp);
                            oppToUpdate.add(each);
                        }                     
                    }                                                                                                                                
                }
            }
            
            if(!accToUpdate.isEmpty()) update accToUpdate;
            if(!oppToUpdate.isEmpty()) update oppToUpdate;
            
            if(!relatedRecUpdateMap.isEmpty()){
                            
                for(String eachRecKey : relatedRecUpdateMap.keySet()){
                    if(relatedRecUpdateMap.get(eachRecKey) != null && !relatedRecUpdateMap.get(eachRecKey).isEmpty()){                            
                        dynamicUpsert(relatedRecUpdateMap.get(eachRecKey), eachRecKey);
                    }
                }
            }
        }                        
    }            
    
    public static void dynamicUpsert(List<SObject> records, String sObjectType){
        String listType = 'List<' + sObjectType + '>';
        List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
        castRecords.addAll(records);
        upsert castRecords;
    }
    
    public static void insertCommercial(List<Opportunity> oppToOperate, Map<String, List<Plan__c>> productPlanMap){
        //commented for pre-onboarding
        if(!oppToOperate.isEmpty() && !productPlanMap.isEmpty()){
            getPlanData(productPlanMap);         
            
            Map<String, SObject> commercialsToInsert = new Map<String, SObject>();                
            Map<String, SObject> mpoToInsert = new Map<String, SObject>();
            List<SObject> tdrsToInsert = new List<SObject>();
            
            for(Opportunity each : oppToOperate){
                
                if(productPlanMap.containsKey(each.Product__c) && productPlanMap.get(each.Product__c) != null){
                    
                    for(Plan__c eachPlan : productPlanMap.get(each.Product__c)){
                        Commercial__c theComm = new Commercial__c(Opportunity__c = each.Id, Type__c = 'payu');
                        commercialsToInsert.put(each.Id + '__' + eachPlan.Id, objectMap(eachPlan, theComm, commercialPlanFieldMap));
                    }
                }
            }
            
            if(!commercialsToInsert.isEmpty()){
                
                insert commercialsToInsert.values();
                
                for(Opportunity each : oppToOperate){
                    
                    if(productPlanMap.containsKey(each.Product__c) && productPlanMap.get(each.Product__c) != null){                                        
                        
                        for(Plan__c thePlan : productPlanMap.get(each.Product__c)){
                            
                            if(commercialsToInsert.containsKey(each.Id + '__' + thePlan.Id)){
                                SObject theComm = commercialsToInsert.get(each.Id + '__' + thePlan.Id);
                                
                                for(PricingPaymentOption__c eachPPO : thePlan.Pricing_Payment_Options__r){                                
                                    String uniqueMpoStr = each.Id + '__' + eachPPO.Payment_Option__c + '__' + eachPPO.Payment_Gateway__c;
                                    
                                    if(!mpoToInsert.containsKey(uniqueMpoStr)){
                                        MerchantPaymentOption__c theMPO = new MerchantPaymentOption__c(Opportunity__c = each.Id);
                                        mpoToInsert.put(uniqueMpoStr, objectMap(eachPPO, theMPO, mpoPpoFieldMap));
                                    }
                                }
                                
                                for(Plan_Pricing__c eachPricing : thePlan.Plan_Pricings__r){
                                    TDR__c theTDR = new TDR__c(Commercial__c = theComm.Id, Opportunity__c = each.Id);
                                    tdrsToInsert.add(objectMap(eachPricing, theTDR, tdrPricingFieldMap));
                                }
                            }
                        }
                    }
                }
                
                if(!mpoToInsert.isEmpty()) insert mpoToInsert.values();
                if(!tdrsToInsert.isEmpty()) insert tdrsToInsert;
            } 
        }          
    }
      
    public static SObject objectMap(SObject source, SObject destination, Map<String, String> fieldMap){
        for(String each : fieldMap.keySet()){
            destination.put(fieldMap.get(each), source.get(each));
        }
        return destination;
    }
      
    public static void getRecords(String sobName, Map<String, SObject> sobMap, Set<String> filterIds, Boolean getAll){
        
        String queryStr = 'SELECT ' + (getAll ? String.join(new List<String>(AWSConsumerBatch.getFieldSet(sobName)), ',') : ('Id,Identifier__c,' + relationShipFieldMap.get(sobName)));
        if('Opportunity'.equals(sobName) && !getAll) queryStr += ',AccountId,RecordTypeId,Name';
        if('Account'.equals(sobName) && !getAll) queryStr += ',RecordTypeId,Name';
        Map<String, String> objectMap = soqlMap.get(sobName);
        for(String each : objectMap.keySet()){
            queryStr += ', (SELECT ' + (getAll ? String.join(new List<String>(AWSConsumerBatch.getFieldSet(each)), ',') : ('Id,Identifier__c,' + relationShipFieldMap.get(each))) + ' FROM '+ objectMap.get(each) + ')';            
        }
        queryStr += ' FROM ' + sobName + ' WHERE Id IN ' + TDRScreenController.joinfilterIds(filterIds);        
        sobMap.putAll(Database.query(queryStr));       
    }        
       
    //commented for pre-onboarding
    public static void getPlanData(Map<String, List<Plan__c>> productPlanMap){
        String queryStr = 'SELECT Id, ' + String.join(PlanFormController.planFieldsList, ', ') + ', ';
        
        queryStr += '(SELECT Id, ';
        queryStr += String.join(PlanFormController.planPricingList, ', ');
        queryStr += ' FROM Plan_Pricings__r), ';
        
        queryStr += '(SELECT Id, Payment_Option__c, ';
        queryStr += String.join(PlanFormController.planPricingPOList, ', ');
        queryStr += ' FROM Pricing_Payment_Options__r)';
        
        queryStr += ' FROM Plan__c WHERE Type__c =\'merchant_plan\'';         
        queryStr += ' AND Product__c IN ' + TDRScreenController.joinfilterIds(productPlanMap.keySet());       
        queryStr += ' AND Default__c = true';
        
        for(Plan__c each : Database.query(queryStr)){             
            if(productPlanMap.containsKey(each.Product__c)){
                if(productPlanMap.get(each.Product__c) != null){
                    productPlanMap.get(each.Product__c).add(each); 
                }else{
                    productPlanMap.put(each.Product__c, new List<Plan__c>{each});    
                }   
            }
        }        
    } 
    
    public static void checkInsertWP(Opportunity newRec, Set<Id> productsIdSet, Set<String> intTypeSet, List<Opportunity> oppToOperate){
        if(newRec.Product__c != null && String.isNotBlank(newRec.Integration_Type__c)){ // && newRec.isConverted__c){     ==> comment by uma shankar at May.02, 2019 as per discussed with Nilesh
            productsIdSet.add(newRec.Product__c);
            intTypeSet.add(newRec.Integration_Type__c);
            oppToOperate.add(newRec);
        }
    }
    
    //commented in OpportunityTriggerHandler
    /*public static void insertWPs(Set<Id> productsIdSet, Set<String> intTypeSet, List<Opportunity> oppToOperate){
        if(!productsIdSet.isEmpty() && !intTypeSet.isEmpty()){
            Map<String, List<Website_Page_Master__c>> wpmMap = new Map<String, List<Website_Page_Master__c>>();
            
            for(Website_Page_Master__c each : [SELECT Id, Name, Page_Details__c, Product__c, Integration_Type__c 
                                               FROM Website_Page_Master__c 
                                               WHERE Active__c = true 
                                               AND Integration_Type__c IN: intTypeSet 
                                               AND Product__c IN: productsIdSet AND Integration_Type__c != null]){
                List<Website_Page_Master__c> tempWPM = !wpmMap.containskey(each.Product__c + '__' + each.Integration_Type__c) ? new List<Website_Page_Master__c>() : wpmMap.get(each.Product__c + '__' + each.Integration_Type__c);
                tempWPM.add(each);
                wpmMap.put(each.Product__c + '__' + each.Integration_Type__c, tempWPM);
            } 
                          
            System.debug('--------------------->'+wpmMap);
            
            if(!wpmMap.isEmpty()){
                List<Website_Page__c> wpListToInsert = new List<Website_Page__c>();
                
                for(Opportunity each : oppToOperate){                    
                    if(wpmMap.containsKey(each.Product__c + '__' + each.Integration_Type__c)){
                        for(Website_Page_Master__c eachWP : wpmMap.get(each.Product__c + '__' + each.Integration_Type__c)){                                                     
                            wpListToInsert.add(new Website_Page__c(Opportunity__c = each.Id, Page_Details__c = eachWP.Page_Details__c, Active__c = true, Name = eachWP.Name));                           
                        }                        
                    }                    
                }
                System.debug('--------->>------------>'+wpListToInsert);
                if(!wpListToInsert.isEmpty()) Database.insert(wpListToInsert, false);
            }
        }
    } */
    
    /*public static void sendEmailToMerchant(Opportunity opty, Id templateId){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toaddresses = new String[] { opty.Email__c };
        message.bccaddresses = new String[] { 'danish.hoda@cognizant.com' };
        message.setTemplateId(templateId);
        message.saveAsActivity = false;
        message.setWhatId(opty.Id);
        //message.setTargetObjectId(opty.Id);
        message.targetobjectid = (opty.Id);
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }*/
    
    //Added to regenerate Agreement when Website is updated
    public static List<Sobject> updateagreementWithNewWebURL(List<Opportunity> oppList, Map<String,String> oppIdwithChildId){
        
        Set<String> setofAccId = new Set<String>();
        List<Contract> lstContractUpdate = new List<Contract>();
        Map<Id, Opportunity> mapAccIdOpp = new Map<Id, Opportunity>();
        Map<String,String> mapofContractWithopport = new Map<String,String>();
        Map<String,List<Contract>> mapAccountwithContract = new Map<String,List<Contract>>();
        Map<Id,Contract> mapOfIdContract = new Map<Id,Contract>();
        Map<Id,String> mapofContractWithAgreementVFpage = new Map<Id,String>();List<String> lstofBankId ;
        List<Account> accounttoUpdateList = new List<Account>();
        Map<String,Opportunity> mapofApprovedContrOpp = new Map<string,Opportunity>();
        //List<Contract> lstAddendumUpdate = new List<Contract>();
        
        if(!oppList.isEmpty() && oppList.size() > 0){
            for(opportunity opp : oppList){
                setofAccId.add(opp.AccountId);
            }
            if(!setofAccId.isEmpty()) getContractfromAccount(setofAccId, mapAccountwithContract);
            
            for(opportunity eachOpp : oppList){
                if(eachOpp.AccountId != null && mapAccountwithContract.containsKey(eachOpp.AccountId) 
                   //&& eachOpp.Website_updated_last__c
                   && mapAccountwithContract.get(eachOpp.AccountId) != null
                   && !mapAccountwithContract.get(eachOpp.AccountId).isEmpty()){
                       String VfpageName ='';
                       if(eachOpp.VFPageKey__c != null && VFPageWithData__c.getValues(eachOpp.VFPageKey__c) != null){
                           VfpageName = VFPageWithData__c.getValues(eachOpp.VFPageKey__c).VFPageName__c ;
                       }
                       if(Test.isRunningTest()) VfpageName = 'payUmoney-Merchant';
                       system.debug('=======VfpageName ======'+VfpageName );    
                       for(Contract objContact : mapAccountwithContract.get(eachOpp.AccountId)){
                           if((objContact.Status == 'Pending' || objContact.Status == 'Sent') && VfpageName != '' && objContact.Active__c == false
                              && eachOpp.Agreement_Regeneration__c){
                                  if(oppIdwithChildId.isEmpty()) mapofContractWithopport.put(objContact.Id,eachOpp.Id); 
                                else mapofContractWithopport.put(objContact.Id,oppIdwithChildId.get(eachOpp.Id));
                               mapOfIdContract.put(objContact.Id,objContact);
                               mapofContractWithAgreementVFpage.put(objContact.Id,VfpageName);
                               objContact.URL__c ='';
                               objContact.Upload_Date__c = System.today();
                               Break;
                           }
                           else if(objContact.Status == 'Approved Activate' || objContact.Status == 'Approved' || objContact.Status == 'Counter Signed Received'){
                               mapofApprovedContrOpp.put(objContact.id, eachOpp);
                           }
                       }
                   }
            }
        }
            
            if(!mapOfIdContract.isEmpty()){
            for(Id objId:mapOfIdContract.keySet()){
                system.debug('=objId====='+objId);
                String strEndPoint ='';
                Contract objContract = new Contract();
                objContract = mapOfIdContract.get(objId);
                if(mapofContractWithAgreementVFpage.get(objId) != null && mapofContractWithopport.get(objId)!= null){
                    PageReference pageRef = new PageReference('/apex/' + mapofContractWithAgreementVFpage.get(objId));
                    pageRef.getParameters().put('id', mapofContractWithopport.get(objId));        
                    pageRef.getParameters().put('strIsFinal', 'true');
                    pageRef.getParameters().put('eStampNo', String.valueof(objContract.E_Stamp_Number__c));
                    Blob body;
                    
                    if(!Test.isRunningTest()){
                        body = pageRef.getContent();
                        strEndPoint = AWSUtility.uploadAndGetDocUrlS3(objContract, objContract.Account.Identifier__c, body);
                    }else if(Test.isRunningTest()){
                        strEndPoint = 'google.com';
                        body = Blob.valueOf('Test Data');
                    }                 
                    
                    system.debug('strEndPoint ************ '+strEndPoint);
                    if(String.isNotBlank(strEndPoint)){
                        objContract.URL__c = strEndPoint;
                        objContract.Upload_Date__c = System.today();
                        objContract.File_Size__c = String.valueOf(body.size());
                        
                        lstContractUpdate.add(objContract);
                        
                        Account accObj = new Account(Id = objContract.AccountId);
                        if(accObj.Agreement_Status__c == 'Not Generated'){
                            accObj.Agreement_Status__c = 'Sent';
                            accounttoUpdateList.add(accObj);
                        } 
                    }
                }
            }
        }
        /*else if(!mapofApprovedContrOpp.isEmpty()){
            lstContractUpdate = createNewAddendumforWebsiteUpdate(mapofApprovedContrOpp);
        }*/
        System.debug(lstContractUpdate.size()+' <== lstContractInsert ==> '+lstContractUpdate); 
        System.debug(accounttoUpdateList.size()+' <== accounttoUpdateList ==> '+accounttoUpdateList);   
        if(!lstContractUpdate.isEmpty())
            update lstContractUpdate;
        if(!accounttoUpdateList.isEmpty()) 
            update accounttoUpdateList;
        return lstContractUpdate;
        
    } 

public static Map<String,List<Contract>> getContractfromAccount(Set<String> setAccountId, Map<String,List<Contract>> mapAccountwithContract){
        
        for(Contract objContract:[SELECT Id, Status, Account.Agreement_Status__c,AccountId, E_Stamp__c, Document_Master__c, Type__c, Document_Category__c,  
                                  Document_Category__r.Name, Contract_Type__c, Offline_Generation__c, Pricebook2Id, Active__c,Account.Identifier__c,
                                  Document_Content_Type__c, File_Size__c, URL__c, OwnerExpirationNotice, Document_Type__c, 
                                  Document_Category_Name__c, Document_Type_Name__c, StartDate, ContractTerm, E_Stamp_Number__c 
                                  FROM Contract WHERE AccountId IN : setAccountId 
                                  AND (Account.Agreement_Status__c = 'Not Generated' OR Account.Agreement_Status__c = 'Pending'
                                       OR Account.Agreement_Status__c = 'Sent' OR Account.Agreement_Status__c = 'Rejected' 
                                       OR Account.Agreement_Status__c = 'Draft In Process' 
                                       OR Account.Agreement_Status__c = 'Counter Signed Received'
                                       OR Account.Agreement_Status__c = 'Approved')
                                  AND Contract_Type__c = 'Agreement' AND Status IN('Pending','Sent')
                                  ORDER BY LastModifiedDate DESC]){
                                           
                                           if(String.isBlank(objContract.Document_Type_Name__c) && objContract.Status != 'Approved' && objContract.Status != 'Counter Signed Received'){
                                               objContract.Document_Type_Name__c = 'Agreement';
                                           }
                                           if(String.isBlank(objContract.Document_Category_Name__c) && objContract.Status != 'Approved' && objContract.Status != 'Counter Signed Received'){
                                               objContract.Document_Category_Name__c = 'Service Agreement';
                                           }
                                           if(mapAccountwithContract.get(String.valueof(objContract.AccountId)) != null){
                                               List<Contract> lstCont = mapAccountwithContract.get(String.valueof(objContract.AccountId));
                                               lstCont.add(objContract);
                                               mapAccountwithContract.put(String.valueof(objContract.AccountId),lstCont);
                                           }
                                           else if(mapAccountwithContract.get(String.valueof(objContract.AccountId)) == null){
                                               List<Contract> lstCont = new List<Contract>();
                                               lstCont.add(objContract);
                                               mapAccountwithContract.put(String.valueof(objContract.AccountId),lstCont);
                                           }  
                                       }
    return mapAccountwithContract;
    }
    /*public static List<Contract> createNewAddendumforWebsiteUpdate (Map<String,Contract> mapContrOpp) {
        Map<String, String> mapContentType = (Map<String, String>) json.deserialize(Label.ContentTypeBasedOnFileType,Map<String, String>.class);
        List<string> DocMasterList = Label.DocMasterList.Split(',');
        String PageAssociation;
        List<Document_Master__c> docDetails = [Select Id,Name, Page_Association__c 
                                    FROM Document_Master__c where id IN :DocMasterList order by Page_Association__c];
        List<Contract> AddendumList = new List<Contract>();
        set<String> setAddendumId = new Set<String>();
        String strEndPoint;
        List<Contract> updatedList = new List<Contract>();
        
        for(String each : mapContrOpp.keySet()){
            Contract Addendum = new Contract();
            Addendum.Contract_Type__c = 'Addendum';
            Addendum.Opportunity__c = each;
            Addendum.AccountId = mapContrOpp.get(each).AccountId;
            Addendum.Name = 'Website Change Addendum';
            //Addendum.Document_Master__c = (docDetails[0].Name != null) ? docDetails[0].Name : 'Addendum';
            Addendum.Active__c = true;
            Addendum.Document_Category_Name__c = 'Service Agreement';
            Addendum.Document_Type_Name__c = 'Addendum';
            Addendum.Document_Content_Type__c = mapContentType.get('pdf');
            Addendum.StartDate = date.today();
            Addendum.ContractTerm = 120;
            Addendum.KYC_Documentable_Type__c = 'Merchant';
            AddendumList.add(Addendum);
        }
        if(AddendumList != null && AddendumList.size() > 0) {
            Insert AddendumList;
        }
        return AddendumList;
    }  */
    
    public static void deleteWebsitePages(List<opportunity> oppList){
        
        List<Website_Page__c> webpagestoDeleteList = [Select id from Website_Page__c where Opportunity__c IN :oppList];
        delete webpagestoDeleteList;
        
        
    }
}