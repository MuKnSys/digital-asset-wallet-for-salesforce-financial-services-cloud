@SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
public class CryptoAccountExternalCalloutQueue implements Queueable, Database.AllowsCallouts {
    private List<Crypto_Account__c> cryptoAccounts;

    public CryptoAccountExternalCalloutQueue(List<Crypto_Account__c> cryptoAccounts) {
        this.cryptoAccounts = cryptoAccounts;
    }

    public void execute(QueueableContext context) {
        String orgId = OrganizationService.getOrganizationId();
        String baseUrl = MuknSettings.muknCaAppUrl;
        for (Crypto_Account__c record : cryptoAccounts) {
            if (String.isBlank(record.Financial_Account__c)) {
                System.debug('No Financial_Account__c for Crypto_Account__c ' + record.Id);
                continue;
            }
            String endpoint = baseUrl + '/salesforce/organization/' + orgId + '/financial-account/' + record.Financial_Account__c + '/assets';
            System.debug('Calling PUT endpoint: ' + endpoint);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('PUT');
            req.setHeader(HttpConstants.HEADER_CONTENT_TYPE, HttpConstants.HEADER_CONTENT_TYPE_JSON);
            req.setHeader(MuKnApiConstants.MUKN_KEY_AUTHORIZATION_HEADER, new MuknKeyService().getApiKey());
            // Example body: you can adjust as needed
            Map<String, Object> body = new Map<String, Object>{
                'walletAddress' => record.Wallet_Address__c,
                'masterPublicKey' => record.Master_Public_Key__c
            };
            req.setBody(JSON.serialize(body));
            System.debug('Request body: ' + req.getBody());
            try {
                HttpResponse resp = new Http().send(req);
                System.debug('Callout response for record ' + record.Id + ': ' + resp.getBody());
            } catch (Exception e) {
                System.debug('Callout failed for record ' + record.Id + ': ' + e.getMessage());
            }
        }
    }
} 