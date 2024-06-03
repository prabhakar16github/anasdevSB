public class CustomizedRatesJSONParser {
    public String code;
	public String message;
	public Integer status;
	public List<Result> result;

	public class Result {
        public String clientId;
		public String merchantId;
		public String ruleId;
		public String paymentMode;
		public String type;
		public String debitModel;
		public String subPaymentMode;
		public String paymentScheme;
		public String paymentEntity;
		public Double moreThanAmount;
		public Integer isOnus;
		public String refundMode;
		public String cardType;
		public String validFrom;
		public String validTill;
		public String gmvLimit;
		public String gmvLimtMode;
		public Double flatFee;
		public Double percentageFee;
		public String tdrType;
        
		/*public String clientId;
		public String merchantId;
		public String ruleId;
		public String paymentMode;
		public String type;
		public String debitModel;
		public Object subPaymentMode;
		public Object paymentScheme;
		public Object paymentEntity;
		public Double moreThanAmount;
		public Integer isOnus;
		public Object refundMode;
		public String cardType;
		public String validFrom;
		public Object validTill;
		public Object gmvLimit;
		public Object gmvLimtMode;
		public Double flatFee;
		public Double percentageFee;
		public String tdrType;*/
	}

	
	public static CustomizedRatesJSONParser parse(String json) {
        System.debug('Parsed value is: ' +(CustomizedRatesJSONParser) System.JSON.deserialize(json, CustomizedRatesJSONParser.class));
		return (CustomizedRatesJSONParser) System.JSON.deserialize(json, CustomizedRatesJSONParser.class);
	}

}