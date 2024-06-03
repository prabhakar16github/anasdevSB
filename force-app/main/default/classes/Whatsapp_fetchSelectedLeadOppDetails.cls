//Updated by Arka Patra
public class Whatsapp_fetchSelectedLeadOppDetails {
    
    public class MessagingInput {
        @InvocableVariable(required=false)
        public String selectedOption;
        
    }
    
    public class MessagingOutput{
        
        @InvocableVariable(required=true)
        public String sMid;
        
       // @InvocableVariable(required=true)
        //public string sProduct;
        
        @InvocableVariable(required=true)
        public string sfirstName;
        
        @InvocableVariable(required=true)
        public string sEmail;
    }
    
    @InvocableMethod(Label = 'Get selected MID details')
    public static List<MessagingOutput> getMIDDetails(List<MessagingInput> inputs){
        
        //MessagingInput input = new MessagingInput();
       // input.selectedOption = 'MID:713212, Email:arkapatra31@gmail.com';
      //  List<MessagingInput> inputs = new List<MessagingInput>();
      //  inputs.add(input);
        
        MessagingOutput Output = new MessagingOutput();
        List<MessagingOutput> outputList = new List<MessagingOutput>();
        String objectType = '';
        
        if(inputs != null && inputs.size() > 0){
            for(MessagingInput each : inputs){
                if(string.isNotBlank(each.selectedOption)){
                    string selectedOpt = each.selectedOption;
                    Output.sMid = selectedOpt.split(',')[0].split(':')[1];
                    
                    String parameterType = selectedOpt.split(',')[1].split(':')[0];
                    if(parameterType.trim() == 'Email')  objectType = 'Lead';
                    else  objectType = 'Opportunity';
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
                    //Leads =  GuestUserUtilityHelper.querySobject('Lead','Merchant_Id__c = '+ Mid + ' And IsConv = false order by lastmodifieddate desc limit 1');
                    Leads = [select Merchant_Id__c, ProductLabel__c, Display_Name__c, Email
                            from Lead
                            where Merchant_Id__c = :Mid];
                	else
                    Opps = GuestUserUtilityHelper.querySobject('Opportunity','Merchant_Id__c = '+ Mid +' order by lastmodifieddate desc limit 1');
  
                    if(Leads != null  && Leads.size() > 0){
                        Output.sMID = String.valueOf(Leads[0].Merchant_Id__c);
                        //Output.sProduct = Leads[0].ProductLabel__c;
                        Output.sfirstName = Leads[0].Display_Name__c;
                        Output.sEmail = Leads[0].Email;
                        //system.debug('Product: '+Output.sProduct);
                        system.debug('Name: '+Output.sfirstName);
                        system.debug('Email: '+Output.sEmail);
                    } 
                    else if(Opps != null && Opps.size() > 0) {
                        Output.sMID = String.valueOf(Opps[0].Merchant_Id__c);
                       // Output.sProduct =  Opps[0].ProductLabel__c;
                        Output.sfirstName = Opps[0].First_Name__c;
                        Output.sEmail = Opps[0].Email__c;
                    } 
                    outputList.add(Output);
                }
            
        }
        return outputList;
    }
    
   

}