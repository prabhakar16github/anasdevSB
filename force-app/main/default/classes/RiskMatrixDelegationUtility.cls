/*******************************************************************************************************
* Author       : PayU Payments Pvt. Ltd.
* Class Name   : RiskMatrixDelegationUtility
* Created Date : 24 Novemeber 2022
* Description  : Utility class for Risk Delegation matrix
********************************************************************************************************
* Updates
* Author                 | Date                | Description
* Aditya Mukkawar        | 24 Novemeber 2022   | Initial Creation
*******************************************************************************************************/

global without sharing class RiskMatrixDelegationUtility {
    
    // Get settlement access token for further callouts
//     public static void getAccessToken() {
//         String strEndPoint = '';
//         String strBody = 'grant_type=password';
//         strBody += '&client_id={Enter_Client_Id}&client_secret={Enter_Client_Secret}';
//         strBody += '&username={Enter_Username}&password={Enter_Password}';
//         HttpRequest objRequest = new HttpRequest();
//         objRequest.setEndpoint(strEndPoint);
//         objRequest.setMethod('POST');
//         objRequest.setBody(strBody);
//         objRequest.setTimeout(120000);
//         Http http = new Http();
//         HTTPResponse objResponse = http.send(objRequest);
//         System.debug('objResponse=>'+objResponse.getBody());
//         System.debug('objResponse=>'+objResponse.getStatusCode());
//         String strAccessToken;
//         /*JSONParser parser = JSON.createParser(objResponse.getBody());
// while (parser.nextToken() != null) {
// if ((parser.getCurrentToken() == JSONToken.FIELD_NAME ) && 
// (parser.getText() == 'access_token')) {
// parser.nextToken();
// strAccessToken = parser.getText();
// break;
// }
// }
// */
//         System.debug( 'Access Token is ' + strAccessToken ); 
//     }
    
//     // Get settlement amount
//     public static void getSettlementAmount(String accessToken,String mId) {
//         String strEndPoint = 'http://10.248.8.215:8090/treasury/v1/settlement/upcomingSettlementsDetails';
        
//         JSONGenerator gen = JSON.createGenerator(true);
//         gen.writeStartObject();
//         gen.writeStringField('mid', mId);
//         gen.writeEndObject();
//         String strBody = gen.getAsString();
//         system.debug('strBody=>'+strBody);
//         HttpRequest objRequest = new HttpRequest();
//         objRequest.setEndpoint(strEndPoint);
//         objRequest.setMethod('GET');
//         objRequest.setHeader('Content-Type', 'application/json');
//         //objRequest.setHeader('Accept', 'application/json');
//         objRequest.setBody(strBody);
//         objRequest.setTimeout(120000);
//         Http http = new Http();
//         HTTPResponse objResponse = http.send(objRequest);
//         system.debug('objResponse=>'+objResponse);
//         System.debug('objResponse=>'+objResponse.getStatusCode());
//         System.debug('objResponse=>'+objResponse.getBody());
//     }
    
    // Final Rejection for Release Note
    @AuraEnabled
    WebService static void revertApprovalProcess(String recordId, String comment) {
    //     List<ProcessInstanceWorkItem> pis = [SELECT Id, ActorId, Actor.Name FROM ProcessInstanceWorkitem WHERE processInstance.TargetObjectId = :recordId];
    //     if(!pis.isEmpty()) {
    //         ProcessInstanceWorkItem pi = pis[0];
    //         String approvalId = pi.Id;
    //         System.debug(approvalId);
    //         //ProcessInstanceWorkItem pi = [SELECT Id, ActorId, Actor.Name FROM ProcessInstanceWorkItem LIMIT 1];
    //         System.debug(pi.ActorId);
    //         System.debug(pi.Actor.Name);
    //         System.debug(pi.Actor.Name.split('L')[1].split(' Initiators')[0]);
    //         Integer stepNo = Integer.valueOf(pi.Actor.Name.split('L')[1].split(' Initiators')[0]);
    //         System.debug(stepNo);
    //         GroupMember gm = [Select Group.Name from GroupMember where UserOrGroupId = :UserInfo.getUserId() and GroupId = :pi.ActorId and Group.Type = 'Queue'];

    //         Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
    //         req.setComments(comment);
    //         req.setAction('Removed');
    //         req.setWorkitemId((String)pi.Id);
    //         Approval.ProcessResult result = Approval.process(req);            
    //     } 
        
    //     // Update Release Note Status to Send email to L1 Initators
    //     Release_Note__c rn = new Release_Note__c(Id = recordId);
    //     rn.Status__c = 'Recalled';

    //     update rn;
    //     // List<Approval.ProcessWorkitemRequest> pwirs = new List<Approval.ProcessWorkitemRequest>();
    //     // if(gm != null) {
    //     //     for (Integer i = 0; i < stepNo; i++) {
    //     //         Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
    //     //         req.setComments(comment);
    //     //         req.setAction('Reject');
    //     //         req.setWorkitemId((String)pi.Id);
    //     //         pwirs.add(req);                
    //     //     }
    //     // }

    //     // List<Approval.ProcessResult> result = Approval.process(pwirs);
    //     /*Boolean flag = false;
    //     String newId = '';
    //     if(pi.Actor.Name.contains('L1')) {
    //         Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
    //         req.setComments('');
    //         req.setAction('Reject');
    //         req.setWorkitemId((String)pi.Id);            
    //         Approval.ProcessResult result = Approval.process(req);
    //         flag = true;
    //     } else if(pi.Actor.Name.contains('L2')) {
    //         RiskMatrixDelegation__mdt  delMatInst = RiskMatrixDelegation__mdt.getInstance('L1');
    //         newId = delMatInst.Id__c;
    //     } else if(pi.Actor.Name.contains('L3')) {
    //         RiskMatrixDelegation__mdt  delMatInst = RiskMatrixDelegation__mdt.getInstance('L2');
    //         newId = delMatInst.Id__c;
    //     } else if(pi.Actor.Name.contains('L4')) {
    //         RiskMatrixDelegation__mdt  delMatInst = RiskMatrixDelegation__mdt.getInstance('L3');
    //         newId = delMatInst.Id__c;
    //     }
        
    //     if(!flag) {
    //     	pi.ActorId = newId;
    //     	update pi;            
    //     }
    //     */
    }

    // Make Settlement Status Active (Approval process final approval)
    public static void updSettlementStatus(List<Release_Note__c> releaseNotes) {
        List<Opportunity> toUpdate = new List<Opportunity>();
        for(Release_Note__c rn : releaseNotes) {
            if(rn.Status__c == 'Approved') {
                Opportunity opp = new Opportunity(Id = rn.Opportunity__c);
                opp.Settlement_Status__c = 'Active';
                toUpdate.add(opp);
            }
        }

        if(toUpdate.size() > 0 && !Test.isRunningTest()) {
            update toUpdate;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getReleaseNotes(String oppId) {
        Map<Id, Release_Note__c> rnsMap = new Map<Id, Release_Note__c>([Select Id, Name, Status__c, Ageing_From_Hold_Days__c, CreatedDate, (Select Id, CreatedDate FROM ProcessInstances Order By CreatedDate DESC LIMIT 1) FROM Release_Note__c Where Opportunity__c = :oppId Order By CreatedDate Desc]);
        List<Release_Note__c> rns = rnsMap.values();
        Set<Id> piIds = new Set<Id>();
        for(Release_Note__c rn : rns) {
            if(rn.ProcessInstances != null && rn.ProcessInstances.size() > 0) {
                piIds.add(rn.ProcessInstances[0].Id);
            }
        }

        List<ProcessInstance> pis = [SELECT Id, TargetObjectId, (SELECT Id, StepStatus, Comments, ActorId, OriginalActorId, OriginalActor.Name FROM Steps Order By CreatedDate DESC LIMIT 1) FROM ProcessInstance Where Id IN :piIds];
        Map<Id, String> piStatusMap = new Map<Id, String>();
        for(ProcessInstance pi : pis) {
            String str = '';
            System.debug('steps======');
            System.debug(pi.Steps);
            if(pi.Steps != null && pi.Steps.size() > 0) {
                switch on pi.Steps[0].StepStatus {
                    when  'Rejected'{
                        str += 'Revert by ' + pi.Steps[0].OriginalActor.Name;
                        if(str == 'Revert by L2 Initiators' && rnsMap.get(pi.TargetObjectId).Status__c == 'Recalled') {
                            str = 'Final Rejection by L1 Initiators';
                        }
                    }
                    when  'Removed'{
                        str += 'Final Rejection by ' + pi.Steps[0].OriginalActor.Name;
                    }
                    when  'Approved'{
                        str += 'Approved by ' + pi.Steps[0].OriginalActor.Name;
                    }
                    when  'Started'{
                        str += 'Approved by L1 Initiators';
                    }
                    when else {
                        System.debug('No Steps found');
                    }
                }
            }

            piStatusMap.put(pi.Id, str);
        }
        return new List<String>{JSON.serialize(rns), JSON.serialize(piStatusMap)};
    }

    @AuraEnabled
    public static Release_Note__c getRNCheck(Id recId) {
        system.debug(recId);
        
        return [Select Id, Analyst_L1_Status__c, Analyst_process_info__c From Release_Note__c Where Id = :recId];
    }
    
    @AuraEnabled
    public static Boolean getAnalystAccess(Id recId) {
        if(Label.Analysts_for_Delgation_Matrix.contains(UserInfo.getUserId())){  
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static List<ProcessInstance> getProcessInstances(Id recId) {
        return [select id, targetobjectid, ProcessDefinition.Name, (SELECT actor.name,originalactorid, originalactor.name,StepStatus, CreatedDate, ProcessNode.Name, Comments FROM StepsAndWorkitems) 
        from ProcessInstance where targetobjectid = :recId];
    }

    @AuraEnabled
    public static void updateRNAnalystL1Status(Boolean val, Id recId, String comment) {
        if(val != null && recId != null) {
            //Release_Note__c rn = new Release_Note__c();
            Release_Note__c rn = [Select Id, Analyst_L1_Status__c, Analyst_process_info__c From Release_Note__c Where Id = :recId];

            // rn.Id = recId;
            rn.Analyst_process_info__c = comment;
            
            rn.Analyst_L1_Status__c = val;
    		
            if(!Test.isRunningTest()) {
				update rn;   
            }
        }
    }
}