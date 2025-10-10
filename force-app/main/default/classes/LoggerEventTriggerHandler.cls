public class LoggerEventTriggerHandler extends TriggerHandler {
    /***************************************
     * Private instance variables
    ***************************************/
    private Map<Id, Logger__e> triggerOldMap;
    
    /***************************************
     * Constructors
    ***************************************/
    public LoggerEventTriggerHandler() {
        this.triggerOldMap = (Map<Id, Logger__e>) Trigger.oldMap;
    }
	
    /***************************************
     * Public instance methods
    ***************************************/
    public override void afterInsert() {
        
        List<Log__c> logs = new List<Log__c>();
        for(Logger__e event: (List<Logger__e>)Trigger.New) {
            
            logs.add(new Log__c(
                Source__c = event.Source__c,
                OwnerId = event.Logged_By__c,
                Log_Level__c = event.Log_Level__c,
                Source_Object__c = getSourceObjectName(event.Source_Record_Id__c),
                Source_Record_Id__c = event.Source_Record_Id__c,
                Message__c = event.Message__c,
                Stack_Trace__c = event.Stack_Trace__c
            ));            
        }
        
        if (!logs.isEmpty()) {
            Database.SaveResult[] results = Database.insert(logs, false); // avoids blocking transaction if some logs fail
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    System.debug('Failed to insert log: ' + results[i].getErrors()[0].getMessage());
                }
            }
        }
    }
    
    /***************************************
     * Private static methods
    ***************************************/
    private static Boolean isId(String idStr) {
        
        if (String.isBlank(idStr)) return false;
        try {
            Id idVal = Id.valueOf(idStr);
            return true;
        } catch (Exception e) {
            return false;
        }        
    }
    
    private static String getSourceObjectName(String recordId) {
        
        if (!isId(recordId)) return ''; 
        Schema.SObjectType objType = ((Id)recordId).getSObjectType(); // Get the sObject type
		return objType.getDescribe().getName();        
    }
}