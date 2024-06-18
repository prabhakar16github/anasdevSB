declare module "@salesforce/apex/TDRScreenController.getCommercials" {
  export default function getCommercials(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.getCommercialRecords" {
  export default function getCommercialRecords(param: {oppId: any, getPayments: any, commercialId: any}): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.getRequiredData" {
  export default function getRequiredData(param: {commercialId: any, planId: any, planType: any, oppId: any, mdrTsfMasterExists: any}): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.getPartners" {
  export default function getPartners(): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.getPlans" {
  export default function getPlans(param: {planType: any, planId: any, oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.getRackRatePlans" {
  export default function getRackRatePlans(param: {planType: any, oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.deleteTDRList" {
  export default function deleteTDRList(param: {tdrToDelete: any}): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.getMPOData" {
  export default function getMPOData(param: {oppId: any, planId: any}): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.getMdrTSFMasterData" {
  export default function getMdrTSFMasterData(): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.getMcpData" {
  export default function getMcpData(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.getCreateCommData" {
  export default function getCreateCommData(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.getNewTDRData" {
  export default function getNewTDRData(param: {planId: any, mdrTsfMasterExists: any, commercialId: any, oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.deleteCommercial" {
  export default function deleteCommercial(param: {theCommercial: any}): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.upsertMcpData" {
  export default function upsertMcpData(param: {mcpInsertData: any, mcpUpdateData: any, mcpDeleteData: any}): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.insertCommercialData" {
  export default function insertCommercialData(param: {theCommercial: any, isPlanChanged: any, ppoToDelete: any, pricingToDelete: any, paypentOptionsToInsert: any, paypentOptionsToUpdate: any, pricingToInsert: any, pricingToUpdate: any}): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.savePaymentsData" {
  export default function savePaymentsData(param: {theCommercial: any, paymentsToInsert: any, paymentsToUpdate: any}): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.getPaymentsData" {
  export default function getPaymentsData(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.getPaymentDetails" {
  export default function getPaymentDetails(param: {selectedPaymentId: any}): Promise<any>;
}
declare module "@salesforce/apex/TDRScreenController.getSelectedPlanMPOData" {
  export default function getSelectedPlanMPOData(param: {oppId: any, planId: any}): Promise<any>;
}
