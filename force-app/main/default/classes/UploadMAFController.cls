/**
* This class is triggered from Lightning component Upload_MAF
* Used to calout MAF API and mapping of MAF response in Lead/Opportunity.

* Company       Date         Author          Description

* Saasfocus     1-Aug-2018   Manav Arora     Initial Version
*
**/
public class UploadMAFController{
    
    @AuraEnabled
    public static String mafEnabledStatus(Id sobId){
        
        String sObjName = sobId.getSObjectType().getDescribe().getName();
        
        if(sObjName == 'Lead'){
            Lead leadObj = [SELECT Id, Product__r.MAF_Enable__c FROM Lead WHERE Id =: sobId LIMIT 1];
            
            if(!leadObj.Product__r.MAF_Enable__c){
                return 'MAF_Not_Enable';
            }
        }
        
        if(sObjName == 'Opportunity'){
            Opportunity optyObj = [SELECT Id, Product__r.MAF_Enable__c FROM Opportunity WHERE Id =: sobId LIMIT 1];
            
            if(!optyObj.Product__r.MAF_Enable__c){
                return 'MAF_Not_Enable';
            }
        }
        return null;
    }
    
    @auraEnabled
    public static void getDetail(Id sobId, Id docIds){
        
        if(String.isNotBlank(sobId) && String.isNotBlank(docIds)){
            
            ContentVersion cv = [select id from contentversion where contentdocumentid =: docIds];
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'CD:'+ sobId;
            cd.ContentVersionId = cv.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            insert cd;
            
            ContentDistribution filePublicURL = [SELECT ContentDownloadUrl,Name FROM ContentDistribution 
                                                 WHERE Id =: cd.Id Limit 1];
            
            String filePath = '{"file_path": "'+filePublicURL.ContentDownloadUrl+'"}';
            mafMapping(filePath, sobId, docIds);
        }
    }
    
