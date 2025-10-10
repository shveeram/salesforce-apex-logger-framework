trigger LoggerEventTrigger on Logger__e (after insert) {
    
    /*
    * Description: Trigger for Logger event (Platform Event)
    * Change Log:
        * 29-Sep-2025 | Shasikkumar Veeramani | Created
    */
	
    new LoggerEventTriggerHandler().run();
}