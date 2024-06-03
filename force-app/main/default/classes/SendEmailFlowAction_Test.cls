@isTest
private class SendEmailFlowAction_Test {

    @isTest static void testSimpleEmail() {
        String testEmailTo = 'test@test.com';
        SendEmailFlowAction.SendEmailRequest req = new SendEmailFlowAction.SendEmailRequest();
        req.toAddresses = new List<String>{testEmailTo};
        req.plainTextBody = 'test body';

        Test.startTest();
        List<SendEmailFlowAction.SendEmailResult> results = SendEmailFlowAction.sendEmails(new List<SendEmailFlowAction.SendEmailRequest>{req});
        Test.stopTest();

        List<EmailMessage> emailMessages = [SELECT Id FROM EmailMessage WHERE ToAddress =: testEmailTo];
        System.assertEquals(1, emailMessages.size());

        for (SendEmailFlowAction.SendEmailResult res : results) {
            System.assertEquals(res.isSuccess, true);
        }
    }

    @isTest static void testSimpleEmailExceptionNoToAddress() {
        SendEmailFlowAction.SendEmailRequest req = new SendEmailFlowAction.SendEmailRequest();

        Test.startTest();
        try {
            List<SendEmailFlowAction.SendEmailResult> results = SendEmailFlowAction.sendEmails(new List<SendEmailFlowAction.SendEmailRequest>{req});
        } catch (SendEmailFlowAction.SendEmailFlowActionException e) {
            System.assertNotEquals(null, e.getMessage());
        }

        Test.stopTest();
    }

    @isTest static void testEmailNoValueForTemplateID() {
        SendEmailFlowAction.SendEmailRequest req = new SendEmailFlowAction.SendEmailRequest();
        req.templateId = ' ';

        Test.startTest();
        try {
            List<SendEmailFlowAction.SendEmailResult> results = SendEmailFlowAction.sendEmails(new List<SendEmailFlowAction.SendEmailRequest>{req});
        } catch (SendEmailFlowAction.SendEmailFlowActionException e) {
            System.assertNotEquals(null, e.getMessage());
        }

        Test.stopTest();
    }

    @isTest static void testEmailNoValueForWhatID() {
        SendEmailFlowAction.SendEmailRequest req = new SendEmailFlowAction.SendEmailRequest();
        req.whatId = ' ';

        Test.startTest();
        try {
            List<SendEmailFlowAction.SendEmailResult> results = SendEmailFlowAction.sendEmails(new List<SendEmailFlowAction.SendEmailRequest>{req});
        } catch (SendEmailFlowAction.SendEmailFlowActionException e) {
            System.assertNotEquals(null, e.getMessage());
        }

        Test.stopTest();
    }

    @isTest static void testEmailNoValueForOrgWideEmailAddressID() {
        SendEmailFlowAction.SendEmailRequest req = new SendEmailFlowAction.SendEmailRequest();
        req.orgWideEmailAddressId = ' ';

        Test.startTest();
        try {
            List<SendEmailFlowAction.SendEmailResult> results = SendEmailFlowAction.sendEmails(new List<SendEmailFlowAction.SendEmailRequest>{req});
        } catch (SendEmailFlowAction.SendEmailFlowActionException e) {
            System.assertNotEquals(null, e.getMessage());
        }

        Test.stopTest();
    }

    @isTest static void testEmailNoValueForInReplyToID() {
        SendEmailFlowAction.SendEmailRequest req = new SendEmailFlowAction.SendEmailRequest();
        req.inReplyToId = ' ';

        Test.startTest();
        try {
            List<SendEmailFlowAction.SendEmailResult> results = SendEmailFlowAction.sendEmails(new List<SendEmailFlowAction.SendEmailRequest>{req});
        } catch (SendEmailFlowAction.SendEmailFlowActionException e) {
            System.assertNotEquals(null, e.getMessage());
        }

        Test.stopTest();
    }

    @isTest static void testEmailNoValueForTargetObjectID() {
        SendEmailFlowAction.SendEmailRequest req = new SendEmailFlowAction.SendEmailRequest();
        req.targetObjectId = ' ';

        Test.startTest();
        try {
            List<SendEmailFlowAction.SendEmailResult> results = SendEmailFlowAction.sendEmails(new List<SendEmailFlowAction.SendEmailRequest>{req});
        } catch (SendEmailFlowAction.SendEmailFlowActionException e) {
            System.assertNotEquals(null, e.getMessage());
        }

        Test.stopTest();
    }
}