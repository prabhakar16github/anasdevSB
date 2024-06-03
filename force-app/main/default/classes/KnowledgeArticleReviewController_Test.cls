@isTest
public class KnowledgeArticleReviewController_Test {
    
    @testSetup static void setupCommonData(){        
        Knowledge__kav knowledgeArticleObj = New Knowledge__kav();
        knowledgeArticleObj.Title = 'Test';
        knowledgeArticleObj.UrlName = 'Test1';
        insert knowledgeArticleObj;
    }
    
    @isTest
    public static void testMethod1(){       
        Id KnowledgeId = [Select Id From Knowledge__kav Where Title = 'Test' Limit 1].Id;
        
        Test.startTest();
        KnowledgeArticleReviewController.submitReview(KnowledgeId,'5', 'Testing');
        Test.stopTest();
        
        List<Knowledge_Article_Review__c> karList = [SELECT Id From Knowledge_Article_Review__c];
        System.assertEquals(1, karList.size());
        
    }   
    
}