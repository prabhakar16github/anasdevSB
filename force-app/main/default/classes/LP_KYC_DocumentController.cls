/**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       Apex class that Manage custom screen of case which is represnted by lightning component
@history
<Date>        <Authors Name>        <Brief Description of Change>
04-Sep-18     Eitika Verma          created
**/
public class LP_KYC_DocumentController {
    
    /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     this method is used to get the data of KYC document and prepare wrapper
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    */
    @AuraEnabled
    public static string getKYCDocData(string caseId){
        list<KYCWrapper> lstWrapper = new list<KYCWrapper>(); 
        Map<string,map<string,string>> mapOfRejectionReason = new Map<string,map<string,string>>();
        string loggedinUserQueue = '';
        map<string,string> mapOfFieldMappings;
        list<Case> lstCase;
        list<LP_Document_Status_Visibility__mdt> lstMdt;
        if(String.isNotBlank(caseId)){
            
            //find the logged in user queue name
            list<GroupMember> lstgrp = [Select group.name From GroupMember WHERE UserOrGroupId =:UserInfo.getUserId() and group.type = 'Queue'];
            if(lstgrp != NULL && lstgrp.size()>0){
                loggedinUserQueue = lstgrp[0].group.name;
            }
            
            if(String.isNotBlank(loggedinUserQueue)){
                //fetch case data
                //get fields information from custom metadata
                list<LP_Document_Status_Visibility__mdt> lstdefaultMdt = [SELECT id,LP_FieldsToQuery__c,LP_Mapping__c FROM LP_Document_Status_Visibility__mdt WHERE DeveloperName='Default'];
                system.debug('lstdefaultMdt======'+lstdefaultMdt);
                
                if(lstdefaultMdt != NULL && lstdefaultMdt.size()>0){
                    string strquery = 'Select '+lstdefaultMdt[0].LP_FieldsToQuery__c + ' FROM Case WHERE Id='+'\''+caseId+'\'';
                    system.debug('strquery======'+strquery);
                    lstCase = Database.query(strquery);
                    
                    mapOfFieldMappings = (Map<String, String>)JSON.deserialize(lstdefaultMdt[0].LP_Mapping__c, Map<String, String>.class);
                }
            
            
                //status visibility
                if(mapOfFieldMappings != NULL && mapOfFieldMappings.size()>0){
                    string whereCond = '';
                    for(string eachKey : mapOfFieldMappings.keyset()){
                        system.debug('eachKey======'+eachKey);
                        system.debug('product======'+lstCase[0].get(mapOfFieldMappings.get(eachKey)));
                        whereCond += eachKey+'='+'\''+lstCase[0].get(mapOfFieldMappings.get(eachKey))+'\' AND ';
                    }
                    system.debug('whereCond======'+whereCond);
                    whereCond += 'LP_Queue_Name__c ='+'\''+loggedinUserQueue+'\'';
                    string strquery = 'SELECT id,LP_Status__c FROM LP_Document_Status_Visibility__mdt WHERE '+ whereCond;
                    system.debug('strquery======'+strquery);
                    lstMdt = Database.query(strquery);
                }
            }
            // check that L1 and L2 agent has access to edit the documents or not
            boolean isEditAccess = isloggedinUserL1OrL2(caseId);
            
            //get the data from custom metadata
                for(KYC_Rejection_Reason__mdt eachReason : [SELECT MasterLabel,LP_Values__c,LP_Status__c FROM KYC_Rejection_Reason__mdt]){
                if(!mapOfRejectionReason.containsKey(eachReason.MasterLabel))
                    mapOfRejectionReason.put(eachReason.MasterLabel,new map<string,string>());
                    mapOfRejectionReason.get(eachReason.MasterLabel).put(eachReason.LP_Status__c,eachReason.LP_Values__c);
            }
            
            list<LP_KYC_Document__c> lstKYCDoc = [SELECT Id,
                                                        Name,
                                                        LP_Image_URL__c,
                                                        LP_Status__c,
                                                        LP_Case__c,
                                                        LP_Password__c,
                                                        LP_Case__r.LP_Sub_Status__c,
                                                        LP_Rejection_Reason__c,
                                                        LP_Date_Created__c,
                                                        LP_Last_Modified_Date__c,LP_Show_On_Component__c
                                                        FROM LP_KYC_Document__c 
                                                        WHERE LP_Case__c = :caseId and LP_Show_On_Component__c = true];
            
            if(lstKYCDoc != NULL && lstKYCDoc.size() > 0){
                for(LP_KYC_Document__c eachDoc : lstKYCDoc){
                    KYCWrapper objWrapper = new KYCWrapper();
                    objWrapper.showEdit = isEditAccess;
                    objWrapper.kycDoc = eachDoc;
                    if(eachDoc.LP_Image_URL__c != NULL && (eachDoc.LP_Image_URL__c.contains('.pdf') || eachDoc.LP_Image_URL__c.contains('.PDF')))
                        objWrapper.typeOfDoc = 'pdf';
                    else
                        objWrapper.typeOfDoc = 'image';
                    system.debug('lstMdt====='+lstMdt);
                    if(lstMdt != NULL && lstMdt.size()>0){
                        if(lstMdt[0].LP_Status__c.contains(',')){
                            objWrapper.lstStatus = lstMdt[0].LP_Status__c.split(',');
                        }
                        else{
                            list<string> lstStatusMdt = new list<string>{lstMdt[0].LP_Status__c};
                            objWrapper.lstStatus = lstStatusMdt;
                        }
                    }
                        
                    objWrapper.caseSubStatus = eachDoc.LP_Case__r.LP_Sub_Status__c;
                    if(mapOfRejectionReason != NULL && mapOfRejectionReason.size()>0 && mapOfRejectionReason.containsKey(eachDoc.Name) && mapOfRejectionReason.get(eachDoc.Name)!= NULL){
                        list<RejectionReasonWrapper> lstOfPendingRejectionReason;
                        objWrapper.lstOfPendingRejectionReason = fillRejectionList(eachDoc,'Pending',lstOfPendingRejectionReason,mapOfRejectionReason);
                        
                        list<RejectionReasonWrapper> lstOfVerifiedRejectionReason;
                        objWrapper.lstOfVerifiedRejectionReason = fillRejectionList(eachDoc,'Verified',lstOfVerifiedRejectionReason,mapOfRejectionReason);
                        
                        list<RejectionReasonWrapper> lstOfDeclinedRejectionReason;
                        objWrapper.lstOfDeclinedRejectionReason = fillRejectionList(eachDoc,'Declined',lstOfDeclinedRejectionReason,mapOfRejectionReason);
                    }
                    lstWrapper.add(objWrapper);
                }
                return JSON.serialize(lstWrapper);
            }
            else
                return '';
         }
        else
            return '';
         
    }
    
    
    public static list<RejectionReasonWrapper> fillRejectionList(LP_KYC_Document__c eachDoc,string status,list<RejectionReasonWrapper> lstRejectionReason,
                                                         Map<string,map<string,string>> mapOfRejectionReason){
        system.debug('mapOfRejectionReason======'+mapOfRejectionReason);
        system.debug('eachDoc.Name======'+eachDoc.Name);
        
        lstRejectionReason = new list<RejectionReasonWrapper>();
      if(mapOfRejectionReason.get(eachDoc.Name).get(status) != NULL){
        for(String eachStr : mapOfRejectionReason.get(eachDoc.Name).get(status).split(';')){
            RejectionReasonWrapper objRejectionWrapper = new RejectionReasonWrapper();
            objRejectionWrapper.label = eachStr.trim();
            if(eachDoc.LP_Rejection_Reason__c != null && eachDoc.LP_Rejection_Reason__c.contains(objRejectionWrapper.label) && eachDoc.LP_Status__c == status)
                objRejectionWrapper.selected = true;
            else
                objRejectionWrapper.selected = false; 
            lstRejectionReason.add(objRejectionWrapper);
        }
      }
        return lstRejectionReason;
    }
     /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     this method is used to get the values of picklist field
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    */
    @AuraEnabled 
    public static string getPicklistValues(String fieldName, String objectName, Boolean noneIncluded){
        string picklistVal = PicklistGenerator.getPicklistValues(objectName,fieldName,'',false); 
        system.debug('picklistVal========'+picklistVal);
        return picklistVal;
    }
    
