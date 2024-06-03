public class LazyPayConsumerSchedule implements Schedulable {
	public void execute(SchedulableContext sc) {
        // We now call the batch class to be scheduled
        string strquery = 'SELECT Id, Status, JobItemsProcessed,TotalJobItems, NumberOfErrors FROM AsyncApexJob where ApexClassID = ';
        strquery += '\''+ Label.LP_LazyPayConsumerBatchId+ '\''; 
        strquery += ' and (status = \'Processing\' or status = \'Holding\' or status = \'Queued\' or status = \'Preparing\')';
        System.debug('strquery======='+strquery);
        list<AsyncApexJob> lst = Database.query(strquery);
        
            if(lst != NULL && lst.size() == 0){
                system.debug('enter=====');
                //Parameters of ExecuteBatch(context,BatchSize)
        		database.executebatch(new LazyPayConsumerBatch());
            }
     }
  }