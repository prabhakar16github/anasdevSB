public class GMVUploadEmailServiceBatch implements Database.batchable<String>, Database.Stateful{
    
    public string fileData;
    public String rowDelimiterMatcher = '\n';
    public string platformName = '';
    
    public Iterable<String> start(Database.batchableContext batchableContext){ 
        // m_csvFile is blob data in csv file
        return new Utility_RowIterator(fileData, rowDelimiterMatcher);
    }
    
    public void execute(Database.BatchableContext batchableContext, List<String> scope){
        
        Boolean csvBizDataList = False;
        Boolean csvPayUmoneyDataList = False;
        
        if(!scope.isEmpty()){
            for(string eachString : scope){
                if(platformName == 'GMVBizUpload' && eachString.replaceAll( '\\s+', '').startsWith('Biz')){
                    csvBizDataList = true;
                }else if(platformName == 'GMVMoneyUpload' && eachString.replaceAll( '\\s+', '').startsWith('Money')){
                    csvPayUmoneyDataList = true;
                }
            }
            
            if(csvBizDataList){
                updateGMVBizData(scope);
            }
            if(csvPayUmoneyDataList){
                updateGMVMoneyData(scope);
            }
            if(platformName == 'NPSUpload'){
                updateNPSData(scope);
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){}
    
    public static void updateGMVBizData(List<String> csvBizDataList){
        System.debug('csvBizDataList:::'+csvBizDataList);
        Set<Integer> prodMids = New Set<Integer>();
        Map<Integer,Opportunity> prodMerchantIdOppMap = New Map<Integer,Opportunity>();
        List<Opportunity> oppObjList = New List<Opportunity>();
        String[] errorMessage = New List<String>();
        
        if(!csvBizDataList.isEmpty()){
            for(string eachString : csvBizDataList){
                if(eachString.replaceAll( '\\s+', '').startsWith('Biz')){
                    String[] inputvalues = new String[]{};
                        inputvalues = eachString.split(',');
                    if(Decimal.valueof(inputvalues[1]) != null){
                        prodMids.add(Integer.valueof(inputvalues[1]));
                    }
                }
            }
           SYstem.debug('prodMids:::::::'+prodMids); 
            if(!prodMids.isEmpty()){
                for(Opportunity eachOpp : [Select Id,Prod_Merchant_Id__c,GMV_Lifetime__c,Last_3_months_GMV__c,Merchant_Create_Date__c ,Last_12_months_GMV__c,YTD_GMV__c ,Identifier__c,
                                           Last_6_months_GMV__c,Chargeback_GMV__c,CB_Ratio__c,MTD_GMV__c,
                                           First_Txn_date__c,Last_txn_date__c,Last_1_month_GMV__c,Last_2_month_GMV__c From Opportunity Where Prod_Merchant_Id__c IN: prodMids AND Product__r.Name='PayU Biz']){
                                               prodMerchantIdOppMap.put(Integer.ValueOf(eachOpp.Prod_Merchant_Id__c),eachOpp);
                                           }
            }
            System.debug('prodMerchantIdOppMap::::::'+prodMerchantIdOppMap);
            if(!prodMerchantIdOppMap.isEmpty()){
                for(String eachRow : csvBizDataList){
                    String[] inputvalues = new String[]{};
                        inputvalues = eachRow.split(',');
                    if(eachRow.replaceAll( '\\s+', '').startsWith('Biz') && prodMerchantIdOppMap.containsKey(Integer.ValueOf(inputvalues[1]))){
                        Opportunity oppObj = prodMerchantIdOppMap.get(Integer.ValueOf(inputvalues[1]));
                        if(inputvalues[2] != '') oppObj.YTD_GMV__c  = Decimal.valueof(inputvalues[2]);
                        if(inputvalues[3] != '') oppObj.Last_3_months_GMV__c  = Decimal.valueof(inputvalues[3]);
                        if(inputvalues[4] != '') oppObj.Last_6_months_GMV__c  = Decimal.valueof(inputvalues[4]);
                        if(inputvalues[5] != '') oppObj.Last_12_months_GMV__c   = Decimal.valueof(inputvalues[5]);
                        if(inputvalues[6] != '') oppObj.Chargeback_GMV__c = Decimal.valueof(inputvalues[6]);
                        if(inputvalues[7] != '') oppObj.CB_Ratio__c  = Decimal.valueof(inputvalues[7]);
                        if(inputvalues[8] != '') oppObj.MTD_GMV__c  = Decimal.valueof(inputvalues[8]);
                        if(inputvalues[9] != ''){
                           oppObj.Merchant_Create_Date__c = setStringToDateFormat(inputvalues[9].replaceAll( '\\s+', ''));  
                        }
                        if(inputvalues[10] != ''){
                           oppObj.Last_txn_date__c = setStringToDateFormat(inputvalues[10].replaceAll( '\\s+', '')); 
                        }
                        /** SFI-927 added by Rahul Pandey***/
                        if(inputvalues[11] != '') oppObj.Last_1_month_GMV__c  = Decimal.valueof(inputvalues[11]);
                        if(inputvalues[12] != '') oppObj.Last_2_month_GMV__c  = Decimal.valueof(inputvalues[12]);
                        
                        oppObj.GMV_Latest_Date__c = Date.today();
                        oppObjList.add(oppObj);
                    }
                }
            }
            System.debug('@@@@@ oppObjList '+oppObjList);
            System.debug('Opportunity.Identifier__c--------->'+Opportunity.Identifier__c.getDescribe().getSObjectField());
            if(!oppObjList.isEmpty() && oppObjList.size()>0) {
                OpportunityTriggerHandler.publishUpdateFromApex = false;
                Database.UpsertResult[] results = Database.upsert(oppObjList, Opportunity.Identifier__c.getDescribe().getSObjectField(), false);
                System.debug('results::::::'+results);
                for(Integer i=0;i<results.size();i++){
                    if (!results.get(i).isSuccess()){
                        Database.Error err = results.get(i).getErrors().get(0);
                        errorMessage.add('Biz GMV Upload Error - '+err.getMessage()+'\n Fields : '+err.getFields());
                        System.debug('Error - '+err.getMessage() + '\nStatus Code : '+err.getStatusCode()+'\n Fields : '+err.getFields());
                    }
                }
            }
            
            if(!errorMessage.isEmpty()){
                // error email
                Error_Details__c objErrorLog = new Error_Details__c();
                objErrorLog.Message__c = 'Batch Class - '+errorMessage;
                objErrorLog.Process__c = 'Biz - GMV upload Email Service failed';
                insert objErrorLog;
            }
        }
    }
    
    public static void updateGMVMoneyData(List<String> csvMoneyDataList){
        List<Opportunity> oppObjList = New List<Opportunity>();
        String[] errorMessage = New List<String>();
        
        if(!csvMoneyDataList.isEmpty()){
            for(string eachString : csvMoneyDataList){
                if(eachString.replaceAll( '\\s+', '').startsWith('Money')){
                    String[] inputvalues = new String[]{};
                        inputvalues = eachString.split(',');
                    Opportunity oppObj = New Opportunity(Identifier__c = inputvalues[13]);
                    if(inputvalues[2] != '') oppObj.GMV_Lifetime__c = Decimal.valueof(inputvalues[2]);
                    if(inputvalues[3] != '') oppObj.Last_3_months_GMV__c  = Decimal.valueof(inputvalues[3]);
                    if(inputvalues[4] != '') oppObj.Last_6_months_GMV__c  = Decimal.valueof(inputvalues[4]);
                    if(inputvalues[5] != '') oppObj.Chargeback_GMV__c = Decimal.valueof(inputvalues[5]);
                    if(inputvalues[6] != '') oppObj.CB_Ratio__c  = Decimal.valueof(inputvalues[6]);
                    if(inputvalues[7] != '') oppObj.MTD_GMV__c  = Decimal.valueof(inputvalues[7]);
                    if(inputvalues[8] != '') oppObj.First_Txn_date__c = setStringToDateFormat(inputvalues[8].replaceAll( '\\s+', ''));
                    if(inputvalues[9] != '') oppObj.Last_txn_date__c  = setStringToDateFormat(inputvalues[9].replaceAll( '\\s+', ''));
                    if(inputvalues[10] !='') oppObj.SE_Date__c = setStringToDateFormat(inputvalues[10].replaceAll( '\\s+', ''));
                    if(inputvalues[11] != '') oppObj.Last_1_month_GMV__c  = Decimal.valueof(inputvalues[11]);
                    if(inputvalues[12] != '') oppObj.Last_2_month_GMV__c = Decimal.valueof(inputvalues[12]);
                    oppObj.GMV_Latest_Date__c = Date.today();
                    oppObjList.add(oppObj);
                }
            }
            if(!oppObjList.isEmpty() && oppObjList.size()>0) {
                OpportunityTriggerHandler.publishUpdateFromApex = false;
                Database.UpsertResult[] results = Database.upsert(oppObjList, Opportunity.Identifier__c.getDescribe().getSObjectField(), false);
                
                for(Integer i=0;i<results.size();i++){
                    if (!results.get(i).isSuccess()){
                        Database.Error err = results.get(i).getErrors().get(0);
                        errorMessage.add('PayU Money GMV Upload Error - '+err.getMessage()+'\n Fields : '+err.getFields());
                        System.debug('Error - '+err.getMessage() + '\nStatus Code : '+err.getStatusCode()+'\n Fields : '+err.getFields());
                    }
                }
            }
        }
    }
    
    public static void updateNPSData(List<String> csvNPSDataList){
        Set<Integer> prodMids = New Set<Integer>();
        Map<Integer,Opportunity> prodMerchantIdOppMap = New Map<Integer,Opportunity>();
        List<Opportunity> oppObjList = New List<Opportunity>();
        String[] errorMessage = New List<String>();
        Set<String> emailIdSet = New Set<String>();
        
        if(!csvNPSDataList.isEmpty()){
            for(string eachString : csvNPSDataList){
                if(eachString.replaceAll( '\\s+', '').startsWith('Any')){
                    String[] inputvalues = new String[]{};
                        inputvalues = eachString.split(',');
                    if(Decimal.valueof(inputvalues[1]) != null){
                        prodMids.add(Integer.valueof(inputvalues[1]));
                    }
                    if(String.valueof(inputvalues[2]) != null){
                        emailIdSet.add(String.valueof(inputvalues[2]));
                    }
                }
            }
            
            if(!prodMids.isEmpty()){
                for(Opportunity eachOpp : [Select Id,Prod_Merchant_Id__c,NPS_Score__c,NPS_Comments__c,NPS_Segment__c,Identifier__c
                                           From Opportunity Where Prod_Merchant_Id__c IN: prodMids AND Email__c IN: emailIdSet]){
                                               prodMerchantIdOppMap.put(Integer.ValueOf(eachOpp.Prod_Merchant_Id__c),eachOpp);
                                           }
            }
            
            if(!prodMerchantIdOppMap.isEmpty()){
                for(String eachRow : csvNPSDataList){
                    if(eachRow.replaceAll( '\\s+', '').startsWith('Any')){
                        String[] inputvalues = new String[]{};
                            inputvalues = eachRow.split(',');
                        if(prodMerchantIdOppMap.containsKey(Integer.ValueOf(inputvalues[1]))){
                            Opportunity oppObj = prodMerchantIdOppMap.get(Integer.ValueOf(inputvalues[1]));
                            if(inputvalues[3] != '') oppObj.NPS_Score__c = String.valueof(inputvalues[3]);
                            if(inputvalues[4] != '') oppObj.NPS_Comments__c  = String.valueof(inputvalues[4]);
                            if(inputvalues[5] != '') oppObj.NPS_Segment__c  = String.valueof(inputvalues[5]);
                            oppObjList.add(oppObj);
                        }
                    }
                }
            }
            
            if(!oppObjList.isEmpty() && oppObjList.size()>0) {
                OpportunityTriggerHandler.publishUpdateFromApex = false;
                Database.UpsertResult[] results = Database.upsert(oppObjList, Opportunity.Identifier__c.getDescribe().getSObjectField(), false);
                
                for(Integer i=0;i<results.size();i++){
                    if (!results.get(i).isSuccess()){
                        Database.Error err = results.get(i).getErrors().get(0);
                        errorMessage.add('NPS Upload Error - '+err.getMessage()+'\n Fields : '+err.getFields());
                        System.debug('Error - '+err.getMessage() + '\nStatus Code : '+err.getStatusCode()+'\n Fields : '+err.getFields());
                    }
                }
            }
            
            if(!errorMessage.isEmpty()){
                // error email
                Error_Details__c objErrorLog = new Error_Details__c();
                objErrorLog.Message__c = 'Batch Class - '+errorMessage;
                objErrorLog.Process__c = 'NPS upload Email Service failed';
                insert objErrorLog;
            }
        }
    }
    @testvisible
    private static Date setStringToDateFormat(String myDate) {
        system.debug('@@@@ myDate '+myDate);
        String[] myDateOnly = myDate.split(' ');
        system.debug('@@@@ myDateOnly '+myDateOnly);
        if(myDateOnly[0].contains('/')){
            String[] strDate = myDateOnly[0].split('/');
            system.debug('@@@@ strDate '+strDate);
            Integer myIntDate = integer.valueOf(strDate[1]);
            system.debug('@@@@ myIntDate '+myIntDate);
            Integer myIntMonth = integer.valueOf(strDate[0]);
            Integer myIntYear = integer.valueOf(strDate[2]);
            Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
            return d;
        }else if(myDateOnly[0].contains('-')){
            String[] strDate = myDateOnly[0].split('-');
            system.debug('@@@@ strDate '+strDate);
            Integer myIntDate = integer.valueOf(strDate[2]);
            system.debug('@@@@ myIntDate '+myIntDate);
            Integer myIntMonth = integer.valueOf(strDate[1]);
            Integer myIntYear = integer.valueOf(strDate[0]);
            Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
            return d;
        }else
            return Date.parse(myDate);
    }
}