class Employee {
  final int id;
  final String employeeCode;
  final String fullName;
  final String email;
  final String? department;
  final String? designation;
  final String sector;
  final bool isActive;
  final DateTime createdAt;

  const Employee({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.email,
    this.department,
    this.designation,
    required this.sector,
    required this.isActive,
    required this.createdAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int,
      employeeCode: json['employee_code'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      department: json['department'] as String?,
      designation: json['designation'] as String?,
      sector: json['sector'] as String? ?? 'Sector 09A',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'employee_code': employeeCode,
    'full_name': fullName,
    'email': email,
    'department': department,
    'designation': designation,
    'sector': sector,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
  };
}
