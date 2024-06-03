// Created by Arka Patra

public class Whatsapp_Fetch1 {
    
    @InvocableMethod(label='Dummy Whatsapp 1')
    public static List<List<String>> dummyWapp1(){
        //List<WhatsappDummyOutput> outputs = new List<WhatsappDummyOutput>();
        //Set<String> outputs = new Set<String>();
        List<List<String>> outputList = new List<List<String>>();
        //Map<String,DateTime> dateMap = new Map<String,DateTime>();
        String output; 
        List<String> outputs = new List<String>();
        //List<String> convertedList = new List<String>();
        //Integer optionIndex = 0;
        
        String name = 'Guest';
        String sObjectName = '';
        string mid = '';
        String leadMid = '';
        String leadName = '';
        String wapp = '6100000001';
        string panStatus = '';
        string bankStatus = ''; 
		
        
        List<Lead> leads = [SELECT Email, Name, Prod_Merchant_Id__c, lastmodifieddate
                                 FROM Lead
                                 WHERE MobilePhone = :wapp];
        
        List<Opportunity> opps = [SELECT Display_Name__c, Prod_Merchant_Id__c,lastmodifieddate
                                  FROM Opportunity
                                  WHERE Mobile__c = :wapp];
        
        
        system.debug('Leads : '+leads.size()+' Opps : '+opps.size());        
                
        //Arrange Leads and Opportunity in desc order
        if(!Leads.isEmpty() && Leads.size() >= 1 && !Opps.isEmpty() && Opps.size() >= 1){
            system.debug('lead and opp both present');
            for(integer i = 0 ; i < Leads.size() ; i++){
                Lead eachLead = Leads[i];
                for(integer j = 0 ;j < Opps.size() ; j++){
                    Opportunity eachOpp = Opps[j];
                    if(eachLead.lastmodifieddate > eachOpp.lastmodifieddate){
                        system.debug('lead createdDate id greater');
                        output = 'MID : '+String.valueOf(eachLead.Prod_Merchant_Id__c)+', Email : '+eachLead.Email+', Name : '+eachLead.Name;
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
                            output = 'MID : '+String.valueOf(eachLead.Prod_Merchant_Id__c)+', Email : '+eachLead.Email+', Name : '+eachLead.Name;
                            outputs.add(output);
                        }
                    }
                    else{
                        output = 'MID : '+String.valueOf(eachLead.Prod_Merchant_Id__c)+', Email : '+eachLead.Email+', Name : '+eachLead.Name;
                        outputs.add(output);
                        output = 'MID : '+String.valueOf(eachOpp.Prod_Merchant_Id__c)+', Name : '+String.valueof(eachOpp.Display_Name__c);
                        outputs.add(output);
                    }
                    system.debug('output=='+output);
                }
            }
        }
        else if(Leads.isEmpty()  && !Opps.isEmpty() && Opps.size() >= 1){
            system.debug('opps only');
            for(opportunity eachOpp : Opps){
                output = 'MID : '+String.valueOf(eachOpp.Prod_Merchant_Id__c)+', Name : '+String.valueof(eachOpp.Display_Name__c);
                outputs.add(output);
            }
        }
        else if(!Leads.isEmpty() && Leads.size() >= 1 && Opps.isEmpty()){
            system.debug('leads only');
            for(Lead eachLead : Leads){
                output = 'MID : '+String.valueOf(eachLead.Prod_Merchant_Id__c)+', Email : '+eachLead.Email+', Name : '+eachLead.Name;
                outputs.add(output);
            }
        }
        
        system.debug('Outputs : '+outputs);
        outputList.add(outputs);
        
   		return outputList;
    }
}