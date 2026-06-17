import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/deep_ocean_theme.dart';
import '../widgets/glass_container.dart';
import 'login_screen.dart';

class InboxScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String tempPassword;
  final String? emailPreviewUrl;

  const InboxScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.tempPassword,
    this.emailPreviewUrl,
  });

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  bool _isMailOpen = false;

  void _copyToClipboardAndNavigate() {
    Clipboard.setData(ClipboardData(text: widget.tempPassword));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Temporary password copied to clipboard!',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Navigate back to login with pre-filled credentials
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          initialEmail: widget.email,
          initialPassword: widget.tempPassword,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = '${widget.firstName} ${widget.lastName}';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'TechMail Inbox',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Inbox is up to date.')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.02),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Mailbox header status
                Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.brightness == Brightness.dark 
                      ? const Color(0xFF0F121C) 
                      : Theme.of(context).cardColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.brightness == Brightness.dark 
                            ? const Color(0xFF1C2230) 
                            : Theme.of(context).colorScheme.primaryContainer,
                        radius: 18,
                        child: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            widget.email,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '1 Unread',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Mail content list or detail view
                Expanded(
                  child: _isMailOpen ? _buildMailDetail(fullName) : _buildMailList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMailList() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isMailOpen = true;
            });
          },
          child: GlassContainer(
            padding: const EdgeInsets.all(16.0),
            borderRadius: BorderRadius.circular(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unread dot & Icon
                Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.brightness == Brightness.dark 
                            ? const Color(0xFF1A1F2E) 
                            : Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: Icon(
                        Icons.mark_email_unread_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.brightness == Brightness.dark 
                              ? const Color(0xFF00FF87)
                              : const Color(0xFF10B981),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.brightness == Brightness.dark 
                                ? const Color(0xFF131722) 
                                : Theme.of(context).cardColor, 
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                
                // Email Snippet details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'BitByte HRMS Support',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Just now',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome to BitByte HRMS - Temporary Password',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hello ${widget.firstName}, Welcome to the next-gen workforce management system. Your HRMS account has been successfully created. Below is your temporary credentials...',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMailDetail(String fullName) {
    final accentGreen = Theme.of(context).colorScheme.brightness == Brightness.dark 
        ? const Color(0xFF00FF87)
        : const Color(0xFF10B981);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back to list action
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isMailOpen = false;
              });
            },
            icon: Icon(Icons.arrow_back_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
            label: Text(
              'Back to Inbox',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
          ),
          const SizedBox(height: 12),

          // Email Detail Card
          GlassContainer(
            padding: const EdgeInsets.all(20.0),
            borderRadius: BorderRadius.circular(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject Header
                Text(
                  'Welcome to BitByte HRMS - Temporary Password Generated',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                // From/To Headers
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.brightness == Brightness.dark 
                          ? const Color(0xFF1C2230) 
                          : Theme.of(context).colorScheme.primaryContainer,
                      radius: 20,
                      child: Text(
                        'BB',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                              children: [
                                const TextSpan(
                                  text: 'From: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: 'BitByte HRMS <support@bitbyte.tech>',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                              children: [
                                const TextSpan(
                                  text: 'To: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: widget.email,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Theme.of(context).colorScheme.primary.withOpacity(0.08)),
                const SizedBox(height: 16),

                // Email Body
                Text(
                  'Hello $fullName,',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Welcome to the next-gen workforce management system.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your HRMS account has been successfully created. Please use the temporary credentials below to log in for the first time:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 24),

                // Temporary Password Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.brightness == Brightness.dark 
                        ? const Color(0xFF0F121C) 
                        : Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'TEMPORARY PASSWORD',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        widget.tempPassword,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: accentGreen,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'For your security, you will be prompted to update this password immediately upon your first login.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 32),

                // Proceed Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: accentGreen.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _copyToClipboardAndNavigate,
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  accentGreen,
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Copy & Proceed to Login',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.copy_all_rounded,
                                    color: Theme.of(context).colorScheme.onPrimary,
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
                
                // Show ethereal link text if available
                if (widget.emailPreviewUrl != null) ...[
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Test SMTP URL Generated (Ethereal):',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          widget.emailPreviewUrl!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
