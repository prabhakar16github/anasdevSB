declare module "@salesforce/apex/MaintenanceCtrl.getPickListValues" {
  export default function getPickListValues(param: {sObjectName: any, sObjectField: any}): Promise<any>;
}
declare module "@salesforce/apex/MaintenanceCtrl.getBusinessEntities" {
  export default function getBusinessEntities(): Promise<any>;
}
declare module "@salesforce/apex/MaintenanceCtrl.createClonedData" {
  export default function createClonedData(param: {recordId: any, selectedType: any}): Promise<any>;
}
declare module "@salesforce/apex/MaintenanceCtrl.updateBankAccountData" {
  export default function updateBankAccountData(param: {newBankObj: any}): Promise<any>;
}
declare module "@salesforce/apex/MaintenanceCtrl.updateAccountData" {
  export default function updateAccountData(param: {newAccountObj: any, oppObj: any, selectedDetail: any}): Promise<any>;
}
declare module "@salesforce/apex/MaintenanceCtrl.updateOpportunityData" {
  export default function updateOpportunityData(param: {newOppObj: any, oldOppObj: any, entityData: any, selectedDetail: any}): Promise<any>;
}
declare module "@salesforce/apex/MaintenanceCtrl.createAddressAccountData" {
  export default function createAddressAccountData(param: {newOppAddressObj: any, newOppObj: any, oldOppObj: any, addressType: any, selectedDetail: any}): Promise<any>;
}
