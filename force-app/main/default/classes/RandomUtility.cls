public class RandomUtility {
    
    //method to return random value between 2 numbers
    public static Integer generateRandomFromRange(integer startNum, integer endNum){	
        Integer returnValue;
        Integer randomNumber = Integer.valueof((math.random() * 10));
        Boolean addSubFlag= math.mod(randomNumber,2) == 0 ? true : false;
        Integer diffInRange = endNum-startNum;
        Integer randomNum = Math.mod(Math.round(Math.random()*diffInRange+1),diffInRange);
        
        if(addSubFlag){
            if(diffInRange > 1)
                returnValue =startNum + randomNum;
            else
                returnValue =startNum;
        }else{
            if(diffInRange > 1)
                returnValue = endNum - randomNum;
            else
                returnValue =endNum;
        }
        return returnValue;
    }
    
    //method to return random number between 0 and size-1
    /*public static Integer generateRandomNumber(Integer size){
        Decimal d = math.random() * size;
        return d.intValue();
    }
    
    //method to return boolean number randomly
    public static Boolean generateRandomBoolean(){
        integer randomNumber = Integer.valueof((math.random() * 10));
        boolean returnValue= math.mod(randomNumber,2) == 0 ? true : false;
        return returnValue;
    }
    //Finding a random string value from list of strings
    public static String findRandomStringFromList(List<String> values){
        Integer randomNumber = generateRandomFromRange(0,values.size()-1);
        return values[randomNumber];
    }*/    
}