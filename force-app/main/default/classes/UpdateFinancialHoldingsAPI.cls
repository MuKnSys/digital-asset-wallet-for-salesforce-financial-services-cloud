@RestResource(urlMapping='/update/financial-holdings')
global with sharing class UpdateFinancialHoldingsAPI {
    @HttpPost
    global static void updateFinancialHoldings() {
        RestResponse response = RestContext.response;
        try {
            String result = SecuritiesPricingService.updateAllSecuritiesAndHoldings();
            response.statusCode = HttpConstants.CODE_SUCCESS;
            response.responseBody = Blob.valueOf(result);
        } catch (Exception e) {
            response.statusCode = HttpConstants.CODE_INTERNAL_SERVER_ERROR;
            response.responseBody = Blob.valueOf('Error: ' + e.getMessage());
        }
    }
} 