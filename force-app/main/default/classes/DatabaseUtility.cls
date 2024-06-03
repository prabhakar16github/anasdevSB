public class DatabaseUtility{
	/*----------------------------------------------------------------------------------------------------
        Description:    method to get the list of email templates record based on email template name 
        Inputs:         String strDeveloperName
        Outputs:        List<EmailTemplate>
        History
        <Date>      <Authors Name>      <Brief Description of Change>
        11-June-18   Uma Shankar		Created
    ----------------------------------------------------------------------------------------------------*/
    public static List<EmailTemplate> getEmailTemplate(String strDeveloperName){
        if(String.isNotBlank(strDeveloperName)){
            system.debug('database utility strDeveloperName &&&&&&&&&& '+strDeveloperName);
            return [SELECT Id, Name, Description, DeveloperName, HtmlValue,
                    FolderId, IsActive, Subject, Body
                    FROM EmailTemplate
                    WHERE DeveloperName =: strDeveloperName
                    AND IsActive =: True Limit 1];
        }
        return null;
    }

	/*------------------------------------------------------------
        Description:    method to get the list of attachment records 
        Inputs:         Id
        Outputs:        list<Attachment>
        History
        <Date>      <Authors Name>      <Brief Description of Change>
        11-June-18   Uma Shankar		Created
    ------------------------------------------------------------*/
    public static list<Attachment> getListAttachment(Id parentId){
        if(String.isNotBlank(parentId)){
            return [SELECT id, Name, Body, BodyLength, ContentType 
                    FROM Attachment
                    WHERE ParentId =: parentId];
        }
        return null;
    }    
}