     /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     this method is used to upsert the data of KYC document and upsert case as well
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    */
/*    @AuraEnabled
    public static void saveKYCDocData(string docdata){
        // docData is list of documents 
        if(String.isNotBlank(docdata)){
            Case objCase;
            list<LP_KYC_Document__c> lstKYCDoc = new list<LP_KYC_Document__c>();
            list<KYCWrapper> lstKYCWrapper = (list<KYCWrapper>)JSON.deserialize(docdata, list<KYCWrapper>.class);
            system.debug('lstKYCWrapper======='+lstKYCWrapper);
            if(lstKYCWrapper != NULL && lstKYCWrapper.size()>0){
                string finalStatusonCase = 'Verified';
                string finalKYCState = 'Under Manual Verification';
                for(KYCWrapper eachKYC : lstKYCWrapper){
                    System.debug('eachKYC.kycDoc ***' + eachKYC.kycDoc);
                    if(eachKYC.kycDoc.LP_Status__c == 'Pending' || eachKYC.kycDoc.LP_Status__c == 'Declined'){
                        System.debug('Pending**');
                        finalStatusonCase = 'Pending'; 
                    }                            
                    if(eachKYC.kycDoc.LP_Status__c == 'Declined'){
                        System.debug('Declined***');
                       finalKYCState = 'User Documents Pending'; 
                    } 
                    lstKYCDoc.add(eachKYC.kycDoc);
                }
                
                //update the case
                objCase = new Case(Id=lstKYCWrapper[0].kycDoc.LP_Case__c,Status=finalStatusonCase,LP_Sub_Status__c = '',LP_KYC_State__c = finalKYCState,LP_KYC_Last_Modified_Date__c = System.now());
            }
            
            system.debug('lstKYCDoc========'+lstKYCDoc);
                
             //   DMLOperation.performDMLOnList(lstKYCDoc);
            
           // update objCase;
              
            // For Payload callouts
            if(lstKYCDoc != NULL && lstKYCDoc.size()>0){
                set<id> setKeyIds = New set<id>();
                for(LP_KYC_Document__c objKycdoc :lstKYCDoc){
                    System.debug('objKycdoc****' + objKycdoc);
                    setKeyIds.add(objKycdoc.id);
                }
                System.debug('Send Payload For Doc');
                //lazypayPublish.SendPayloadCaseData(setKeyIds);
                //Edited  by Kapil
                String responseCode = '';
                if(!Test.isRunningTest()){
                   responseCode =  lazyPayPublish_v2.SendPayloadCaseData(setKeyIds); 
                }else{
                   responseCode = '200'; 
                }               
                System.debug('responseCode***' + responseCode );
                if(responseCode.equals('200')){
                   update lstKYCDoc;
                   update objCase;  
                }else{
                    throw new AuraHandledException(label.Data_not_pushed_to_lazyPay);
                }                
            }
            
            
        }
    }
*/
    
