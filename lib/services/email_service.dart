import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

/// Sends transactional emails via Gmail SMTP using an App Password.
///
/// The Gmail account and App Password are configured below.
/// Make sure "Less secure app access" is OFF and a valid App Password is used
/// (generated from Google Account → Security → 2-Step Verification → App Passwords).
class EmailService {
  // ── Gmail SMTP credentials ─────────────────────────────────────────────
  static const String _username    = "aarthiarunachalamk@gmail.com";
  static const String _appPassword = "plme htqa bqag dcrc";

  /// Sends the temporary-password welcome email to [recipientEmail].
  /// Returns `true` on success, `false` on failure (logs the error).
  static Future<bool> sendTempPasswordEmail({
    required String recipientEmail,
    required String recipientName,
    required String tempPassword,
  }) async {
    final smtpServer = gmail(_username, _appPassword);

    final message = Message()
      ..from = Address(_username, 'HRMS – BitByte')
      ..recipients.add(recipientEmail)
      ..subject = 'Welcome to HRMS – Your Temporary Login Credentials'
      ..html = '''
<!DOCTYPE html>
<html>
<body style="margin:0;padding:0;background:#f4f6fb;font-family:Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0">
    <tr>
      <td align="center" style="padding:40px 0;">
        <table width="480" cellpadding="0" cellspacing="0"
               style="background:#ffffff;border-radius:12px;
                      box-shadow:0 4px 24px rgba(0,0,0,0.08);
                      overflow:hidden;">
          <!-- Header -->
          <tr>
            <td style="background:linear-gradient(135deg,#004AC6,#00B4D8);
                        padding:32px 36px;text-align:center;">
              <h1 style="margin:0;color:#ffffff;font-size:28px;
                          letter-spacing:4px;font-weight:900;">HRMS</h1>
              <p style="margin:6px 0 0;color:rgba(255,255,255,0.8);
                         font-size:13px;">BitByte Workforce Management</p>
            </td>
          </tr>
          <!-- Body -->
          <tr>
            <td style="padding:36px;">
              <p style="margin:0 0 12px;font-size:16px;color:#1A2340;">
                Hi <strong>$recipientName</strong>,
              </p>
              <p style="margin:0 0 20px;font-size:14px;color:#434655;line-height:1.6;">
                Your HRMS account has been created successfully.
                Use the temporary password below to log in and
                <strong>change it immediately</strong> on first login.
              </p>

              <!-- Password box -->
              <table width="100%" cellpadding="0" cellspacing="0"
                     style="margin:0 0 24px;">
                <tr>
                  <td style="background:#EFF4FF;border:1.5px solid #004AC6;
                              border-radius:8px;padding:20px;text-align:center;">
                    <p style="margin:0 0 6px;font-size:11px;
                               color:#004AC6;letter-spacing:2px;
                               text-transform:uppercase;font-weight:700;">
                      Temporary Password
                    </p>
                    <p style="margin:0;font-size:24px;font-weight:900;
                               color:#0B1C30;letter-spacing:4px;
                               font-family:monospace;">
                      $tempPassword
                    </p>
                  </td>
                </tr>
              </table>

              <p style="margin:0 0 8px;font-size:13px;color:#737686;">
                📧 <strong>Account Email:</strong> $recipientEmail
              </p>
              <p style="margin:0 0 24px;font-size:13px;color:#d32f2f;">
                ⚠️ This password is temporary. Please change it after your
                first login to keep your account secure.
              </p>

              <!-- CTA Button -->
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td align="center">
                    <a href="#"
                       style="display:inline-block;background:#004AC6;
                               color:#ffffff;text-decoration:none;
                               font-size:15px;font-weight:700;
                               padding:14px 40px;border-radius:8px;">
                      Proceed to Login
                    </a>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <!-- Footer -->
          <tr>
            <td style="background:#f4f6fb;padding:20px 36px;
                        text-align:center;border-top:1px solid #e8eaed;">
              <p style="margin:0;font-size:11px;color:#9AA0B5;">
                © 2025 BitByte Technologies · ISO 27001 Certified ·
                AES-256 Encrypted
              </p>
              <p style="margin:4px 0 0;font-size:11px;color:#9AA0B5;">
                This is an automated message, please do not reply.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
''';

    try {
      await send(message, smtpServer);
      // ignore: avoid_print
      print('[EmailService] Email sent to $recipientEmail');
      return true;
    } on MailerException catch (e) {
      // ignore: avoid_print
      print('[EmailService] Mailer error: ${e.message}');
      for (final p in e.problems) {
        // ignore: avoid_print
        print('  Problem: ${p.code} – ${p.msg}');
      }
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('[EmailService] Unexpected error: $e');
      return false;
    }
  }
}
