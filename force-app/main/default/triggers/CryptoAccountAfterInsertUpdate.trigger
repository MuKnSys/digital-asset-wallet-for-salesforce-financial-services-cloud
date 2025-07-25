// AFTER TRIGGER: Callout logic
trigger CryptoAccountAfterInsertUpdate on Crypto_Account__c (after insert, after update) {
    List<Crypto_Account__c> validRecords = new List<Crypto_Account__c>();
    for (Crypto_Account__c record : Trigger.new) {
        Boolean hasBlockchains = String.isNotBlank(record.Connected_Blockchains__c);
        Boolean hasWalletAddress = String.isNotBlank(record.Wallet_Address__c);
        Boolean hasMasterPublicKey = String.isNotBlank(record.Master_Public_Key__c);

        System.debug('Record: ' + (Trigger.isInsert ? 'New Record' : 'Id: ' + record.Id) +
            ' | Connected_Blockchains__c: ' + record.Connected_Blockchains__c +
            ' | Wallet_Address__c: ' + record.Wallet_Address__c +
            ' | Master_Public_Key__c: ' + record.Master_Public_Key__c);

        if (!hasBlockchains) {
            System.debug('Required field missing: Connected_Blockchains__c is empty.');
        }
        if (hasWalletAddress == hasMasterPublicKey) { // both true or both false
            System.debug('Exactly one of Wallet_Address__c or Master_Public_Key__c must be set, but not both or neither.');
        }
        if (hasBlockchains && (hasWalletAddress != hasMasterPublicKey)) {
            System.debug('All required fields are set for this record. Adding to valid records.');
            validRecords.add(record);
        }
    }
    if (!validRecords.isEmpty()) {
        System.debug('Enqueuing CryptoAccountExternalCalloutQueue for ' + validRecords.size() + ' valid records');
        System.enqueueJob(new CryptoAccountExternalCalloutQueue(validRecords));
    }
} 