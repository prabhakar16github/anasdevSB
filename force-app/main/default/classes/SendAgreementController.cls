// =================== Used for "SendDraftAgreement" and "SendFinalAgreement" Component =====================
public class SendAgreementController {
    /*--------------------------------------------------------------------------------------------------------
Description:    method to get the Opportunity records and list of contracts records under the opp 
---------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static WrapperSendAgreement getOpportunityRecord(Id oppId, Boolean isFinal){
        if(String.isNotBlank(oppId)){
            //Remove later - just for testing
            
            /*List<Opportunity> oppList = [SELECT Id, Has_Customized_Rates__c FROM Opportunity WHERE Has_Customized_Rates__c = TRUE];
            getCustomizedRates(oppList);*/
            
            // - End testing
            
            List<Document_Master__c> lstDocMasterAddendum = new  List<Document_Master__c>();
            List<Document_Master__c> lstDocMasterAgreement = new List<Document_Master__c>();
            List<Document_Master__c> lstDocMasterPayoutAgreement = new List<Document_Master__c>();
            List<E_Stamp_Master__c> lstEStampMaster = new List<E_Stamp_Master__c>();
            List<Document_Type_Master__c> lstDocTypeAddendum = New List<Document_Type_Master__c>();
            WrapperSendAgreement clsWrapperSendAgreement =  new WrapperSendAgreement();
            
            List<Cross_Sell__c> crossSellList = New List<Cross_Sell__c>();
            List<Fee_Master__c> feeMasterList = New List<Fee_Master__c>();
            
            clsWrapperSendAgreement.oppObj = getOpportunity(oppId);
            
            if(clsWrapperSendAgreement.oppObj.E_Stamp__c == null){
                list<Contract> contrct =[select id,E_Stamp__c from Contract where 
                                         AccountId=:clsWrapperSendAgreement.oppObj.accountid AND E_Stamp__c != null 
                                         AND Contract_Type__c='Agreement'];
                String accountid=clsWrapperSendAgreement.oppObj.accountid ;
                
                if(contrct.size()== 0){ 
                    lstEStampMaster = getEStampMaster();
                    system.debug(lstEStampMaster.size()+' %%%%%%%%% lstEStampMaster ============= '+lstEStampMaster);
                    
                    if(!lstEStampMaster.isEmpty()){
                        E_Stamp_Master__c newEstampObj = lstEStampMaster[0];
                        clsWrapperSendAgreement.oppObj.E_Stamp__c = newEstampObj.Id;
                        
                        E_Stamp_Master__c estampObj = new E_Stamp_Master__c(Id=newEstampObj.Id, Used__c = true);
                        
                        update clsWrapperSendAgreement.oppObj; 
                        update estampObj;
                        
                        clsWrapperSendAgreement.oppObj = getOpportunity(oppId);
                    } 
                }
                else{
                    system.debug('Inside else Prashant');
                    SendAgreementController.getEStampid(accountid,clsWrapperSendAgreement.oppObj,contrct[0].E_Stamp__c);
                }
            }
            
            clsWrapperSendAgreement.accObj = getAccount(clsWrapperSendAgreement.oppObj.AccountId);
            
            clsWrapperSendAgreement.authSignContact = (clsWrapperSendAgreement.accObj.Contacts != null && !clsWrapperSendAgreement.accObj.Contacts.isEmpty()) ? clsWrapperSendAgreement.accObj.Contacts[0] : null;
            
            if(String.isNotBlank(clsWrapperSendAgreement.accObj.RecordTypeId) 
               && clsWrapperSendAgreement.accObj.RecordType.DeveloperName.equalsIgnoreCase('Support_Account') 
               && String.isNotBlank(clsWrapperSendAgreement.accObj.ParentId))
            {
                clsWrapperSendAgreement.authSignContact = getParentAcntContactRec(clsWrapperSendAgreement.accObj.ParentId)[0];                
            }
            
            clsWrapperSendAgreement.isSendingMail = false;
            System.debug('Identifier__c>>'+clsWrapperSendAgreement.oppObj.Partner__r.Identifier__c);
            // get document master
            getDocumentMaster(lstDocMasterAddendum, lstDocMasterAgreement,lstDocMasterPayoutAgreement);
            // get document types for addendum
            lstDocTypeAddendum= getDocTypeForAddendum();
            
            clsWrapperSendAgreement.lstDocMasterAddendum = (!lstDocMasterAddendum.isEmpty()) ? lstDocMasterAddendum : null;
            
            clsWrapperSendAgreement.lstDocMasterAgreement = getAgreementDocMaster(clsWrapperSendAgreement.accObj, clsWrapperSendAgreement.oppObj, lstDocMasterAgreement);
            // Upadated for addendum
            clsWrapperSendAgreement.lstDocTypeAddendum = (!lstDocTypeAddendum.isEmpty()) ? lstDocTypeAddendum : null;
            // Updated for payout
            
            clsWrapperSendAgreement.lstDocMasterPayoutAgreement = getPayoutAgreementDocMaster(clsWrapperSendAgreement.accObj, clsWrapperSendAgreement.oppObj, lstDocMasterPayoutAgreement);
            System.debug('######## lstDocMasterPayoutAgreement '+clsWrapperSendAgreement.lstDocMasterPayoutAgreement);
            
            Map<String, List<Contract>> mapStrTypeVsLstContract = new Map<String, List<Contract>>();
            Map<String, List<Contract>> mapStatusTypeVsLstContract = new Map<String, List<Contract>>();
            clsWrapperSendAgreement.optyRelatedContract = null;
            // update for Payout
            Map<String, List<Contract>> mapStrTypeVsLstPayoutContract = new Map<String, List<Contract>>();
            Map<String, List<Contract>> mapStatusTypeVsLstPayoutContract = new Map<String, List<Contract>>();
            clsWrapperSendAgreement.optyRelatedPayoutContract = null;
            
            // update for Payout==================start=======================
            crossSellList = getCrossSell(oppId);
            clsWrapperSendAgreement.lstCrossSell = !crossSellList.isEmpty() ? crossSellList : null;
            if(!crossSellList.isEmpty()) feeMasterList = crossSellForMerchant_Controller.getFeeMasters(crossSellList);
            clsWrapperSendAgreement.lstFeeMaster = !feeMasterList.isEmpty() ? feeMasterList : null;
            // update for Payout==================end=======================
            
