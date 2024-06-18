declare module "@salesforce/apex/PicklistController.getPickListValues" {
  export default function getPickListValues(param: {objApiName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/PicklistController.getDependentOptions" {
  export default function getDependentOptions(param: {objApiName: any, fieldName: any, contrFieldApiName: any}): Promise<any>;
}
declare module "@salesforce/apex/PicklistController.getFieldLabel" {
  export default function getFieldLabel(param: {objName: any, fieldName: any}): Promise<any>;
}
