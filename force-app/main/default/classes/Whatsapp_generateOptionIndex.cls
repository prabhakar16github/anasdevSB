public with sharing class Whatsapp_generateOptionIndex {
    
    public class MessagingInput {
        @InvocableVariable(required=false)
        public String OptionIndex;
        
    }
    
    public class MessagingOutput{
        @InvocableVariable(required=false)
        public String OptIndex;
    }
    
    @InvocableMethod(label='Generate Option Index')
    public static List<MessagingOutput> generateOptionIndex(List<MessagingInput> inputs) {

        MessagingOutput output = new MessagingOutput();
        List<MessagingOutput> outputList = new List<MessagingOutput>();
        Integer OptIndex = Integer.Valueof(system.label.OptionSize);
        
        for(MessagingInput each : inputs){
            if(each.OptionIndex != null)
            {
                Integer Index = Integer.valueof(each.OptionIndex);
            	OptIndex = Index > 0 ? Index + Integer.Valueof(system.label.OptionSize) : 2 * Integer.Valueof(system.label.OptionSize); 
            }
            else{
                OptIndex = 2* Integer.Valueof(system.label.OptionSize);
            }
            }
        
        system.debug('OptIndex='+OptIndex);
        output.OptIndex = String.valueof(OptIndex);
        outputList.add(output);
        
        return outputList;
    }
    

}