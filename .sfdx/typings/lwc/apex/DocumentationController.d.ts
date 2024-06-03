declare module "@salesforce/apex/DocumentationController.getMerchantDocumentRecords" {
  export default function getMerchantDocumentRecords(param: {SobjectId: any, SobjectName: any}): Promise<any>;
}
declare module "@salesforce/apex/DocumentationController.saveMerchantDocument" {
  export default function saveMerchantDocument(param: {strWrpDoc: any}): Promise<any>;
}
declare module "@salesforce/apex/DocumentationController.deleteMerchantDocument" {
  export default function deleteMerchantDocument(param: {merchantDocId: any}): Promise<any>;
}
declare module "@salesforce/apex/DocumentationController.getErrorSolutionMapping" {
  export default function getErrorSolutionMapping(param: {accountObj: any, opportunityObj: any, docCateId: any}): Promise<any>;
}
declare module "@salesforce/apex/DocumentationController.getDocumentURL" {
  export default function getDocumentURL(param: {strDocumentId: any}): Promise<any>;
}
declare module "@salesforce/apex/DocumentationController.addNewRecordDoc" {
  export default function addNewRecordDoc(param: {strWrapperDocumentObj: any}): Promise<any>;
}
declare module "@salesforce/apex/DocumentationController.getContractLink" {
  export default function getContractLink(param: {strContDocuId: any}): Promise<any>;
}
declare module "@salesforce/apex/DocumentationController.getHistoryData" {
  export default function getHistoryData(param: {merchantDocId: any}): Promise<any>;
}
