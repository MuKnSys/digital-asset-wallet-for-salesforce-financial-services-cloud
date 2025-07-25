public with sharing class MuknSettings {
    @TestVisible
    private static Mukn_Setting__mdt orgDefaultSettings {
        get {
            if (orgDefaultSettings == null) {
                orgDefaultSettings = Mukn_Setting__mdt.getInstance('Default');
            }
            return orgDefaultSettings;
        }
        set;
    }

    public static String muknCaAppUrl {
        get {
            return orgDefaultSettings.MuKnWeb3CA_AppUrl__c;
        }
    }

    public static String muknCaSFDCAppUrl {
        get {
            return orgDefaultSettings.MuKnWeb3CA_SFDC_AppUrl__c;
        }
    }
}
