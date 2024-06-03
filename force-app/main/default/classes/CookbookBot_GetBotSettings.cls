public with sharing class CookbookBot_GetBotSettings {
    
    public class BotSettingOutput{
        @InvocableVariable(required=true)
        public String sLiveChatTranscriptId;
        @InvocableVariable(required=true)
        public String sOrgId;
        @InvocableVariable(required=true)
        public String sLiveChatDeploymentId;
        @InvocableVariable(required=true)
        public String sLiveChatButtonId;
        @InvocableVariable(required=true)
        public String sLiveChatButtonForTransferId;
        @InvocableVariable(required=true)
        public Boolean bInitialAgentTranserAvailability;
    }
    
    public class BotSettingInput{
        @InvocableVariable(required=true)
        public String sLiveAgentSessionId;
    }
    
    @InvocableMethod(label='Get Bot Settings')
    public static List<BotSettingOutput> getBotSettings(List<BotSettingInput> inputParameters){        
        List<BotSettingOutput> outputParameters = new List<BotSettingOutput>();
        
        BotSettingOutput outputParameter = new BotSettingOutput();    
        outputParameter.sOrgId = UserInfo.getOrganizationId();
        //by default, set agent transfer availablity to true if the transfer button to pull status hasn't been set up.
        outputParameter.bInitialAgentTranserAvailability = true;
        outputParameter.sLiveChatTranscriptId = '';
        outputParameter.sLiveChatDeploymentId = '';
        outputParameter.sLiveChatButtonId = '';
        outputParameter.sLiveChatButtonForTransferId = '';    
        outputParameters.add(outputParameter);  
        String sLiveAgentSessionId = inputParameters[0].sLiveAgentSessionId;
        List<LiveChatTranscript> liveChatTranscripts = [Select Id, LiveChatButtonId, LiveChatDeploymentId From LiveChatTranscript Where ChatKey = :sLiveAgentSessionId Order By CreatedDate Desc];
        if (liveChatTranscripts.size()>0)
        {
            System.debug('liveChatTranscripts '+liveChatTranscripts);
            LiveChatTranscript liveChatTranscript = liveChatTranscripts[0];
            outputParameter.sLiveChatTranscriptId = liveChatTranscript.Id;
            outputParameter.sLiveChatDeploymentId = liveChatTranscript.LiveChatDeploymentId;
            outputParameter.sLiveChatButtonId = liveChatTranscript.LiveChatButtonId;
            List<LiveChatButton> chatButtons = [Select Id, DeveloperName From LiveChatButton Where Id = :outputParameter.sLiveChatButtonId];
            System.debug('chatButtons '+chatButtons);
            if (chatButtons.size()>0){
                CookbookBot_Button__mdt[] chatButtonsMDT = [SELECT MasterLabel, DeveloperName, AgentAvailabilityButton__c FROM CookbookBot_Button__mdt];
                Map<String, String> chatButtonAgentAvailabilityMap = new Map<String, String>();
                for (CookbookBot_Button__mdt chatButtonMDT : chatButtonsMDT) {
                    chatButtonAgentAvailabilityMap.put(chatButtonMDT.DeveloperName, chatButtonMDT.AgentAvailabilityButton__c);
                }
                String sLiveChatButtonForTransferName = chatButtonAgentAvailabilityMap.get(chatButtons[0].Id + '/' +
                                                                                          chatButtons[0].DeveloperName + '_for_Transfer');
                System.debug('chatButtonAgentAvailabilityMap '+chatButtonAgentAvailabilityMap);
                if (sLiveChatButtonForTransferName != null && sLiveChatButtonForTransferName != '')
                {
                    List<LiveChatButton> chatButtonForTransfers = [Select Id From LiveChatButton Where DeveloperName = :sLiveChatButtonForTransferName];
                    if (chatButtonForTransfers.size()>0)
                    {
                        outputParameter.sLiveChatButtonForTransferId = chatButtonForTransfers[0].Id;
                        outputParameter.bInitialAgentTranserAvailability = CookbookBot_REST_Utils.getButtonAvailabilityForTransfer(outputParameter.sOrgId, outputParameter.sLiveChatDeploymentId, outputParameter.sLiveChatButtonForTransferId);
                    }
                }
            }
        }
        System.debug('outputParameters '+outputParameters);
        return outputParameters;
    }      
}