public with sharing class SecuritiesPricingService {
    /**
     * Updates all securities with latest prices from CoinGecko and updates related financial holdings.
     * Returns a summary message.
     */
    public static String updateAllSecuritiesAndHoldings() {
        List<FinServ__Securities__c> securitiesToUpdate = [
            SELECT Id, Name, CoinGeckoAPIName__c, FinServ__Price__c
            FROM FinServ__Securities__c
            WHERE CoinGeckoAPIName__c != null AND CoinGeckoAPIName__c != ''
        ];
        CoinGeckoService service = new CoinGeckoService();
        String orgDefaultCurrency = CoinGeckoService.getOrgDefaultCurrencyIso();
        Set<String> apiNames = new Set<String>();
        for (FinServ__Securities__c sec : securitiesToUpdate) {
            apiNames.add(sec.CoinGeckoAPIName__c);
        }
        Map<String, Object> allPrices = new Map<String, Object>();
        if (!apiNames.isEmpty()) {
            String joinedIds = String.join(new List<String>(apiNames), ',');
            allPrices = service.getExchangeRates(joinedIds, orgDefaultCurrency);
            for (FinServ__Securities__c sec : securitiesToUpdate) {
                if (allPrices.containsKey(sec.CoinGeckoAPIName__c)) {
                    Map<String, Object> priceObj = (Map<String, Object>)allPrices.get(sec.CoinGeckoAPIName__c);
                    if (priceObj != null && priceObj.containsKey(orgDefaultCurrency)) {
                        Decimal price = (Decimal)priceObj.get(orgDefaultCurrency);
                        sec.FinServ__Price__c = price;
                    }
                }
            }
            if (!securitiesToUpdate.isEmpty()) {
                update securitiesToUpdate;
            }
        }
        // Update related financial holdings
        Map<Id, Decimal> securityIdToPrice = new Map<Id, Decimal>();
        for (FinServ__Securities__c sec : securitiesToUpdate) {
            securityIdToPrice.put(sec.Id, sec.FinServ__Price__c);
        }
        List<FinServ__FinancialHolding__c> holdingsToUpdate = [
            SELECT Id, FinServ__Securities__c, FinServ__Shares__c, FinServ__Price__c, FinServ__MarketValue__c
            FROM FinServ__FinancialHolding__c
            WHERE FinServ__Securities__c IN :securityIdToPrice.keySet()
        ];
        for (FinServ__FinancialHolding__c holding : holdingsToUpdate) {
            if (securityIdToPrice.containsKey(holding.FinServ__Securities__c)) {
                Decimal price = securityIdToPrice.get(holding.FinServ__Securities__c);
                holding.FinServ__Price__c = price;
                holding.FinServ__MarketValue__c = price * holding.FinServ__Shares__c;
            }
        }
        if (!holdingsToUpdate.isEmpty()) {
            update holdingsToUpdate;
        }
        return 'Updated ' + securitiesToUpdate.size() + ' securities and ' + holdingsToUpdate.size() + ' holdings.';
    }
    @AuraEnabled
    public static String updateAllViaLwc() {
        return updateAllSecuritiesAndHoldings();
    }
} 