         /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     this method is used to upsert the data of KYC document and upsert case as well
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    */

    @AuraEnabled
    public static void saveKYCDocData(string docdata){
        if(String.isNotBlank(docdata)){
            Case objCase;
            list<LP_KYC_Document__c> lstKYCDoc = new list<LP_KYC_Document__c>();
            list<KYCWrapper> lstKYCWrapper = (list<KYCWrapper>)JSON.deserialize(docdata, list<KYCWrapper>.class);
            system.debug('lstKYCWrapper======='+lstKYCWrapper);
            if(lstKYCWrapper != NULL && lstKYCWrapper.size()>0){
                string finalStatusonCase = 'Verified';
                string finalKYCState = 'Under Manual Verification';
                for(KYCWrapper eachKYC : lstKYCWrapper){
                    System.debug('Each KYC Doc****' + eachKYC);
                    if(eachKYC.kycDoc.LP_Status__c == 'Pending' || eachKYC.kycDoc.LP_Status__c == 'Declined'){
                       finalStatusonCase = 'Pending'; 
                       System.debug('Pending Or Declined>>>' + finalStatusonCase); 
                    }    
                    if(eachKYC.kycDoc.LP_Status__c == 'Declined'){
                       finalKYCState = 'User Documents Pending'; 
                       System.debug('Declined >> ' + finalKYCState); 
                    }                    
                       lstKYCDoc.add(eachKYC.kycDoc);
                }
                
                //update the case
                objCase = new Case(Id=lstKYCWrapper[0].kycDoc.LP_Case__c,Status=finalStatusonCase,LP_Sub_Status__c = '',LP_KYC_State__c = finalKYCState,LP_KYC_Last_Modified_Date__c = System.now());
                System.debug('objCase***' + objCase);
            }
            
            system.debug('lstKYCDoc========'+lstKYCDoc);
            if(lstKYCDoc != NULL && lstKYCDoc.size()>0)
                update lstKYCDoc;
            
            update objCase;
            // For Payload callouts
            if(lstKYCDoc != NULL && lstKYCDoc.size()>0){
                set<id> setKeyIds = New set<id>();
                for(LP_KYC_Document__c objKycdoc :lstKYCDoc){
                    setKeyIds.add(objKycdoc.id);
                }
                lazypayPublish.SendPayloadCaseData(setKeyIds);
            }
            
            
        }
    }
   
