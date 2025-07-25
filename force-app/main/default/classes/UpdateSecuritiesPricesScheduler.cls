global class UpdateSecuritiesPricesScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        System.debug('UpdateSecuritiesPricesScheduler: Starting scheduled price update.');
        List<Crypto_Account__c> securities = [
            SELECT Id, CoinGeckoAPIName__c
            FROM Crypto_Account__c
            WHERE CoinGeckoAPIName__c != null AND CoinGeckoAPIName__c != ''
        ];
        System.debug('Found ' + securities.size() + ' securities with CoinGecko API names.');
        Set<String> coingeckoIds = new Set<String>();
        for (Crypto_Account__c sec : securities) {
            coingeckoIds.add(sec.CoinGeckoAPIName__c.trim().toLowerCase());
        }
        Map<String, Decimal> priceMap = new Map<String, Decimal>();
        if (!coingeckoIds.isEmpty()) {
            try {
                String currencyIso = CoinGeckoService.getOrgDefaultCurrencyIso();
                System.debug('Batch fetching prices for CoinGecko IDs: ' + coingeckoIds + ' in currency: ' + currencyIso);
                CoinGeckoService service = new CoinGeckoService();
                List<String> idList = new List<String>(coingeckoIds);
                String joinedIds = String.join(idList, ',');
                Map<String, Object> allPrices = service.getExchangeRates(joinedIds, currencyIso);
                System.debug('Batch price response: ' + allPrices);
                for (String id : coingeckoIds) {
                    if (allPrices.containsKey(id)) {
                        Map<String, Object> priceObj = (Map<String, Object>)allPrices.get(id);
                        if (priceObj != null && priceObj.containsKey(currencyIso.toLowerCase())) {
                            priceMap.put(id, (Decimal)priceObj.get(currencyIso.toLowerCase()));
                        }
                    }
                }
            } catch (Exception e) {
                System.debug('Error batch fetching prices: ' + e.getMessage());
            }
        }
        List<Crypto_Account__c> toUpdate = new List<Crypto_Account__c>();
        for (Crypto_Account__c sec : securities) {
            String id = sec.CoinGeckoAPIName__c.trim().toLowerCase();
            if (priceMap.containsKey(id)) {
                Decimal price = priceMap.get(id);
                if (price != null) {
                    sec.Price__c = price;
                    sec.Last_Updated__c = Date.today();
                    toUpdate.add(sec);
                    System.debug('Set price for ' + id + ': ' + price);
                }
            } else {
                System.debug('No price found for ' + id + ', leaving blank.');
            }
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate;
            System.debug('Updated ' + toUpdate.size() + ' securities with new prices.');
        } else {
            System.debug('No securities to update.');
        }
        System.debug('UpdateSecuritiesPricesScheduler: Finished scheduled price update.');
    }
} 