public class MCareDashboardCompController {
    
    @AuraEnabled
    public static MCareDashWrapper getMCareDashboardData(Id recordId){
        MCareDashWrapper wrapperObj = New MCareDashWrapper();
        wrapperObj.userCurrentTheme = UserInfo.getUiThemeDisplayed();
        if(string.isNotBlank(recordId)){
            if(String.valueOf(recordId).startsWith('500')){
                wrapperObj.MCareDashboardCaseObj = getMCareDashboardCaseFromCase(recordId);
                if(String.isNotBlank(wrapperObj.MCareDashboardCaseObj.Merchant_Id__c) && String.isNotBlank(wrapperObj.MCareDashboardCaseObj.Opportunity__c)) 
                    wrapperObj.opportunityObj = getOpportunityDetails(wrapperObj.MCareDashboardCaseObj.Opportunity__c);
            }else{
            	wrapperObj.MCareDashboardCaseObj = getMCareDashboardCase(recordId);
                if(String.isNotBlank(wrapperObj.MCareDashboardCaseObj.Merchant_Id__c) && String.isNotBlank(wrapperObj.MCareDashboardCaseObj.Opportunity__c)) 
                    wrapperObj.opportunityObj = getOpportunityDetails(wrapperObj.MCareDashboardCaseObj.Opportunity__c);
            }
        }else{
            wrapperObj.MCareDashboardCaseObj = New MCare_Dashboard_Case__c();
            wrapperObj.MCareDashboardCaseObj.Tracker_Id__c = 'Risk Hold';
            wrapperObj.MCareDashboardCaseObj.Status__c = 'Risk Hold';
        }
        return wrapperObj;
    }
    
    public static MCare_Dashboard_Case__c getMCareDashboardCase(Id recordId){
        return [Select Desposition_L1__c ,Desposition_L2__c ,ANDX_Value__c ,Business_Origin__c ,
                Case__c ,Category__c ,Credit_Risk_Rating__c , CTS_FTS_RR_Check__c, Customer1_Calling_Review__c ,Customer1_Phone__c ,Customer2_Calling_Review__c ,
                Customer2_Phone__c ,Customer3_Calling_Review__c ,Customer3_Phone__c ,Delivery_duration__c ,Description__c ,Due_Date__c ,
                Estimated_Hours__c ,FNDX_Value__c ,From_Address__c ,Hold_Reason_Shown_to_Merchant__c ,Last_Transaction_Date__c ,Merchant_Age__c ,
                Merchant_Age_Check__c ,Merchant_Email__c ,Merchant_Id__c ,Merchant_Legal_Name__c ,Merchant_URL__c ,No_of_Days_to_Whitelist__c ,
                Payment_Id__c ,Priority__c ,Project_Id__c ,Reason__c ,Risk_Rating__c ,Social_Media_Check__c ,Start_Date__c ,Status__c ,
                Sub_Category__c ,Subject__c ,Tracker_Id__c,Created_Internally__c,Opportunity__c,Product_Name__c from MCare_Dashboard_Case__c Where Id =:recordId];
    }
    
    public static MCare_Dashboard_Case__c getMCareDashboardCaseFromCase(Id recordId){
        return [Select Desposition_L1__c ,Desposition_L2__c ,ANDX_Value__c ,Business_Origin__c ,
                Case__c ,Category__c ,Credit_Risk_Rating__c , CTS_FTS_RR_Check__c, Customer1_Calling_Review__c ,Customer1_Phone__c ,Customer2_Calling_Review__c ,
                Customer2_Phone__c ,Customer3_Calling_Review__c ,Customer3_Phone__c ,Delivery_duration__c ,Description__c ,Due_Date__c ,
                Estimated_Hours__c ,FNDX_Value__c ,From_Address__c ,Hold_Reason_Shown_to_Merchant__c ,Last_Transaction_Date__c ,Merchant_Age__c ,
                Merchant_Age_Check__c ,Merchant_Email__c ,Merchant_Id__c ,Merchant_Legal_Name__c ,Merchant_URL__c ,No_of_Days_to_Whitelist__c ,
                Payment_Id__c ,Priority__c ,Project_Id__c ,Reason__c ,Risk_Rating__c ,Social_Media_Check__c ,Start_Date__c ,Status__c ,
                Sub_Category__c ,Subject__c ,Tracker_Id__c,Created_Internally__c,Opportunity__c,Product_Name__c from MCare_Dashboard_Case__c Where Case__c =:recordId ORDER BY LastModifiedDate DESC LIMIT 1];
    }
    
    public static Opportunity getOpportunityDetails(Id recordId){
        return[SELECT Id,Settlement_Status__c,Key_Assigned_Manager__c,Key_Assigned_Manager__r.Email, Key_Assigned_Manager_Segment__c from Opportunity Where Id =: recordId];
    }
    
