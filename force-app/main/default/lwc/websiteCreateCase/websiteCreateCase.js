import { LightningElement } from 'lwc';
import { api } from 'lwc';

import AttachmentIcon from '@salesforce/resourceUrl/AttachmentIcon';
import saveFiles from '@salesforce/apex/FileUploaderClass.saveFiles';
import getFiles from '@salesforce/apex/FileUploaderClass.returnFiles';
import createCase from '@salesforce/apex/FileUploaderClass.createCase';
import updateEmail from '@salesforce/apex/FileUploaderClass.updateEmail';
import UserPreferencesShowFaxToExternalUsers from '@salesforce/schema/User.UserPreferencesShowFaxToExternalUsers';


export default class Website_CreteCase extends LightningElement {

    @api
    messageContentType;
    @api 
    isformSubmitted

    objectName = 'Case';
    controllingFieldName = 'LP_Issue__c';
    fieldName = 'LP_Sub_Issue__c';

    routableId;
    selectedValues ;
    
    showLoadingSpinner = false;
    fileNames = '';
    filesUploaded = [];
    dataFileName;


    comments;
    merchantName;
    merchantEmail;
    Mobile;
    error = '';
    errorEmail = '';
    errorName = '';
    errorMobile = '';
    errorComment = '';

    Issue;
    SubIssue;
    mid;
    Product;
    confirmEmail;
    emailchangeMsg;

    isInputName=false;
    isInputEmail=false;
    isInputMobile=false;
    isInputComment=false;
    createTicket=false;
    isCaseCreated=false;
    isloggedOut=true;
    showEmailInput=false;
    ignoreMsg=false;
    isUpdateEmail=false;
    caseNumber;
    caseIdentifier;
    contactId;
    ignoreMsgText;
    updateEmailMsg;
    showSelectedMaxFiles = false;
    errorAtt = '';
    submitError = '';
    isSubmitError = false;


    caseObj={Name: undefined,
        Mobile: undefined,
        Email: undefined,
        Comment: undefined,
        Issue:undefined,
        SubIssue:undefined,
        mid:undefined,
        Product:undefined,
        ChatTranscriptId:undefined,
        merchantType:undefined
    };


    AttIcon = AttachmentIcon;
    
    connectedCallback(){
        this.createWebsiteCase();
    }
    createWebsiteCase(){
        console.log('check message content=='+this.messageContentType);
        var str = this.messageContentType.value.split(':')[1];
        this.Issue = str.split(';')[0];
        this.SubIssue = str.split(';')[1];
        this.mid = str.split(';')[2];
        console.log('this.mid='+this.mid);
        console.log('this.Issue='+this.Issue);
        console.log('this.SubIssue='+this.SubIssue);
        
        this.Product = str.split(';')[3];
        console.log('this.product='+this.Product);

        this.routableId = str.split(';')[4];
        console.log('this.routableId='+this.routableId);
        

        if(this.mid != '{!MID}' && this.Product != '{!Product}'){
            this.isloggedOut = false;
            this.recordtype = 'loggedIn';
            this.enableSubmitButton();
        }
        console.log('this.isloggedOut =='+this.isloggedOut);
    }