            if(clsWrapperSendAgreement.accObj.Contracts != null && !clsWrapperSendAgreement.accObj.Contracts.isEmpty()){
                system.debug(clsWrapperSendAgreement.accObj.Contracts +' ************ ');
                for(Contract contObj : clsWrapperSendAgreement.accObj.Contracts){
                    if(contObj.Type__c == 'Draft' && contObj.Contract_Type__c=='Agreement'){
                        if(mapStrTypeVsLstContract.containsKey('Draft')){
                            mapStrTypeVsLstContract.get('Draft').add(contObj);
                        }else{
                            mapStrTypeVsLstContract.put('Draft', new List<Contract>{ contObj });
                        }
                    }
                    
                    if(contObj.Type__c == 'Final' && contObj.Contract_Type__c=='Agreement'){
                        if(mapStrTypeVsLstContract.containsKey('Final')){
                            mapStrTypeVsLstContract.get('Final').add(contObj);
                        }else{
                            mapStrTypeVsLstContract.put('Final', new List<Contract>{ contObj });
                        }
                        
                        // ===== For Approved Status ============
                        if(contObj.Status == 'Approved' && mapStatusTypeVsLstContract.containsKey('Approved')){
                            mapStatusTypeVsLstContract.get('Approved').add(contObj);
                        }else if(contObj.Status == 'Approved' && !mapStatusTypeVsLstContract.containsKey('Approved')){
                            mapStatusTypeVsLstContract.put('Approved', new List<Contract>{ contObj });
                        }
                        
                        // ===== For Sent (Pending) Status ============
                        if(contObj.Status == 'Pending' && mapStatusTypeVsLstContract.containsKey('Pending')){
                            mapStatusTypeVsLstContract.get('Pending').add(contObj);
                        }else if(contObj.Status == 'Pending' && !mapStatusTypeVsLstContract.containsKey('Pending')){
                            mapStatusTypeVsLstContract.put('Pending', new List<Contract>{ contObj });
                        }
                        
                        // ===== For Counter Signed Received Status ============
                        if(contObj.Status == 'Counter Signed Received' && mapStatusTypeVsLstContract.containsKey('Counter Signed Received')){
                            mapStatusTypeVsLstContract.get('Counter Signed Received').add(contObj);
                        }else if(contObj.Status == 'Counter Signed Received' && !mapStatusTypeVsLstContract.containsKey('Counter Signed Received')){
                            mapStatusTypeVsLstContract.put('Counter Signed Received', new List<Contract>{ contObj });
                        }
                        
                        // ===== For Declined Status ============
                        if(contObj.Status == 'Declined' && mapStatusTypeVsLstContract.containsKey('Declined')){
                            mapStatusTypeVsLstContract.get('Declined').add(contObj);
                        }else if(contObj.Status == 'Declined' && !mapStatusTypeVsLstContract.containsKey('Declined')){
                            mapStatusTypeVsLstContract.put('Declined', new List<Contract>{ contObj });
                        }
                    }
                    
                    // ===========upated for Payout===================
                    
                    if(contObj.Type__c == 'Draft' && contObj.Contract_Type__c=='PayoutAgreement' && contObj.Opportunity__c == oppId){
                        if(mapStrTypeVsLstPayoutContract.containsKey('Draft')){
                            mapStrTypeVsLstPayoutContract.get('Draft').add(contObj);
                        }else{
                            mapStrTypeVsLstPayoutContract.put('Draft', new List<Contract>{ contObj });
                        }
                    }
                    
                    if(contObj.Type__c == 'Final' && contObj.Contract_Type__c=='PayoutAgreement' && contObj.Opportunity__c == oppId){
                        if(mapStrTypeVsLstPayoutContract.containsKey('Final')){
                            mapStrTypeVsLstPayoutContract.get('Final').add(contObj);
                        }else{
                            mapStrTypeVsLstPayoutContract.put('Final', new List<Contract>{ contObj });
                        }
                        
                        // ===== For Sent (Pending) Status ============
                        if(contObj.Status == 'Pending' && mapStatusTypeVsLstPayoutContract.containsKey('Pending')){
                            mapStatusTypeVsLstPayoutContract.get('Pending').add(contObj);
                        }else if(contObj.Status == 'Pending' && !mapStatusTypeVsLstPayoutContract.containsKey('Pending')){
                            mapStatusTypeVsLstPayoutContract.put('Pending', new List<Contract>{ contObj });
                        }
                        
                        // ===== For Approved Status ============
                        if(contObj.Status == 'Approved' && mapStatusTypeVsLstPayoutContract.containsKey('Approved')){
                            mapStatusTypeVsLstPayoutContract.get('Approved').add(contObj);
                        }else if(contObj.Status == 'Approved' && !mapStatusTypeVsLstPayoutContract.containsKey('Approved')){
                            mapStatusTypeVsLstPayoutContract.put('Approved', new List<Contract>{ contObj });
                        }
                                                
                    }
                    //======================= Final payout end===========
                }
                system.debug(mapStrTypeVsLstContract.size()+' #### mapStrTypeVsLstContract &&&&&& '+mapStrTypeVsLstContract);
                system.debug(mapStatusTypeVsLstContract.size()+' #### mapStatusTypeVsLstContract &&&&&& '+mapStatusTypeVsLstContract);
                
                if(!isFinal && !mapStrTypeVsLstContract.isEmpty() && mapStrTypeVsLstContract.containsKey('Draft')){                    
                    clsWrapperSendAgreement.optyRelatedContract = mapStrTypeVsLstContract.get('Draft')[0];
                } else if(isFinal && !mapStrTypeVsLstContract.isEmpty() && mapStrTypeVsLstContract.containsKey('Final')){                    
                    // commented the below code because no need to check the Approved case    ==> date : feb.26, 2019
                    //if(!mapStatusTypeVsLstContract.isEmpty() && !mapStatusTypeVsLstContract.containsKey('Approved') && mapStatusTypeVsLstContract.containsKey('Pending')){                    
                    
                    if(!mapStatusTypeVsLstContract.isEmpty() && mapStatusTypeVsLstContract.containsKey('Pending')){
                        clsWrapperSendAgreement.optyRelatedContract = mapStatusTypeVsLstContract.get('Pending')[0];
                        
                        if(mapStatusTypeVsLstContract.containsKey('Counter Signed Received')){
                            clsWrapperSendAgreement.counterSignedContract = mapStatusTypeVsLstContract.get('Counter Signed Received')[0];
                        }
                        else if(mapStatusTypeVsLstContract.containsKey('Declined')){
                            clsWrapperSendAgreement.counterSignedContract = mapStatusTypeVsLstContract.get('Declined')[0];
                        }
                    }                    
                    system.debug('==========clsWrapperSendAgreement========'+clsWrapperSendAgreement);
                } 
                system.debug(clsWrapperSendAgreement.isContractAvail +' ************ '+ clsWrapperSendAgreement.optyRelatedContract);
                
                // ==========updated for Payout============================
                if(!isFinal && !mapStrTypeVsLstPayoutContract.isEmpty() && mapStrTypeVsLstPayoutContract.containsKey('Draft')){                    
                    clsWrapperSendAgreement.optyRelatedPayoutContract = mapStrTypeVsLstPayoutContract.get('Draft')[0];
                } else if(isFinal && !mapStrTypeVsLstPayoutContract.isEmpty() && mapStrTypeVsLstPayoutContract.containsKey('Final')){                    
                    
                    if(!mapStatusTypeVsLstPayoutContract.isEmpty() && mapStatusTypeVsLstPayoutContract.containsKey('Pending')){
                        clsWrapperSendAgreement.optyRelatedPayoutContract = mapStatusTypeVsLstPayoutContract.get('Pending')[0];                        
                    } 
                }
                //================updated for Payout end==============
            }
            
