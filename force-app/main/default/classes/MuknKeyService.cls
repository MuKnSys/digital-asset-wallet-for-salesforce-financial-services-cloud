public without sharing class MuknKeyService {
    private MuknAPISettings__c apiSettings;

    public MuknKeyService() {
        apiSettings = MuknAPISettings__c.getOrgDefaults();
    }

    public String getApiKey() {
        if (apiSettings != null && !String.isBlank(apiSettings.APIKey__c)) {
            return apiSettings.APIKey__c;
        }
        // Fallback: SOQL for org default, safe from List has no rows
        List<MuknAPISettings__c> settings = [SELECT APIKey__c FROM MuknAPISettings__c WHERE SetupOwnerId = :UserInfo.getOrganizationId() LIMIT 1];
        if (!settings.isEmpty() && !String.isBlank(settings[0].APIKey__c)) {
            return settings[0].APIKey__c;
        }
        return '';
    }
}
