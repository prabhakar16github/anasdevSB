import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
export default class EmailQuickAction extends NavigationMixin(LightningElement) {
    handleClick() {
        var pageRef = {
            type: "standard__quickAction",
            attributes: {
                apiName: "Global.SendEmail"
            },
            state: {
                recordId: '0060p00000D40mzAAB',
                defaultFieldValues:
                encodeDefaultFieldValues({
                    HtmlBody : "Pre-populated text for the email body.", 
                    Subject : "Pre-populated Subject of the Email"
                })
            }
        };

        this[NavigationMixin.Navigate](pageRef);
    }
}