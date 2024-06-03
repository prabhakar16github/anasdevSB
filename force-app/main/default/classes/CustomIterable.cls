global class CustomIterable implements Iterator<Email_Message_Big_Object__b>{ 

   List<Email_Message_Big_Object__b > accs {get; set;} 
   Integer i {get; set;} 

   public CustomIterable(){ 
       accs =[SELECT Record_Id__c,ParentId__c,BccAddress__c,CcAddress__c,FromAddress__c,HtmlBody__c,RelatedTo__c,Subject__c,
        TextBody__c,ToAddress__c FROM Email_Message_Big_Object__b]; 
       i = 0; 
   }   

   global boolean hasNext(){ 
       if(i >= accs.size()) {
           return false; 
       } else {
           return true; 
       }
   }    

   global Email_Message_Big_Object__b next(){ 
       // 8 is an arbitrary 
       // constant in this example
       // that represents the 
       // maximum size of the list.
       if(i == 8){return null;} 
       i++; 
       return accs[i-1]; 
   } 
}