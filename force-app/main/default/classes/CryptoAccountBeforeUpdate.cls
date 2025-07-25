public class CryptoAccountBeforeUpdate {
    public static void handleBeforeInsert(List<Crypto_Account__c> newList) {
        for(Crypto_Account__c newRecord : newList) {
            // Handle before insert logic
            validateCryptoAccount(newRecord);
        }
    }
    
    public static void handleBeforeUpdate(List<Crypto_Account__c> newList, Map<Id, Crypto_Account__c> oldMap) {
        for(Crypto_Account__c newRecord : newList) {
            Crypto_Account__c oldRecord = oldMap.get(newRecord.Id);
            
            // Check if any of the key fields have changed
            if(newRecord.Master_Public_Key__c != oldRecord.Master_Public_Key__c ||
               newRecord.Wallet_Address__c != oldRecord.Wallet_Address__c ||
               newRecord.Connected_Blockchains__c != oldRecord.Connected_Blockchains__c) {
                
                validateCryptoAccount(newRecord);
            }
        }
    }
    
    private static void validateCryptoAccount(Crypto_Account__c record) {
        // Validate Master Public Key
        if(String.isNotBlank(record.Master_Public_Key__c)) {
            // Add validation logic for Master Public Key
        }
        
        // Validate Wallet Address
        if(String.isNotBlank(record.Wallet_Address__c)) {
            // Add validation logic for Wallet Address
        }
        
        // Validate Connected Blockchains
        if(String.isNotBlank(record.Connected_Blockchains__c)) {
            // Add validation logic for Connected Blockchains
        }
    }
} 