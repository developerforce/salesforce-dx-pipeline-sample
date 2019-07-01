public with sharing class DemoController {
	private static final String version = '1.0.7';
    /**
     * An empty constructor for the testing
     */
    public DemoController() {
        System.debug('Constructor');
    }


    /**
     * Get the version of the SFDX demo app
     */
    public String getAppVersion() {       
        System.debug('getAppVersions');
        return version;
    }
}
