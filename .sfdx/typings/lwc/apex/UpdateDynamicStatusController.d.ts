declare module "@salesforce/apex/UpdateDynamicStatusController.updateSelectedStatus" {
  export default function updateSelectedStatus(param: {preRiskHoldReason: any, riskHoldReasonEmailContent: any, preRiskReasonEmailContent: any, objectName: any, recordId: any, field: any, value: any, riskHoldReason: any}): Promise<any>;
}
declare module "@salesforce/apex/UpdateDynamicStatusController.getRiskHoldReason" {
  export default function getRiskHoldReason(): Promise<any>;
}
declare module "@salesforce/apex/UpdateDynamicStatusController.getPreRiskHoldReason" {
  export default function getPreRiskHoldReason(): Promise<any>;
}
declare module "@salesforce/apex/UpdateDynamicStatusController.getOBHoldReason" {
  export default function getOBHoldReason(): Promise<any>;
}
declare module "@salesforce/apex/UpdateDynamicStatusController.getRiskHoldAccess" {
  export default function getRiskHoldAccess(): Promise<any>;
}
declare module "@salesforce/apex/UpdateDynamicStatusController.getSettlementStatusPicklist" {
  export default function getSettlementStatusPicklist(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/UpdateDynamicStatusController.getRiskHoldContent" {
  export default function getRiskHoldContent(param: {riskHoldReason: any}): Promise<any>;
}
declare module "@salesforce/apex/UpdateDynamicStatusController.getPreRiskHoldEmailContent" {
  export default function getPreRiskHoldEmailContent(param: {preRiskHoldReason: any}): Promise<any>;
}
declare module "@salesforce/apex/UpdateDynamicStatusController.getRiskStatusDetail" {
  export default function getRiskStatusDetail(param: {mcareCaseId: any}): Promise<any>;
}
declare module "@salesforce/apex/UpdateDynamicStatusController.mcareCaseUpdate" {
  export default function mcareCaseUpdate(param: {mcareCaseId: any, reason: any, comment: any, investigation: any}): Promise<any>;
}
