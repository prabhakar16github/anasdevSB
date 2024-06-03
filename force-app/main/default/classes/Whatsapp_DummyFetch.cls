// Created by Arka Patra.

public class Whatsapp_DummyFetch {
    
    public class WhatsappDummyOutput {
        @InvocableVariable(required=true)
        public String sWhatsapp;
        @InvocableVariable(required=true)
        public String sName;
        @InvocableVariable(required=true)
        public String sMID;
    }
    
    @InvocableMethod(label='Dummy Whatsapp')
    public static List<WhatsappDummyOutput> dummyWapp(){
        List<WhatsappDummyOutput> outputs = new List<WhatsappDummyOutput>();
        String wapp = '8583860292';
        String name = 'Stranger';
        String mid = '';
        List<Lead> leads = [SELECT Name, Prod_Merchant_Id__c
                                 FROM Lead
                                 WHERE MobilePhone = :wapp];
        system.debug('Leads : '+leads.size());
        if(!leads.isEmpty()){
		   for(integer i=0; i<leads.size(); i++){
                    WhatsappDummyOutput output = new WhatsappDummyOutput();
               		name = leads[i].Name;
               		mid = String.valueOf(leads[i].Prod_Merchant_Id__c);
                    system.debug('Name : '+name);
                    system.debug('Mid_'+(i+1)+' : '+mid);
                    output.sWhatsapp = wapp;
       				output.sName = name;
               		output.sMID = mid;
               		outputs.add(output);
                } 
        }
        return outputs;
    }
}