public class ServiceAgreementController {
    public String strContentType {get; set;}
    public String strRenderAs {get; set;}
    public String strIsFinal {get; set;}
    public String eStampNo {get; set;}
    public decimal decSetupAmount {get; set;}
    public decimal decAMCAmount {get; set;}
    public decimal decSecurityDeposit {get; set;} 
    public date todayDate {get; set;} 
    public Product_Account_Detail__c prdctaccObj {get; set;}
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
    public List<Fee_Master__c> listFeeMaster {get; set;}
    public List<Cross_Sell__c> listCrossSell {get; set;}
    public List<Fee_Master__c> listPayoutFeeMaster {get; set;}
    public Map<String, List<pricingTableWrapper>> pricingMap {get;set;} 
 	public Map<String, Integer> pricingCountMap{get;set;}
 	public List<String> modeList {get;set;}
    public String websiteLinkDetails {get;set;}
    public String businessCategoryDetails {get;set;}
    public String businessEntityDetails {get;set;}
    public List<String> customizedRatesUI {get; set;}
    
    public ServiceAgreementController(ApexPages.StandardController controller) {         
        if (!Test.isRunningTest())  controller.addFields(new List<String>{'Id', 'Mobile__c','AccountId', 'Name', 'Website__c', 'Email__c', 'Parent_Opportunity__c','Fee_Model__c','Fee_Model__r.Name','New_Website_Url__c','BusinessEntityName__c','Business_Category__c','IOS_URL__c','Android_URL__c','Legal_Name_Account__c'});
        
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
        listFeeMaster = New List<Fee_Master__c>();
        listCrossSell = New List<Cross_Sell__c>();
        listPayoutFeeMaster = New List<Fee_Master__c>();
        pricingMap = new Map<String, List<pricingTableWrapper>>();
  		pricingCountMap = new Map<String, Integer>();
  		modeList = new List<String>();
        businessCategoryDetails = '';
        businessEntityDetails ='';

        Opportunity oppRecord = (Opportunity) controller.getRecord();
        List<Opportunity> oppRecs = [Select Id , AccountId , Parent_Opportunity__c , Business_Category__c , BusinessEntityName__c , Settlement_Date__c, Fee_Model__c, Legal_Name_Account__c, Website__c, Android_URL__c, iOS_URL__c , Mobile__c, Email__c, Offer_Engine_Commercial__c, Lead_Business_Name__c, Letter_Dated__c, Account_Number__c, Merchant_Affordability_Frequency__c, Rate_Merchant_Affordability__c, Prod_Merchant_Id__c /*, Customized_Rates__c*/ FROM Opportunity Where Id = :oppRecord.Id];
        if(oppRecs.size() > 0) {
            oppObj = oppRecs[0];
             /*if(!String.isBlank(oppObj.Customized_Rates__c)) {
                customizedRatesUI = oppObj.Customized_Rates__c.split(';');
                System.debug(customizedRatesUI);
                System.debug(EncodingUtil.urlEncode(oppObj.Customized_Rates__c, 'UTF-8'));
            }*/
        } else {
            oppObj = new Opportunity();
        }
        
         List<Product_Account_Detail__c> padRecs= [SELECT Id, Name, MCP_Ticket_ID__c, Priority_Settlement_Plan__c, American_Express_cards__c, Credit_card_EMIs__c, Diners_Credit_cards__c, Debit_card_EMIs__c, Deferred_Payment_Solutions__c,Rupay_Credit_cards__c,Wallets__c,LazyPay__c, Cycle_Name__c, Settlement_Charge__c FROM Product_Account_Detail__c where Opportunity__c=:oppRecord.id];
        if(padRecs.size() > 0) {
            prdctaccObj = padRecs[0];
        } else {
            prdctaccObj = new Product_Account_Detail__c();
        }
        
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
                        if(conObj.Authorised_Signatory__c && conObj.Active__c){
                            conAuthSign = conObj;
                        }
                    }
                }
                
                //============Updated for Onboarding Revamp==============
                /*if(accObj.Address_Details__r != null && !accObj.Address_Details__r.isEmpty()){
                    for(Address_Details__c addDetail : accObj.Address_Details__r){
                        if(addDetail.Type__c == 'Registered'){
                            if(String.isNotBlank(addDetail.Opportunity__c) && addDetail.Opportunity__c == oppObj.Id){
                                regAddress = addDetail;
                            }else if(String.isBlank(addDetail.Opportunity__c)){
                               regAddress = addDetail;
                            }
                        }
                        if(addDetail.Type__c == 'Operating'){
                            if(String.isNotBlank(addDetail.Opportunity__c) && addDetail.Opportunity__c == oppObj.Id){
                               opAddress = addDetail;
                            }else if(String.isBlank(addDetail.Opportunity__c)){
                                opAddress = addDetail;
                            }
                        }
                    }
                }else{
                    for(Address_Details__c addDetail : [SELECT Id, Name, Address_Line__c, Pincode__c, City__c, State__c, Country__c, Type__c,Opportunity__c
                 										FROM Address_Details__c WHERE Active__c=true AND Type__c IN ('Registered', 'Operating') AND Opportunity__c =:oppObj.Id ]){
                     if(addDetail != Null){
                         if(addDetail.Type__c == 'Registered'){
                            regAddress = addDetail;
                        }
                        if(addDetail.Type__c == 'Operating'){
                            opAddress = addDetail;
                        }                        
                    }
                   }*/
                       
                 //}
                 /**** To populate Address details in Service Agreement.
                  * If Address details are ACTIVE on Opportunity, it will get populated.
                  * If it is not Active on Opportunity, and Active on Account, then the Account's Address details will get populated in agreement
                  */
                 List<Address_Details__c> addDetailOpp = [SELECT Id, Name, Address_Line__c, Pincode__c, City__c, State__c, Country__c, Type__c,Account__c
                 										FROM Address_Details__c WHERE Active__c=true AND Type__c IN ('Registered', 'Operating') AND Opportunity__c =:oppObj.Id];
                	List<Address_Details__c> addDetailAcc = [SELECT Id, Name, Address_Line__c, Pincode__c, City__c, State__c, Country__c, Type__c,Account__c
                 										FROM Address_Details__c WHERE Active__c=true AND Type__c IN ('Registered', 'Operating') AND Account__c =:accObj.Id];
                	
                    if(addDetailOpp.size()>0){
                        for(Address_Details__c addDetail : addDetailOpp){
                            if(addDetail.Type__c == 'Registered'){
                            	regAddress = addDetail;
                          }
                        	if(addDetail.Type__c == 'Operating'){
                            	opAddress = addDetail;
                          }
                        }
                        System.debug('Insiddddeeee if');
                    } else if(addDetailAcc.size()>0){
                        System.debug('Insiddddeeee else');
                        for(Address_Details__c addDetail : addDetailAcc){
                            if(addDetail.Type__c == 'Registered'){
                            	regAddress = addDetail;
                          }
                        	if(addDetail.Type__c == 'Operating'){
                            	opAddress = addDetail;
                          }
                        }
                    }
                /**To populate Address details in Service Agreement - END ***********/
                
                if(String.isNotBlank(oppObj.BusinessEntityName__c)){
                    businessEntityDetails = oppObj.BusinessEntityName__c;
                }
                
                if(String.isNotBlank(oppObj.Business_Category__c)){
                    businessCategoryDetails = oppObj.Business_Category__c;
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
                
                if(string.isNotBlank(oppObj.Fee_Model__c)) listFeeMaster = getFeeMasters(oppObj.Fee_Model__c);
                
                listCrossSell = getPayoutCrossSell(oppObj.Id); 
                if(!listCrossSell.isEmpty() && listCrossSell !=null){
                    Set<String> payoutCSIds = New Set<String>();
                    for(Cross_Sell__c eachCS : listCrossSell){
                        if(eachCS.Custom_Product__r.Name == 'Payout') payoutCSIds.add(eachCS.Id);
                    }
                    if(!payoutCSIds.isEmpty() && payoutCSIds != null){
                        listPayoutFeeMaster = getPayoutFeeMaster(payoutCSIds);
                    }
                    if(!listPayoutFeeMaster.isEmpty()){
                        for(Fee_Master__c eachFM : listPayoutFeeMaster){
                            List<pricingTableWrapper> pricingWrapperList = new List<pricingTableWrapper>();
                            if(String.isNotBlank(eachFM.Pricing_Configurator__c)){
                                Map<String, Object> pricingObjList = (Map<String, Object>)JSON.deserializeUntyped(eachFM.Pricing_Configurator__c);
                                system.debug('####### pricingObjList '+pricingObjList);
                                
                                for(string keyAmount : pricingObjList.keySet()){
                                    Map<String, Object> pricingObjValueMap = (Map<String, Object>)pricingObjList.get(keyAmount);
                                    if(pricingMap.containsKey(eachFM.Mode__c)){
                                        pricingWrapperList = pricingMap.get(eachFM.Mode__c);
                                        if(pricingObjValueMap.containsKey('percent'))
                                        	pricingWrapperList.add(new pricingTableWrapper(eachFM.Mode__c,keyAmount,'INR '+String.valueOf(pricingObjValueMap.get('percent'))));
                                        pricingMap.put(eachFM.Mode__c, pricingWrapperList);
                                        pricingCountMap.put(eachFM.Mode__c, pricingWrapperList.size());
                                    }else{
                                        if(pricingObjValueMap.containsKey('percent'))
                                        	pricingWrapperList.add(new pricingTableWrapper(eachFM.Mode__c,keyAmount,'INR '+String.valueOf(pricingObjValueMap.get('percent'))));
                                        pricingMap.put(eachFM.Mode__c, pricingWrapperList);
                                        
                                        //store count of rows per Module Name
                                        pricingCountMap.put(eachFM.Mode__c, pricingWrapperList.size());
                                    }
                                }
                            }
                        }
                        modeList = new List<String>(pricingMap.keySet());
                    }
                }
            }
        }        
    }
    
    //======== Get the Parent Opportunity record if exist ========================
    Private Static Opportunity getParentOpty(Id parentOptyId){
        return [SELECT Id, Website__c, Email__c,Fee_Model__c FROM Opportunity WHERE Id =: parentOptyId];
    }
    
    // ======= Get the Account record ===========================
    Private Static Account getAccountDetails(Id AccId){
        return [SELECT Id, Name, Legal_Name__c, BillingAddress, BillingStreet, BillingCity, BillingState, BillingCountry,Merchant_Trading_Name__c,
                BillingPostalCode, ShippingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, ParentId,BusinessCategoryName__c,
                Website, Business_Category__c, Business_Category__r.Name, Sub_Category__c, Sub_Category__r.Name, PAN_Number__c,Business_Entity__r.Name,PAN_Holder_Name__c,American_Express_cards__c,Diners_Credit_cards__c,LazyPay__c,Credit_card_EMIs__c,Debit_card_EMIs__c,Non_bank_EMIs__c,Wallets__c,Deferred_Payment_Solutions__c,
                (SELECT Id, Name, Email, MobilePhone, Phone,Fax,Designation__c, Type__c,Authorised_Signatory__c, Active__c 
                 FROM Contacts 
                 WHERE Type__c IN ('Secondary Contact' ,'Signing Authority')
                 OR Authorised_Signatory__c =: true),
                (SELECT Id, Name, Address_Line__c, Pincode__c, City__c, State__c, Country__c, Type__c,Opportunity__c
                 FROM Address_Details__r WHERE Active__c=true AND Type__c IN ('Registered', 'Operating'))
                FROM Account 
                WHERE Id =: AccId];
    }
    
   /* Private Static Opportunity getOppDetails(Id OpptyId){
        return [Select Id, Name, Active__c, Type__c, Address_Line__c, City__c, Pincode__c, State__c, Country__c, Setup_Operating_Address__c, ProductLabel__c, Opportunity__c
                FROM Address_Details__r WHERE Active__c=true AND Type__c IN ('Registered', 'Operating')
                FROM Opportunity WHERE Opportunity__c =: OpptyId]; 
    }*/
    
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
        return [SELECT Id, Name, Account_Number__c, Account_Holder_Name__c, Bank_Name__c, Branch_Address__c, IFSC_Code__c, Account_Type__c 
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
    
    private static List<Fee_Master__c> getFeeMasters(Id feeMasterId){
        return [Select Id, Name, Active__c,
                Amex__c,Credit_Card__c,Debit_Card_RuPay__c,
                Debit_Card_Transaction_less_than_2000__c,
                Debit_Card_Transaction_more_than_2000__c,Net_Banking__c,UPI__c,Wallets__c 
                FROM Fee_Master__c 
                WHERE Id =: feeMasterId AND Active__c = True 
                ORDER BY LastModifiedDate DESC Limit 1];
    }
    
    private static List<Cross_Sell__c> getPayoutCrossSell(Id oppId){
        return [Select Id,Custom_Product__c,Custom_Product__r.Name From Cross_Sell__c Where Opportunity__c=:oppId];
    }
    
    private static List<Fee_Master__c> getPayoutFeeMaster(Set<String> csIds){
        return [Select Id,Mode__c, Pricing_Configurator__c,Active__c,NEFT__c  from Fee_Master__c Where Cross_Sell__c IN: csIds AND Active__c=true];
    }
    
    public class pricingTableWrapper{
        public pricingTableWrapper(string mode,string range,string amount){
            this.mode = mode;
            //if(range != '0') this.priceRange = 'Greater Than '+range;
            //else this.priceRange = 'Any Amount';
            this.priceRange = range;
            this.amount = amount;
        }
        
        public String mode {get;set;}
        public String priceRange {get;set;}
        public String amount {get;set;}
    }
    
}