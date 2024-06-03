/*
    @author: Eitika Verma
    @company: Saasfocus
    @date : 1/11/2018
    @description: This schedule class is used to schedule the IVR call batch second time
*/
public class KYCRuleEngineSecondSchedulable implements Schedulable{
    public void execute(SchedulableContext sc) {
        // We now call the batch class to be scheduled
        KYCIVRCallBatch objKYCIVRCallBatch = new KYCIVRCallBatch(True);
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(objKYCIVRCallBatch);
     }
  }