public class QueueableCallout implements Queueable, Database.AllowsCallouts {
    
    // 5 for developer edition orgs, production orgs have no practical limit, test cases have a limit of 0
    @TestVisible
    private static final Integer MAX_QUEUE_DEPTH = 2147483647;
    // Max 100 callouts per single transaction
    @TestVisible
    private static final Integer DEFAULT_BATCH_SIZE = 3;

    private QueueableCalloutWorker worker;
    private List<sObject> records;

    public QueueableCallout(QueueableCalloutWorker worker, List<sObject> records) {
        this.worker = worker;
        this.records = records;
    }

    public static void startJob(List<sObject> records) {
        System.enqueueJob(
            new QueueableCallout(new QueueableCalloutWorker(0, DEFAULT_BATCH_SIZE), records)
        );
    }

    public void execute(QueueableContext context) {
        Map<Id, sObject> recordsMap = new Map<Id,sObject>(records);        

        // Insert 7
        for (sObject record : recordsMap.values()) {
            // Execute callout
            HttpResponse response = worker.doJob(record);
            responseProcessor.processResponse(response, record);

            // Removed processed sObject
            recordsMap.remove(record.Id);
            
            // Check the maximum length of the batch (100), if it is more than that, chain a new job
            if (worker.nextJob()) break;
        }

        if (worker.nextJob() && !recordsMap.values().isEmpty() && !Test.isRunningTest()) {
            chainNewJob(recordsMap.values());            
        }

        // Process response
    }

    private void chainNewJob(List<sObject> remainingRecords) {
        QueueableCallout nextQueuable = new QueueableCallout(
            worker.nextWorker(), 
            remainingRecords
        );

        if( worker.queueDepth >= MAX_QUEUE_DEPTH ) {
            System.debug('Maximum queue depth reached. Prematurely aborting job');
        } else {
            System.debug('Batch was full, enqueueing a subsequent batch');
            System.enqueueJob( nextQueuable );
        }
    }
}