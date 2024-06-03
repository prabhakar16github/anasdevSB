public class MAFJsonMapping{
    
    public String subject;	//www.gayoressentials.com
    public String registered_contact_person_name;	//Chirag Mehra
    public String registered_address;	//UMAC Pharmaceuticals, Janak Puri, New Delhi
    public String registered_pincode;	//110058
    public String registered_mobile_number;	//8447150055
    public String registered_email;	//chiragmehra23@yahoo.in
    public String operations_contact_person_name;	//Chirag Mehra
    public String operations_address;	//Gayore Essentials\n#3822, Sector-23,\nGurgaon, Haryana.\n
    public String operations_pincode;	//122017
    public String operations_mobile_number;	//8447150055
    public String operations_email;	//chiragmehra23@yahoo.in
    public String queries_contact_name;	//Chirag Mehra
    public String queries_mobile_number;	//8447150055
    public String queries_email;	//chiragmehra23@yahoo.in
    public String account_name;	//UMAC Pharmaceuticals
    public String bank_account_number;	//100505000446
    public String bank_ifsc_code;	//ICIC0001005
    public String bank_branch_address;	//Tilak Nagar New Delhi
    public String bank_branch;	//Tilak Nagar New Delhi
    public String bank_account_type;	//Current
    public String website_url;	//www.gayoressentials.com
    public String merchant_legal_name;	//UMAC Pharmaceuticals
    public String products_and_services_sold;	//Proteitn
    public String trans_monthly_vol;	//200
    public String pan_number;	//AADFU3370N
    public String tan_number;	//
    public String average_cost;	//12000
    public String pay_to_name;	//UMAC Pharmaceuticals
    public String gst_number;	//07AADFU3370N1ZT
    public String merchant_business_name;
    
    public static MAFJsonMapping parse(String json){
        return (MAFJsonMapping) System.JSON.deserialize(json, MAFJsonMapping.class);
    }   
}