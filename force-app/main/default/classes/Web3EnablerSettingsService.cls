public without sharing class Web3EnablerSettingsService {
    private final static Decimal DEFAULT_PAYMENT_VARIANCE_ACCEPTED = 3;

    private Web3EnablerSettings__c settings;

    public Web3EnablerSettingsService() {
        settings = Web3EnablerSettings__c.getOrgDefaults();
    }

    // Web3 Payments
    public Decimal getPaymentVariance() {
        return settings.Payment_Variance_Accepted__c != null
            ? settings.Payment_Variance_Accepted__c
            : DEFAULT_PAYMENT_VARIANCE_ACCEPTED;
    }

    public void updatePaymentVariance(Decimal value) {
        settings.Payment_Variance_Accepted__c = value;
    }

    // Shared
    public void saveSettings() {
        upsert as system settings;
    }
}
