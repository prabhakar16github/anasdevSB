public class LeadTriggerHandler{    
    public static List<String> fieldsToCkeck = new List<String>{'Legal_Name__c', 'PAN_Number__c', 'Email'};
        public static Boolean publishUpdateFromApex = true;
        public static boolean runningFromConsumerAPI = false;
        public static boolean enterpriseBusinessType = false;
    public static Set<String> merchantAccId = new Set<String>();
    public static List<String> leadTypeList = New List<String>{'Merchant','Seller','seller', 'aggregator','Aggregator','child_aggregator','Child Aggregator'};
        public static List<String> merchantTypeList = New List<String>{'seller','Seller','aggregator','Aggregator','child_aggregator','Child Aggregator'};
            
            // this method call FROM Lead trigger at before insert
            public static void beforeInsertHandler(List<Lead> triggerNew){  
                //Prashant
                Map<string,string> leadRecordtypeMap = (Map<string,string>)JSON.deserialize(system.label.Lead_Convert_Recordtype, Map<string,string>.class);      
                //Prashant     
                Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Lead'); 
                system.debug('enableUUIDObj  ++======= >>> '+enableUUIDObj );
                
                // Change lead status based on othere business category and other sub category before insert
                changeLeadStatusBI(triggerNew);
                
                List<String> partnerUUId = new List<String>();
                
                Set<Id> setBusinessCategory = new Set<Id>();        
                List<Lead> lstLead = new List<Lead>();
                Integer counterofPartnerLead = 0;
                Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));
                Set<Id> subCategoryIds = new Set<Id>();
                List<Lead> shopMaticLeadTriggerNew = New List<Lead>();
                //Map<String, String> partnerIdentifiersMap = (Map<String, String>)JSON.deserialize(Label.Merchant_Owner_for_Shopmatic, Map<String, String>.class);
                Map<String, String> partnerIdentifiersMap = new Map<string,string>();	
                for(Partner_Lead_Ownership__mdt  ownerMetadata : [Select id,PartnerId_OwnerId_Map__c FROM Partner_Lead_Ownership__mdt order by label]){	
                    partnerIdentifiersMap = (Map<String, String>)JSON.deserialize(ownerMetadata.PartnerId_OwnerId_Map__c, Map<String, String>.class);	
                }
                List<Lead> assignmentLeadList = New List<Lead>();
                
                Integer counterofExternalPartnerLead = 0;
                Integer ExternalIntrandomNumber = Integer.valueof((Math.random() * 1000));
                Integer counterofPartnerAllianceLead = 0;
                Integer PartnerAllianceIntrandomNumber = Integer.valueof((Math.random() * 1000));
                Integer existingLeadAssignment = 0;
                Integer existingLeadIntrandomNumber = Integer.valueof((Math.random() * 1000));
                List<String> leadIdList = new List<String>();
                List<String> businessCatList = new List<String>();
                List<String> subCatList = new List<String>();
                List<String> bussEntityList = new List<String>();
                List<Lead> leadsToInsertForEnterpriseFlow = new List<Lead>();
                
                Set<String> newLeadEmails = new Set<String>(); // Kunal-Offline Lead Issue
                
                
                
                //Set<Id> leadIdSet = new Set<Id>();
                
                for(Lead each : triggerNew){
                    newLeadEmails.add(each.Email);
                    System.debug('>>>>>>each.CreatedById>>>>>'+each.CreatedById);
                    System.debug('>>>>>>UserInfo.getUserId()>>>>>'+UserInfo.getUserId());
                    System.debug('>>>>>>Label.Offline_Lead_Check>>>>>'+Label.Offline_Lead_Check);
                    if(UserInfo.getUserId() != Label.Offline_Lead_Check){
                        each.Offline_Lead__c = TRUE;
                        each.Online_Lead__c = FALSE;
                    } else {
                        each.Offline_Lead__c = FALSE;
                        each.Online_Lead__c = TRUE;
                    }
                    
                    System.debug('each:::::::46:::'+each);//rohit
                    leadIdList.add(each.Select_Product__c);
                    businessCatList.add(each.Select_Business_Category__c);
                    subCatList.add(each.Select_Sub_Category__c);
                    bussEntityList.add(each.Select_Entity__c);
                    //leadIdSet.add(each.Id);
                    each.Created__c = true;
                    
                    //Calling the COCalloutToGetMIDBatch Batch Class to hit the CO's API for Enterprise flow ** Kunal***
                    
                    /*if(each.Prod_Merchant_Id__c == NULL && each.Identifier__c == NULL){
                        leadsToInsertForEnterpriseFlow.add(each);
                        
                        
                    }*/
                    
                    //*******End****Kunal*******************************************************************************
                    // call this method to get the identifier field value if not exist   
                    if(String.isNotBlank(each.RecordTypeId) && !leadRecordtypeMap.isEmpty() && leadRecordtypeMap.containskey(each.RecordTypeId) && leadRecordtypeMap.get(each.RecordTypeId) != null){
                        each.Lead_Type__c = leadRecordtypeMap.get(each.RecordTypeId);
                        System.debug('each:::::::46:::'+each.RecordTypeId);//rohit
                        SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj); 
                    } 
                    
                    if(String.isNotBlank(each.FirstName))
                        each.Signup_First_Name__c = each.FirstName;
                    
                    each.Lead_date__c = System.Today();
                    
                    if(String.isNotBlank(each.LastName)) 
                        each.Signup_Last_Name__c = each.LastName;
                    
                    if(String.isNotBlank(each.PAN_Holder_Name__c) && String.isBlank(each.Legal_Name__c))
                        each.Legal_Name__c = each.PAN_Holder_Name__c;
                    
                    if(String.isNotBlank(each.PAN_Holder_Name__c) && String.isBlank(each.LastName))
                        each.LastName = each.PAN_Holder_Name__c;
                    
                    //=========Linking "Select Product" field to Product=== SFI-511=====Kunal=======================
                    
                    /*if(String.isNotBlank(each.Select_Product__c) && each.Select_Product__c == 'PayU Biz')
                        each.Product__c = system.label.Product_PayUBiz;
                    else if(String.isNotBlank(each.Select_Product__c) && each.Select_Product__c == 'PayU Money')
                        each.Product__c = system.label.Product_PayUMoney;
                    else if(String.isNotBlank(each.Select_Product__c) && each.Select_Product__c == 'Payu Now')
                        each.Product__c = system.label.Product_PayUNow;
                    else if(String.isNotBlank(each.Select_Product__c) && each.Select_Product__c == 'Citrus')
                        each.Product__c = system.label.Product_Citrus;
                    else if(String.isNotBlank(each.Select_Product__c) && each.Select_Product__c == 'EMI')
                        each.Product__c = system.label.Product_EMI;
                    else if(String.isNotBlank(each.Select_Product__c) && each.Select_Product__c == 'MCP')
                        each.Product__c = system.label.Product_MCP;
                    else if(String.isNotBlank(each.Select_Product__c) && each.Select_Product__c == 'Payout')
                        each.Product__c = system.label.Product_Payout;
                    else if(String.isNotBlank(each.Select_Product__c) && each.Select_Product__c == 'SI')
                        each.Product__c = system.label.Product_SI;
                    else if(String.isNotBlank(each.Select_Product__c) && each.Select_Product__c == 'T+0')
                        each.Product__c = system.label.Product_T_0;*/
                    
                    
                    //=========END===Linking "Select Product" field to Product=== SFI-511=====Kunal=======================      
                    
                    //========Updating default lead type if Merchant Type is available for all Merchants============
                    if(string.isNotBlank(each.merchant_Type__c)){
                        each.Lead_Type__c = each.merchant_type__c;
                    }
                    
                    // Put Email field value in "Signup Email" field
                    if(String.isNotBlank(each.Email))   each.Signup_Email__c = each.Email;
                    
                    // Put Phone field value in "Signup Phone" field
                    if(each.MobilePhone != null)    each.Signup_Phone__c = each.MobilePhone;
                    
                    //update "Not Responding Date" field
                    if(each.Sub_Status__c == 'Not Responding')  each.Lead_Not_Responding_Date__c = system.today();
                    
                    //update Online Lead checkbox for all online leads.
                    if(System.isBatch() && each.Sub_Source__c == 'WebsiteSignUp') each.Online_Lead__c = true;
                    
                    // Update company name based on pan number and legal name/ update status as junk if lead type is buyer
                    updateLeadCompanyAndStatuses(each, null);
                    
                    // ======== update LOB status and Risk Auto Approved fields value
                    if(String.isNotEmpty(each.Transaction_Facility_Required__c)
                       && each.Delivery_Duration__c != null && each.NDX_Score__c != null && each.BusinessCategory__c != null){
                           lstLead.add(each);
                           setBusinessCategory.add(each.BusinessCategory__c);
                       }
                    
                    // =========== set the lead status as "Nurturing" and sub status as "Contacted" ============== 
                    if(String.isNotBlank(each.PAN_Holder_Name__c) && String.isNotBlank(each.PAN_Number__c) && String.isNotBlank(each.Legal_Name__c)){
                        setLeadStatus(each);            
                    }
                    
                    // ============ Set the lead Owner Id based on lead Source is equal to partner Dec.24, 2018 =================
                    // ==============Commented due to JIRA ISSUE Because on some partner cases LeadSouce will always not will be partner. 
                    //if(String.isNotBlank(each.LeadSource) && each.LeadSource.equalsIgnoreCase('Partner') && String.isNotBlank(each.Partner_Owner_Id__c)){
                    if((String.isNotBlank(each.Partner_Owner_Id__c) && partnerIdentifiersMap.isEmpty()) || 
                       (!partnerIdentifiersMap.isEmpty() && string.isNotBlank(each.Partner_ID__c) && 
                        !partnerIdentifiersMap.containsKey(each.Partner_ID__c) && String.isNotBlank(each.Partner_Owner_Id__c))){
                            each.OwnerId = each.Partner_Owner_Id__c;
                        }
                    
                    //update Merchant Trading name with Legal Name//
                    if(String.isNotBlank(each.Legal_Name__c) && String.isBlank(each.Merchant_Trading_Name__c))   
                        each.Merchant_Trading_Name__c = each.Legal_Name__c;
                    
                    if(String.isNotBlank(each.Lead_Type__c) && 'Partner'.equals(each.Lead_Type__c) && string.isBlank(each.Queue_Name__c))
                        counterofPartnerLead = counterofPartnerLead + 1;
                    
                    //=====================Used to copy Test MID and MID=================
                    copyMIDToTxtField(each); 
                    
                    //=====update delivery duration==========
                    if(string.isNotBlank(each.BusinessCategory__c) && string.isNotBlank(each.Sub_Category__c)){
                        subCategoryIds.add(each.Sub_Category__c);
                    }
                    
                    //================ Owner update for indi and Sole================                
                    if(String.valueof(each.OwnerId).startsWith('00G') && string.isNotBlank(each.Business_Entity__c) && string.isBlank(each.Partner__c) && String.isBlank(each.Partner_ID__c) && String.isNotBlank(each.Owner_Assignment_Header__c) && each.Owner_Assignment_Header__c.startsWith('Sole_Indi') && string.isBlank(each.Aggregator__c)){
                        each.OwnerId = Id.ValueOf(each.Owner_Assignment_Header__c.subStringAfter('-'));
                    }
                    else if(!String.valueof(each.OwnerId).startsWith('00G') && String.valueof(each.OwnerId) == System.Label.IntegrationUserId && string.isNotBlank(each.Business_Entity__c) && string.isBlank(each.Partner__c) && String.isBlank(each.Partner_ID__c) && String.isNotBlank(each.Owner_Assignment_Header__c) && each.Owner_Assignment_Header__c.startsWith('Sole_Indi') && string.isBlank(each.Aggregator__c)){
                        each.OwnerId = Id.ValueOf(each.Owner_Assignment_Header__c.subStringAfter('-'));
                    }
                    else if(String.valueof(each.OwnerId).startsWith('00G') && string.isNotBlank(each.Business_Entity__c) && string.isBlank(each.Partner__c) && String.isBlank(each.Partner_ID__c) && String.isNotBlank(each.Owner_Assignment_Header__c) && string.isNotBlank(each.Aggregator__c)){
                        each.OwnerId = Label.IntegrationUserId;
                    }
                    //================== Shopmatic Lead check for Owner Update ===================
                    
                    if(!partnerIdentifiersMap.isEmpty() && string.isNotBlank(each.Partner_ID__c) && partnerIdentifiersMap.containsKey(each.Partner_ID__c)){
                        shopMaticLeadTriggerNew.add(each);
                    }
                    
                    //================== External Partner Lead assignment=========
                    if(String.isNotBlank(each.RecordTypeId) && leadRecordtypeMap.containskey(each.RecordTypeId) && each.Lead_Type__c == 'External Partner'){
                        counterofExternalPartnerLead = counterofExternalPartnerLead + 1;
                    }
                    
                    //============= Partner Alliance Lead assignment=========
                    if(String.isNotBlank(each.Lead_Type__c) && 'Partner'.equals(each.Lead_Type__c) && string.isNotBlank(each.Queue_Name__c) && each.Queue_Name__c == 'Partnerships_Alliances')
                        counterofPartnerAllianceLead = counterofPartnerAllianceLead + 1;
                    
                    //==============Existing Lead Assignment===========
                    if(String.isNotBlank(each.Lead_Type__c) && 'Merchant'.equals(each.Lead_Type__c) && string.isNotBlank(each.Queue_Name__c) && each.Queue_Name__c == 'Existing_Lead_Assignment'){
                        existingLeadAssignment = existingLeadAssignment + 1;
                    }
                }
                
                /* Kunal - Offline Lead Issue */
                List<Lead> existingLeads = [SELECT Id, Email FROM Lead WHERE Email IN :newLeadEmails];

                // Map to store existing emails and corresponding Lead Ids
                Map<String, Id> existingEmailsMap = new Map<String, Id>();
                for (Lead existingLead : existingLeads) {
                    existingEmailsMap.put(existingLead.Email, existingLead.Id);
                }
                
                // Check each new lead and add an error if the email already exists
                    for (Lead newLead : triggerNew) {
                        if (existingEmailsMap.containsKey(newLead.Email)) {
                            newLead.Email.addError('Lead creation is not allowed because the email already exists on Lead Id: ' + existingEmailsMap.get(newLead.Email));
                        }
                    }
                
                /* Kunal - Offline Lead Issue - END */
                		//*********Calling the COCalloutToGetMIDBatch Batch*********Kunal**********
                		/*COCalloutToGetMIDBatch batch = new COCalloutToGetMIDBatch(leadsToInsertForEnterpriseFlow);
        				Database.executeBatch(batch);*/
                		//**************************End************Kunal***************************
                
                //=========Linking "Select Product" field to Product=== SFI-511=====Kunal=======================
                List<Product__c> prodList = [Select Id, Name from Product__c WHERE Name=:leadIdList];
                Map<String, Id> productNameVsIdMap = new Map<String, Id>();
                for(Product__c currProd : prodList) {
                    productNameVsIdMap.put(currProd.Name, currProd.Id);
                }
                system.debug('productNameVsIdMap'+productNameVsIdMap);
                for(Lead each : triggerNew){
                    if(productNameVsIdMap.containsKey(each.Select_Product__c)) {
                        each.Product__c = productNameVsIdMap.get(each.Select_Product__c);   
                    }
                }
                //=========END==========Linking "Select Product" field to Product=== SFI-511=====Kunal=======================
                //
                //=========Linking "Select Business Category" field to Business Category=========Kunal=======================
                List<Business_Category__c> categoryList = [Select Id, Name from Business_Category__c WHERE Name=:businessCatList];
                Map<String, Id> bussCategoryNameVsIdMap = new Map<String, Id>();
                for(Business_Category__c currBussinessCat : categoryList) {
                    bussCategoryNameVsIdMap.put(currBussinessCat.Name, currBussinessCat.Id);
                }
                system.debug('bussCategoryNameVsIdMap'+bussCategoryNameVsIdMap);
                for(Lead each : triggerNew){
                    if(bussCategoryNameVsIdMap.containsKey(each.Select_Business_Category__c)) {
                        each.BusinessCategory__c = bussCategoryNameVsIdMap.get(each.Select_Business_Category__c);   
                    }
                }
                //=========END==========Linking Select Business Category" field to Business Category=====Kunal=======================
                //
                //=========Linking "Select Sub Category" field to Sub Category=== SFI-511=====Kunal=======================
                List<Sub_Category__c> subCategoryList = [Select Id, Name from Sub_Category__c WHERE Name=:subCatList];
                Map<String, Id> subCategoryNameVsIdMap = new Map<String, Id>();
                for(Sub_Category__c currSubCat : subCategoryList) {
                    subCategoryNameVsIdMap.put(currSubCat.Name, currSubCat.Id);
                }
                system.debug('subCategoryNameVsIdMap'+subCategoryNameVsIdMap);
                for(Lead each : triggerNew){
                    if(subCategoryNameVsIdMap.containsKey(each.Select_Sub_Category__c)) {
                        each.Sub_Category__c = subCategoryNameVsIdMap.get(each.Select_Sub_Category__c);   
                    }
                }
                //=========END==========Linking "Select Sub Category" field to Sub Category=====Kunal=======================
                //
                //=========Linking "Select Entity" field to Business Entity=== SFI-511=====Kunal=======================
                List<Entity__c> entityList = [Select Id, Name from Entity__c WHERE Name=:bussEntityList];
                Map<String, Id> bussEntityNameVsIdMap = new Map<String, Id>();
                for(Entity__c currBussEntity : entityList) {
                    bussEntityNameVsIdMap.put(currBussEntity.Name, currBussEntity.Id);
                }
                system.debug('bussEntityNameVsIdMap'+bussEntityNameVsIdMap);
                for(Lead each : triggerNew){
                    if(bussEntityNameVsIdMap.containsKey(each.Select_Entity__c)) {
                        each.Business_Entity__c = bussEntityNameVsIdMap.get(each.Select_Entity__c);   
                    }
                }
                //=========END==========Linking "Select Entity" field to Business Entity=====Kunal=======================
                
                // This is used to check partner lead and add to set for owner assignment
                if(counterofPartnerLead > 0){
                    List<Group> lstGroup = getGroupdata(Label.Reseller_Sales_Team);
                    if(lstGroup != null && lstGroup.size() > 0){
                        for(Lead objLead : triggerNew){
                            System.debug('==========='+objLead.Round_Robin_Identifier__c);
                            if(lstGroup[0].GroupMembers != null && !lstGroup[0].GroupMembers.isEmpty()){                        
                                Integer userIndex = Math.mod(IntrandomNumber, lstGroup[0].GroupMembers.Size());
                                system.debug('userIndex ===== '+userIndex);
                                system.debug('userIndex value ===== '+lstGroup[0].GroupMembers.get(userIndex).UserOrGroupId);
                                objLead.OwnerId = lstGroup[0].GroupMembers.get(userIndex).UserOrGroupId;
                                IntrandomNumber = IntrandomNumber+1;
                            } 
                        }
                    }
                }
                
                // This is used to check External partner lead and add to set for owner assignment
                if(counterofExternalPartnerLead > 0){
                    List<Group> lstGroup = getGroupdata('External_Partner_Team');
                    if(lstGroup != null && lstGroup.size() > 0){
                        for(Lead objLead : triggerNew){
                            If(String.isNotBlank(objLead.RecordTypeId) && leadRecordtypeMap.containskey(objLead.RecordTypeId) && objLead.Lead_Type__c == 'External Partner'){
                                if(lstGroup[0].GroupMembers != null && !lstGroup[0].GroupMembers.isEmpty()){                        
                                    Integer userIndex = Math.mod(ExternalIntrandomNumber, lstGroup[0].GroupMembers.Size());
                                    objLead.OwnerId = lstGroup[0].GroupMembers.get(userIndex).UserOrGroupId;
                                    ExternalIntrandomNumber = ExternalIntrandomNumber + 1;
                                } 
                            }
                        }
                    }
                }
                
                //======== This is used to check partner alliances lead and add to set for owner assignment
                if(counterofPartnerAllianceLead > 0){
                    List<Group> lstGroup = getGroupdata('Partnerships_Alliances');
                    if(lstGroup != null && lstGroup.size() > 0){
                        for(Lead objLead : triggerNew){
                            if(lstGroup[0].GroupMembers != null && !lstGroup[0].GroupMembers.isEmpty()){                        
                                Integer userIndex = Math.mod(IntrandomNumber, lstGroup[0].GroupMembers.Size());
                                objLead.OwnerId = lstGroup[0].GroupMembers.get(userIndex).UserOrGroupId;
                                PartnerAllianceIntrandomNumber = PartnerAllianceIntrandomNumber+1;
                            }
                        }
                    }
                }
                
                //======== This is used to check round robin lead and add to set for owner assignment
                if(existingLeadAssignment > 0){
                    List<Group> lstGroup = getGroupdata('Existing_Lead_Assignment');
                    if(lstGroup != null && lstGroup.size() > 0){
                        for(Lead objLead : triggerNew){
                            if(lstGroup[0].GroupMembers != null && !lstGroup[0].GroupMembers.isEmpty()){
                                Integer userIndex = Math.mod(existingLeadIntrandomNumber, lstGroup[0].GroupMembers.Size());
                                objLead.OwnerId = lstGroup[0].GroupMembers.get(userIndex).UserOrGroupId;
                                existingLeadIntrandomNumber = existingLeadIntrandomNumber + 1;
                            }
                        }
                    }
                }
                
                if(!lstLead.isEmpty())   updateLOBAndRiskAutoApproved(lstLead, setBusinessCategory);  
                
                if(!shopMaticLeadTriggerNew.isEmpty() && shopMaticLeadTriggerNew.Size()>0) checkModifyOwner(shopMaticLeadTriggerNew, null);
                
                //==============update delivery duration=====================
                if(!subCategoryIds.isEmpty() && subCategoryIds.size()>0){
                    updateDeliveryDuration(subCategoryIds,triggerNew);
                }
            }
    
    // this method call FROM Lead trigger at before update
    public static void beforeUpdateHandler(List<Lead> triggerNew, Map<Id, Lead> triggerOldMap){ 
        Map<string,string> fieldWithMessage = new Map<string,string>();
        try{
            
            //Prashant
            Map<string,string> otherLeadRecordtypeMap = (Map<string,string>)JSON.deserialize(system.label.Lead_Convert_Recordtype, Map<string,string>.class); 
            List<Lead> otherLeadTriggerNew = New List<Lead>();  
            List<Lead> leadList = new List<Lead>();
            //Prashant     
            Set<Id> subCategoryIds = new Set<Id>(); 
            List<Lead> leadTriggerNew = New List<Lead>();
            
            // shopmatic lead check for owner
            List<Lead> shopMaticLeadTriggerNew = New List<Lead>();
            
            // Get all group and group Member 
            Map<Id,Group> allGroupDataMap = New Map<Id,Group>();
            Set<String> groupIdSet = new Set<String>();
            Boolean isGroupToQuery = false;
            //Map<String, String> partnerIdentifiersMap = (Map<String, String>)JSON.deserialize(Label.Merchant_Owner_for_Shopmatic, Map<String, String>.class);
            Map<String, String> partnerIdentifiersMap = new Map<string,string>();	
            for(Partner_Lead_Ownership__mdt  ownerMetadata : [Select id,PartnerId_OwnerId_Map__c FROM Partner_Lead_Ownership__mdt order by label]){	
                partnerIdentifiersMap = (Map<String, String>)JSON.deserialize(ownerMetadata.PartnerId_OwnerId_Map__c, Map<String, String>.class);	
            } 
            Integer existingLeadAssignment = 0;
            Integer existingLeadIntrandomNumber = Integer.valueof((Math.random() * 1000));
            
            List<Id> leadIdSet = new List<Id>();
            List<String> bussEntityList = new List<String>();
            
            
            for(Lead each : triggerNew){
                /* SFI : 1125 :: GST Number Validation : 3rd to 12th character of GST Number should be the PAN Number*/
                String gstNumber = each.GST_Number__c;
                String panNumber = each.PAN_Number__c;
                
                if(gstNumber != null && gstNumber.length() == 15){
                    String gstSubString = gstNumber.subString(2, 12);
                    if(!gstSubString.equals(panNumber)){
                        each.addError('Invalid GST Number. GST Number should be of 15 characters. Also, 3rd to 12th character of GST Number should be the PAN Number');
                        System.debug('WRONG GST');
                    }
                }
                /*End : GST Number Validation */
                
                /*** Added by Kunal - SFI-479***/
                if( (each.Prod_Merchant_Id__c == NULL && each.Identifier__c == NULL && each.Merchant_Account_Id__c == NULL && ((each.MobilePhone != triggerOldMap.get(each.Id).MobilePhone || each.Email != triggerOldMap.get(each.Id).Email)) || each.Switch_to_get_MID__c != triggerOldMap.get(each.Id).Switch_to_get_MID__c)) leadIdSet.add(each.Id);//&& each.Merchant_Account_Id__c == NULL
                /*if(each.Offline_Lead__c == true && enterpriseBusinessType == false) {
                    each.Merchant_Business_Type__c = 'Enterprise';
                    enterpriseBusinessType = true;
                }*/
                System.debug('triggerOldMap : '+triggerOldMap.get(each.Id).MobilePhone);
                System.debug('newMap : '+each.MobilePhone);
                // if(each.Prod_Merchant_Id__c == NULL && each.Identifier__c == NULL && each.Merchant_Account_Id__c == NULL ) leadIdSet.add(each.Id);//&& each.Merchant_Account_Id__c == NULL
                bussEntityList.add(each.Select_Entity__c);
				/*END** Added by Kunal - SFI-479***/
                
                if(String.isNotBlank(each.Owner_Assignment_Header__c)){
                    string eachGroupId = each.Owner_Assignment_Header__c.substringAfter('-');
                    groupIdSet.add(eachGroupId);
                }
                if(String.isNotBlank(each.OwnerId) && String.valueOf(each.OwnerId).startsWith('00G')){
                    groupIdSet.add(each.OwnerId);
                }
                if(String.isNotBlank(each.Owner_Assignment_Header__c) && !allGroupDataMap.containsKey(Id.ValueOf(each.Owner_Assignment_Header__c.substringAfter('-'))) && (!allGroupDataMap.containsKey(each.OwnerId) && String.valueOf(each.OwnerId).startsWith('00G'))){
                    isGroupToQuery = true;
                }
                
                if(String.isNotBlank(each.FirstName))
                    each.Signup_First_Name__c = each.FirstName;
                
                each.Lead_date__c = System.Today();
                
                if(String.isNotBlank(each.LastName)) 
                    each.Signup_Last_Name__c = each.LastName;
                
                if(String.isNotBlank(each.PAN_Holder_Name__c) && String.isBlank(each.Legal_Name__c))
                    each.Legal_Name__c = each.PAN_Holder_Name__c;
                
                if(String.isNotBlank(each.PAN_Holder_Name__c) && String.isBlank(each.LastName))
                    each.LastName = each.PAN_Holder_Name__c;
                
                /******ADDED as part of Offline Lead : To make PAN Verification as Success*****/
                //if(each.Offline_Lead__c = TRUE && each.PAN_Number__c != null) each.PAN_Verification_Status__c = 'Success';
                 /******END::::To make PAN Verification as Success*****/
            }
            
            //=========Linking "Select Entity" field to Business Entity=== SFI-511=====Kunal=======================
                List<Entity__c> entityList = [Select Id, Name from Entity__c WHERE Name=:bussEntityList];
                Map<String, Id> bussEntityNameVsIdMap = new Map<String, Id>();
                for(Entity__c currBussEntity : entityList) {
                    bussEntityNameVsIdMap.put(currBussEntity.Name, currBussEntity.Id);
                }
                system.debug('bussEntityNameVsIdMap'+bussEntityNameVsIdMap);
                for(Lead each : triggerNew){
                    if(bussEntityNameVsIdMap.containsKey(each.Select_Entity__c)) {
                        each.Business_Entity__c = bussEntityNameVsIdMap.get(each.Select_Entity__c);   
                    }
                }
                //=========END==========Linking "Select Entity" field to Business Entity=====Kunal=======================
            /*if(!leadIdSet.isEmpty()){
              COCalloutToGetMIDBatch batch = new COCalloutToGetMIDBatch(leadIdSet, 50);
        	  Database.executeBatch(batch);
            }*/
            
            if(!leadIdSet.isEmpty()){
            COCalloutToGetMIDQueueable queueable = new COCalloutToGetMIDQueueable(leadIdSet);
            System.enqueueJob(queueable);
            }
            
            // Change lead status based on othere business category and other sub category before update
            changeLeadStatusBU(triggerNew, triggerOldMap);
            
            if(groupIdSet.size()>0 && !groupIdSet.isEmpty() && isGroupToQuery){
                allGroupDataMap.putAll([SELECT Id, Name, Type, (SELECT Id, UserOrGroupId, GroupId FROM GroupMembers) FROM Group WHERE Id IN : groupIdSet]);
            }
            
            //List<Group> lstGroupObj = [SELECT Id, Name, Type, (SELECT Id, UserOrGroupId, GroupId FROM GroupMembers) FROM Group WHERE DeveloperName =: Label.Other_Queue_Name AND Type =: 'Queue' LIMIT 1];
            //System.debug('lstGroupObj ==> '+lstGroupObj);
            
            //update Merchant Trading name with Legal Name//
            for(Lead each : triggerNew){
                //Used to copy Test MID and MID
                copyMIDToTxtField(each);
                
                if(otherLeadRecordtypeMap.containsKey(each.RecordTypeId) && otherLeadRecordtypeMap.get(each.RecordTypeId) == each.Lead_Type__c){
                    If(otherLeadRecordtypeMap.get(each.RecordTypeId) == 'Wibmo') otherLeadTriggerNew.add(each);
                }else{  
                    leadTriggerNew.add(each);   
                }
                
                if(String.isNotBlank(each.Legal_Name__c) && ((String.isBlank(each.Merchant_Trading_Name__c) && 
                                                              (each.Legal_Name__c != triggerOldMap.get(each.Id).Legal_Name__c || each.Merchant_Trading_Name__c != triggerOldMap.get(each.Id).Merchant_Trading_Name__c)) || 
                                                             (String.isNotBlank(each.Merchant_Trading_Name__c) && each.Legal_Name__c != triggerOldMap.get(each.Id).Legal_Name__c &&
                                                              triggerOldMap.get(each.Id).Merchant_Trading_Name__c == triggerOldMap.get(each.Id).Legal_Name__c)))
                { 
                    each.Merchant_Trading_Name__c = each.Legal_Name__c;
                }
                
                // ==============Commented due to JIRA ISSUE Because on some partner cases LeadSouce will always not will be partner. 
                //if(String.isNotBlank(each.LeadSource) && each.Partner__c != null && (each.LeadSource!= triggerOldMap.get(each.Id).LeadSource || each.Partner__c != triggerOldMap.get(each.Id).Partner__c) 
                //    && each.LeadSource.equalsIgnoreCase('Partner') && String.isNotBlank(each.Partner_Owner_Id__c)){
                if(each.Partner__c != triggerOldMap.get(each.Id).Partner__c && String.isNotBlank(each.Partner_Owner_Id__c)){
                    if(!partnerIdentifiersMap.isEmpty() && !partnerIdentifiersMap.containsKey(each.Partner_ID__c)){
                        each.OwnerId = each.Partner_Owner_Id__c;
                    }else if(partnerIdentifiersMap.isEmpty()){
                        each.OwnerId = each.Partner_Owner_Id__c;}                
                }
                
                if(!String.valueof(each.OwnerId).startsWith('00G') && !each.Owner_Active__c && allGroupDataMap != null && !allGroupDataMap.isEmpty() && allGroupDataMap.get(Id.ValueOf(each.Owner_Assignment_Header__c.subStringAfter('-'))).GroupMembers != null && !allGroupDataMap.get(Id.ValueOf(each.Owner_Assignment_Header__c.subStringAfter('-'))).GroupMembers.isEmpty() && String.valueof(each.OwnerId) != System.Label.IntegrationUserId && String.isNotBlank(each.Owner_Assignment_Header__c) && string.isBlank(each.Partner__c) && ('Merchant'.equals(each.Lead_Type__c) || 'seller'.equals(each.Lead_Type__c) || 'aggregator'.equals(each.Lead_Type__c))){
                    Integer userIndex = Math.mod(Integer.valueOf(each.Round_Robin_Identifier__c), allGroupDataMap.get(Id.ValueOf(each.Owner_Assignment_Header__c.subStringAfter('-'))).GroupMembers.Size());
                    
                    each.OwnerId = allGroupDataMap.get(Id.ValueOf(each.Owner_Assignment_Header__c.subStringAfter('-'))).GroupMembers.get(userIndex).UserOrGroupId;} 
                
                /*if(String.valueof(each.OwnerId).startsWith('00G') && lstGroupObj != null && !lstGroupObj.isEmpty() && lstGroupObj[0].GroupMembers != null && !lstGroupObj[0].GroupMembers.isEmpty()
&& each.isConverted && each.isConverted != triggerOldMap.get(each.Id).isConverted && !(each.ProductLabel__c == 'PayUnow' ||  ((each.ProductLabel__c == 'PayUmoney' || each.ProductLabel__c == 'PayUbiz') && each.Integration_Type__c == 'Tools'))){
Integer userIndex = Math.mod(Integer.valueOf(each.Round_Robin_Identifier__c), lstGroupObj[0].GroupMembers.Size());
system.debug('userIndex ===== '+userIndex);
system.debug('userIndex value ===== '+lstGroupObj[0].GroupMembers.get(userIndex).UserOrGroupId);
each.OwnerId = lstGroupObj[0].GroupMembers.get(userIndex).UserOrGroupId;
}*/
                
                
                if(String.valueof(each.OwnerId).startsWith('00G') && allGroupDataMap != null && !allGroupDataMap.isEmpty() && allGroupDataMap.containsKey(each.OwnerId) && allGroupDataMap.get(each.OwnerId).GroupMembers != null && !allGroupDataMap.get(each.OwnerId).GroupMembers.isEmpty() && each.isConverted && each.isConverted != triggerOldMap.get(each.Id).isConverted && string.isBlank(each.Partner__c) && ('Merchant'.equals(each.Lead_Type__c) || 'seller'.equals(each.Lead_Type__c) || 'child_aggregator'.equals(each.Lead_Type__c) || 'Child Aggregator'.equals(each.Lead_Type__c))){
                    Integer userIndex = Math.mod(Integer.valueOf(each.Round_Robin_Identifier__c), allGroupDataMap.get(each.OwnerId).GroupMembers.Size());
                    
                    each.OwnerId = allGroupDataMap.get(each.OwnerId).GroupMembers.get(userIndex).UserOrGroupId;
                }
                // Updated by Shivdeep for user ownerId
                else if(String.valueof(each.OwnerId).startsWith('00G') && allGroupDataMap != null && !allGroupDataMap.isEmpty() && allGroupDataMap.containsKey(each.OwnerId) && allGroupDataMap.get(each.OwnerId).GroupMembers != null && !allGroupDataMap.get(each.OwnerId).GroupMembers.isEmpty() && String.isNotBlank(each.Business_Entity__c) && each.Business_Entity__c != triggerOldMap.get(each.Id).Business_Entity__c && string.isBlank(each.Partner__c) && ('Merchant'.equals(each.Lead_Type__c) || 'seller'.equals(each.Lead_Type__c) || 'child_aggregator'.equals(each.Lead_Type__c) || 'Child Aggregator'.equals(each.Lead_Type__c))){
                    Integer userIndex = Math.mod(Integer.valueOf(each.Round_Robin_Identifier__c), allGroupDataMap.get(each.OwnerId).GroupMembers.Size());
                    
                    each.OwnerId = allGroupDataMap.get(each.OwnerId).GroupMembers.get(userIndex).UserOrGroupId;}
                
                if(!String.valueof(each.OwnerId).startsWith('00G') && allGroupDataMap != null && !allGroupDataMap.isEmpty() && allGroupDataMap.containsKey(Id.ValueOf(each.Owner_Assignment_Header__c.subStringAfter('-'))) && allGroupDataMap.get(Id.ValueOf(each.Owner_Assignment_Header__c.subStringAfter('-'))).GroupMembers != null && !allGroupDataMap.get(Id.ValueOf(each.Owner_Assignment_Header__c.subStringAfter('-'))).GroupMembers.isEmpty() && each.isConverted && each.isConverted != triggerOldMap.get(each.Id).isConverted && String.valueof(each.OwnerId) == System.Label.IntegrationUserId && String.isNotBlank(each.Owner_Assignment_Header__c) && string.isBlank(each.Partner__c) && ('Merchant'.equals(each.Lead_Type__c) || 'seller'.equals(each.Lead_Type__c) || 'child_aggregator'.equals(each.Lead_Type__c) || 'Child Aggregator'.equals(each.Lead_Type__c))){
                    
                    Integer userIndex = Math.mod(Integer.valueOf(each.Round_Robin_Identifier__c), allGroupDataMap.get(Id.ValueOf(each.Owner_Assignment_Header__c.subStringAfter('-'))).GroupMembers.Size());
                    
                    each.OwnerId = allGroupDataMap.get(Id.ValueOf(each.Owner_Assignment_Header__c.subStringAfter('-'))).GroupMembers.get(userIndex).UserOrGroupId;
                    
                }            
                // Updated by Shivdeep for user ownerId
                else if(!String.valueof(each.OwnerId).startsWith('00G') && allGroupDataMap != null && !allGroupDataMap.isEmpty() && allGroupDataMap.containsKey(Id.ValueOf(each.Owner_Assignment_Header__c.subStringAfter('-'))) && allGroupDataMap.get(Id.ValueOf(each.Owner_Assignment_Header__c.subStringAfter('-'))).GroupMembers != null && !allGroupDataMap.get(Id.ValueOf(each.Owner_Assignment_Header__c.subStringAfter('-'))).GroupMembers.isEmpty() && String.isNotBlank(each.Business_Entity__c) && each.Business_Entity__c != triggerOldMap.get(each.Id).Business_Entity__c && String.valueof(each.OwnerId) == System.Label.IntegrationUserId && String.isNotBlank(each.Owner_Assignment_Header__c) && string.isBlank(each.Partner__c) && ('Merchant'.equals(each.Lead_Type__c) || 'seller'.equals(each.Lead_Type__c) || 'child_aggregator'.equals(each.Lead_Type__c))){
                    
                    Integer userIndex = Math.mod(Integer.valueOf(each.Round_Robin_Identifier__c), allGroupDataMap.get(Id.ValueOf(each.Owner_Assignment_Header__c.subStringAfter('-'))).GroupMembers.Size());
                    
                    each.OwnerId = allGroupDataMap.get(Id.ValueOf(each.Owner_Assignment_Header__c.subStringAfter('-'))).GroupMembers.get(userIndex).UserOrGroupId;
                }
                
                
                // OwnerId update end
                //update Online Lead checkbox for all online leads.
                if((String.isBlank(each.Sub_Source__c) || each.Sub_Source__c == 'WebsiteSignUp') && (each.ProductLabel__c == 'PayUmoney' || each.ProductLabel__c == 'PayUbiz') && (each.Merchant_Account_Id__c != null && each.Offline_Lead__c != true)) each.Online_Lead__c = true; 
                //if((String.isBlank(each.Sub_Source__c) || each.Sub_Source__c == 'WebsiteSignUp') && (each.ProductLabel__c == 'PayUmoney' || each.ProductLabel__c == 'PayUbiz')) each.Online_Lead__c = true; 
                
                //Aggregator and Seller condition added
                if(string.isNotBlank(each.Merchant_Type__c) && merchantTypeList.contains(each.Merchant_Type__c)//(each.Merchant_Type__c=='Aggregator' || each.Merchant_Type__c=='Seller' || each.Merchant_Type__c=='aggregator' || each.Merchant_Type__c=='seller') 
                   && each.Merchant_Type__c != triggerOldMap.get(each.Id).Merchant_Type__c && (System.isBatch() || Test.isRunningTest())){
                       each.Lead_Type__c = each.Merchant_Type__c; 
                   }
                //Aggregator and Seller condition added
                if(string.isNotBlank(each.Lead_Type__c) && merchantTypeList.contains(each.Lead_Type__c)//(each.Lead_Type__c=='Aggregator' || each.Lead_Type__c=='Seller'
                   //|| each.Lead_Type__c=='aggregator' || each.Lead_Type__c=='seller') 
                   && each.Lead_Type__c != triggerOldMap.get(each.Id).Lead_Type__c){
                       each.Merchant_Type__c = each.Lead_Type__c;
                   }
                
                //Aggregator and Seller condition added
                /*if(string.isNotBlank(each.Lead_Type__c) && each.Lead_Type__c != triggerOldMap.get(each.Id).Lead_Type__c
&& (each.Lead_Type__c=='Merchant' || each.Lead_Type__c=='Partner'){
each.Merchant_Type__c = '';                
}*/
                
                //===============update delivery duration===============================//
                if(string.isNotBlank(each.BusinessCategory__c) && string.isNotBlank(each.Sub_Category__c) &&
                   (each.Sub_Category__c != triggerOldMap.get(each.Id).Sub_Category__c)){
                       subCategoryIds.add(each.Sub_Category__c);
                   }           
                //==============update delivery end=====================================//
                
                //====================update delivery duration end==================
                
                //Update Call Status and Call Duration of C2C
                if((string.isNotBlank(each.Manual_Call_Response__c) && each.Manual_Call_Response__c!=null 
                    && each.Manual_Call_Response__c.contains(',')
                    && each.Manual_Call_Response__c != triggerOldMap.get(each.Id).Manual_Call_Response__c 
                    && (each.Missed_Call_Time__c == triggerOldMap.get(each.Id).Missed_Call_Time__c)) ||
                   (each.Missed_Call_Time__c != triggerOldMap.get(each.Id).Missed_Call_Time__c && String.isNotBlank(each.Missed_Call_Time__c)))
                {
                    map<string,string> callResponseMap = new Map<string,string>();
                    
                    String manualCallResponce  =each.Manual_Call_Response__c;
                    list<string> listManualCallResponse = new list<string>();
                    
                    if(String.isNotBlank(manualCallResponce)){
                        listManualCallResponse= manualCallResponce.split(',');
                    } 
                    for(integer i=0; i<listManualCallResponse.size(); i++)
                    {
                        list<string> str = listManualCallResponse[i].split(':');
                        callResponseMap.put(str[0],str[1]);
                    }
                    
                    
                    if(!callResponseMap.isEmpty() && callResponseMap != null){
                        each.Call_Status__c = callResponseMap.get('CallStatus');
                        each.Call_Duration__c = callResponseMap.get('Bill_Seconds');
                        // each.Agent_Details__c = each.Agent_Name__c+ ' - '+each.Agent_Mobile__c;
                    }
                    leadList.add(each);
                }
                
                // check if lead is a part od shopmatic
                
                if(!partnerIdentifiersMap.isEmpty() && String.isNotBlank(each.Partner_ID__c) && partnerIdentifiersMap.containsKey(each.Partner_ID__c) && each.Partner_ID__c != triggerOldMap.get(each.Id).Partner_ID__c){
                    shopMaticLeadTriggerNew.add(each);
                }
                
                //==============Existing Lead Assignment===========
                if(String.isNotBlank(each.Lead_Type__c) && 'Merchant'.equals(each.Lead_Type__c) && string.isNotBlank(each.Queue_Name__c) && each.Queue_Name__c == 'Existing_Lead_Assignment' && each.Queue_Name__c != triggerOldMap.get(each.Id).Queue_Name__c){
                    existingLeadAssignment = existingLeadAssignment + 1;
                }
                
                if(each.Prod_Merchant_Id__c != NULL) each.Error_Message__c = '';// Added by Kunal to remove Error_Message__c if MID gets populated
            }
            
            //============== if Shopatric partner is updated on Lead ================
            if(!shopMaticLeadTriggerNew.isEmpty() && shopMaticLeadTriggerNew.size()>0) checkModifyOwner(shopMaticLeadTriggerNew, triggerOldMap);
            
            // ========= Check all validation on lead conversion ===============
            leadConversionValidation(leadTriggerNew);
            
            //Prashant
            if(!otherLeadTriggerNew.isEmpty() && otherLeadTriggerNew.size()>0){
                otherLeadConversionValidation(otherLeadTriggerNew);
            }
            //Prashant 
            
            //===============update delovery duraion ====================
            if(!subCategoryIds.isEmpty()) updateDeliveryDuration(subCategoryIds,triggerNew);
            
            // ===============delivery duration end
            
            if(leadList.size() > 0){
                createTaskforClickToCall(leadList,triggerOldMap); 
            }  
            
            //======== This is used to check round robin lead and add to set for owner assignment
            System.debug('####### existingLeadAssignment '+existingLeadAssignment);
            if(existingLeadAssignment > 0){
                List<Group> lstGroup = getGroupdata('Existing_Lead_Assignment');
                if(lstGroup != null && lstGroup.size() > 0){
                    for(Lead objLead : triggerNew){
                        if(lstGroup[0].GroupMembers != null && !lstGroup[0].GroupMembers.isEmpty()){                          
                            Integer userIndex = Math.mod(existingLeadIntrandomNumber, lstGroup[0].GroupMembers.Size());
                            objLead.OwnerId = lstGroup[0].GroupMembers.get(userIndex).UserOrGroupId;
                            existingLeadIntrandomNumber = existingLeadIntrandomNumber + 1;
                        }
                    }
                }
            }
        }catch(Exception ex){
            fieldWithMessage.put('Message__c',ex.getMessage());
            fieldWithMessage.put('Process__c','BeforeupdateLead');
            fieldWithMessage.put('Request__c','BeforeupdateHandlerLead');
            SystemUtility.errorHandler(ex,fieldWithMessage);
        }
    }
    
    // this method call FROM Lead trigger at after insert
    public static void afterInsertHandler(List<Lead> triggerNew){
        
        Set<String> legalNameSet = new Set<String>();
        Set<String> panNoSet = new Set<String>();
        Set<String> emailSet = new Set<String>();
        Map<String, String> queriedObjMap = new Map<String, String>();
        Set<Id> setGroupId = new Set<Id>();
        Map<Id, Group> mapGroupRecords = new Map<Id, Group>();
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        List<Contact> listContact = new List<Contact>();
        Map<Id, Id> mapLeadIdVsAccId = new Map<Id, Id>();
        Map<Id, Id> mapLeadIdVsOppId = new Map<Id, Id>();
        Map<string,string> leadRecordtypeMap = (Map<string,string>)JSON.deserialize(system.label.Lead_Convert_Recordtype, Map<string,string>.class);
        
        List<Lead_Product_Interest__c> leadProductInterest = new List<Lead_Product_Interest__c>();
        
        //==============Used , if conversion happen on insertion.===============
        Set<Id> setConvertedLeadId = New Set<Id>();
        List<Lead> lstConvertedLead = New List<Lead>();
        
        Map<Id, List<Contact>> mapLeadIdVsListCont = new Map<Id, List<Contact>>();
        Map<Id, List<Bank_Account_Detail__c>> mapLeadIdVsListBankAccDet = new Map<Id, List<Bank_Account_Detail__c>>();
        Map<Id, List<Address_Details__c>> mapLeadIdVsListAddress = new Map<Id, List<Address_Details__c>>();
        //update for Consultative selling
        Map<Id, List<Merchant_Plan__c>> mapLeadIdVsListMerchantPlan = new Map<Id, List<Merchant_Plan__c>>();
        Map<Id, List<Merchant_Status_Details__c>> mapLeadIdVsListMerchantStatusDetail = new Map<Id, List<Merchant_Status_Details__c>>();
        
        List<Bank_Account_Detail__c> listBankAccDet = new List<Bank_Account_Detail__c>();
        List<Address_Details__c> listAddDetails = new List<Address_Details__c>();
        //update for Consultative selling
        List<Merchant_Plan__c> listMerchantPlan = new List<Merchant_Plan__c>();
        List<Merchant_Status_Details__c> lstMerchantStatusDetails = new List<Merchant_Status_Details__c>();
        //Set<Id> leadIdSet = new Set<Id>();
        List<Id> leadIdSet = new List<Id>();
        
        for(Lead each : triggerNew){ 
            
            /*leadIdSet.add(each.Id);
            if(each.Prod_Merchant_Id__c == NULL) getMID(leadIdSet);*/
           if(each.Prod_Merchant_Id__c == NULL && each.Identifier__c == NULL && each.Merchant_Account_Id__c == NULL ) leadIdSet.add(each.Id);//&& each.Merchant_Account_Id__c == NULL
            
            
            if('Partner'.equals(each.Lead_Type__c) && !each.isConverted){
                if(String.isNotBlank(each.Legal_Name__c)) legalNameSet.add(each.Legal_Name__c);            
                //if(String.isNotBlank(each.PAN_Number__c)) panNoSet.add(each.PAN_Number__c);            
                if(String.isNotBlank(each.Email)) emailSet.add(each.Email); 
                if(String.isNotBlank(each.Merchant_Account_Id__c )) merchantAccId.add(each.Merchant_Account_Id__c ); 
                if(String.valueof(each.OwnerId).startsWith('00G')) setGroupId.add(each.OwnerId);
            }
            //===============Commenting Wibmo Code as Team is not using the product===========             
            /*if(String.isNotBlank(each.RecordTypeId) && leadRecordtypeMap.containskey(each.RecordTypeId)){
If(leadRecordtypeMap.get(each.RecordTypeId) == 'Wibmo')
LeadConvert_Wibmo(each, null, leadsToConvert, queriedObjMap, null, null, null);
} */
        }
        
        /*if(!leadIdSet.isEmpty()){
            COCalloutToGetMIDBatch batch = new COCalloutToGetMIDBatch(leadIdSet, 50);
            Database.executeBatch(batch);
        }*/
        
        
        if(!leadIdSet.isEmpty()){
        COCalloutToGetMIDQueueable queueable = new COCalloutToGetMIDQueueable(leadIdSet);
        System.enqueueJob(queueable);
        }
        

        
        
        if(!setGroupId.isEmpty()) getGroupDetails(setGroupId, mapGroupRecords);
        if(!legalNameSet.isEmpty() || !merchantAccId.isEmpty() || !emailSet.isEmpty()) returnAccConMap(legalNameSet, merchantAccId, emailSet, queriedObjMap);
        for(Lead each : triggerNew){ 
            LeadTriggerHandler.merchantAccId.add(each.Merchant_Account_Id__c);//added by rohit
            /*if('Partner'.equals(each.Lead_Type__c) && !each.isConverted){               
returnLeadConvertList(each, null, leadsToConvert, queriedObjMap, mapGroupRecords, null, null); 
}*/
            //========= Adding Business Entity check for Onboarding Revamp-JIRA-SFPI-997============
            if(('Partner'.equals(each.Lead_Type__c) && !each.isConverted) || (String.isNotBlank(each.Business_Entity__c) && String.isNotBlank(each.Legal_Name__c) && String.isNotBlank(each.PAN_Number__c) && !'Partner'.equals(each.Lead_Type__c) && !each.isConverted)){               
                returnLeadConvertList(each, null, leadsToConvert, queriedObjMap, mapGroupRecords, null, null); 
            }
            //============Used when lead converted during insertion================
            if(each.isConverted){ 
                setConvertedLeadId.add(each.id);
                lstConvertedLead.add(each);
            }
            //if(each.Merchant_Account_Id__c != null && each.Offline_Lead__c == true) each.Online_Lead__c = FALSE;
        }
        
        if(!setConvertedLeadId.isEmpty()) getRelListOfLead(setConvertedLeadId, mapLeadIdVsListCont, mapLeadIdVsListBankAccDet, mapLeadIdVsListAddress,mapLeadIdVsListMerchantPlan, mapLeadIdVsListMerchantStatusDetail);
        
        // ==== Getting the list of Contact to update ==============
        if(!lstConvertedLead.isEmpty()) createContactRecords(lstConvertedLead, listContact, mapLeadIdVsListCont);
        
        // ==== Getting the list of Bank Account Details to update ==============
        if(!lstConvertedLead.isEmpty()) createBankAccDetailsRecords(lstConvertedLead, listBankAccDet, mapLeadIdVsListBankAccDet);
        
        // ==== Getting the list of Address Details to update ==============
        if(!lstConvertedLead.isEmpty())  createAddressDeatilRecords(lstConvertedLead, listAddDetails, mapLeadIdVsListAddress);
        
        // ==== Getting the list of Merchant Plans to update ==============
        if(!lstConvertedLead.isEmpty())  createMerchantPlanRecords(lstConvertedLead, listMerchantPlan, mapLeadIdVsListMerchantPlan);
        
        // ==== Getting the list of Merchant Status Details to update ==============
        if(!lstConvertedLead.isEmpty())  createMerchantStatusDetailRecords(lstConvertedLead, lstMerchantStatusDetails, mapLeadIdVsListMerchantStatusDetail);
        
        if(!leadsToConvert.isEmpty()) 
            conversionUtil(leadsToConvert, listContact, mapLeadIdVsAccId, mapLeadIdVsOppId, (Map<Id, Lead>)Trigger.newMap);
        
        List<Opportunity> listOpportunity = new List<Opportunity>();
        if(!mapLeadIdVsOppId.isEmpty()) updateOppPlan(triggerNew, listOpportunity, mapLeadIdVsOppId);
        
        if(!listOpportunity.isEmpty()) updateOpportunities(listOpportunity);        
        
        
        // ==== Insert and Update Contact =========================
        if(!listContact.isEmpty()){
            Database.SaveResult[] saveResults = Database.update(listContact, false); //update listContact;
            if(saveResults != null && !saveResults.isEmpty()){
                Map<String, String> messages = new Map<String, String>();
                List<String> lstContIds = new List<String>();
                for(Database.SaveResult saveResult : saveResults){
                    if(!saveResult.isSuccess() || Test.isRunningTest()){
                        List<String> lstErrors = new List<String>();
                        SystemUtility.getAllErrors(saveResult.getErrors(), lstErrors);
                        messages.put(saveResult.getId(), String.join(lstErrors, '\n'));
                        lstContIds.add(saveResult.getId());
                    }
                }
                
                if(!messages.isEmpty()){
                    messages.put('Severity__c', 'High');
                    messages.put('Process__c', 'After lead conversion insert Contacts records');
                    messages.put('SF_ID__c', String.join(lstContIds, ','));
                    SystemUtility.errorHandler(null, messages);
                }
            }
        } 
        
        // ==== Updatye bank account details =========================
        if(!listBankAccDet.isEmpty()){
            Database.SaveResult[] saveResults = Database.update(listBankAccDet, false); //update listBankAccDet;
            if(saveResults != null && !saveResults.isEmpty()){
                Map<String, String> messages = new Map<String, String>();
                List<Id> lstBankAccDetIds = new List<Id>();
                for(Database.SaveResult saveResult : saveResults){
                    if(!saveResult.isSuccess() || Test.isRunningTest()){
                        List<String> lstErrors = new List<String>();
                        SystemUtility.getAllErrors(saveResult.getErrors(), lstErrors);
                        messages.put(saveResult.getId(), String.join(lstErrors, '\n'));
                        lstBankAccDetIds.add(saveResult.getId()); }
                }
                
                if(!messages.isEmpty()){
                    messages.put('Severity__c', 'High');
                    messages.put('Process__c', 'After lead conversion insert Bank Account Details records');
                    if(!lstBankAccDetIds.isEmpty()) messages.put('SF_ID__c', String.join(lstBankAccDetIds, ','));
                    SystemUtility.errorHandler(null, messages);}
            }
        }
        
        // ==== Update address details =========================
        if(!listAddDetails.isEmpty()){
            Database.SaveResult[] saveResults = Database.update(listAddDetails, false); //update listAddDetails;
            if(saveResults != null && !saveResults.isEmpty()){
                Map<String, String> messages = new Map<String, String>();
                List<String> lstAddDetailIds = new List<String>();
                for(Database.SaveResult saveResult : saveResults){
                    if(!saveResult.isSuccess() || Test.isRunningTest()){
                        List<String> lstErrors = new List<String>();
                        SystemUtility.getAllErrors(saveResult.getErrors(), lstErrors);
                        /*messages.put(saveResult.getId(), String.join(lstErrors, '\n'));
lstAddDetailIds.add(saveResult.getId());*/
                        for(Address_Details__c addDetail : listAddDetails){
                            messages.put(addDetail.Id, String.join(lstErrors, '\n'));
                            lstAddDetailIds.add(addDetail.Id);
                        }
                    }
                }
                
                if(!messages.isEmpty()){
                    messages.put('Severity__c', 'High');
                    messages.put('Process__c', 'After lead conversion insert Address Details records');
                    messages.put('SF_ID__c', String.join(lstAddDetailIds, ','));
                    SystemUtility.errorHandler(null, messages);
                }
            }
        }
        
        // ==== Update Merchant Plan details =========================
        if(!listMerchantPlan.isEmpty()){
            Database.SaveResult[] saveResults = Database.update(listMerchantPlan, false); //update listBankAccDet;
            if(saveResults != null && !saveResults.isEmpty()){
                Map<String, String> messages = new Map<String, String>();
                List<Id> lstMerchantPlanIds = new List<Id>();
                for(Database.SaveResult saveResult : saveResults){
                    if(!saveResult.isSuccess() || Test.isRunningTest()){
                        List<String> lstErrors = new List<String>();
                        SystemUtility.getAllErrors(saveResult.getErrors(), lstErrors);
                        messages.put(saveResult.getId(), String.join(lstErrors, '\n'));
                        lstMerchantPlanIds.add(saveResult.getId()); }
                }
                
                if(!messages.isEmpty()){
                    messages.put('Severity__c', 'High');
                    messages.put('Process__c', 'After lead conversion insert Merchant Plan records');
                    if(!lstMerchantPlanIds.isEmpty()) messages.put('SF_ID__c', String.join(lstMerchantPlanIds, ','));
                    SystemUtility.errorHandler(null, messages);}
            }
        }
        
        // ==== Update Merchant Status details =========================
        if(!lstMerchantStatusDetails.isEmpty()){
            Database.SaveResult[] saveResults = Database.update(lstMerchantStatusDetails, false);
            if(saveResults != null && !saveResults.isEmpty()){
                Map<String, String> messages = new Map<String, String>();
                List<Id> lstMerchantStatusDetailIds = new List<Id>();
                for(Database.SaveResult saveResult : saveResults){
                    if(!saveResult.isSuccess() || Test.isRunningTest()){
                        List<String> lstErrors = new List<String>();
                        SystemUtility.getAllErrors(saveResult.getErrors(), lstErrors);
                        messages.put(saveResult.getId(), String.join(lstErrors, '\n'));
                        lstMerchantStatusDetailIds.add(saveResult.getId()); }
                }
                
                if(!messages.isEmpty()){
                    messages.put('Severity__c', 'High');
                    messages.put('Process__c', 'After lead conversion insert Merchant Status Details records');
                    if(!lstMerchantStatusDetailIds.isEmpty()) messages.put('SF_ID__c', String.join(lstMerchantStatusDetailIds, ','));
                    SystemUtility.errorHandler(null, messages);}
            }
        }
        getMIDAndTriggerAssignment(triggerNew);
        
        
        //**** Create one record of Lead Product Interest Object after the Lead gets created*****KUNAL***********
        
        /*for(Lead lead : triggerNew) {
            Lead_Product_Interest__c productInterest = new Lead_Product_Interest__c();
            productInterest.Lead__c = lead.Id;
            leadProductInterest.add(productInterest);
        }
        
        if(!leadProductInterest.isEmpty()){
            Database.insert(leadProductInterest, false);
        }*/
        
        //****** END **********Create one record of Lead Product Interest Object after the Lead gets created*****
    }
    
    public static void updateOpportunities(List<Opportunity> listOpportunity){
        Database.SaveResult[] saveResults = Database.update(listOpportunity, false); //update listOpportunity;
        if(saveResults != null && !saveResults.isEmpty()){
            Map<String, String> messages = new Map<String, String>();
            List<String> lstOptyIds = new List<String>();
            for(Database.SaveResult saveResult : saveResults){
                if(!saveResult.isSuccess() || Test.isRunningTest()){
                    List<String> lstErrors = new List<String>();
                    SystemUtility.getAllErrors(saveResult.getErrors(), lstErrors);
                    messages.put(saveResult.getId(), String.join(lstErrors, '\n'));
                    lstOptyIds.add(saveResult.getId());
                }
            }
            
            if(!messages.isEmpty()){
                messages.put('Severity__c', 'High');
                messages.put('Process__c', 'After lead conversion Insert Opportunity records');
                messages.put('SF_ID__c', String.join(lstOptyIds, ','));
                SystemUtility.errorHandler(null, messages);
            }
        }
    }
    
    // this method call FROM Lead trigger at after update
    public static void afterUpdateHandler(List<Lead> triggerNew, Map<Id, Lead> triggerOldMap, Map<Id, Lead> triggerNewMap){
        System.debug('triggerNew::::'+triggerNew +'triggerOldMap::::'+triggerOldMap);
        //Prashant
        Map<string,string> leadRecordtypeMap = (Map<string,string>)JSON.deserialize(system.label.Lead_Convert_Recordtype, Map<string,string>.class);
        //Prashant
        List<Lead> lstLeadsforAssignment = new List<Lead>();
       // List<Lead> leadsToUpdate = new List<Lead>();// Added by Kunal SFI:479
        
        for(Lead each : triggerNew){ 
            
           LeadTriggerHandler.merchantAccId.add(each.Merchant_Account_Id__c);//added by rohit
           //Prashant
            if((string.isNotBlank(each.RecordTypeId) && !leadRecordtypeMap.containskey(each.RecordTypeId)) || string.isBlank(each.RecordTypeId)
               || each.RecordTypeId==null){
                   Lead oldEach = triggerOldMap.get(each.Id);
                   if(!LeadConvertBatch.isLeadConversionBatch){ 
                       isLeadConvertedForAction(each, oldEach);
                       if(each.Data_need_to_be_publish__c && publishUpdateFromApex && !runningFromConsumerAPI){
                           System.debug('each:::::'+each+'oldEach:::::::'+oldEach);
                           IntegrationUtility.sendPayLoadData(each, oldEach, 'Lead', 'Lead');
                       }
                       
                   }
                   else if(LeadConvertBatch.isLeadConversionBatch && each.isConverted) IntegrationUtility.oppConvertedSet.add(each.ConvertedOpportunityId);
                   
                   
                   // preparing list of online leads to initiate assignment rule
                   /*if(each.Sub_Source__c == 'WebsiteSignUp'  
&& oldEach.Business_Entity__c != each.Business_Entity__c 
&& String.isNotEmpty(each.Business_Entity__c) && !each.LeadSource.equalsIgnoreCase('Partner'))*/
                   system.debug('-->> 213 '+each.Sub_Source__c+' - '+each.Business_Entity__c+' - '+oldEach.Business_Entity__c +' - '+each.Partner__c+' - '+oldEach.Partner__c);
                   if(each.Sub_Source__c == 'WebsiteSignUp' && String.isNotEmpty(each.Business_Entity__c) && String.isBlank(each.Partner__c)              
                      && (oldEach.Business_Entity__c != each.Business_Entity__c || (each.Partner__c != oldEach.Partner__c)))
                   {
                       system.debug('====='+each);
                       lstLeadsforAssignment.add(new Lead(id=each.id));
                   }
               }
        } 
        
        // triggering assignment rule for online leads
        if(!lstLeadsforAssignment.isEmpty()){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            Database.update(lstLeadsforAssignment, dmo);
        }
        convertTheLeadAU(triggerNew, triggerOldMap, triggerNewMap);
    }
    
    public static void isLeadConvertedForAction(Lead newLead, Lead oldLead){
        if(newLead.isConverted && !oldLead.isConverted){
            IntegrationUtility.oppConvertedSet.add(newLead.ConvertedOpportunityId);
        }
    }
    
    private static void convertTheLeadAU(List<Lead> newList, Map<Id, Lead> oldMap, Map<Id, Lead> triggerNewMap){
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        
        Set<String> legalNameSet = new Set<String>();
        Set<String> panNoSet = new Set<String>();
        Set<String> emailSet = new Set<String>();
        Set<Id> setPlatformId = new Set<Id>();
        Set<Id> setProductId = new Set<Id>();
        List<Contact> listContact = new List<Contact>();
        List<Opportunity> listOpportunity = new List<Opportunity>();
        List<TDR__c> listTDRs = new List<TDR__c>();
        
        Map<Id, Id> mapLeadIdVsAccId = new Map<Id, Id>();
        Map<Id, Id> mapLeadIdVsOppId = new Map<Id, Id>();
        Map<String, String> queriedObjMap = new Map<String, String>();
        
        Set<Id> setConvertedLeadId = new Set<Id>();
        List<Lead> lstConvertedLead = new List<Lead>();
        List<Lead> lstOfflineConvertedLead = new List<Lead>();
        
        Map<Id, List<Contact>> mapLeadIdVsListCont = new Map<Id, List<Contact>>();
        Map<Id, List<Bank_Account_Detail__c>> mapLeadIdVsListBankAccDet = new Map<Id, List<Bank_Account_Detail__c>>();
        Map<Id, List<Address_Details__c>> mapLeadIdVsListAddress = new Map<Id, List<Address_Details__c>>();
        //update for Consultative selling
        Map<Id, List<Merchant_Plan__c>> mapLeadIdVsListMerchantPlan = new Map<Id, List<Merchant_Plan__c>>();
        Map<Id, List<Merchant_Status_Details__c>> mapLeadIdVsListMerchantStatusDetail = New Map<Id, List<Merchant_Status_Details__c>>();
        
        List<Bank_Account_Detail__c> listBankAccDet = new List<Bank_Account_Detail__c>();
        List<Address_Details__c> listAddDetails = new List<Address_Details__c>();
        //update for Consultative selling
        List<Merchant_Plan__c> listMerchantPlan = new List<Merchant_Plan__c>();
        List<Merchant_Status_Details__c> lstMerchantStatusDetails = New List<Merchant_Status_Details__c>();
        
        Set<Id> setGroupId = new Set<Id>();
        Map<Id, Group> mapGroupRecords = new Map<Id, Group>();
        
        List<Group> lstGroupObj = [SELECT Id, Name, Type, (SELECT Id, UserOrGroupId, GroupId FROM GroupMembers) FROM Group WHERE DeveloperName =: Label.Other_Queue_Name AND Type =: 'Queue' LIMIT 1];
        for(Lead each : newList){
            System.debug('each.isConverted::::::'+each.isConverted);
            Lead oldEach = oldMap.get(each.Id);
            if(each.isConverted){
                setConvertedLeadId.add(each.id);
                lstConvertedLead.add(each);
                
                if(!each.Online_Lead__c){
                    lstOfflineConvertedLead.add(each);
                }
                
            }
            
            if(String.valueof(each.OwnerId).startsWith('00G')) {
                setGroupId.add(each.OwnerId);
            }else if(!String.valueof(each.OwnerId).startsWith('00G') && each.ownerId == System.Label.IntegrationUserId && String.isNotBlank(each.Owner_Assignment_Header__c) && each.Owner_Assignment_Header__c!=null){
                setGroupId.add(Id.ValueOf(each.Owner_Assignment_Header__c.subStringAfter('-')));
            }
        } 
        
        if(!setConvertedLeadId.isEmpty()) getRelListOfLead(setConvertedLeadId, mapLeadIdVsListCont, mapLeadIdVsListBankAccDet, mapLeadIdVsListAddress,mapLeadIdVsListMerchantPlan,mapLeadIdVsListMerchantStatusDetail);
        system.debug('######### mapLeadIdVsListMerchantStatusDetail '+mapLeadIdVsListMerchantStatusDetail);
        system.debug('######### lstConvertedLead '+lstConvertedLead);
        // ==== Getting the list of Contact to update ==============
        if(!lstConvertedLead.isEmpty()) createContactRecords(lstConvertedLead, listContact, mapLeadIdVsListCont);
        
        // ==== Getting the list of Bank Account Details to update ==============
        if(!lstConvertedLead.isEmpty()) createBankAccDetailsRecords(lstConvertedLead, listBankAccDet, mapLeadIdVsListBankAccDet);
        
        // ==== Getting the list of Address Details to update ==============
        if(!lstConvertedLead.isEmpty())  createAddressDeatilRecords(lstConvertedLead, listAddDetails, mapLeadIdVsListAddress);
        
        // ==== Getting the list of Merchant Plans to update ==============
        if(!lstConvertedLead.isEmpty())  createMerchantPlanRecords(lstConvertedLead, listMerchantPlan, mapLeadIdVsListMerchantPlan);
        
        // ==== Getting the list of Merchant Status Details to update ============== 
        if(!lstConvertedLead.isEmpty())  createMerchantStatusDetailRecords(lstConvertedLead, lstMerchantStatusDetails, mapLeadIdVsListMerchantStatusDetail);
        
        // ==== Getting the List of Opportunity to update the rceord type for offline process ================  
        if(!lstOfflineConvertedLead.isEmpty()) getListOptyOffline(lstOfflineConvertedLead, listOpportunity);
        
        // ==== Get the Group and GroupMembers Details =====================
        if(!setGroupId.isEmpty()) getGroupDetails(setGroupId, mapGroupRecords);
        Set<String> merchantAccId = new Set<String>();
        for(Lead each : newList){
            System.debug('>>>>>each--> LeadType>>>>>>'+each.Lead_Type__c);
            System.debug('>>>>>each--> RecordType>>>>>>'+each.RecordTypeId);
            merchantAccId.add(each.Merchant_Account_Id__c );
            Lead oldEach = oldMap.get(each.Id);
            getPanAndLegalSet(each, oldEach, legalNameSet, merchantAccId, emailSet);              
        }
        
        if(!legalNameSet.isEmpty() || !merchantAccId.isEmpty() || !emailSet.isEmpty()) returnAccConMap(legalNameSet, merchantAccId, emailSet, queriedObjMap);
        
        Map<String, Contact> contactMap = new Map<String, Contact>();
        List<Contact> contactList = new List<Contact>();
        List<String> identifierListContact = new List<String>();
        Map<String, Account> accountMap = new Map<String, Account>();
        List<Account> accountList = new List<Account>();
        List<String> identifierListAccount = new List<String>();
        getContactAndAccountWithIdentifiers(contactMap, contactList, identifierListContact, accountMap, accountList, identifierListAccount, newList);
        
        for(Lead each : newList){   
            if (!each.isConverted){
                Lead oldEach = oldMap.get(each.Id);
                String setCId;
                String setAId;
                if(identifierListContact.size()>0 && !identifierListContact.isEmpty() && each.Identifier__c != null && identifierListContact.contains(each.Identifier__c)){
                    if(!contactMap.isEmpty() && contactMap.size()>0) setCId = contactMap.get(each.Identifier__c).Id;
                    if(!contactMap.get(each.Identifier__c).Cases.isEmpty() && contactMap.get(each.Identifier__c).Cases.Size()>0) 
                        setAId = contactMap.get(each.Identifier__c).Cases[0].AccountId;
                }
                /* if(identifierListAccount.contains(each.Identifier__c)){
setAId = accountMap.get(each.Identifier__c).Id;
}*/
                if(!identifierListAccount.isEmpty() && identifierListAccount.size()>0 && !accountMap.isEmpty() && accountMap.size()>0){
                    // setAId = accountMap.get(each.Identifier__c).Id;
                }
                system.debug('-->> setCId '+setCId+' -- '+setAId);
                returnLeadConvertList(each, oldEach, leadsToConvert, queriedObjMap, mapGroupRecords, setCId, setAId); 
                //returnLeadConvertList(each, oldEach, leadsToConvert, queriedObjMap, mapGroupRecords, null, null); 
            }
            
        }
        system.debug('leadsToConvert'+leadsToConvert.size());
        system.debug('merchantAccId::::907'+merchantAccId);
        
        if(!leadsToConvert.isEmpty()) {
            conversionUtil(leadsToConvert, listContact, mapLeadIdVsAccId, mapLeadIdVsOppId, triggerNewMap);
        }
        
        // ==== Getting the list of Opportunity to update ==============
        updateOppPlan(newList, listOpportunity, mapLeadIdVsOppId);
        
        // ==== Insert and Update Contact =========================
        if(!listContact.isEmpty()){
            Database.SaveResult[] saveResults = Database.update(listContact, false); //update listContact;
            if(saveResults != null && !saveResults.isEmpty()){
                Map<String, String> messages = new Map<String, String>();
                List<String> lstContIds = new List<String>();
                for(Database.SaveResult saveResult : saveResults){
                    if(!saveResult.isSuccess() || Test.isRunningTest()){
                        List<String> lstErrors = new List<String>();
                        SystemUtility.getAllErrors(saveResult.getErrors(), lstErrors);
                        messages.put(saveResult.getId(), String.join(lstErrors, '\n'));
                        lstContIds.add(saveResult.getId());
                    }
                }
                
                if(!messages.isEmpty()){
                    messages.put('Severity__c', 'High');
                    messages.put('Process__c', 'After lead conversion update Contacts records');
                    messages.put('SF_ID__c', String.join(lstContIds, ','));
                    SystemUtility.errorHandler(null, messages);
                }
            }
        } 
        
        // ==== Update Opportunity  and Insert the list of TDR's under each opportunity ====================================
        if(!listOpportunity.isEmpty()) updateOpportunities(listOpportunity);        
        
        // ==== Updatye bank account details =========================
        if(!listBankAccDet.isEmpty()){
            Database.SaveResult[] saveResults = Database.update(listBankAccDet, false); //update listBankAccDet;
            if(saveResults != null && !saveResults.isEmpty()){
                Map<String, String> messages = new Map<String, String>();
                List<Id> lstBankAccDetIds = new List<Id>();
                for(Database.SaveResult saveResult : saveResults){
                    if(!saveResult.isSuccess() || Test.isRunningTest()){
                        List<String> lstErrors = new List<String>();
                        SystemUtility.getAllErrors(saveResult.getErrors(), lstErrors);
                        messages.put(saveResult.getId(), String.join(lstErrors, '\n'));
                        lstBankAccDetIds.add(saveResult.getId()); }
                }
                
                if(!messages.isEmpty()){
                    messages.put('Severity__c', 'High');
                    messages.put('Process__c', 'After lead conversion update Bank Account Details records');
                    if(!lstBankAccDetIds.isEmpty()) messages.put('SF_ID__c', String.join(lstBankAccDetIds, ','));
                    SystemUtility.errorHandler(null, messages);}
            }
        }
        
        // ==== Update address details =========================
        if(!listAddDetails.isEmpty()){
            Database.SaveResult[] saveResults = Database.update(listAddDetails, false); //update listAddDetails;
            if(saveResults != null && !saveResults.isEmpty()){
                Map<String, String> messages = new Map<String, String>();
                List<String> lstAddDetailIds = new List<String>();
                for(Database.SaveResult saveResult : saveResults){
                    if(!saveResult.isSuccess() || Test.isRunningTest()){
                        List<String> lstErrors = new List<String>();
                        SystemUtility.getAllErrors(saveResult.getErrors(), lstErrors);
                        /*messages.put(saveResult.getId(), String.join(lstErrors, '\n'));
lstAddDetailIds.add(saveResult.getId());*/
                        for(Address_Details__c addDetail : listAddDetails){
                            messages.put(addDetail.Id, String.join(lstErrors, '\n'));
                            lstAddDetailIds.add(addDetail.Id);
                        }
                    }
                }
                
                if(!messages.isEmpty()){
                    messages.put('Severity__c', 'High');
                    messages.put('Process__c', 'After lead conversion update Address Details records');
                    messages.put('SF_ID__c', String.join(lstAddDetailIds, ','));
                    SystemUtility.errorHandler(null, messages);
                }
            }
        }
        
        // ==== Update Merchant Plan details =========================
        if(!listMerchantPlan.isEmpty()){
            Database.SaveResult[] saveResults = Database.update(listMerchantPlan, false); //update listBankAccDet;
            if(saveResults != null && !saveResults.isEmpty()){
                Map<String, String> messages = new Map<String, String>();
                List<Id> lstMerchantPlanIds = new List<Id>();
                for(Database.SaveResult saveResult : saveResults){
                    if(!saveResult.isSuccess() || Test.isRunningTest()){
                        List<String> lstErrors = new List<String>();
                        SystemUtility.getAllErrors(saveResult.getErrors(), lstErrors);
                        messages.put(saveResult.getId(), String.join(lstErrors, '\n'));
                        lstMerchantPlanIds.add(saveResult.getId()); }
                }
                
                if(!messages.isEmpty()){
                    messages.put('Severity__c', 'High');
                    messages.put('Process__c', 'After lead conversion update Merchant Plan records');
                    if(!lstMerchantPlanIds.isEmpty()) messages.put('SF_ID__c', String.join(lstMerchantPlanIds, ','));
                    SystemUtility.errorHandler(null, messages);}
            }
        }
        system.debug('######### lstMerchantStatusDetails '+lstMerchantStatusDetails);
        // ==== Update Merchant status details =========================
        if(!lstMerchantStatusDetails.isEmpty()){
            Database.SaveResult[] saveResults = Database.update(lstMerchantStatusDetails, false); //update listBankAccDet;
            if(saveResults != null && !saveResults.isEmpty()){
                Map<String, String> messages = new Map<String, String>();
                List<Id> lstMerchantStatusDetailIds = new List<Id>();
                for(Database.SaveResult saveResult : saveResults){
                    if(!saveResult.isSuccess() || Test.isRunningTest()){
                        List<String> lstErrors = new List<String>();
                        SystemUtility.getAllErrors(saveResult.getErrors(), lstErrors);
                        messages.put(saveResult.getId(), String.join(lstErrors, '\n'));
                        lstMerchantStatusDetailIds.add(saveResult.getId()); }
                }
                
                if(!messages.isEmpty()){
                    messages.put('Severity__c', 'High');
                    messages.put('Process__c', 'After lead conversion update Merchant Status Details records');
                    if(!lstMerchantStatusDetailIds.isEmpty()) messages.put('SF_ID__c', String.join(lstMerchantStatusDetailIds, ','));
                    SystemUtility.errorHandler(null, messages);}
            }
        }
    }
    
    private static void getGroupDetails(Set<Id> setGroupId, Map<Id, Group> mapGroupRecords){
        mapGroupRecords.putAll([SELECT Id, Name, Type, (SELECT Id, UserOrGroupId, GroupId FROM GroupMembers) FROM Group WHERE Id IN : setGroupId]);
    }
    
    private static void getPanAndLegalSet(Lead newLead, Lead oldLead, Set<String> legalNameSet, Set<String> panNoSet, Set<String> emailSet){
        if(checkLeadToBeConverted(newLead, oldLead)){
            if(String.isNotBlank(newLead.Legal_Name__c)){
                legalNameSet.add(newLead.Legal_Name__c);
            }
            if(String.isNotBlank(newLead.PAN_Number__c)){
                panNoSet.add(newLead.PAN_Number__c);
            }
            if(String.isNotBlank(newLead.Email)){
                emailSet.add(newLead.Email);}
        }
    }
    
    private static void returnAccConMap(Set<String> legalNameSet, Set<String> merchantAccId, Set<String> emailSet, Map<String, String> queriedObjMap){
        System.debug('>>>>>>legalNameSet>>>>>'+legalNameSet);
        System.debug('>>>>>>merchantAccId>>>>>'+merchantAccId);
        System.debug('>>>>>>queriedObjMap>>>>>'+queriedObjMap);
        if(!merchantAccId.isEmpty() && !legalNameSet.isEmpty()){
            String accQueryString = 'SELECT Id, PAN_Number__c,Merchant_Account_Id__c , Legal_Name__c FROM Account WHERE '; 
            if(!legalNameSet.isEmpty()){
                accQueryString += 'Legal_Name__c IN (\'' + String.join(new List<String>(legalNameSet), '\',\'') + '\')';
            }
            
            if(!merchantAccId.isEmpty() && !legalNameSet.isEmpty()){
                accQueryString += ' AND ';}
            
            if(!merchantAccId.isEmpty()){
                accQueryString += 'Merchant_Account_Id__c  IN (\'' + String.join(new List<String>(merchantAccId), '\',\'') + '\')';
            }
            System.debug('accQueryString ******** '+accQueryString);
            
            for(Sobject each : Database.query(accQueryString)){
                System.debug('each !!!!!!!! '+each);
                String theLegalName = String.valueOf(each.get('Legal_Name__c'));
                
                if(String.isNotBlank(theLegalName)){
                    queriedObjMap.put(theLegalName, String.valueOf(each.get('Id')));}
                
                String thePanNo = String.valueOf(each.get('Merchant_Account_Id__c'));
                
                if(String.isNotBlank(thePanNo)){
                    queriedObjMap.put(thePanNo, String.valueOf(each.get('Id')));
                }
            }
        }
    }
    
    private static void returnLeadConvertList(Lead newLead, Lead oldLead, List<Database.LeadConvert> leadsToConvert, Map<String, String> queriedObjMap, Map<Id, Group> mapGroupRecords, String setCId, String setAId){
        //Aggregatot logic added
        if((Trigger.isInsert && 'Partner'.equals(newLead.Lead_Type__c) && !newLead.isConverted) || 
           (newLead.Lead_Type__c == 'ProductAccount' && checkLeadToBeConverted(newLead, oldLead)) ||
           (newLead.Lead_Type__c == 'Merchant' && checkLeadToBeConverted(newLead, oldLead)) 
           || (newLead.Lead_Type__c == 'Aggregator' && checkLeadToBeConverted(newLead, oldLead))
           || (newLead.Lead_Type__c == 'aggregator' && checkLeadToBeConverted(newLead, oldLead))
           || (newLead.Lead_Type__c == 'Seller' && checkLeadToBeConverted(newLead, oldLead))
           || (newLead.Lead_Type__c == 'seller' && checkLeadToBeConverted(newLead, oldLead))
           || (newLead.Lead_Type__c == 'Child Aggregator' && checkLeadToBeConverted(newLead, oldLead))
           || (newLead.Lead_Type__c == 'child_aggregator' && checkLeadToBeConverted(newLead, oldLead))){
               Database.LeadConvert lc = new Database.LeadConvert();
               system.debug('inside update' +newLead.Lead_Type__c);
               system.debug('checkLeadToBeConverted' +checkLeadToBeConverted(newLead, oldLead));
               
               for(String each : fieldsToCkeck){                
                   String theFieldValue = String.ValueOf(newLead.get(each)); 
                   
                   if(String.isNotBlank(theFieldValue) && queriedObjMap.containsKey(theFieldValue)){
                       String accOrConId = queriedObjMap.get(theFieldValue);
                       if(String.isNotBlank(accOrConId)){ 
                           if(accOrConId.startsWith('001')) lc.setAccountId(accOrConId);
                           if(accOrConId.startsWith('003')) lc.setContactId(accOrConId);
                       } 
                   }
               }            
               if(String.isNotBlank(setCId) && setCId != null && String.isNotBlank(setAId) && setAId != null){
                   lc.setAccountId(setAId);
                   lc.setContactId(setCId);
               }
               if(String.isNotBlank(setAId) && setAId != null){
                   // lc.setAccountId(setAId);
               }
               
               lc.setLeadId(newLead.Id);
               if(newLead.Sub_Status__c != 'Banned'){  
                   lc.setOpportunityName(newLead.Company + (newLead.Merchant_Id__c != null ? ' - ' + newLead.Merchant_Id__c : ''));
               }else{
                   lc.setDoNotCreateOpportunity(true);
               }
               
               lc.setConvertedStatus('Qualified'); 
               
               if(String.valueof(newLead.OwnerId).startsWith('00G') && !mapGroupRecords.isEmpty() && mapGroupRecords.containsKey(newLead.OwnerId) && !mapGroupRecords.get(newLead.OwnerId).GroupMembers.isEmpty())
               {
                   Integer userIndex = Math.mod(Integer.valueOf(newLead.Round_Robin_Identifier__c), mapGroupRecords.get(newLead.OwnerId).GroupMembers.Size());                
                   lc.setOwnerId(mapGroupRecords.get(newLead.OwnerId).GroupMembers.get(userIndex).UserOrGroupId);              
               } 
               if(String.isNotBlank(newLead.Owner_Assignment_Header__c) && newLead.Owner_Assignment_Header__c.startsWith('Other')){
                   if(!String.valueof(newLead.OwnerId).startsWith('00G') && String.valueof(newLead.OwnerId) == System.Label.IntegrationUserId && !mapGroupRecords.isEmpty() && mapGroupRecords.containsKey(Id.ValueOf(newLead.Owner_Assignment_Header__c.subStringAfter('Other-'))) && !mapGroupRecords.get(Id.ValueOf(newLead.Owner_Assignment_Header__c.subStringAfter('Other-'))).GroupMembers.isEmpty() && String.isBlank(newLead.Partner__c) && ('Merchant'.equals(newLead.Lead_Type__c) || 'seller'.equals(newLead.Lead_Type__c)) && newLead.Owner_Assignment_Header__c.startsWith('Other'))
                   {
                       Integer userIndex = Math.mod(Integer.valueOf(newLead.Round_Robin_Identifier__c), mapGroupRecords.get(Id.ValueOf(newLead.Owner_Assignment_Header__c.subStringAfter('Other-'))).GroupMembers.Size());                
                       lc.setOwnerId(mapGroupRecords.get(Id.ValueOf(newLead.Owner_Assignment_Header__c.subStringAfter('Other-'))).GroupMembers.get(userIndex).UserOrGroupId);              
                   }
               }else if(String.isNotBlank(newLead.Owner_Assignment_Header__c) && newLead.Owner_Assignment_Header__c.startsWith('Sole_Indi')){
                   if(!String.valueof(newLead.OwnerId).startsWith('00G') && String.valueof(newLead.OwnerId) == System.Label.IntegrationUserId && !mapGroupRecords.isEmpty() && mapGroupRecords.containsKey(Id.ValueOf(newLead.Owner_Assignment_Header__c.subStringAfter('Sole_Indi-'))) && !mapGroupRecords.get(Id.ValueOf(newLead.Owner_Assignment_Header__c.subStringAfter('Sole_Indi-'))).GroupMembers.isEmpty() && String.isBlank(newLead.Partner__c) && ('Merchant'.equals(newLead.Lead_Type__c) || 'seller'.equals(newLead.Lead_Type__c)) && newLead.Owner_Assignment_Header__c.startsWith('Sole_Indi'))
                   {
                       Integer userIndex = Math.mod(Integer.valueOf(newLead.Round_Robin_Identifier__c), mapGroupRecords.get(Id.ValueOf(newLead.Owner_Assignment_Header__c.subStringAfter('Sole_Indi-'))).GroupMembers.Size());                
                       lc.setOwnerId(mapGroupRecords.get(Id.ValueOf(newLead.Owner_Assignment_Header__c.subStringAfter('Sole_Indi-'))).GroupMembers.get(userIndex).UserOrGroupId);              
                   }
               }
               
               system.debug('converted status of lead=='+lc.getConvertedStatus());
               leadsToConvert.add(lc);
           }
    }
    
    // ======= Check the lead for conversion ======================
    private static Boolean checkLeadToBeConverted(Lead newLead, Lead OldLead){
        //========= Adding Business Entity check for Onboarding Revamp-JIRA-SFPI-997============
        return  (!newLead.isConverted && newLead.Status != 'Closed' && newLead.Sub_Status__c != 'Banned'      
                 && ((Trigger.isUpdate        
                      && ((newLead.Bank_Verification_Status__c != OldLead.Bank_Verification_Status__c && newLead.Bank_Verification_Status__c == 'Success') 
                          || (newLead.Skip_Verification__c && newLead.Skip_Verification__c != OldLead.Skip_Verification__c)
                          || (String.isNotBlank(newLead.Business_Entity__c) && String.isNotBlank(newLead.Legal_Name__c) && String.isNotBlank(newLead.PAN_Number__c) 
                              && (newLead.Business_Entity__c != OldLead.Business_Entity__c || newLead.Legal_Name__c != OldLead.Legal_Name__c || newLead.PAN_Number__c != OldLead.PAN_Number__c))))   
                     || (Trigger.isInsert && String.isNotBlank(newLead.Business_Entity__c) && String.isNotBlank(newLead.Legal_Name__c) && String.isNotBlank(newLead.PAN_Number__c))) /*&& (newLead.Online_Lead__c == TRUE && newLead.Offline_Lead__c == FALSE)*/
                );
    }
    
    // =========== Convert the list of lead ======================================
    private static void conversionUtil(List<Database.LeadConvert> leadsToConvert, 
                                       List<Contact> listContact, Map<Id, Id> mapLeadIdVsAccId, 
                                       Map<Id, Id> mapLeadIdVsOppId, Map<Id, Lead> triggerNewMap) {
                                           /*******If account is already there for for an opportunity or product and for same account 
if we want another product or an opp in this case below if else condition written where I am checking if acc is already there
then do not create duplicate account just create an opp and tagged to same account
added by rohit gupta********/
                                           List<Database.LeadConvertResult> listLeadConvertResult;
                                           SYstem.debug('merchantAccId::1171:::'+merchantAccId);
                                           List<Account> existingAccounts = [SELECT Id FROM Account WHERE Merchant_Account_Id__c = :merchantAccId AND Merchant_Account_Id__c !=NULL];
                                           System.debug('existingAccounts::::::'+existingAccounts);
                                           if (existingAccounts.isEmpty()) {
                                               Database.LeadConvert lc = new Database.LeadConvert();
                                               listLeadConvertResult = Database.convertLead(leadsToConvert, false);
                                           }
                                           else{
                                               List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
                                               for (Database.LeadConvert leadConvert : leadsToConvert) {
                                                   leadConvert.setAccountId(existingAccounts[0].Id);
                                                   leadConverts.add(leadConvert);
                                               }
                                               // Query for an existing contact with the same email address and account ID
                                               if(!existingAccounts.isEmpty() && existingAccounts !=NULL){
                                                   Contact existingContact = [SELECT Id FROM Contact WHERE  AccountId = :existingAccounts[0].Id LIMIT 1];
                                                   if(!existingAccounts.isEmpty()) {
                                                       // If a matching contact is found, associate the lead with the existing contact
                                                       leadsToConvert.get(0).setContactId(existingContact.Id);
                                                   } 
                                               }
                                               
                                               listLeadConvertResult = Database.convertLead(leadConverts, false);
                                           }
                                           // System.debug(listLeadConvertResult.size()+'######## listLeadConvertResult ^^^^^^^ '+listLeadConvertResult);
                                           
                                           Id ProdAcc ;
                                           Id LeadId ;
                                           if(listLeadConvertResult != null && !listLeadConvertResult.isEmpty()){
                                               Map<String, String> messages = new Map<String, String>();
                                               List<String> lstLeadIds = new List<String>();
                                               List<Account> accLst = new List<Account>();
                                               AccountContactRelation acr = new AccountContactRelation();
                                               
                                               for(Database.LeadConvertResult LeadConvertResultObj : listLeadConvertResult){
                                                   if(LeadConvertResultObj.isSuccess()){
                                                       mapLeadIdVsAccId.put(LeadConvertResultObj.getLeadId(), LeadConvertResultObj.getAccountId());
                                                       ProdAcc = LeadConvertResultObj.getAccountId(); 
                                                       LeadId = LeadConvertResultObj.getLeadId();
                                                       if(String.isNotBlank(LeadConvertResultObj.getOpportunityId()))
                                                       {
                                                           mapLeadIdVsOppId.put(LeadConvertResultObj.getLeadId(), LeadConvertResultObj.getOpportunityId());
                                                       }
                                                   }
                                                   else{
                                                       List<String> lstErrors = new List<String>();
                                                       SystemUtility.getAllErrors(LeadConvertResultObj.getErrors(), lstErrors);
                                                       messages.put(LeadConvertResultObj.getLeadId(), String.join(lstErrors, '\n'));
                                                       if(!String.valueof(triggerNewMap.get(LeadConvertResultObj.getLeadId()).OwnerId).startsWith('00G')) messages.put('OwnerId', triggerNewMap.get(LeadConvertResultObj.getLeadId()).OwnerId);
                                                       lstLeadIds.add(LeadConvertResultObj.getLeadId());
                                                   }
                                               }
                                               
                                               if(!messages.isEmpty()){
                                                   messages.put('Severity__c', 'High');
                                                   messages.put('Process__c', 'Lead Conversion');
                                                   messages.put('SF_ID__c', String.join(lstLeadIds, ','));
                                                   SystemUtility.errorHandler(null, messages);
                                                   System.debug('######### message '+messages);
                                               }
                                           }
                                       }
    
    
    private static void getListOptyOffline(List<Lead> lstConvertedLead, List<Opportunity> lstOpty){
        for(lead leadObj : lstConvertedLead){
            getListOpportunity(leadObj, lstOpty, leadObj.ConvertedOpportunityId);            
        }
    }
    
    private static void updateOppPlan(List<Lead> lstLead, List<Opportunity> listOpportunity, Map<Id, Id> mapLeadIdVsOppId){//
        for(lead leadObj : lstLead){
            if(mapLeadIdVsOppId != null && mapLeadIdVsOppId.containsKey(leadObj.Id) && mapLeadIdVsOppId.get(leadObj.Id) != null){
                getListOpportunity(leadObj, listOpportunity, mapLeadIdVsOppId.get(leadObj.Id)); 
            }
        } 
    }
    
    private static void getListOpportunity(Lead leadObj, List<Opportunity> listOpportunity, Id oppId){
        //Aggregator logic added
        if(String.isNotBlank(leadObj.Lead_Type__c) && leadTypeList.contains(leadObj.Lead_Type__c)){// == 'Merchant' || leadObj.Lead_Type__c == 'Aggregator' || leadObj.Lead_Type__c=='Seller')){
            Opportunity oppObj = new Opportunity(Id = oppId);
            //oppObj.Id = oppId;
            if(leadObj.Lead_Type__c == 'child_aggregator')
                oppObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Child Aggregator').getRecordTypeId();
            else
                oppObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(leadObj.Lead_Type__c).getRecordTypeId();
            oppObj.StageName = 'MAF';
            oppObj.CloseDate = Date.Today().addMonths(1);
            if(String.isNotBlank(leadObj.Partner__c)) oppObj.Partner__c = leadObj.Partner__c;
            if(String.isNotBlank(leadObj.Aggregator__c)) oppObj.Aggregator__c = leadObj.Aggregator__c;
            if(String.isNotBlank(leadObj.Aggregator_UUID__c)) oppObj.Aggregator_UUID__c = leadObj.Aggregator_UUID__c;
            if(String.isNotBlank(leadObj.Merchant_Type__c)) {
                oppObj.Merchant_Type__c = leadObj.Merchant_Type__c;
                oppObj.Lead_Type__c = leadObj.Lead_Type__c;
            }
            listOpportunity.add(oppObj);
        }
        
        // ======= Added by Uma shankar at Dec.20, 2018 =====================
        if(String.isNotBlank(leadObj.Lead_Type__c) && (leadObj.Lead_Type__c == 'Partner')){
            Opportunity oppObj = new Opportunity();
            oppObj.Id = oppId;
            oppObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Reseller').getRecordTypeId();
            oppObj.StageName = 'Onboarding';
            oppObj.CloseDate = Date.Today().addMonths(1);
            listOpportunity.add(oppObj);
        }
        /***** Not using this product anymore=======
//Prashant
if(String.isNotBlank(leadObj.Lead_Type__c) && (leadObj.Lead_Type__c == 'Wibmo')){
system.debug('Inside Type logic');
Opportunity oppObj = new Opportunity();
oppObj.Id = oppId;
oppObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Wibmo').getRecordTypeId();
oppObj.StageName = 'Stage 0 - Yet to start';
oppObj.CloseDate = Date.Today().addMonths(1);
listOpportunity.add(oppObj);
}
//Prashant
*******/
    }
    
    private static void getRelListOfLead(Set<Id> setConvertedLeadId, Map<Id, List<Contact>> mapLeadIdVsListCont, 
                                         Map<Id, List<Bank_Account_Detail__c>> mapLeadIdVsListBankAccDet,
                                         Map<Id, List<Address_Details__c>> mapLeadIdVsListAddress,
                                         Map<Id, List<Merchant_Plan__c>> mapLeadIdVsListMerchantPlan,
                                         Map<Id, List<Merchant_Status_Details__c>> mapLeadIdVsListMerchantStatusDetail)
    {
        for(Lead leadObj : [SELECT Id, 
                            (SELECT ID, AccountId FROM Contacts__r), 
                            (SELECT Id, Opportunity__c FROM Bank_Account_Details__r),
                            (SELECT ID, Account__c,Opportunity__c FROM Address_Details__r),
                            (SELECT ID, Opportunity__c FROM Merchant_Plan__r),
                            (SELECT ID,Opportunity__c FROM Merchant_Status_Details__r)
                            FROM Lead 
                            WHERE Id IN : setConvertedLeadId])
        {
            if(!leadObj.Contacts__r.isEmpty()){
                mapLeadIdVsListCont.put(leadObj.Id, leadObj.Contacts__r);
            }
            if(!leadObj.Bank_Account_Details__r.isEmpty()){
                mapLeadIdVsListBankAccDet.put(leadObj.Id, leadObj.Bank_Account_Details__r);
            }           
            if(!leadObj.Address_Details__r.isEmpty()){
                mapLeadIdVsListAddress.put(leadObj.Id, leadObj.Address_Details__r);
            }
            //update for CS
            if(!leadObj.Merchant_Plan__r.isEmpty()){
                mapLeadIdVsListMerchantPlan.put(leadObj.Id, leadObj.Merchant_Plan__r);
            }
            
            if(!leadObj.Merchant_Status_Details__r.isEmpty()){
                mapLeadIdVsListMerchantStatusDetail.put(leadObj.Id, leadObj.Merchant_Status_Details__r);
            }
        }
    }
    
    private static void createContactRecords(List<Lead> lstConvertedLead, List<Contact> listContact, Map<Id, List<Contact>> mapLeadIdVsListCont){
        for(Lead leadObj : lstConvertedLead){            
            if(mapLeadIdVsListCont.containsKey(leadObj.Id)){
                //List<Contact> contactsToSave = verifyContactData(leadObj.Id, mapLeadIdVsListCont.get(leadObj.Id));
                for(Contact conObj : mapLeadIdVsListCont.get(leadObj.Id)){
                    //for(Contact conObj : contactsToSave){
                    conObj.AccountId = leadObj.ConvertedAccountId;
                    listContact.add(conObj);
                    //}
                }
            }}}
    /*List<Contact> ContactList = [SELECT Id, Name, Identifier__c, Email FROM Contact];
for(Lead leadObj : lstConvertedLead){
for(Contact contactObj : ContactList){
if(leadObj.Email == contactObj.Email){
Contact con = new Contact(id = contactObj.Id);
listContact.add(con);
system.debug('-->> 598 '+listContact);
}
}
}
}*/
    
    /*private static List<Contact> verifyContactData(Id LeadId, List<Contact> Contacts){
List<Contact> contactsToSave = new List<Contact>();
List<Contact> ContactList = [SELECT Id, Name, Identifier__c, Email FROM Contact];*/
    /*Map<String, Id> mapContactIdentifier = new Map<String, Id>();
for(Contact con : ContactList){
mapContactIdentifier.put(con.Identifier__c, con.Id);
}
for(Contact contact : contacts){
if(contact.Identifier__c != mapContactIdentifier.get(contact.Identifier__c)){
contactsToSave.add(contact);
}
}*/
    /*Map<String, Id> mapContactIdentifier = new Map<String, Id>();
for(Contact con : ContactList){
mapContactIdentifier.put(con.Email, con.Id);
system.debug('-->> 608 '+mapContactIdentifier);
}
for(Contact contact : contacts){
for(String str : mapContactIdentifier.keySet()){
if(contact.Email == str){
Contact con = new Contact(id=mapContactIdentifier.get(str));
contactsToSave.add(con);
}
else{
contactsToSave.add(contact);
}
}
}
return contactsToSave;
}*/
    
    private static void createBankAccDetailsRecords(List<Lead> lstConvertedLead, List<Bank_Account_Detail__c> listBankAccDet, Map<Id, List<Bank_Account_Detail__c>> mapLeadIdVsListBankAccDet){
        BankDetailTriggerHandler.setBankDeatilId = new Set<Id>();
        for(Lead leadObj : lstConvertedLead){
            if(mapLeadIdVsListBankAccDet.containsKey(leadObj.Id)){                
                for(Bank_Account_Detail__c bankAccDetObj : mapLeadIdVsListBankAccDet.get(leadObj.Id)){
                    if(String.isNotBlank(leadObj.ConvertedOpportunityId)){
                        bankAccDetObj.Opportunity__c = leadObj.ConvertedOpportunityId ;
                        listBankAccDet.add(bankAccDetObj);
                        BankDetailTriggerHandler.setBankDeatilId.add(bankAccDetObj.Id);
                    }
                }                
            }            
        }
    }
    
    private static void createAddressDeatilRecords(List<Lead> lstConvertedLead, List<Address_Details__c> listAddDetails, Map<Id, List<Address_Details__c>> mapLeadIdVsListAddress){
        for(Lead leadObj : lstConvertedLead){
            if(mapLeadIdVsListAddress.containsKey(leadObj.Id)){
                for(Address_Details__c addDeatilObj : mapLeadIdVsListAddress.get(leadObj.Id)){
                    addDeatilObj.Account__c = leadObj.ConvertedAccountId;
                    addDeatilObj.Opportunity__c = leadObj.ConvertedOpportunityId;
                    listAddDetails.add(addDeatilObj);
                }
            }
        }
    }
    
    //update for CS
    //listMerchantPlan, mapLeadIdVsListMerchantPlan
    
    private static void createMerchantPlanRecords(List<Lead> lstConvertedLead, List<Merchant_Plan__c> listMerchantPlan, Map<Id, List<Merchant_Plan__c>> mapLeadIdVsListMerchantPlan){
        for(Lead leadObj : lstConvertedLead){
            if(mapLeadIdVsListMerchantPlan.containsKey(leadObj.Id)){
                for(Merchant_Plan__c merchantPlanObj : mapLeadIdVsListMerchantPlan.get(leadObj.Id)){
                    merchantPlanObj.Opportunity__c = leadObj.ConvertedOpportunityId;
                    listMerchantPlan.add(merchantPlanObj);
                }
            }
        }
    }
    
    private static void createMerchantStatusDetailRecords(List<Lead> lstConvertedLead, List<Merchant_Status_Details__c> lstMerchantStatusDetails, Map<Id, List<Merchant_Status_Details__c>> mapLeadIdVsListMerchantStatusDetail){
        for(Lead leadObj : lstConvertedLead){
            if(mapLeadIdVsListMerchantStatusDetail.containsKey(leadObj.Id)){
                for(Merchant_Status_Details__c merchantStatusDetailObj : mapLeadIdVsListMerchantStatusDetail.get(leadObj.Id)){
                    merchantStatusDetailObj.Opportunity__c = leadObj.ConvertedOpportunityId;
                    lstMerchantStatusDetails.add(merchantStatusDetailObj);
                }
            }
        }
    }
    
    private static void changeLeadStatusBI(List<Lead> newList){        
        Set<String> setBusiCateOther = new Set<String>();
        Set<String> setSubCateOther = new Set<String>();
        
        Map<String, Business_Category__c> mapBCNameVsBCObj = new Map<String, Business_Category__c>();
        Map<String, Sub_Category__c> mapSCNameVsSCObj = new Map<String, Sub_Category__c>();
        
        for(Lead each : newList){            
            if(String.isNotBlank(each.Business_Category_Other__c)){setBusiCateOther.add(each.Business_Category_Other__c);}
            if(String.isNotBlank(each.Sub_Category_Other__c)){setSubCateOther.add(each.Sub_Category_Other__c);}
        } 
        
        if(!setBusiCateOther.isEmpty()) getBusinessCategory(setBusiCateOther, mapBCNameVsBCObj);
        
        if(!setSubCateOther.isEmpty()) getSubCategory(setSubCateOther, mapSCNameVsSCObj);
        
        for(Lead each : newList){
            changeLeadStatus(each, mapBCNameVsBCObj, mapSCNameVsSCObj);           
        }
    }
    
    private static void changeLeadStatusBU(List<Lead> newList, Map<Id, Lead> oldMap){        
        Set<String> setBusiCateOther = new Set<String>();
        Set<String> setSubCateOther = new Set<String>();
        
        Map<String, Business_Category__c> mapBCNameVsBCObj = new Map<String, Business_Category__c>();
        Map<String, Sub_Category__c> mapSCNameVsSCObj = new Map<String, Sub_Category__c>();
        
        Set<Id> setBusinessCategory = new Set<Id>();        
        List<Lead> lstLead = new List<Lead>();
        
        for(Lead each : newList){
            Lead oldEach = oldMap.get(each.Id);
            
            if(String.isNotBlank(each.Business_Category_Other__c) 
               && each.Business_Category_Other__c != oldMap.get(each.Id).Business_Category_Other__c){
                   setBusiCateOther.add(each.Business_Category_Other__c);
               }
            if(String.isNotBlank(each.Sub_Category_Other__c) 
               && each.Sub_Category_Other__c != oldMap.get(each.Id).Sub_Category_Other__c){
                   setSubCateOther.add(each.Sub_Category_Other__c);
               }
            
            // Put Name field value in "Signup Name" field
            if(String.isNotBlank(each.FirstName)){
                each.Signup_First_Name__c = each.FirstName;
            }
            if(String.isNotBlank(each.LastName)){	
                each.Signup_Last_Name__c = each.LastName;	
            }
            
            // Put Email field value in "Signup Email" field
            if(each.Email != oldEach.Email) each.Signup_Email__c = each.Email;
            
            // Put Phone field value in "Signup Phone" field
            if(each.MobilePhone != oldEach.MobilePhone) each.Signup_Phone__c = each.MobilePhone;
            
            //update "Not Responding Date" field
            if(each.Sub_Status__c != oldEach.Sub_Status__c && each.Sub_Status__c == 'Not Responding') each.Lead_Not_Responding_Date__c = system.today();
            
            // Update company name based on pan number and legal name/ update status as junk if lead type is buyer
            updateLeadCompanyAndStatuses(each, oldEach);            
            
            // ======== update LOB status and Risk Auto Approved fields value ============
            if(String.isNotEmpty(each.Transaction_Facility_Required__c)
               && each.Delivery_Duration__c != null
               && each.NDX_Score__c != null
               && each.BusinessCategory__c != null){
                   lstLead.add(each);
                   setBusinessCategory.add(each.BusinessCategory__c);
               }
            
            // =========== set the lead status as "Nurturing" and sub status as "Contacted" ============== 
            if((each.PAN_Holder_Name__c != oldEach.PAN_Holder_Name__c || each.PAN_Number__c != oldEach.PAN_Number__c || each.Legal_Name__c != oldEach.Legal_Name__c)
               && String.isNotBlank(each.PAN_Holder_Name__c) && String.isNotBlank(each.PAN_Number__c) && String.isNotBlank(each.Legal_Name__c)){
                   setLeadStatus(each);
               }               
        }
        
        if(!setBusiCateOther.isEmpty()) getBusinessCategory(setBusiCateOther, mapBCNameVsBCObj);
        
        if(!setSubCateOther.isEmpty()) getSubCategory(setSubCateOther, mapSCNameVsSCObj);     
        
        for(Lead each : newList){           
            changeLeadStatus(each, mapBCNameVsBCObj, mapSCNameVsSCObj);
        }
        
        if(!lstLead.isEmpty()) updateLOBAndRiskAutoApproved(lstLead, setBusinessCategory);
    }
    
    private static void changeLeadStatus(Lead each, Map<String, Business_Category__c> mapBCNameVsBCObj, Map<String, Sub_Category__c> mapSCNameVsSCObj){
        if(String.isNotBlank(each.Business_Category_Other__c) 
           && !mapBCNameVsBCObj.isEmpty() 
           && mapBCNameVsBCObj.containsKey(each.Business_Category_Other__c))
        {
            each.Status = 'Closed';
            each.Sub_Status__c = 'Banned';
        }
        if(String.isNotBlank(each.Sub_Category_Other__c) 
           && !mapSCNameVsSCObj.isEmpty() 
           && mapSCNameVsSCObj.containsKey(each.Sub_Category_Other__c))
        {
            each.Status = 'Closed';
            each.Sub_Status__c = 'Banned';
        }
    }
    
    private static void getBusinessCategory(Set<String> setBusiCateOther, Map<String, Business_Category__c> mapBCNameVsBCObj){
        for(Business_Category__c busiCateObj : [SELECT Id, Name, Banned__c FROM Business_Category__c WHERE Name IN : setBusiCateOther AND Banned__c =: true]){
            mapBCNameVsBCObj.put(busiCateObj.Name, busiCateObj);
        }
    }   
    
    private static void getSubCategory(Set<String> setSubCateOther, Map<String, Sub_Category__c> mapSCNameVsSCObj){
        for(Sub_Category__c subCateObj : [SELECT Id, Name, Banned__c FROM Sub_Category__c WHERE Name IN : setSubCateOther AND Banned__c =: true]){
            mapSCNameVsSCObj.put(subCateObj.Name, subCateObj);
        }
    }
    
    // Update company name based on pan number and legal name/ update status as junk if lead type is buyer
    public static void updateLeadCompanyAndStatuses(Lead newData, Lead oldData){        
        if(String.isNotBlank(newData.Legal_Name__c) && String.isNotBlank(newData.PAN_Number__c) &&
           (oldData == null || newData.Legal_Name__c != oldData.Legal_Name__c || newData.PAN_Number__c != oldData.PAN_Number__c))
        {
            newData.Company = newData.Legal_Name__c + '-' + newData.PAN_Number__c;
        }
        if(String.isNotBlank(newData.Lead_Type__c) && newData.Lead_Type__c == 'Buyer' && (oldData == null || newData.Lead_Type__c != oldData.Lead_Type__c )){
            newData.Status = 'Closed';
            newData.Sub_Status__c = 'Junk';
        }
    }
    
    public static void updateLOBAndRiskAutoApproved(List<Lead> listLead, Set<Id> setBusinessCategory){
        Map<Id, Business_Category__c> mapBusinessCategory = new Map<Id, Business_Category__c>();
        getBusinessCategoryRecord(setBusinessCategory, mapBusinessCategory);
        
        for(Lead eachLead : listLead){
            if(mapBusinessCategory.get(eachLead.BusinessCategory__c).Doable__c
               && eachLead.Transaction_Facility_Required__c == 'Domestic'
               && eachLead.Delivery_Duration__c > 0
               && eachLead.NDX_Score__c > 0
               && eachLead.NDX_Score__c <= 140000)
            {
                eachLead.Risk_Auto_Approved__c = true;
                eachLead.LOB_Status__c = 'Approved';
            }
            else{
                eachLead.Risk_Auto_Approved__c = false;
                eachLead.LOB_Status__c = 'Pending';
            }
        }
    }
    
    // Get the Business Category Records
    private static void getBusinessCategoryRecord(Set<Id> setBusinessCategory, Map<Id, Business_Category__c> mapBusinessCategory){
        mapBusinessCategory.putAll([SELECT Id, Doable__c From Business_Category__c
                                    WHERE Id IN : setBusinessCategory]);
    }
    
    
    public static void leadConversionValidation(List<Lead> triggerNew){ 
        // Added for SFPI-568 for avoiding validation   
        Boolean passleadvalidation = True;  
        List<String> lstStringofProfileskip = Label.Onboarding_profile_validation.split(';');   
        Set<String> setofProfiletoUpdate = new Set<String>();   
        for(String objstr: lstStringofProfileskip){ 
            setofProfiletoUpdate.add(objstr);   
        }   
        
        List<User> lstUser = [SELECT Id, Profile.Name FROM User WHERE Id=:Userinfo.getUserId()];    
        
        if(setofProfiletoUpdate != null && setofProfiletoUpdate.size() > 0 && String.isNotBlank(lstUser[0].Profile.Name) &&     
           setofProfiletoUpdate.contains(lstUser[0].Profile.Name)){ 
               passleadvalidation = false;  
           }    
        for(Lead leadObj : triggerNew){ 
            
            if(leadObj.isConverted && !'Partner'.equals(leadObj.Lead_Type__c) &&    
               (String.isBlank(leadObj.Merchant_Type__c))){ 
                   String strErrorMsg = 'Please correct the below error messages :' + '<br/>';  
                   boolean isError = false; 
                   //========= Commenting Bank Verification Status check for Onboarding Revamp-JIRA-SFPI-997============
                   /*if(leadObj.Bank_Verification_Status__c != 'Success' && !leadObj.Skip_Verification__c){   
strErrorMsg = strErrorMsg + 'Please verify Bank Account of the merchant before lead conversion.' + '<br/>';  
isError = true;  
} */                   
                   /* if(String.isBlank(leadObj.GST_Number__c) && (leadObj.ProductLabel__c == 'PayUbiz' || leadObj.ProductLabel__c == 'CitrusPay')){    
strErrorMsg = strErrorMsg + 'Please enter GSTIN of the merchant.' + '<br/>';    
isError = true; 
}       
//Aggregator logic added    
if(leadObj.Merchant_Id__c == null && (leadObj.Lead_Type__c == 'Merchant' || leadObj.Lead_Type__c == 'Aggregator' ) && (leadObj.ProductLabel__c == 'PayUbiz' || leadObj.ProductLabel__c == 'CitrusPay')){    
strErrorMsg = strErrorMsg + 'TEST MID is not captured against the lead.' + '<br/>'; 
isError = true; 
}                   
*/  
                   if(String.isBlank(leadObj.PAN_Number__c)){   
                       strErrorMsg = strErrorMsg + 'Please enter PAN Card Number.' + '<br/>';   
                       isError = true;  
                   }            
                   //Aggregator logic added 
                   if(leadObj.Prod_Merchant_Id__c == null && (leadObj.Lead_Type__c == 'Merchant' || leadObj.Lead_Type__c == 'Aggregator')   
                      && (leadObj.ProductLabel__c == 'PayUMoney' || leadObj.ProductLabel__c == 'PayUbiz' || leadObj.ProductLabel__c == 'PayUnow')){ 
                          strErrorMsg = strErrorMsg + 'MID is not captured against the lead.' + '<br/>';    
                          isError = true;   
                      }                 
                   //Aggregator logic added 
                   if(leadObj.Product__c == null && (leadObj.Lead_Type__c == 'Merchant' || leadObj.Lead_Type__c == 'Aggregator')){  
                       strErrorMsg = strErrorMsg + 'Please select Product for the lead.' + '<br/>'; 
                       isError = true;  
                   }    
                   
                   if(leadObj.Business_Entity__c == null){  
                       strErrorMsg = strErrorMsg + 'Please enter Business Entity of the merchant.' + '<br/>';   
                       isError = true;  
                   }    
                   
                   if(String.isBlank(leadObj.Legal_Name__c) && (leadObj.ProductLabel__c == 'PayUnow' || leadObj.ProductLabel__c == 'PayUmoney' || leadObj.ProductLabel__c == 'PayUbiz')){   
                       strErrorMsg = strErrorMsg + 'Please enter Legal Name of the merchant.' + '<br/>'; 
                       isError = true;   
                   } 
                   
                   if(String.isBlank(leadObj.PAN_Holder_Name__c)){ 
                       strErrorMsg = strErrorMsg + 'Please enter PAN Card holder name.' + '<br/>';  
                       isError = true;  
                   }    
                   //========= Commenting Bank Verification Status check for Onboarding Revamp-JIRA-SFPI-997============
                   // ========== validation for off-line lead ========================  
                   /*if(!leadObj.Online_Lead__c){ 

//Aggregator logic added 
if(leadObj.BusinessCategory__c == null  && (leadObj.Lead_Type__c == 'Merchant' || leadObj.Lead_Type__c == 'Aggregator') && !(leadObj.ProductLabel__c == 'PayUnow' || ((leadObj.ProductLabel__c == 'PayUmoney' || leadObj.ProductLabel__c == 'PayUbiz') && leadObj.Integration_Type__c == 'Tools'))){     
strErrorMsg = strErrorMsg + 'Please enter Business Category of the merchant.' + '<br/>';    
isError = true; 
}   
//Aggregator logic added 
if((leadObj.Lead_Type__c == 'Merchant' || leadObj.Lead_Type__c == 'Aggregator') && (leadObj.Delivery_Duration__c == null || leadObj.Monthly_Expected_Sale__c == null) && !(leadObj.ProductLabel__c == 'PayUnow' || ((leadObj.ProductLabel__c == 'PayUmoney' || leadObj.ProductLabel__c == 'PayUbiz') && leadObj.Integration_Type__c == 'Tools'))){   
strErrorMsg = strErrorMsg + 'Please enter Delivery Duration and Monthly Expected Sale of the merchant.' + '<br/>';  
isError = true; 
}                   

//Aggregator logic added 
if(leadObj.Sub_Category__c == null && (leadObj.Lead_Type__c == 'Merchant' || leadObj.Lead_Type__c == 'Aggregator') && !(leadObj.ProductLabel__c == 'PayUnow' || ((leadObj.ProductLabel__c == 'PayUmoney' || leadObj.ProductLabel__c == 'PayUbiz') && leadObj.Integration_Type__c == 'Tools'))){  
strErrorMsg = strErrorMsg + 'Please enter Sub Category of the merchant.' + '<br/>';  
isError = true;  
} 
} */
                   //===============================    
                   System.debug('strErrorMsg ********* '+strErrorMsg);  
                   if(isError == true){ 
                       leadObj.addError(strErrorMsg);//, false);    
                   }    
               }else if((leadObj.isConverted && !'Partner'.equals(leadObj.Lead_Type__c) && 'seller'.equals(leadObj.Lead_Type__c) && 'seller'.equals(leadObj.Merchant_Type__c))  || String.isNotBlank(leadObj.Migrated_From__c)){    
                   String strErrorMsg = 'Please correct the below error messages :' + '<br/>'; 
                   boolean isError = false;    
                   //========= Commenting Bank Verification Status check for Onboarding Revamp-JIRA-SFPI-997============
                   /*if(leadObj.Bank_Verification_Status__c != 'Success' && !leadObj.Skip_Verification__c){  
strErrorMsg = strErrorMsg + 'Please verify Bank Account of the seller before lead conversion.' + '<br/>';   
isError = true; 
} */  
                   /*  
if(leadObj.PAN_Verification_Status__c != 'Success'){    
strErrorMsg = strErrorMsg + 'Please verify Pan verification of the seller before lead conversion.' + '<br/>';   
isError = true; 
}   
*/  
                   if(String.isBlank(leadObj.PAN_Holder_Name__c)){ 
                       strErrorMsg = strErrorMsg + 'Please enter PAN Card holder name.' + '<br/>'; 
                       isError = true; 
                   }   
                   
                   if(leadObj.Product__c == null){ 
                       strErrorMsg = strErrorMsg + 'Please enter Product for the merchant.' + '<br/>'; 
                       isError = true; 
                   }   
                   
                   if(String.isBlank(leadObj.PAN_Number__c)){  
                       strErrorMsg = strErrorMsg + 'Please enter PAN Card Number.' + '<br/>';  
                       isError = true; 
                   }           
                   //Aggregator logic added    
                   if(leadObj.Prod_Merchant_Id__c == null && leadObj.ProductLabel__c == 'PayUMoney' || leadObj.ProductLabel__c == 'PayUnow' || leadObj.ProductLabel__c == 'PayUbiz'){  
                       strErrorMsg = strErrorMsg + 'MID is not captured against the lead.' + '<br/>';  
                       isError = true; 
                   }   
                   //===============================   
                   System.debug('strErrorMsg ********* '+strErrorMsg); 
                   if(isError == true){    
                       leadObj.addError(strErrorMsg);//, false);   
                   }   
               }   
        }   
    }
    
    // ======= This method is used to get the Merchant ID and trigger assignment after lead insert ============
    private static void getMIDAndTriggerAssignment(List<Lead> newList){
        List<Lead> lstLeadsforAssignment = new List<Lead>();
        for(Lead each : newList){
            //LeadTriggerHelper.checkFetchMID(each, 'Lead');
            // preparing list of online leads to initiate assignment rule
            // ==============Commented due to JIRA ISSUE Because on some partner cases LeadSouce will always not will be partner. 
            //if(each.Sub_Source__c == 'WebsiteSignUp' && !each.LeadSource.equalsIgnoreCase('Partner') && (String.isNotEmpty(each.Business_Entity__c) || 'Partner'.equals(each.Lead_Type__c))){ //Commented for Partner cases 
            if(each.Sub_Source__c == 'WebsiteSignUp' && String.isBlank(each.Partner__c) && each.Partner__c==null && (String.isNotEmpty(each.Business_Entity__c) || 'Partner'.equals(each.Lead_Type__c))){ //Commented for Partner cases 
                lstLeadsforAssignment.add(new Lead(id = each.id));
            }
        }
        
        if(!lstLeadsforAssignment.isEmpty()){
            // triggering assignment rule for online leads
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            Database.update(lstLeadsforAssignment, dmo);
        }
    }
    
    private static void setLeadStatus(Lead leadObj){
        if(!leadObj.IsConverted || leadObj.Status != 'Qualified') leadObj.Status = 'Nurturing';
        if(leadObj.Sub_Source__c == 'WebsiteSignUp')    leadObj.Sub_Status__c = 'Self Signup';
        else{leadObj.Sub_Status__c = 'Contacted';}
    }
    
    private static void copyMIDToTxtField(Lead objLead){
        if(objLead.Prod_Merchant_Id__c != null)
            objLead.MID_Text_Field__c = String.valueof(objLead.Prod_Merchant_Id__c);
        else if(objLead.Merchant_Id__c != null)
            objLead.MID_Text_Field__c = String.valueof(objLead.Merchant_Id__c);
        
    }
    
    private static List<Group> getGroupdata(String strGroupName){
        return [SELECT Id, Name, Type, (SELECT Id, UserOrGroupId, GroupId FROM GroupMembers) FROM Group WHERE DeveloperName =: strGroupName AND Type =: 'Queue' LIMIT 1];
    }
    
    //Method for Lead_convert cmp
    @AuraEnabled
    public static String convertLead(Id recordId){
        try{
            Boolean error = false;
            User user = [SELECT Id, Name, ProfileId,Super_User__c FROM User Where Id=:UserInfo.getUserId()];
            Lead lead = [SELECT Id, Name, isConverted,Bank_Verification_Status__c,OwnerId,Company,Merchant_Id__c,
                         Round_Robin_Identifier__c,Sub_Status__c
                         FROM Lead WHERE Id =:recordId];
            Map<Id, Group> mapGroupRecords = New Map<Id, Group>();
            if(lead.IsConverted){
                error = true;
                return 'Lead already converted.';
            }else if(String.ValueOf(lead.ownerId).Startswith('005') && User.Id != lead.ownerId && !user.Super_User__c){
                error = true;
                return 'You are not a lead Owner.';
            }else if(String.ValueOf(lead.ownerId).Startswith('00G') && !user.Super_User__c){                
                getGroupDetails(new Set<Id>{lead.ownerId},mapGroupRecords);
                Set<String> groupMembersId = New Set<String>();
                for(GroupMember gm : mapGroupRecords.get(lead.ownerId).GroupMembers){
                    groupMembersId.add(gm.UserOrGroupId);
                }
                If(!groupMembersId.contains(String.ValueOf(lead.ownerId))){
                    error = true;
                    return 'You are not a part of queue.';
                }
            }else{
                //========= Commenting Bank Verification Status check for Onboarding Revamp-JIRA-SFPI-997============
                /* List<Bank_Account_Detail__c> bankAccList = [Select Id from Bank_Account_Detail__c where Lead__c=:recordId AND
verification_Status__c=:'Success' AND Active__c=:True];
if(bankAccList.Size()>0 && lead.Bank_Verification_Status__c !='Success'){
lead.Bank_Verification_Status__c = 'Success';
update lead;
system.debug('value printed');
}else if(bankAccList.Size() == 0 && bankAccList.isEmpty()){
error = true;
return 'Bank is not verified.';
}
if(string.isNotBlank(lead.id) && error == False && !lead.IsConverted && lead.Bank_Verification_Status__c == 'Success'){*/
                if(string.isNotBlank(lead.id) && error == False && !lead.IsConverted){
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(lead.Id);
                    if(lead.Sub_Status__c != 'Banned'){  
                        lc.setOpportunityName(lead.Company + (lead.Merchant_Id__c != null ? ' - ' + lead.Merchant_Id__c : ''));
                    }else{
                        lc.setDoNotCreateOpportunity(true);
                    }
                    
                    lc.setConvertedStatus('Qualified'); 
                    
                    if(String.valueof(lead.OwnerId).startsWith('00G') && !mapGroupRecords.isEmpty() && mapGroupRecords.containsKey(lead.OwnerId) && !mapGroupRecords.get(lead.OwnerId).GroupMembers.isEmpty())
                    {
                        SYstem.debug('inside 1851');
                        Integer userIndex = Math.mod(Integer.valueOf(lead.Round_Robin_Identifier__c), mapGroupRecords.get(lead.OwnerId).GroupMembers.Size());                
                        lc.setOwnerId(mapGroupRecords.get(lead.OwnerId).GroupMembers.get(userIndex).UserOrGroupId);              
                    } 
                    if(!String.valueof(lead.OwnerId).startsWith('00G') && String.valueof(lead.OwnerId) != System.Label.IntegrationUserId){
                        lc.setOwnerId(lead.OwnerId);
                    }
                     system.debug('lc::::'+lc);
                    Database.LeadConvertResult lcr = Database.convertLead(lc);
                    return 'Success';
                }else{
                    return 'Failed';
                }                
            }
            return '';
        }
        catch(Exception ex){
            System.debug('ERROR:: '+ex.getMessage());  
            System.debug('LINE NO:: '+ex.getLineNumber()); 
            return ex.getMessage();
        }
    }
    
    public static void getContactAndAccountWithIdentifiers(Map<String, Contact> contactMap, List<Contact> contactList, List<String> identifierListContact, Map<String, Account> accountMap, 
                                                           List<Account> accountList, List<String> identifierListAccount, List<Lead> newList){
                                                               List<String> identifierListLead = new List<String>();
                                                               for(Lead lead : newList){
                                                                   system.debug('@@@@ Check Identifier '+lead.Identifier__c);
                                                                   system.debug('@@@@ Check Merchant_Account_Id__c '+lead.Merchant_Account_Id__c );
                                                                   if(String.isNotBlank(lead.Identifier__c)) identifierListLead.add(lead.Identifier__c);
                                                               }
                                                               system.debug('++++List Value'+identifierListLead);
                                                               system.debug('++++List Size Value'+identifierListLead.size());
                                                               //Prashant
                                                               if(identifierListLead.size() > 0 && !identifierListLead.isEmpty()){
                                                                   contactList = [SELECT Id, Name, Identifier__c, Email, Account.Identifier__c,
                                                                                  (SELECT Id, AccountId, ContactId FROM Cases) FROM Contact 
                                                                                  WHERE Identifier__c IN :identifierListLead];
                                                                   if(contactList.size()>0 && !contactList.isEmpty()){
                                                                       for(Contact conObj : contactList){
                                                                           contactMap.put(conObj.Identifier__c, conObj);
                                                                           identifierListContact.add(conObj.Identifier__c);
                                                                           if(String.isNotBlank(conObj.Account.Identifier__c)) identifierListAccount.add(conObj.Account.Identifier__c);
                                                                       }
                                                                   }
                                                                   if(!identifierListAccount.isEmpty() && identifierListAccount.size()>0) 
                                                                       accountList = [SELECT Id, Name, Identifier__c FROM Account WHERE Identifier__c IN :identifierListAccount];
                                                                   if(accountList.size()>0 && !accountList.isEmpty()){
                                                                       for(Account accObj : accountList){
                                                                           accountMap.put(accObj.Identifier__c, accObj);
                                                                           identifierListAccount.add(accObj.Identifier__c);
                                                                       }
                                                                   }                                                                   
                                                               }
                                                           }
    
    public static void checkModifyOwner(List<Lead> triggerNew, Map<Id, Lead> triggerOldMap){
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));
        //Map<String, String> mapOfMerchant_Owners = (Map<String, String>)JSON.deserialize(Label.Merchant_Owner_for_Shopmatic, Map<String, String>.class);
        Map<String, String> mapOfMerchant_Owners= new Map<String, String>();	
        for(Partner_Lead_Ownership__mdt  ownerMetadata : [Select id,PartnerId_OwnerId_Map__c FROM Partner_Lead_Ownership__mdt order by label]){	
            mapOfMerchant_Owners = (Map<String, String>)JSON.deserialize(ownerMetadata.PartnerId_OwnerId_Map__c, Map<String, String>.class);	
        } 
        List<String> desiredOwners = new List<String>();
        Integer userIndex = 0;
        for(Lead lead : triggerNew){
            //Prashant New
            if(String.isNotBlank(lead.Partner_ID__c) && !mapOfMerchant_Owners.isEmpty()){
                if(lead.Partner__c != null && mapOfMerchant_Owners.containsKey(lead.Partner_ID__c)) 
                    desiredOwners = mapOfMerchant_Owners.get(lead.Partner_ID__c).split(', ');
                if(!desiredOwners.isEmpty()){
                    userIndex = Math.mod(IntrandomNumber, desiredOwners.Size());
                }else{
                    userIndex = 0;
                }
                if(trigger.isInsert){
                    if(mapOfMerchant_Owners.keySet().contains(lead.Partner_ID__c) && !desiredOwners.isEmpty() && !desiredOwners.contains(lead.OwnerId)){
                        lead.OwnerId =  desiredOwners.get(userIndex);
                        lead.Owner_Id__c = lead.OwnerId;
                    }
                }else if(trigger.isUpdate){
                    //List<String> payU_SMB_Outsource_Team_Members = Label.PayU_SMB_Outsource_Team_Members.split(', ');
                    if(mapOfMerchant_Owners.keySet().contains(lead.Partner_ID__c) && !desiredOwners.isEmpty() && lead.Partner__c != triggerOldMap.get(lead.id).partner__c && !desiredOwners.contains(lead.OwnerId)){
                        //if(!payU_SMB_Outsource_Team_Members.contains(lead.Owner_First_Name__c+' '+lead.Owner_Last_Name__c)){
                        lead.OwnerId =  desiredOwners.get(userIndex);
                        //lead.Owner_Id__c = lead.OwnerId;
                        // }else{
                        //    if(!triggerOldMap.isEmpty())    lead.OwnerId = triggerOldMap.get(lead.Id).ownerId;
                        //}
                    }
                    system.debug('-->> lead.OwnerId '+lead.OwnerId);
                }
                IntrandomNumber = IntrandomNumber+1;
            }
        }
    }
    
    //============Commenting the Wibmo Code as Team is not using the Product===============
    /*public static void LeadConvert_Wibmo(Lead newLead, Lead oldLead, List<Database.LeadConvert> leadsToConvert, Map<String, String> queriedObjMap, Map<Id, Group> mapGroupRecords, String setCId, String setAId){
system.debug('Inside Method');
List<Account> actList= new List<Account>();
Database.LeadConvert lc = new Database.LeadConvert();
List<Account> accntObjList = getAccountdata(newLead.Client_Name_New__c);                            
system.debug('accntObjList@@'+accntObjList);
for(String each : fieldsToCkeck){                
String theFieldValue = String.ValueOf(newLead.get(each)); 

if(String.isNotBlank(theFieldValue) && queriedObjMap.containsKey(theFieldValue)){
String accOrConId = queriedObjMap.get(theFieldValue);
if(String.isNotBlank(accOrConId)){ 
if(accOrConId.startsWith('001')) lc.setAccountId(accOrConId);
if(accOrConId.startsWith('003')) lc.setContactId(accOrConId);
} 
}
}            
if(String.isNotBlank(setCId) && setCId != null && String.isNotBlank(setAId) && setAId != null){
lc.setAccountId(setAId);
lc.setContactId(setCId);
}
if(String.isNotBlank(setAId) && setAId != null){
lc.setAccountId(setAId);
}
system.debug('setAId Prashant'+setAId);
system.debug('setLeadId Prashant'+setAId);

lc.setLeadId(newLead.Id);
If(!accntObjList.isEmpty() && accntObjList.size()>0){
lc.setConvertedStatus('Qualified'); 
system.debug('Coversion done ');
leadsToConvert.add(lc);
}
else{
Account accountParentWibmo= new Account();

Client_Name__c clientname =[select name from Client_Name__c where id=:newLead.Client_Name_New__c];
accountParentWibmo.Name=clientname.name;
accountParentWibmo.Type__c='Wibmo';
accountParentWibmo.Client_Name_New__c= newLead.Client_Name_New__c;

actList.add(accountParentWibmo);
system.debug('Before insert prashant@@'+actList);
if(!actList.isEmpty())  insert actList;
system.debug('After insert prashant@@');


lc.setConvertedStatus('Qualified'); 
system.debug('Coversion done in Account Not found');
leadsToConvert.add(lc);
Database.LeadConvertResult lcr = Database.convertLead(lc);
} 
}

private static List<Account> getAccountdata(String clientName){
return [SELECT Id, Name, Client_Name__c , Region__c 
FROM Account 
WHERE Type__c =: 'Wibmo' AND Client_Name_New__c !=''
AND (Client_Name_New__c =:clientName AND ParentId = null)];
}
*/
    
    public static void updateDeliveryDuration(Set<Id> subCategoryIds,List<Lead> triggerNew){
        Map<Id,Sub_Category__c> subCategoryMap = new Map<Id,Sub_Category__c>();
        if(!subCategoryIds.isEmpty() && subCategoryIds.size()>0){
            for(Sub_Category__c sbObj : [Select Id,Delivery_duration__c from Sub_Category__c where Id IN: subCategoryIds]){
                if(sbObj.Delivery_duration__c != null){
                    subCategoryMap.put(sbObj.Id,sbobj);
                }
            }
            if(!subCategoryMap.isEmpty() && subCategoryMap != null){
                for(Lead eachLead : triggerNew){
                    if(subCategoryMap.containsKey(eachLead.Sub_Category__c)){
                        if(eachLead.Delivery_Duration__c==null || eachLead.Delivery_Duration__c==0)
                            eachLead.Delivery_Duration__c = subCategoryMap.get(eachLead.Sub_Category__c).Delivery_duration__c;
                    }
                }
            }
        }
    }
    
    private static void otherLeadConversionValidation(List<Lead> otherLeadTriggerNew){}
    
    // Created for click to call
    public static void createTaskforClickToCall(List<Lead> triggerNew,Map<Id, Lead> triggerOldMap){  
        try{  
            //Integer tempCount = 0;  
            List<Task> taskList = new List<Task>();  
            String userDetails = '';  
            for(Lead lead: triggerNew){  
                userDetails = lead.Agent_Details__c;  
            }  
            List<String> strList = new List<String>();
            if(userDetails != null){
                strList =  userDetails.split('-');
            }
            
            String userMobile = strList[1].deleteWhitespace();  
            if(userMobile.contains('+91')){  
                userMobile = userMobile.removeStart('+91');  
            }  
            userMobile = '%'+userMobile;  
            //String finalMobile  
            String userName = strList[0].trim();  
            System.debug('userMobile:: '+userMobile);  
            System.debug('userName:: '+userName);  
            User user = [SELECT Id, Name,isActive,FirstName,LastName, MobilePhone FROM User where Name =: userName AND isActive = true AND MobilePhone Like: userMobile];  
            System.debug('user:: '+user);  
            for(Lead lead: triggerNew){  
                Lead oldlead = triggerOldMap.get(lead.Id);  
                Decimal oldCount;  
                if(oldlead.C2C_Call_Count__c  != null && lead.Manual_Call_Response__c  != oldlead.Manual_Call_Response__c){  
                    oldCount = oldlead.C2C_Call_Count__c ;  
                }else if(lead.C2C_Call_Count__c ==null){  
                    oldCount = 0;  
                }  
                
                if(lead.Manual_Call_Response__c  != oldlead.Manual_Call_Response__c && lead.Manual_Call_Response__c != null && (lead.Missed_Call_Time__c == oldlead.Missed_Call_Time__c)){  
                    
                    lead.C2C_Call_Count__c   = oldCount + 1;
                    Task taskObj = getTaskList(lead, user, 'Click To Call Details', 'Closed');
                    taskObj.Description = 'Manual Call Responce:: '+lead.Manual_Call_Response__c+', '+'\n Audio Clip: '+lead.Audio_Clip__c;  
                    taskObj.Agent_Details__c = lead.Agent_Details__c;
                    if(string.isNotBlank(lead.Call_Status__c) && string.isNotBlank(lead.Call_Duration__c) && lead.Call_Status__c != NULL && lead.Call_Duration__c != NULL){
                        taskObj.Call_Status__c = lead.Call_Status__c;
                        taskObj.CallDurationInSeconds = Integer.valueOf(lead.Call_Duration__c);
                    }
                    taskList.add(taskObj);  
                }  
                if(lead.Missed_Call_Time__c != oldlead.Missed_Call_Time__c && String.isNotBlank(lead.Missed_Call_Time__c) ){  
                    Task taskObj = getTaskList(lead, user, 'Click To Call Missed Call Alert', 'Open');
                    taskList.add(taskObj);
                }  
            }  
            if(taskList.size() > 0){
                system.debug('Insert Task'+taskList);
                insert taskList;  
                system.debug('Insert sucessfully'+taskList);
            }  
        }Catch(Exception ex){  
            System.debug('ERROR:: '+ex.getMessage());  
            System.debug('LINE NO:: '+ex.getLineNumber());  
        } 
    }
    
    //===========================MID fetching from CO === KUNAL ==SFI-600=====================
    /*@future (callout=true)
public static void getMID(Set<ID> leadIds){

List<Lead> leads = [SELECT Name, Email, MobilePhone, FirstName, Product__c FROM Lead WHERE Id IN :leadIds];
System.debug('Lead list ==>'+leads);
string enterpriseMIDAccessToken = '';
if(!Test.isRunningTest()){
enterpriseMIDAccessToken = IntegrationUtility.getAuthToken('EnterpriseMIDAuthentication');
System.debug('enterpriseMIDAccessToken : '+enterpriseMIDAccessToken);

}
else{
enterpriseMIDAccessToken += 'b74acb75e87f93aa9db8073d570753474e58702aa9e91af4054478bba98af38e';
System.debug('enterpriseMIDAccessToken+++'+enterpriseMIDAccessToken);
}


// Define the endpoint URL and HTTP method
String endpoint = 'https://test10-onboarding.payu.in/api/v3/sf_product_accounts/';
String httpMethod = 'POST';
//List<Map<String, Object>> requestBodyList = new List<Map<String, Object>>();   
Map<String, Object> productAccount = new Map<String, Object>();
List<Lead> updateMIDList = new List<Lead>();
for (Lead lead : leads) {
//Map<String, Object> productAccount = new Map<String, Object>();
productAccount.put('email', lead.Email);
productAccount.put('first_name', lead.FirstName);
productAccount.put('mobile', lead.MobilePhone);
productAccount.put('product', 'PayUbiz');

//String bodyCustom = "{\"product_account\":{\"email\":\"testr8@payutest.in\",\"mobile\":\"8820454582\",\"first_name\":\"Test1\",\"last_name\":\"2\",\"business_name\":\"TestCorp\",\"monthly_expected_volume\":\"100\",\"average_delivery_time\":\"10\",\"website_url\":\"www.youtube.com\",\"gst_number\":\"07CPBPP3374Q1Z1\",\"product\":\"PayUbiz\",}}";


//requestBodyList.add(productAccount);
//String requestBody = JSON.serialize(requestBodyList);
String requestBody = JSON.serialize(productAccount);

String finalRequestBody = '{ "product_account": '+requestBody+' }';

System.debug('Final Body ==>'+finalRequestBody);

System.debug('Body List Serialized ==>'+requestBody);

if(string.isNotBlank(enterpriseMIDAccessToken)){
HttpRequest request = new HttpRequest();
request.setEndpoint(endpoint);
request.setMethod(httpMethod);
request.setHeader('Content-Type', 'application/json');
request.setHeader('Authorization', 'Bearer '+enterpriseMIDAccessToken);
request.setBody(finalRequestBody);
request.setTimeout(120000);

// Send the HTTP request and get the response
Http http = new Http();
HttpResponse response = http.send(request);

// Handle the response as needed
if (response.getStatusCode() == 200) {
System.debug('HTTP callout succeeded');
System.debug('Response==>'+response.getBody());
Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
Map<String, Object> prdAccountObj = (Map<String, Object>) responseObj.get('product_account');
Integer midExtract = (Integer)prdAccountObj.get('identifier');
System.debug('prdAccountObj==>'+(Integer)prdAccountObj.get('identifier'));

Lead leadRec = new Lead();
leadRec.Id = lead.Id;
leadRec.Prod_Merchant_Id__c = midExtract;

updateMIDList.add(leadRec);

} 
else {
System.debug('HTTP callout failed with status code ' + response.getStatusCode() + ' and message ' + response.getStatus());
}

}
update updateMIDList;
}
}*/
    
  /*  @future(callout=true)
    public static void getMID(Set<ID> leadIds) {
        //String productSent = new String();
        List<Lead> leads = [SELECT Id, Name, Email, MobilePhone, FirstName, Product__c, Select_Product__c FROM Lead WHERE Id IN :leadIds];
        
        String enterpriseMIDAccessToken = Test.isRunningTest() ? 'b74acb75e87f93aa9db8073d570753474e58702aa9e91af4054478bba98af38e' : IntegrationUtility.getAuthToken('EnterpriseMIDAuthentication');
        
        // Define the endpoint URL and HTTP method
        String endpoint = 'https://test10-onboarding.payu.in/api/v3/sf_product_accounts/';
        String httpMethod = 'POST';
        List<Lead> updateMIDList = new List<Lead>();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(httpMethod);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + enterpriseMIDAccessToken);
        request.setTimeout(120000);
        
        for (Lead lead : leads) {
            String productSent;
            if(lead.Select_Product__c == 'PayU Biz') productSent = 'PayUbiz';
            Map<String, Object> productAccount = new Map<String, Object>();
            productAccount.put('email', lead.Email);
            productAccount.put('first_name', lead.FirstName);
            productAccount.put('mobile', lead.MobilePhone);
            //productAccount.put('product', lead.Select_Product__c);
            productAccount.put('product', productSent);
            String requestBody = JSON.serialize(new Map<String, Object>{'product_account' => productAccount});
            request.setBody(requestBody);
            
            // Send the HTTP request and get the response
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            // Handle the response as needed
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> prdAccountObj = (Map<String, Object>) responseObj.get('product_account');
                Integer midExtract = (Integer) prdAccountObj.get('identifier');
                Lead leadRec = new Lead(Id = lead.Id, Prod_Merchant_Id__c = midExtract);
                updateMIDList.add(leadRec);
                SYstem.debug('updateMIDList::::'+updateMIDList);
            } else {
                System.debug('HTTP callout failed with status code ' + response.getStatusCode() + ' and message ' + response.getStatus());
            }
        }
        update updateMIDList ;
    }*/
    
    
    //===========================END===MID fetching from CO === KUNAL ==SFI-600=====================
    
    private static Task getTaskList(Lead lead, User user, String subject, String status){
        Task objTask = New Task();  
        objTask.Subject = subject;  
        objTask.whoId = lead.Id;  
        objTask.Status = status;  
        objTask.OwnerId = user.Id;  
        objTask.Merchant_Name__c = lead.Merchant_Name__c;  
        objTask.Merchant_Mobile__c = lead.Merchant_Mobile__c;  
        return objTask;
    }
}