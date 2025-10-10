# Logger: Simple APEX Logging Framework

## Context
In most Salesforce projects I’ve worked on, logging is either done through System.debug() statements or ignored entirely. During early development, this might be tolerable. But once an org starts handling async jobs, third-party integrations, or high-volume user interactions, debug logs fall apart. You can’t trace behavior. And when something breaks in production, team is left flying blind. Logging should never be an afterthought. Yet, in practice, logging frameworks in Apex are often avoided because they’re perceived as heavy, unnecessary, or too developer-focused.

> A simple, well-structured, lightweight logging framework can provide massive value.

## Features

- Guaranteed log, even when a transaction fails, or an exception occurs
- Buffered and bulkfied as standard
- Easy configuration to disable logging framework or enable only for warning/error messages

## Usage

Custom setting configuration called Logger settings has option to enable logging and whether logging is to be enabled only for Errors/Warnings or all levels.

Once enabled, using in the APEX code is straight-forward. Example below:
```java
Logger.add('DebugConsole', null, 'Test logging 1', Logger.LogLevel.INFO);
Id accountId = '0014L00000DVugkQAD';
Decimal accountBalance = AccountService.calculateBalance(accountId);

// AccountService
public class AccountService {
    private static final String MODULE_NAME = 'AccountService';
    public static Decimal calculateBalance(Id accountId) {
        String sourceMethod = MODULE_NAME+'.'+calculateBalance;
        try {
        	Logger.add(sourceMethod, accountId, 'Step 1', Logger.LogLevel.INFO);
        	//Do something
            Logger.add(sourceMethod, accountId, 'Step 2', Logger.LogLevel.INFO);
            //Do some more
            Logger.add(sourceMethod, accountId, 'Step 3', Logger.LogLevel.INFO);
            
            //At at the publish to persist the buffer to the log object and clear
            Logger.publish();
        } catch (Exception e) {
            Logger.add(sourceMethod, accountId, e);
            Logger.publish();
            throw e
        }
    }
}
```

## Dependencies

I have always used Kevin O'Hara's light-weight [trigger framework](https://github.com/kevinohara80/sfdc-trigger-framework). In this framework, it is included and used in the platform event trigger.

## Further development

- Automatic purging through batchable/schedulable based on configuration in custom setting