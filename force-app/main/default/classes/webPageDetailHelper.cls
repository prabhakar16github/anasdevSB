public class webPageDetailHelper {
    public class WebPageDetailParser {
        public String name;
        public String status;
        public Boolean is_present;
        public string error;
        public string remarks;
    }
    
    
    public static List<WebPageDetailParser> parse(String json) {
        return (List<WebPageDetailParser>) System.JSON.deserialize(json, List<WebPageDetailParser>.class);
    }
    
    public static void statusApprovedSerialization(Map<string,List<string>> pageDetailWithNameMap, string statusValue){
        List<string> pgDetailString;
        for(Website_Page_Master__c wpm : [Select Name,Active__c,Integration_Type__c,Page_Details__c,Product__c from Website_Page_Master__c Where Active__c=:true]){
            if(Test.isRunningTest()) {
                if(!wpm.Page_Details__c.startsWith('[')){
                 	wpm.Page_Details__c = '['+wpm.Page_Details__c+']';   
                }
            }
            system.debug('-->> wpm.Page_Details__c -- '+wpm.Page_Details__c);
            //List<WebPageDetailParser> webParserList = parse(wpm.Page_Details__c);
            //List<WebPageDetailParser> webParserUpdatedList = New List<WebPageDetailParser>();
            
            if(string.isNotBlank(wpm.Page_Details__c)){   
                if(wpm.Name == 'Contact Us Details' && string.isNotBlank(wpm.Name)){
                    pgDetailString = New List<string>();
                    for(WebPageDetailParser webParser : parse(wpm.Page_Details__c)){                    
                        if(string.isNotBlank(webParser.status) && webParser.status <> statusValue){                    
                            webParser.status = statusValue;
                            pgDetailString.add(JSON.serialize(webParser));
                            if(!pageDetailWithNameMap.containskey('Contact Us Details')){
                                pageDetailWithNameMap.put('Contact Us Details',pgDetailString);
                            }
                        }
                    }
                }
                
                if(wpm.Name == 'Terms & Conditions Details' && string.isNotBlank(wpm.Name)){
                    pgDetailString = New List<string>();
                    for(WebPageDetailParser webParser : parse(wpm.Page_Details__c)){
                        if(string.isNotBlank(webParser.status) && webParser.status <> statusValue){                    
                            webParser.status = statusValue;
                            pgDetailString.add(JSON.serialize(webParser));
                            if(!pageDetailWithNameMap.containskey('Terms & Conditions Details')){
                                pageDetailWithNameMap.put('Terms & Conditions Details',pgDetailString);
                            }
                        }
                    }  
                }
                
                if(wpm.Name == 'Product/Services Details' && string.isNotBlank(wpm.Name)){
                    pgDetailString = New List<string>();
                    for(WebPageDetailParser webParser : parse(wpm.Page_Details__c)){
                        if(string.isNotBlank(webParser.status) && webParser.status <> statusValue){                    
                            webParser.status = statusValue;
                            pgDetailString.add(JSON.serialize(webParser));
                            if(!pageDetailWithNameMap.containskey('Product/Services Details')){
                                pageDetailWithNameMap.put('Product/Services Details',pgDetailString);
                            }
                        }
                    }
                }                    
            }
            
        }
        system.debug('-->>> pagedetal Map  '+pageDetailWithNameMap);
    }
    
}