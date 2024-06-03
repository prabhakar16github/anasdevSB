declare module "@salesforce/apex/CrossSellDocumentController.getMerchantDocumentRecords" {
  export default function getMerchantDocumentRecords(param: {SobjectId: any, SobjectName: any, crossSellId: any}): Promise<any>;
}
declare module "@salesforce/apex/CrossSellDocumentController.saveMerchantDocument" {
  export default function saveMerchantDocument(param: {strWrpDoc: any}): Promise<any>;
}
declare module "@salesforce/apex/CrossSellDocumentController.deleteMerchantDocument" {
  export default function deleteMerchantDocument(param: {merchantDocId: any}): Promise<any>;
}
declare module "@salesforce/apex/CrossSellDocumentController.getErrorSolutionMapping" {
  export default function getErrorSolutionMapping(param: {accountObj: any, docCateId: any}): Promise<any>;
}
declare module "@salesforce/apex/CrossSellDocumentController.getDocumentURL" {
  export default function getDocumentURL(param: {strDocumentId: any}): Promise<any>;
}
declare module "@salesforce/apex/CrossSellDocumentController.addNewRecordDoc" {
  export default function addNewRecordDoc(param: {strWrapperDocumentObj: any, crossSellId: any}): Promise<any>;
}
