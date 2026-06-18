// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../widgets/glass_container.dart';
// import '../widgets/bitbyte_logo.dart';
// import '../services/employee_service.dart';
// import '../services/api_client.dart';
// import 'login_screen.dart';

// /// Forced "first login" password-change screen.
// ///
// /// Flow: LoginScreen (temp password) -> ChangePasswordScreen -> LoginScreen
// /// (now log in again with the new password) -> MainNavigationScreen.
// class ChangePasswordScreen extends StatefulWidget {
//   final String email;
//   final String tempPassword;

//   const ChangePasswordScreen({
//     super.key,
//     required this.email,
//     required this.tempPassword,
//   });

//   @override
//   State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
// }

// class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();

//   bool _obscureNew = true;
//   bool _obscureConfirm = true;
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _onCreatePasswordPressed() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       await EmployeeService.changePassword(
//         email: widget.email,
//         tempPassword: widget.tempPassword,
//         newPassword: _newPasswordController.text.trim(),
//       );

//       if (!mounted) return;
//       setState(() => _isLoading = false);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Password changed successfully! Please log in again.'),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );

//       // Send the user back to Login (email pre-filled) — clears the whole stack
//       // so they can't go "back" into the change-password / temp-password flow.
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(
//           builder: (_) => LoginScreen(initialEmail: widget.email),
//         ),
//         (route) => false,
//       );
//     } on ApiException catch (e) {
//       if (!mounted) return;
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(e.message),
//           backgroundColor: Theme.of(context).colorScheme.error,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Something went wrong: $e'),
//           backgroundColor: Theme.of(context).colorScheme.error,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     final labelStyle = GoogleFonts.inter(
//       fontSize: 11,
//       fontWeight: FontWeight.w700,
//       color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
//       letterSpacing: 1.2,
//     );

//     return Scaffold(
//       backgroundColor: theme.colorScheme.surface,
//       body: Stack(
//         children: [
//           // Subtle ambient glow (same style as Login/Signup)
//           Positioned(
//             top: -100,
//             left: -100,
//             child: Container(
//               width: 350,
//               height: 350,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: theme.colorScheme.primary.withOpacity(0.04),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: -150,
//             right: -100,
//             child: Container(
//               width: 400,
//               height: 400,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: theme.colorScheme.secondary.withOpacity(0.02),
//               ),
//             ),
//           ),

//           SafeArea(
//             child: Center(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const SizedBox(height: 10),
//                     const BitByteLogo(size: 80, showText: true, fontSize: 22),
//                     const SizedBox(height: 16),

//                     Text(
//                       'Set New Password',
//                       style: GoogleFonts.outfit(
//                         fontSize: 28,
//                         fontWeight: FontWeight.w800,
//                         color: theme.colorScheme.primary,
//                         letterSpacing: 1.0,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'This is your first login. Please set a new\npassword to continue to your dashboard.',
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.inter(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                         color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
//                       ),
//                     ),
//                     const SizedBox(height: 28),

//                     GlassContainer(
//                       padding: const EdgeInsets.all(20.0),
//                       borderRadius: BorderRadius.circular(24.0),
//                       backgroundColor: isDark ? const Color(0xFF131722).withOpacity(0.75) : theme.colorScheme.surface,
//                       borderColor: theme.colorScheme.outline,
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Temporary password — fetched automatically, read-only
//                             Text('TEMPORARY PASSWORD (used to log in)', style: labelStyle),
//                             const SizedBox(height: 8),
//                             TextFormField(
//                               initialValue: widget.tempPassword,
//                               readOnly: true,
//                               style: GoogleFonts.inter(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w600,
//                                 color: theme.colorScheme.onSurface,
//                               ),
//                               decoration: InputDecoration(
//                                 prefixIcon: Icon(
//                                   Icons.mail_lock_outlined,
//                                   color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
//                                   size: 20,
//                                 ),
//                                 filled: true,
//                                 fillColor: isDark ? const Color(0xFF0F121C) : theme.colorScheme.surfaceDim.withOpacity(0.5),
//                                 contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12.0),
//                                   borderSide: BorderSide(color: theme.colorScheme.outline, width: 1.0),
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12.0),
//                                   borderSide: BorderSide(color: theme.colorScheme.outline, width: 1.0),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 20),

//                             // New Password
//                             Text('NEW PASSWORD', style: labelStyle),
//                             const SizedBox(height: 8),
//                             TextFormField(
//                               controller: _newPasswordController,
//                               obscureText: _obscureNew,
//                               style: GoogleFonts.inter(fontSize: 15, color: theme.colorScheme.onSurface),
//                               decoration: _buildInputDecoration(
//                                 hintText: 'Enter new password',
//                                 theme: theme,
//                                 isDark: isDark,
//                                 suffixIcon: IconButton(
//                                   icon: Icon(
//                                     _obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
//                                     color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
//                                     size: 20,
//                                   ),
//                                   onPressed: () => setState(() => _obscureNew = !_obscureNew),
//                                 ),
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.trim().isEmpty) {
//                                   return 'Please enter a new password';
//                                 }
//                                 if (value.trim().length < 8) {
//                                   return 'Password must be at least 8 characters';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 20),

//                             // Confirm Password
//                             Text('CONFIRM PASSWORD', style: labelStyle),
//                             const SizedBox(height: 8),
//                             TextFormField(
//                               controller: _confirmPasswordController,
//                               obscureText: _obscureConfirm,
//                               style: GoogleFonts.inter(fontSize: 15, color: theme.colorScheme.onSurface),
//                               decoration: _buildInputDecoration(
//                                 hintText: 'Re-enter new password',
//                                 theme: theme,
//                                 isDark: isDark,
//                                 suffixIcon: IconButton(
//                                   icon: Icon(
//                                     _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
//                                     color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
//                                     size: 20,
//                                   ),
//                                   onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
//                                 ),
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.trim().isEmpty) {
//                                   return 'Please confirm your new password';
//                                 }
//                                 if (value.trim() != _newPasswordController.text.trim()) {
//                                   return 'Passwords do not match';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 24),

//                             // Create Password Button
//                             SizedBox(
//                               width: double.infinity,
//                               height: 54,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(14),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: theme.colorScheme.primary.withOpacity(0.12),
//                                       blurRadius: 12,
//                                       offset: const Offset(0, 4),
//                                     ),
//                                   ],
//                                 ),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(14),
//                                   child: Material(
//                                     color: Colors.transparent,
//                                     child: InkWell(
//                                       onTap: _isLoading ? null : _onCreatePasswordPressed,
//                                       child: Ink(
//                                         decoration: BoxDecoration(
//                                           gradient: LinearGradient(
//                                             begin: Alignment.centerLeft,
//                                             end: Alignment.centerRight,
//                                             colors: [
//                                               theme.colorScheme.primary,
//                                               theme.colorScheme.secondary,
//                                             ],
//                                           ),
//                                         ),
//                                         child: Center(
//                                           child: _isLoading
//                                               ? const SizedBox(
//                                                   height: 24,
//                                                   width: 24,
//                                                   child: CircularProgressIndicator(
//                                                     strokeWidth: 2.5,
//                                                     color: Colors.white,
//                                                   ),
//                                                 )
//                                               : Row(
//                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                   children: [
//                                                     Text(
//                                                       'Create Password',
//                                                       style: GoogleFonts.inter(
//                                                         fontSize: 16,
//                                                         fontWeight: FontWeight.bold,
//                                                         color: Colors.white,
//                                                         letterSpacing: 0.5,
//                                                       ),
//                                                     ),
//                                                     const SizedBox(width: 8),
//                                                     const Icon(
//                                                       Icons.check_circle_outline,
//                                                       color: Colors.white,
//                                                       size: 18,
//                                                     ),
//                                                   ],
//                                                 ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 28),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   InputDecoration _buildInputDecoration({
//     required String hintText,
//     required ThemeData theme,
//     required bool isDark,
//     Widget? suffixIcon,
//   }) {
//     return InputDecoration(
//       hintText: hintText,
//       hintStyle: GoogleFonts.inter(
//         fontSize: 14,
//         color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
//       ),
//       prefixIcon: Icon(
//         Icons.lock_outlined,
//         color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
//         size: 20,
//       ),
//       suffixIcon: suffixIcon,
//       filled: true,
//       fillColor: isDark ? const Color(0xFF0F121C) : theme.colorScheme.surfaceDim.withOpacity(0.5),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//       errorStyle: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.error),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12.0),
//         borderSide: BorderSide(color: theme.colorScheme.outline, width: 1.0),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12.0),
//         borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.0),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12.0),
//         borderSide: BorderSide(color: theme.colorScheme.error.withOpacity(0.5), width: 1.0),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12.0),
//         borderSide: BorderSide(color: theme.colorScheme.error, width: 1.0),
//       ),
//     );
//   }
// }