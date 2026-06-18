import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/employee_service.dart';
import '../services/api_client.dart';
import 'login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  /// Email of the user — passed from login screen.
  final String email;
  /// The temp password they just logged in with.
  final String tempPassword;

  const ChangePasswordScreen({
    super.key,
    required this.email,
    required this.tempPassword,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tempController    = TextEditingController();
  final _newController     = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showTemp    = false;
  bool _showNew     = false;
  bool _showConfirm = false;
  bool _isLoading   = false;

  // ── Security requirement states
  bool get _hasMinLength  => _newController.text.length >= 8;
  bool get _hasNumber     => _newController.text.contains(RegExp(r'\d'));
  bool get _hasSpecial    => _newController.text.contains(RegExp(r'[@#$%^&*(),.?":{}|<>!]'));
  bool get _passwordMatch =>
      _newController.text.isNotEmpty &&
      _newController.text == _confirmController.text;

  @override
  void initState() {
    super.initState();
    // Pre-fill the temp password from login
    _tempController.text = widget.tempPassword;
    _newController.addListener(() => setState(() {}));
    _confirmController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tempController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasMinLength || !_hasNumber || !_hasSpecial || !_passwordMatch) {
      _showSnack('Please meet all security requirements.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await EmployeeService.changePassword(
        email: widget.email,
        tempPassword: _tempController.text.trim(),
        newPassword: _newController.text.trim(),
      );

      if (!mounted) return;
      _showSnack('Password updated! Please log in with your new password.');

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      // ── Navigate back to Login with email pre-filled
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(initialEmail: widget.email),
        ),
        (route) => false, // clear entire stack
      );
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack(e.message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('Server unreachable. Try again.', isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF0284C7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg         = Color(0xFF0D0F1A);
    const surface    = Color(0xFF151822);
    const card       = Color(0xFF1A1D2E);
    const primary    = Color(0xFF38BDF8);
    const onSurface  = Color(0xFFE2E8F0);
    const subtle     = Color(0xFF64748B);
    const border     = Color(0xFF1E2535);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: border),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: onSurface, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.shield_outlined,
                            color: primary, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'BitByte HRMS',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.notifications_outlined,
                      color: subtle, size: 22),
                ],
              ),
            ),

            // ── Scrollable body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // ── Shield icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary.withValues(alpha: 0.12),
                          border: Border.all(
                              color: primary.withValues(alpha: 0.25), width: 1.5),
                        ),
                        child: const Icon(Icons.lock_outline_rounded,
                            color: primary, size: 32),
                      ),
                      const SizedBox(height: 20),

                      // ── Title
                      Text(
                        'Change Your\nPassword',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'For your security, please update the\ntemporary password provided by your\nadministrator.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: subtle,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Temporary password field
                      _buildFieldLabel('Temporary Password'),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        controller: _tempController,
                        hint: 'Enter temporary password',
                        show: _showTemp,
                        onToggle: () => setState(() => _showTemp = !_showTemp),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      // ── New password field
                      _buildFieldLabel('New Password'),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        controller: _newController,
                        hint: 'Min. 8 characters',
                        show: _showNew,
                        onToggle: () => setState(() => _showNew = !_showNew),
                        validator: (v) =>
                            (v == null || v.length < 8) ? 'Min. 8 characters' : null,
                      ),
                      const SizedBox(height: 20),

                      // ── Confirm password field
                      _buildFieldLabel('Confirm Password'),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        controller: _confirmController,
                        hint: 'Repeat new password',
                        show: _showConfirm,
                        onToggle: () =>
                            setState(() => _showConfirm = !_showConfirm),
                        validator: (v) => v != _newController.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // ── Security requirements card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.shield_outlined,
                                    color: primary, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Security Requirements',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _buildRequirement(
                                'At least 8 characters long', _hasMinLength),
                            _buildRequirement(
                                'Contains at least one number', _hasNumber),
                            _buildRequirement(
                                'One special character (@#\$%^&*)', _hasSpecial),
                            _buildRequirement(
                                'Passwords must match', _passwordMatch),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Text(
                                   'Create Password',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Help link
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.help_outline_rounded,
                                color: subtle, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Need help? ',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: subtle),
                            ),
                            Text(
                              'Contact HR Support',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ── Footer
                      Text(
                        '© 2024 BitByte Systems Inc. All rights reserved.',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: subtle.withValues(alpha: 0.6)),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF38BDF8),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool show,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !show,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFFE2E8F0)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
            fontSize: 14, color: const Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFF151822),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E2535)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E2535)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            show ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: const Color(0xFF64748B),
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _buildRequirement(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: met ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: met
                  ? const Color(0xFFE2E8F0)
                  : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