    @future(callout=true)
    public static void mafMapping(String filePath, Id sobId, String docIds){
        
        String regFirstName;
        String regLastName;
        
        try{
            ContentDocument contDoc = [Select Id, title FROM ContentDocument WHERE Id =: docIds];
            
            HttpResponse response = AWSUtility.getAWSData('ReteriveMAF',null, null, filePath, null);
            system.debug('code.>>>>' +response.getStatusCode());
            system.debug('body>>>>>>>' +response.getBody());
            
            String JSON = response.getBody();
            
            MAFJsonMapping returnDetail = MAFJsonMapping.parse(JSON);
            system.debug('@ReturnJSOn@'+returnDetail);
            
            String sObjName = sobId.getSObjectType().getDescribe().getName();
            
            if(String.isNotBlank(returnDetail.registered_contact_person_name)){
                if(returnDetail.registered_contact_person_name.Contains(' ')){
                    regFirstName = returnDetail.registered_contact_person_name.substringBefore(' ');
                    regLastName = returnDetail.registered_contact_person_name.substringAfter(' ');
                }
                else{
                    regLastName = returnDetail.registered_contact_person_name;
                }
            }
            
            /***Upload MAF for Lead***/
            if(sObjName == 'Lead' && response.getStatusCode() == 200){
                
                Lead oldLead = Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Lead')), ',') + ' FROM Lead WHERE Id =\'' + sobId + '\'');
                Lead updateLead = new Lead(Id = oldLead.Id);
                updateLead.GST_Number__c = returnDetail.gst_number;
                updateLead.Legal_Name__c = returnDetail.merchant_legal_name;
                updateLead.PAN_Number__c = returnDetail.pan_number;
                updateLead.PAN_Holder_Name__c = returnDetail.merchant_legal_name;
                updateLead.Product_Service_Description__c = returnDetail.products_and_services_sold;
                updateLead.FirstName = regFirstName;
                updateLead.LastName = regLastName;
                updateLead.MobilePhone = returnDetail.registered_mobile_number;
                updateLead.Email = returnDetail.registered_email;
                updateLead.TAN_Number__c = returnDetail.tan_number;
                updateLead.Website__c = returnDetail.website_url;
                updateLead.Expected_Monthly_Txn_Count__c = returnDetail.trans_monthly_vol == null ? null : decimal.valueOf(returnDetail.trans_monthly_vol);
                updateLead.Average_Ticket_Size__c = returnDetail.average_cost == null ? null : decimal.valueOf(returnDetail.average_cost);
                updateLead.Merchant_Trading_Name__c = returnDetail.merchant_business_name;
                updateLead.MAF_Status__c = 'Received';
                
                IntegrationUtility.isUpdate = true;
                IntegrationUtility.isTriggerExecuting = true;  
                
                IntegrationUtility.sendPayLoadData(updateLead, oldLead, 'Lead', 'Lead');
                
                update updateLead;
                
                List<Address_Details__c> addressDetail = upsertAddressDetails(sobId, sObjName, returnDetail);
                upsert addressDetail;
                
                List<Bank_Account_Detail__c> eachBank = upsertBankAccount(sobId, sObjName, returnDetail);
                upsert eachBank;
                
                List<Contact> contactList = upsertContacts(sobId, sObjName, returnDetail);
                upsert contactList;
                
                delete contDoc;
            }
            
            /***Upload MAF for Opportunity***/
            else if(sObjName == 'Opportunity' && response.getStatusCode() == 200){
                
                List<Bank_Account_Detail__c> eachBank = upsertBankAccount(sobId, sObjName, returnDetail);
                upsert eachBank;
                
                List<Opportunity> acntId = [Select Id, Name, AccountId FROM Opportunity WHERE Id =: sobId];
                
                Account acnt = new Account(Id = acntId[0].AccountId);
                
                acnt.Legal_Name__c = returnDetail.merchant_legal_name;
                acnt.PAN_Number__c = returnDetail.pan_number;
                acnt.PAN_Holder_Name__c = returnDetail.merchant_legal_name;
                acnt.Product_Service_Description__c = returnDetail.products_and_services_sold;
                acnt.TAN_Number__c = returnDetail.tan_number;
                acnt.Expected_Monthly_Txn_Count__c = returnDetail.trans_monthly_vol == null ? null : decimal.valueOf(returnDetail.trans_monthly_vol);
                acnt.Average_Ticket_Size__c = returnDetail.average_cost == null ? null : decimal.valueOf(returnDetail.average_cost);
                acnt.Phone = returnDetail.registered_mobile_number;
                acnt.Merchant_Trading_Name__c = returnDetail.merchant_business_name;                
                
                List<Address_Details__c> addressDetail = upsertAddressDetails(acntId[0].AccountId, sObjName, returnDetail);
                upsert addressDetail;
                
                List<Contact> contactList = upsertContacts(acntId[0].AccountId, sObjName, returnDetail);
                upsert contactList;
                
                update acnt;
                
                //delete content created intially
                delete contDoc;
                
                Opportunity opty = new Opportunity(Id = sobId, MAF_Status__c = 'Received');
                opty.First_Name__c = regFirstName;
                opty.Last_Name__c = regLastName;
                opty.Mobile__c = returnDetail.registered_mobile_number;
                opty.Email__c = returnDetail.registered_email;
                opty.GST_Number__c = returnDetail.gst_number;
                opty.Website__c = returnDetail.website_url;
                update opty;
            }
        }
        catch(Exception ex){    
            system.debug(ex.getStackTraceString() + 'exception=='+ex.getMessage());
            Map<String, String> messages = new Map<String, String>();
            messages.put('Severity__c', 'High');
            messages.put('SF_ID__c', sobId);
            messages.put('Process__c', 'Upload MAF');
            SystemUtility.errorHandler(ex, messages);
            
            /*Error_Details__c errorDetailsObj = new Error_Details__c();
            errorDetailsObj.Severity__c = 'High';
            errorDetailsObj.SF_ID__c = sobId;
            errorDetailsObj.Message__c = ex.getMessage() + '\n\n' + ex.getStackTraceString();
            errorDetailsObj.Process__c = 'Upload MAF';
            insert errorDetailsObj;*/
        }    
    }
    
    public static List<Bank_Account_Detail__c> upsertBankAccount(String objId, String Obj, MAFJsonMapping objMAFJsonMapping){
        List<Bank_Account_Detail__c> lstBankAccts = new List<Bank_Account_Detail__c>();
        
        if(Obj == 'Opportunity'){
            lstBankAccts = [Select Id, Name, Account_Holder_Name__c, Account_Number__c, Account_Type__c, IFSC_Code__c, Bank_Name__c, Branch_Address__c 
                            FROM Bank_Account_Detail__c WHERE Opportunity__c =: objId AND 
                            Account_Number__c =: objMAFJsonMapping.bank_account_number AND IFSC_Code__c =: objMAFJsonMapping.bank_ifsc_code Limit 1];
        }
        else if(Obj == 'Lead'){
            lstBankAccts = [Select Id, Name, Account_Holder_Name__c, Account_Number__c, Account_Type__c, IFSC_Code__c, Bank_Name__c, Branch_Address__c 
                            FROM Bank_Account_Detail__c WHERE Lead__c =: objId AND 
                            Account_Number__c =: objMAFJsonMapping.bank_account_number AND IFSC_Code__c =: objMAFJsonMapping.bank_ifsc_code Limit 1];
        }
        
        //if Bank Account list is not empty//
        if(lstBankAccts.size()>0 && !lstBankAccts.isEmpty()){
            for(Bank_Account_Detail__c bankdetail : lstBankAccts){
                bankdetail.Account_Holder_Name__c = objMAFJsonMapping.account_name;
                bankdetail.Account_Number__c = objMAFJsonMapping.bank_account_number;
                bankdetail.Account_Type__c = objMAFJsonMapping.bank_account_type;
                bankdetail.Branch__c = objMAFJsonMapping.bank_branch;
                bankdetail.Branch_Address__c = objMAFJsonMapping.bank_branch_address;
                bankdetail.IFSC_Code__c = objMAFJsonMapping.bank_ifsc_code;
                bankdetail.Active__c = true;
            }
        }
        
        //if Bank Account list is empty//
        else{
            Bank_Account_Detail__c bnkAcntDetail = new Bank_Account_Detail__c();
            bnkAcntDetail.Account_Holder_Name__c = objMAFJsonMapping.account_name;
            bnkAcntDetail.Account_Number__c = objMAFJsonMapping.bank_account_number;
            bnkAcntDetail.Account_Type__c = objMAFJsonMapping.bank_account_type;
            bnkAcntDetail.Branch__c = objMAFJsonMapping.bank_branch;
            bnkAcntDetail.Branch_Address__c = objMAFJsonMapping.bank_branch_address;
            bnkAcntDetail.IFSC_Code__c = objMAFJsonMapping.bank_ifsc_code;
            bnkAcntDetail.Active__c = true;
            if(obj == 'Opportunity'){
                bnkAcntDetail.Opportunity__c = objId;
            }
            else if(obj == 'Lead'){
                bnkAcntDetail.Lead__c = objId;    
            }
            lstBankAccts.add(bnkAcntDetail);
        }
        return lstBankAccts;
    }
    
    public static List<Address_Details__c> upsertAddressDetails(String objId, String Obj, MAFJsonMapping objMAFJsonMapping){
        List<Address_Details__c> addressDetail = new List<Address_Details__c>();
        if(obj == 'Opportunity'){
            addressDetail = [Select Id, Name, Account__c, Address_Line__c, Pincode__c, Type__c FROM Address_Details__c
                             WHERE Account__c =: objId AND (Type__c = 'Registered' OR Type__c = 'Operating')];
        }
        else if(obj == 'Lead'){
            addressDetail = [Select Id, Name, Lead__c, Address_Line__c, Pincode__c, Type__c FROM Address_Details__c
                             WHERE Lead__c =: objId AND (Type__c = 'Registered' OR Type__c = 'Operating')];
        }
        
        //if Address Detail list is not empty//
        if(addressDetail.size()>0 && !addressDetail.isEmpty()){
            for(Address_Details__c eachAddress : addressDetail){
                if(eachAddress.Type__c == 'Registered'){
                    eachAddress.Address_Line__c = objMAFJsonMapping.registered_address;
                    eachAddress.Pincode__c = objMAFJsonMapping.registered_pincode;
                    eachAddress.Type__c = 'Registered';
                    eachAddress.Active__c = True;
                }
                else if(eachAddress.Type__c == 'Operating'){
                    eachAddress.Address_Line__c = objMAFJsonMapping.operations_address;
                    eachAddress.Pincode__c = objMAFJsonMapping.operations_pincode;
                    eachAddress.Type__c = 'Operating';
                    eachAddress.Active__c = True;
                }
            }
            if(addressDetail.size()==1 && addressDetail[0].Type__c == 'Registered'){
                Address_Details__c opAddress = new Address_Details__c();
                opAddress.Address_Line__c = objMAFJsonMapping.operations_address;
                opAddress.Pincode__c = objMAFJsonMapping.operations_pincode;
                opAddress.Type__c = 'Operating';
                opAddress.Active__c = True;
                if(obj == 'Opportunity'){
                    opAddress.Account__c = objId;
                }
                else if(obj == 'Lead'){
                    opAddress.Lead__c = objId;    
                }
                addressDetail.add(opAddress);
            }
            if(addressDetail.size()==1 && addressDetail[0].Type__c == 'Operating'){
                Address_Details__c regAddress = new Address_Details__c();
                regAddress.Address_Line__c = objMAFJsonMapping.registered_address;
                regAddress.Pincode__c = objMAFJsonMapping.registered_pincode;
                regAddress.Type__c = 'Registered';
                regAddress.Active__c = True; 
                if(obj == 'Opportunity'){
                    regAddress.Account__c = objId;
                }
                else if(obj == 'Lead'){
                    regAddress.Lead__c = objId;    
                }
                addressDetail.add(regAddress);
            }
        }
        
        //if Address Detail list is empty//
        else{
            if(String.isNotBlank(objMAFJsonMapping.registered_address)){
                Address_Details__c regAddress = new Address_Details__c();
                regAddress.Address_Line__c = objMAFJsonMapping.registered_address;
                regAddress.Pincode__c = objMAFJsonMapping.registered_pincode;
                regAddress.Type__c = 'Registered';
                regAddress.Active__c = True; 
                if(obj == 'Opportunity'){
                    regAddress.Account__c = objId;
                }
                else if(obj == 'Lead'){
                    regAddress.Lead__c = objId;    
                }
                addressDetail.add(regAddress);
            }
            if(String.isNotBlank(objMAFJsonMapping.operations_address)){
                Address_Details__c opAddress = new Address_Details__c();
                opAddress.Address_Line__c = objMAFJsonMapping.operations_address;
                opAddress.Pincode__c = objMAFJsonMapping.operations_pincode;
                opAddress.Type__c = 'Operating';
                opAddress.Active__c = True; 
                if(obj == 'Opportunity'){
                    opAddress.Account__c = objId;
                }
                else if(obj == 'Lead'){
                    opAddress.Lead__c = objId;    
                }
                addressDetail.add(opAddress);
            }
        }
        return addressDetail;
    }
    
    public static List<Contact> upsertContacts(String objId, String Obj, MAFJsonMapping objMAFJsonMapping){
        List<Contact> conList = new List<Contact>();
        
        String secFirstName;
        String secLastName;
        String fraudFirstName;
        String fraudLastName;
        
        if(obj == 'Opportunity'){
            conList = [Select Id, Name, MobilePhone, Email, MailingAddress, PAN__c, Type__c FROM Contact 
                       WHERE AccountId =: objId AND (Type__c = 'Secondary Contact' OR Type__c = 'Fraud/Dispute Alert')];
        }
        else if(obj == 'Lead'){
            conList = [Select Id, Name, MobilePhone, Email, MailingAddress, PAN__c, Type__c FROM Contact 
                       WHERE Lead__c =: objId AND (Type__c = 'Secondary Contact' OR Type__c = 'Fraud/Dispute Alert')];
        }
        
        if(String.isNotBlank(objMAFJsonMapping.operations_contact_person_name)){
                if(objMAFJsonMapping.operations_contact_person_name.Contains(' ')){
                    secFirstName = objMAFJsonMapping.operations_contact_person_name.substringBefore(' ');
                    secLastName = objMAFJsonMapping.operations_contact_person_name.substringAfter(' ');
                }
                else{
                    secLastName = objMAFJsonMapping.operations_contact_person_name;
                }
            }
        
        if(String.isNotBlank(objMAFJsonMapping.queries_contact_name)){
                if(objMAFJsonMapping.queries_contact_name.Contains(' ')){
                    fraudFirstName = objMAFJsonMapping.queries_contact_name.substringBefore(' ');
                    fraudLastName = objMAFJsonMapping.queries_contact_name.substringAfter(' ');
                }
                else{
                    fraudLastName = objMAFJsonMapping.queries_contact_name;
                }
            }
        
        //if Contact list is not empty//
        if(conList.size()>0 && !conList.isEmpty()){
            for(Contact each : conList){
                if(each.Type__c == 'Secondary Contact'){
                    each.FirstName = secFirstName;
                    each.LastName = secLastName;
                    each.MobilePhone = objMAFJsonMapping.operations_mobile_number;
                    each.Email = objMAFJsonMapping.operations_email;
                }
                else if(each.Type__c == 'Fraud/Dispute Alert'){
                    each.FirstName = fraudFirstName;
                    each.LastName = fraudLastName;
                    each.MobilePhone = objMAFJsonMapping.queries_mobile_number;
                    each.Email = objMAFJsonMapping.queries_email;
                }
            }
            if(conList.size()==1 && conList[0].Type__c == 'Secondary Contact'){
                Contact fraudCon = new Contact();
                fraudCon.Type__c = 'Fraud/Dispute Alert';
                fraudCon.FirstName = fraudFirstName;
                fraudCon.LastName = fraudLastName;
                fraudCon.MobilePhone = objMAFJsonMapping.queries_mobile_number;
                fraudCon.Email = objMAFJsonMapping.queries_email;
                if(obj == 'Opportunity'){
                    fraudCon.AccountId = objId;
                }
                else if(obj == 'Lead'){
                    fraudCon.Lead__c = objId;    
                }
                conList.add(fraudCon);
            }
            if(conList.size()==1 && conList[0].Type__c == 'Fraud/Dispute Alert'){
                Contact secCon = new Contact();
                secCon.Type__c = 'Secondary Contact';
                secCon.FirstName = secFirstName;
                secCon.LastName = secLastName;
                secCon.MobilePhone = objMAFJsonMapping.operations_mobile_number;
                secCon.Email = objMAFJsonMapping.operations_email;
                if(obj == 'Opportunity'){
                    secCon.AccountId = objId;
                }
                else if(obj == 'Lead'){
                    secCon.Lead__c = objId;    
                }
                conList.add(secCon);
            }
        }
        
        //if Contact list is empty//
        else{
            if(String.isNotBlank(secLastName)){
                Contact secCon = new Contact();
                secCon.Type__c = 'Secondary Contact';
                secCon.FirstName = secFirstName;
                secCon.LastName = secLastName;
                secCon.MobilePhone = objMAFJsonMapping.operations_mobile_number;
                secCon.Email = objMAFJsonMapping.operations_email;
                if(obj == 'Opportunity'){
                    secCon.AccountId = objId;
                }
                else if(obj == 'Lead'){
                    secCon.Lead__c = objId;    
                }
                conList.add(secCon);
            }
            if(String.isNotBlank(fraudLastName)){
                Contact fraudCon = new Contact();
                fraudCon.Type__c = 'Fraud/Dispute Alert';
                fraudCon.FirstName = fraudFirstName;
                fraudCon.LastName = fraudLastName;
                fraudCon.MobilePhone = objMAFJsonMapping.queries_mobile_number;
                fraudCon.Email = objMAFJsonMapping.queries_email;
                if(obj == 'Opportunity'){
                    fraudCon.AccountId = objId;
                }
                else if(obj == 'Lead'){
                    fraudCon.Lead__c = objId;    
                }
                conList.add(fraudCon);
            }
        }
        return conList;
    }
}