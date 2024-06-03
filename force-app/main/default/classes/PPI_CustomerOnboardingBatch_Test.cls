@isTest
public class PPI_CustomerOnboardingBatch_Test {
	@isTest
    static void test1(){
        String str1 = 'Client Name,Client Id,SOR Customer ID,Customer Id,Customer First Name,Customer Middle Name,Customer Last Name,Mobile,Email,PAN,OVD Type,OVD Number,Address,City,State,Pin code,DOB,Mobile validation flag,Email validation flag,Dedupe and Internal blacklisting flag,KYC Status,Name Screening status,Risk Score,Risk Category\n';
        String str2 = str1 + 'WIBMOBANK,1234,,62507sree402,Sree,,S,919597883995,sree.kumar@wibmo.com,ABCDE1234A,,,"Chennai, Chennai_1, Chennai_2, Chennai_3",Chennai,TamilNadu,123456,1993-07-11,N,N,N,FULL_KYC,N,100,Medium Risk\n';
        
    	Database.executeBatch(new PPI_CustomerOnboardingBatch(str2,'testfile.csv'));
    }
    
    @isTest
    static void test2(){
        String str1 = 'Client Name,Client Id,SOR Customer ID,Customer Id,Customer First Name,Customer Middle Name,Customer Last Name,Mobile,Email,PAN,OVD Type,OVD Number,Address,City,State,Pin code,DOB,Mobile validation flag,Email validation flag,Dedupe and Internal blacklisting flag,KYC Status,Name Screening status,Risk Score,Risk Category\n';
        String str2 = str1 + 'WIBMOBANK,1234,,62507sree402,Sree,,S,919597883995,sree.kumar@wibmo.com,ABCDE1234A,,,"Chennai, Chennai_1, Chennai_2, Chennai_3",Chennai,TamilNadu,123456,1993-07-11,N,N,N,FULL_KYC,';
        
    	Database.executeBatch(new PPI_CustomerOnboardingBatch(str2,'testfile.csv'));
    }
    
    @isTest
    static void test3(){
        String str1 = 'Client Name,Client Id,SOR Customer ID,Customer Id,Customer First Name,Customer Middle Name,Customer Last Name,Mobile,Email,PAN,OVD Type,OVD Number,Address,City,State,Pin code,DOB,Mobile validation flag,Email validation flag,Dedupe and Internal blacklisting flag,KYC Status,Name Screening status,Risk Score,Risk Category\n';
        String str2 = str1 + 'WIBMOBANK,1234,,,,,S,919597883995,sree.kumar@wibmo.com,ABCDE1234A,,,"Chennai, Chennai_1, Chennai_2, Chennai_3",Chennai,TamilNadu,123456,1993-07-11,N,N,N,FULL_KYC,N,100,Medium Risk';
        
    	Database.executeBatch(new PPI_CustomerOnboardingBatch(str2,'testfile.csv'));
    }
}