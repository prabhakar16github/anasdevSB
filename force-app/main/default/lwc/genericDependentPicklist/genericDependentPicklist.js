import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
export default class GenericDependentPicklist extends LightningElement {
   @api
   objectApiName;
   //An Api Name for Controlling PickList Field
   @api
   controllingPicklistApiName;
   //An Api Name for Dependent Picklist for any Object
   @api
   dependentPicklistApiName;
   // to show the label for the dependent field
   @api
   dependentPicklistLabel;
   // to show the label for the controlling field
   @api
   controllingPicklistLabel;
   //An Object to fill show user all available options
   @track
   optionValues = {controlling:[], dependent:[]};
   //To fill all controlling value and its related valid values
   allDependentOptions={};
   //To hold what value, the user selected.
   @track
   selectedValues = {controlling:undefined, dependent:undefined};
   //Invoke in case of error.
   isError = false;
   errorMessage;
   //To Disable Dependent PickList until the user won't select any parent picklist.
   isDisabled = true;
   //An Api Name of record type id
   @api
   recordTypeId;

   @api
   issue;

   @api
   subIssue;
   
   @track
   ShowDependentPicklist = true;

   isSubIssueEmpty = false;
   isIssueEmpty = false;
   errorIssue ='';
   errorSubIssue = '';
   lengthDependent = 0;
   optionVals = {controlling:[], dependent:[]};


   /*controllingPicklist=[];
   dependentPicklist;
   @track finalDependentVal=[];
   @track selectedControlling="--None--";

   showpicklist = false;
   dependentDisabled=true;
   showdependent = false;*/

   @wire(getObjectInfo, {objectApiName : '$objectApiName'})
   objectInfo;
   @wire(getPicklistValuesByRecordType, { objectApiName: '$objectApiName', recordTypeId: '$recordTypeId'})
   fetchValues({error, data}){
       console.log('enter fetch values');
       if(!this.objectInfo){
           console.log('enter not obj info');
           this.isError = true;
           this.errorMessage = 'Please Check Your Object Settings';
           return;
       }
       if(data && data.picklistFieldValues){
           try{
               this.setUpControllingPicklist(data);
               this.setUpDependentPickList(data);
           }catch(err){
               this.isError = true;
               this.errorMessage = err.message;
               console.log('enter not catch err');
               console.log('this.errorMessage=='+JSON.stringify(this.errorMessage));
           }
       }else if(error){
           this.isError = true;
           console.log('actual error msg=='+JSON.stringify(error));
           this.errorMessage = 'Object is not configured properly please check';
       }
   }
   //Method to set Up Controlling Picklist
   setUpControllingPicklist(data){
       this.optionValues.controlling = [{ label:'None', value:'' }];
       if(data.picklistFieldValues[this.controllingPicklistApiName]){
           data.picklistFieldValues[this.controllingPicklistApiName].values.forEach(option => {
               this.optionValues.controlling.push({label : option.label, value : option.value});
           });
           if(this.optionValues.controlling.length == 1)
               throw new Error('No Values Available for Controlling PickList');
       }else
           throw new Error('Controlling Picklist doesn\'t seems right');
   }
   //Method to set up dependent picklist
   setUpDependentPickList(data){
       if(data.picklistFieldValues[this.dependentPicklistApiName]){
           if(!data.picklistFieldValues[this.dependentPicklistApiName].controllerValues){
               throw new Error('Dependent PickList does not have any controlling values');
           }
           if(!data.picklistFieldValues[this.dependentPicklistApiName].values){
               throw new Error('Dependent PickList does not have any values');
           }
           this.allDependentOptions = data.picklistFieldValues[this.dependentPicklistApiName];
       }else{
           throw new Error('Dependent Picklist Doesn\'t seems right');
       }
   }
   handleControllingChange(event){
       console.log('slectedvalue=='+event.target.value);
       this.selectedValues = {controlling:undefined, dependent:undefined};
       const selected = event.target.value;
       if(selected && selected != 'None'){
           this.isIssueEmpty = false;
           console.log('controlling='+selected);
           this.selectedValues.controlling = selected;
           this.selectedValues.dependent = [];
           this.optionVals.dependent = [];
           this.optionValues.dependent = [];
           let controllerValues = this.allDependentOptions.controllerValues;
           this.allDependentOptions.values.forEach( val =>{
               val.validFor.forEach(key =>{
                   if(key === controllerValues[selected]){
                       console.log('key=='+key+' controllervalues[sd]=='+controllerValues[selected]);
                       this.lengthDependent = this.lengthDependent + 1;
                       this.isDisabled = false;
                       this.optionVals.dependent.push({label : val.label, value : val.value});
                       this.optionValues.dependent.push({label : val.label, value : val.value});
                   }
               });
           });
           this.isSubIssueEmpty =true;
           this.errorSubIssue = 'this field cannot be blank';

           const selectedrecordevent = new CustomEvent(
                "selectedpicklists", {
                    detail : { pickListValue : this.selectedValues}
                }
            );
            this.dispatchEvent(selectedrecordevent);

           if(this.optionVals.dependent && this.optionVals.dependent.length > 1){

           }
           else{
               this.optionVals.dependent = [];
               this.isDisabled = true;
           }
       }else{
           this.isDisabled = true;
           this.selectedValues.dependent = [];
           this.selectedValues.controlling = [];
           this.isIssueEmpty =true;
           this.errorIssue = 'this field cannot be blank';
       }
   }
   handleDependentChange(event){
       const selected = event.target.value;
       if(selected){
        this.selectedValues.dependent = selected;
        this.optionValues.dependent = [];
        /*this.optionValues.dependent = [{label : 'None', value : ''}];
        if(this.lengthDependent > 0){
            for(var i=0 ; i < this.lengthDependent ; i++){
                 console.log('optionVals.dependent[i]=='+JSON.stringify(this.optionVals.dependent[i]));
                 this.optionValues.dependent.push(this.optionVals.dependent[i]);
            }*/
            this.isSubIssueEmpty =false;
        const selectedrecordevent = new CustomEvent(
            "selectedpicklists",
            {
                detail : { pickListValue : this.selectedValues}
            }
        );
        this.dispatchEvent(selectedrecordevent);
       }else{
        this.isSubIssueEmpty =true;
        this.errorSubIssue = 'this field cannot be blank';
       }
   }


}