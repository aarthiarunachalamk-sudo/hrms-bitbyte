import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';
import '../widgets/bitbyte_logo.dart';
import '../services/employee_service.dart';
import '../services/email_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _joiningDateController = TextEditingController();
  
  String? _selectedRole;
  bool _isLoading = false;

  final List<String> _designations = [
    'Software Engineer',
    'HR Specialist',
    'Product Manager',
    'UI/UX Designer',
    'DevOps Engineer',
    'QA Engineer',
    'Admin',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _joiningDateController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller, {
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().isBefore(lastDate) && DateTime.now().isAfter(firstDate)
          ? DateTime.now()
          : lastDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: isDark 
                ? const ColorScheme.dark(
                    primary: Color(0xFF00D2FF),
                    onPrimary: Color(0xFF0D0D16),
                    surface: Color(0xFF131722),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: theme.colorScheme.primary,
                    onPrimary: theme.colorScheme.onPrimary,
                    surface: theme.colorScheme.surface,
                    onSurface: theme.colorScheme.onSurface,
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = formatDate(picked);
      });
      _formKey.currentState?.validate();
    }
  }

  void _onSignUpPressed() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await EmployeeService.signUp(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          designation: _selectedRole!,
          birthday: _birthdayController.text,
          joiningDate: _joiningDateController.text,
        );

        final String tempPassword = result['tempPassword'] as String? ?? '';
        final String? emailPreviewUrl = result['emailPreviewUrl'] as String?;

        // Send welcome email
        await EmailService.sendTempPasswordEmail(
          recipientEmail: _emailController.text.trim(),
          recipientName: '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
          tempPassword: tempPassword,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Show registration success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              final dialogTheme = Theme.of(context);
              return AlertDialog(
                backgroundColor: dialogTheme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: dialogTheme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                title: Text(
                  'Registration Complete!',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: dialogTheme.colorScheme.onSurface,
                  ),
                ),
                content: Text(
                  'Your account has been successfully created. We have sent a temporary login password to your email address.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: dialogTheme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to login
                    },
                    child: Text(
                      'Close',
                      style: GoogleFonts.inter(
                        color: dialogTheme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dialogTheme.colorScheme.primary,
                      foregroundColor: dialogTheme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Close dialog
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(
                            initialEmail: _emailController.text.trim(),
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Go to Login',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          );
        }
      } catch (err) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.error,
              content: Text(
                err.toString().replaceAll('ApiException: ', ''),
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.onError,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final labelStyle = GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
      letterSpacing: 1.2,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Subtle ambient glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.03),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withOpacity(0.02),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Top Logo Section
                  const BitByteLogo(
                    size: 80,
                    showText: false,
                  ),
                  const SizedBox(height: 12),

                  // Header text
                  Text(
                    'HRMS',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main container
                  GlassContainer(
                    padding: const EdgeInsets.all(20.0),
                    borderRadius: BorderRadius.circular(24.0),
                    backgroundColor: isDark ? const Color(0xFF131722).withOpacity(0.75) : theme.colorScheme.surface,
                    borderColor: theme.colorScheme.outline,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Form Title
                          Text(
                            'Create Account',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Join the next-gen workforce management system.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // First and Last Name in a Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'FIRST NAME',
                                      style: labelStyle,
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _firstNameController,
                                      style: GoogleFonts.inter(fontSize: 15, color: theme.colorScheme.onSurface),
                                      decoration: _buildInputDecoration(hintText: 'John', theme: theme, isDark: isDark),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        if (value.trim().length < 2) {
                                          return 'At least 2 characters';
                                        }
                                        if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value.trim())) {
                                          return 'Alphabetic only';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'LAST NAME',
                                      style: labelStyle,
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _lastNameController,
                                      style: GoogleFonts.inter(fontSize: 15, color: theme.colorScheme.onSurface),
                                      decoration: _buildInputDecoration(hintText: 'Doe', theme: theme, isDark: isDark),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        if (value.trim().length < 2) {
                                          return 'At least 2 characters';
                                        }
                                        if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value.trim())) {
                                          return 'Alphabetic only';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Email ID
                          Text(
                            'EMAIL ID',
                            style: labelStyle,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.inter(fontSize: 15, color: theme.colorScheme.onSurface),
                            decoration: _buildInputDecoration(
                              hintText: 'john.doe@techcorp.com',
                              prefixIcon: Icons.email_outlined,
                              theme: theme,
                              isDark: isDark,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email ID';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Designation
                          Text(
                            'DESIGNATION',
                            style: labelStyle,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            dropdownColor: theme.colorScheme.surface,
                            style: GoogleFonts.inter(fontSize: 15, color: theme.colorScheme.onSurface),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                            ),
                            decoration: _buildInputDecoration(
                              hintText: 'Select your role',
                              prefixIcon: Icons.badge_outlined,
                              theme: theme,
                              isDark: isDark,
                            ),
                            items: _designations.map((String designation) {
                              return DropdownMenuItem<String>(
                                value: designation,
                                child: Text(
                                  designation,
                                  style: GoogleFonts.inter(fontSize: 15, color: theme.colorScheme.onSurface),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedRole = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                  return 'Please select your role';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Birthday & Joining Date
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'BIRTHDAY',
                                      style: labelStyle,
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _birthdayController,
                                      readOnly: true,
                                      onTap: () => _selectDate(
                                        context,
                                        _birthdayController,
                                        firstDate: DateTime(1950),
                                        lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)), // Minimum 16 years old
                                      ),
                                      style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface),
                                      decoration: _buildInputDecoration(
                                        hintText: 'YYYY-MM-DD',
                                        theme: theme,
                                        isDark: isDark,
                                        suffixIcon: Icon(
                                          Icons.calendar_today_outlined,
                                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                                          size: 18,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        if (_joiningDateController.text.isNotEmpty) {
                                          try {
                                            final dob = DateTime.parse(value);
                                            final doc = DateTime.parse(_joiningDateController.text);
                                            final ageAtJoining = doc.difference(dob).inDays / 365.25;
                                            if (ageAtJoining < 18) {
                                              return 'Must be 18+ at joining';
                                            }
                                          } catch (_) {}
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'JOINING DATE',
                                      style: labelStyle,
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _joiningDateController,
                                      readOnly: true,
                                      onTap: () => _selectDate(
                                        context,
                                        _joiningDateController,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                                      ),
                                      style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface),
                                      decoration: _buildInputDecoration(
                                        hintText: 'YYYY-MM-DD',
                                        theme: theme,
                                        isDark: isDark,
                                        suffixIcon: Icon(
                                          Icons.calendar_today_outlined,
                                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                                          size: 18,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        if (_birthdayController.text.isNotEmpty) {
                                          try {
                                            final dob = DateTime.parse(_birthdayController.text);
                                            final doc = DateTime.parse(value);
                                            final ageAtJoining = doc.difference(dob).inDays / 365.25;
                                            if (ageAtJoining < 18) {
                                              return 'Must be 18+ at joining';
                                            }
                                          } catch (_) {}
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Sign Up Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _isLoading ? null : _onSignUpPressed,
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            theme.colorScheme.primary,
                                            theme.colorScheme.secondary,
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Sign Up',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                    Icons.arrow_forward_rounded,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Divider
                          Divider(
                            color: theme.colorScheme.outline,
                            thickness: 1,
                          ),
                          const SizedBox(height: 16),

                          // Already have an account row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Log In',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.login_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Legal Footer Links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Privacy Policy coming soon!')),
                          );
                        },
                        child: Text(
                          'Privacy Policy',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Technical Support coming soon!')),
                          );
                        },
                        child: Text(
                          'Technical Support',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required ThemeData theme,
    required bool isDark,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
      ),
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              size: 20,
            )
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark ? const Color(0xFF0F121C) : theme.colorScheme.surfaceDim.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      errorStyle: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.error),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: theme.colorScheme.outline,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 1.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: theme.colorScheme.error.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: theme.colorScheme.error,
          width: 1.0,
        ),
      ),
    );
  }
}
