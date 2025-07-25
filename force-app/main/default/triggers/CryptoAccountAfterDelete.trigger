// AFTER DELETE TRIGGER: Callout logic for deleted records
trigger CryptoAccountAfterDelete on Crypto_Account__c (after delete) {
    List<Crypto_Account__c> validRecords = new List<Crypto_Account__c>();
    for (Crypto_Account__c record : Trigger.old) {
        Boolean hasBlockchains = String.isNotBlank(record.Connected_Blockchains__c);
        Boolean hasWalletAddress = String.isNotBlank(record.Wallet_Address__c);
        Boolean hasMasterPublicKey = String.isNotBlank(record.Master_Public_Key__c);
        Boolean hasFinancialAccount = String.isNotBlank(record.Financial_Account__c);

        System.debug('Deleted Record: Id: ' + record.Id +
            ' | Connected_Blockchains__c: ' + record.Connected_Blockchains__c +
            ' | Wallet_Address__c: ' + record.Wallet_Address__c +
            ' | Master_Public_Key__c: ' + record.Master_Public_Key__c +
            ' | Financial_Account__c: ' + record.Financial_Account__c);

        // Only enqueue if all required fields are present and exactly one of wallet or pubkey is set
        if (
            hasBlockchains &&
            hasFinancialAccount &&
            (hasWalletAddress != hasMasterPublicKey) // exactly one is set
        ) {
            System.debug('All required fields are set for this deleted record. Adding to valid records.');
            validRecords.add(record);
        } else {
            System.debug('Record did not meet requirements for callout. Skipping.');
        }
    }
    if (!validRecords.isEmpty()) {
        System.debug('Enqueuing CryptoAccountExternalCalloutQueue for ' + validRecords.size() + ' deleted valid records');
        System.enqueueJob(new CryptoAccountExternalCalloutQueue(validRecords));
    }
} 