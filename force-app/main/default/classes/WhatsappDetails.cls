//created by Arka Patra
public class WhatsappDetails {
    
    //public wrapperObj wrpObj{get;set;}
    
    public wrapperObj getwrapperObj(){
        wrapperObj wrpObj = new wrapperObj('Arka','123456','','','WhatsappPage');
        //wrpObj.nam = '';
        //wrpObj.emailId = '';
         //wrpObj.tester = true;
        return wrpObj;
    }
    
    public pageReference setwrapperObj(){
        wrapperObj wrpObj = new wrapperObj('Arka','123456','','','WhatsappPage');
        //wrpObj.nam = '';
        //wrpObj.emailId = '';
         wrpObj.tester = true;
       PageReference acctPage = ApexPages.currentPage();
        return acctPage;
    }
    
    
    
    public class wrapperObj{
        public string nam{get;set;}
        public string wNumber{get;set;}
        public string product{get;set;}
        public string mid{get;set;}
        public string pageName{get;set;}
        public boolean tester{get;set;}
        public wrapperObj(String nam,string wNumber, string product,String mid,string pageName) {
            this.nam = nam; 
            this.wNumber = wNumber;
			this.product = product;
            this.mid = mid; 
            this.pageName = pageName;
        }
    }
    
    
}