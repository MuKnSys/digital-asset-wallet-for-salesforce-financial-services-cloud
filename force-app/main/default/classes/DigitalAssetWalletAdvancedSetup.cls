public with sharing class DigitalAssetWalletAdvancedSetup {
    @AuraEnabled
    public static SetupData getSetup() {
        try {
            SetupData setupData = new SetupData();
            setupData.coinGeckoAPIKey = getCoinGeckoAPIKeyStatus();
            return setupData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void reinitializeAssetToken() {
        try {
            // Load the static resource
            StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'InvestmentSecuritiesInitialRecords' LIMIT 1];
            String jsonString = sr.Body.toString();
            List<Object> records = (List<Object>) JSON.deserializeUntyped(jsonString);
            
            // Build a map of symbol to record from JSON
            Map<String, Map<String, Object>> jsonMap = new Map<String, Map<String, Object>>();
            for (Object obj : records) {
                Map<String, Object> rec = (Map<String, Object>) obj;
                if (rec.containsKey('symbol')) {
                    jsonMap.put((String)rec.get('symbol'), rec);
                }
            }

            // Query existing securities by symbol (Name)
            Map<String, FinServ__Securities__c> existing = new Map<String, FinServ__Securities__c>();
            for (FinServ__Securities__c sec : [SELECT Id, Name, FinServ__SecuritiesName__c FROM FinServ__Securities__c WHERE Name IN :jsonMap.keySet()]) {
                existing.put(sec.Name, sec);
            }

            List<FinServ__Securities__c> toUpsert = new List<FinServ__Securities__c>();
            for (String symbol : jsonMap.keySet()) {
                Map<String, Object> rec = jsonMap.get(symbol);
                String secName = (String)rec.get('name');
                FinServ__Securities__c sec = existing.containsKey(symbol) ? existing.get(symbol) : new FinServ__Securities__c();
                sec.Name = symbol;
                sec.FinServ__SecuritiesName__c = secName;
                if (rec.containsKey('coingecko')) {
                    sec.CoinGeckoAPIName__c = (String)rec.get('coingecko');
                }
                if (rec.containsKey('exchange')) {
                    sec.FinServ__Exchange__c = (String)rec.get('exchange');
                }
                toUpsert.add(sec);
            }
            if (!toUpsert.isEmpty()) {
                upsert toUpsert FinServ__SecuritiesName__c;
            }

            // Enqueue the Queueable job to update prices asynchronously
            System.enqueueJob(new UpdateSecuritiesPricesQueue(new List<String>(jsonMap.keySet())));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void reinitializeContractToken() {
        try {
            mukn_web3enable.PostInstall installer = new mukn_web3enable.PostInstall();
            installer.installDefaultAssetsAndContracts();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveCoinGeckoCredentials(String coinGeckoAPIKey) {
        try {
            mukn_web3enable.ExternalKeyService keyService = new mukn_web3enable.ExternalKeyService();
            if (coinGeckoAPIKey != System.Label.SetupCoinGeckoApiKeySet) {
                keyService.updateCoinGeckoApiKey(coinGeckoAPIKey);
                keyService.saveSettings();
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteCoinGeckoCredentials() {
        try {
            mukn_web3enable.ExternalKeyService keyService = new mukn_web3enable.ExternalKeyService();
            keyService.updateCoinGeckoApiKey(null);
            keyService.saveSettings();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateAllSecuritiesAndHoldings() {
        SecuritiesPricingService.updateAllSecuritiesAndHoldings();
    }

    private static String getCoinGeckoAPIKeyStatus() {
        mukn_web3enable.ExternalKeyService settings = new mukn_web3enable.ExternalKeyService();
        return settings.getCoinGeckoApiKey() != '' ? System.Label.SetupCoinGeckoApiKeySet : null;
    }

    // Queueable class for updating prices asynchronously
    public class UpdateSecuritiesPricesQueue implements Queueable, Database.AllowsCallouts {
        private List<String> symbols;
        public UpdateSecuritiesPricesQueue(List<String> symbols) {
            this.symbols = symbols;
        }
        public void execute(QueueableContext context) {
            SecuritiesPricingService.updateAllSecuritiesAndHoldings();
        }
    }

    public class SetupData {
        @AuraEnabled
        public String coinGeckoAPIKey;
    }
} 