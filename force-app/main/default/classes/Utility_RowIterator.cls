public class Utility_RowIterator implements Iterator<String>, Iterable<String>{
   public String dataMatcher;
   public Integer indexMatcher = 0;
   public String rowDelimiterMatcher = '\n';

   public Utility_RowIterator(String fileData){
      dataMatcher = fileData; 
   }
    
   public Utility_RowIterator(String fileData, String rowDelimiter){
      dataMatcher = fileData; 
      rowDelimiterMatcher = rowDelimiter;
   }

   public Boolean hasNext(){
      return indexMatcher < dataMatcher.length() ? true : false;
   }
    
   public String next(){     
      Integer key = dataMatcher.indexOf(rowDelimiterMatcher, indexMatcher);

      if (key == -1)
        key = dataMatcher.length();

      String row = dataMatcher.subString(indexMatcher, key);
      indexMatcher = key + 1;
      return row;
   }
    
   public Iterator<String> Iterator(){
      return this;   
   }
}