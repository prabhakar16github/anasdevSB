public with sharing class EmailController {
    @AuraEnabled(cacheable=false)
    public static void sendEmail(String recipient, String subject, String body, String attachmentId) {
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        if (!String.isBlank(attachmentId)) {
            attachments.add(getAttachment(attachmentId));
        }

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { recipient });
        email.setSubject(subject);
        email.setHtmlBody(body);
        email.setFileAttachments(attachments);

        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        if (!results[0].isSuccess()) {
            String errorMessage = results[0].getErrors()[0].getMessage();
            throw new AuraHandledException(errorMessage);
        }
    }

    private static Messaging.EmailFileAttachment getAttachment(String attachmentId) {
        Attachment attachment = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE Id = :attachmentId];
        Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
        emailAttachment.setFileName(attachment.Name);
        emailAttachment.setContentType(attachment.ContentType);
        emailAttachment.setBody(attachment.Body);
        return emailAttachment;
    }
}