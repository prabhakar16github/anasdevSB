@isTest
public class MAFJsonMappingTracker {
	@isTest static void testMethodOne(){      
        
        MAFJsonMapping clsMAFJsonMapping = new MAFJsonMapping();
        clsMAFJsonMapping.subject = 'www.gayoressentials.com';
        clsMAFJsonMapping.registered_contact_person_name = 	'Chirag Mehra';
        clsMAFJsonMapping.registered_address = 	'UMAC Pharmaceuticals, Janak Puri, New Delhi';
        clsMAFJsonMapping.registered_pincode = 	'110058';
        clsMAFJsonMapping.registered_mobile_number = 	'8447150055';
        clsMAFJsonMapping.registered_email = 	'chiragmehra23@yahoo.in';
        clsMAFJsonMapping.operations_contact_person_name = 	'Chirag Mehra';
        clsMAFJsonMapping.operations_address = 	'Gayore Essentials\n#3822, Sector-23,\nGurgaon, Haryana.\n';
        clsMAFJsonMapping.operations_pincode = 	'122017';
        clsMAFJsonMapping.operations_mobile_number = 	'8447150055';
        clsMAFJsonMapping.operations_email = 	'chiragmehra23@yahoo.in';
        clsMAFJsonMapping.queries_contact_name = 	'Chirag Mehra';
        clsMAFJsonMapping.queries_mobile_number = 	'8447150055';
        clsMAFJsonMapping.queries_email = 	'chiragmehra23@yahoo.in';
        clsMAFJsonMapping.account_name = 	'UMAC Pharmaceuticals';
        clsMAFJsonMapping.bank_account_number = 	'100505000446';
        clsMAFJsonMapping.bank_ifsc_code = 	'ICIC0001005';
        clsMAFJsonMapping.bank_branch_address = 	'Tilak Nagar New Delhi';
        clsMAFJsonMapping.bank_branch = 	'Tilak Nagar New Delhi';
        clsMAFJsonMapping.bank_account_type = 	'Current';
        clsMAFJsonMapping.website_url = 	'www.gayoressentials.com';
        clsMAFJsonMapping.merchant_legal_name = 	'UMAC Pharmaceuticals';
        clsMAFJsonMapping.products_and_services_sold = 	'Proteitn';
        clsMAFJsonMapping.trans_monthly_vol = 	'200';
        clsMAFJsonMapping.pan_number = 	'AADFU3370N';
        clsMAFJsonMapping.tan_number = 	'345678';
        clsMAFJsonMapping.average_cost = 	'12000';
        clsMAFJsonMapping.pay_to_name = 	'UMAC Pharmaceuticals';
        clsMAFJsonMapping.gst_number = 	'07AADFU3370N1ZT';
        clsMAFJsonMapping.merchant_business_name = 'agshdvahsdvash';        
        
        Test.startTest();
        String strJson = Json.serialize(clsMAFJsonMapping);
        MAFJsonMapping.parse(strJson);
        Test.stopTest();
    }
}