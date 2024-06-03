import BaseChatMessage from 'lightningsnapin/baseChatMessage';
import { track } from 'lwc';

const CHAT_CONTENT_CLASS = 'chat-content';
const AGENT_USER_TYPE = 'agent';
const CHASITOR_USER_TYPE = 'chasitor';
const SUPPORTED_USER_TYPES = [AGENT_USER_TYPE, CHASITOR_USER_TYPE];

/**
 * Displays a chat message using the inherited api messageContent and is styled based on the inherited api userType and messageContent api objects passed in from BaseChatMessage.
 */
export default class BuyerChatMessage extends BaseChatMessage {
    @track messageStyle = '';
    transId;
    isStandardText = true;
    customMessage;

    isSupportedUserType(userType) {
        return SUPPORTED_USER_TYPES.some((supportedUserType) => supportedUserType === userType);
    }

    connectedCallback() {
            /*let recid = 'transId';
            console.log('firstClass');
            let firstClass = this.template.querySelector(".od-text-field");
            let val = this.template.querySelector(`[data-id="${recid}"]`);
            if(val){
                console.log('let val ', val);
                console.log(firstClass);
                this.transId = val.value;
            }else{
                //alert(val);
            }*/
            if(this.messageContent.value && this.messageContent.value.includes("tnxId=")){
                const queryString = window.location.search;
                //console.log(queryString);
                const urlParams = new URLSearchParams(queryString);
                this.transId = urlParams.get('transId')
                this.customMessage =  this.messageContent.value.replaceAll("tnxId=", `tnxId=${this.transId}`);
                //this.customMessage =  this.messageContent.value.replaceall("tnxId=", `https://help.payu.in/raise-ticket?tnxId=${this.transId}`);
                //console.log('transId ', this.transId);
                this.isStandardText = false;
                //alert(this.messageContent.value);
                //alert(this.customMessage);
            }
            
        if (this.isSupportedUserType(this.userType)) {
            this.messageStyle = `${CHAT_CONTENT_CLASS} ${this.userType}`;
        } else {
            throw new Error(`Unsupported user type passed in: ${this.userType}`);
        }
    }
}