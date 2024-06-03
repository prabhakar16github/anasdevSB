@isTest
public class Whatsapp_generateOptionIndexTracker {
    @isTest
    public static void testData1(){
        
        Test.startTest();
        Whatsapp_generateOptionIndex.MessagingInput input = new Whatsapp_generateOptionIndex.MessagingInput();
        input.OptionIndex = null;
        
        
        List<Whatsapp_generateOptionIndex.MessagingInput> listInput = new List<Whatsapp_generateOptionIndex.MessagingInput>();
        listInput.add(input);
        
        Whatsapp_generateOptionIndex.generateOptionIndex(listInput);
        
        test.StopTest();
    }
    @isTest
    public static void testData2(){
        
        Test.startTest();
        Whatsapp_generateOptionIndex.MessagingInput input = new Whatsapp_generateOptionIndex.MessagingInput();
        input.OptionIndex = '6';
        
        
        List<Whatsapp_generateOptionIndex.MessagingInput> listInput = new List<Whatsapp_generateOptionIndex.MessagingInput>();
        listInput.add(input);
        
        Whatsapp_generateOptionIndex.generateOptionIndex(listInput);
        
        test.StopTest();
    }

}