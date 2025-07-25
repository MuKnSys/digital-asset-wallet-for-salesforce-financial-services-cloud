public with sharing class DigitalAssetWalletSetup {
    @AuraEnabled
    public static SetupData getSetup() {
        try {
            SetupData setupData = new SetupData();
            setupData.orgId = OrganizationService.getOrganizationId();
            setupData.muknCaSFDCAppUrl = MuknSettings.muknCaSFDCAppUrl;
            setupData.muknApiKeyStatus = getMuknAPIKeyStatus();
            setupData.authorizationStatus = getAuthorizationStatus();
            return setupData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String getMuknAPIKeyStatus() {
        MuknKeyService settings = new MuknKeyService();
        return settings.getApiKey() != '' ? System.Label.SetupApiKeySet : System.Label.SetupApiKeyNotSet;
    }

    private static AuthorizationStatus getAuthorizationStatus() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(MuknSettings.muknCaAppUrl + '/organization/' + OrganizationService.getOrganizationId());
        req.setMethod(HttpConstants.METHOD_GET);

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() == HttpConstants.CODE_SUCCESS) {
            return (AuthorizationStatus) JSON.deserialize(res.getBody(), AuthorizationStatus.class);
        } else {
            return new AuthorizationStatus();
        }
    }

    public class SetupData {
        @AuraEnabled
        public String orgId;
        @AuraEnabled
        public AuthorizationStatus authorizationStatus;
        @AuraEnabled
        public String muknCaSFDCAppUrl;
        @AuraEnabled
        public String muknApiKeyStatus;

        @AuraEnabled
        public Boolean getOrgAuthorized() {
            return orgId == authorizationStatus.orgid;
        }
    }

    public class AuthorizationStatus {
        @AuraEnabled
        public String organization_uuid;
        @TestVisible
        private String orgid;
        @AuraEnabled
        public String org_url;
        @AuraEnabled
        public Boolean authorized;
        @TestVisible
        private String muknapikey;

        public AuthorizationStatus() {
            organization_uuid = '';
            orgid = '';
            org_url = '';
            authorized = false;
            muknapikey = '';
        }
    }
}
