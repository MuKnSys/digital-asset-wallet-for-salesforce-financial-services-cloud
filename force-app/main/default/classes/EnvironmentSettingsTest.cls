@isTest
private class EnvironmentSettingsTest {
    @isTest
    static void getEnvironmentSetup_isProduction() {
        Test.startTest();
        Boolean isProduction = EnvironmentSettings.getEnvironmentSetup();
        Test.stopTest();

        Assert.isTrue(isProduction);
    }

    @isTest
    static void overideEnvironmentURL_isTestEnvironment() {
        Test.startTest();
        Id jobId = EnvironmentSettings.overideEnvironmentURL(false);
        Test.stopTest();

        Assert.isNull(jobId);
    }
}
