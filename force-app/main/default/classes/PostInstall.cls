global class PostInstall implements InstallHandler {
    @TestVisible
    private static String DEFAULT_CURRENCY = 'USD';
    @TestVisible
    private static Map<String, Boolean> activeSections = new Map<String, Boolean>{};

    global void onInstall(InstallContext context) {
    }

    // This is used in development only
    public void installDefaultAssetsAndContracts() {
    }
}