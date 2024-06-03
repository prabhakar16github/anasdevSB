declare module "@salesforce/apex/crossSellForMerchant_Controller.getCombinedData" {
  export default function getCombinedData(param: {currentRecId: any}): Promise<any>;
}
declare module "@salesforce/apex/crossSellForMerchant_Controller.createCrossSellForProduct" {
  export default function createCrossSellForProduct(param: {currentRecId: any}): Promise<any>;
}
declare module "@salesforce/apex/crossSellForMerchant_Controller.getCrossSellStatus" {
  export default function getCrossSellStatus(param: {sObjectName: any, field: any}): Promise<any>;
}
declare module "@salesforce/apex/crossSellForMerchant_Controller.updateCrossSellData" {
  export default function updateCrossSellData(param: {strWrap: any}): Promise<any>;
}
declare module "@salesforce/apex/crossSellForMerchant_Controller.fetchAttachments" {
  export default function fetchAttachments(param: {crossSellId: any}): Promise<any>;
}
declare module "@salesforce/apex/crossSellForMerchant_Controller.createNewMerchDocument" {
  export default function createNewMerchDocument(param: {crossSell: any}): Promise<any>;
}
declare module "@salesforce/apex/crossSellForMerchant_Controller.getMerchantDocList" {
  export default function getMerchantDocList(param: {parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/crossSellForMerchant_Controller.deleteMerchDocument" {
  export default function deleteMerchDocument(param: {mdRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/crossSellForMerchant_Controller.updateRiskStatusToReEvaluate" {
  export default function updateRiskStatusToReEvaluate(param: {crossSellId: any}): Promise<any>;
}
declare module "@salesforce/apex/crossSellForMerchant_Controller.createContract" {
  export default function createContract(param: {accObj: any, authContObj: any, isFinal: any, optyObj: any, contractType: any}): Promise<any>;
}
declare module "@salesforce/apex/crossSellForMerchant_Controller.createTaskForRiskTeam" {
  export default function createTaskForRiskTeam(param: {strWrap: any, productName: any, teamName: any}): Promise<any>;
}
declare module "@salesforce/apex/crossSellForMerchant_Controller.getMerchantAdminIdentifier" {
  export default function getMerchantAdminIdentifier(param: {currentRecId: any}): Promise<any>;
}
