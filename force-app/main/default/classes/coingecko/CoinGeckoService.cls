public inherited sharing class CoinGeckoService {
    public static final String GET_EXCHANGE_RATE_ENDPOINT = '/api/v3/simple/price?ids={0}&vs_currencies={1}';

    public Decimal getExchangeRate(String source, String targetCurrency) {
        Map<String, Object> exchangeRates = getExchangeRates(source, targetCurrency);
        Map<String, Object> exchangeRate = (Map<String, Object>) exchangeRates.get(source);

        return (Decimal) exchangeRate.get(targetCurrency.toLowerCase());
    }

    public Map<String, Object> getExchangeRates(String source, String targetCurrency) {
        CoinGeckoAPI request = new CoinGeckoAPI(
                String.format(GET_EXCHANGE_RATE_ENDPOINT, new List<String>{ source, targetCurrency.toLowerCase() })
            )
            .doGET();

        HttpResponse response = request.callout();

        if ((new List<String>{ '{}', null }).contains(response.getBody())) {
            throw new CoinGeckoAPI.CoinGeckoAPIException(System.Label.CoinGeckoInvalidAssetToken);
        }

        return (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    }

    // Get the org's default (corporate) currency ISO code, with enhanced logging and robust checking
    public static String getOrgDefaultCurrencyIso() {
        String defaultCurrency = 'usd'; // fallback
        try {
            System.debug('Attempting to fetch org default currency (corporate currency) using CurrencyType...');
            // Try CurrencyType (multi-currency orgs)
            List<SObject> currencies = Database.query('SELECT IsoCode FROM CurrencyType WHERE IsActive = true AND IsCorporate = true LIMIT 1');
            if (!currencies.isEmpty() && String.valueOf(currencies[0].get('IsoCode')) != null) {
                defaultCurrency = String.valueOf(currencies[0].get('IsoCode')).toLowerCase();
                System.debug('Found org corporate currency via CurrencyType: ' + defaultCurrency);
            } else {
                System.debug('No active corporate currency found in CurrencyType, will try UserInfo.getDefaultCurrency().');
                String userCurrency = UserInfo.getDefaultCurrency();
                if (String.isNotBlank(userCurrency)) {
                    defaultCurrency = userCurrency.toLowerCase();
                    System.debug('Found default currency via UserInfo: ' + defaultCurrency);
                } else {
                    System.debug('UserInfo.getDefaultCurrency() returned blank, defaulting to usd.');
                }
            }
        } catch (Exception e) {
            System.debug('Exception while fetching org default currency: ' + e.getMessage());
            // Try UserInfo.getDefaultCurrency() as fallback
            try {
                String userCurrency = UserInfo.getDefaultCurrency();
                if (String.isNotBlank(userCurrency)) {
                    defaultCurrency = userCurrency.toLowerCase();
                    System.debug('Found default currency via UserInfo (in catch): ' + defaultCurrency);
                } else {
                    System.debug('UserInfo.getDefaultCurrency() (in catch) returned blank, defaulting to usd.');
                }
            } catch (Exception e2) {
                System.debug('Exception in UserInfo.getDefaultCurrency(): ' + e2.getMessage());
            }
        }
        return defaultCurrency;
    }

    @AuraEnabled
    public static Map<String, Object> updateSecurityPrice(Id securityId) {
        try {
            System.debug('Starting updateSecurityPrice for securityId: ' + securityId);
            
            // Check if CurrencyIsoCode exists on the object
            Map<String, SObjectField> fields = Schema.getGlobalDescribe().get('Crypto_Account__c').getDescribe().fields.getMap();
            Boolean hasCurrencyIsoCode = fields.containsKey('CurrencyIsoCode');
            System.debug('Does Crypto_Account__c have CurrencyIsoCode? ' + hasCurrencyIsoCode);

            Crypto_Account__c security;
            String targetCurrency;
            if (hasCurrencyIsoCode) {
                // Multi-currency org
                String soql = 'SELECT Id, CoinGeckoAPIName__c, Price__c, CurrencyIsoCode FROM Crypto_Account__c WHERE Id = :securityId LIMIT 1';
                security = Database.query(soql);
                System.debug('Multi-currency org detected. Using record CurrencyIsoCode: ' + security.get('CurrencyIsoCode'));
                String currencyIso = (String)security.get('CurrencyIsoCode');
                targetCurrency = String.isNotBlank(currencyIso) ? currencyIso.toLowerCase() : 'usd';
            } else {
                // Single-currency org
                security = [
                    SELECT Id, CoinGeckoAPIName__c, Price__c
                    FROM Crypto_Account__c
                    WHERE Id = :securityId
                    LIMIT 1
                ];
                String userCurrency = UserInfo.getDefaultCurrency();
                targetCurrency = String.isNotBlank(userCurrency) ? userCurrency.toLowerCase() : 'usd';
                System.debug('Single-currency org detected. Using UserInfo.getDefaultCurrency(): ' + targetCurrency);
            }

            System.debug('Retrieved security: ' + security);

            if (String.isBlank(security.CoinGeckoAPIName__c)) {
                System.debug('CoinGecko API Name is blank for security: ' + security.Id);
                throw new AuraHandledException('CoinGecko API Name is not set for this security.');
            }

            System.debug('Using target currency: ' + targetCurrency);

            CoinGeckoService service = new CoinGeckoService();
            System.debug('Fetching price for CoinGecko API Name: ' + security.CoinGeckoAPIName__c + ' in ' + targetCurrency);
            Decimal price = service.getExchangeRate(security.CoinGeckoAPIName__c, targetCurrency);
            System.debug('Retrieved price: ' + price);

            security.Price__c = price;
            security.Last_Updated__c = Date.today();
            update security;
            System.debug('Updated security with new price: ' + price);

            return new Map<String, Object>{
                'success' => true,
                'price' => price,
                'currency' => targetCurrency,
                'message' => 'Successfully updated price to: ' + price.setScale(2) + ' ' + targetCurrency.toUpperCase()
            };
        } catch (Exception e) {
            System.debug('Error in updateSecurityPrice: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
}