    validateCaseCreationInput(){

        this.isformSubmitted=true;
        //this.handleFormSubmissionEvent(this.isformSubmitted);
        let name = this.merchantName;
        let email = this.merchantEmail;
        let mobile = this.Mobile;
        let comment = this.comments;
        let issue = this.Issue;
        let subIssue = this.SubIssue;

        this.caseObj.Name= name;
        this.caseObj.Mobile =mobile;
        this.caseObj.Email = email;
        this.caseObj.Comment = comment;
        this.caseObj.Issue = issue;
        this.caseObj.SubIssue = subIssue;
        this.caseObj.mid= this.mid;
        this.caseObj.Product = this.Product;
        this.caseObj.ChatTranscriptId = this.routableId;
        //this.caseObj.recordtype = this.recordtype;
        this.caseObj.merchantType = this.merchantType;

        console.log('this.caseObj=='+this.caseObj);
        console.log('this.caseObj string=='+JSON.stringify(this.caseObj));

        if(!this.createTicket){
        createCase({caseToInsert: this.caseObj})
        .then(data => {
            console.log('case created!!');
            console.log('ticket id=='+data);
            let returnstr = data;
            if(returnstr.includes('for same issue already exists and is in-progress.')){
            this.isCaseCreated = true;
                this.text = data.split(';')[0]+'\n\n Our team will reach you shortly at the contact address: '+ data.split(';')[2];
                this.caseNumber = data.split(';')[3];
                let str = 'You can track the status of your query https://test-help.payu.in/search-query.';
                this.confirmEmail =  str
                .replace( // innerText or textContent
                /(?:(?:ht|f)tp(?:s?)\:\/\/|~\/|\/)?(?:\w+:\w+@)?((?:(?:[-\w\d{1-3}]+\.)+(?:com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|edu|co\.uk|ac\.uk|it|fr|tv|museum|asia|local|travel|[a-z]{2}))|((\b25[0-5]\b|\b[2][0-4][0-9]\b|\b[0-1]?[0-9]?[0-9]\b)(\.(\b25[0-5]\b|\b[2][0-4][0-9]\b|\b[0-1]?[0-9]?[0-9]\b)){3}))(?::[\d]{1,5})?(?:(?:(?:\/(?:[-\w~!$+|.,=]|%[a-f\d]{2})+)+|\/)+|\?|#)?(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?:#(?:[-\w~!$ |\/.,*:;=]|%[a-f\d]{2})*)?/g,
                function(imgUrl) {
                    // Only switch out to specific shortened urls if the agent is the user.
                    if(this.userType === AGENT_USER_TYPE) {
                        return `<a target="_blank" href="${imgUrl}" style="color:green;">here</a>`;
                    }
                    return imgUrl;
                    }.bind(this)
                );
                console.log('isloggedOut??'+this.isloggedOut);
            if(!this.isloggedOut){
                console.log('enter change email');
                this.emailchangeMsg = 'Incase, you would like to change the contact address please click on \'YES\' below, else ignore:-';
                this.confirmEmail = true;
                this.isShowEmailChange = true;
                
            }
            this.caseIdentifier = data.split(';')[1];
            console.log('returnstr.split'+returnstr.split(';')[1]+'  '+ returnstr.split(';')[2]+'  '+ returnstr.split(';')[3]);
            this.contactId = returnstr.split(';')[3];
            if(this.filesUploaded.length > 0){
                this.handleSaveFiles(this.caseIdentifier);
            } 
            
        }
        else{

            this.isCaseCreated = true;
            this.text = data.split(';')[0]+'\n\n Our team will reach you shortly at the contact address: '+ data.split(';')[2];
            this.caseNumber = data.split(';')[3];
            this.caseIdentifier = data.split(';')[1];
            this.contactId = data.split(';')[4];

            console.log('isloggedOut??'+this.isloggedOut);

            if(!this.isloggedOut){
                console.log('enter email change when case does not exists');       
                this.emailchangeMsg = 'Incase, you would like to change the contact address please click on \'YES\' below, else ignore:-';
                this.confirmEmail = true;
                this.isShowEmailChange = true;  
            }
            if(this.filesUploaded.length > 0){
                this.handleSaveFiles(this.caseIdentifier);
            } 

        }
        })
        .catch(error => {
            console.log('error=='+JSON.stringify(error));
        });

    }else{
        console.log('submit error');
        this.submitError = 'Kindly update all the manadatory fields';
        this.isSubmitError = true;
        this.isformSubmitted = false;
    }
    }

    handlePicklist(event) {
        this.selectedValues = event.detail.pickListValue;
        //window.console.log('\n **** selectedValues **** \n ', selectedValues);
        this.selectedValues = JSON.parse(JSON.stringify(this.selectedValues));
        window.console.log('\n **** selectedvalues ** \n ', JSON.stringify(this.selectedValues));
        
        if(this.selectedValues){
            if(this.selectedValues.controlling){
                this.Issue = this.selectedValues.controlling;
                this.SubIssue = this.selectedValues.dependent;
            }
        }
    }


    handleInputComment(e){
        this.comments = e.target.value;
        if(this.comments){
            this.errorComment = '';
            this.isInputComment = false;
            this.enableSubmitButton();
            
        }else{
            //addErrorMsg('This field cannot be left blank');
            this.errorComment = 'This field cannot be blank';
            this.isInputComment = true;
        }
        
    }

    handleInputName(e){
        this.merchantName = e.target.value;
        if(this.merchantName){
            this.errorName = '';
            this.isInputName = false;  
            this.enableSubmitButton();          
        }else{
            //addErrorMsg('This field cannot be left blank');
            this.errorName = 'This field cannot be blank';
            this.isInputName = true;
        }
        
    }
    handleInputEmail(e){
        this.merchantEmail = e.target.value;
        if(this.merchantEmail){
            //var mailformat = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/;
            var mailformat = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
            if(this.merchantEmail.match(mailformat))
            {
                this.errorEmail = '';
                this.isInputEmail = false;
                this.enableSubmitButton();
            }
            else{
                this.errorEmail = 'Invalid Email Id';
                this.isInputEmail = true;
            }
        }
        else{
            //addErrorMsg('This field cannot be left blank');
            this.errorEmail = 'This field cannot be blank';
            this.isInputEmail = true;
        }
        
    }
    handleInputMobile(e){
        try{
            this.Mobile = e.target.value;
            if(this.Mobile){
            var mobileFormat = /^[0-9]{10}$/;
            //var mobileFormat = /^[6789]\\d{9}$/;
            if(this.Mobile.match(mobileFormat)){
                this.errorMobile = '';
                this.isInputMobile = false;
                this.enableSubmitButton();
            }
            else{
                this.errorMobile = 'enter 10 digit number';
                this.isInputMobile = true;
            }
            
            
            }else{
            //addErrorMsg('This field cannot be left blank');
            this.errorMobile = 'This field cannot be blank';
            this.isInputMobile= true;
            }
        }catch(err){
            console.log('err.message;==='+err.message);
        }
        
        
    }


    setShowEmailInput(){
        try{
            console.log('setShowEmailInput=true');
            this.showEmailInput = true;
            this.confirmEmail = false;
        }catch(err){
            console.log('err.message;==='+err.message);
        }
    }

    showIgnoreMsg(){
        try{
            this.ignoreMsg= true;
            this.confirmEmail = false;
            this.ignoreMsgText = 'Thank you for your input, soon we will get in touch with you'
        }catch(err){
            console.log('err.message;==='+err.message);
        }
    }

    UpdateEmail(){
        this.showEmailInput = false;
        this.isUpdateEmail = true;
        if(this.merchantEmail){
            this.caseObj.Email = this.merchantEmail;
            console.log('contactId==='+this.contactId);
            updateEmail({emailId : this.merchantEmail, ContactId : this.contactId})
            .then(data => {
                if(data){
                    //this.updateEmailMsg = 'Thanks for sharing your updated contact details. Our team will reach you out at your updated contact information.\n  Your ticket ID for Issue:<b>'+ this.Issue+'</b> & '+this.SubIssue+':'+' is '+this.caseNumber;
                    this.updateEmailMsg = data;
                    let str = 'You can track status of your query https://test-help.payu.in/search-query.'
                    let trackaquery = str
                    .replace( // innerText or textContent
                    /(?:(?:ht|f)tp(?:s?)\:\/\/|~\/|\/)?(?:\w+:\w+@)?((?:(?:[-\w\d{1-3}]+\.)+(?:com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|edu|co\.uk|ac\.uk|it|fr|tv|museum|asia|local|travel|[a-z]{2}))|((\b25[0-5]\b|\b[2][0-4][0-9]\b|\b[0-1]?[0-9]?[0-9]\b)(\.(\b25[0-5]\b|\b[2][0-4][0-9]\b|\b[0-1]?[0-9]?[0-9]\b)){3}))(?::[\d]{1,5})?(?:(?:(?:\/(?:[-\w~!$+|.,=]|%[a-f\d]{2})+)+|\/)+|\?|#)?(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?:#(?:[-\w~!$ |\/.,*:;=]|%[a-f\d]{2})*)?/g,
                    function(imgUrl) {
                        // Only switch out to specific shortened urls if the agent is the user.
                        if(this.userType === AGENT_USER_TYPE) {
                            return `<a target="_blank" href="${imgUrl}" style="color:green;">here</a>`;
                        }
                        return imgUrl;
                        }.bind(this)
                    );
                    this.updateEmailMsg = this.updateEmailMsg + '\n'+ trackaquery;
                    console.log('show email changed in back end')
                    this.isUpdateEmail = true;
                }
                else{
                    console.log('error occured')
                }
            })
            .catch(error =>{
                console.log('error=='+JSON.stringify(error));
            })
        }
    }
    
    displayError(error) {
        this.error = 'Unknown error';
        if (Array.isArray(error.body)) {
            this.error = error.body.map(e => e.message).join(', ');
            this.isError =true;
            console.log('error==='+this.error);
        }
        else if (typeof error.body.message === 'string') {
            this.error = error.body.message;
            this.isError =true;
            
        }
    }

    enableSubmitButton(){
        /*if(this.errorMobile == '' && this.errorEmail == '' && this.errorName == '' && this.errorComment == ''
         && this.Mobile && this.merchantEmail && this.merchantName && this.comments && this.isloggedOut){
            this.createTicket = false;
        }
        else if(!this.isloggedOut && this.errorComment == '' && this.comments){
            this.createTicket = false;
        }
        else {
            this.createTicket = true;
        }*/

        this.createTicket = false;
        
    }

    handleFileChanges(event) {
        let files = event.target.files;
        console.log('files.length=='+files.length);

        if (files.length > 0 && files.length < 6) {
           this.showSelectedMaxFiles = false;
            let filesName = '';
            console.log('enter files');
            for (let i = 0; i < files.length; i++) {
                let file = files[i];
                console.log('file==='+ JSON.stringify(file));
                filesName = filesName + file.name + ', ';

                let freader = new FileReader();
                freader.onload = f => {
                    let base64 = 'base64,'
                    let content = freader.result.indexOf(base64) + base64.length;
                    let fileContents = freader.result.substring(content);
                    let fileData = freader.result.split(':')[1];
                    let filetype = fileData.split(';')[0];
                    console.log('filetype=='+filetype);
                    this.filesUploaded.push({
                        Title: file.name,
                        VersionData: fileContents,
                        fileType: filetype
                    });
                };
                freader.readAsDataURL(file);
            }

            this.fileNames = filesName.slice(0, -1);
    }
    else if(files.length > 5){
        this.showSelectedMaxFiles = true;
        this.errorAtt = 'Kindly select maximum 5 files.'
    }
    }

    handleSaveFiles(caseId) {
        this.showLoadingSpinner = true;
        saveFiles({filesToInsert: this.filesUploaded,caseId: caseId})
        .then(data => {
            this.showLoadingSpinner = false;
            console.log('uploaded successfully');
            this.getFilesData(data);
            console.log('data=='+data);
            this.fileNames = undefined;
        })
        .catch(error => {
            console.log('error=='+JSON.stringify(error));
        });
    }

    getFilesData(lstIds) {
        getFiles({lstFileIds: lstIds})
        .then(data => {
            data.forEach((record) => {
                record.FileName = '/' + record.Id;
            });

            this.dataFileName = data;
        })
        .catch(error => {
            window.console.log('error ====> ' + error);
        })
    }

    handleFormSubmissionEvent(evt){
        const selected = evt;
        if(selected){
            console.log('enter form submitted website create case');
         this.isformSubmitted = selected;
         const formsubmittedEvent = new CustomEvent(
             "formsubmission",
             {
                isformSubmitted : this.isformSubmitted
             }
         );
         this.dispatchEvent(formsubmittedEvent);
        }else{
         //this.isSubIssueEmpty =true;
         //this.errorSubIssue = 'this field cannot be blank';
        }
    }

}