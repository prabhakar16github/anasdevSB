/******************************************************
@ Class:          CasecreationfromApp
@ Author:         Prashant Kulshrestha
******************************************************/

@RestResource(urlMapping = '/CreateCase_App/*')
global class CasecreationfromApp{
  

 @HttpPOST
 global static void request(){
 
   String ContactId;
   String Status;
   String Origin;
   String Subject;
   String LP_Rating;
   String Labels;
   String Agent_Comments;
   String DeviceName;
   String DeviceMfg;
   String LP_Model;
   String OS;
   String LP_OS_version;
   String LP_Carrier;
   boolean flag = false;
   list<Contact> c;
   String cntrt ;
   //String[]s1;
   
   string[] p1 = new string[]{};
   map<String, String> maplead=new map<String, String>();
   map<String, String> mapvwoact=new map<String, String>();
   map<string, string> maplead_convert = new map<string,string>();
   list<string> s1 = new list<string>();

   
   RestRequest request = RestContext.request;  
   String requestBody = RestContext.request.requestBody.toString();
   System.debug('requestBody***'+requestBody);
   
   
        
       JSONParser parser = JSON.createParser(requestBody);
        while(parser.nextToken()!=null && parser.getCurrentToken()!=JSONToken.END_OBJECT){
        
            //VWO Account Creation form Json
            if((parser.getCurrentToken()==JSONToken.FIELD_NAME) && parser.getCurrentName()=='ContactId'){
                parser.nextToken();
                ContactId=parser.getText();
                system.debug('ContactId:*--'+ContactId);
                //Call Class for Create VWO Account
               /* mapvwoact = Process_Automation.VWO_Account_Creation(account_id);
                vwoid = mapvwoact.get('VWO_id');  */ 
                //system.debug('vwoid:*--'+vwoid);
             }
             
             if((parser.getCurrentToken()==JSONToken.FIELD_NAME) && parser.getCurrentName()=='Status'){
                parser.nextToken();
                Status=parser.getText();
                system.debug('Status:*--'+Status);
             }
             if((parser.getCurrentToken()==JSONToken.FIELD_NAME) && parser.getCurrentName()=='Origin'){
                parser.nextToken();
                Origin=parser.getText();
                system.debug('Origin:*--'+Origin);
             }
             if((parser.getCurrentToken()==JSONToken.FIELD_NAME) && parser.getCurrentName()=='Subject'){
                parser.nextToken();
                Subject=parser.getText();
                system.debug('Subject:*--'+Subject);
             }
             if((parser.getCurrentToken()==JSONToken.FIELD_NAME) && parser.getCurrentName()=='LP_Rating'){
                parser.nextToken();
                LP_Rating=parser.getText();
                system.debug('LP_Rating__c:*--'+LP_Rating);
             }
             if((parser.getCurrentToken()==JSONToken.FIELD_NAME) && parser.getCurrentName()=='Labels'){
                parser.nextToken();
                Labels=parser.getText();
                system.debug('Labels:*--'+Labels);
             }
             if((parser.getCurrentToken()==JSONToken.FIELD_NAME) && parser.getCurrentName()=='Agent_Comments'){
                parser.nextToken();
                Agent_Comments=parser.getText();
                system.debug('Agent_Comments:*--'+Agent_Comments);
             }
             if((parser.getCurrentToken()==JSONToken.FIELD_NAME) && parser.getCurrentName()=='DeviceName'){
                parser.nextToken();
                DeviceName=parser.getText();
                system.debug('DeviceName:*--'+DeviceName);
             }
             if((parser.getCurrentToken()==JSONToken.FIELD_NAME) && parser.getCurrentName()=='DeviceMfg'){
                parser.nextToken();
                DeviceMfg=parser.getText();
                system.debug('DeviceMfg:*--'+DeviceMfg);
             }
             if((parser.getCurrentToken()==JSONToken.FIELD_NAME) && parser.getCurrentName()=='LP_Model'){
                parser.nextToken();
                LP_Model=parser.getText();
                system.debug('LP_Model:*--'+LP_Model);
             }
             if((parser.getCurrentToken()==JSONToken.FIELD_NAME) && parser.getCurrentName()=='OS'){
                parser.nextToken();
                OS=parser.getText();
                system.debug('OS:*--'+OS);
             }
             if((parser.getCurrentToken()==JSONToken.FIELD_NAME) && parser.getCurrentName()=='LP_OS_version'){
                parser.nextToken();
                LP_OS_version=parser.getText();
                system.debug('LP_OS_version:*--'+LP_OS_version);
             }
             if((parser.getCurrentToken()==JSONToken.FIELD_NAME) && parser.getCurrentName()=='LP_Carrier'){
                parser.nextToken();
                LP_Carrier=parser.getText();
                system.debug('LP_Carrier:*--'+LP_Carrier);
             }
 
 
 
 
 
 
 
 
          }
   }
}