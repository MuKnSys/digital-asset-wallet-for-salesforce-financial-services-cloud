@NamespaceAccessible
@IsTest
public with sharing class TestDataFactory {
    @NamespaceAccessible
    public static Account createAccount(Boolean doInsert) {
        Account account = new Account();
        account.Name = 'test_account_name';

        if (doInsert) {
            insert account;
        }
        return account;
    }

    @NamespaceAccessible
    public static Mukn_Setting__mdt createMuknSettings() {
        Mukn_Setting__mdt settings = new Mukn_Setting__mdt(
            MuKnWeb3CA_AppUrl__c = 'mukn_app_url',
            MuKnWeb3CA_SFDC_AppUrl__c = 'mukn_sfdc_app_url'
        );

        return settings;
    }
}