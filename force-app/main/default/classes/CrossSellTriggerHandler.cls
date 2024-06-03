public class CrossSellTriggerHandler {
    public static Id productCrossSellRecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Product Cross-Selling').getRecordTypeId();
    public static Id InstantSettlementRecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Instant Settlement').getRecordTypeId();
    
    public static void beforeInsertHandler(List<Cross_Sell__c> triggerNew){
        List<Opportunity> opList = new List<Opportunity>();
        List<Cross_Sell__c> CrossSellListToDelete = new List<Cross_Sell__c>();
        Map<String,String> oppIdVsProdNameMap = new Map<String,String>();
        Map<String,String> oppIdVsProdNameMapFinal = new Map<String,String>();
        Set<Id> opIdSet = new Set<Id>();
        Map<Id,Opportunity> oppObjMap = new Map<Id,Opportunity>();
        Set<String> prodNameSet = New Set<String>();
        List<Task> taskList = New List<Task>();
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Cross_Sell__c');
        String sources = system.Label.CrossSell_Source;
        List<String> sourceList = sources.split(',');
        Map<String,String> prodIdVsNameMap = new Map<String,String>();
        Map<String,String> crossSellProductAndUserIdMap =(Map<String, String>)JSON.deserialize(system.label.CrossSell_ProductAndUserIdMap, Map<String, String>.class);
        List<Cross_Sell__c> existingCrossSell = New List<Cross_Sell__c>();
        
        for(Product__c prod: [SELECT Id, Name FROM Product__c LIMIT 20]){
            prodIdVsNameMap.put(prod.Id,prod.Name);
        }
        
        //Map<Id,Opportunity> oppMIDsMap = New Map<Id,opportunity>();
        Date gmvLatestDate ;
        Date todaysDate ;
        Integer gmvAging;
        
        for(Cross_Sell__c cs: triggerNew){ 
            SystemUtility.getIdentifierUUID(cs, 'Identifier__c', enableUUIDObj);
            if(String.isNotBlank(cs.Opportunity__c)){
                oppObjMap.put(cs.Opportunity__c,null);
                if(String.isNotBlank(cs.Custom_Product__c) && (String.isBlank(cs.Name) || (String.isNotBlank(cs.Name) && cs.Name.startsWith('a29')))){
                    cs.Name = prodIdVsNameMap.get(cs.Custom_Product__c);
                }
                if(String.isNotBlank(cs.Product_Name__c)){
                    prodNameSet.add(cs.Product_Name__c);
                }else if(String.isBlank(cs.Product_Name__c)){
                    cs.Product_Name__c = 'PayU Money';
                    prodNameSet.add(cs.Product_Name__c);
                }
            }
        }
        
        If(!oppObjMap.isEmpty() && !prodNameSet.isEmpty()){
            List<Cross_Sell__c> updatelist= new list<Cross_Sell__c>();
            for(Opportunity each : [Select Id,Product_Name__c,Email__c,GMV_Latest_Date__c,Key_Assigned_Manager__c,(Select Id,Risk_Status__c,Risk_Rejection_Aging__c,Risk_Zone__c,Kam_Status__c,Re_Uploaded_Count__c,KAM_Comment__c,Enable_Date__c,Source__c,Priority__c,Custom_Product__c,RecordTypeId,Opportunity__c,Custom_Product__r.Name,Cross_Sell_Stop_Task_Creation__c From Cross_Sells__r) from Opportunity Where Id IN: oppObjMap.keySet()]){
                oppObjMap.put(each.Id,each);
                gmvLatestDate = each.GMV_Latest_Date__c;
                todaysDate = Date.today();
                if(gmvLatestDate != null){
                    gmvAging = gmvLatestDate.daysBetween(todaysDate);
                }else{
                    gmvAging = 31;
                }
                
                If(each.Cross_Sells__r.size() > 0) existingCrossSell = each.Cross_Sells__r;
            }
            
            if(existingCrossSell.size()>0){
                for(Cross_Sell__c cs: triggerNew){
                    
                    for(Cross_Sell__c existingCs: existingCrossSell){
                        If(cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId){
                            if(cs.Custom_Product__c == existingCs.Custom_Product__c && existingCs.Opportunity__c==cs.Opportunity__c){
                                if(!cs.Is_Migrated__c){
                                    if(existingCs.Risk_Status__c == 'Approved' && existingCs.Kam_Status__c == 'Merchant Accepted'){
                                        cs.addError('Cross Sell with Same Product already exist.');
                                    }else if(((gmvAging <= 30 && existingCs.Risk_Status__c == 'Rejected' && existingCs.Risk_Rejection_Aging__c >= 30) || ((existingCs.Risk_Status__c == 'Pending' && existingCs.Risk_Zone__c == 'Amber Zone' && prodIdVsNameMap.get(cs.Custom_Product__c) == 'T+0') || (existingCs.Risk_Status__c == 'Approved' && existingCs.Risk_Zone__c == 'Green Zone' && prodIdVsNameMap.get(cs.Custom_Product__c) == 'T+0') || (existingCs.Risk_Status__c == 'Pending' || prodIdVsNameMap.get(cs.Custom_Product__c) == 'MCP')) && System.isBatch() == false)){
                                        If(cs.Enable_Date__c != null) existingCs.Enable_Date__c =cs.Enable_Date__c;
                                        If(cs.RecordTypeId != null) existingCs.RecordTypeId = cs.RecordTypeId;
                                        //existingCs.Opportunity__c = cs.Opportunity__c;
                                        If(String.isNotBlank(cs.Priority__c)) existingCs.Priority__c = cs.Priority__c;
                                        If(String.isNotBlank(cs.Source__c)) existingCs.Source__c = cs.Source__c;
                                        if((existingCs.Risk_Status__c == 'Rejected' && existingCs.Risk_Rejection_Aging__c >= 0) || (existingCs.Risk_Status__c == 'Pending' && existingCs.Risk_Zone__c == 'Amber Zone')){
                                            existingCs.Risk_Status__c = 'Re-Engaged';
                                        }
                                        If(String.isNotBlank(cs.Custom_Product__c)) existingCs.Custom_Product__c = cs.Custom_Product__c;
                                        existingCs.Active__c = true;
                                        if(existingCs.Re_Uploaded_Count__c == null){
                                            existingCs.Re_Uploaded_Count__c = 1;
                                        }else{
                                            existingCs.Re_Uploaded_Count__c = existingCs.Re_Uploaded_Count__c+1; 
                                        }
                                        existingCs.KAM_Comment__c = '';
                                        updatelist.add(existingCs); 
                                        //oppMIDsMap.put(each.Id,each);
                                        
                                        if((existingCs.Risk_Status__c == 'Approved')){
                                            //Task task = getTaskCreate(existingCs.Opportunity__c,oppMIDsMap,prodIdVsNameMap.get(existingCs.Custom_Product__c)+' Merchant Interested And Risk Approved','','',crossSellProductAndUserIdMap);
                                            Task task = getTaskCreate(existingCs.Opportunity__c,oppObjMap,prodIdVsNameMap.get(existingCs.Custom_Product__c)+' Merchant Interested And Risk Approved','','',crossSellProductAndUserIdMap);
                                            task.Priority = 'High';
                                            taskList.add(task);
                                        }else if((existingCs.Risk_Status__c == 'Rejected' && existingCs.Risk_Rejection_Aging__c >= 0) || (existingCs.Risk_Status__c == 'Pending')){
                                            String queueName = '';
                                            if(prodIdVsNameMap.get(cs.Custom_Product__c) == 'MCP'){
                                                queueName = 'Cross_Sell_Risk_Team';
                                            }else if(prodIdVsNameMap.get(cs.Custom_Product__c) == 'T+0'){
                                                queueName = 'Cross_Sell_T_0_Risk_Team';
                                            }
                                            Task taskToUpdate = getTaskCreate(existingCs.Opportunity__c,null,prodIdVsNameMap.get(existingCs.Custom_Product__c) +' Cross-Sell Task for Product Approval Re-Engaged','',queueName,null);
                                            taskToUpdate.Priority = 'High';
                                            taskList.add(taskToUpdate);                                        
                                        }
                                        cs.Delete_it__c = true;
                                    }else{
                                        cs.addError('Cross Sell with Same Product already exist.');
                                    }
                                }else{
                                    if(String.isNotBlank(cs.Risk_Status__c)) existingCs.Risk_Status__c = cs.Risk_Status__c;
                                    if(String.isNotBlank(cs.KAM_Status__c)) existingCs.KAM_Status__c = cs.KAM_Status__c;
                                    if(cs.Enable_Date__c != null) existingCs.Enable_Date__c = cs.Enable_Date__c;
                                    if(cs.Product_GMV__c != null) existingCs.Product_GMV__c = cs.Product_GMV__c;
                                    cs.Delete_it__c = true;
                                    cs.Source__c = 'Uploaded by System';
                                    existingCs.Source__c = 'Uploaded by System';
                                    existingCs.Is_Migrated__c = True;
                                    updatelist.add(existingCs);
                                }
                            }
                        }
                    }
                }
            }
            
            if(!updatelist.isEmpty() && updatelist.size() >0) update updatelist;
            if(taskList.size()>0){
                insert taskList;
            }
        }
        
        for(Cross_Sell__c cs: triggerNew){            
            if(cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId){
                if(cs.Risk_Status__c == null) cs.Risk_Status__c = 'Pending';
                //cs.Send_Reminder_Start_Time__c = System.now();
                if(String.isNotBlank(cs.Opportunity__c) && String.isNotBlank(cs.Product_Name__c)){
                    
                    if(oppObjMap.containsKey(cs.Opportunity__c) && cs.Product_Name__c == oppObjMap.get(cs.Opportunity__c).Product_Name__c){
                        cs.Opportunity__c = oppObjMap.get(cs.Opportunity__c).Id;
                    }
                }else if(String.isNotBlank(cs.Opportunity__c) && String.isBlank(cs.Product_Name__c)){
                    if(oppObjMap.containsKey(cs.Opportunity__c) && oppObjMap.get(cs.Opportunity__c).Product_Name__c == 'PayU Money'){
                        cs.Opportunity__c = oppObjMap.get(cs.Opportunity__c).Id;
                    } 
                }
            }
            if(sourceList.contains(cs.Source__c) && (cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId) ){
                cs.Care_Status__c = 'Interested';
                cs.Care_Comment__c = 'Marked interested via system on basis of Source';
            }
        }
    }
    
    public static void beforeUpdateHandler(List<Cross_Sell__c> triggerNew,Map<Id,Cross_Sell__c> triggerOldMap){
        String profileName = [SELECT Id, Name FROM Profile where Id =: UserInfo.getProfileId()].Name;
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Cross_Sell__c');
        Set<Id> idSet = new Set<Id>();
        Map<Id,Opportunity> oppObjMap = new Map<Id,Opportunity>();
        
        for(Cross_Sell__c cs :triggerNew){
            If(String.isNotBlank(cs.Opportunity__c)) oppObjMap.put(cs.Opportunity__c,null);
        }
        
        for(Opportunity each : [Select Id,Product_Name__c,Email__c from Opportunity Where Id IN: oppObjMap.keySet()]){
            oppObjMap.put(each.Id,each);                      
        }
        
        for(Cross_Sell__c cs :triggerNew){
            
            Cross_Sell__c oldCrossSell =  triggerOldMap.get(cs.Id);
            if(cs.Risk_Status__c != oldCrossSell.Risk_Status__c && (cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId)  && String.isBlank(cs.Identifier__c) ){
                SystemUtility.getIdentifierUUID(cs, 'Identifier__c', enableUUIDObj);
            }
            if(cs.Care_Status__c != oldCrossSell.Care_Status__c && (cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId)){
                System.debug('Inside If');
                //cs.Priority__c = updateTaskPriority(cs,'update');
            }
            // for Cross Sell Reporting By:- Akash Pandey
            if(cs.Risk_Status__c != oldCrossSell.Risk_Status__c && cs.Risk_Status__c == 'Rejected' && (cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId)){
                cs.Risk_Rejection_Date__c = date.today();
            }
            // for Cross Sell Reporting By:- Akash Pandey
            if(cs.Risk_Status__c != oldCrossSell.Risk_Status__c && cs.Risk_Status__c != 'Re-Evaluate' && (cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId)){
                cs.Risk_Reviewer_Name__c = UserInfo.getName();
                cs.Risk_Review_Time__c = System.now();
            }
            /*// for Cross Sell Reporting By:- Akash Pandey
if(cs.Risk_Status__c != oldCrossSell.Risk_Status__c && cs.Risk_Status__c != 'Re-Evaluate' && (cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId)){
cs.Risk_Review_Time__c = System.now();
}*/
            // for Cross Sell Reporting By:- Akash Pandey
            if(cs.Kam_Status__c != oldCrossSell.Kam_Status__c && (cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId)){
                cs.KAM_Reviewer_Name__c = UserInfo.getName();
            }
            // for Cross Sell Reporting By:- Akash Pandey
            if(cs.Kam_Status__c != oldCrossSell.Kam_Status__c && (cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId)){
                cs.KAM_Review_Time__c = System.now();
            }
            //to manage re-evaluate count(SPPI-772) By:- Akash Pandey
            /* if(cs.Risk_Status__c != oldCrossSell.Risk_Status__c && cs.Risk_Status__c=='Re-Evaluate' && cs.RecordTypeId == productCrossSellRecordTypeId){
if(cs.Re_Evaluate_Count__c == null || cs.Re_Evaluate_Count__c == 0){
cs.Re_Evaluate_Count__c  = 1;
}else{
cs.Re_Evaluate_Count__c  = cs.Re_Evaluate_Count__c + 1;
}
cs.Kam_Status__c = 'Merchant Rejected';
}*/
            if(cs.Risk_Status__c != oldCrossSell.Risk_Status__c && cs.Risk_Status__c != 'Re-Evaluate' && String.isNotBlank(oldCrossSell.Risk_Status__c) && oldCrossSell.Risk_Status__c == 'Re-Evaluate' 
               && (cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId) 
               && (profileName == 'Sales Manager' || profileName== 'Sales User' || profileName== 'Merchant Care User' ||  profileName== 'Merchant Care Parent L2' ||  profileName== 'Merchant Care Parent' ||  profileName== 'System Administrator') ){
                   cs.Kam_Status__c = 'Re-Evaluated by Risk';
               }
            if(cs.Risk_Status__c != oldCrossSell.Risk_Status__c && cs.Risk_Status__c == 'Rejected' && (cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId) /*&& (profileName != 'Sales Manager' || profileName != 'Sales User')*/){
                cs.Kam_Status__c = 'Rejected by Risk';
            }
            if(cs.Risk_Status__c =='Approved' && cs.Kam_Status__c =='Merchant Accepted' && cs.Active__c == true && (cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId) ){
                if(cs.Enable_Date__c == null) cs.Enable_Date__c = System.now();
                cs.Product_Enable__c = true;
            }
            If(String.isBlank(cs.Merchant_Email__c)) cs.Merchant_Email__c = oppObjMap.get(cs.Opportunity__c).Email__c;
        }
    }
    
    public static void afterInsertHandler(List<Cross_Sell__c> triggerNew){
        List<Task> taskList = New List<Task>();
        /*blank attachment list*/
        List<Attachment> attList = new List<Attachment>();
        List<Id> oppIDs = New List<Id>();
        Map<Id,Opportunity> oppMIDsMap = New Map<Id,opportunity>();
        Integer userIndex = 0;
        integer sendEmail = 0;
        List<Cross_Sell__c> CrossSellListToDelete = new List<Cross_Sell__c>();
        
        List<Cross_Sell__c> enabledCrossSellList = New List<Cross_Sell__c>();
        Set<String> enabledOppIds = New Set<String>();
        
        //Map of Product Id and the product name.
        Map<String,String> prodIdVsNameMap = new Map<String,String>();
        for(Product__c prod: [SELECT Id, Name FROM Product__c LIMIT 20]){
            prodIdVsNameMap.put(prod.Id,prod.Name);
        }
        // Updated for cross-sell opportunity
        for(Cross_Sell__c cs : triggerNew){
            if(String.isNotBlank(cs.Opportunity__c))
                oppIDs.add(cs.Opportunity__c);
        }
        
        if(oppIDs.size()>0){
            for(opportunity opp : [Select Prod_Merchant_Id__c,Key_Assigned_Manager__c,Id,ownerId from Opportunity 
                                   where Id IN: oppIDs]){
                                       oppMIDsMap.put(opp.Id,opp);
                                   }
        }
        for(Cross_Sell__c cs : triggerNew){
            System.debug('Inside afterInsertHandler '+cs);
            
            if(cs.Enable_Date__c != null){
                enabledCrossSellList.add(cs);
                enabledOppIds.add(cs.Opportunity__c);
            }
            
            if(cs.Source__c != 'Uploaded by System' && String.isNotBlank(cs.Opportunity__c) && string.isNotBlank(cs.Custom_Product__c) && cs.Uploaded_by_dataloader__c == true 
               && (cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId) && System.isBatch() == false && cs.Cross_Sell_Stop_Task_Creation__c == false){
                   String taskSubject= '';
                   String queueName = '';
                   if(prodIdVsNameMap.get(cs.Custom_Product__c) == 'MCP'){
                       queueName = 'Cross_Sell_Risk_Team';
                   }else if(prodIdVsNameMap.get(cs.Custom_Product__c) == 'T+0'){
                       queueName = 'Cross_Sell_T_0_Risk_Team';
                   }
                   taskSubject = prodIdVsNameMap.get(cs.Custom_Product__c) +' Cross-Sell Task for Product Approval';
                   Task taskToUpdate = getTaskCreate(cs.Opportunity__c,null,taskSubject,'',queueName,null);
                   System.debug('taskToUpdate '+taskToUpdate);
                   if(cs.Priority__c  == 'Low'){
                       taskToUpdate.Priority = 'Low';
                   }
                   if(cs.Priority__c  == 'Medium'){
                       taskToUpdate.Priority = 'Normal';
                   }
                   if(cs.Priority__c  == 'High'){
                       taskToUpdate.Priority = 'High';
                   }
                   taskList.add(taskToUpdate);
               }
            if(cs.Risk_Status__c == 'Pending' && cs.RecordTypeId == InstantSettlementRecordTypeId){
                sendEmail++;
            }
            if(cs.Delete_it__c){
                CrossSellListToDelete.add(cs);
            }
        }
        if(sendEmail>0){
            System.debug('sendEmail'+sendEmail);
            //sendEmailCommonMethod('PayU Instant Settlement', 'Request Email to Risk Team','Pre_Onboarding_Risk_Team', attList);            
        }
        if(!taskList.isEmpty()){
            insert taskList;
        } 
        if(CrossSellListToDelete.size()>0){
            delete [select id from Cross_Sell__c where id in :triggerNew AND Delete_it__c = true];   
            Database.emptyRecycleBin(CrossSellListToDelete);
        }
        
        if(!enabledCrossSellList.isEmpty() && !enabledOppIds.isEmpty()){
            enableProductOnOpportunities(enabledCrossSellList,enabledOppIds);
        }
    }
    
    public static void afterUpdateHandler(List<Cross_Sell__c> triggerNew, Map<Id,Cross_Sell__c> triggerOldMap){
        Id orgEmailId = [SELECT DisplayName, Id,Address, IsAllowAllProfiles FROM OrgWideEmailAddress where Address = 'no_reply@payu.in' LIMIT 1].Id;
        System.debug('orgEmailId'+orgEmailId);
        Map<String,String>  CrossSell_SendCrossSellDataExcelMap = (Map<String,String>)JSON.deserialize(System.Label.CrossSell_Additional_Access_As_Kam_And_Send_CrossSell_Data_Excel ,Map<String, String>.class);
        List<String> CrossSell_SendCrossSellDataExcelInsteadOfMerchantMaintenance = CrossSell_SendCrossSellDataExcelMap.get('Send Cross Sell Data excel instead of merchant maintenance').split(',');
        List<String> CrossSell_SendCrossSellDataExcelAlongWithMerchantMaintenance = CrossSell_SendCrossSellDataExcelMap.get('Send Cross Sell Data along with merchant maintenance').split(',');
        List<Task> taskList = New List<Task>();
        List<Id> oppIDs = New List<Id>();
        List<String> merDocUrlList = new List<String>();
        Map<Id,Opportunity> oppMIDsMap = New Map<Id,opportunity>();
        Map<String,String>  CrossSell_ProductAndUserIdMap =(Map<String, String>)JSON.deserialize(system.label.CrossSell_ProductAndUserIdMap, Map<String, String>.class);
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> csIdSet = new Set<Id>();
        Integer userIndex = 0;
        String finalUrlStr= '';
        List<Case> caseList = New List<Case>();
        List<Cross_Sell__c> enabledCrossSellList = New List<Cross_Sell__c>();
        Set<String> enabledOppIds = New Set<String>();
        
        //Map of Product Id and the product name.
        Map<String,String> prodIdVsNameMap = new Map<String,String>();
        for(Product__c prod: [SELECT Id, Name FROM Product__c LIMIT 20]){
            prodIdVsNameMap.put(prod.Id,prod.Name);
        }
        
        // Updated for cross-sell opportunity
        for(Cross_Sell__c cs : triggerNew){
            if(String.isNotBlank(cs.Opportunity__c)){
                oppIDs.add(cs.Opportunity__c);
                csIdSet.add(cs.Id);
            }
        }
        /*
* List of Merchant Concent send in email when kam statu is merchant Accepted
*/
        List<Merchant_Document__c> merDocList = new List<Merchant_Document__c>();
        merDocList = [Select Id,Name,URL__c from Merchant_Document__c where Cross_Sell__c =: csIdSet AND KYC_Documentable_Type__c =:'Merchant consent crossSell'];
        if(merDocList.size() >0){
            finalUrlStr = 'Kindly find the attached data. '+'\n';
            for(Merchant_Document__c mDoc: merDocList){
                String urlStr = system.Label.crossSell_Vfp_Url+'/DownloadFromS3?relatedId='+mDoc.URL__c;
                System.debug('urlStr>>>>'+urlStr);
                //String urlStr = 'https://uat-payuin.cs6.force.com/DownloadFromS3?relatedId='+mDoc.URL__c;
                String html = '<html><a href="'+urlStr+'">'+'Merchant Consent'+'</a></html>'+ ' ';
                finalUrlStr = finalUrlStr+html + '\n' ;
            }
        }else{
            finalUrlStr = 'Kindly find the attached data.'+'\n';
        }
        
        if(oppIDs.size()>0){
            for(opportunity opp : [Select Prod_Merchant_Id__c,First_Name__c ,Last_Name__c,
                                   ownerId,Email__c,AccountId,Id,Legal_Name_Account__c,Website__c,Business_Category__c ,
                                   Key_Assigned_Manager__c,Contact__c ,Mobile__c, Product_Name__c from Opportunity where Id IN: oppIDs]){
                                       oppMIDsMap.put(opp.Id,opp);
                                   }
        }
        for(Cross_Sell__c cs : triggerNew){
            if(String.isNotBlank(cs.Opportunity__c) && string.isNotBlank(cs.Custom_Product__c)){
                if(triggerOldMap.containsKey(cs.Id)){
                    Cross_Sell__c oldCrossSell =  triggerOldMap.get(cs.Id);
                    
                    Map<String,String> crossSellProductAndUserIdMap =(Map<String, String>)JSON.deserialize(system.label.CrossSell_ProductAndUserIdMap, Map<String, String>.class);
                    
                    if(cs.Enable_Date__c != oldCrossSell.Enable_Date__c){
                        enabledCrossSellList.add(cs);
                        enabledOppIds.add(cs.Opportunity__c);
                    }
                    
                    if((((cs.Risk_Status__c=='Need More Information') && (cs.Care_Status__c != oldCrossSell.Care_Status__c && ((cs.Care_Status__c =='Interested' && ( cs.Source__c == 'Active Merchant' || cs.Source__c == 'Care' )) || ( cs.Source__c != 'Active Merchant' || cs.Source__c != 'Care')))) || ((cs.Risk_Status__c != oldCrossSell.Risk_Status__c && cs.Risk_Status__c=='Need More Information') && ((cs.Care_Status__c =='Interested' && ( cs.Source__c == 'Active Merchant' || cs.Source__c == 'Care' )) || ( cs.Source__c != 'Active Merchant' || cs.Source__c != 'Care')))) && (cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId) && System.isBatch() == false){
                        taskList.add(getTaskCreate(cs.Opportunity__c,oppMIDsMap,prodIdVsNameMap.get(cs.Custom_Product__c)+' Cross-Sell Task for Document Required','','',crossSellProductAndUserIdMap));
                    } 
                    if(((cs.Risk_Status__c != oldCrossSell.Risk_Status__c && (cs.Risk_Status__c=='Approved' || cs.Risk_Status__c=='Deffered')) && ((cs.Care_Status__c =='Interested' && ( cs.Source__c == 'Active Merchant' || cs.Source__c == 'Care' )) || ( cs.Source__c != 'Active Merchant' || cs.Source__c != 'Care'))) && ((cs.Care_Status__c != oldCrossSell.Risk_Status__c && ((cs.Care_Status__c =='Interested' && ( cs.Source__c == 'Active Merchant' || cs.Source__c == 'Care' )) || ( cs.Source__c != 'Active Merchant' || cs.Source__c != 'Care'))) && (cs.Risk_Status__c=='Approved' || cs.Risk_Status__c=='Deffered')) && (cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId) && System.isBatch() == false && cs.Cross_Sell_Stop_Task_Creation__c == false){
                        taskList.add(getTaskCreate(cs.Opportunity__c,oppMIDsMap,prodIdVsNameMap.get(cs.Custom_Product__c)+' Merchant Interested And Risk Approved','','',crossSellProductAndUserIdMap));
                    }
                    //create the task for cross sell risk team when risk status is Re-Evaluate for MCP(SP-772).
                    if(cs.Risk_Status__c != oldCrossSell.Risk_Status__c && cs.Risk_Status__c=='Re-Evaluate' && (cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId) && System.isBatch() == false){
                        String queueName = '';
                        if(prodIdVsNameMap.get(cs.Custom_Product__c) == 'MCP'){
                            queueName = 'Cross_Sell_Risk_Team';
                        }else if(prodIdVsNameMap.get(cs.Custom_Product__c) == 'T+0'){
                            queueName = 'Cross_Sell_T_0_Risk_Team';
                        }
                        taskList.add(getTaskCreate(cs.Opportunity__c,oppMIDsMap,prodIdVsNameMap.get(cs.Custom_Product__c)+' Cross-Sell Task for Re-Evaluation','',queueName,null));
                    }
                    
                    
                    //===========T+0 task for risk team.at the time of Risk approoved and green zone.=========
                    /*if((cs.Risk_Zone__c != oldCrossSell.Risk_Zone__c && cs.Risk_Zone__c =='Amber') && cs.RecordTypeId == InstantSettlementRecordTypeId){
taskList.add(getTaskCreate(cs.Opportunity__c,null,'T+0 Task For Risk Team','','Cross_Sell_Risk_Team',null));
}
*/
                    //===========MCP task for risk team.at the time of Risk approoved and green zone.=========
                    if((cs.Risk_Zone__c != oldCrossSell.Risk_Zone__c && cs.Risk_Zone__c =='Amber Zone') && cs.KAM_Status__c == 'Rejected by System' 
                       && cs.Risk_Status__c == 'Rejected' && cs.RecordTypeId == productCrossSellRecordTypeId){
                           taskList.add(getTaskCreate(cs.Opportunity__c,null,prodIdVsNameMap.get(cs.Custom_Product__c)+' Cross-Sell Task For Risk Team','','Cross_Sell_Risk_Team',null));
                       }
                    
                    List<String> toEmailAddress = New List<string>();
                    List<string> merchantRelationEmailId = New List<String>();
                    
                    if(string.isNotBlank(oppMIDsMap.get(cs.Opportunity__c).Key_Assigned_Manager__c) && oppMIDsMap.containsKey(cs.Opportunity__c)){
                        userIdSet.add(oppMIDsMap.get(cs.Opportunity__c).Key_Assigned_Manager__c);
                    }
                    
                    //send the email to the merchant when risk status is rejected for MCP(SP- 772).
                    if(cs.Risk_Status__c != oldCrossSell.Risk_Status__c && cs.Risk_Status__c=='Rejected' && (cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId)){
                        System.debug('Inside IF');
                        List<String> toEmailAddressList = new List<String>();
                        toEmailAddressList.add(oppMIDsMap.get(cs.Opportunity__c).Email__c);
                        List<User> userList = [SELECT Id, Name,IsActive, Title, Email FROM User where Id IN:userIdSet];
                        if(userList.size()>0){
                            for(User u: userList){
                                if(u.IsActive) toEmailAddressList.add(u.Email);
                            }
                        }
                        EmailTemplate emailTemplate;
                        if(prodIdVsNameMap.get(cs.Custom_Product__c) == 'MCP'){
                            emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body from 
                                             EmailTemplate where name = 'RiskRejectionEmail'];
                        }else if(prodIdVsNameMap.get(cs.Custom_Product__c) == 'T+0'){
                            emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body from 
                                             EmailTemplate where name = 'Risk Rejection Email For T_0'];
                        }
                        if(oppMIDsMap.get(cs.Opportunity__c).Key_Assigned_Manager__c !=null){
                            if(toEmailAddressList.size() > 0){
                                sendEmailWithUpdateBody(cs.Custom_Product__r.Name+'-Rejected By risk',toEmailAddressList,emailTemplate,null,'PayU',null,null,orgEmailId,true,'',oppMIDsMap.get(cs.Opportunity__c),'','MCP-Rejected By risk');
                            }
                        }/*else{
String queueName = '';
if(prodIdVsNameMap.get(cs.Custom_Product__c) == 'MCP'){
queueName = 'Cross_Sell_Risk_Team';
}else if(prodIdVsNameMap.get(cs.Custom_Product__c) == 'T+0'){
queueName = 'Cross_Sell_T_0_Risk_Team';
}
//String riskRejectedTaskAssignment_id = Label.CrossSell_RiskRejectedTaskAssignment;
taskList.add(getTaskCreate(cs.Opportunity__c,null,prodIdVsNameMap.get(cs.Custom_Product__c)+' Cross-Sell Rejected By risk',Label.CrossSell_RiskRejectedTaskAssignment,queueName,null));
}*/
                        
                        // As per JIRA-SFPI-980 commented else logic and create new else logic.
                        else{
                            String riskRejectedTaskAssignment_id = Label.CrossSell_RiskRejectedTaskAssignment;
                            toEmailAddressList = riskRejectedTaskAssignment_id.split(',');
                            if(toEmailAddressList.size() > 0){
                                sendEmailWithUpdateBody(cs.Custom_Product__r.Name+'-Rejected By risk',toEmailAddressList,emailTemplate,null,'PayU',null,null,orgEmailId,true,'',oppMIDsMap.get(cs.Opportunity__c),'','MCP-Rejected By risk');
                            }
                        }
                    }
                    if(!cs.Is_Migrated__c && (cs.Kam_Status__c != oldCrossSell.Kam_Status__c && cs.Kam_Status__c == 'Merchant Accepted') && (cs.Risk_Status__c=='Approved' || cs.Risk_Status__c=='Deffered') && ((cs.Care_Status__c =='Interested' && ( cs.Source__c == 'Active Merchant' || cs.Source__c == 'Care' )) || ( cs.Source__c != 'Active Merchant' || cs.Source__c != 'Care')) && (cs.RecordTypeId == productCrossSellRecordTypeId || cs.RecordTypeId == InstantSettlementRecordTypeId)){
                        
                        String str = getBody(oppMIDsMap,cs);
                        
                        merchantRelationEmailId.add(system.Label.CrossSell_SendCrossSellDataExelToAddress);
                        userIdSet.add(CrossSell_ProductAndUserIdMap.get('MCP'));
                        
                        if(CrossSell_SendCrossSellDataExcelInsteadOfMerchantMaintenance.contains(UserInfo.getUserId())){
                            for(String user_Id: CrossSell_SendCrossSellDataExcelInsteadOfMerchantMaintenance){
                                userIdSet.add(user_Id);
                            }
                            //toEmailAddress.add(system.Label.CrossSell_SendCrossSellDataExelToAddress);
                        }else if(CrossSell_SendCrossSellDataExcelAlongWithMerchantMaintenance.contains(UserInfo.getUserId())){
                            for(String user_Id: CrossSell_SendCrossSellDataExcelAlongWithMerchantMaintenance){
                                userIdSet.add(user_Id);
                            }
                            //toEmailAddress.add(system.Label.CrossSell_SendCrossSellDataExelToAddress);
                        }//else{
                        //toEmailAddress.add(system.Label.CrossSell_SendCrossSellDataExelToAddress);
                        //}
                        else if(!userIdSet.contains(UserInfo.getUserId())){
                            userIdSet.add(UserInfo.getUserId());
                        }
                        
                        List<User> userList = [SELECT Id, Name,IsActive, Title, Email FROM User where Id IN:userIdSet];
                        
                        if(userList.size()>0){
                            for(User u: userList){
                                if(u.IsActive) toEmailAddress.add(u.Email);
                            }
                        }
                        //toEmailAddress.add('shivani.mishra@payu.in');
                        System.debug('toEmailAddress>>> '+toEmailAddress);
                        //EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'SendCrossSellDataExcel'];
                        if(!toEmailAddress.isEmpty())
                            sendEmailWithUpdateBody('MCP',toEmailAddress,null,null,'PayU',null,null,orgEmailId,true,str,oppMIDsMap.get(cs.Opportunity__c),finalUrlStr,'Cross Sell Data Mid: '+oppMIDsMap.get(cs.Opportunity__c).Prod_Merchant_Id__c);
                        
                        // Send email to merchant relation
                        if(!merchantRelationEmailId.isEmpty()){
                            sendEmailWithUpdateBody('MCP',merchantRelationEmailId,null,null,'PayU',null,null,orgEmailId,true,str,oppMIDsMap.get(cs.Opportunity__c),finalUrlStr,'Cross Sell Data Mid: '+oppMIDsMap.get(cs.Opportunity__c).Prod_Merchant_Id__c);
                            caseList.add(createMerchantRelationCase(oppMIDsMap.get(cs.Opportunity__c), 'Farming_Merchant_Relations', 'Farming_Merchant_Relations','Medium','Farming_Merchant_Relations','MCP Cross Sell Data Mid: '+oppMIDsMap.get(cs.Opportunity__c).Prod_Merchant_Id__c,finalUrlStr));
                        }
                    }  
                }
            }
        }
        System.debug('taskList '+taskList);
        if(!taskList.isEmpty()){
            insert taskList;
            System.debug('taskList '+taskList);
        } 
        
        if(!enabledCrossSellList.isEmpty() && !enabledOppIds.isEmpty()){
            enableProductOnOpportunities(enabledCrossSellList,enabledOppIds);
        }
        
        if(!caseList.isEmpty()) Insert caseList;
    }
    
    public static String getBody(Map<Id,Opportunity> opMIDMap,Cross_Sell__c cs){
        String header = 'Risk Status,Risk Comment,Request Date,optimus id,MID,Merchant Name,URL,Category,annotation services,Pin code,Addresss,City,State,State Code,Zone,Contact Person name,Mobile number,Email ID,Source(Payu or Citrus or Yes bank),All currency or Top 9 Currency or Domestic,Code attachment date(For Banking Ops Team),MCP Rate(Mandatory in case mcp required),FEE Model (TDR/ Con),KAM\n';
        //htmlBody = 'Request Date'+'   '+'optimus id'+'    '+'MID'+'   '+'Merchant Name'+' '+'URL'+'/t'+'Category'+'   '+'annotation services'+'   '+'Pin code'+'  '+'Addresss'+'  '+'City'+'  '+'State'+' '+'State Code'+'    '+'Zone'+'  '+'Contact Person name'+'   '+'Mobile number'+' '+'Email ID'+'  '+'Source(Payu or Citrus or Yes bank)'+'    '+'All currency or Top 9 Currency or Domestic'+'    '+'Code attachment date(For Banking Ops Team)'+'    '+'MCP Rate(Mandatory in case mcp required)'+'  '+'FEE Model (TDR/ Con)'+'  '+'KAM'+'\n';
        string finalnachlist = header;
        String recordString='';
        String risk_Status = String.isNotBlank(cs.Risk_Status__c) ? cs.Risk_Status__c : '';
        String risk_Comment = String.isNotBlank(cs.Risk_Comment__c) ? cs.Risk_Comment__c : '';
        recordString = '"' +risk_Status;
        finalnachlist = finalnachlist+recordString;
        recordString = '","' +risk_Comment;
        finalnachlist = finalnachlist+recordString;
        for(Opportunity op: opMIDMap.values()){
            
            //String Request_Summary_Data = op.Legal_Name_Account__c != null ? op.Legal_Name_Account__c : '';
            String Request_Date = '';
            String optimus_id = '';
            Decimal Mid = op.Prod_Merchant_Id__c != null ? op.Prod_Merchant_Id__c : 0;
            String merchant_Name = op.Legal_Name_Account__c != null ? op.Legal_Name_Account__c : '';
            String url = op.Website__c != null ? op.Website__c : '';
            String category = String.isNotBlank(op.Business_Category__c) ? op.Business_Category__c : '';
            String annotation_services = '';
            String contact_Person_Name = String.isNotBlank(op.Contact__c) ? op.Contact__c : '';
            String mobile_number = String.isNotBlank(op.Mobile__c) ? op.Mobile__c : '';
            String email_ID = String.isNotBlank(op.Email__c) ? op.Email__c : '';
            String source = String.isNotBlank(op.Product_Name__c) ? op.Product_Name__c : '';
            String all_currency_or_Top_9_Currency_or_Domestic = '';
            String code_attachment_date = '';
            String mcp_Rate = '';
            String fee_Model = '';
            String pin_code = '';
            String addresss = '';
            String city = '';
            String state = '';
            String state_Code = '';
            String zone = '';
            String kam= '';
            //String kam = op.Key_Assigned_Manager__c != null ? op.Key_Assigned_Manager__c : '';
            recordString = '","'+Request_Date + '","'+optimus_id+ '","'+Mid+ '","'+merchant_Name+ '","'+url+ '","'+category+ '","'+annotation_services+ '","'+pin_code+ '","'+addresss+ '","'+city+ '","'+state+ '","'+state_Code+ '","'+zone+ '","'+contact_Person_Name+ '","'+mobile_number+ '","'+email_ID+ '","'+source+ '","'+all_currency_or_Top_9_Currency_or_Domestic+ '","'+code_attachment_date+ '","'+mcp_Rate+ '","'+fee_Model+ '","'+kam+ '","\n';
            finalnachlist = finalnachlist+recordString;
        }
        //htmlBody += '</table>';
        
        Attachment at =  new Attachment(ParentId = cs.Id,
                                        Body = blob.valueOf(finalnachlist),
                                        Name = 'Test_Table.csv',
                                        ContentType = 'CSV');
        insert at;
        return finalnachlist;
    }
    
    public Static String updateTaskPriority(Cross_Sell__c newCs,String mtdType){
        String opId = newCs.Opportunity__c;
        System.debug('opId . '+opId);
        String priority = '';
        System.debug('Inside Risk_Status__c'+newCs.Risk_Status__c);
        System.debug('Inside Care_Status__c' + newCs.Care_Status__c);
        Task taskToUpdate = [SELECT Id,Priority, WhatId,Status, Subject,CreatedDate FROM Task where WhatId =:opId AND Subject=: 'Cross-Sell Task for Product Approval' AND (Status != 'Completed' OR Status != 'Closed') ORDER BY CreatedDate DESC LIMIT 1];
        System.debug('Inside taskToUpdate' + newCs.Care_Status__c);
        if(newCs.Care_Status__c == 'Interested' && newCs.Risk_Status__c == 'Pending' && taskToUpdate != null){
            System.debug('Inside 1 IF');
            taskToUpdate.Priority = 'High';
            priority = 'High';
        }
        if(newCs.Care_Status__c == 'Not Interested' && newCs.Risk_Status__c == 'Pending' && taskToUpdate != null){
            System.debug('Inside 2 If');
            taskToUpdate.Priority = 'Normal';
            taskToUpdate.Status = 'Closed';
            priority = 'Low';
        }
        if(newCs.Priority__c  == 'Low' && mtdType == 'insert'){
            taskToUpdate.Priority = 'Low';
        }
        if(newCs.Priority__c  == 'Medium' && mtdType == 'insert'){
            taskToUpdate.Priority = 'Normal';
        }
        if(newCs.Priority__c  == 'High' && mtdType == 'insert'){
            taskToUpdate.Priority = 'High';
        }
        update taskToUpdate; 
        return priority;
    }
    
    public static List<Messaging.SendEmailResult> sendEmailWithUpdateBody(string name, string[] email, EmailTemplate emailTemplateObj, list<Attachment> listAttachment, String ownerName, String ownerEmail, String[] acntOwnerEmail, Id OrgWideEmailAddId, Boolean isSendAgreement, string str,Opportunity oppObj,String body,String subject){
        List<Messaging.EmailFileAttachment> listEmailFileAttachment = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment emailFileAttachment = new Messaging.EmailFileAttachment();
        
        if(str != ''){
            emailFileAttachment.setFileName('crossSellData.csv');
            emailFileAttachment.setInline(false);
            if(str != null){
                emailFileAttachment.setBody(blob.valueOf(str));
            }
            if(emailFileAttachment.getBody() != null){
                listEmailFileAttachment.add(emailFileAttachment);
            }
        }
        Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();
        singleEmailMsg.setReplyTo(ownerEmail);            
        singleEmailMsg.setToAddresses(email);
        if(emailTemplateObj != null && emailTemplateObj.HtmlValue != null){
            emailTemplateObj.HtmlValue = (emailTemplateObj.HtmlValue.contains('ContactName') && String.isNotBlank(name)) ? emailTemplateObj.HtmlValue.replace('ContactName', name) : emailTemplateObj.HtmlValue;
            emailTemplateObj.HtmlValue = (emailTemplateObj.HtmlValue.contains('OwnerName') && String.isNotBlank(OwnerName)) ? emailTemplateObj.HtmlValue.replace('OwnerName', ownerName) : emailTemplateObj.HtmlValue;
            emailTemplateObj.HtmlValue = (emailTemplateObj.HtmlValue.contains('FIRSTNAME') && String.isNotBlank(oppObj.First_Name__c)) ? emailTemplateObj.HtmlValue.replace('FIRSTNAME', oppObj.First_Name__c) : emailTemplateObj.HtmlValue;
            emailTemplateObj.HtmlValue = (emailTemplateObj.HtmlValue.contains('LASTNAME') && String.isNotBlank(oppObj.Last_Name__c)) ? emailTemplateObj.HtmlValue.replace('LASTNAME', oppObj.Last_Name__c) : emailTemplateObj.HtmlValue;
            //if((acntOwnerEmail.size()>0)) singleEmailMsg.setCcAddresses(acntOwnerEmail ); 
            singleEmailMsg.setTemplateId(emailTemplateObj.Id);
            singleEmailMsg.setSubject(emailTemplateObj.Subject);
            singleEmailMsg.setHtmlBody(emailTemplateObj.HtmlValue);
        }else{
            singleEmailMsg.setHtmlBody(body);
            singleEmailMsg.setSubject(name+' Cross Sell Data Mid: '+oppObj.Prod_Merchant_Id__c);
        }
        if(isSendAgreement){
            if(String.isNotBlank(OrgWideEmailAddId)) singleEmailMsg.setOrgWideEmailAddressId(OrgWideEmailAddId);    
        }else{
            if(String.isNotBlank(ownerName)) singleEmailMsg.setSenderDisplayName(ownerName);     
        } 
        if(listEmailFileAttachment.size()>0 ){
            singleEmailMsg.setFileAttachments(listEmailFileAttachment);
        }
        List<Messaging.SendEmailResult> listSendEmailResult = Messaging.sendEmail(new Messaging.Singleemailmessage[] { singleEmailMsg });
        system.debug(listSendEmailResult.size()+' :::::::: listSendEmailResult ::::::::'+listSendEmailResult);
        return listSendEmailResult;
    }
    
    public static task getTaskCreate(Id OppId,Map<Id,Opportunity> oppMIDsMap, string subject, string ownerLabelname,string queueName,Map<string,string> crossSellProductAndUserIdMap){
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));        
        List<string>  desiredOwners= New List<string>();
        Integer userIndex = 0;
        
        if(desiredOwners.isEmpty() && string.isNotBlank(ownerLabelname)){
            desiredOwners = ownerLabelname.split(',');
        }else if(desiredOwners.isEmpty() && string.isNotBlank(queueName)){
            for(GroupMember gpm: [SELECT Id, UserOrGroupId FROM GroupMember where Group.DeveloperName=:queueName]){
                desiredOwners.add(gpm.UserOrGroupId);
            }
        }
        if(!desiredOwners.isEmpty()){
            userIndex = Math.mod(IntrandomNumber, desiredOwners.Size());
        }else{
            userIndex = 0;
        }
        Task objTask = New Task();
        objTask.Subject = subject;
        objTask.WhatId = OppId;
        if(oppMIDsMap != null && (subject != 'MCP Cross-Sell Task for Re-Evaluation' && subject != 'T+0 Cross-Sell Task for Re-Evaluation' && subject != 'Payout Cross-Sell Task for Re-Evaluation')) {
            if(string.isNotBlank(oppMIDsMap.get(oppId).Key_Assigned_Manager__c) && oppMIDsMap.containsKey(oppId)){
                objTask.OwnerId = oppMIDsMap.get(oppId).Key_Assigned_Manager__c;
            }else{                    
                if(crossSellProductAndUserIdMap!=null && crossSellProductAndUserIdMap.containskey('MCP')) objTask.OwnerId = crossSellProductAndUserIdMap.get('MCP');                                
            }
        }else if(!desiredOwners.isEmpty() && desiredOwners.get(userIndex) != null){
            objTask.OwnerId = desiredOwners.get(userIndex);
        }else{
            objTask.OwnerId = UserInfo.getUserId();
        }
        
        objTask.Status = 'Not Started';
        objTask.Priority = 'Normal';
        objTask.ActivityDate = Date.today()+2;
        return objTask;
    }
    
    /*
public static Task getTaskToCreate(Cross_Sell__c cs, Map<Id,Opportunity> oppMIDsMap, Integer userIndex){
Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));        
List<string>  desiredOwners= New List<string>();
if(desiredOwners.isEmpty()) desiredOwners = getQueueId();
if(!desiredOwners.isEmpty()){
userIndex = Math.mod(IntrandomNumber, desiredOwners.Size());
}else{
userIndex = 0;
}
Task objTask = New Task();
objTask.Subject = 'Cross-Sell risk approval required';
objTask.WhatId = cs.Opportunity__c;
objTask.OwnerId = desiredOwners.get(userIndex);
objTask.Status = 'Not Started';
objTask.Priority = 'Normal';
objTask.ActivityDate = Date.today()+2;
return objTask;
}
public static Task getTaskToCreateForKAM(Cross_Sell__c cs, Map<Id,Opportunity> oppMIDsMap, Integer userIndex){
Map<String,String> crossSellProductAndUserIdMap =(Map<String, String>)JSON.deserialize(system.label.CrossSell_ProductAndUserIdMap, Map<String, String>.class);
System.debug('UserId '+crossSellProductAndUserIdMap.get('MCP'));
System.debug('Inside getTaskToCreateForKAM '+cs);

Task objTask = New Task();
if(cs.Care_Status__c == 'Interested'){
objTask.Subject = 'Cross-Sell Interested Merchant - Care';
}
objTask.WhatId = cs.Opportunity__c;
if(!oppMIDsMap.isEmpty()) {
if(string.isNotBlank(oppMIDsMap.get(cs.Opportunity__c).Key_Assigned_Manager__c)){
objTask.OwnerId = oppMIDsMap.get(cs.Opportunity__c).Key_Assigned_Manager__c;
}else{
//if(productName == 'MCP'){
System.debug('UserId '+crossSellProductAndUserIdMap.get('MCP'));
objTask.OwnerId = crossSellProductAndUserIdMap.get('MCP');
//}                
}
}
objTask.Status = 'Not Started';
objTask.Priority = 'Normal';
objTask.ActivityDate = Date.today()+2;
System.debug('objTask '+objTask);
return objTask;
}

public static Task getTaskToCreateBasedOnDoc(Cross_Sell__c cs, Map<Id,Opportunity> oppMIDsMap, Integer userIndex){
Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));        
List<string>  desiredOwners= New List<string>();
if(desiredOwners.isEmpty()) desiredOwners = getQueueId();
if(!desiredOwners.isEmpty()){
userIndex = Math.mod(IntrandomNumber, desiredOwners.Size());
}else{
userIndex = 0;
}
System.debug('>>>>>cs '+cs);
Integer count = 0;
List<Merchant_Document__c> merchantDocList = [SELECT Id,Onboarding_Status__c FROM Merchant_Document__c 
where Cross_Sell__c =:cs.id];
if(merchantDocList.size() >0){
for(Merchant_Document__c mDoc:merchantDocList){
if(mDoc.Onboarding_Status__c == 'Received'){
count++;
}
}
}
if(count>0 && cs.Risk_Status__c == 'Need More Information'){
Task objTask = New Task();
objTask.Subject = 'Cross-Sell document required';
objTask.WhatId = cs.Opportunity__c;
objTask.OwnerId = desiredOwners.get(userIndex);
objTask.Status = 'Not Started';
objTask.Priority = 'Normal';
objTask.ActivityDate = Date.today()+2;
return objTask;
}else{
return null;
}
}

public static List<string> getQueueId(){
List<string> ownerIds = New List<string>();
for(GroupMember gpm: [SELECT Id, UserOrGroupId FROM GroupMember where Group.DeveloperName='Cross_Sell_Risk_Team' LIMIT 1]){
ownerIds.add(gpm.UserOrGroupId);
}
return ownerIds;
}*/
    
    public static void sendEmailCommonMethod(string emailName, string emailTemplateName,string groupName,List<Attachment> attList){
        Id orgEmailId = [SELECT DisplayName, Id, IsAllowAllProfiles FROM OrgWideEmailAddress LIMIT 1].Id;
        List<GroupMember> groupMember = [SELECT Id, GroupId,group.name,group.DeveloperName, UserOrGroupId 
                                         FROM GroupMember where Group.DeveloperName=:groupName];
        Set<Id> userIdSet = new Set<Id>();
        for(GroupMember gm: groupMember){
            userIdSet.add(gm.UserOrGroupId);
        }
        List<User> userList = [SELECT Id, Name,IsActive, Title, Email FROM User where Id IN:userIdSet];
        String[] toEmailAddress = New List<string>();
        String[] ccEmailAddress = New List<string>();
        for(User u: userList){
            if(u.IsActive) toEmailAddress.add(u.Email);
        }
        EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body from 
                                       EmailTemplate where name =: emailTemplateName];
        sendEmailWithUpdateBody(emailName,toEmailAddress,emailTemplate,null,'PayU',null,null,
                                orgEmailId,false,'',null,'',null);
        
    }
    
    public static void enableProductOnOpportunities(List<Cross_Sell__c> csObjList , Set<string> oppIds){
        List<Opportunity> oppList = New List<Opportunity>();
        Map<Id,Opportunity> opportunityMap = New Map<Id,Opportunity>([Select Id,Enable_MCP__c,Enable_T_0__c,Enable_EMI__c from Opportunity Where Id IN: oppIds]);
        
        for(Cross_Sell__c csObj : csObjList){
            if(opportunityMap.containsKey(csObj.Opportunity__c)){
                Opportunity oppObj = opportunityMap.get(csObj.Opportunity__c);
                if(csObj.Name == 'MCP'){
                    oppObj.Enable_MCP__c = True;
                }
                if(csObj.Name == 'T+0'){
                    oppObj.Enable_T_0__c = True;
                }
                if(csObj.Name == 'EMI'){
                    oppObj.Enable_EMI__c = True;
                }
                oppList.add(oppObj);
            }
        }
        if(!oppList.isEmpty()) update oppList;
    }
    
    public static Case createMerchantRelationCase(Opportunity eachOpp, String ownerName, string recordTypeName,String priority,String origin,String subject,string body){
        Case caseObj = New Case();
        caseObj.Subject = subject;
        caseObj.RecordTypeId = Schema.SObjectType.CASE.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        caseObj.Origin = origin;
        caseObj.AccountId = eachOpp.AccountId;
        caseObj.ContactId = [Select Id from Contact Where AccountId =: eachOpp.AccountId LIMIT 1].Id;
        caseObj.Merchant_Id__c = String.valueOf(eachOpp.Prod_Merchant_Id__c);
        caseObj.Priority = priority;
        caseObj.Description = body;
        caseObj.comments = body;
        caseObj.OwnerId = [Select Id from Group Where Type='Queue' AND DeveloperName =: ownerName LIMIT 1].Id;
        return caseObj;
    }
}