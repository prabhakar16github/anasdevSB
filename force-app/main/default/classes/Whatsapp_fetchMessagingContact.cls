public class Whatsapp_fetchMessagingContact {
    
    public class MessagingInput {
        @InvocableVariable(required=false)
        public ID endUserID;
        
        @InvocableVariable(required=false)
        public String OptionIndex;
        
        
    }
    
    
    @InvocableMethod(label='Find Contact for Messaging User')
    public static List<List<String>> getUserName(List<MessagingInput> inputs) {
        
        Set<String> outputs = new Set<String>();
        List<List<String>> outputList = new List<List<String>>();
        Map<String,DateTime> dateMap = new Map<String,DateTime>();
        String output; 
        List<String> outputsList = new List<String>();
        List<String> convertedList = new List<String>();
        Integer optionIndex = 0;
        
        for (MessagingInput input : inputs) {
            
            //Output Params
            String name = 'Guest';
            String sObjectName = '';
            string mid = '';
            String leadMid = '';
            String leadName = '';
            string mobile = '';
            string panStatus = '';
            string bankStatus = '';   
            
            
            //Get the messaging end user record from the ID
            List<MessagingEndUser> messagingUsers = [SELECT Id, Name
                                                     FROM MessagingEndUser
                                                     WHERE Id = :input.endUserID
                                                     LIMIT 1];
            //Did we find the messaging user?
            if (!messagingUsers.isEmpty()) {
                String phoneNumber = messagingUsers[0].Name.split(':')[1];
                
                // Get the contact/lead/Opportunity based on the phone number
                system.debug('phoneNumber==='+phoneNumber);
                if(string.isNotBlank(phoneNumber))
                    mobile = phoneNumber.substring(3);
                
                
                
                if(input.OptionIndex != null )
                    if( Integer.valueOf(input.OptionIndex) > 0){
                    system.debug('input.OptionIndex=='+Integer.valueOf(input.OptionIndex));
                    optionIndex = Integer.valueOf(input.OptionIndex);
                }
                    
                
                
                List<Lead> Leads = GuestUserUtilityHelper.querySobject('Lead','mobilePhone = \''+ mobile + '\''+ ' And IsConverted = false order by lastmodifieddate desc limit 10');
                List<Opportunity> Opps = GuestUserUtilityHelper.querySobject('Opportunity','Mobile__c = \''+ mobile + '\''+'order by lastmodifieddate desc limit 10');
                
                
                //Arrange Leads and Opportunity in desc order
                if(!Leads.isEmpty() && Leads.size() >= 1 && !Opps.isEmpty() && Opps.size() >= 1){
                    system.debug('lead and opp both present');
                    for(integer i = 0 ; i < Leads.size() ; i++){
                        Lead eachLead = Leads[i];
                        for(integer j = 0 ;j < Opps.size() ; j++){
                            Opportunity eachOpp = Opps[j];
                            if(eachLead.lastmodifieddate > eachOpp.lastmodifieddate){
                                system.debug('lead createdDate id greater');
                                output = 'MID : '+String.valueOf(eachLead.Prod_Merchant_Id__c)+', Email : '+eachLead.Email;
                                outputs.add(output);
                                if(i == Leads.size() - 1){
                                    output = 'MID : '+String.valueOf(eachOpp.Prod_Merchant_Id__c)+', Name : '+String.valueof(eachOpp.Display_Name__c);
                                    outputs.add(output);
                                }
                            }
                            else if(eachLead.lastmodifieddate < eachOpp.lastmodifieddate){
                                system.debug('lead createdDate id lesser');
                                output = 'MID : '+String.valueOf(eachOpp.Prod_Merchant_Id__c)+', Name : '+String.valueof(eachOpp.Display_Name__c);
                                outputs.add(output);
                                if(j == Opps.size() - 1){
                                    output = 'MID : '+String.valueOf(eachLead.Prod_Merchant_Id__c)+', Email : '+eachLead.Email;
                                    outputs.add(output);
                                }
                            }
                            else{
                                output = 'MID : '+String.valueOf(eachLead.Prod_Merchant_Id__c)+', Email : '+eachLead.Email;
                                outputs.add(output);
                                output = 'MID : '+String.valueOf(eachOpp.Prod_Merchant_Id__c)+', Name : '+String.valueof(eachOpp.Display_Name__c);
                                outputs.add(output);
                            }
                            system.debug('output=='+output);
                        }
                    }
                }
                else if(Leads.isEmpty()  && !Opps.isEmpty() && Opps.size() >= 1){
                    for(opportunity eachOpp : Opps){
                        output = 'MID : '+String.valueOf(eachOpp.Prod_Merchant_Id__c)+', Name : '+String.valueof(eachOpp.Display_Name__c);
                        outputs.add(output);
                    }
                }
                else if(!Leads.isEmpty() && Leads.size() >= 1 && Opps.isEmpty()){
                    for(Lead eachLead : Leads){
                        output = 'MID : '+String.valueOf(eachLead.Prod_Merchant_Id__c)+', Email : '+eachLead.Email;
                        outputs.add(output);
                    }
                }
            }
            
            if(outputs != null && outputs.size() > 0){
                Integer optionSize = Integer.valueOf(system.label.OptionSize);
                if(outputs.size() <= optionSize ){
                    for(String str : outputs)  outputsList.add(str);
                }
                
                
                else if(outputs.size() > optionSize){
                    //convert set to List
                    for(String Str : outputs){
                        convertedList.add(Str);
                    }
                    //When there are more options than optionSize
                    //Check if options are displayed for first time or when none of these was selected
                    
                    //When none of these is selected
                    system.debug('optionIndex=='+optionIndex);
                    system.debug('convertedList=='+convertedList.size());
                    if(optionIndex != null && optionIndex >= 2*optionSize){
                        if(convertedList.size() >= optionIndex){
                            for(integer i=optionIndex - optionSize ; i < optionIndex ; i++)
                                outputsList.add(convertedList[i]);
                            outputsList.add('None of these');
                        }
                        else{
                            for(integer i=optionIndex - optionSize ; i < convertedList.size() ; i++)
                                outputsList.add(convertedList[i]);
                        }
                    }
                    
                    //When there are more than 'N' option show first N options
                    else {
                        for(integer i=0 ; i < optionSize ; i++)
                            outputsList.add(convertedList[i]);
                        outputsList.add('None of these');
                    }
                    
                    
                }
            }
            outputList.add(outputsList);  
        }
        return outputList;
    }
    
}