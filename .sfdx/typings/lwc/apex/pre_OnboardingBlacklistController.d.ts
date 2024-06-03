declare module "@salesforce/apex/pre_OnboardingBlacklistController.getBlacklistDetails" {
  export default function getBlacklistDetails(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/pre_OnboardingBlacklistController.unblockMerchant" {
  export default function unblockMerchant(param: {oppId: any, blacklistComment: any, riskTypeforInactive: any, selectedRiskType: any}): Promise<any>;
}
declare module "@salesforce/apex/pre_OnboardingBlacklistController.saveWrapperDetail" {
  export default function saveWrapperDetail(param: {oppObj: any, isBlacklIstData: any, riskTypes: any}): Promise<any>;
}
