public with sharing class OrganizationService {
    @AuraEnabled(cacheable=true)
    public static String getOrganizationId() {
        return String.valueOf(UserInfo.getOrganizationId()).substring(0, 15);
    }

    @AuraEnabled(cacheable=true)
    public static String getOrganizationName() {
        return [SELECT Name FROM Organization LIMIT 1].Name;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean getIsSandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}
