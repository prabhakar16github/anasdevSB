public class ServiceAgreementMoneyComponentController{

    public String strContentType {get; set;}
    public String strRenderAs {get; set;}
    public String strOppId{get;set;}
    public String strIsFinal {get; set;}
    public String eStampNo {get; set;}
    public decimal decSetupAmount {get; set;}
    public decimal decAMCAmount {get; set;}
    public decimal decSecurityDeposit {get; set;} 
    public date todayDate {get; set;}
    public Opportunity oppObj {get; set;}
    public Account accObj {get; set;}
    public contact conSecondaryCon {get; set;} 
    public contact conAuthSign {get; set;} 
    public Address_Details__c regAddress {get; set;}
    public Address_Details__c opAddress {get; set;}
    public List<Payment__c> lstPayment {get; set;}
    public List<TDR__c> listTDRs {get; set;}
    public List<Bank_Account_Detail__c> lstBankAccDetail {get; set;}
    public List<Commercial__c> lstCommercial {get; set;}
    public Map<Integer, String> dt {get; set;}
    public Map<Integer, String> mnth {get; set;}
    
    public string getstrOpportunity() {         
        //if (!Test.isRunningTest())  controller.addFields(new List<String>{'Id', 'AccountId', 'Name'});
        
        lstPayment = new List<Payment__c>();
        listTDRs = new List<TDR__c>();
        lstBankAccDetail = new List<Bank_Account_Detail__c>();
        lstCommercial = new List<Commercial__c>();
        strRenderAs = '';
        strContentType = '';
        
        if(!string.isBlank(strOppId)){
        List<Schema.FieldSetMember> lstOfFieldMember = SObjectType.Opportunity.FieldSets.OpportunityfieldSetData.getFields();
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : lstOfFieldMember) {
             query += f.getFieldPath() + ', ';
        }
        query += 'id FROM Opportunity WHERE id=\''+strOppId+'\' LIMIT 1';
        List<Opportunity> lstOpp = Database.query(query);
        if(lstOpp != null && lstOpp.size() > 0)
           oppObj =  lstOpp[0];
        } 
        system.debug('oppObj ========== '+oppObj);
        
        if(oppObj != null && String.isNotBlank(oppObj.Id)){
                dt = new Map<Integer, String>{1 => 'st', 2 => 'nd', 3 => 'rd', 4 => 'th', 5 => 'th', 6 => 'th', 7 => 'th', 8 => 'th', 9 => 'th', 10 => 'th',
                11 => 'th', 12 => 'th', 13 => 'th', 14 => 'th', 15 => 'th', 16 => 'th', 17 => 'th', 18 => 'th', 19 => 'th', 20 => 'th',
                21 => 'st', 22 => 'nd', 23 => 'rd', 24 => 'th', 25 => 'th', 26 => 'th', 27 => 'th', 28 => 'th', 29 => 'th', 30 => 'th', 31 => 'st'};
                    
            mnth = new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',6=>'June', 7=>'July', 8=>'August', 9=>'September',
                        10=>'October',11=>'November', 12=>'December'};
                            
            //eStampNo = ApexPages.currentPage().getParameters().get('eStampNo');
            system.debug('eStampNo @@@@@@@@@@@ '+eStampNo ); 
            
            if(oppObj.Account != null && oppObj.Account.Business_Entity__c != null && oppObj.Product__c != null)
            {
                List<E_Stamp_Master__c > lstEStampMaster = [SELECT Id, EStamp_Number__c, Active__c, Used__c FROM E_Stamp_Master__c 
                                                               WHERE Active__c = true AND Used__c = false ORDER BY EStamp_Number__c ASC];
                if(lstEStampMaster != null && lstEStampMaster.size() > 0 && lstEStampMaster[0].EStamp_Number__c != null)
                    eStampNo = String.valueof(lstEStampMaster[0].EStamp_Number__c);                                                        
            }
            
            //strIsFinal = ApexPages.currentPage().getParameters().get('strIsFinal');
           system.debug('strIsFinal &&&&&&&&&&&&&&&& '+strIsFinal );
              
            system.debug('strRenderAs =='+strRenderAs + ' & strContentType== ' +strContentType );
            
            if(oppObj != null && String.isNotBlank(oppObj.Id)){
                decAMCAmount = decSetupAmount = decSecurityDeposit = 0.00;
                todayDate = System.today();
                
                accObj = getAccountDetails(oppObj.AccountId);    
                system.debug('accObj ========== '+accObj);
                
                if(accObj.Contacts != null && !accObj.Contacts.isEmpty()){
                    for(contact conObj : accObj.Contacts){
                        if(conObj.Type__c == 'Secondary Contact'){
                            conSecondaryCon = conObj;
                        }
                        if(conObj.Authorised_Signatory__c){
                            conAuthSign = conObj;
                        }
                    }
                }
                
                if(accObj.Address_Details__r != null && !accObj.Address_Details__r.isEmpty()){
                    for(Address_Details__c addDetail : accObj.Address_Details__r){
                        if(addDetail.Type__c == 'Registered'){
                            regAddress = addDetail;
                        }
                        if(addDetail.Type__c == 'Operating'){
                            opAddress = addDetail;
                        }
                    }
                }
                
                lstPayment = getPaymentList(oppObj.Id); 
                system.debug('lstPayment ========== '+lstPayment);
                
                if(lstPayment != null && !lstPayment .isEMpty()){
                    for(Payment__c  paymentObj : lstPayment){
                        if(paymentObj.Charges_Type__c == 'AMC' ){
                            decAMCAmount = paymentObj.Amount__c != null ? paymentObj.Amount__c : 0.00 ;
                        }
                        if(paymentObj.Charges_Type__c == 'Setup Fee' ){
                            decSetupAmount = paymentObj.Amount__c != null ? paymentObj.Amount__c : 0.00 ;
                        }
                        if(paymentObj.Charges_Type__c == 'Security Deposit' ){
                            decSecurityDeposit = paymentObj.Amount__c != null ? paymentObj.Amount__c : 0.00 ;
                        }
                    }
                }
                
                listTDRs = getTDRList(oppObj.Id); 
                system.debug('listTDRs ========== '+listTDRs);
                
                lstBankAccDetail = getbankAccDetailsList(oppObj.Id);             
                system.debug('lstBankAccDetail ========== '+lstBankAccDetail);   
                
                lstCommercial = getCommercialDetails(oppObj.Id);
                system.debug('lstCommercial ========== '+lstCommercial ); 
            }
        }  
        return '';      
    }
    
    // ======= Get the Account record ===========================
    Private Static Account getAccountDetails(Id AccId){
        return [SELECT Id, Name, Legal_Name__c, BillingAddress, BillingStreet, BillingCity, BillingState, BillingCountry,Merchant_Trading_Name__c,
                BillingPostalCode, ShippingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, 
                Website, Business_Category__c, Business_Category__r.Name, Sub_Category__c, Sub_Category__r.Name,PAN_Number__c,Business_Entity__r.Name,
                (SELECT Id, Name, Email, MobilePhone, Phone,Fax, Designation__c, Type__c,Authorised_Signatory__c 
                 FROM Contacts 
                 WHERE Type__c =: 'Secondary Contact' 
                 OR Authorised_Signatory__c =: true),
                (SELECT Id, Name, Address_Line__c, Pincode__c, City__c, State__c, Country__c, Type__c
                 FROM Address_Details__r WHERE Type__c IN ('Registered', 'Operating'))
                FROM Account 
                WHERE Id =: AccId];
    }
    
    // ======= Get the list of Payment ===========================
    Private Static List<Payment__c> getPaymentList(Id OptyId){
        return [SELECT Id, Amount__c, Charges_Type__c  
                FROM Payment__c]; 
    }
    
    // ======= Get the list of TDR ===========================
    Private Static List<TDR__c> getTDRList(Id OptyId){
        return [SELECT Id, Name, Active__c, Sponsor__c, 
                Payment_Gateway__c, Payment_Gateway__r.Name 
                FROM TDR__c LIMIT 50000]; 
    }
    
    // ======= Get the list of Bank Account Details ===========================
    Private Static List<Bank_Account_Detail__c> getbankAccDetailsList(Id OptyId){
        return [SELECT Id, Name, Account_Number__c, Account_Holder_Name__c, Bank_Name__c, Branch_Address__c, IFSC_Code__c 
                FROM Bank_Account_Detail__c 
                WHERE Opportunity__c =: OptyId 
                AND Active__c = True 
                Limit 1]; 
    }
    
    // ======= Get the list of Commercials ===========================
    Private Static List<Commercial__c> getCommercialDetails(Id OptyId){
        return [Select Id, Name, AMC__c, Deposit_Fee__c, Setup_Fee__c FROM Commercial__c 
                WHERE Opportunity__c =: OptyId AND Active__c = True 
                Limit 1];
    }    
    
}