@IsTest
private class LoggerEventTriggerHandlerTest {
    
    @TestSetup
    static void setup() {
        insert new Logger_Settings__c(
            Enabled__c = true,
            Errors_Warnings_Only__c = false
        );
    }

    @IsTest
    static void testEventCreatesLogRecords() {
        Test.startTest();

        // Publish 2 platform events
        List<Logger__e> events = new List<Logger__e>{
            new Logger__e(
                Logged_By__c = UserInfo.getUserId(),
                Log_Level__c = 'INFO',
                Source__c = 'LoggerEventTriggerHandlerTest',
                Source_Record_Id__c = UserInfo.getUserId(),
                Message__c = 'Info log',
                Stack_Trace__c = null
            ),
            new Logger__e(
                Logged_By__c = UserInfo.getUserId(),
                Log_Level__c = 'ERROR',
                Source__c = 'LoggerEventTriggerHandlerTest',
                Source_Record_Id__c = null,
                Message__c = 'Error log',
                Stack_Trace__c = 'Example stack'
            )
        };

        EventBus.publish(events);

        Test.stopTest(); // This fires the platform event trigger

        // Verify logs were created
        List<Log__c> logs = [SELECT Log_Level__c, Message__c, Source__c, Stack_Trace__c FROM Log__c];
        System.assertEquals(2, logs.size(), 'Two Log__c records should be created');
        System.assertEquals('INFO', logs[0].Log_Level__c);
        System.assertEquals('ERROR', logs[1].Log_Level__c);
    }

    @IsTest
    static void testInvalidRecordIdHandledGracefully() {
        Test.startTest();
        EventBus.publish(new Logger__e(
            Logged_By__c = UserInfo.getUserId(),
            Log_Level__c = 'INFO',
            Source__c = 'LoggerEventTriggerHandlerTest',
            Source_Record_Id__c = 'NotAValidId',
            Message__c = 'Bad ID',
            Stack_Trace__c = null
        ));
        Test.stopTest();

        List<Log__c> logs = [SELECT Source_Object__c FROM Log__c];
        System.assertEquals(true, String.isBlank(logs[0].Source_Object__c), 'Source_Object__c should be blank for invalid Ids');
    }
}