import 'dart:io';
import '../models/attendance_record.dart';
import '../models/activity_log.dart';
import 'api_client.dart';

class AttendanceService {
  /// Record a check-in for [employeeId] with a captured selfie.
  static Future<AttendanceRecord> checkIn({
    required int employeeId,
    required File selfieFile,
    String zone = 'Tech Hub South',
    String authMethod = 'Biometric/NFC',
    String? workstation,
  }) async {
    final fields = {
      'employee_id': employeeId.toString(),
      'zone': zone,
      'auth_method': authMethod,
      if (workstation != null) 'workstation': workstation,
    };
    
    final res = await ApiClient.multipartPost(
      '/api/attendance/check-in',
      fields,
      'selfie',
      selfieFile,
    );
    return AttendanceRecord.fromJson(res['data'] as Map<String, dynamic>);
  }

  /// Record a check-out for [employeeId] with a captured selfie.
  static Future<AttendanceRecord> checkOut({
    required int employeeId,
    required File selfieFile,
    String zone = 'Tech Hub South',
    String authMethod = 'Biometric/NFC',
    String? workstation,
  }) async {
    final fields = {
      'employee_id': employeeId.toString(),
      'zone': zone,
      'auth_method': authMethod,
      if (workstation != null) 'workstation': workstation,
    };

    final res = await ApiClient.multipartPost(
      '/api/attendance/check-out',
      fields,
      'selfie',
      selfieFile,
    );
    return AttendanceRecord.fromJson(res['data'] as Map<String, dynamic>);
  }

  /// Get today's attendance record for [employeeId]. Returns null if none yet.
  static Future<AttendanceRecord?> getToday(int employeeId) async {
    final res = await ApiClient.get('/api/attendance/today/$employeeId');
    if (res['data'] == null) return null;
    return AttendanceRecord.fromJson(res['data'] as Map<String, dynamic>);
  }

  /// Get paginated attendance history for [employeeId].
  static Future<List<AttendanceRecord>> getHistory(
    int employeeId, {
    int limit = 30,
    int offset = 0,
  }) async {
    final res = await ApiClient.get(
      '/api/attendance/history/$employeeId?limit=$limit&offset=$offset',
    );
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get recent activity logs for [employeeId].
  static Future<List<ActivityLog>> getActivityLogs(
    int employeeId, {
    int limit = 10,
  }) async {
    final res = await ApiClient.get(
      '/api/attendance/activity/$employeeId?limit=$limit',
    );
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => ActivityLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
