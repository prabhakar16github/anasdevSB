// Created by Arka Patra.

public class WhatsappBot_FetchMIDfor1 {
    
    public class MessagingInput {
        @InvocableVariable(required=true)
        public List<string> profileOptions;
    }
    
    public class MessagingOutput {
        @InvocableVariable(required=true)
        public string sMid;
        
        @InvocableVariable
        public string sProduct;
        
        @InvocableVariable
        public string sfirstName;
        
        @InvocableVariable(required=true)
        public string sEmail;
    }

    @InvocableMethod(label='Get Single MID Details')
    public static List<MessagingOutput> getSingleMID(List<MessagingInput> inputs){
        system.debug('inputs : '+inputs);
        MessagingOutput Output = new MessagingOutput();
        List<MessagingOutput> outputList = new List<MessagingOutput>();
        String objectType = '';
        
        //if(inputs != null && inputs.size() > 0){
            for(MessagingInput each : inputs){
                if(each.profileOptions.size()==1){
                    system.debug('profileOptions : '+each.profileOptions);
        			string selectedOpt = each.profileOptions[0];
                    system.debug('selectedOpt : '+selectedOpt);
                    Output.sMid = selectedOpt.split(',')[0].split(':')[1];
                    
                    String parameterType = selectedOpt.split(',')[1].split(':')[0];
                    if(parameterType.trim() == 'Email')  objectType = 'Lead';
                    else  objectType = 'Opportunity';
                }
                else{
                    system.debug('This method only works on phone numbers with 1 MID');
                }
            }
            
            if(Output != null)
            if(Output.sMid != null && String.isNotBlank(objectType)){
                string midStr = Output.sMid.trim();
                system.debug('midStr=='+midStr);
                Integer Mid = Integer.valueOf(midStr) ;
                system.debug('Mid=='+Mid);
                List<Lead> Leads = new List<Lead>();
                List<Opportunity> Opps = new List<Opportunity>();
                
                if(objectType == 'Lead')
                    Leads =   GuestUserUtilityHelper.querySobject('Lead','Prod_Merchant_Id__c = '+ Mid + ' And IsConverted = false order by lastmodifieddate desc limit 1');
                else
                    Opps = GuestUserUtilityHelper.querySobject('Opportunity','Prod_Merchant_Id__c = '+ Mid +' order by lastmodifieddate desc limit 1');
                
                if(Leads != null  && Leads.size() > 0){
                    Output.sMID = String.valueOf(Leads[0].Prod_Merchant_Id__c);
                    Output.sProduct = Leads[0].ProductLabel__c;
                    Output.sfirstName = Leads[0].Display_Name__c;
                    Output.sEmail = Leads[0].Email;
                } 
                else if(Opps != null && Opps.size() > 0) {
                    Output.sMID = String.valueOf(Opps[0].Prod_Merchant_Id__c);
                    Output.sProduct =  Opps[0].ProductLabel__c;
                    Output.sfirstName = Opps[0].First_Name__c;
                    Output.sEmail = Opps[0].Email__c;
                } 
                outputList.add(Output);
            }
   
        system.debug('###'+outputList);
    	return outputList;
    }
}