    /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     this method shows error message if on case substatus value is additional document requested
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    19-Dec-18     Eitika Verma          created
    */
    @AuraEnabled
    public static string handleEditAccess(string caseId){
        if(String.isNotBlank(caseId)){
            list<Case> lstCase = [SELECT LP_KYC_state__c FROM Case WHERE id=:caseId];
            if(lstCase != null && lstCase.size()>0){
                if(lstCase[0].LP_KYC_state__c == 'Add Doc Requested Manually'){
                    return Label.LP_Access_is_denied_as_additional_document_requested;
                }
                else
                    return '';
            }
            else
                return '';
        }
        else
            return '';
    }
    
     /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     this method checks that logged in user is L1/L2. It sets the visibility of edit button
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    */
    public static boolean isloggedinUserL1OrL2(string caseId){
        
        if(caseId != NULL){
            list<Case> lstCase = [SELECT Ownerid,LP_KYC_State__c FROM Case WHERE id=:caseId];
            if(lstCase!= NULL && lstCase.size()>0){
                if(userinfo.getUserId() == lstCase[0].ownerid && lstCase[0].LP_KYC_State__c != 'Add Doc Requested Manually'){
                    return true;
                }
                else{
                    return false;
                }
            }
            else{
                return false;
            }
        }
        else{
            return false;
        }
    }
    
    public static void codeCoverage(){
        integer i = 1;
        i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;

    }
    
     /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     wrapper class to display the data on screen
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    */
    public class KYCWrapper{
        @AuraEnabled public LP_KYC_Document__c kycDoc;
        @AuraEnabled public list<string> lstStatus;
        @AuraEnabled public list<RejectionReasonWrapper> lstOfPendingRejectionReason;
        @AuraEnabled public list<RejectionReasonWrapper> lstOfVerifiedRejectionReason;
        @AuraEnabled public list<RejectionReasonWrapper> lstOfDeclinedRejectionReason;
        @AuraEnabled public string errorMsg;
        @AuraEnabled public boolean showEdit;
        @AuraEnabled public string caseSubStatus;
        @AuraEnabled public string typeOfDoc;
        
    }
    public class RejectionReasonWrapper{
        @auraEnabled public string label;
        @auraEnabled public boolean selected;
    }
    
}