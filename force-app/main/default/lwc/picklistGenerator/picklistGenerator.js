import { LightningElement, api, track } from 'lwc';
import getPickListValues from "@salesforce/apex/PicklistController.getPickListValues";
import getDependentOptions from "@salesforce/apex/PicklistController.getDependentOptions";
import getFieldLabel from "@salesforce/apex/PicklistController.getFieldLabel";

export default class SelectComponent extends LightningElement {
    @track options;
    @track selectedOptions = 'Select';
    @track isAttributeRequired = true;
    @api fieldName;
    @api objectName;
    @api controllingFieldName;
    @api label;
    contrFieldValue;
    @track fieldLabelName;

    @track optionValues = {controlling:[], dependent:[]};
    @track allDependentData;
    @track
    selectedValues = {controlling:undefined, dependent:undefined};
    @track isPicklistDisabled = false;



    connectedCallback() {
        if(this.controllingFieldName) {
            console.log('enter get dependent values');
            console.log('this.objectName==='+this.objectName);
            console.log('this.controllingFieldName==='+this.controllingFieldName);

            getPickListValues({ objApiName: this.objectName, fieldName: this.controllingFieldName })
            .then(data => {
                console.log('data getpicklist=='+JSON.stringify(data));
                this.optionValues.controlling = data;
            })
            .catch(error => {
                console.log('enter error=='+error.body.message);
                this.displayError(error);
            });
        //}else{
            getDependentOptions({ objApiName: this.objectName, fieldName: this.fieldName, contrFieldApiName: this.controllingFieldName })
            .then(data => {
                console.log('data=='+JSON.stringify(data));
                this.allDependentData = data;
            })
            .catch(error => {
                this.displayError(error);
            });
        }
        

        if(!this.label) {
            getFieldLabel({objName:this.objectName,fieldName:this.fieldName})
            .then(data => {
                this.fieldLabelName = data;
            })
            .catch(error => {
                this.displayError(error);
            });
        }
        else {
            this.fieldLabelName = this.label;
        }
    }


    handleControllingChange(event){
        const selected = event.target.value;
        if(selected && selected != 'None'){
            this.selectedValues.controlling = selected;
            this.selectedValues.dependent = null;
            //this.optionValues.dependent = [{ label:'None', value:'' }];
            console.log('allDependentData=='+JSON.stringify(this.allDependentData));
            //let controllerValues = this.allDependentData[];
            this.optionValues.dependent = this.allDependentData[selected];
            /*for (let [key, value] of this.allDependentData[selected]) {
                this.optionValues.dependent.push(key,value);
            }*/
 
            
            if(this.optionValues.dependent && this.optionValues.dependent.length > 1){
                console.log('depenfent list has values greater than 1');
            }
            else{
                console.log('this.optionValues.dependent==='+this.optionValues.dependent);
                console.log('set dependent list to 1');
                this.optionValues.dependent = [];
                this.isPicklistDisabled = true;
            }
        }else{
            this.isPicklistDisabled = true;
            this.selectedValues.dependent = [];
            this.selectedValues.controlling = [];
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
}