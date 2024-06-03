import { LightningElement,api } from 'lwc';

export default class ParentComponent extends LightningElement {
    @api parentNAME = "PARENT COMPONENT VALUE Rohit";
    handleClick(){
       this.parentNAME = "Kya Baat Hai"; 
    }
}