declare module "@salesforce/apex/PlanFormController.getPaymentOptionData" {
  export default function getPaymentOptionData(param: {planId: any}): Promise<any>;
}
declare module "@salesforce/apex/PlanFormController.getPlanData" {
  export default function getPlanData(param: {planId: any}): Promise<any>;
}
declare module "@salesforce/apex/PlanFormController.getPOData" {
  export default function getPOData(param: {planId: any}): Promise<any>;
}
declare module "@salesforce/apex/PlanFormController.insertPlanAndPricing" {
  export default function insertPlanAndPricing(param: {thePlan: any, ppoToDelete: any, pricingToDelete: any, paypentOptionsToInsert: any, paypentOptionsToUpdate: any, pricingToInsert: any, pricingToUpdate: any}): Promise<any>;
}
