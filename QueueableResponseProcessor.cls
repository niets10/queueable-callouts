public class QueueableResponseProcessor {

    public class Response {
        public Id accountId { get; set; }
        public String externalId { get; set; }
        // Other properties
    }

    public List<Response> responses;

    public QueueableResponseProcessor() {
        this.responses = new List<Response>();
    }

    public void processResponse(HttpResponse response, SObject sObjectAccount) {

        Account account = (Account) sObjectAccount;

        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        Response r = new Response();   
        r.accountId = account.Id;
        r.externalId = (String) body.get('externalId'); // example of a property from the body
        
        responses.add(r);
    }

    public void updateAccounts() {
        System.debug('Responses ' + responses);
        System.debug('Responses size ' + responses.size());        
    }
}
