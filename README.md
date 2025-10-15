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
Logger log = Logger.get();
log.add('DebugConsole', null, 'Start of logging', Logger.LogLevel.INFO);

Map<Id, Account> accountMap = new Map<Id, Account>([SELECT ID, Name FROM Account WHERE Type != null]);
Map<Id, Decimal> accountBalanceMap = AccountsService.calculateBalance(accountMap.keySet());
log.add('Debug Console', null, 'accountBalanceMap = '+accountBalanceMap, Logger.LogLevel.INFO);
log.add('Debug Console', null, 'End of logging', Logger.LogLevel.INFO);
log.publish();

// AccountsService
public class AccountsService {

    private static final String MODULE_NAME = 'AccountService';
    public class AccountException extends Exception {}
    
    public static Map<Id, Decimal> calculateBalance(Set<Id> accountIds) {
 
        String sourceMethod = MODULE_NAME+'.calculateBalance';
        Map<Id, Decimal> accountBalanceMap = new Map<Id, Decimal>();
        Logger log = Logger.get();
        try {
            List<Account> accounts = [SELECT ID, Name, Type FROM Account WHERE Id IN :accountIds];
            if (accounts.size() == 0) {
                throw new AccountException('No accounts exists for the account ids = '+accountIds);
            }

			log.add(sourceMethod, null, 'Total accounts passed = '+accounts.size(), Logger.LogLevel.INFO);
            
            for (Account account:accounts) {
                Decimal accountBalance = 0;
                log.add(sourceMethod, account.Id, 'Step 1 - Account Balance: '+accountBalance, Logger.LogLevel.INFO);
                             
                If (account.Type == 'Prospect') {
                    accountBalance = 0;
                } else if (account.Type == 'Customer - Direct') {
                    accountBalance = 10000;
                } else {
                    accountBalance = 5000;
                }
                
                log.add(sourceMethod, account.Id, 'Step 2 - Account Type: '+account.Type, Logger.LogLevel.INFO);
                log.add(sourceMethod, account.Id, 'Step 3 - Account Balance: '+accountBalance, Logger.LogLevel.INFO);                
                accountBalanceMap.put(account.Id, accountBalance);
            }
        } catch (Exception e) {
            log.add(sourceMethod, null, e);
            log.publish();
            throw e;
        }
        
        log.publish();
        return accountBalanceMap;
    }
}
```

## Dependencies

I have always used Kevin O'Hara's light-weight [trigger framework](https://github.com/kevinohara80/sfdc-trigger-framework). In this framework, it is included and used in the platform event trigger.

## Further development

- Automatic purging through batchable/schedulable based on configuration in custom setting