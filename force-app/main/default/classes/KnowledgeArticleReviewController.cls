public without sharing class KnowledgeArticleReviewController {
    
    @AuraEnabled
    public static string submitReview(Id knowledgeId, String rating, String review){
        String response;
        try {
            Knowledge_Article_Review__c kar = new Knowledge_Article_Review__c();
            kar.Knowledge_Article__c = knowledgeId;
            kar.Rating__c = rating;
            kar.Review__c = review;
            kar.User__c = UserInfo.getUserId();

            insert kar;
            response = 'success';

        } catch (Exception e) {
            response = e.getMessage();
        }

        return response;
    }
}