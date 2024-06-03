public class UpdatePricingRemarksChatterController {
    public static void updateRemarks(List<Pricing__c> pricingList){
        Set<Id> pricingId = new Set<Id>();
        List<String> remarksValue = new List<String>();
        for(Pricing__c pri : pricingList){
            pricingId.add(pri.Id);
            if(pri.Remarks__c !=null){
                 remarksValue.add(pri.Remarks__c);
            }
        }
        if( remarksValue !=Null && remarksValue.size()>0){
            List<FeedItem> postList = [SELECT Id, ParentId, Body FROM FeedItem WHERE ParentId=:pricingId];
            List<FeedItem> feedItemList = new List<FeedItem>();
            for(Pricing__c pri : pricingList){
                if(pri.Remarks__c !=NULL){
                    FeedItem feed = new FeedItem();
                    feed.ParentId =pri.Id;
                    feed.Body = pri.Remarks__c; 
                    feed.Type='ContentPost';
                    feedItemList.add(feed);
                }
            }
            if(feedItemList!=null && feedItemList.size()>0){
                upsert feedItemList;
            }  
        }
    }
}