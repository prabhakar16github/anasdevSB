public class TestQueueableClass implements Queueable {
    public List<Account> accList ; 
    public TestQueueableClass(){
          
    }
    public void execute(QueueableContext context) {
        OpportunityTriggerHandler.sendSettlementStatusToBizTreasury(new Map<Id,String>{},new Map<id, double>{});
        OpportunityTriggerHandler.sendSettlementStatusToBizTreasury(new Map<Id,String>{},new Map<id, double>{});
        OpportunityTriggerHandler.sendSettlementStatusToBizTreasury(new Map<Id,String>{},new Map<id, double>{});
    }
}