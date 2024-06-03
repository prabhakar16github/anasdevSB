import { LightningElement, track, api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import SelectAllPreApprovedPayment from '@salesforce/apex/PricingModuleComponentController.SelectAllPreApproved';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
export default class MultiSelectPickList extends LightningElement {
    
    @api options;
    @api selectedValue;
    @api selectedValues = [];
    @api label;
    
    @api disabled = false;
    @api multiSelect = false;
    @track value;
    @track values = [];
    @track optionData;
    @track searchString;
    @track noResultMessage;
    @track showDropdown = false;
    @track hasSelectAllOption = false;// added by rohit
    @track Selectoptions;//added by rohit
    @api paymentModeId;
    isEventDispatched=false;
      //Method to show Toast Message on the UI
      showToast(title,variant,message) {
        const event = new ShowToastEvent({
            title : title,
            message : message,
            variant : variant
        });
        this.dispatchEvent(event);
    }
      connectedCallback() {
        this.showDropdown = false;
        var optionData = this.options ? (JSON.parse(JSON.stringify(this.options))) : null;
        var value = this.selectedValue ? (JSON.parse(JSON.stringify(this.selectedValue))) : null;
        var values = this.selectedValues ? (JSON.parse(JSON.stringify(this.selectedValues))) : [];
        
        if(value || values) {
            var searchString;
            var count = 0;
            for(var i = 0; i < optionData.length; i++) {
                if(this.multiSelect) {
                    if(values.includes(optionData[i].value)) {
                        optionData[i].selected = true;
                        count++;
                    }  
                } else {
                    if(optionData[i].value == value) {
                        searchString = optionData[i].label;
                    }
                }
            }
            if(this.multiSelect) {
                //this.searchString = count + ' Option(s) Selected';
                this.searchString = this.values.toString();  
            }
                
            else
                this.searchString = searchString;
        }
        
        this.value = value;
        this.values = values;
        this.optionData = optionData;
        this.handleBlur();
    }
 
    filterOptions(event) {
        this.searchString = event.target.value;
        if( this.searchString && this.searchString.length > 0 ) {
            this.noResultMessage = '';
            if(this.searchString.length >= 2) {
                
                var flag = true;
                for(var i = 0; i < this.optionData.length; i++) {
                    if(this.optionData[i].label.toLowerCase().trim().startsWith(this.searchString.toLowerCase().trim())) {
                        this.optionData[i].isVisible = true;
                        flag = false;
                    } else {
                        this.optionData[i].isVisible = false;
                    }
                }
                if(flag) {
                    this.noResultMessage = "No results found for '" + this.searchString + "'";
                }
            }
            this.showDropdown = true;
        } else {
            this.showDropdown = false;
        }
    }
 
    selectItem(event) {
        
        var selectedVal = event.currentTarget.dataset.id;
        if(selectedVal) {
            var count = 0;
            var options = JSON.parse(JSON.stringify(this.optionData));
            var isSelectAllPreApprovedPresent = false;
            options.forEach(option => {
                if ( option.value === 'Select All') {
                     isSelectAllPreApprovedPresent = false;
                }
                if(option.value === 'Select All PreApproved'){
                    isSelectAllPreApprovedPresent = true;
                }
            }); 
            /************ this if condition is Written by rohit if  value on specification selected "Select All" then mark all other values */
            if(selectedVal === 'Select All') { 
                if (this.values.length === options.length - 1) {
                    // All options except 'Select All' are already selected
                    this.values = this.values.filter(value => value !== 'Select All' ||  value !== 'Select All PreApproved'); // remove 'Select All' from 'values'
                    options.forEach(option => option.selected = false); // mark all options as unselected
                    this.values = []; // reset the 'values' array
                    this.searchString = ''; // reset the search string
                } 
                else if (this.values.length === options.length - 2 && this.values.length !=0 && isSelectAllPreApprovedPresent) {
                        // All options except 'Select All' are already selected
                        this.values = this.values.filter(value => value !== 'Select All' ||  value !== 'Select All PreApproved'); // remove 'Select All' from 'values'
                        options.forEach(option => option.selected = false); // mark all options as unselected
                        this.values = []; // reset the 'values' array
                        this.searchString = ''; // reset the search string
                }
                else {
                    // User is selecting the "Select All" option
                    //options.forEach(option => option.selected = true); // mark all options as selected
                    options.forEach(option => {
                        if (option.value !== 'Select All PreApproved') {
                            option.selected = true;
                        }
                        else if(option.value === 'Select All'){
                            option.selected = false;
                        }
                        else if (option.value === 'Select All PreApproved') {
                            option.selected = true;
                        }
                         else {
                            option.selected = false;
                        }
                    }); 
                    this.searchString = 'All Options Selected'; // update the search string to indicate all options are selected
                    // add all values to 'values' array except for 'Select All' && 'Select All PreApproved'
                    this.values = options.filter(option => option.value !== 'Select All' && option.value !== 'Select All PreApproved').map(option => option.value);
                    
                }
            }
            else if (selectedVal === 'Select All PreApproved') {
                // If the "Select All PreApproved" option was already selected, deselect all options
                console.log('includes selectallpreapporved:::'+this.values.includes('Select All PreApproved')+'  this.hasSelectAllOption::'+this.hasSelectAllOption);
                if (this.values.includes('Select All PreApproved') || (this.hasSelectAllOption)) {
                    this.values = [];
                    options.forEach(option => {
                            option.selected = false;
                    });
                  
                  this.searchString = '';
                  this.hasSelectAllOption = false;
                } else {
                 // Otherwise, select all options that are of type 'PreApproved' or have the value 'Select All PreApproved'

                  this.values = [];
                  options.forEach(option => {
                     if ( option.type === 'PreApproved' || option.value == 'Select All PreApproved') {
                      option.selected = true;
                      if (option.type=='PreApproved' || option.value != 'Select All PreApproved') {
                        this.values.push(option.value);
                        this.hasSelectAllOption = true;
                      }
                    } else {
                      option.selected = false;
                    }
                  });
                  if (this.values.length === 0) {
                    this.showToast('ERROR', 'error', 'No PreApproved Payment Gateway found');
                  } else {
                    this.searchString = 'All PreApproved Options Selected';
                  }
                }
              }

            else{
                for(var i = 0; i < options.length; i++) {
                    if(options[i].value === selectedVal) {
                        if(this.multiSelect) {
                            if(this.values.includes(options[i].value)) {
                                this.values.splice(this.values.indexOf(options[i].value), 1);
                                options.find(option => option.value === 'Select All').selected = false; // unselect the "Select All" option
                                if(options.find(option => option.value === 'Select All PreApproved')){
                                    options.find(option => option.value === 'Select All PreApproved').selected = false;
                                }
                            } 
                            else {
                                this.values.push(options[i].value);
                                if(options.find(option => option.value === 'Select All PreApproved')){
                                    options.find(option => option.value === 'Select All PreApproved').selected = false;
                                   // isSelectAllPreApprovedPresent =true;
                                }
                            }
                            options[i].selected = options[i].selected ? false : true; 
                            this.hasSelectAllOption = true; 
                        }
                        else{
                            this.value = options[i].value;
                            this.searchString = options[i].label;
                        }
                    }
                        if((options[i].value !== 'Select All' && options[i].value !== 'Select All PreApproved'  &&  options[i].selected)) {
                            count++;
                        }
                }
                    // update the search string to indicate how many options are selected
                    if(this.multiSelect){
                        this.searchString = count + ' Option(s) Selected';
                    }
            }
            this.optionData = options;
            // dispatch a custom event with the selected values
            let ev = new CustomEvent('selectoption', {detail:this.values});
            this.dispatchEvent(ev);

            if(!this.multiSelect){
                let ev = new CustomEvent('selectoption', {detail:this.value});
                this.dispatchEvent(ev);
            }

            if(this.multiSelect)
                event.preventDefault();
            else
                this.showDropdown = false;
        }
    }
 
    showOptions() {
        if(this.disabled == false && this.options) {
            this.noResultMessage = '';
            this.searchString = '';
            var options = JSON.parse(JSON.stringify(this.optionData));
            for(var i = 0; i < options.length; i++) {
                options[i].isVisible = true;
            }
            if(options.length > 0) {
                this.showDropdown = true;
            }
            this.optionData = options;
        }
    }
 
    closePill(event) {
        var value = event.currentTarget.name;
        var count = 0;
        var options = JSON.parse(JSON.stringify(this.optionData));
        for(var i = 0; i < options.length; i++) {
            if(options[i].value === value) {
                options[i].selected = false;
                this.values.splice(this.values.indexOf(options[i].value), 1);
            }
            if(options[i].selected) {
                count++;
            }
        }
        this.optionData = options;
        if(this.multiSelect){
            //this.searchString = count + ' Option(s) Selected';
            this.searchString = this.values.toString(); 
            let ev = new CustomEvent('selectoption', {detail:this.values});
            this.dispatchEvent(ev);
        }
    }
 
    handleBlur() {
        var previousLabel;
        var count = 0;

        for(var i = 0; i < this.optionData.length; i++) {
            if(this.optionData[i].value === this.value) {
                previousLabel = this.optionData[i].label;
            }
            if(this.optionData[i].selected) {
                count++;
            }
        }

        if(this.multiSelect){
            //this.searchString = count + ' Option(s) Selected';
            this.searchString = this.values.toString(); 
        }else{
            this.searchString = previousLabel;
        }

        this.showDropdown = false;
    }

    handleMouseOut(){
        this.showDropdown = false;
    }

    handleMouseIn(){
        this.showDropdown = true;
    }

    renderedCallback() {
                 
    }
}