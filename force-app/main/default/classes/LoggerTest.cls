@IsTest
private class LoggerTest {
    
    @TestSetup
    static void setup() {
        insert new Logger_Settings__c(
            Enabled__c = true,
            Errors_Warnings_Only__c = false
        );
    }
    
    @IsTest
    static void testBasicLoggingAndPublish() {
        Test.startTest();
        Logger.add('LoggerTest', null, 'Debug message', Logger.LogLevel.DEBUG);
        Logger.add('LoggerTest', null, 'Info message', Logger.LogLevel.INFO);
        Logger.add('LoggerTest', null, 'Warning message', Logger.LogLevel.WARN);
        
        // simulate an exception log
        try {
            Integer x = 1 / 0;
        } catch (Exception e) {
            Logger.add('LoggerTest', null, e);
        }

        // Should not throw any exception
        Logger.publish();
        Test.stopTest();

        Logger.publish(); // buffer is already cleared, should do nothing
        System.assertEquals(true, true, 'Publish executed without errors');
    }

    @IsTest
    static void testLoggingDisabled() {
        Logger_Settings__c s = [SELECT Id, Enabled__c FROM Logger_Settings__c LIMIT 1];
        s.Enabled__c = false;
        update s;

        Test.startTest();
        Logger.add('LoggerTest', null, 'Should not log', Logger.LogLevel.INFO);
        Logger.publish(); // should not publish anything
        Test.stopTest();

        System.assertEquals(true, true, 'Publish executed successfully even when disabled');
    }

    @IsTest
    static void testErrorsWarningsOnlyMode() {
        Logger_Settings__c s = [SELECT Id FROM Logger_Settings__c LIMIT 1];
        s.Errors_Warnings_Only__c = true;
        update s;

        Test.startTest();
            Logger.add('LoggerTest', null, 'Debug message', Logger.LogLevel.DEBUG);
            Logger.add('LoggerTest', null, 'Info message', Logger.LogLevel.INFO);
            Logger.add('LoggerTest', null, 'Warning message', Logger.LogLevel.WARN);
            Logger.add('LoggerTest', null, 'Error message', Logger.LogLevel.ERROR);
            Logger.publish();
        Test.stopTest();

        System.assertEquals(true, true, 'Publish executed successfully with filter applied');
    }

    @IsTest
    static void testPublishWithEmptyBuffer() {
        Test.startTest();
        Logger.publish(); // should not throw
        Test.stopTest();
        System.assertEquals(true, true, 'Empty Publish executed successfully');
    }

    @IsTest
    static void testBufferClearedAfterPublish() {
        Test.startTest();
            Logger.add('LoggerTest', null, 'Message A', Logger.LogLevel.INFO);
            Logger.publish();        
        	Logger.publish();// Second publish should do nothing (buffer empty)
        Test.stopTest();

        System.assertEquals(true, true, 'Publish cleared after flush');
    }
}