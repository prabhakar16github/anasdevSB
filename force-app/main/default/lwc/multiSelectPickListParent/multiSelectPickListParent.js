import { LightningElement, track } from 'lwc';
const options = [
                    {'label':'India','value':'India'},
                    {'label':'UK','value':'UK'},
                    {'label':'UAE','value':'UAE'},
                    {'label':'USA','value':'USA'},
                    {'label':'China','value':'China'},
                    {'label':'Russia','value':'Russia'},
                    {'label':'Thailand','value':'Thailand'},
                    {'label':'Japan','value':'Japan'},
                    {'label':'Canada','value':'Canada'}
                ];
 
export default class MultiSelectPickListParent extends LightningElement {
    @track selectedValue = 'India,UK';
    @track selectedValueList = ['India','UK'];
    
    @track options = options;
     
    //for single select picklist
    handleSelectOption(event){
        //alert(event.detail);
        this.selectedValue = event.detail;
        //alert(this.selectedValue);
    }
 
    //for multiselect picklist
    handleSelectOptionList(event){
        //alert(event.detail);
        this.selectedValueList = event.detail;
        //alert(this.selectedValueList);
    }
}