public class Logger {
    
    public enum LogLevel { DEBUG, INFO, WARN, ERROR }
    private static Logger instance;
    public static final Logger_Settings__c SETTINGS = Logger_Settings__c.getInstance();
    private static List<LogEntry> bufferEntries = new List<LogEntry>();

    // Prevent direct instantiation
    private Logger() {}
    // Public accessor for singleton instance
    public static Logger get() {
        if (instance == null) {
            instance = new Logger();
        }
        return instance;
    }

    private class LogEntry {

        private String message;
        private LogLevel level;
        private String source;
        private String sourceRecordId;
        private String stackTrace;
        
        private LogEntry(String message, LogLevel level, String source, String sourceRecordId, String stackTrace) {
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

    public void add(String source, String sourceRecordId, String message, LogLevel level) {
        if (!isEnabled() || !allowLogLevel(level)) return;
        bufferEntries.add(new LogEntry(message, level, source, sourceRecordId, null));
    }

    public void add(String source, String sourceRecordId, Exception e) {
        if (!isEnabled()) return;
        bufferEntries.add(new LogEntry(e.getMessage(), LogLevel.ERROR, source, sourceRecordId, e.getStackTraceString()));
    }

    public void publish() {
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