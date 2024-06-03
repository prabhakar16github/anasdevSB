public with sharing class JiraWrapper {

	//public String projectKey;
	//public Integer issueTypeId;
	public String summary;
	public String description;
	public String assigneeTo;
	public String reporterTo;
	//public CustomField customField;
    public String engineeringTeam;
	public Integer priority;

	/*public class CustomField {
		public Integer bugCategory;
		public Integer bugSource;
		public Integer productTeams;
	}*/
    
    public class Comments {
        public String author;
        public String comment;
    }


    public class JiraResponse {
        public String jiraId;
        public String status;
        public String description;
        public String summary;
        public String assignee;
        public String reporter;
        public List<Comments> comments;
        public String jiraIdUrl;
    }
	
	public static JiraWrapper.JiraResponse parseResponse(String json) {
		return (JiraWrapper.JiraResponse) System.JSON.deserialize(json, JiraWrapper.JiraResponse.class);
	}

    public static JiraWrapper parseLWCRequest(String json) {
		return (JiraWrapper) System.JSON.deserialize(json, JiraWrapper.class);
	}

}