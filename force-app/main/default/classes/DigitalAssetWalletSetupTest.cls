@isTest
private class DigitalAssetWalletSetupTest {
    @isTest
    static void testGetSetup() {
        Test.startTest();
        try {
            DigitalAssetWalletSetup.SetupData setupData = DigitalAssetWalletSetup.getSetup();
            System.assertNotEquals(null, setupData, 'Setup data should not be null');
            System.assertNotEquals(null, setupData.authorizationStatus, 'Authorization status should not be null');
        } catch (Exception e) {
            System.assert(false, 'Exception thrown: ' + e.getMessage());
        }
        Test.stopTest();
    }
} 