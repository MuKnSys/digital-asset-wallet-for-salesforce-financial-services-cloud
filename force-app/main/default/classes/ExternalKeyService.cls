public without sharing class ExternalKeyService {
    private ExternalAPISettings__c apiSettings;

    public ExternalKeyService() {
        apiSettings = ExternalAPISettings__c.getOrgDefaults();
    }

    // CoinGecko
    public Boolean isCoinGeckoProEnabled() {
        return apiSettings.CoinGeckoAPIKey__c != null;
    }

    public String getCoinGeckoApiKey() {
        return apiSettings.CoinGeckoAPIKey__c != null ? apiSettings.CoinGeckoAPIKey__c : '';
    }

    public void updateCoinGeckoApiKey(String value) {
        apiSettings.CoinGeckoAPIKey__c = value;
    }

    // Shared
    public void saveSettings() {
        upsert as system apiSettings;
    }
}
