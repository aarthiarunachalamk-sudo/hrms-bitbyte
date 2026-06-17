class AttendanceRecord {
  final int id;
  final int employeeId;
  final String? fullName;
  final String? employeeCode;
  final DateTime workDate;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final int? workingMinutes;
  final int overtimeMinutes;
  final int lateMinutes;
  final String status;
  final String zone;
  final String authMethod;
  final String? notes;
  final String? checkInSelfieUrl;
  final String? checkOutSelfieUrl;

  // Pre-formatted display strings from the API
  final String workingHoursDisplay;
  final String overtimeDisplay;
  final String lateDisplay;

  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    this.fullName,
    this.employeeCode,
    required this.workDate,
    this.checkInTime,
    this.checkOutTime,
    this.workingMinutes,
    required this.overtimeMinutes,
    required this.lateMinutes,
    required this.status,
    required this.zone,
    required this.authMethod,
    this.notes,
    this.checkInSelfieUrl,
    this.checkOutSelfieUrl,
    required this.workingHoursDisplay,
    required this.overtimeDisplay,
    required this.lateDisplay,
  });

  bool get isCheckedIn  => checkInTime != null;
  bool get isCheckedOut => checkOutTime != null;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as int,
      employeeId: json['employee_id'] as int,
      fullName: json['full_name'] as String?,
      employeeCode: json['employee_code'] as String?,
      workDate: DateTime.parse(json['work_date'] as String),
      checkInTime: json['check_in_time'] != null
          ? DateTime.parse(json['check_in_time'] as String)
          : null,
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'] as String)
          : null,
      workingMinutes: json['working_minutes'] as int?,
      overtimeMinutes: json['overtime_minutes'] as int? ?? 0,
      lateMinutes: json['late_minutes'] as int? ?? 0,
      status: json['status'] as String? ?? 'absent',
      zone: json['zone'] as String? ?? 'Tech Hub South',
      authMethod: json['auth_method'] as String? ?? 'Biometric/NFC',
      notes: json['notes'] as String?,
      checkInSelfieUrl: json['check_in_selfie_url'] as String?,
      checkOutSelfieUrl: json['check_out_selfie_url'] as String?,
      workingHoursDisplay: json['working_hours_display'] as String? ?? '00:00',
      overtimeDisplay: json['overtime_display'] as String? ?? '00:00',
      lateDisplay: json['late_display'] as String? ?? '00:00',
    );
  }
}