            return clsWrapperSendAgreement;
        }
        return null;
    }
    
    @AuraEnabled
    public static Contract createContract(Account accObj, Contact authContObj, Boolean isFinal, Opportunity optyObj,string contractType){
        Contract contractObj = new Contract();
        system.debug('optyObj ==> '+optyObj);
        if(!isFinal){
            createNewContRec(accObj.Id, contractObj, authContObj, 'Draft Sent', 'Draft', optyObj,contractType);  
        }else{
            createNewContRec(accObj.Id, contractObj, authContObj, 'Pending', 'Final', optyObj,contractType);
        }       
        upsert contractObj;
        return contractObj;
        
    }
    
    @AuraEnabled
    public static String sendMailWithAttachment(Opportunity optyObj, Contact contObj, String strSelectedDocMaster, Id uploadedDocumentId, Boolean isFinal, Contract contractObject, String ContractType, Boolean isSendMail, Contract objCounterSign){   // Contract contractObj
        ContentVersion contentVersionObj = new ContentVersion();
        Document_Master__c docMasterObj = new Document_Master__c ();
        List<E_Stamp_Master__c> lstEStampMaster = new List<E_Stamp_Master__c>();
        String strFileExtensionType = '';
        system.debug('uploadedDocumentId ====>>> '+uploadedDocumentId);
        system.debug('contractObject &&&&&&&>>> '+contractObject);
        system.debug('strSelectedDocMaster &&&&&&&>>> '+strSelectedDocMaster);
        
        // ================== Build at Dec.26, 2018 ========================
        Contract oldContractObj = new Contract();
        if(isFinal && contractObject.Status != 'Approved' && String.isNotBlank(contractObject.URL__c) 
           && String.isNotBlank(contractObject.Document_Category__c) && String.isNotBlank(strSelectedDocMaster) 
           && String.isBlank(uploadedDocumentId)){             
            Contract newContractObj = new Contract();
            if(contractObject.status == 'Pending'){
                if(objCounterSign != null && String.isNotBlank(objCounterSign.Id)){                 
                    oldContractObj = objCounterSign;
                }
                newContractObj = contractObject;
                createNewContRec(optyObj.AccountId,newContractObj , contObj, 'Pending', 'Final', optyObj,ContractType);
                newContractObj.Document_Content_Type__c = 'application/pdf';
                newContractObj.Active__c = false;
                contractObject = newContractObj;
            }
        }
        system.debug('contractObject ###########>>> '+contractObject);
        // =================================================================        
        
        // =========== get Document Master detail =============================
        if(String.isNotBlank(strSelectedDocMaster)){
            docMasterObj = getDocumentMasterRec(strSelectedDocMaster);
        }   
        system.debug('docMasterObj ============= '+docMasterObj);
        
        // =========== get the list of E Stamp Master recordbased on E Stamp number in Ascending order and Active is true and used is false and 
        //lstEStampMaster = getEStampMaster();    // Commented by Uma Shankar at Feb.27, 2019        
        lstEStampMaster.add(new E_Stamp_Master__c(Id=optyObj.E_Stamp__c, EStamp_Number__c=optyObj.E_Stamp_Number__c));        
        system.debug(lstEStampMaster.size()+' %%%%%%%%% lstEStampMaster ============= '+lstEStampMaster);
        
        if(contObj == null){
            return URL.getSalesforceBaseUrl().toExternalForm() + '/apex/' + docMasterObj.Page_Association__c + '?Id=' + optyObj.Id + '&strIsFinal=' + String.valueof(isFinal) + '&eStampNo=' + optyObj.E_Stamp_Number__c;
        }
        
        if(String.isNotBlank(uploadedDocumentId)){            
            contentVersionObj = getcontentVersion(uploadedDocumentId);            
            if(contentVersionObj.ContentDocument.ContentSize > 5000000) return 'File_Size_5_MB';//ERROR: '+ contentVersionObj.Title +' file is more than 5 MB.';
            strFileExtensionType = (contentVersionObj.FileType == 'WORD') ? '.doc' : '.pdf'; 
        }
        system.debug('contentVersionObj @@@@@@@@ '+contentVersionObj);
        
        // ============ get the "Biz_Introduction_Template_With_MAF" email templates ==========
        List<EmailTemplate> listEmailTemplateObj = new List<EmailTemplate>();            
        
        if(isSendMail){
            if(ContractType == 'Agreement'){
            	if(!isFinal)    listEmailTemplateObj = DatabaseUtility.getEmailTemplate('Agreement_Email_Template_Draft');
            
            	if(isFinal)     listEmailTemplateObj = DatabaseUtility.getEmailTemplate('Agreement_Email_Template');
            	system.debug(listEmailTemplateObj.size()+' ^^^^^^^^^^^^^^ listEmailTemplateObj ============= '+listEmailTemplateObj);
            }else if(ContractType == 'PayoutAgreement'){
                if(isFinal)     listEmailTemplateObj = DatabaseUtility.getEmailTemplate('Payout_Agreement_Email_Template');
            }
            if(listEmailTemplateObj == null || listEmailTemplateObj.isEmpty()){
                return 'No_Template';
            }
        }
        
        List<Attachment> lstAttachment = new List<Attachment>();
        
        // get the list of attachment when contract is not exist
        if(String.isNotBlank(docMasterObj.Page_Association__c) && String.isBlank(uploadedDocumentId)){
            if(contractObject != null && contractObject.E_Stamp__c != null){
                E_Stamp_Master__c objEStamp = new E_Stamp_Master__c();
                objEStamp.Id = contractObject.E_Stamp__c;
                objEStamp.EStamp_Number__c = contractObject.E_Stamp_Number__c;
                createPageReference(optyObj, lstAttachment, docMasterObj, isFinal, new List<E_Stamp_Master__c>{objEStamp});
            }
            else
                createPageReference(optyObj, lstAttachment, docMasterObj, isFinal, lstEStampMaster);
        } 
        
        // get the list of attachment when contract is exist
        if(String.isNotBlank(contentVersionObj.Id) && String.isNotBlank(uploadedDocumentId)){
            createListAttachment(optyObj.Id, lstAttachment, contentVersionObj.title, contentVersionObj.VersionData, strFileExtensionType);       
        }        
        system.debug(lstAttachment.size()+' !!!!!!!!!!!! lstAttachment ============= '+lstAttachment);
        
        if(!lstAttachment.isEmpty()) {
            // ======= Call API method ===================
            if(isFinal){                        
                Map<String, String> mapContentType = (Map<String, String>) json.deserialize(Label.ContentTypeBasedOnFileType, Map<String, String>.class);
                updateContractRecord(ContractObject, docMasterObj, lstEStampMaster, contentVersionObj, ContractType);
                system.debug('!!ContractObject ============= '+ContractObject);
                try{
                    if(String.isNotBlank(strSelectedDocMaster) && String.isBlank(uploadedDocumentId)){
                        system.debug('First case =======');
                        sendDocumentToAWS(ContractObject, optyObj, uploadedDocumentId, lstAttachment, contentVersionObj);                       
                    }else if(String.isNotBlank(uploadedDocumentId)){
                        system.debug('Second case =======');
                        sendDocumentToAWS(ContractObject, optyObj, uploadedDocumentId, null, contentVersionObj);
                    }                    
                }catch(DMLException ex){
                    return ex.getMessage();
                }
            }
            
            // =========== Send mail with attach Document and sending mail allow from the page ===================
            if(isSendMail){
                String orgWideEmailAdd = Label.Organization_Wide_Email_Address;
                Id orgWideEmailAddId = null;
                List<OrgWideEmailAddress> lstOrgWideEmailAddress = new List<OrgWideEmailAddress>();
                if(String.isNotBlank(orgWideEmailAdd)) lstOrgWideEmailAddress = [select Id from OrgWideEmailAddress where DisplayName =: orgWideEmailAdd];
                if(!lstOrgWideEmailAddress.isEmpty()) orgWideEmailAddId = lstOrgWideEmailAddress[0].Id;                
                List<Messaging.SendEmailResult> listSendEmailResult = new List<Messaging.SendEmailResult>();
                string accountOwnerEmail = optyObj.Account.OwnerId != Label.IntegrationUserId ? optyObj.Account.Owner.Email : '';
                System.debug('351 contObj.Email'+contObj.Email+'Contname'+contObj.Name+'lstAttachment'+lstAttachment+'optyObj.Owner.Email'+optyObj.Owner.Email+'accountOwnerEmail'+accountOwnerEmail);
                listSendEmailResult = SystemUtility.sendEmailWithUpdateBody(contObj.Name, contObj.Email, listEmailTemplateObj[0], lstAttachment, optyObj.Owner.Name, optyObj.Owner.Email, accountOwnerEmail, orgWideEmailAddId, true);
                system.debug(listSendEmailResult.size()+' :::::::: listSendEmailResult &&&&&&&&&&&& '+listSendEmailResult);
                if(listSendEmailResult.size()>0){
                    if(!listSendEmailResult[0].isSuccess()){
                        list<Messaging.SendEmailError> listSendEmailError = listSendEmailResult[0].getErrors();
                        system.debug(listSendEmailError.size()+' @@@@@@@@@@ listSendEmailError $$$$$$$$$$$$ '+listSendEmailError);
                        return 'ERROR: '+listSendEmailError;
                    }
                }
            }   
            
            if(String.isBlank(strSelectedDocMaster) && !isFinal){
                return 'Agreement_Sent';
            }
            
            // ======= update the Contract ===============================
            if(!isFinal){ 
                system.debug('Draft ++++++++++ ');
                try{                            
                    updateContractRecord(ContractObject, docMasterObj, null, contentVersionObj, ContractType);
                    update ContractObject;   
                    system.debug('ContractObject Draft------------------ '+ContractObject);
                    
                    lstAttachment[0].ParentId = ContractObject.Id;
                    insert lstAttachment;
                    
                    return 'Agreement_Sent';
                }catch(DMLException ex){
                    return ex.getMessage();
                }
            }
            if(isFinal){                        
                system.debug('Final ++++++++++ ');                    
                try{
                    upsert ContractObject;   
                    system.debug('ContractObject Final------------------ '+ContractObject);
                    if(String.isNotBlank(oldContractObj.Id)){
                        oldContractObj.Active__c = false;
                        oldContractObj.Status = 'Declined';
                        oldContractObj.E_Stamp__c = null;
                        oldContractObj.ContractTerm = 120; // Set it 10 years for now but in PayU Context Agreement End Date doesn't matter.
                        update oldContractObj;
                    }                    
                    lstAttachment[0].ParentId = ContractObject.Id;
                    insert lstAttachment;                    
                    return 'Agreement_Sent';
                }catch(DMLException ex){
                    return ex.getMessage();
                }
            }     
        } 
        return null;
    }
    
    // ============== get the opportunity record =============================
    public static Opportunity getOpportunity(Id oppId){
        return [SELECT Id, Name, Product__c, Product__r.Enable_Draft_Agreement__c, Product__r.Platform__c, MAF_Status__c, Merchant_Id__c,
                Product_Name__c, Identifier__c, AccountId, Pricing_Negotiation_Status__c, Product__r.Platform__r.Name, Bank_Verification_Status__c,
                Account.LOB_Status__c, Account.Dow_Jones_Status__c, Account.Document_Status__c,  Account.Business_Entity__c, 
                E_Stamp__c, E_Stamp__r.EStamp_Number__c, E_Stamp_Number__c,Settlement_Status__c,Partner_Id__c,Customized_Agreement__c,
                Account.Identifier__c, Account.Owner.Email, RecordTypeId, RecordType.Name, Lead_Type__c, 
                Profile_Verification_Status__c, Blacklist__c,Partner__r.Identifier__c,Account.BusinessCategoryName__c,
                Owner.Name,Owner.Email,Account.OwnerId,Business_Entity__c,Is_Partner_reffered_Merchant_Customized__c,PEP_Status__c,Customer_Declaration_PEP__c,Jocata_System_Alerts__c
                FROM Opportunity
                WHERE Id =: oppId];
    }
    
    // ================= get the account record ==================================
    public static Account getAccount(Id accId){
        return [SELECT Id, Name, Business_Entity__c, Dow_Jones_Status__c, Document_Status__c, LOB_Status__c, 
                Identifier__c, RecordTypeId, RecordType.DeveloperName, ParentId,BusinessCategoryName__c,
                (SELECT Id, Status, Name, AccountId, E_Stamp__c, Document_Master__c, Type__c, Document_Category__c,  
                 Document_Category__r.Name, Contract_Type__c, Offline_Generation__c, Pricebook2Id, Active__c,
                 Document_Content_Type__c, File_Size__c, URL__c, OwnerExpirationNotice, Document_Type__c,Opportunity__c, 
                 Document_Category_Name__c, Document_Type_Name__c, StartDate, ContractTerm, E_Stamp_Number__c 
                 FROM Contracts where Contract_Type__c IN('Agreement','PayoutAgreement') ORDER BY CreatedDate DESC),    // WHERE Active__c =: true),
                (SELECT Id, Email, Name, Designation__c, PAN__c, Authorised_Signatory__c, Owner.Name, Owner.Email FROM Contacts WHERE Authorised_Signatory__c =: true)
                FROM Account
                WHERE Id =: accId];
    }
    
    // ================= get the parent account related contact record ==================================
    public static List<Contact> getParentAcntContactRec(Id ParentAcntId){
        return [SELECT Id, Email, Name, Designation__c, PAN__c, Authorised_Signatory__c, Owner.Name, Owner.Email 
                FROM Contact 
                WHERE Authorised_Signatory__c =: true 
                AND AccountId =: ParentAcntId];
    }
    
    // =================== get the list of document master records =============================
    public static void getDocumentMaster(List<Document_Master__c> lstDocMasterAddendum, List<Document_Master__c> lstDocMasterAgreement,List<Document_Master__c> lstDocMasterPayoutAgreement){
        for(Document_Master__c docMasterObj : [SELECT Id, Name, Entity__c, RecordtypeId, RecordType.Name, Page_Association__c, Product__c,
                                               Document_Category__c, Document_Category__r.Name, Document_Type__c, Document_Type__r.Name, 
                                               Document_For__c,Customized_Agreement__c,Partner_Identifier__c
                                               FROM Document_Master__c 
                                               WHERE (RecordType.Name =: 'Addendum' 
                                                      OR RecordType.Name =: 'Agreement'
                                                      OR RecordType.Name =: 'Payout Activation')
                                               AND Active__c =: true
                                               AND Page_Association__c != null])
        {
            
            if(docMasterObj.RecordType.Name == 'Agreement'){
                lstDocMasterAgreement.add(docMasterObj);
            } 
            if(docMasterObj.RecordType.Name == 'Addendum'){
                lstDocMasterAddendum.add(docMasterObj);
            } 
            if(docMasterObj.RecordType.Name == 'Payout Activation'){
                lstDocMasterPayoutAgreement.add(docMasterObj);
            }
        }
    }
    
    // =================== Build List of Document Master of Agreement type  =============================
    public static List<Document_Master__c> getAgreementDocMaster(Account accObj,Opportunity oppObj, List<Document_Master__c> lstDocMasterAgreement){
        if(oppObj != null){
            List<Document_Master__c> docMasterList = AgreementManagerController.getDocmasterDetail(oppObj);
            return docMasterList;
        }else
        	return null;
    }
    
    // ================= Create Contract Record =================================
    public static void createNewContRec(Id accId, Contract contractObj, Contact contObj, String strStatus, String strType, Opportunity optyObj,String contractType){
        contractObj.AccountId = accId;
        contractObj.CustomerSignedId = (contObj != null && contObj.Id != null) ? contObj.Id : null;
        contractObj.StartDate = Date.Today();
        contractObj.ContractTerm = 120;   // Set it 10 years for now but in PayU Context Agreement End Date doesn't matter.
        contractObj.Status = strStatus; 
        contractObj.Type__c = strType;
        contractObj.Offline_Generation__c = true;
        contractObj.Document_Received__c = 'Soft Copy';
        contractObj.Active__c = (contractType == 'Agreement') ? false : true;
        contractObj.URL__c = null;
        contractObj.Document_Category__c = null;
        contractObj.Opportunity__c = (optyObj != null && optyObj.Id != null) ? optyObj.Id : null;
        contractObj.Contract_Type__c = contractType;
    }
    
    // ================= update the contract records ===================================
    public static void updateContractRecord(Contract ContractObject, Document_Master__c docMasterObj, List<E_Stamp_Master__c> lstEStampMaster, ContentVersion contentVersionObj, String ContractType){ 
        System.debug(' ContractObject ********** '+ContractObject);
        ContractObject.Contract_Type__c = (String.isNotBlank(ContractType)) ? ContractType : null;
        ContractObject.ContractTerm = ContractObject.ContractTerm;
        ContractObject.Document_Content_Type__c = 'application/pdf';
        
        if(docMasterObj != null && docMasterObj.Id != null){
            ContractObject.Document_Master__c = docMasterObj.Id; 
            ContractObject.Name = docMasterObj.Name;
            ContractObject.Document_Category_Name__c  = String.isNotBlank(docMasterObj.Document_Category__c) ? docMasterObj.Document_Category__r.Name : 'Service Agreement';            
            ContractObject.Document_Type_Name__c = String.isNotBlank(docMasterObj.Document_Type__c) ? docMasterObj.Document_Type__r.Name : 'Service Agreement'; 
            ContractObject.Document_Category__c = String.isNotBlank(docMasterObj.Document_Category__c) ? docMasterObj.Document_Category__c : null ;
            ContractObject.Document_Type__c = String.isNotBlank(docMasterObj.Document_Type__c) ? docMasterObj.Document_Type__c : null ;            
        }
        if(contentVersionObj != null && contentVersionObj.Id != null){
          //ContractObject.Document_Content_Type__c = String.isNotBlank(contentVersionObj.ContentDocument.FileExtension) ? String.valueOf(contentVersionObj.ContentDocument.FileExtension) : null;
            //ContractObject.Document_Content_Type__c = 'application/pdf';
            ContractObject.File_Size__c = (contentVersionObj.ContentDocument.ContentSize != null) ? String.valueOf(contentVersionObj.ContentDocument.ContentSize) : null;
        }
        if(ContractObject.Type__c == 'Final' && lstEStampMaster != null && !lstEStampMaster.isEmpty() && ContractObject.E_Stamp__c == null){
            ContractObject.E_Stamp__c = lstEStampMaster[0].Id ;     
        } 
        if(String.isNotBlank(ContractType) && ContractType == 'PayoutAgreement'){
            ContractObject.KYC_Documentable_Type__c = 'Merchant';
            ContractObject.Active__c = True;
        }
    }
    
    // ======================== Create the Visualforce Page Reference  with attachments ================================
    public static void createPageReference(Opportunity optyObj, List<Attachment> lstAttachment, Document_Master__c docMasterObj, Boolean isFinal, List<E_Stamp_Master__c> lstEStampMaster){
        system.debug('PageReference ============= ');
        PageReference pageRef = new PageReference('/apex/' + docMasterObj.Page_Association__c);
        pageRef.getParameters().put('id', optyObj.Id);        
        pageRef.getParameters().put('strIsFinal', String.valueof(isFinal));
        
        if(isFinal && !lstEStampMaster.isEmpty())   pageRef.getParameters().put('eStampNo', String.valueof(lstEStampMaster[0].EStamp_Number__c));
        Blob body;
        if(!Test.isRunningTest()){
            body = pageRef.getContent();
        }else{
            body = Blob.valueOf('Test Attachment Body');
        }
        String strFielExtension = isFinal ? '.pdf' :  '.doc';
        createListAttachment(optyObj.Id, lstAttachment, docMasterObj.Page_Association__c, body, strFielExtension);
    }
    
    // ========================= build the list of attachments =====================================
    public static void createListAttachment(Id OptyId, List<Attachment> lstAttachment, String strTitle, Blob body, String strFielExtension){        
        system.debug('Attachment ============= ');
        Attachment attachmentObj = new Attachment();
        attachmentObj.Body = body;
        attachmentObj.Name = strTitle + strFielExtension;
        attachmentObj.IsPrivate = false;
        attachmentObj.ParentId = OptyId;
        lstAttachment.add(attachmentObj);
    }
    
    // =============== get the document master records based on id ==================================
    public static Document_Master__c getDocumentMasterRec(String strSelectedDocMaster){
        return [SELECT Id, Name, Entity__c, RecordtypeId, RecordType.Name, Page_Association__c, Document_Category__c, Document_Type__c,
                Document_Category__r.Name, Document_Type__r.Name
                FROM Document_Master__c 
                WHERE Id =: strSelectedDocMaster LIMIT 1];
    }
    
    // ============= get the list of E-Stamp master records ================================
    public static List<E_Stamp_Master__c> getEStampMaster(){
        return [SELECT Id, EStamp_Number__c, Active__c, Used__c 
                FROM E_Stamp_Master__c 
                WHERE Active__c =: true 
                AND Used__c =: false 
                ORDER BY EStamp_Number__c ASC];     
    } 
    
    // ===================== get the uploaded file details ==========================
    public static ContentVersion getContentVersion(Id uploadedDocumentId){
        return [SELECT Id, Title, VersionData, isLatest, ContentDocumentId, FileType,
                ContentDocument.FileExtension, ContentDocument.ContentSize
                FROM ContentVersion 
                WHERE isLatest = true 
                AND ContentDocumentId =: uploadedDocumentId
                LIMIT 1];
    }
    //Prashant
    // ============= Fetch the Data on basis of opportunity ================================
    public static void getEStampid(String accid,Opportunity optyObj,String estampid){
        system.debug('@@@@Inside Method');
        optyObj.E_Stamp__c = estampid;
        Update optyObj;
        system.debug('@@@@Update Opp');
    } 
    
    public static void sendDocumentToAWS(Contract contractObj, Opportunity optyObj, Id uploadedDocumentId, List<Attachment> lstAttachment, ContentVersion contentVersionObj){
        String strEndPoint = '';        
        try{ 
            if(String.isNotBlank(uploadedDocumentId)){
                system.debug('uploadedDocumentId case *&^$#@** '+uploadedDocumentId);
                //strEndPoint = AWSUtility.uploadAndGetDocUrlS3(contractObj, optyObj.Account.Identifier__c, contentVersionObj.VersionData);
                strEndPoint = AWSUtility.uploadAndGetDocUrlS3Type(contractObj, optyObj.Identifier__c, contentVersionObj.VersionData, 'merchants');
            }else if(lstAttachment != null && !lstAttachment.isEmpty()){
                //strEndPoint = AWSUtility.uploadAndGetDocUrlS3(contractObj, optyObj.Account.Identifier__c, lstAttachment[0].Body);
				strEndPoint = AWSUtility.uploadAndGetDocUrlS3Type(contractObj, optyObj.Identifier__c, lstAttachment[0].Body, 'merchants');                
            }
            system.debug('strEndPoint ************ '+strEndPoint);
            if(String.isNotBlank(strEndPoint)){
                contractObj.Opportunity__c = optyObj.Id;
                contractObj.URL__c = strEndPoint;
                contractObj.Upload_Date__c = System.today();
                contractObj.File_Size__c = lstAttachment != null && !lstAttachment.isEmpty() ? String.valueOf(lstAttachment[0].BodyLength) : null;
            }
            system.debug('contractObj with URL %%%%%%%%% '+contractObj);            
        }catch(Exception ex){
            Map<String, String> messages = new Map<String, String>();
            messages.put('Identifier__c', String.valueOf(contractObj.Identifier__c));
            messages.put('SF_Record_Name__c', String.valueOf(contractObj.Name));
            messages.put('Severity__c', 'High');
            messages.put('SF_ID__c', contractObj.Id);
            messages.put('Process__c', 'Send Agreement');
            SystemUtility.errorHandler(ex, messages);
        }
    }
    
    /*============Get document types for addendum send==================*/
    public static List<Document_Type_Master__c> getDocTypeForAddendum(){
        List<Document_Type_Master__c> dtmList = New List<Document_Type_Master__c>();
        for(Document_Type_Master__c dtm : [Select Id,Active__c,KYC_Documentable_Type__c,Name from Document_Type_Master__c where Active__c=:true]){
            if(dtm.Active__c==true  && dtm.KYC_Documentable_Type__c == 'Addendum'){
                dtmList.add(dtm);
            }
        }
        return dtmList;
    } 
    
    @AuraEnabled
    public static string insertAttachmentonOpp(Id parentId,string fileId,String fileName, String base64Data, String contentType){
        system.debug('###### attachment insert call start ');
        if(string.isBlank(fileId )){
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            Attachment attach = new Attachment();
            attach.parentId = parentId;
            attach.Body = EncodingUtil.base64Decode(base64Data);
            attach.Name = fileName;
            attach.ContentType = contentType;
            Insert attach;
            return attach.Id;
        }else{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');        
            Attachment a = [SELECT Id, Body FROM Attachment WHERE Id = :fileId];            
            String existingBody = EncodingUtil.base64Encode(a.Body);
            a.Body = EncodingUtil.base64Decode(existingBody + base64Data);            
            update a;
        }    
        return Id.valueOf(fileId);
    }
    
    @AuraEnabled
    public static void insertContractAndSendToESB(string fileId,Boolean isSendMail,Contact contObj,WrapperSendAgreement wrapperdata,string kycdocType, string docTypeId,string docTypeName, Boolean isFinal){
        system.debug('###### wrapperdata call start ');
        Attachment attach;
        if(string.isNotBlank(fileId)){
            attach = [Select Id,Body,contentType,Name,BodyLength from Attachment where Id=:fileId LIMIT 1];
        } 
        system.debug('docTypeName@@@@' +docTypeName);
         system.debug('attach@@@@' +attach);
        
        if(attach !=null && string.isNotBlank(docTypeName)){
            Document_Type_Master__c docTypeMaster = [Select Id, Name from Document_Type_Master__c where Id=: docTypeId LIMIT 1];
            
            Contract contractObj = New Contract();
            if(!isFinal){            
                createNewContRec(wrapperdata.accObj.Id,contractObj,wrapperdata.authSignContact,'Draft Sent','Draft',wrapperdata.oppObj,kycDocType);
            }else{
                createNewContRec(wrapperdata.accObj.Id,contractObj,wrapperdata.authSignContact,'Pending','Final',wrapperdata.oppObj,kycDocType);
            }
            
            contractObj.Document_Category_Name__c = 'Service Agreement';
            contractObj.ContractTerm = 120;
            //contractObj.Name = docTypeName+' '+kycDocType+' '+wrapperdata.oppObj.E_Stamp_Number__c;
            contractObj.Name = docTypeName;
            contractObj.Contract_Type__c = (kycDocType!=null) ? kycDocType:'Addendum';
            //contractObj.Document_Content_Type__c = attach.contentType;
            contractObj.Document_Content_Type__c = 'application/pdf';
            contractObj.Document_Type__c = [Select Id from Document_Type_Master__c where Name=:'Addendum' LIMIT 1].Id;
            contractObj.Document_Category__c = [Select Id from Document_Category_Master__c where Name=:'Service Agreement' LIMIT 1].Id;
            contractObj.Upload_Date__c = Date.today();
            contractObj.Document_Type_Name__c = docTypeMaster.Name;
            contractObj.File_Size__c = string.valueOf(attach.BodyLength);
            contractObj.E_Stamp__c = wrapperdata.oppObj.E_Stamp__c;
            contractObj.Active__c = True;
            contractObj.KYC_Documentable_Type__c = 'Merchant';
            string strEndPoint = '';
            if(!Test.isRunningTest()) 
                //strEndPoint = AWSUtility.uploadAndGetDocUrlS3(contractObj, wrapperdata.oppObj.Identifier__c, attach.Body);
                strEndPoint = AWSUtility.uploadAndGetDocUrlS3Type(contractObj, wrapperdata.oppObj.Identifier__c, attach.Body,'merchants');
            system.debug('###### strEndPoint '+strEndPoint);
            contractObj.URL__c = strEndPoint;
            if(isSendMail){
                String orgWideEmailAdd = Label.Organization_Wide_Email_Address;
                Id orgWideEmailAddId = null;
                
                //Prashant
                EmailTemplate templateId = [Select id from EmailTemplate where name = 'Merchant email'];
                List<OrgWideEmailAddress> lstOrgWideEmailAddress = new List<OrgWideEmailAddress>();
                if(String.isNotBlank(orgWideEmailAdd)) lstOrgWideEmailAddress = [select Id from OrgWideEmailAddress where DisplayName =: orgWideEmailAdd];
                if(!lstOrgWideEmailAddress.isEmpty()) orgWideEmailAddId = lstOrgWideEmailAddress[0].Id;  
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                
                message.setOrgWideEmailAddressId(orgWideEmailAddId);
                if(contObj!=null && string.isNotBlank(contObj.Email))
                    message.setToAddresses(new String[] { contObj.Email });
                if(contObj!=null && string.isNotBlank(contObj.Owner.Email))
                    message.setReplyTo(contObj.Owner.Email != 'salesforceteam@payu.in' ? contObj.Owner.Email : 'noreply@payu.in');/** SFI-546 - Changed to update the reply email as 'noreply@payu.in'.  */ /** old - contObj.Owner.Email */  
                if(wrapperdata.oppObj.Account !=null && string.isNotBlank(wrapperdata.oppObj.Account.Owner.Email)){
                    if(wrapperdata.oppObj.Account.Owner.Email != 'salesforceteam@payu.in'){ /** SFI-546 - Added to skip the salesforce team email Id which was tagging as the CC address */
                        message.setCcAddresses(new String[] { wrapperdata.oppObj.Account.Owner.Email });
                    }
                }
                
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(attach.Name);
                efa.setBody(attach.Body);                
                efa.setContentType(attach.ContentType);
                attachments.add(efa);                
                message.setFileAttachments(attachments);
                //message.setPlainTextBody('Please see attached document as an addendum.<br/>s');
                //Prashant
                message.setTemplateID(templateId.Id);
                message.setTargetObjectId(contObj.id);	
                message.setWhatId(contObj.accountid);	
                message.setSaveAsActivity(false);	
                message.setUseSignature(false);
                if(!Test.isRunningTest())
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
            }
            try{
                insert contractObj;
                delete attach;
            }catch(exception e){system.debug('addendum exception '+e);}
        }
    }
    
    public static List<Cross_Sell__c> getCrossSell(Id oppId){
        return[Select Id,Fee_Master__c,Risk_Status__c,Custom_Product__r.Name from Cross_Sell__c where Opportunity__c =: oppId AND Custom_Product__c IN(Select Id from Product__c Where Name=:'Payout')];
    }
    
    // =================== Build List of Document Master of Payout Agreement type  =============================
    public static List<Document_Master__c> getPayoutAgreementDocMaster(Account accObj,Opportunity oppObj, List<Document_Master__c> lstDocMasterAgreement){
        if(oppObj != null){
            List<Document_Master__c> docMasterList = [Select Id, Name, Document_Category__c, Document_Category__r.Name, Document_Category__r.Identifier__c, 
                         Document_Type__c, Document_Type__r.Name, Document_Type__r.Identifier__c, Page_Association__c 
                         FROM Document_Master__c WHERE Entity__c =: oppObj.Account.Business_Entity__c AND
                         RecordType.DeveloperName = 'Payout_Activation' AND Active__c = True
                         AND Document_For__c =: oppObj.Lead_Type__c AND Product__c=:oppObj.Product__c];
            return docMasterList;
        }else
        	return null;
    }
    /*
    @AuraEnabled
    public static Map<String, Decimal> getPaymentModeRateMap(String oppId) {
        Map<String, Decimal> paymentModeToRateMap = new Map<String, Decimal>();
        
        Opportunity oppObj = [SELECT Id, Prod_Merchant_Id__c, Has_Customized_Rates__c FROM Opportunity WHERE Id =: oppId];
        
        if(oppObj.Has_Customized_Rates__c == TRUE){
            System.debug('On line 128');
            string responseBody = '';
            string customizedAgreementAccessToken = '';
            string body = '';
            body += 'merchantId=' + oppObj.Prod_Merchant_Id__c + '&';
            body += 'clientId=' + 1;
            system.Debug('On line 135');
            if(!Test.isRunningTest()){
                customizedAgreementAccessToken = IntegrationUtility.getAuthToken('Customized_Agreement_Authentication');
                //customizedAgreementAccessToken += '23c0e38e7232208787dcf7ef06873ea1cd17439663e7a2d3e2f2f65c9260572d';
                System.debug('customizedAgreementAccessToken : '+customizedAgreementAccessToken);
                System.debug('On line 135');
                System.debug('Response Body : '+responseBody);
                
                
            }
            else{
                customizedAgreementAccessToken += 'b74acb75e87f93aa9db8073d570753474e58702aa9e91af4054478bba98af38e';
                System.debug('On line 142');
            }
            if(string.isNotBlank(customizedAgreementAccessToken)){
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                Integration_Setting__mdt theIntIns = IntegrationUtility.getIntSetting('Get_Customized_Rates');
                request.setEndpoint(theIntIns.EndPointUrl__c);
                request.setMethod(theIntIns.Method__c);
                request.setBody(body);
                request.setHeader('Authorization', 'Bearer ' + customizedAgreementAccessToken);
                request.setHeader('Content-Type', 'application/json');
                //request.setHeader('Connection', 'keep-alive');
                
                HttpResponse response = http.send(request);
                
                System.debug('Body === '+body);
                System.debug('End URL === '+theIntIns.EndPointUrl__c);
                System.debug('Method === '+theIntIns.Method__c);
                
                if(response.getStatusCode() == 200){
                    Map<String,Object> resultsMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                    System.debug('resultsMap===='+resultsMap);
                }
    		}
        }
        return paymentModeToRateMap;
    }
    
    /*public static void getCustomizedRates(List<Opportunity> opps){
        for(Opportunity opp : opps){
            if(opp.Has_Customized_Rates__c == TRUE){
                //String oppId = opp.Id;
                ServiceAgreementController.getPaymentModeRateMap(opp.Id);
                //ServiceAgreementController.getPaymentModeRateMap();
            }
        }
        
    }*/

}