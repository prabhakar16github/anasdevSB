declare module "@salesforce/apex/WebsiteStatusMaintanenceController_Onb.getWebsitePageRecords" {
  export default function getWebsitePageRecords(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/WebsiteStatusMaintanenceController_Onb.getPickListValues" {
  export default function getPickListValues(param: {strObjectName: any, strPicklistField: any}): Promise<any>;
}
declare module "@salesforce/apex/WebsiteStatusMaintanenceController_Onb.saveWebsitePageRecords" {
  export default function saveWebsitePageRecords(param: {strWrapperWebsitePage: any}): Promise<any>;
}
declare module "@salesforce/apex/WebsiteStatusMaintanenceController_Onb.getMccCodeMetaData" {
  export default function getMccCodeMetaData(param: {mccCode: any, partner: any}): Promise<any>;
}
declare module "@salesforce/apex/WebsiteStatusMaintanenceController_Onb.updateOptyWebsiteStatus" {
  export default function updateOptyWebsiteStatus(param: {recordId: any, status: any, strWrapperWebsitePage: any}): Promise<any>;
}
declare module "@salesforce/apex/WebsiteStatusMaintanenceController_Onb.updateApprovalDetails" {
  export default function updateApprovalDetails(param: {recordId: any, isPrioritySettlment: any, maxAmount: any, preApprvdEMI: any, PreApprvdMCP: any}): Promise<any>;
}
declare module "@salesforce/apex/WebsiteStatusMaintanenceController_Onb.updatePreRiskDetails" {
  export default function updatePreRiskDetails(param: {recordId: any, mccCode: any, BaseMID: any, isFileUploaded: any, lobRiskReason: any, lobStatus: any, lobRiskApprover: any, businessEntity: any, businessCategory: any, subCategory: any, strWrapperWebsitePage: any}): Promise<any>;
}
