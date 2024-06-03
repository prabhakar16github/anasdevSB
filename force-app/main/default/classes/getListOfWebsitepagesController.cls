public class getListOfWebsitepagesController {
    public ID strOptyId {get; set;}  
    public errorDataWrapper objWrapper {get; set;}
    public List<errorDataWrapper> wrapperList {get; set;}
    //private final List<errorDataWrapper> obj;
    
    public List<errorDataWrapper> objerrorDataWrapper{
    get {
        return fetchData();
    }
    	set;
    }
    
    public getListOfWebsitepagesController(){}
    
    public List<errorDataWrapper> fetchData(){
        List<errorDataWrapper> wrapperList = new List<errorDataWrapper>();
		/*objWrapper = new errorDataWrapper();
		objWrapper.websitePagesName = '';
		objWrapper.websitePagesError = '';
		wrapperList.add(objWrapper);   */     
        List<Website_Page__c> wp = [SELECT Id, Name, Page_Details__c FROM Website_Page__c WHERE Opportunity__c = :strOptyId];
        system.debug('-->> '+strOptyId+' - '+wp);
        for(Website_Page__c page : wp){
            system.debug('-->> '+page.Page_Details__c);
            if(page.Page_Details__c != null){
            List<webPageDetailHelper.WebPageDetailParser> pgDetails = webPageDetailHelper.parse(page.Page_Details__c);
        	for(webPageDetailHelper.WebPageDetailParser wpdp : pgDetails){    
                if(wpdp.status == 'Rejected'){
                    objWrapper = new errorDataWrapper();
                    objWrapper.websitePagesName = wpdp.name;
                    objWrapper.websitePagesError = wpdp.error;
                    wrapperList.add(objWrapper);
                }
        	}
        }
        }
        return wrapperList;
    }
    
    public class errorDataWrapper{
        public String websitePagesName {get; set;}
		public String websitePagesError {get; set;}
    }
}