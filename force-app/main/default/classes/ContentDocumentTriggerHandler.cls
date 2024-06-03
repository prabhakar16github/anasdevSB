/*
* Created Date: 6 Sep 2019
* Created By: Akash Pandey
* Description: This class is used to send the Attachment related data to the merchant from the Lightning view.
* */
public class ContentDocumentTriggerHandler {
    public static List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
    public static void getCaseOnInsert(List<ContentDocument> triggerNew){
        try{
            List<Id> attIdList = new List<Id>();
            Set<Id> CaseIdSet = new Set<Id>();
            List<ContentDocument> attachmentList = new List<ContentDocument>();
            List<Id> conDocId = new List<Id>();
            for(ContentDocument ct: triggerNew){
                conDocId.add(ct.Id);
            }
        	//System.debug('conDocId-->'+conDocId);
            //for(ContentDocument ct: triggerNew){
            //System.debug('cdlList-->'+cdlList);
            //if(cdlList.size() == 0){
                 //cdlList = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink Where ContentDocumentId IN: conDocId];
            //}
        	//System.debug('cdlList-->'+cdlList);
                for(ContentDocumentLink cdl: [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink Where ContentDocumentId IN: conDocId]){
                    //System.debug('cdl-->'+cdl);
                    if(cdl.LinkedEntityId != null){
                        Id caseId = cdl.LinkedEntityId;
                        Schema.SObjectType objType = caseId.getSobjectType();
                        String objectType = String.valueOf(objType);
                        //System.debug('InsideForLoop-->');
                        if(objectType == 'Case'){
                            //System.debug('objectType-->'+objectType);
                            attIdList.addAll(conDocId);
                            CaseIdSet.add(cdl.LinkedEntityId);
                        }
                    }
                }
                
                //System.debug('ctList'+ctList);
                
           // }
            //system.debug('attIdList-->'+attIdList);
        	//System.debug('CaseIdSet-->'+CaseIdSet);
            if(attIdList.size() >0){
                preparePayloadForAttachment(conDocId ,CaseIdSet,'CarePanel','');
            }
        }catch(Exception ex){
            system.debug('ERROR:: '+ex.getMessage());
            system.debug('Line No:: '+ex.getLineNumber());
        }
        
    } 
    
    //Testing method Created By Akash
    @Future(Callout=true)
    public static void preparePayloadForAttachment(list<Id> lstAttId, Set<id> CaseIdSet, string devName,string strNotify){
        try{
            List<Case> caseList = new List<Case>();
            //Set<Id> CaseIdSet = new Set<Id>();
            string strPayload = '';
            if(CaseIdSet.size()>0){
                caseList = [SELECT Id,TicketId__c,Failed_Attachment_Count__c ,Status,Parent_Case__c,Parent_Case__r.TicketId__c From Case where Id IN: CaseIdSet AND Parent_Case__c = null];
            }
            // Added by Pooja || Parent_Case__c = null in Where Clause to stop sending attachment to merchant from Child case in C2C cases.
            
            PayloadActMap__mdt objPayload;
            list<LP_HTTP_Publisher__c> lstPub = new list<LP_HTTP_Publisher__c>();
            
            //get payload data from custom metadata which needs to be publish
            map<string,PayloadActMap__mdt> mapOfObjectVsPayload = CareUtility.getPayloadData('MerchantCare');
            if(mapOfObjectVsPayload != NULL && mapOfObjectVsPayload.size()>0 && mapOfObjectVsPayload.containsKey('Attachment'))
                objPayload = mapOfObjectVsPayload.get('Attachment');
            //get Integration settings from custom metadata
            List<Integration_Setting__mdt> insList = [SELECT Id, Body__c, EndPointUrl__c, Headers__c, Method__c 
                                                      FROM Integration_Setting__mdt 
                                                      WHERE DeveloperName =:devName];
            
            //get AccessToken to publish the data in care panel
            string strAccessToken;
            If(!Test.isRunningTest())
                strAccessToken = CarePanelUtility.getAccessToken();
            else
                strAccessToken = '544555';
            //get Case Data
            if(objPayload != NULL && objPayload.Field_To_Query__c != NULL){
                string strquery = 'SELECT '+objPayload.Field_To_Query__c+' FROM ContentDocument WHERE ID IN:lstAttId';
                Map<String, String> mapOfPayloadStructure = (Map<String, String>)JSON.deserialize(objPayload.JSONMapPub__c, Map<String, String>.class);
                for(ContentDocument eachdocument : Database.query(strquery)){
                    System.debug('eachdocument>>>'+eachdocument);
                    if(eachdocument != null){
                        strPayload = prepareRequestBodyForAttachment(caseList,eachdocument,mapOfPayloadStructure);
                    }
                    
                    for(Case eachCase: caseList){
                        if(String.isNotBlank(strPayload)){
                            LP_HTTP_Publisher__c objPub = CarePanelUtility.sendDataToCarePanel(strPayload,eachCase,strAccessToken,insList);
                            //lstPub.add(objPub);
                        }
                    }
                }            
            }
            system.debug('lstPub======='+lstPub);
            //if(lstPub != NULL && lstPub.size()>0)
            //insert lstPub;
        }catch(Exception ex){
            System.debug('Error Message: '+ex.getMessage());
            System.debug('Line No: '+ex.getLineNumber());
        }
    }
    
