declare module "@salesforce/apex/CrossSellEmailtoRiskUser.sendEmailtoRiskTeam" {
  export default function sendEmailtoRiskTeam(param: {csToUpdate: any}): Promise<any>;
}
declare module "@salesforce/apex/CrossSellEmailtoRiskUser.getCrossSellSelectedRec" {
  export default function getCrossSellSelectedRec(param: {selectedIds: any}): Promise<any>;
}
declare module "@salesforce/apex/CrossSellEmailtoRiskUser.uploadDocToS3" {
  export default function uploadDocToS3(param: {fileName: any, base64Data: any, contentType: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CrossSellEmailtoRiskUser.getMerchantDocList" {
  export default function getMerchantDocList(param: {parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/CrossSellEmailtoRiskUser.getselectOptions" {
  export default function getselectOptions(param: {objectStr: any, fld: any}): Promise<any>;
}
declare module "@salesforce/apex/CrossSellEmailtoRiskUser.createNewMerchDocument" {
  export default function createNewMerchDocument(param: {crossSell: any}): Promise<any>;
}
declare module "@salesforce/apex/CrossSellEmailtoRiskUser.deleteMerchDocument" {
  export default function deleteMerchDocument(param: {mdRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CrossSellEmailtoRiskUser.getUserIdentity" {
  export default function getUserIdentity(param: {emailId: any}): Promise<any>;
}
declare module "@salesforce/apex/CrossSellEmailtoRiskUser.fetchCrossSell" {
  export default function fetchCrossSell(): Promise<any>;
}
declare module "@salesforce/apex/CrossSellEmailtoRiskUser.saveCrossSell" {
  export default function saveCrossSell(param: {lstCrossSell: any, userORmanager: any, riskUserORmanagerId: any}): Promise<any>;
}
declare module "@salesforce/apex/CrossSellEmailtoRiskUser.getselectOptions" {
  export default function getselectOptions(param: {objectType: any, fld: any}): Promise<any>;
}
declare module "@salesforce/apex/CrossSellEmailtoRiskUser.saveTheFile" {
  export default function saveTheFile(param: {parentId: any, fileName: any, base64Data: any, contentType: any, crossSellRecord: any}): Promise<any>;
}
