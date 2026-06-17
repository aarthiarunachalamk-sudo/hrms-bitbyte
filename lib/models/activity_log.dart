class ActivityLog {
  final int id;
  final int employeeId;
  final String? fullName;
  final String eventType;
  final DateTime eventTime;
  final String? zone;
  final String? workstation;
  final String authMethod;

  const ActivityLog({
    required this.id,
    required this.employeeId,
    this.fullName,
    required this.eventType,
    required this.eventTime,
    this.zone,
    this.workstation,
    required this.authMethod,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as int,
      employeeId: json['employee_id'] as int,
      fullName: json['full_name'] as String?,
      eventType: json['event_type'] as String,
      eventTime: DateTime.parse(json['event_time'] as String),
      zone: json['zone'] as String?,
      workstation: json['workstation'] as String?,
      authMethod: json['auth_method'] as String? ?? 'Biometric/NFC',
    );
  }

  /// Human-readable label for the event type
  String get displayLabel {
    switch (eventType) {
      case 'check_in':       return 'Morning Entry';
      case 'check_out':      return 'Clocked Out';
      case 'break_start':    return 'Break';
      case 'break_end':      return 'Break Ended';
      case 'session_resume': return 'Session Resumed';
      default:               return eventType;
    }
  }
}
