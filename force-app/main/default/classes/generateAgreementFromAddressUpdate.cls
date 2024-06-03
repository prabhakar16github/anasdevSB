global class generateAgreementFromAddressUpdate implements Queueable,Database.AllowsCallouts{
    
    Set<String> setofAddressId = New Set<String>();
    global generateAgreementFromAddressUpdate(Set<String> addressDetailIds) {
        this.setofAddressId = addressDetailIds;
    }
    global void execute(QueueableContext context) {
        System.debug('address trigger fire');
        Set<String> setofAccId = new Set<String>();
        List<Contract> lstContractUpdate = new List<Contract>();
        
        Map<Id, Address_Details__c> mapAddressDetail = new Map<Id, Address_Details__c>();
        
        Map<String,String> mapofContractWithopport = new Map<String,String>();
        Map<String,List<Contract>> mapAccountwithContract = new Map<String,List<Contract>>();
        
        Map<Id,Contract> mapOfIdContract = new Map<Id,Contract>();
        Map<Id,String> mapofContractWithAgreementVFpage = new Map<Id,String>();
        List<String> lstofAddressId ;
        List<Address_Details__c> lstAddressUpdate = New List<Address_Details__c>();
        
        if(setofAddressId != null && setofAddressId.size() > 0)
            lstofAddressId = new List<String>(setofAddressId);
        if(lstofAddressId != null && lstofAddressId.size() > 0){
            for(Address_Details__c objAddressDetail: Database.Query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Address_Details__c')), ',') + ' FROM Address_Details__c WHERE Id IN (\'' + String.join(new List<String>(lstofAddressId), '\',\'') + '\')')){
                system.debug('====objAddressDetail======='+objAddressDetail);
                if(String.isNotBlank(objAddressDetail.Account__c)){                
                    setofAccId.add(objAddressDetail.Account__c);
                    //mapAddressDetail.put(objAddressDetail.Id, objAddressDetail);
                }
            }
        }
        if(!setofAccId.isEmpty()){
            Boolean register=false;
            Boolean operater=false;
            List<string> lstofAccId = new List<String>(setofAccId);
            for(Address_Details__c objAddressDetail: Database.Query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Address_Details__c')), ',') + ' FROM Address_Details__c WHERE Account__c IN (\'' + String.join(new List<String>(lstofAccId), '\',\'') + '\')')){
                system.debug('====objAddressDetail======='+objAddressDetail);
                if(objAddressDetail.Type__c=='Registered' && objAddressDetail.Status__c==true && objAddressDetail.Active__c==true){                
                    register = true;
                }
                if(objAddressDetail.Type__c=='Operating' && objAddressDetail.Status__c==true && objAddressDetail.Active__c==true){                
                    operater = true;                    
                }
                if(register && operater){
                    mapAddressDetail.put(objAddressDetail.Id, objAddressDetail);
                }
            }
        }            
        system.debug('===mapAddressDetail===='+mapAddressDetail);
        if(!setofAccId.isEmpty()) AddressDetailsTriggerHandler.getAddressFromAccount(setofAccId, mapAccountwithContract,mapofContractWithopport );
        system.debug('====mapOpty====='+mapAccountwithContract);
        if(!mapAddressDetail.isEmpty() && !mapAccountwithContract.isEmpty()){
            for(String eachAddress : mapAddressDetail.keySet()){ 
                system.debug('===='+mapAccountwithContract.get(mapAddressDetail.get(eachAddress).Account__c));
                
                if(String.isNotBlank(mapAddressDetail.get(eachAddress).Account__c) 
                   && mapAccountwithContract.containsKey(mapAddressDetail.get(eachAddress).Account__c)                     
                   && mapAccountwithContract.get(mapAddressDetail.get(eachAddress).Account__c) != null
                   && !mapAccountwithContract.get(mapAddressDetail.get(eachAddress).Account__c).isEmpty())
                {
                    String VfpageName ='';
                    if(mapAddressDetail.get(eachAddress).VFPageKey__c != null && VFPageWithData__c.getValues(mapAddressDetail.get(eachAddress).VFPageKey__c) != null){
                        VfpageName = VFPageWithData__c.getValues(mapAddressDetail.get(eachAddress).VFPageKey__c).VFPageName__c ;
                    }
                    system.debug('=======VfpageName ======'+VfpageName );    
                    for(Contract objContract : mapAccountwithContract.get(mapAddressDetail.get(eachAddress).Account__c)){
                        if((objContract.Status == 'Pending' && VfpageName != '') || Test.isRunningTest()){                                 
                            mapOfIdContract.put(objContract.Id,objContract );
                            mapofContractWithAgreementVFpage.put(objContract.Id,VfpageName);
                            objContract.URL__c ='';
                            objContract.Upload_Date__c = System.today();
                            Break;
                        }
                    }                   
                }                
            }
            System.debug(lstContractUpdate.size()+' <== lstContractInsert ==> '+lstContractUpdate);
        }
        if(!mapOfIdContract.isEmpty()){
            for(Id objId:mapOfIdContract.keySet()){
                system.debug('=objId====='+objId);
                String strEndPoint ='';
                Contract objContract = new Contract();
                objContract = mapOfIdContract.get(objId);
                if(mapofContractWithAgreementVFpage.get(objId) != null ){//&& mapofContractWithopport.get(objId)!= null
                    PageReference pageRef = new PageReference('/apex/' + mapofContractWithAgreementVFpage.get(objId));
                    pageRef.getParameters().put('id', mapofContractWithopport.get(objId));
                    pageRef.getParameters().put('strIsFinal', 'true');
                    pageRef.getParameters().put('eStampNo', String.valueof(objContract.E_Stamp_Number__c));
                    Blob body;
                    
                    if(!Test.isRunningTest()){
                        body = pageRef.getContent();
                        
                        strEndPoint = AWSUtility.uploadAndGetDocUrlS3(objContract, objContract.Account.Identifier__c, body);                
                        system.debug('strEndPoint ************ '+strEndPoint);
                    }
                    if(String.isNotBlank(strEndPoint)){
                        objContract.URL__c = strEndPoint;
                        objContract.Upload_Date__c = System.today();
                        objContract.File_Size__c = String.valueOf(body.size());                    
                        lstContractUpdate.add(objContract);
                    }                
                }
            } 
        }
        System.debug(lstContractUpdate.size()+' <== lstContractInsert ==> '+lstContractUpdate);   
        if(!lstContractUpdate.isEmpty())
            update lstContractUpdate;
    }
    
}