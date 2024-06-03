declare module "@salesforce/apex/PricingModuleComponentController.getPlanDetailsOnLoad" {
  export default function getPlanDetailsOnLoad(): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getSubPlanDetails" {
  export default function getSubPlanDetails(param: {planId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getPaymentDetails" {
  export default function getPaymentDetails(param: {templateId: any, commercialId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getSpecificationDetails" {
  export default function getSpecificationDetails(param: {paymentModeId: any, paymentOptionId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.savePricingApex" {
  export default function savePricingApex(param: {selectedListPaymentData: any, recordId: any, commercialName: any, selectedTemplate: any, commercialId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.existingCommercial" {
  export default function existingCommercial(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getPricingRecordsForCommercial" {
  export default function getPricingRecordsForCommercial(param: {commercialId: any, commercialName: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getPaymentGatewayData" {
  export default function getPaymentGatewayData(param: {paymentModeId: any, paymentOptionId: any, selectedSpecifications: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getBelowRackRatesRecords" {
  export default function getBelowRackRatesRecords(param: {commercialId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.updateBelowRackRatesRecords" {
  export default function updateBelowRackRatesRecords(param: {commercialId: any, belowRackRatesRecords: any, listPricingIds: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getSendToBHRecords" {
  export default function getSendToBHRecords(param: {commercialId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.sendToBHEmail" {
  export default function sendToBHEmail(param: {commercialId: any, body: any, subject: any, listPricingIds: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.insertFixedPricingAndPublishCommercial" {
  export default function insertFixedPricingAndPublishCommercial(param: {commercialId: any, listFixedPricingString: any, listPlatformFee: any, listFallbackCharges: any, selectedType: any, selectedInterval: any, selectedStartDate: any, selectedEndDate: any, selectedDebitModel: any, listFixedPricing2: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getCommercialInformationBeforeValidatePricing" {
  export default function getCommercialInformationBeforeValidatePricing(param: {commercialId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getTemplateDetails" {
  export default function getTemplateDetails(param: {planId: any, subPlanId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.createTemplateForOrdinaryUser" {
  export default function createTemplateForOrdinaryUser(param: {templateName: any, selectedListPaymentData: any, listFixedPricingString: any, commercialId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getPrivateTemplateDetails" {
  export default function getPrivateTemplateDetails(): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getPlanAndSubPlanDetails" {
  export default function getPlanAndSubPlanDetails(): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getSubPlanDetailsForSelectedPlan" {
  export default function getSubPlanDetailsForSelectedPlan(param: {planId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.createTemplateForSuperUser" {
  export default function createTemplateForSuperUser(param: {templateName: any, selectedListPaymentData: any, listFixedPricingString: any, commercialId: any, publicTemplateCheckbox: any, planName: any, subPlanName: any, action: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getPublicCheckboxForTemplate" {
  export default function getPublicCheckboxForTemplate(param: {templateId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getNewAPILiveDetailsFromTreasury" {
  export default function getNewAPILiveDetailsFromTreasury(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getLiveDetailsFromTreasury" {
  export default function getLiveDetailsFromTreasury(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getPrivateTemplateDetailsForPlanAndSubPlan" {
  export default function getPrivateTemplateDetailsForPlanAndSubPlan(param: {planId: any, subPlanId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getModalInformation" {
  export default function getModalInformation(param: {commercialId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getAuditTrailRecordsForCommercial" {
  export default function getAuditTrailRecordsForCommercial(param: {commercialId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getPricingData" {
  export default function getPricingData(param: {pricingId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getOverallAuditTrail" {
  export default function getOverallAuditTrail(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingModuleComponentController.getOverallAuditForStackTrail" {
  export default function getOverallAuditForStackTrail(param: {opportunityId: any}): Promise<any>;
}
