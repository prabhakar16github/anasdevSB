declare module "@salesforce/apex/WebsiteDocumentController.getMerchantDocumentRecords" {
  export default function getMerchantDocumentRecords(param: {SobjectId: any, SobjectName: any}): Promise<any>;
}
declare module "@salesforce/apex/WebsiteDocumentController.saveMerchantDocument" {
  export default function saveMerchantDocument(param: {strWrpDoc: any}): Promise<any>;
}
declare module "@salesforce/apex/WebsiteDocumentController.deleteMerchantDocument" {
  export default function deleteMerchantDocument(param: {merchantDocId: any}): Promise<any>;
}
declare module "@salesforce/apex/WebsiteDocumentController.getErrorSolutionMapping" {
  export default function getErrorSolutionMapping(param: {accountObj: any, docCateId: any}): Promise<any>;
}
declare module "@salesforce/apex/WebsiteDocumentController.getDocumentURL" {
  export default function getDocumentURL(param: {strDocumentId: any}): Promise<any>;
}
declare module "@salesforce/apex/WebsiteDocumentController.addNewRecordDoc" {
  export default function addNewRecordDoc(param: {strWrapperDocumentObj: any}): Promise<any>;
}
