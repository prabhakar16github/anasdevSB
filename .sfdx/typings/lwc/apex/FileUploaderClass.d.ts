declare module "@salesforce/apex/FileUploaderClass.returnFiles" {
  export default function returnFiles(param: {lstFileIds: any}): Promise<any>;
}
declare module "@salesforce/apex/FileUploaderClass.saveFiles" {
  export default function saveFiles(param: {filesToInsert: any, caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/FileUploaderClass.updateEmail" {
  export default function updateEmail(param: {emailId: any, ContactId: any}): Promise<any>;
}
declare module "@salesforce/apex/FileUploaderClass.createCase" {
  export default function createCase(param: {caseToInsert: any}): Promise<any>;
}
