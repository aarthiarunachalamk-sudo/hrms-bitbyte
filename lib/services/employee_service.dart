import 'dart:math' as math;
import '../models/employee.dart';
import 'api_client.dart';

class EmployeeService {
  /// Fetch all active employees.
  static Future<List<Employee>> getAll() async {
    final res = await ApiClient.get('/api/employees');
    final list = res['data'] as List<dynamic>;
    return list.map((e) => Employee.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetch a single employee by ID.
  static Future<Employee> getById(int id) async {
    final res = await ApiClient.get('/api/employees/$id');
    return Employee.fromJson(res['data'] as Map<String, dynamic>);
  }

  /// Login — returns employee data + isFirstLogin flag.
  /// Throws [ApiException] on wrong credentials.
  static Future<({Employee employee, bool isFirstLogin})> login({
    required String email,
    required String password,
  }) async {
    final res = await ApiClient.post('/api/auth/login', {
      'email': email,
      'password': password,
    });
    final data = res['data'] as Map<String, dynamic>;
    return (
      employee: Employee.fromJson(data),
      isFirstLogin: data['is_first_login'] as bool? ?? true,
    );
  }

  /// Change password — verifies temp password then sets the new one.
  /// Throws [ApiException] on failure.
  static Future<void> changePassword({
    required String email,
    required String tempPassword,
    required String newPassword,
  }) async {
    await ApiClient.post('/api/auth/change-password', {
      'email': email,
      'temp_password': tempPassword,
      'new_password': newPassword,
    });
  }

  /// Create a new employee.
  static Future<Employee> create({
    required String employeeCode,
    required String fullName,
    required String email,
    String? department,
    String? designation,
    String? sector,
  }) async {
    final res = await ApiClient.post('/api/employees', {
      'employee_code': employeeCode,
      'full_name': fullName,
      'email': email,
      if (department != null) 'department': department,
      if (designation != null) 'designation': designation,
      if (sector != null) 'sector': sector,
    });
    return Employee.fromJson(res['data'] as Map<String, dynamic>);
  }

  static Future<Map<String, dynamic>> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String designation,
    required String birthday,
    required String joiningDate,
  }) async {
    try {
      final res = await ApiClient.post('/api/employees/signup', {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'designation': designation,
        'birthday': birthday,
        'joiningDate': joiningDate,
      });
      return res['data'] as Map<String, dynamic>;
    } catch (e) {
      // ignore: avoid_print
      print('Backend server offline ($e). Falling back to mock registration.');
      final random = math.Random();
      const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%';
      final tempPassword = 'BB-${List.generate(10, (index) => chars[random.nextInt(chars.length)]).join()}';
      return {
        'tempPassword': tempPassword,
        'emailPreviewUrl': null,
        'isOffline': true,
      };
    }
  }
}

