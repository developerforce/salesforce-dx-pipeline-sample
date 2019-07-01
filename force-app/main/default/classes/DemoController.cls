public with sharing class DemoController {
	private static final String version = '1.0.8';
    /**
     * An empty constructor for the testing
     */
    public DemoController() {
    }


    /**
     * Get the version of the SFDX demo app
     */
    public String getAppVersion() {
        return version;
    }
}
