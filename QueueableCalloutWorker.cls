public class QueueableCalloutWorker {
    
    public static List<Id> processedIds;
    private Boolean nextJob = false;
    private Integer workerBatchSize;
    public Integer queueDepth;

    static {
        processedIds = new List<Id>();
    }

    public QueueableCalloutWorker(Integer queueDepth, Integer workerBatchSize) {
        this.queueDepth = queueDepth;
        this.workerBatchSize = workerBatchSize;
    }

    public HttpResponse doJob(sObject record) {
        processedIds.add(record.Id);

        // Max of callouts per transaction
        if (processedIds.size() >= workerBatchSize) {
            this.nextJob = true;
        }

        return executeCallout();
    }

    public static HttpResponse executeCallout() {

       return CalloutGenerator.executeCallout('GET', 'yourendpoint');
    }

    public Boolean nextJob(){
        return nextJob;
    }

    public QueueableCalloutWorker nextWorker() {
        return new QueueableCalloutWorker(
            this.queueDepth + 1,
            this.workerBatchSize
        );
    }
}