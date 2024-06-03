global with sharing class SendEmailFlowAction {
    
    @InvocableMethod(label='Send Email Flow Action' description='Sends Email with options for attachments and templates')
    global static List<SendEmailResult> sendEmails(List<SendEmailRequest> requests) {
        List<SendEmailResult> results = new List<SendEmailResult>();

        for (SendEmailRequest ser : requests) {
            results.add(sendEmail(ser));
        }

        return results;
    }

    // this method actually sends the individual emails and logs the results back to the user
    private static SendEmailResult sendEmail(SendEmailRequest req) {
        SendEmailResult res = new SendEmailResult();
        res.errorMessages = new List<String>();

        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();

        // there needs to be a template, html, or plain body
        if (req.htmlBody == null && req.plainTextBody == null && req.templateId == null) {
            throw new SendEmailFlowActionException('Specify a value for Template ID, HTML Body, or Plain Text Body.');
        }

        try {

            // setting all the email settings from the flow
            emailMessage.setSenderDisplayName(req.senderDisplayName);
            emailMessage.setReplyTo(req.replyTo);

            emailMessage.setCharset(req.characterSet);
            emailMessage.setBccAddresses(req.bccAddresses);
            emailMessage.setBccSender(req.bccSender);
            emailMessage.setSaveAsActivity(req.saveAsActivity);

            if (req.templateId != null) {
                if (String.isBlank(req.templateId) == false) {
                    emailMessage.setTemplateID(req.templateId);
                } else {
                    throw new SendEmailFlowActionException('Incorrect ID entered = ' + req.templateId + '. Please include an Email Template ID or do not include that field in the Flow Configuration.');
                }
            }

            if (req.whatId != null) {
                if (String.isBlank(req.whatId) == false) {
                    emailMessage.setWhatId(req.whatId);
                } else {
                    throw new SendEmailFlowActionException('Incorrect ID entered = ' + req.whatId + '. Please include a What ID value or do not include in Flow Configuration.');
                }
            }

            if (req.inReplyToId != null) {
                if (String.isBlank(req.inReplyToId) == false) {
                    emailMessage.setInReplyTo(req.inReplyToId);
                } else {
                    throw new SendEmailFlowActionException('Incorrect ID entered = ' + req.inReplyToId + '. Please include an In Reply To ID value or do not include in Flow Configuration.');
                }
            }

            if (req.targetObjectId != null) {
                if (String.isBlank(req.targetObjectId) == false) {
                    emailMessage.setTargetObjectId(req.targetObjectId);
                } else {
                    throw new SendEmailFlowActionException('Incorrect ID entered = ' + req.targetObjectId + '. Please include a Target Object ID value or do not include in Flow Configuration.');
                }
            }

            if (req.orgWideEmailAddressId != null) {
                if (String.isBlank(req.orgWideEmailAddressId) == false) {
                    emailMessage.setOrgWideEmailAddressId(req.orgWideEmailAddressId);
                } else {
                    throw new SendEmailFlowActionException('Incorrect ID entered = ' + req.orgWideEmailAddressId + '. Please include an Org Wide Email Address ID value or do not include in Flow Configuration.');
                }
            }

            emailMessage.setToAddresses(req.toAddresses);
            emailMessage.setEntityAttachments(req.entityAttachmentIds);
            emailMessage.setCcAddresses(req.ccAddresses);
            emailMessage.setHtmlBody(req.htmlBody);
            emailMessage.setOptOutPolicy(req.emailOptOutPolicy);
            emailMessage.setPlainTextBody(req.plainTextBody);
            emailMessage.setReferences(req.references);
            emailMessage.setSubject(req.subject);
            emailMessage.setTreatBodiesAsTemplate(req.treatBodiesAsTemplate);
            emailMessage.setTreatTargetObjectAsRecipient(req.treatTargetObjectAsRecipient);

            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {emailMessage};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

            for (Messaging.SendEmailResult result : results) {
                res.isSuccess = result.isSuccess();
                for (Messaging.SendEmailError err : result.getErrors()) {
                    res.errorMessages.add(err.getStatusCode()+  '-> Object ID: ' + err.getTargetObjectId() + ', Fields: ' + err.getFields() + ', ErrorMessage: ' + err.getMessage());
                }

            }
        } catch (Exception ex) {
            res.isSuccess = false;
            res.errorMessages.add('Error when sending email -> ' + ex.getMessage());
        }

        return res;
    }

    // all Id fields are set as Strings so that we can provide better error messages than Salesforce Flow Debug messages
    // otherwise, the Id value being a bad value will fail before the apex action is called
    global class SendEmailRequest {
        @InvocableVariable(label='BCC Addresses' required=false description='A list of blind carbon copy (BCC) addresses or object IDs of the contacts, leads, and users you’re sending the email to.')
        global List<String> bccAddresses;

        @InvocableVariable(label='CC Addresses' required=false description='A list of carbon copy (CC) addresses or object IDs of the contacts, leads, and users you’re sending the email to.')
        global List<String> ccAddresses;

        @InvocableVariable(label='Character Set' required=false description='The character set for the email. If this value is null, the users default value is used.')
        global String characterSet;

        @InvocableVariable(label='Entity (Document, ContentVersion, Attachment) Attachment IDs' required=false description='Array of IDs of Document, ContentVersion, or Attachment items to attach to the email.')
        global List<String> entityAttachmentIds;

        @InvocableVariable(label='HTML Body' required=false description='The HTML version of the email, specified by the sender. The value is encoded according to the specification associated with the organization. Specify a value for setTemplateId, setHtmlBody, or setPlainTextBody.')
        global String htmlBody;

        @InvocableVariable(label='In Reply To EmailMessage Id' required=false description='Sets the optional In-Reply-To field of the outgoing email. This field identifies the email or emails to which this email is a reply (parent emails).')
        global String inReplyToId;

        @InvocableVariable(label='Email Opt Out Policy' required=false description='If you added recipients by ID instead of email address and the Email Opt Out option is set, this method determines the behavior of the sendEmail() call. If you add recipients by their email addresses, the opt-out settings for those recipients aren’t checked and those recipients always receive the email.')
        global String emailOptOutPolicy;

        @InvocableVariable(label='Plain Text Body' required=false description='The text version of the email, specified by the sender. Specify a value for setTemplateId, setHtmlBody, or setPlainTextBody. Or, you can define both setHtmlBody and setPlainTextBody.')
        global String plainTextBody;

        @InvocableVariable(label='Organization-wide Email Address ID' required=false description='The ID of the organization-wide email address associated with the outgoing email. The objects DisplayName field cannot be set if the setSenderDisplayName field is already set.')
        global String orgWideEmailAddressId;

        @InvocableVariable(label='References (Identifies an email thread)' required=false description='The References field of the outgoing email. Identifies an email thread. Contains the parent emails References and message IDs, and possibly the In-Reply-To fields.')
        global String references;

        @InvocableVariable(label='Subject' required=false description='The email subject line. If you are using an email template, the subject line of the template overrides this value.')
        global String subject;

        @InvocableVariable(label='Target Object ID (Lead, Contact, or User IDs needed)' required=false description='Required if using a template, optional otherwise. The ID of the contact, lead, or user to which the email will be sent. The ID you specify sets the context and ensures that merge fields in the template contain the correct data.')
        global String targetObjectId;

        @InvocableVariable(label='Email Template ID' required=false description='Required if using a template, optional otherwise. The ID of the template used to create the email.')
        global String templateId;

        @InvocableVariable(label='To Addresses List' required=false description='A list of email addresses or object IDs of the contacts, leads, and users you’re sending the email to.')
        global List<String> toAddresses;

        @InvocableVariable(label='Treat Bodies as Template?' required=false)
        global Boolean treatBodiesAsTemplate = false;

        @InvocableVariable(label='Treat Target Object As Recipient?' required=false)
        global Boolean treatTargetObjectAsRecipient = true;

        @InvocableVariable(label='What ID (For scenarios like merge fields in templates)' required=false description='If you specify a contact for the targetObjectId field, you can specify an optional whatId as well. This helps to further ensure that merge fields in the template contain the correct data.')
        global String whatId;

        @InvocableVariable(label='BCC Sender Receives Copy?' required=false description='Indicates whether the email sender receives a copy of the email that is sent.')
        global Boolean bccSender = false;

        @InvocableVariable(label='Reply To Address' required=false description='The email address that receives the message when a recipient replies.')
        global String replyTo;

        @InvocableVariable(label='Save As Activity?' required=false description='The default value is true, meaning the email is saved as an activity. This argument only applies if the recipient list is based on targetObjectId or targetObjectIds. If HTML email tracking is enabled for the organization, you will be able to track open rates.')
        global Boolean saveAsActivity = true;

        @InvocableVariable(label='Sender Display Name (Name that appears on the "From" line of the email)' required=false description='The name that appears on the From line of the email. This cannot be set if the object associated with a setOrgWideEmailAddressId for a SingleEmailMessage has defined its DisplayName field.')
        global String senderDisplayName;

        @InvocableVariable(label='Use Signature? (Configure in sending User Settings)' required=false description='Indicates whether the email includes an email signature if the user has one configured. The default is true, meaning if the user has a signature it is included in the email unless you specify false.')
        global Boolean useSignature = true;
    }

    global class SendEmailResult {
        @InvocableVariable
        global Boolean isSuccess;

        @InvocableVariable
        global List<String> errorMessages;
    }

    global class SendEmailFlowActionException extends Exception {}
}