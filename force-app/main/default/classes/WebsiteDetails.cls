public class WebsiteDetails {
    
    //public wrapperObj wrpObj{get;set;}
    
    public wrapperObj getwrapperObj(){
        System.debug('USER: '+UserInfo.getUserId());
        wrapperObj wrpObj = new wrapperObj('guest1','PayUbiz','8006686','WebsitePage');
        //wrpObj.nam = '';
        //wrpObj.emailId = '';
         //wrpObj.tester = true;
        return wrpObj;
    }
    
    public pageReference setwrapperObj(){
        System.debug('USER: '+UserInfo.getUserId());
        wrapperObj wrpObj = new wrapperObj('guest1','PayUbiz','7210493','WebsitePage');
        //wrpObj.nam = '';
        //wrpObj.emailId = '';
         //wrpObj.tester = true;
       PageReference acctPage = ApexPages.currentPage();
        return acctPage;
    }
    
    
    
    public class wrapperObj{
        public string nam{get;set;}
        public string product{get;set;}
        public string mid{get;set;}
        public string pageName{get;set;}
        public boolean tester{get;set;}
        public wrapperObj(String nam,string product, String mid,string pageName) {
            this.nam = nam; 
			this.product = product;
            this.mid = mid; 
            this.pageName = pageName;
        }
    }
    
    
}