public with sharing class CaseMerge implements Queueable {

    /*private List<EmailMessage> emailLists = new List<EmailMessage>();

    public CaseMerge(List<EmailMessage> emails){
        emailLists = emails;
    }

    public void execute(QueueableContext context) {

        if(emailLists.isEmpty()){ return; } //if no data found then exit from the transaction

        List<EmailMessage> getEmails =[SELECT Id, ParentId, Parent.Description, Parent.Subject, Parent.SuppliedEmail, FromAddress, ToAddress
                                        FROM EmailMessage 
                                        WHERE Id IN :emailLists 
                                        AND ParentId != NULL
                                        AND Parent.SuppliedEmail != NULL ORDER BY FromAddress];
        //get the parentId to fetch the cases
        Map<String, String> subjectMap = new Map<String, String>();
        Map<String, String> descriptionMap = new Map<String, String>();

        for(EmailMessage em : getEmails){

        }

    }

    public class MergeWrapper{
        public Id parentId;
        public Id duplicateId;
    }*/

    private List<Case> caseLists = new List<Case>();

    public CaseMerge(List<Case> cases){
        caseLists = cases;
    }

    public void execute(QueueableContext context) {

        if(caseLists.isEmpty()){ return; } //if no data found then exit from the transaction

        List<EmailMessage> getEmails =[SELECT Id, ParentId, Parent.Description, Parent.Subject, Parent.SuppliedEmail, FromAddress, ToAddress
                                        FROM EmailMessage 
                                        WHERE ParentId != :caseLists
                                        AND Parent.SuppliedEmail != NULL];

        //email message to check from address
        Map<Id, EmailMessage> emailMap = new Map<Id, EmailMessage>();
        for(EmailMessage em : getEmails){
            emailMap.put(em.ParentId, em);
        }

        Map<String, String> subjectMap = new Map<String, String>();
        List<Case> duplicateCase = new List<Case>();

        for(Case cs : caseLists){
            if(emailMap.containsKey(cs.Id) && emailMap.get(cs.Id)?.ToAddress == 'poojarv381@gmail.com'){
                String key = cs.Subject+'_'+cs.SuppliedEmail;
                subjectMap.put(key, cs.Id);
            }else if(emailMap.containsKey(cs.Id) && emailMap.get(cs.Id)?.ToAddress == 'poojarv961@gmail.com'){
                duplicateCase.add(cs);
            }
        }

        List<Case> updateCase = new List<Case>();
        //set parent Id to the duplicate case nd close it
        for(Case cs : duplicateCase){
            String key = cs.Subject+'_'+cs.SuppliedEmail;
            if(subjectMap.containsKey(key)){
                cs.Status = 'Closed';
                cs.ParentId = subjectMap.get(key);
                updateCase.add(cs);
            }
        }

        if(!updateCase.isEmpty()) { 

            List<Database.SaveResult> uResults = Database.update(updateCase, false);

            for(Database.SaveResult result : uResults) {
                if (!result.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : result.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }else{
                    System.debug('Successfully case closed: ' + result.getId());
                }
            }
        }
    }
}