public with sharing class LeadConvertBatchIdQueryBasic implements Database.Batchable<String>, Database.AllowsCallouts, Database.stateful {
    public String data;
    public String type;
    public List<String> convertedIds;

    public LeadConvertBatchIdQueryBasic(String data, String type) {
        this.data = data;
        this.type = type;
    }

    public List<String> start(Database.BatchableContext BC){
        if(this.type == 'ids') {
            return this.data.split(',');
        }
        return null;
    }

    public void execute(Database.BatchableContext BC, List<String> scope){
        if(this.convertedIds == null) this.convertedIds = new List<String>();
        for(String recid : scope) {
            try {
                LeadTriggerHandler.convertLead(recid);
            } catch (Exception e) {
                System.debug(e.getMessage());
                throw e;
            }
            this.convertedIds.add(recid);
        }
    }

    public void finish(Database.BatchableContext BC){

    }
}