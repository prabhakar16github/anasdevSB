global class BigObjectIterable implements iterable<Email_Message_Big_Object__b>{
   global Iterator<Email_Message_Big_Object__b> Iterator(){
      return new CustomIterable();
   }
}