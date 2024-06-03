/*
    @author: Eitika Verma
    @company: Saasfocus
    @date : 1/11/2018
    @description: This schedule class is used to schedule the KYC Rule Engine
*/
public class KYCRuleEngineSchedule implements Schedulable{
    public void execute(SchedulableContext sc) {
        // We now call the batch class to be scheduled
        KYCRuleEngineBatch objKYCRuleEngineBatch = new KYCRuleEngineBatch();
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(objKYCRuleEngineBatch);
     }
  }