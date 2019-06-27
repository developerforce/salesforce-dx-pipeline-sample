public with sharing class DemoController {
    private string version = '1.0.2';
    /**
     * An empty constructor for the testing
     */
    public DemoController() {}

    /**
     * Get the version of the SFDX demo app
     */
    public String getAppVersion() {        
        return version;
    }
}
