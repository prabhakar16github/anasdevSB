/**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       Apex class manages the code of CSAT Form
@history
<Date>        <Authors Name>        <Brief Description of Change>
11-Mar-19    Eitika Verma          created
**/
public class csatFormController {

     /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     this method is used to display the content of page and set in wrapper
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    11-Mar-19     Eitika Verma          created
    */
    @AuraEnabled
    public static string getPageContent(string caseId){
        //variable
        list<feedbackWrapper> lstFeedbackWrapper = new list<feedbackWrapper>();
        
        //first check feedback is already given or not. If yes then block the user
        if(!checkfeedbackValue(caseId)){
            string htmlBodyContent = getEmailMergeBodyContent(caseId);
            system.debug('htmlBodyContent======='+htmlBodyContent);
            //get the data from custom setting
            for(LP_CsatFormValues__c eachValue : LP_CsatFormValues__c.getAll().Values()){
                system.debug('eachValue======='+eachValue.LP_LabelValue__c);
                list<picklistWrapper> lstPickWrapper = new list<picklistWrapper>();
                feedbackWrapper objWrapper = new feedbackWrapper();
                objWrapper.starNum = eachValue.Name;
                objWrapper.starValue = eachValue.LP_starValue__c;
                objWrapper.labelVal = eachValue.LP_LabelValue__c;
                for(string eachPicklistVal : eachValue.LP_feedbackValue__c.split(';')){
                    picklistWrapper objPickWrap = new picklistWrapper();
                    objPickWrap.label = eachPicklistVal;
                    objPickWrap.value = eachPicklistVal;
                    lstPickWrapper.add(objPickWrap);
                }
                objWrapper.lstselectedVal = new list<string>();
                objWrapper.lstfeedback = lstPickWrapper;
                lstFeedbackWrapper.add(objWrapper);
            }
            system.debug('lstFeedbackWrapper======='+lstFeedbackWrapper);
            csatWrapper objWrapper = new csatWrapper();
            objWrapper.bodyVal = htmlBodyContent;
            objWrapper.isShow = true;
            objWrapper.lstFeedbackWrap = lstFeedbackWrapper;
            return JSON.serialize(objWrapper);
        }
        else{
            csatWrapper objWrapper = new csatWrapper();
            objWrapper.isShow = false;
            return JSON.serialize(objWrapper);
        }
    }
    
    /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     this method is used to save the data of csat form on case
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    11-Mar-19     Eitika Verma          created
    */
     @AuraEnabled
    public static void saveCSATData(string csatData){
        system.debug('csatData======='+csatData);
        if(String.isNotBlank(csatData)){
            map<string,Object> mapOfFeedbackForm = (Map<String, Object>)JSON.deserializeUntyped(csatData);
            Case objCase = new Case();
            objCase.put('id',mapOfFeedbackForm.get('caseId'));
            objCase.put('LP_Rating__c',mapOfFeedbackForm.get('ratingNum'));
            objCase.put('LP_Customer_Feedback__c',mapOfFeedbackForm.get('ratingVal'));
            objCase.put('LP_Customer_Comments__c',mapOfFeedbackForm.get('comment'));

            string custSubVal = '';
            for(Object eachString : (list<Object>)mapOfFeedbackForm.get('selectedOptions')){
                custSubVal += (String)eachString + ';';
            }
            custSubVal = custSubVal.removeEnd(';');
            objCase.put('LP_Customer_Sub_Feedback__c',custSubVal);
            
            update objCase;
        }
    }
    
    public static boolean checkfeedbackValue(string strCaseId){
        if(String.isNotBlank(strCaseId)){
            list<Case> lstCase = [SELECT LP_Customer_Feedback__c FROM Case WHERE Id=:strCaseId];
            if(lstCase != NULL && lstCase.size()>0){
                if(lstCase[0].LP_Customer_Feedback__c != NULL){
                    return true;
                }
            }
        }
        return false;
    }
    
    
    /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     this method is used to get the page content from custom metadata and data binding of case fields
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    11-Mar-19     Eitika Verma          created
    */
    public static string getEmailMergeBodyContent(string caseID){
        System.debug('caseID======'+caseID);
        string strbodyContent ='';
        //get the Data From Custom Metadata
        list<PayloadActMap__mdt> lstPayload = [SELECT JsonMap__c,JSONMapPub__c,Field_To_Query__c,Sobject__c FROM PayloadActMap__mdt WHERE DeveloperName='CareCSATForm'];
        
        System.debug('lstPayload======'+lstPayload);
        if(lstPayload != NULL && lstPayload.size()>0){
            PayloadActMap__mdt objPayload = lstPayload[0];
            List<sobject>lstCase = getAllFieldsOfObject(caseID,'Id',objPayload);
            System.debug('lstCase========'+lstCase);
            if(lstCase != null && lstCase.size()>0 && objPayload != NULL){
                map<string,Object> mapOfFieldMapping = (map<string,Object>)JSON.deserializeUntyped(objPayload.JsonMap__c);
                sObject objCase = lstCase[0];
                strbodyContent = objPayload.JSONMapPub__c;
                if(mapOfFieldMapping != NULL && mapOfFieldMapping.size()>0){
                    for(string eachKey : mapOfFieldMapping.keyset()){
                        if(strbodyContent.contains(eachKey)){
                            string strReplace = '{!'+eachKey+'}';
                            if(mapOfFieldMapping.get(eachKey) != NULL){
                                string strValue = String.ValueOf(mapOfFieldMapping.get(eachKey));
                                if(strValue.contains('.')){
                                    string strReplaceContent = strbodyContent.replace(strReplace, String.ValueOf(objCase.getSObject(strValue.substringBefore('.')).get(strValue.substringAfter('.'))));
                                	strbodyContent = strReplaceContent;
                                }
                                else{
                                    string strReplaceContent = strbodyContent.replace(strReplace, String.ValueOf(objCase.get(strValue)));
                                	strbodyContent = strReplaceContent;
                                }
                            }
                        }
                    }
                }
            }
    	}
        return strbodyContent;
    }
    
    /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     this method is used to get all field values of case from database
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    11-Mar-19     Eitika Verma          created
    */
    public static List<sobject> getAllFieldsOfObject(string action,string fieldname,PayloadActMap__mdt objMapping)
    {       
        string query;
        if(objMapping != NULL){
            query = 'select ';
            query += objMapping.Field_To_Query__c +' FROM ' + objMapping.Sobject__c + ' WHERE '+fieldname+ '=\'' + action +'\'';
        	system.debug('<<>>'+ query);
        }
        return  Database.query(query);
    }
    
    
    //main wrapper classes
    public class csatWrapper{
        public string bodyVal;
        public boolean isShow;
        public list<feedbackWrapper> lstFeedbackWrap;
    }
    
    //wrapper holds the picklist value
    public class picklistWrapper{
        public string label;
        public string value; 
    }
    
    //wrapper holds the selected values of star and feedback
    public class feedbackWrapper{
        public string starNum;
        public string starValue;
        public string labelVal;
        public list<string> lstselectedVal;
        public list<picklistWrapper> lstfeedback;
    }
}