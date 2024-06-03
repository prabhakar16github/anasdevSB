import { LightningElement, wire, track, api} from 'lwc';
 
export default class Riskstatuslwc extends LightningElement {
    @api poststatuspage; 
    @api obstatuspage; 
    @api prestatuspage; 
    @api postrecidpage;
    @api obredidpage;
    @api preredidpage;
    postHoldPage;
    postparent;
    releaseparent;
    obHoldPage;
    obparent;
    releaseobparent;
    check =true;
    modelVisblity = true;
  
    
    
    handleCancel(event){
        this.modelVisblity = false;
    }

    handlePostHoldClick(){
        this.postHoldPage = true;
        this.postparent=true;
    }

    handlPostReleaseClick(event){
        this.postHoldPage = true;
        this.postparent=false;
        this.releaseparent = true;
    }
    handleOBHoldClick(event){
        this.obHoldPage = true;
        this.obparent = true;
    }

    handleOBReleaseClick(event){
        this.obHoldPage = true;
        this.releaseparent = true;
    }

    get disablePostHold(){
        return (this.poststatuspage == 'On Hold') ? true : false;
    }

    get disablePostRelease(){
        return (this.poststatuspage == 'Not On Hold') ? true : false;
    }

    get disableOBHold(){
        return (this.obstatuspage == 'On Hold') ? true : false;
    }

    get disableOBRelease(){
        return (this.obstatuspage == 'Not On Hold') ? true : false;
    }

    get disablePreHold(){
        return (this.prestatuspage == 'On Hold') ? true : false;
    }

    get disablePreRelease(){
        return (this.prestatuspage == 'Not On Hold') ? true : false;
    }

}