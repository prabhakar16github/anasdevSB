declare module "@salesforce/apex/MCareDashboardCompController.getMCareDashboardData" {
  export default function getMCareDashboardData(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/MCareDashboardCompController.getMerchantStatus" {
  export default function getMerchantStatus(param: {objType: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/MCareDashboardCompController.getBusinessCategory" {
  export default function getBusinessCategory(): Promise<any>;
}
declare module "@salesforce/apex/MCareDashboardCompController.getFieldHelpText" {
  export default function getFieldHelpText(param: {objDetail: any}): Promise<any>;
}
declare module "@salesforce/apex/MCareDashboardCompController.saveDashboardData" {
  export default function saveDashboardData(param: {wrapperString: any, isSendEmail: any, isSendAttachment: any, doNotSendDescription: any, projectName: any, internallyCreated: any, documentId: any}): Promise<any>;
}
declare module "@salesforce/apex/MCareDashboardCompController.getDependentMap" {
  export default function getDependentMap(param: {objDetail: any, contrfieldApiName: any, depfieldApiName: any}): Promise<any>;
}
