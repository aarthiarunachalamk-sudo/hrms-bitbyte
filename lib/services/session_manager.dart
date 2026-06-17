import '../models/employee.dart';

class SessionManager {
  static Employee? currentUser;

  static bool get isLoggedIn => currentUser != null;

  static void login(Employee employee) {
    currentUser = employee;
  }

  static void logout() {
    currentUser = null;
  }
}
