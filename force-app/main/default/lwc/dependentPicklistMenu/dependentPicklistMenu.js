import { LightningElement } from 'lwc';

export default class DependentPicklistMenu extends LightningElement {
    selectedvalues;
    debugger;
    handlePicklist(event) {
        let selectedValues = event.detail.pickListValue;
        window.console.log('\n **** selectedValues **** \n ', selectedValues);
        this.selectedvalues = JSON.parse(JSON.stringify(selectedValues));
        window.console.log('\n **** selectedvalues ** \n ', this.selectedvalues);
    }

    
}