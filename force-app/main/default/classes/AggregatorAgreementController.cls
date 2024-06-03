public class AggregatorAgreementController {
    
    public String strContentType {get; set;}
    public String strRenderAs {get; set;}
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
    public Id parentOptyId {get; set;}
    public Id parentAcntId {get; set;}
    public List<Bank_Account_Detail__c> lstBankAccDetailParent {get; set;}
    public Account accParentObj {get; set;}
    public Opportunity oppParentObj {get; set;}
    public Address_Details__c regParentAddress {get; set;}      
    public Address_Details__c opParentAddress {get; set;}
    public List<Contract> lstContract {get; set;}
    public date oneYearLaterDate {get; set;}
    public List<Payment__c> lstPaymentParentOpty {get; set;}
    public decimal decSetupParentAmount {get; set;}
    public decimal decAMCParentAmount {get; set;}
    public decimal decSecurityDepositParentAmnt {get; set;} 
    
    public AggregatorAgreementController(ApexPages.StandardController controller) {         
        if (!Test.isRunningTest())  controller.addFields(new List<String>{'Id', 'AccountId', 'Name', 'Website__c', 'Email__c', 'Parent_Opportunity__c'});
        
        lstPayment = new List<Payment__c>();
        listTDRs = new List<TDR__c>();
        lstBankAccDetail = new List<Bank_Account_Detail__c>();
        lstBankAccDetailParent = new List<Bank_Account_Detail__c>(); 
        lstCommercial = new List<Commercial__c>();
        strRenderAs = '';
        strContentType = '';
        todayDate = System.today();
        oneYearLaterDate = todaydate.addYears(1);
        accParentObj = new Account();
        oppParentObj = new Opportunity();
        regParentAddress = new Address_Details__c ();
        opParentAddress = new Address_Details__c ();
        regAddress = new Address_Details__c (); 
        opAddress = new Address_Details__c (); 
        lstContract = new List<Contract>();
        lstPaymentParentOpty = new List<Payment__c>();
            
        oppObj = (opportunity) controller.getRecord();
        system.debug('oppObj ========== '+oppObj);
        
        if(oppObj != null && String.isNotBlank(oppObj.Id)){
                dt = new Map<Integer, String>{1 => 'st', 2 => 'nd', 3 => 'rd', 4 => 'th', 5 => 'th', 6 => 'th', 7 => 'th', 8 => 'th', 9 => 'th', 10 => 'th',
                11 => 'th', 12 => 'th', 13 => 'th', 14 => 'th', 15 => 'th', 16 => 'th', 17 => 'th', 18 => 'th', 19 => 'th', 20 => 'th',
                21 => 'st', 22 => 'nd', 23 => 'rd', 24 => 'th', 25 => 'th', 26 => 'th', 27 => 'th', 28 => 'th', 29 => 'th', 30 => 'th', 31 => 'st'};
                    
            mnth = new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',6=>'June', 7=>'July', 8=>'August', 9=>'September',
                        10=>'October',11=>'November', 12=>'December'};
                            
            eStampNo = ApexPages.currentPage().getParameters().get('eStampNo');
            system.debug('eStampNo @@@@@@@@@@@ '+eStampNo ); 
            
            strIsFinal = ApexPages.currentPage().getParameters().get('strIsFinal');
            system.debug('strIsFinal &&&&&&&&&&&&&&&& '+strIsFinal );
             
            if(strIsFinal == 'true'){
                strRenderAs = 'PDF';
                strContentType = '';
            }else if(strIsFinal == 'false'){
                strRenderAs = '';
                strContentType = 'application/msword#ServiceAgreementIndianTrustsActOf1882.doc';
            }
            system.debug('strRenderAs =='+strRenderAs + ' & strContentType== ' +strContentType );
            
            if(String.isNotBlank(oppObj.Parent_Opportunity__c))    parentOptyId = oppObj.Parent_Opportunity__c;
            system.debug('parentOptyId @@@@@@@@@@@ '+parentOptyId ); 
            
            if(String.isNotBlank(parentOptyId)) oppParentObj = getParentOpty(parentOptyId);
            
            if(oppObj != null && String.isNotBlank(oppObj.Id)){
                decAMCAmount = decSetupAmount = decSecurityDeposit = 0.00;
                todayDate = System.today();
                
                accObj = getAccountDetails(oppObj.AccountId);    
                system.debug('accObj ========== '+accObj);
                
                if(String.isNotBlank(accObj.ParentId)) parentAcntId = accObj.ParentId;
                system.debug('parentAcntId ************* '+parentAcntId );
                
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
                
                if(String.isNotBlank(parentOptyId)) lstPaymentParentOpty = getPaymentList(parentOptyId); 
                if(lstPaymentParentOpty != null && !lstPaymentParentOpty .isEMpty()){
                    for(Payment__c  paymentObj : lstPaymentParentOpty){
                        if(paymentObj.Charges_Type__c == 'AMC' ){
                            decAMCParentAmount = paymentObj.Amount1__c != null ? paymentObj.Amount1__c : 0.00 ;
                        }
                        if(paymentObj.Charges_Type__c == 'Setup Fee' ){
                            decSetupParentAmount = paymentObj.Amount1__c != null ? paymentObj.Amount1__c : 0.00 ;
                        }
                        if(paymentObj.Charges_Type__c == 'Security Deposit' ){
                            decSecurityDepositParentAmnt = paymentObj.Amount1__c != null ? paymentObj.Amount1__c : 0.00 ;
                        }
                    }
                }
                
                
                //listTDRs = getTDRList(oppObj.Id); 
                system.debug('listTDRs ========== '+listTDRs);
                
                lstBankAccDetail = getbankAccDetailsList(oppObj.Id);             
                system.debug('lstBankAccDetail ========== '+lstBankAccDetail);   
                
                lstCommercial = getCommercialDetails(oppObj.Id);
                system.debug('lstCommercial ========== '+lstCommercial ); 
                
                if(String.isNotBlank(parentOptyId))    lstBankAccDetailParent = getbankAccDetailsList(parentOptyId);
                
                if(String.isNotBlank(parentAcntId))    accParentObj = getAccountDetails(parentAcntId); 
                
                if(String.isNotBlank(parentAcntId)) lstContract = getContractDetails(parentAcntId);
                
                if(accParentObj.Id != null && accParentObj.Address_Details__r != null && !accParentObj.Address_Details__r.isEmpty()){
                    for(Address_Details__c addDetail : accParentObj.Address_Details__r){
                        if(addDetail.Type__c == 'Registered'){
                            regParentAddress = addDetail;
                        }
                        if(addDetail.Type__c == 'Operating'){
                            opParentAddress = addDetail;
                        }
                    }
                }
            }
        }        
    }
    
    //======== Get the Parent Opportunity record if exist ========================
    Private Static Opportunity getParentOpty(Id parentOptyId){
        return [SELECT Id, Website__c, Email__c FROM Opportunity WHERE Id =: parentOptyId];
    }
    
    // ======= Get the Account record ===========================
    Private Static Account getAccountDetails(Id AccId){
        return [SELECT Id, Name, Legal_Name__c, BillingAddress, BillingStreet, BillingCity, BillingState, BillingCountry,Merchant_Trading_Name__c,
                BillingPostalCode, ShippingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, ParentId,
                Website, Business_Category__c, Business_Category__r.Name, Sub_Category__c, Sub_Category__r.Name, PAN_Number__c,Business_Entity__r.Name,
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
        return [SELECT Id, Amount__c, Charges_Type__c, Amount1__c  
                FROM Payment__c]; 
    }
    
    // ======= Get the list of TDR ===========================
    Private Static List<TDR__c> getTDRList(Id OptyId){
        return [SELECT Id, Name, Active__c, Sponsor__c, MDR__c, TSF__c, Payment_Gateway__c, Payment_Gateway__r.Name 
                FROM TDR__c LIMIT 50000]; 
    }
    
    // ======= Get the list of Bank Account Details ===========================
    Private Static List<Bank_Account_Detail__c> getbankAccDetailsList(Id OptyId){
        return [SELECT Id, Name, Account_Number__c, Account_Holder_Name__c, Bank_Name__c, Branch_Address__c, IFSC_Code__c 
                FROM Bank_Account_Detail__c 
                WHERE Opportunity__c =: OptyId 
                AND Active__c = True 
                Order By CreatedDate ASC
                Limit 1]; 
    }
    
    // ======= Get the list of Commercials ===========================
    Private Static List<Commercial__c> getCommercialDetails(Id OptyId){
        return [Select Id, Name, AMC__c, Deposit_Fee__c, Setup_Fee__c FROM Commercial__c 
                WHERE Opportunity__c =: OptyId AND Active__c = True 
                Limit 1];
    }    
    
    Private Static List<Contract> getContractDetails(Id AccId){        
         return [SELECT Id, Name, StartDate, Type__c, AccountId, EndDate 
                FROM Contract 
                WHERE AccountId =: AccId AND Type__c =: 'Final' AND Active__c =: true Limit 1]; 
    }
}