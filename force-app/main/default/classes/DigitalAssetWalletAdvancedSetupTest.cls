@isTest
private class DigitalAssetWalletAdvancedSetupTest {
    @isTest
    static void testGetSetup() {
        Test.startTest();
        try {
            DigitalAssetWalletAdvancedSetup.SetupData setupData = DigitalAssetWalletAdvancedSetup.getSetup();
            System.assertNotEquals(null, setupData, 'Setup data should not be null');
        } catch (Exception e) {
            System.assert(false, 'Exception thrown: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testCoinGeckoCredentials() {
        Test.startTest();
        try {
            // Test saving credentials
            DigitalAssetWalletAdvancedSetup.saveCoinGeckoCredentials('test-api-key');
            
            // Get setup data and verify key is set
            DigitalAssetWalletAdvancedSetup.SetupData setupData = DigitalAssetWalletAdvancedSetup.getSetup();
            System.assertEquals(System.Label.SetupCoinGeckoApiKeySet, setupData.coinGeckoAPIKey, 'CoinGecko API key should be set');
            
            // Test deleting credentials
            DigitalAssetWalletAdvancedSetup.deleteCoinGeckoCredentials();
            
            // Verify key is deleted
            setupData = DigitalAssetWalletAdvancedSetup.getSetup();
            System.assertEquals(null, setupData.coinGeckoAPIKey, 'CoinGecko API key should be null after deletion');
        } catch (Exception e) {
            System.assert(false, 'Exception thrown: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testTokenReinitialization() {
        Test.startTest();
        try {
            // Test asset token reinitialization
            DigitalAssetWalletAdvancedSetup.reinitializeAssetToken();
            
            // Test contract token reinitialization
            DigitalAssetWalletAdvancedSetup.reinitializeContractToken();
            
            // No assertions needed as we're just verifying the methods don't throw exceptions
            System.assert(true, 'Token reinitialization completed successfully');
        } catch (Exception e) {
            System.assert(false, 'Exception thrown: ' + e.getMessage());
        }
        Test.stopTest();
    }
} 