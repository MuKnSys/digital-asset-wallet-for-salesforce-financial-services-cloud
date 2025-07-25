public with sharing class ConfigurationService {
    public static String namespace {
        get {
            if (namespace == null) {
                String envClassName = ConfigurationService.class.getName();
                namespace = envClassName.contains('.') ? envClassName.substringBefore('.') : '';
            }
            return namespace;
        }
        private set;
    }

    public static String orgNamespace {
        get {
            if (orgNamespace == null) {
                orgNamespace = '';
                if (String.isNotBlank(namespace)) {
                    orgNamespace = namespace + '__';
                }
            }
            return orgNamespace;
        }
        private set;
    }
}
