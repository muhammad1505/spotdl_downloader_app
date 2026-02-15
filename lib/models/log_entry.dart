enum LogLevel { info, warning, error, success }

class LogEntry {
  final String message;
  final LogLevel level;
  final DateTime timestamp;

  const LogEntry({
    required this.message,
    required this.level,
    required this.timestamp,
  });

  factory LogEntry.info(String message) => LogEntry(
        message: message,
        level: LogLevel.info,
        timestamp: DateTime.now(),
      );

  factory LogEntry.warning(String message) => LogEntry(
        message: message,
        level: LogLevel.warning,
        timestamp: DateTime.now(),
      );

  factory LogEntry.error(String message) => LogEntry(
        message: message,
        level: LogLevel.error,
        timestamp: DateTime.now(),
      );

  factory LogEntry.success(String message) => LogEntry(
        message: message,
        level: LogLevel.success,
        timestamp: DateTime.now(),
      );

  factory LogEntry.fromType(String type, String message) {
    switch (type) {
      case 'warning':
        return LogEntry.warning(message);
      case 'error':
        return LogEntry.error(message);
      case 'success':
        return LogEntry.success(message);
      default:
        return LogEntry.info(message);
    }
  }
}
