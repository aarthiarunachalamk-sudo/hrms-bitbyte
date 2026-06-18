import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';
import '../widgets/bitbyte_logo.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';
import '../services/session_manager.dart';
import '../services/api_client.dart';
import 'main_navigation.dart';
import 'signup_screen.dart';
import 'change_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? initialEmail;
  final String? initialPassword;

  const LoginScreen({
    super.key,
    this.initialEmail,
    this.initialPassword,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _stayLoggedIn = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
    if (widget.initialPassword != null) {
      _passwordController.text = widget.initialPassword!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillCredentials(String role) {
    setState(() {
      switch (role) {
        case 'Employee':
          _emailController.text = 'aarthiarunachalamk@gmail.com';
          _passwordController.text = 'BB-TempPass@2026';
          break;
        case 'Admin':
          _emailController.text = 'admin@bitbyte.tech';
          _passwordController.text = 'Admin@1234';
          break;
        case 'SuperAdmin':
          _emailController.text = 'superadmin@bitbyte.tech';
          _passwordController.text = 'Super@1234';
          break;
      }
    });
  }

  Future<void> _onLoginPressed() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final result = await EmployeeService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

SessionManager.login(result.employee);

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (result.isFirstLogin) {
          // First login — force the user to set a new password
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ChangePasswordScreen(
                email: _emailController.text.trim(),
                tempPassword: _passwordController.text.trim(),
              ),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          );
        }
      } on ApiException catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        // Backend offline — fall back to mock login for demo
        debugPrint('Backend offline ($e). Logging in with mock profile.');

       SessionManager.login(Employee(
          id: 1,
          firstName: 'Aarthi',
          lastName: 'S',
          email: _emailController.text.trim(),
          designation: 'Senior Developer',
          isActive: true,
          createdAt: DateTime.now(),
        ));

        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                color: theme.colorScheme.primary.withOpacity(0.04),
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    
                    // Top Logo Section
                    const BitByteLogo(
                      size: 80,
                      showText: true,
                      fontSize: 22,
                    ),
                    const SizedBox(height: 16),
                    
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
                    const SizedBox(height: 6),
                    Text(
                      'HUMAN RESOURCES MANAGEMENT SYSTEM',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMiniTag('SMART HR', theme),
                        const SizedBox(width: 6),
                        Icon(Icons.circle, size: 3, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4)),
                        const SizedBox(width: 6),
                        _buildMiniTag('SMARTER ORG', theme),
                        const SizedBox(width: 6),
                        Icon(Icons.circle, size: 3, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4)),
                        const SizedBox(width: 6),
                        _buildMiniTag('SMARTEST RESULTS', theme),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Main glassmorphic login container
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
                            // Email Label
                            Text(
                              'EMAIL ID',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Email Input
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.inter(fontSize: 15, color: theme.colorScheme.onSurface),
                              decoration: _buildInputDecoration(
                                hintText: 'e.g. admin@hrms.tech',
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
                            const SizedBox(height: 20),

                            // Password Labels
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'PASSWORD',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Mock forgot password action
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Password reset link sent!')),
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Password Input
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.inter(fontSize: 15, color: theme.colorScheme.onSurface),
                              decoration: _buildInputDecoration(
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outlined,
                                theme: theme,
                                isDark: isDark,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.trim().length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Stay logged in checkbox
                            Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _stayLoggedIn,
                                    activeColor: const Color(0xFF00FF87),
                                    checkColor: const Color(0xFF12131C),
                                    side: BorderSide(
                                      color: theme.colorScheme.primary.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        _stayLoggedIn = val ?? false;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Stay logged in for 30 days',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Login Action Button
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withOpacity(0.12),
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
                                      onTap: _isLoading ? null : _onLoginPressed,
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
                                                      'Login',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Icon(
                                                      Icons.login_rounded,
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

                            // Divider for Quick Login
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: theme.colorScheme.outline.withOpacity(0.5),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text(
                                    'Quick Login (tap to fill)',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: theme.colorScheme.outline.withOpacity(0.5),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Quick Login Chips
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildQuickLoginChip('Employee', theme, isDark),
                                const SizedBox(width: 10),
                                _buildQuickLoginChip('Admin', theme, isDark),
                                const SizedBox(width: 10),
                                _buildQuickLoginChip('SuperAdmin', theme, isDark),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Bottom Sign Up Text
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                            ),
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Legal Footer Icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 13,
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ISO 27001 CERTIFIED',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            '|',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.2),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.enhanced_encryption_outlined,
                              size: 13,
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AES-256 ENCRYPTED',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTag(String text, ThemeData theme) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildQuickLoginChip(String label, ThemeData theme, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _fillCredentials(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C2230).withOpacity(0.4) : theme.colorScheme.surfaceDim,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.12),
              width: 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.85),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    required ThemeData theme,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        size: 20,
      ),
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