    @AuraEnabled
    public static List<String> getMerchantStatus(string objType, string fieldName){
        return SystemUtility.getPicklistValue(objType, fieldName);
    }
    
    @AuraEnabled
    public static List<String> getBusinessCategory(){
        List<string> businessCategoryNames = new List<string>();
        for(Business_Category__c categoryObj : [Select Id,Name from Business_Category__c ]){
            businessCategoryNames.add(categoryObj.Name);
        }
        return businessCategoryNames;
    }
    
    @AuraEnabled
    public static Map<string,string> getFieldHelpText(string objDetail){
        Map<string, string> fieldNameWithHelpTextMap = New Map<String, String>();
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objDetail);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType objType = Object_name.getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        for(string fieldAPIName : objFieldMap.keySet()){
            string helpText = objFieldMap.get(fieldAPIName).getDescribe().getInlineHelpText();
            string fieldLabel = objFieldMap.get(fieldAPIName).getDescribe().getName();
            fieldNameWithHelpTextMap.put(fieldLabel,helpText);
        }
		return fieldNameWithHelpTextMap;
    }
    
    @AuraEnabled
    public static MCareDashWrapper saveDashboardData(string wrapperString, Boolean isSendEmail, Boolean isSendAttachment, Boolean doNotSendDescription, string projectName, Boolean internallyCreated, String documentId){
        MCareDashWrapper wrapperObj = New MCareDashWrapper();
        ContentVersion contentVersionObj = new ContentVersion();
        String strFileExtensionType = '';
        List<EmailTemplate> listEmailTemplateObj = new List<EmailTemplate>(); 
        List<Attachment> lstAttachment = new List<Attachment>();
        Set<String> keyManagerSegments = New Set<String>{'Gold','Platinum','Star'};
            
        try{
            wrapperObj = (MCareDashWrapper)JSON.deserialize(wrapperString, MCareDashWrapper.class);
            wrapperObj.MCareDashboardCaseObj.Project_Id__c = projectName;
            if(internallyCreated) wrapperObj.MCareDashboardCaseObj.Created_Internally__c = internallyCreated;
            
            if(String.isNotBlank(documentId)){            
                contentVersionObj = SendAgreementController.getcontentVersion(documentId);            
                if(contentVersionObj.ContentDocument.ContentSize > 5000000) wrapperObj.response = 'Error - File size is greater than 5 MB';//ERROR: '+ contentVersionObj.Title +' file is more than 5 MB.';
                strFileExtensionType = (contentVersionObj.FileType == 'WORD') ? '.doc' : '.pdf'; 
                if(String.isNotBlank(contentVersionObj.Id)){
            		SendAgreementController.createListAttachment(wrapperObj.MCareDashboardCaseObj.Id, lstAttachment, contentVersionObj.title, contentVersionObj.VersionData, strFileExtensionType);       
        		} 
            }
            
            if(!isSendEmail){
            	if(wrapperObj.MCareDashboardCaseObj.Status__c == 'Risk Hold') listEmailTemplateObj = DatabaseUtility.getEmailTemplate('MCare_PO_MID_Settlement_Hold');
                if(wrapperObj.MCareDashboardCaseObj.Status__c == 'Suspend') listEmailTemplateObj = DatabaseUtility.getEmailTemplate('MCare_PO_MID_Suspend');
                if(!listEmailTemplateObj.isEmpty() && listEmailTemplateObj.size() > 0){
                    String orgWideEmailAdd = Label.Organization_Wide_Email_Address;
                    Id orgWideEmailAddId = null;
                    List<OrgWideEmailAddress> lstOrgWideEmailAddress = new List<OrgWideEmailAddress>();
                    if(String.isNotBlank(orgWideEmailAdd)) lstOrgWideEmailAddress = [select Id from OrgWideEmailAddress where DisplayName =: orgWideEmailAdd];
                    if(!lstOrgWideEmailAddress.isEmpty()) orgWideEmailAddId = lstOrgWideEmailAddress[0].Id;                
                    
                    List<Messaging.SendEmailResult> listSendEmailResult = new List<Messaging.SendEmailResult>();
                    if(wrapperObj.opportunityObj != null && String.isNotBlank(wrapperObj.opportunityObj.Key_Assigned_Manager__c) && String.isNotBlank(wrapperObj.opportunityObj.Key_Assigned_Manager__r.Email) && String.isNotBlank(wrapperObj.opportunityObj.Key_Assigned_Manager_Segment__c) && keyManagerSegments.contains(wrapperObj.opportunityObj.Key_Assigned_Manager_Segment__c))
                        listSendEmailResult = sendEmailWithUpdateBody(wrapperObj.MCareDashboardCaseObj, wrapperObj.MCareDashboardCaseObj.Merchant_Legal_Name__c, wrapperObj.MCareDashboardCaseObj.Merchant_Email__c, listEmailTemplateObj[0], lstAttachment, wrapperObj.opportunityObj.Key_Assigned_Manager__r.Email, orgWideEmailAddId);
                    else
                        listSendEmailResult = sendEmailWithUpdateBody(wrapperObj.MCareDashboardCaseObj, wrapperObj.MCareDashboardCaseObj.Merchant_Legal_Name__c, wrapperObj.MCareDashboardCaseObj.Merchant_Email__c, listEmailTemplateObj[0], lstAttachment, '', orgWideEmailAddId);
                    system.debug(listSendEmailResult.size()+' :::::::: listSendEmailResult &&&&&&&&&&&& '+listSendEmailResult);
                    
                    if(listSendEmailResult.size()>0){
                        if(!listSendEmailResult[0].isSuccess()){
                            list<Messaging.SendEmailError> listSendEmailError = listSendEmailResult[0].getErrors();
                        }
                    }
                }
        	}
            upsert wrapperObj.MCareDashboardCaseObj;
        	wrapperObj.response = 'Record Updated Successfully';
        
        }catch(Exception ex){
            wrapperObj.response = 'Error - '+ex.getMessage() +' at Line ' +string.ValueOf(ex.getLineNumber());
        }
        return wrapperObj;
    }
    
    @AuraEnabled
    public static Map<String, List<String>> getDependentMap(string objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objDetail);//From the Object Api name retrieving the SObject
        
        Sobject Object_name = targetType.newSObject();
        
        Schema.sObjectType objType = Object_name.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;    
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public static List<Messaging.SendEmailResult> sendEmailWithUpdateBody(sObject sObjectData, string name, string email, EmailTemplate emailTemplateObj, list<Attachment> listAttachment, String kamEmail, Id OrgWideEmailAddId){
        List<Messaging.EmailFileAttachment> listEmailFileAttachment = new List<Messaging.EmailFileAttachment>();
        
        if(listAttachment != null && !listAttachment.isEmpty()){
            for(Attachment attachObj : listAttachment){
                system.debug('attachObj ::::::::'+attachObj);
                Messaging.EmailFileAttachment emailFileAttachment = new Messaging.EmailFileAttachment();
                emailFileAttachment.setContentType(attachObj.ContentType);
                emailFileAttachment.setFileName(attachObj.Name);
                emailFileAttachment.setInline(false);
                emailFileAttachment.Body = attachObj.Body;
                listEmailFileAttachment.add(emailFileAttachment);
            }
        }
        system.debug(listEmailFileAttachment.size()+' :::::::: listEmailFileAttachment ::::::::'+listEmailFileAttachment);
        system.debug('emailTemplateObj ::::::::'+emailTemplateObj);
        system.debug('name +++ '+name+' ++ email +++ '+email);
        
        if(String.isNotBlank(name) && String.isNotBlank(email) && emailTemplateObj != null && emailTemplateObj.id != null){
            Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();
            
            emailTemplateObj.HtmlValue = emailTemplateObj.HtmlValue.contains('{!MCare_Dashboard_Case__c.Merchant_Legal_Name__c}') ? emailTemplateObj.HtmlValue.replace('{!MCare_Dashboard_Case__c.Merchant_Legal_Name__c}', name) : emailTemplateObj.HtmlValue;
            emailTemplateObj.Subject = emailTemplateObj.Subject.contains('{!MCare_Dashboard_Case__c.Merchant_Id__c}') ? emailTemplateObj.Subject.replace('{!MCare_Dashboard_Case__c.Merchant_Id__c}', String.valueOf(sObjectData.get('Merchant_Id__c'))) : emailTemplateObj.Subject;
                       
            if(String.isNotBlank(email)) singleEmailMsg.setToAddresses(new String[] { email });
            if(String.isNotBlank(kamEmail)) singleEmailMsg.setCcAddresses(new String[] { kamEmail });            
            singleEmailMsg.setSubject(emailTemplateObj.Subject);
            singleEmailMsg.setHtmlBody(emailTemplateObj.HtmlValue);
            
            if(String.isNotBlank(OrgWideEmailAddId)) singleEmailMsg.setOrgWideEmailAddressId(OrgWideEmailAddId);
            
            if(!listEmailFileAttachment.isEmpty())
                singleEmailMsg.setFileAttachments(listEmailFileAttachment);
            
            List<Messaging.SendEmailResult> listSendEmailResult = Messaging.sendEmail(new Messaging.Singleemailmessage[] { singleEmailMsg });
            
            system.debug(listSendEmailResult.size()+' :::::::: listSendEmailResult ::::::::'+listSendEmailResult);
            
            return listSendEmailResult;
        }
        return null;
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
    }
    
    public class MCareDashWrapper{
        @AuraEnabled
        public MCare_Dashboard_Case__c MCareDashboardCaseObj {get; set;}
        
        @AuraEnabled
        public Opportunity opportunityObj {get; set;}
        
        @AuraEnabled
        public String userCurrentTheme {get; set;}
        
        @AuraEnabled
        public string response {get; set;}
    }
}