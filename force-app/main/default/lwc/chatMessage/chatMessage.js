import BaseChatMessage from 'lightningsnapin/baseChatMessage';
import { track,api } from 'lwc';

const CHAT_CONTENT_CLASS = 'chat-content';
const AGENT_USER_TYPE = 'agent';
const CHASITOR_USER_TYPE = 'chasitor';
const SUPPORTED_USER_TYPES = [AGENT_USER_TYPE, CHASITOR_USER_TYPE];
const DEFAULT_MESSAGE_PREFIX = 'ANY_TEXT';
const YOUTUBE_MESSAGE_PREFIX = 'YOUTUBE';
const IMAGE_MESSAGE_PREFIX = 'IMAGE';
const WEBSITE_MESSAGE_PREFIX = 'WEBSITE';
const Create_CASE = 'CREATECASE';
const FILE_UPLOAD = 'FILEUPLOAD';
const MODAL_OPEN = 'OPENMODAL';

const SUPPORTED_MESSAGE_PREFIX = [DEFAULT_MESSAGE_PREFIX, YOUTUBE_MESSAGE_PREFIX, IMAGE_MESSAGE_PREFIX, WEBSITE_MESSAGE_PREFIX, Create_CASE,FILE_UPLOAD,MODAL_OPEN];







/**
 * Displays a chat message that replaces links with custom text.
 */
export default class ShortenedLinksSample extends BaseChatMessage {

    messageType = DEFAULT_MESSAGE_PREFIX;
    messageStyle = '';
    text = '';
    isformSubmitted = false;
    @api messageContentType;
    
    isSupportedUserType(userType) {
        return SUPPORTED_USER_TYPES.some((supportedUserType) => supportedUserType === userType);
    }

    constructor(){
        super();
    }

    connectedCallback() {
    
    if (this.isSupportedUserType(this.userType)) {

    this.messageContentType = this.messageContent;
    const messageTypePrefixPosition = SUPPORTED_MESSAGE_PREFIX.indexOf(this.messageContent.value.split(':')[0]);
    if (messageTypePrefixPosition > -1) {
        this.messageType = SUPPORTED_MESSAGE_PREFIX[messageTypePrefixPosition];
    }

    

    //console.log('message type=='+this.messageType);

    const contentValue = (this.messageContent.value.split(this.messageType + ':').length === 1) ? this.messageContent.value : this.messageContent.value.split(this.messageType + ':')[1];
    if (this.isYoutube) {
    this.text = 'https://www.youtube.com/embed/' + contentValue;
    } else if (this.isImage) {
        this.text = this.extractOriginalString(contentValue);
    }else if (this.isWebsite) {
        this.text = this.messageStyle = `${CHAT_CONTENT_CLASS} ${this.userType}`;
        this.text = contentValue;
    }
    else if(this.isCaseCreation){        
    }

    else if(this.isfileUpload){
    }

    else if(this.isModalOpen){
    }


    else if(this.isAnyText){
            //console.log('enter any text');
            //Set our messageStyle class to decorate the message based on the user.
            this.messageStyle = `${CHAT_CONTENT_CLASS} ${this.userType}`;
            this.text = this.messageContent.value;
            
            this.text = this.messageContent.value
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
    }
    }
    else {
        throw new Error(`Unsupported user type passed in: ${this.userType}`);
    }
    }



    extractOriginalString(generatedString) {
        const matched = generatedString.match(/<a href.+>(.*?)<\/a>/);
        if (matched.length > 1) {
            return matched[1];
        }
        return generatedString;
    }

    

    get isAgent() {
        return (this.userType === AGENT_USER_TYPE);
    }

    get isChatVisitor(){
        return (this.userType === CHASITOR_USER_TYPE);
    }

    get isAnyText() {
        return (this.messageType === DEFAULT_MESSAGE_PREFIX);
    }

    get isYoutube() {
        return this.messageType === YOUTUBE_MESSAGE_PREFIX;
    }
    
    get isImage() {
        return this.messageType === IMAGE_MESSAGE_PREFIX;
    }

    get isWebsite() {
        return this.messageType === WEBSITE_MESSAGE_PREFIX;
    }

    get isCaseCreation() {
        return this.messageType === Create_CASE;
    }

    get isfileUpload() {
        return this.messageType === FILE_UPLOAD;
    }

    get isModalOpen(){
        return this.messageType === MODAL_OPEN;
    }


    handleSubmitCaseEvent(event){
        console.log('enter form submittion to true')
        this.isformSubmitted = event.isformSubmitted;
    }
}