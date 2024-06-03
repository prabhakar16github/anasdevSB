public with sharing class CookbookBot_CheckAgentAvailability {
    
    public class AgentAvailabilityOutput{
        @InvocableVariable(required=true)
        public Boolean bAgentTranserAvailability;
    }
    
    public class AgentAvailabilityInput{
        @InvocableVariable(required=true)
        public String sLiveAgentSessionId;
    }
    
    @InvocableMethod(label='Check Agent Availablity')
    public static List<AgentAvailabilityOutput> checkAgentAvailability(List<AgentAvailabilityInput> inputParameters){  
        
        List<AgentAvailabilityOutput> outputParameters = new List<AgentAvailabilityOutput>();        
        AgentAvailabilityOutput outputParameter = new AgentAvailabilityOutput();
        
        //by default, set agent transfer availablity to true if the transfer button to pull status hasn't been set up.
        outputParameter.bAgentTranserAvailability = true;
        outputParameters.add(outputParameter);  
        
        String sOrgId = UserInfo.getOrganizationId();
        String sLiveAgentSessionId = inputParameters[0]?.sLiveAgentSessionId;
        List<LiveChatTranscript> liveChatTranscripts = [Select Id, LiveChatButtonId, LiveChatDeploymentId From LiveChatTranscript Where ChatKey = :sLiveAgentSessionId Order By CreatedDate Desc];
        String sLiveChatDeploymentId = (liveChatTranscripts.size() > 0) ? liveChatTranscripts[0]?.LiveChatDeploymentId : null;
        
        List<LiveChatButton> chatButtonForTransfers = [Select Id From LiveChatButton Where DeveloperName = 'CookbookBot_for_Transfer'];
        String sLiveChatButtonForTransferId = (chatButtonForTransfers.size() > 0) ? chatButtonForTransfers[0]?.Id : null;
        
        if (sOrgId != null && sOrgId !='' && sLiveChatDeploymentId != null && sLiveChatDeploymentId != ''
            && sLiveChatButtonForTransferId != null && sLiveChatButtonForTransferId != '')
        {
            outputParameter.bAgentTranserAvailability = CookbookBot_REST_Utils.getButtonAvailabilityForTransfer(sOrgId, sLiveChatDeploymentId, sLiveChatButtonForTransferId);
        }
        
        return outputParameters;
    }      
}