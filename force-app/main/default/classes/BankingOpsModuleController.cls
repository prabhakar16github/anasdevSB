/*
* Name of the class : BankingOpsModuleController
* Author's Name     : Rohit Gupta  
* Description       : This class is used for getting Postapproved records from Pricing Object.
* Version.          : 1   
*/ 
public with sharing class BankingOpsModuleController {
    public static Group gpNew = [Select Id,Name,DeveloperName FROM Group WHERE DeveloperName IN('Banking_Ops_Team') AND Type =: 'Queue'];  
    /*This method is used to return resopnse based on bank name and POR type selected and show it to the user on banking
ops page.*/
    @AuraEnabled
    public static DataTableResponse GetWrapperOfSObjectFieldColumnActionValues(String bankName,String porNameVar){
        SYstem.debug('bankName:::::'+bankName+' porNameVar::::::'+porNameVar);
        //List<Pricing__c> pri = new   List<Pricing__c>();
        List<DataTableColumns> lstDataColumns            = new List<DataTableColumns>();
        List<Object> lstDataTableData                    = new List<Object>();
        List<string> columnList                          = new List<string>();
        List<string> fieldAPINameList                    = new List<string>();
        List<Object> staticDataWithListData              = new List<Object>();
        Dynamic_Table_DataTable__mdt TableComponentMetadata = new  Dynamic_Table_DataTable__mdt();
        DataTableResponse finalWrapper   = new DataTableResponse();
        try{
            if(String.isNotEmpty(porNameVar) &&  String.isNotEmpty(bankName)){
                List<Pricing__c> pri  = [SELECT Bank_Name__c,POR_Type_Name__c,POR_File_NameFormula__c FROM Pricing__c WHERE Bank_Name__c =:bankName AND POR_Type_Name__c =:porNameVar AND Type__c='PostApproved'];
                System.debug('pri:::::'+pri);
                if(pri[0].POR_File_NameFormula__c !=Null){
                    TableComponentMetadata = [SELECT Id, DeveloperName,Field_Value__c,Banking_Details__c  , Header_Value__c, Query__c,Website_Page__c,
                                              Pricing_Query__c,Operating_Address__c, Table_Title__c FROM
                                              Dynamic_Table_DataTable__mdt WHERE DeveloperName =: pri[0].POR_File_NameFormula__c];
                }
                if(TableComponentMetadata.Header_Value__c != null) {
                    columnList = TableComponentMetadata.Header_Value__c.split(',');
                }
            } 
            Set<Id> oppId = new Set<Id>();
            Set<Id> pricingId = new Set<Id>();
            Set<Id> operatingAddId = new Set<Id>();
            Set<Id> websiteId = new Set<Id>();
            Set<Id> bankingId = new Set<Id>();
            for(Pricing__c pricing : [Select Payment_Gateway2__r.Name,Opportunity__c, Payment_Mode__r.Name FROM Pricing__c
                                      WHERE Bank_Name__c=:bankName AND POR_Type_Name__c=:porNameVar   AND
                                      (Banking_Ops_Status__c !='Pending with BH' AND Banking_Ops_Status__c !='Rejected with BH' AND Banking_Ops_Status__c !='Approved with BH' AND Banking_Ops_Status__c!=NULL) AND Type__c='PostApproved']){
                                          oppId.add(pricing.Opportunity__c);
                                          pricingId.add(pricing.Id);
                                      }
            if(TableComponentMetadata.Operating_Address__c !=null){
                for(Address_Details__c addressVar : [Select Address_Line__c FROM Address_Details__c WHERE Type__c=:'Operating' AND Opportunity__c=:oppId]){
                    operatingAddId.add(addressVar.Id);
                }
            }
            if(TableComponentMetadata.Website_Page__c !=null){
                for(Website_Page__c  websiteVar : [Select URL__c FROM Website_Page__c   WHERE Opportunity__c=:oppId]){
                    websiteId.add(websiteVar.Id);
                }
            }
            if(TableComponentMetadata.Banking_Details__c !=null){
                for(Bank_Account_Detail__c  bankingVar : [Select Account_Number__c FROM Bank_Account_Detail__c WHERE Opportunity__c=:oppId AND Active__c =true]){
                    bankingId.add(bankingVar.Id);
                }
            }
            if(TableComponentMetadata.Field_Value__c != null) {
                fieldAPINameList = TableComponentMetadata.Field_Value__c.split(',');
            }
            for(integer i = 0; i < columnList.size(); i++) {
                Boolean editableVar = Boolean.valueOf(fieldAPINameList[i].substringAfter(':').substringBefore('@').trim());
                DataTableColumns datacolumns = new DataTableColumns( columnList[i].trim() , fieldAPINameList[i].substringBefore(':').trim(), fieldAPINameList[i].substringAfter('@').trim(),
                                                                    editableVar);
                lstDataColumns.add(datacolumns);
            }
            if(TableComponentMetadata.Operating_Address__c !=null && TableComponentMetadata.Query__c !=null && TableComponentMetadata.Pricing_Query__c!=null && TableComponentMetadata.Website_Page__c==null && TableComponentMetadata.Banking_Details__c ==null){
                for(SObject SObjectItem : Database.query(TableComponentMetadata.Query__c +', ('+TableComponentMetadata.Pricing_Query__c+ ' WHERE Id=:pricingId LIMIT 1)' + ', ('+TableComponentMetadata.Operating_Address__c+ ' WHERE Id=:operatingAddId )'  + ' FROM Opportunity '+ ' WHERE Id=:oppId')) {
                    lstDataTableData.add(SObjectItem);
                }
            }
            else if(TableComponentMetadata.Operating_Address__c !=null && TableComponentMetadata.Query__c !=null && TableComponentMetadata.Pricing_Query__c!=null && TableComponentMetadata.Website_Page__c==null && TableComponentMetadata.Banking_Details__c !=null){
                for(SObject SObjectItem : Database.query(TableComponentMetadata.Query__c +', ('+TableComponentMetadata.Pricing_Query__c+ ' WHERE Id=:pricingId LIMIT 1)' + ', ('+TableComponentMetadata.Operating_Address__c+ ' WHERE Id=:operatingAddId )' + ', ('+TableComponentMetadata.Banking_Details__c+ ' WHERE Id=:bankingId )'  + ' FROM Opportunity '+ ' WHERE Id=:oppId')) {
                    lstDataTableData.add(SObjectItem);
                }
            }
            else if(TableComponentMetadata.Operating_Address__c !=null && TableComponentMetadata.Query__c !=null && TableComponentMetadata.Pricing_Query__c!=null && TableComponentMetadata.Website_Page__c!=null){
                for(SObject SObjectItem : Database.query(TableComponentMetadata.Query__c +', ('+TableComponentMetadata.Pricing_Query__c+ ' WHERE Id=:pricingId)' + ', ('+TableComponentMetadata.Operating_Address__c+ ' WHERE Id=:operatingAddId )'  + ', ('+TableComponentMetadata.Website_Page__c + ' WHERE Id=:websiteId)' + ' FROM Opportunity '+ ' WHERE Id=:oppId')) {
                    lstDataTableData.add(SObjectItem);
                }
            }
            else if(TableComponentMetadata.Operating_Address__c !=null && TableComponentMetadata.Query__c !=null && TableComponentMetadata.Banking_Details__c ==null){
                for(SObject SObjectItem : Database.query(TableComponentMetadata.Query__c +',('+TableComponentMetadata.Operating_Address__c+ ' WHERE Id=:operatingAddId )'  + ' FROM Opportunity '+ ' WHERE Id=:oppId')) {
                    lstDataTableData.add(SObjectItem);
                }
            }
            else if(TableComponentMetadata.Operating_Address__c !=null && TableComponentMetadata.Query__c !=null && TableComponentMetadata.Banking_Details__c !=null){
                for(SObject SObjectItem : Database.query(TableComponentMetadata.Query__c +', ('+TableComponentMetadata.Operating_Address__c+ ' WHERE Id=:operatingAddId )' + ', ('+TableComponentMetadata.Banking_Details__c+ ' WHERE Id=:bankingId )'  + ' FROM Opportunity '+ ' WHERE Id=:oppId')) {
                    lstDataTableData.add(SObjectItem);
                }
            }
            else if(TableComponentMetadata.Operating_Address__c ==null && TableComponentMetadata.Pricing_Query__c==null && TableComponentMetadata.Query__c !=null){
                for(SObject SObjectItem : Database.query(TableComponentMetadata.Query__c   + ' FROM Opportunity '+ ' WHERE Id=:oppId')) {
                    lstDataTableData.add(SObjectItem);
                }
            }
            else{
                if(TableComponentMetadata.Query__c !=null && TableComponentMetadata.Pricing_Query__c !=null){
                    for(SObject SObjectItem : Database.query(TableComponentMetadata.Query__c +', ('+TableComponentMetadata.Pricing_Query__c+ ' WHERE Id=:pricingId LIMIT 1)' +  ' FROM Opportunity '+ ' WHERE Id=:oppId')) {
                        lstDataTableData.add(SObjectItem);
                    }   
                }
            }
            finalWrapper.headerValue          = TableComponentMetadata.Header_Value__c;
            finalWrapper.lstDataTableColumns = lstDataColumns;
            finalWrapper.lstDataTableData    = lstDataTableData;
        }
        catch(Exception e) {
            finalWrapper.message = e.getMessage();
        } 
        return finalWrapper;
    }
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Boolean editable {get;set;}
        public DataTableColumns(String label, String fieldName,String type ,Boolean editable) {
            this.label     = label;
            this.fieldName = fieldName;
            this.type      = type;  
            this.editable =  editable;       
        }
    }
    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns {get;set;}
        @AuraEnabled
        public List<Object> lstDataTableData {get;set;}
        @AuraEnabled
        public String TableTitle {get;set;}   
        @AuraEnabled
        public String message {get;set;}  
        @AuraEnabled
        public String headerValue {get;set;}
    }
    // This method is used for filltering the records based on banking ops Request status field
    @AuraEnabled
    public static DataTableResponse getBankingPickListValues(String req,String bankName,String porNameVar){
        List<DataTableColumns> lstDataColumns            = new List<DataTableColumns>();
        List<SObject> lstDataTableData                   = new List<SObject>();
        List<string> columnList                          = new List<string>();
        List<string> fieldAPINameList                    = new List<string>();
        List<Pricing__c> pri = [SELECT Bank_Name__c,POR_Type_Name__c,POR_File_NameFormula__c FROM Pricing__c WHERE Bank_Name__c=:bankName AND POR_Type_Name__c=:porNameVar AND Type__c='PostApproved'];
        DataTableResponse finalWrapper   = new DataTableResponse();
        Dynamic_Table_DataTable__mdt TableComponentMetadata = [SELECT Id, DeveloperName,Website_Page__c, Field_Value__c,Banking_Details__c, Header_Value__c, Query__c,Pricing_Query__c ,Operating_Address__c,Table_Title__c FROM Dynamic_Table_DataTable__mdt WHERE DeveloperName =: pri[0].POR_File_NameFormula__c];
        try{
            if(TableComponentMetadata.Header_Value__c != null) {
                columnList = TableComponentMetadata.Header_Value__c.split(',');
            }
            Set<Id> websiteId = new Set<Id>();
            Set<Id> bankingId = new Set<Id>();
            List<Opportunity> oppListNew = new List<Opportunity>();
            Set<Id> oppId = new Set<Id>();
            Set<Id> pricingId = new Set<Id>();
            if(req !=NULL && req !='All Request' && req !='New Request'){
                for(Pricing__c pricing : [Select Payment_Gateway2__r.Name,Opportunity__c, Payment_Mode__r.Name FROM Pricing__c WHERE  Banking_Ops_Status__c=:req AND Bank_Name__c=:bankName AND POR_Type_Name__c=:porNameVar  AND
                                          (Banking_Ops_Status__c !='Pending with BH' AND Banking_Ops_Status__c !='Rejected with BH' AND Banking_Ops_Status__c !='Approved with BH' AND Banking_Ops_Status__c!=NULL) AND Type__c='PostApproved']){
                                              oppId.add(pricing.Opportunity__c);
                                              pricingId.add(pricing.Id);
                                          }
            }
            if(req !=NULL && req =='New Request'){
                List<Pricing__c> pricingList = [Select Payment_Gateway2__r.Name,Opportunity__c, Payment_Mode__r.Name,(SELECT Id,Oldvalue,newValue FROM Histories WHERE Field='Banking_Ops_Status__c')
                                                FROM Pricing__c WHERE Bank_Name__c=:bankName AND POR_Type_Name__c=:porNameVar AND Type__c='PostApproved' AND Banking_Ops_Status__c=:'Pending with Banking ops' AND Banking_Ops_Status__c!=NULL];
                for(Pricing__c pricing : pricingList){
                    if(pricing.Histories.size()==0){
                        oppId.add(pricing.Opportunity__c);
                        pricingId.add(pricing.Id); 
                    }
                }
            }
            if(req !=NULL && req =='All Request'){
                for(Pricing__c pricing : [Select Payment_Gateway2__r.Name,Opportunity__c, Payment_Mode__r.Name FROM Pricing__c WHERE  Bank_Name__c=:bankName AND POR_Type_Name__c=:porNameVar AND (Banking_Ops_Status__c !='Pending with BH' AND Banking_Ops_Status__c !='Rejected with BH' AND Banking_Ops_Status__c !='Approved with BH' AND Banking_Ops_Status__c!=NULL)]){
                    oppId.add(pricing.Opportunity__c);
                    pricingId.add(pricing.Id);
                }
            }
            Set<Id> operatingAddId = new Set<Id>();
            if(TableComponentMetadata.Operating_Address__c !=null){
                for(Address_Details__c addressVar : [Select Address_Line__c FROM Address_Details__c WHERE Type__c=:'Operating' AND Opportunity__c=:oppId]){
                    operatingAddId.add(addressVar.Id);
                }
            }
            if(TableComponentMetadata.Website_Page__c !=null){
                for(Website_Page__c  websiteVar : [Select URL__c FROM Website_Page__c   WHERE Opportunity__c=:oppId]){
                    websiteId.add(websiteVar.Id);
                }
            }
            if(TableComponentMetadata.Banking_Details__c !=null){
                for(Bank_Account_Detail__c  bankingVar : [Select Account_Number__c FROM Bank_Account_Detail__c WHERE Opportunity__c=:oppId AND Active__c =true]){
                    bankingId.add(bankingVar.Id);
                }
            }
            if(TableComponentMetadata.Field_Value__c != null) {
                fieldAPINameList = TableComponentMetadata.Field_Value__c.split(',');
            }
            for(integer i = 0; i < columnList.size(); i++) {
                Boolean editableVar = Boolean.valueOf(fieldAPINameList[i].substringAfter(':').substringBefore('@').trim());
                DataTableColumns datacolumns = new DataTableColumns( columnList[i].trim() , fieldAPINameList[i].substringBefore(':').trim(), fieldAPINameList[i].substringAfter('@').trim(),
                                                                    editableVar);
                lstDataColumns.add(datacolumns);
            } 
            if(TableComponentMetadata.Operating_Address__c !=null && TableComponentMetadata.Query__c !=null && TableComponentMetadata.Pricing_Query__c!=null && TableComponentMetadata.Website_Page__c==null && TableComponentMetadata.Banking_Details__c ==null){
                for(SObject SObjectItem : Database.query(TableComponentMetadata.Query__c +', ('+TableComponentMetadata.Pricing_Query__c+ ' WHERE Id=:pricingId LIMIT 1)' + ', ('+TableComponentMetadata.Operating_Address__c+ ' WHERE Id=:operatingAddId )'  + ' FROM Opportunity '+ ' WHERE Id=:oppId')) {
                    lstDataTableData.add(SObjectItem);
                }
            }
            else if(TableComponentMetadata.Operating_Address__c !=null && TableComponentMetadata.Query__c !=null && TableComponentMetadata.Pricing_Query__c!=null && TableComponentMetadata.Website_Page__c==null && TableComponentMetadata.Banking_Details__c !=null){
                for(SObject SObjectItem : Database.query(TableComponentMetadata.Query__c +', ('+TableComponentMetadata.Pricing_Query__c+ ' WHERE Id=:pricingId LIMIT 1)' + ', ('+TableComponentMetadata.Operating_Address__c+ ' WHERE Id=:operatingAddId )' + ', ('+TableComponentMetadata.Banking_Details__c+ ' WHERE Id=:bankingId )'  + ' FROM Opportunity '+ ' WHERE Id=:oppId')) {
                    lstDataTableData.add(SObjectItem);
                }
            }
            else if(TableComponentMetadata.Operating_Address__c !=null && TableComponentMetadata.Query__c !=null && TableComponentMetadata.Pricing_Query__c!=null && TableComponentMetadata.Website_Page__c!=null){
                for(SObject SObjectItem : Database.query(TableComponentMetadata.Query__c +', ('+TableComponentMetadata.Pricing_Query__c+ ' WHERE Id=:pricingId )' + ', ('+TableComponentMetadata.Operating_Address__c+ ' WHERE Id=:operatingAddId )'  + ', ('+TableComponentMetadata.Website_Page__c + ' WHERE Id=:websiteId)' + ' FROM Opportunity '+ ' WHERE Id=:oppId')) {
                    lstDataTableData.add(SObjectItem);
                }
            }
            else if(TableComponentMetadata.Operating_Address__c !=null && TableComponentMetadata.Query__c !=null && TableComponentMetadata.Banking_Details__c ==null){
                for(SObject SObjectItem : Database.query(TableComponentMetadata.Query__c +',('+TableComponentMetadata.Operating_Address__c+ ' WHERE Id=:operatingAddId )'  + ' FROM Opportunity '+ ' WHERE Id=:oppId')) {
                    lstDataTableData.add(SObjectItem);
                }
            }
            else if(TableComponentMetadata.Operating_Address__c !=null && TableComponentMetadata.Query__c !=null && TableComponentMetadata.Banking_Details__c !=null){
                for(SObject SObjectItem : Database.query(TableComponentMetadata.Query__c +', ('+TableComponentMetadata.Operating_Address__c+ ' WHERE Id=:operatingAddId )' + ', ('+TableComponentMetadata.Banking_Details__c+ ' WHERE Id=:bankingId )'  + ' FROM Opportunity '+ ' WHERE Id=:oppId')) {
                    lstDataTableData.add(SObjectItem);
                }
            }
            else if(TableComponentMetadata.Operating_Address__c ==null && TableComponentMetadata.Pricing_Query__c==null && TableComponentMetadata.Query__c !=null){
                for(SObject SObjectItem : Database.query(TableComponentMetadata.Query__c   + ' FROM Opportunity '+ ' WHERE Id=:oppId')) {
                    lstDataTableData.add(SObjectItem);
                }
            }
            else{
                if(TableComponentMetadata.Query__c !=null && TableComponentMetadata.Pricing_Query__c !=null){
                    for(SObject SObjectItem : Database.query(TableComponentMetadata.Query__c +', ('+TableComponentMetadata.Pricing_Query__c+ ' WHERE Id=:pricingId )' +  ' FROM Opportunity '+ ' WHERE Id=:oppId')) {
                        lstDataTableData.add(SObjectItem);
                    }   
                }
            }
            finalWrapper.TableTitle          = TableComponentMetadata.Table_Title__c;
            finalWrapper.lstDataTableColumns = lstDataColumns;
            finalWrapper.lstDataTableData    = lstDataTableData;
        }
        catch(Exception e) {
            finalWrapper.message = e.getMessage();
        } 
        return finalWrapper;
    }
    @AuraEnabled
    public static List<Pricing__c> getApprovedOrRejectedData(String appOrReject){
        System.debug('appOrReject:::::'+appOrReject);
        List<Pricing__c> priList;
        if(appOrReject !=NULL){
            priList  = [SELECT Remarks__c ,Banking_Ops_Status__c,Opportunity__r.Prod_Merchant_Id__c,Merchant_Name_Legal__c FROM Pricing__c WHERE Banking_Ops_Status__c =:appOrReject AND Type__c='PostApproved'];
            System.debug('priList:::;'+priList);
            if(priList !=NULL && priList.size()>0 ){
                return priList; 
            }
            else{
                
            }
        }
        return NULL;
    }
    
    //This method is used when status will change from 1st page of UI then based on status BO taks Owner Will be changed
    @AuraEnabled
    public static List<Pricing__c> getStatusValueUpdate(List<Pricing__c> pricingList, String statusvalue,String bankName,String PORName) {
        System.debug('pricingList:::277:'+pricingList);
        System.debug('pricingList:::277:'+pricingList.size());
        List<Pricing__c> pricingToUpdate =new  List<Pricing__c>();
        // this map created if pricing record get rejected
        Map<Id,Id> priMapId = new Map<Id,Id>();
        try{
            for(Pricing__c priVar : pricingList){
                priMapId.put(priVar.Opportunity__c,priVar.Id);
            }
            Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id,OwnerId FROM Opportunity WHERE Id=:priMapId.keySet()]);
            
            List<User> userList =[SELECT Id,Name FROM USER WHERE Bank__c INCLUDES (:bankName) AND POR_Type__c INCLUDES (:PORName)];
            for(Pricing__c pricing : [SELECT ID,Bank_Name__c,Commercial2__c,POR_Type_Name__c ,Below_Rack_Rates__c,Banking_Ops_Status__c,OwnerId, Opportunity__c FROM Pricing__c WHERE Bank_Name__c=:bankName AND POR_Type_Name__c=:PORName AND Opportunity__c=:oppMap.keySet()]){
                Opportunity opp = oppMap.get(pricing.Opportunity__c);
                if(!pricing.Below_Rack_Rates__c ){//This condition will store all the prciing records which has below rack rates
                    if(statusvalue=='Pending with KAM' && priMapId.containsKey(pricing.Opportunity__c)){
                        pricing.Banking_Ops_Status__c = statusvalue;
                        pricing.OwnerId = opp.OwnerId;
                        pricingToUpdate.add(pricing);
                    }
                    else if((statusvalue=='Pending with Banking ops' || statusvalue=='Approved' || statusvalue=='Rejected') && priMapId.containsKey(opp.Id)){
                        pricing.Banking_Ops_Status__c = statusvalue;
                        pricing.OwnerId = userList[0].Id;
                        pricingToUpdate.add(pricing);
                    }
                    else if(statusvalue=='Pending with Bank' && priMapId.containsKey(opp.Id) && userList !=NULL){
                        pricing.Banking_Ops_Status__c = statusvalue;
                        pricing.BO_Task_Owner_For_Bank__c  =  bankName;
                        pricingToUpdate.add(pricing);
                    }
                }
                //This condition will store If pricing has below rack rate and It is approved by BH
                else if(pricing.Below_Rack_Rates__c && (pricing.Banking_Ops_Status__c=='Approved with BH' || pricing.Banking_Ops_Status__c=='Pending with KAM' || pricing.Banking_Ops_Status__c=='Pending with Banking ops' ||  pricing.Banking_Ops_Status__c=='Rejected' || pricing.Banking_Ops_Status__c=='Approved' || pricing.Banking_Ops_Status__c=='Pending with Bank' )){
                    if(statusvalue=='Pending with KAM' && priMapId.containsKey(pricing.Opportunity__c)){
                        pricing.Banking_Ops_Status__c = statusvalue;
                        pricing.OwnerId = opp.OwnerId;
                        pricingToUpdate.add(pricing);
                    }
                    else if((statusvalue=='Pending with Banking ops' || statusvalue=='Approved' || statusvalue=='Rejected') && priMapId.containsKey(opp.Id)){
                        pricing.Banking_Ops_Status__c = statusvalue;
                        pricing.OwnerId = userList[0].Id;
                        pricingToUpdate.add(pricing);
                    }
                    else if(statusvalue=='Pending with Bank' && priMapId.containsKey(opp.Id) && userList !=NULL){
                        pricing.Banking_Ops_Status__c = statusvalue;
                        pricing.BO_Task_Owner_For_Bank__c =  bankName;
                        pricingToUpdate.add(pricing);
                    }
                }
            }
            if(pricingToUpdate.size()>0 && pricingToUpdate !=null){
                Database.update(pricingToUpdate,false); 
            } 
        }
        catch(Exception e) {
            e.getMessage();
        }
        return pricingToUpdate;
    }
    //This method is used when status will change from chatter page of UI then based on status BO taks Owner Will be changed
    //depending on the banking ops status
    @AuraEnabled
    public static String chatterStatusChange(String statusChangeValue,String recdId,String bankName,String porType){
        try{
            List<Pricing__c> priList = [SELECT ID,Bank_Name__c,POR_Type_Name__c ,Banking_Ops_Status__c,OwnerId, Opportunity__c FROM Pricing__c WHERE ID=: recdId];
            List<Pricing__c> pricingUpdate = new List<Pricing__c>();
            List<Opportunity> oppList = [SELECT OwnerId,(SELECT ID,Bank_Name__c,POR_Type_Name__c ,Banking_Ops_Status__c,OwnerId, Opportunity__c FROM Pricings__r WHERE Bank_Name__c=:priList[0].Bank_Name__c AND POR_Type_Name__c=:priList[0].POR_Type_Name__c ) from Opportunity WHERE ID=:priList[0].Opportunity__c];
            Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id,OwnerId FROM Opportunity WHERE Id=:priList[0].Opportunity__c]);
            List<User> userList =[SELECT Id,Name FROM USER WHERE Bank__c INCLUDES (:bankName) AND POR_Type__c INCLUDES (:porType)];
            for(Pricing__c pricing : [SELECT ID,Bank_Name__c,POR_Type_Name__c ,Below_Rack_Rates__c ,Commercial2__c,Banking_Ops_Status__c,OwnerId, Opportunity__c FROM Pricing__c WHERE Bank_Name__c=:priList[0].Bank_Name__c AND POR_Type_Name__c=:priList[0].POR_Type_Name__c AND Opportunity__c=:oppMap.keySet()]){
                Opportunity opp = oppMap.get(pricing.Opportunity__c);
                if(!pricing.Below_Rack_Rates__c ){
                    if(statusChangeValue !=NULL && statusChangeValue=='Pending with KAM'){
                        pricing.Banking_Ops_Status__c = statusChangeValue;
                        pricing.OwnerId = opp.OwnerId;
                        pricingUpdate.add(pricing);
                    }
                    else if(statusChangeValue !=NULL && (statusChangeValue=='Pending with Banking ops' || statusChangeValue=='Approved' || statusChangeValue=='Rejected')){
                        pricing.Banking_Ops_Status__c = statusChangeValue;
                        pricing.OwnerId = userList[0].Id;
                        pricingUpdate.add(pricing);
                    }
                    else if(statusChangeValue !=NULL && statusChangeValue=='Pending with Bank' && userList !=NULL){
                        pricing.Banking_Ops_Status__c = statusChangeValue;
                        pricing.BO_Task_Owner_For_Bank__c =  bankName;
                        pricingUpdate.add(pricing);
                    }
                }
                else if(pricing.Below_Rack_Rates__c && (pricing.Banking_Ops_Status__c=='Approved with BH' || pricing.Banking_Ops_Status__c=='Pending with KAM' || pricing.Banking_Ops_Status__c=='Pending with Banking ops' || pricing.Banking_Ops_Status__c=='Approved' ||  pricing.Banking_Ops_Status__c=='Rejected' || pricing.Banking_Ops_Status__c=='Pending with Bank' )){
                    if(statusChangeValue !=NULL && statusChangeValue=='Pending with KAM'){
                        pricing.Banking_Ops_Status__c = statusChangeValue;
                        pricing.OwnerId = opp.OwnerId;
                        pricingUpdate.add(pricing);
                    }
                    else if(statusChangeValue !=NULL && (statusChangeValue=='Pending with Banking ops' || statusChangeValue=='Approved' || statusChangeValue=='Rejected')){
                        pricing.Banking_Ops_Status__c = statusChangeValue;
                        pricing.OwnerId = userList[0].Id;
                        pricingUpdate.add(pricing);
                    }
                    else if(statusChangeValue !=NULL && statusChangeValue=='Pending with Bank' && userList !=NULL){
                        pricing.Banking_Ops_Status__c = statusChangeValue;
                        pricing.BO_Task_Owner_For_Bank__c =  bankName;
                        pricingUpdate.add(pricing);
                    }
                }
            }
            if(pricingUpdate !=null && pricingUpdate.size()>0){
                Database.update(pricingUpdate,false); 
            }
            if(statusChangeValue !=NULL && statusChangeValue=='Pending with KAM'){
                return [SELECT Owner.Name from Pricing__c WHERE ID=:pricingUpdate[0].Id].Owner.Name; 
            }
            if(statusChangeValue !=NULL && (statusChangeValue=='Pending with Banking ops' || statusChangeValue=='Approved' || statusChangeValue=='Rejected')){
                return [SELECT Owner.Name from Pricing__c WHERE ID=:pricingUpdate[0].Id].Owner.Name;
            }
            if(statusChangeValue !=NULL && statusChangeValue=='Pending with Bank'){
                return bankName;
            }
        }    
        catch(Exception e) {
            return e.getMessage(); 
        } 
        return null;
    }
    // This method is used to show details for Opportunity and Pricing record on banking ops chatter page
    @AuraEnabled
    public static List<Pricing__c> OpportunityDetailsWithPricig(Id recId){
        List<Pricing__c > priList = [SELECT Id,TDR__c ,TDR_Amount__c ,TDR_Flat_Fee__c,Opportunity__c, Opportunity__r.Prod_Merchant_Id__c,Opportunity__r.SubCategory__c ,
                                     Opportunity__r.PAN_Number_Account__c,Opportunity__r.Business_Category__c,
                                     Opportunity__r.Website__c,Opportunity__r.Legal_Name_Account__c  
                                     FROM Pricing__c WHERE ID=:recId];
        ActivityDetails(priList[0].Opportunity__c,priList[0].Id);
        return priList;
    }
    //This method is used when chnage status then based on status Bo task owner will be displayed on chatter page.
    @AuraEnabled
    public static String OwnerAssignmentLogic(String oppId,String bankingOpsStatus,String bankNameVal,String PORName){
        System.debug('oppId::::'+oppId + ' bankingOpsStatus::::'+bankingOpsStatus +'  bankNameVal::'+bankNameVal +'  PORName::'+PORName);
        try{
            if(bankingOpsStatus !=NULL && bankingOpsStatus=='Pending with KAM'){
                List<Opportunity> oppList = [SELECT Owner.Name from Opportunity WHERE ID=:oppId];
                return oppList[0].Owner.Name;
            }
            else if( bankingOpsStatus !=NULL && (bankingOpsStatus=='Pending with Banking ops' || bankingOpsStatus =='Approved'  || bankingOpsStatus =='Rejected')){
                List<User> userList =[SELECT Id,Name FROM USER WHERE Bank__c INCLUDES (:bankNameVal) AND POR_Type__c INCLUDES (:PORName)];
                return userList[0].Name;
            }
            else if(bankingOpsStatus !=NULL && bankingOpsStatus=='Pending with Bank' && bankNameVal !=null){
                return bankNameVal;
            }
        }
        catch(Exception e) {
            e.getMessage();
        }
        return null;
    }
    //This method is used to show activity  history on banking ops chatter page 
    @AuraEnabled
    public static List<BankingOpsModuleController.wrapperClass> ActivityDetails(Id oppRecId , Id pricingId){
        List<BankingOpsModuleController.wrapperClass> bankingWrapperList = new List<BankingOpsModuleController.wrapperClass>();
        try{
            List<OpportunityFieldHistory> oppFieldHistory =[SELECT  IsDeleted, OpportunityId, CreatedById,CreatedBy.Name, CreatedDate,
                                                            Field, DataType, OldValue, NewValue FROM OpportunityFieldHistory
                                                            Where OpportunityId=:oppRecId AND Field='Owner' Order by createdDate DESC];
            List<Pricing__History> pricingHistoryList = [SELECT CreatedById,CreatedDate ,CreatedBy.Name,DataType,toLabel(Field),Id,IsDeleted,OldValue,NewValue,ParentId
                                                         FROM Pricing__History  WHERE ParentId=:pricingId  Order by createdDate DESC];
            if(oppFieldHistory !=NULL && oppFieldHistory.size()>0){
                for(OpportunityFieldHistory oppHis : oppFieldHistory){
                    if(!(oppHis.OldValue instanceof Id) && !(oppHis.NewValue instanceof Id)){
                        BankingOpsModuleController.wrapperClass bankingWrapper = new BankingOpsModuleController.wrapperClass();
                        bankingWrapper.createdDate = oppHis.CreatedDate;
                        bankingWrapper.field = 'Opportunity '+oppHis.Field;
                        bankingWrapper.User = oppHis.CreatedBy.Name;
                        bankingWrapper.oldValue =String.valueOf(oppHis.OldValue); 
                        bankingWrapper.newValue = String.valueOf(oppHis.NewValue);
                        bankingWrapperList.add(bankingWrapper);  
                    }
                } 
            }
            if(pricingHistoryList !=NULL && pricingHistoryList.size()>0){
                for(Pricing__History pricingHis : pricingHistoryList){
                    if(!(pricingHis.OldValue instanceof Id) && !(pricingHis.NewValue instanceof Id)){
                        BankingOpsModuleController.wrapperClass bankingWrapper = new BankingOpsModuleController.wrapperClass();
                        bankingWrapper.createdDate = pricingHis.CreatedDate;
                        if(pricingHis.Field=='Owner')
                            bankingWrapper.field = 'BO Task '+pricingHis.Field;
                        else
                            bankingWrapper.field =pricingHis.Field;
                        bankingWrapper.User = pricingHis.CreatedBy.Name;
                        bankingWrapper.oldValue = String.valueOf(pricingHis.OldValue);
                        bankingWrapper.newValue = String.valueOf(pricingHis.NewValue);
                        bankingWrapperList.add(bankingWrapper); 
                    }
                }
            }
        }
        catch(Exception e) {
            System.debug('Message::::'+ e.getMessage()); 
        } 
        return bankingWrapperList;
    }
    @AuraEnabled
    public static  List<Bank_PORTypeMapping__c> getBankAndPorType(){
        List<Bank_PORTypeMapping__c> bankPorList = [SELECT Bank__c ,POR_File_Name__c ,POR_Type__c , Bank_Image__c  FROM Bank_PORTypeMapping__c];
        return bankPorList;
    }
    @AuraEnabled(cacheable=true)
    public static List<Bank_PORTypeMapping__c> searchBank(String searchTerm) {
        if(searchTerm.contains('-')){
            String[] searchTerms = searchTerm.split('-');
            String bankTerm = searchTerms[0].trim();
            String porTerm = searchTerms[1].trim();
            String query = 'SELECT  Bank__c, POR_File_Name__c,POR_Type__c,Bank_Image__c FROM Bank_PORTypeMapping__c WHERE Bank__c LIKE \'%' + bankTerm + '%\' AND POR_Type__c LIKE \'%' + porTerm + '%\'';
            return Database.query(query);
        }
        else{
            String query = 'SELECT Bank__c ,POR_File_Name__c ,POR_Type__c , Bank_Image__c FROM Bank_PORTypeMapping__c WHERE Bank__c LIKE \'%' + searchTerm + '%\'';
            return Database.query(query);
        }
    }
    @AuraEnabled
    public static List<Bank_PORTypeMapping__c> Requestsassignedtome(){
        String bank;
        List<String> porTypes = new List<String>();
        User usr = [SELECT Id,Bank__c,POR_Type__c  FROM USER WHERE ID=:UserInfo.getUserId()];
        // Get the Bank field value
        bank = usr.Bank__c;
        // Get the POR Type field values
        if (usr.POR_Type__c != null) {
            porTypes = usr.POR_Type__c.split(';');
        }
        System.debug('porTypes::::'+porTypes);
        List<Bank_PORTypeMapping__c> bankPorList = [SELECT Bank__c ,POR_File_Name__c ,POR_Type__c , Bank_Image__c  FROM Bank_PORTypeMapping__c WHERE Bank__c=:bank AND POR_Type__c=:porTypes];
        System.debug('bankPorList:::::'+bankPorList);
        return bankPorList;
    }
    //This method is used to retrun current logged in user profile name.
    @AuraEnabled
    public static Boolean getProfileName(){
        Id id1 = UserInfo.getProfileId();
        System.debug('id1:::::'+id1);
        List<Profile> profileName = [Select Name from Profile where Id =: id1];
        if(profileName !=NULL && profileName.size()>0){
            if(System.Label.Banking_Ops_Profile==profileName[0].Name){
                return true;
            }
            else{
                return false;
            }
        }
        return  true;
    }
    public class wrapperClass{
        @AuraEnabled
        public DateTime createdDate;
        @AuraEnabled
        public String field;
        @AuraEnabled
        public String oldValue;
        @AuraEnabled
        public String newValue;
        @AuraEnabled
        public String User;
    }
}