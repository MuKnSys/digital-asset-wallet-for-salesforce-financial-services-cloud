public with sharing class EnvironmentSettings {
    public static final Boolean PRODUCTION = !OrganizationService.getIsSandbox();

    private static final String PRODUCTION_URL = 'https://muknweb3ca.mukn.com';
    private static final String SANDBOX_URL = 'https://muknweb3ca-test.mukn.com';

    private static final String MUKN_SETTINGS_NAME = 'Default';
    private static final String MUKN_SETTINGS_OBJECT = 'Mukn_Setting__mdt';
    private static final String MUKN_SETTINGS_URL_FIELD = 'MuKnWeb3CA_AppUrl__c';

    public static Boolean getEnvironmentSetup() {
        Mukn_Setting__mdt settings = Mukn_Setting__mdt.getInstance(MUKN_SETTINGS_NAME);
        return settings.MuKnWeb3CA_AppUrl__c == PRODUCTION_URL;
    }

    public static Id overideEnvironmentURL(Boolean setProduction) {
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        Mukn_Setting__mdt settings = Mukn_Setting__mdt.getInstance(MUKN_SETTINGS_NAME);

        Metadata.CustomMetadata metadataRec = new Metadata.CustomMetadata();
        metadataRec.fullName =
            ConfigurationService.orgNamespace +
            MUKN_SETTINGS_OBJECT +
            '.' +
            ConfigurationService.orgNamespace +
            settings.DeveloperName;
        metadataRec.label = settings.MasterLabel;

        Metadata.CustomMetadataValue customFieldtoUpdate = new Metadata.CustomMetadataValue();
        customFieldtoUpdate.field = ConfigurationService.orgNamespace + MUKN_SETTINGS_URL_FIELD;
        customFieldtoUpdate.value = setProduction ? PRODUCTION_URL : SANDBOX_URL;

        metadataRec.values.add(customFieldtoUpdate);
        mdContainer.addMetadata(metadataRec);

        Id jobId = Test.isRunningTest() ? null : Metadata.Operations.enqueueDeployment(mdContainer, null);
        return jobId;
    }
}
