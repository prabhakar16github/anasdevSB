import { LightningElement,track,api } from 'lwc';

export default class AgreementTabComponent extends LightningElement {
    @track firstScreenVal = true;
    @track secondScreenVal = false;

    firstScreen(){
        this.secondScreenVal = false;
        this.firstScreenVal = true; 
        this.secondScreenVal_2 = false;
        this.secondScreenVal_3 = false;

    }
    secondScreen(){
        this.secondScreenVal = true;
        this.firstScreenVal = false; 
    }
    secondScreen_2(){
        this.secondScreenVal = false;
        this.firstScreenVal = false; 
        this.secondScreenVal_2 = true;
    }
    secondScreen_3(){
        this.secondScreenVal = false;
        this.firstScreenVal = false; 
        this.secondScreenVal_2 = false;
        this.secondScreenVal_3 = true;
    }


    value = '';

    get options() {
        return [
            { label: 'Standard Agreement', value: 'option1' },
            { label: 'Custom Agreement', value: 'option2' },
            { label: 'Upload Agreement', value: 'option3' }
        ];
    }
}