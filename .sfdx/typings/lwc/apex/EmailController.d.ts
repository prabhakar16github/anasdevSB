declare module "@salesforce/apex/EmailController.sendEmail" {
  export default function sendEmail(param: {recipient: any, subject: any, body: any, attachmentId: any}): Promise<any>;
}
