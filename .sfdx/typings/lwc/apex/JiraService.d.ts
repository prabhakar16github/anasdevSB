declare module "@salesforce/apex/JiraService.getJIRASettings" {
  export default function getJIRASettings(): Promise<any>;
}
declare module "@salesforce/apex/JiraService.createJIRA" {
  export default function createJIRA(param: {json: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/JiraService.getJIRAStatus" {
  export default function getJIRAStatus(param: {jiraNumber: any, recordId: any}): Promise<any>;
}
