global class SendManualCallBatch implements Database.batchable <sObject>,Database.Stateful{
    global string strCondition;
    global map<string,Id> mapOfQueueVsQueueId ;
    global List<PayloadActMap__mdt> payloadList;
    global map <string , string> mapOfAgencynamewithCode; 
    global map<string , string> mapOfAgencynamewithOpsPanelKey ;
    
    global SendManualCallBatch(){
        mapOfQueueVsQueueId = new map<string,Id>();
        payloadList = CollectionNotificationUtility.getPayLoadMap('Manual_call'); 
        strCondition = CollectionNotificationUtility.getWhereConditionFromMtdt('Manual_call');
    } 
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        mapOfAgencynamewithCode = new map<string , string>();
        mapOfAgencynamewithOpsPanelKey = new map<string , string>();
        list<Agency__c> listOfAgency = [select id,Name,Agency__c,Agency_Code__c,Ops_Panel_Key__c from Agency__c];
        for(Agency__c each: listOfAgency){
            mapOfAgencynamewithCode.put(each.name, each.Agency_Code__c);
            mapOfAgencynamewithOpsPanelKey.put(each.name, each.Ops_Panel_Key__c);
        }
        
        
        if(mapOfQueueVsQueueId != NULL && mapOfQueueVsQueueId.size() ==0){
            list<string> lstQueues = new list<string>{'LP_Manual_Call_Queue_Collection'};
                mapOfQueueVsQueueId = SystemUtility.getQueuesInfo(lstQueues);
        }
        String dateStr = Date.today().format();
        string strquery = 'SELECT id,ContactId,Contact.Phone,Contact.Name,Status,LP_Mobile_Pay_URL__c,LP_Total_Late_Fee__c,Contact.MobilePhone,LP_Email_Template_Name__c,LP_Due_Since__c,LP_Outstanding_Amount__c,LP_UUID_For_Collection__c,Contact.Email,LP_Late_fee_amount__c,LP_APP_Notification__c,Agency__c,LP_Email__c,LP_IVR_Call__c,LP_Manual_Call__c,LP_SMS__c,Collection_Rule_Time__c ';
        strquery += ' FROM Case WHERE recordtype.developername = \'Collection\' AND  Collection_Rule_Time__c= \''+ dateStr +'\' AND ownerId =\''+mapOfQueueVsQueueId.get('LP_Manual_Call_Queue_Collection') +'\'';
        if(String.isNotBlank(strCondition))
            strquery += ' AND '+ strCondition;
        strquery += ' order by LP_Status_Priority_Order__c desc';
        return Database.getQueryLocator(strquery);
    }
    
    global void execute(Database.BatchableContext info, List<Case> scope){
      /*  System.debug('Total data in scope : ' + scope.size());
        list<case> listofcase = new list<case>();
        list<Manual_Call_Detail__c> lstManualCalldeatil = new list<Manual_Call_Detail__c>();
        for(Case eachCase : scope){
            System.debug('Each Case : ' + eachCase);
            if(eachCase.LP_Manual_Call__c != NULL && eachCase.LP_Manual_Call__c > 0){
                Manual_Call_Detail__c objmanualcall = new Manual_Call_Detail__c();
                //objmanualcall.Due_Date__c = Ishant Please confirm
                objmanualcall.Due_Since__c = string.valueOf(eachCase.LP_Due_Since__c);
                objmanualcall.Email__c = eachCase.contact.Email;
                objmanualcall.Contact_Name__c = eachCase.contact.Name;
                objmanualcall.Case__c = eachCase.id; 
                objmanualcall.Case_status__c = eachCase.Status;
                objmanualcall.mobile__c = eachCase.Contact.MobilePhone; 
                objmanualcall.Agency__c = eachCase.Agency__c;
                objmanualcall.LP_Total_Late_Fee__c = eachCase.LP_Total_Late_Fee__c;
                objmanualcall.AGENCY_CODE__c = mapOfAgencynamewithCode.get(eachCase.Agency__c);
                objmanualcall.OPS_Panel_Key__c = mapOfAgencynamewithOpsPanelKey.get(eachCase.Agency__c);
                objmanualcall.ApiStatus__c      =  true;
                objmanualcall.Outstanding_Amount__c = eachCase.LP_Outstanding_Amount__c;
                objmanualcall.InQueue__c= true;
                objmanualcall.Payment_Link__c = eachCase.LP_Mobile_Pay_URL__c;
                objmanualcall.UUID__c = eachCase.LP_UUID_For_Collection__c;
                system.debug('objmanualcall'+objmanualcall);
                lstManualCalldeatil.add(objmanualcall);
            }
        }
        system.debug('lstManualCalldeatil'+ lstManualCalldeatil.size());
        insert lstManualCalldeatil;
     */
        
    }
    global void finish(Database.BatchableContext info){  
    }
    
}