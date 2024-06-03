/*
* Name of the class : AggregateResultIterator
* Author's Name     : Anas Yar Khan  
* Created Date      : 21th Oct, 2022
* Description       : Custom Iterator class to support Aggregate Queries in the batch class
* Version.          : 1   
*/ 
global class AggregateResultIterator implements Iterator<AggregateResult> {
  AggregateResult [] results {get;set;}
  Integer index {get; set;} 
       
  global AggregateResultIterator(String query) {
    index = 0;
    results = Database.query(query);            
  } 

  global boolean hasNext(){ 
    return results != null && !results.isEmpty() && index < results.size(); 
  }    

  global AggregateResult next(){        
    return results[index++];            
  }       
}