    public static string prepareRequestBodyForAttachment(List<Case> caseList, ContentDocument objDocument, Map<String, String> mapOfPayload){
        try{
            map<string,object> mapOfPublishPayload = new map<string,object>();
            List<ContentVersion> contentVersionList = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :objDocument.Id];
            if(objDocument != null){
                if(mapOfPayload != NULL && mapOfPayload.size()>0){
                    for(string eachKey : mapOfPayload.keyset()){
                        mapOfPublishPayload.put(eachKey,objDocument.get(mapOfPayload.get(eachKey)));
                        //gen.writeStringField(eachKey, String.valueOf(objAttachment.get(mapOfPayload.get(eachKey))));
                    }
                }
            }
            //Blob blobData = Blob.valueOf(contentVersionList[0].VersionData);
            //System.debug('blobData>>> '+blobData);
            if(contentVersionList[0].VersionData != null){
                mapOfPublishPayload.put('body',EncodingUtil.base64Encode(contentVersionList[0].VersionData));
            }
            
            
            //String jsonstring = JSON.serialize(mapOfPublishPayload);
            //object myObj = jsonstring;
            system.JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('document');
            gen.writeObject(mapOfPublishPayload);
            if(caseList.size() >0){
                if(caseList[0].Status != null){
                    gen.writeStringField('status', caseList[0].Status);
                }
            }
            gen.writeEndObject();
            
            System.debug('gen.getAsString()::: '+gen.getAsString());
            return gen.getAsString();
        }catch(Exception ex){
            System.debug('Error Message:: '+ex.getMessage()+' Line No:: '+ex.getLineNumber());
            return null;
        }
    }
    
    public static void checkSizeAndType(List<ContentDocument> triggerNew){
        try{
            List<RecordType> recordTypeList = [SELECT Id, Name,SobjectType FROM RecordType where SobjectType = 'Case' AND (Name = 'BuyerCare' OR Name = 'BuyerCareChild' OR Name = 'MerchantCare' OR Name = 'MerchantChildCase')];
            List<String> recordTypeNameList = new List<String>();
            for(RecordType eachRecord: recordTypeList){
                recordTypeNameList.add(eachRecord.Id);
            }
            System.debug('recordTypeNameList:: '+recordTypeNameList);
            String fileExtension = Label.OneCare_File_Extention;
            List<String> fileTypes = fileExtension.split(',');
            System.debug('fileTypes:: '+fileTypes);
            Set<Id> contentDocIds = New Set<Id>();
            Map<Id,ContentDocumentLink> cdIdwithLinkMap = New Map<Id,ContentDocumentLink>();
            Set<Id> caseIds = New Set<Id>();
            List<Case> caseList = new List<Case>();
            
            for(ContentDocument cd: triggerNew){
                contentDocIds.add(cd.Id);
            }
            if(contentDocIds.size()>0){
                List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink Where ContentDocumentId IN:contentDocIds];
                if(cdlList.size()>0){
                    for(ContentDocumentLink cdl : cdlList){
                        if(string.isNotBlank(cdl.ContentDocumentId)){
                            cdIdwithLinkMap.put(cdl.ContentDocumentId,cdl);
                            Id objId = cdl.LinkedEntityId;
                            Schema.SObjectType objType = objId.getSobjectType();                         
                            if(string.valueOf(objType)=='Case')
                                caseIds.add(cdl.LinkedEntityId);
                        }
                    }
                    if(caseIds.size()>0){
                        caseList = [Select Id,RecordType.Name,RecordTypeId,Record_Type__c from Case where Id IN:caseIds];
                    }
                    for(ContentDocument cd: triggerNew){
                        //cd.RecordTypeId = recordTypeId;
                        ContentDocumentLink cdlObj = cdIdwithLinkMap.get(cd.Id);
                        if(String.isNotBlank(cdlObj.LinkedEntityId)){                                            
                            Case cs = caseList[0];
                            System.debug('recordTypeContain:: '+recordTypeNameList.contains(cs.RecordTypeId));
                            if(recordTypeNameList.contains(cs.RecordTypeId)){
                                if(cd.ContentSize != null){
                                    if(cd.ContentSize > 5000000){
                                        cd.addError('File size should be less than 5Mb.');
                                    } 
                                }
                                System.debug('FILE TYPE:: '+cd.FileType+' >>'+fileTypes.contains(cd.FileType));
                                if(cd.FileType != null && !fileTypes.contains(cd.FileType)){
                                    cd.addError('Invalid file type. File format should be PNG,JPG,PDF,EXCEL_X,WORD_X,ZIP,EXCEL.');
                                }
                            }
                        }
                        
                    }
                }
            }
        }catch(Exception ex){
            System.debug('Error Message: '+ex.getMessage());
            System.debug('Line No: '+ex.getLineNumber());
        }
        
    }
}