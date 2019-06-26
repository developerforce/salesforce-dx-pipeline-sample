public with sharing class DemoController {

    private String appVersion = '1.0.0';

    /**
     * An empty constructor for the testing
     */
    public DemoController() {
        System.System.debug('This is construct');
    }

    /**
     * Get the version of the SFDX demo app
     */
    public String getAppVersion() {
        return appVersion;
    }
}
