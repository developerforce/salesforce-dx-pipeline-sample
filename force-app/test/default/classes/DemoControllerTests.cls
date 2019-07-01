@IsTest
private class DemoControllerTests {
    @IsTest
    static void testGetAppVersion() {
        String version = '1.0.8';
        DemoController demo = new DemoController();
        System.assertEquals(demo.getAppVersion(), version);
    }
}
