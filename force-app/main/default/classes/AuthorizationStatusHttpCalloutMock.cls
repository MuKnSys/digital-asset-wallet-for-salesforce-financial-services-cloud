@isTest
public with sharing class AuthorizationStatusHttpCalloutMock implements HttpCalloutMock {
    Integer httpCode;

    public AuthorizationStatusHttpCalloutMock() {
        httpCode = 200;
    }

    public AuthorizationStatusHttpCalloutMock(Integer httpStatusCode) {
        httpCode = httpStatusCode;
    }

    @TestVisible
    private Map<String, Object> responseMap = new Map<String, Object>{
        'organization_uuid' => 'test_org_uuid',
        'orgid' => 'test_org_id',
        'org_url' => 'test_org_url',
        'authorized' => true,
        'requested_id' => 'test_request_id'
    };

    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setBody(JSON.serialize(responseMap));
        response.setStatusCode(httpCode);
        return response;
    }
}
