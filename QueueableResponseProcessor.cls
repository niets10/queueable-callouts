public class QueueableResponseProcessor {

    public class Response {
        public List<Feature> features { get; set; }
        public Integer featuresSize { get; set; }
        public Id accountId { get; set; }
        public String accountName { get; set; }
    }

    public class Feature {
        public String pamAddressId { get; set; }
        public String pamRecipientId { get; set; }
        public String pamPartyId { get; set; }
    }

    public List<Response> responses;

    public QueueableResponseProcessor() {
        this.responses = new List<Response>();
    }

    public void processResponse(HttpResponse response, SObject sObjectAccount) {

        Account account = (Account) sObjectAccount;

        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        List<Object> featuresObj = (List<Object>) body.get('features');
        
        List<Feature> features = new List<Feature>();
        for(Object featureObj : featuresObj) {

            Map<String, Object> feature = (Map<String, Object>) featureObj;
            Map<String, Object> ids = (Map<String, Object>) feature.get('ids');

            Feature f = new Feature();
            f.pamAddressId = (String) ids.get('pam_address_id');
            f.pamRecipientId = (String) ids.get('pam_recipient_id');
            f.pamPartyId = (String) ids.get('pam_party_id');

            features.add(f);
        }

        Response r = new Response();
        r.features = features;
        r.featuresSize = features.size();   
        r.accountId = account.Id;
        r.accountName = account.Name;
        
        responses.add(r);
    }

    public void updateAccounts() {
        System.debug('Responses ' + responses);
        System.debug('Responses size ' + responses.size());        
    }
}
