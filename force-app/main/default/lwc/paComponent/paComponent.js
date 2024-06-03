import { LightningElement ,track} from 'lwc';

export default class PaComponent extends LightningElement {
   parentName = "PARENT COMPONENT VALUE Rohit";
    handleClick(){
       this.parentName = "Kya Baat Hai"; 
    }
}