public class FeedItemHelper {
    public static void feedCommentAfterInsertHandler(List<FeedComment> feedList){
        for(FeedComment f : feedList){
            SYstem.debug('f::::'+f);
        }
        Set<ID> pricingIDs = new Set<ID>();
        Map<ID,ID> mapCaseIDtoOwnerID = new Map<ID,ID>();     

        for(FeedComment FI : feedList) {
            pricingIDs.add(FI.ParentID);
        }
		System.debug('pricingIDs::::::'+pricingIDs);
        List<Id> oppId = new List<Id>();
        for(Pricing__c C : [SELECT ID,Opportunity__r.OwnerId from Pricing__c WHERE ID IN :pricingIDs]) {
            oppId.add(c.Opportunity__r.OwnerId);               
        }
        List<FeedItem> feedl = new List<FeedItem>();
        //for(FeedComment FI : feedList) {
             FeedItem fitem = new FeedItem();
                    fitem.type = 'Text';
                    fitem.ParentId = oppId[0];
                    fitem.Title = 'View';
        
        //}
        System.debug('feedl::::::'+feedl);

    }
    
}