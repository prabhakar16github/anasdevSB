declare module "@salesforce/apex/SendAgreementController.getOpportunityRecord" {
  export default function getOpportunityRecord(param: {oppId: any, isFinal: any}): Promise<any>;
}
declare module "@salesforce/apex/SendAgreementController.createContract" {
  export default function createContract(param: {accObj: any, authContObj: any, isFinal: any, optyObj: any, contractType: any}): Promise<any>;
}
declare module "@salesforce/apex/SendAgreementController.sendMailWithAttachment" {
  export default function sendMailWithAttachment(param: {optyObj: any, contObj: any, strSelectedDocMaster: any, uploadedDocumentId: any, isFinal: any, contractObject: any, ContractType: any, isSendMail: any, objCounterSign: any}): Promise<any>;
}
declare module "@salesforce/apex/SendAgreementController.insertAttachmentonOpp" {
  export default function insertAttachmentonOpp(param: {parentId: any, fileId: any, fileName: any, base64Data: any, contentType: any}): Promise<any>;
}
declare module "@salesforce/apex/SendAgreementController.insertContractAndSendToESB" {
  export default function insertContractAndSendToESB(param: {fileId: any, isSendMail: any, contObj: any, wrapperdata: any, kycdocType: any, docTypeId: any, docTypeName: any, isFinal: any}): Promise<any>;
}
