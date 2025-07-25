@RestResource(urlMapping='/mukn/settings/*')
global with sharing class MuknKeyAPI {
    @HttpGet
    global static void doGet() {
        RestResponse response = RestContext.response;
        try {
            MuknAPISettings__c settings = MuknAPISettings__c.getOrgDefaults();
            if (settings != null && settings.APIKey__c != null) {
                buildResponse(response, HttpConstants.CODE_SUCCESS, settings.APIKey__c);
            } else {
                buildResponse(response, HttpConstants.CODE_NOT_FOUND, 'API key not found.');
            }
        } catch (Exception error) {
            System.debug(error.getMessage());
            buildResponse(response, HttpConstants.CODE_INTERNAL_SERVER_ERROR, error.getMessage());
        }
    }

    @HttpPut
    global static void doPut(String muknKey) {
        RestResponse response = RestContext.response;
        try {
            String orgId = OrganizationService.getOrganizationId();
            System.debug('Using 15-digit Org ID: ' + orgId);
            MuknAPISettings__c settings = MuknAPISettings__c.getOrgDefaults();
            settings.APIKey__c = muknKey;

            if (isUpsertable()) {
                upsert settings;

                // Re-query to get the potentially updated settings
                MuknAPISettings__c updatedSettings = [SELECT APIKey__c FROM MuknAPISettings__c WHERE Id = :settings.Id];

                if (muknKey == updatedSettings.APIKey__c) {
                    buildResponse(response, HttpConstants.CODE_SUCCESS, 'API Key updated successfully.');
                } else {
                    buildResponse(response, HttpConstants.CODE_CONFLICT, 'API Key update conflict. Please try again.');
                }
            } else {
                buildResponse(response, HttpConstants.CODE_FORBIDDEN, 'Access restricted');
            }
        } catch (Exception error) {
            System.debug(error.getMessage());
            buildResponse(response, HttpConstants.CODE_INTERNAL_SERVER_ERROR, error.getMessage());
        }
    }

    private static Boolean isUpsertable() {
        return FeatureManagement.checkPermission('MuKn_Integration') ||
            (Schema.sObjectType.MuknAPISettings__c.isCreateable() &&
            Schema.sObjectType.MuknAPISettings__c.isUpdateable() &&
            Schema.sObjectType.MuknAPISettings__c.fields.APIKey__c.isCreateable() &&
            Schema.sObjectType.MuknAPISettings__c.fields.APIKey__c.isUpdateable());
    }

    private static void buildResponse(RestResponse response, Integer statusCode, String message) {
        response.statusCode = statusCode;
        if (message != null) {
            response.responseBody = blob.valueOf(message);
        }
    }
} 