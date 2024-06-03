/*
* Name of the class : AggregateResultIterable
* Author's Name     : Anas Yar Khan  
* Created Date      : 21th Oct, 2022
* Description       : Custom Iterator class to support Aggregate Queries in the batch class
* Version.          : 1   
*/
global class AggregateResultIterable implements Iterable<AggregateResult> {
  private String query;

  global AggregateResultIterable(String soql){
    query = soql;
  }

  global Iterator<AggregateResult> Iterator(){
    return new AggregateResultIterator(query);
  }
}