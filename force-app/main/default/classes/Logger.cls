public class Logger {
    
    public enum LogLevel { DEBUG, INFO, WARN, ERROR }
    public static final Logger_Settings__c SETTINGS = Logger_Settings__c.getInstance();
    
    private static List<LogEntry> bufferEntries = new List<LogEntry>();

    public class LogEntry {
        public String message;
        public LogLevel level;
        public String source;
        public String sourceRecordId;
        public String stackTrace;
        
        public LogEntry(String message, LogLevel level, String source, String sourceRecordId, String stackTrace) {
            this.message = message;
            this.level = level == null?LogLevel.INFO:level;
            this.source = source;
            this.sourceRecordId = sourceRecordId;
            this.stackTrace = stackTrace;
        }
    }

    private static Boolean isEnabled() {
        return SETTINGS.Enabled__c;
    }

    private static Boolean allowLogLevel(LogLevel level) {
        if (SETTINGS.Errors_Warnings_Only__c && (level != LogLevel.ERROR && level != LogLevel.WARN))
            return false;
        return true;
    }

    public static void add(String source, String sourceRecordId, String message, LogLevel level) {
        if (!isEnabled() || !allowLogLevel(level)) return;
        bufferEntries.add(new LogEntry(message, level, source, sourceRecordId, null));
    }

    public static void add(String source, String sourceRecordId, Exception e) {
        if (!isEnabled()) return;
        bufferEntries.add(new LogEntry(e.getMessage(), LogLevel.ERROR, source, sourceRecordId, e.getStackTraceString()));
    }

    public static void publish() {
        if (!isEnabled() || bufferEntries.isEmpty()) return;

        List<Logger__e> events = new List<Logger__e>();

        for (LogEntry entry : bufferEntries) {
            if (!allowLogLevel(entry.level)) continue;
            events.add(new Logger__e(
                Logged_By__c = UserInfo.getUserId(),
                Log_Level__c = entry.level.name(),
                Source__c = entry.source,
                Source_Record_Id__c = entry.sourceRecordId,
                Message__c = entry.message,
                Stack_Trace__c = entry.stackTrace
            ));
        }

        if (!events.isEmpty()) {
            Database.SaveResult[] results = EventBus.publish(events);
        }

        bufferEntries.clear();
    }
}