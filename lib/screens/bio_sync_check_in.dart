import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/deep_ocean_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/bitbyte_logo.dart';
import '../services/attendance_service.dart';
import '../services/api_client.dart';
import '../models/attendance_record.dart';

const int _kEmployeeId = 1; // replace with session-based ID in production

class BioSyncCheckInScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onLogoutPressed;

  const BioSyncCheckInScreen({
    super.key,
    this.onMenuPressed,
    this.onLogoutPressed,
  });

  @override
  State<BioSyncCheckInScreen> createState() => _BioSyncCheckInScreenState();
}

class _BioSyncCheckInScreenState extends State<BioSyncCheckInScreen> with TickerProviderStateMixin {
  late Timer _clockTimer;
  late AnimationController _scanController;
  late AnimationController _pulseController;
  
  String _timeString = '00:00:00';
  bool _isLoadingStatus = true;
  bool _isSubmitting = false;
  
  AttendanceRecord? _todayRecord;
  File? _selfieFile;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());

    // Scanner animation moving line up and down
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Pulse animation for the RED live indicator dot
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Load today's check-in/out status
    _loadTodayStatus();
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    if (mounted) {
      setState(() {
        _timeString = "$h:$m:$s";
      });
    }
  }

  Future<void> _loadTodayStatus() async {
    if (!mounted) return;
    setState(() {
      _isLoadingStatus = true;
    });

    try {
      final record = await AttendanceService.getToday(_kEmployeeId);
      if (mounted) {
        setState(() {
          _todayRecord = record;
          _isLoadingStatus = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading status: $e');
      if (mounted) {
        setState(() {
          _isLoadingStatus = false;
        });
      }
    }
  }

  Future<void> _takeSelfie() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null && mounted) {
        setState(() {
          _selfieFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: DeepOceanTheme.errorContainer,
            content: Text(
              'Failed to launch camera: $e',
              style: GoogleFonts.inter(color: DeepOceanTheme.onErrorContainer),
            ),
          ),
        );
      }
    }
  }

  void _clearSelfie() {
    setState(() {
      _selfieFile = null;
    });
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting || _selfieFile == null) return;
    setState(() => _isSubmitting = true);

    final isCheckIn = _todayRecord == null || !_todayRecord!.isCheckedIn;

    try {
      final record = isCheckIn
          ? await AttendanceService.checkIn(
              employeeId: _kEmployeeId,
              selfieFile: _selfieFile!,
              zone: 'Sector 09A',
              authMethod: 'Facial Biometric',
            )
          : await AttendanceService.checkOut(
              employeeId: _kEmployeeId,
              selfieFile: _selfieFile!,
              zone: 'Sector 09A',
              authMethod: 'Facial Biometric',
            );

      if (mounted) {
        setState(() {
          _todayRecord = record;
          _selfieFile = null;
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: DeepOceanTheme.primaryContainer,
            duration: const Duration(seconds: 4),
            content: Row(
              children: [
                const Icon(Icons.verified, color: DeepOceanTheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isCheckIn ? 'Check-In Verification Successful' : 'Check-Out Verification Successful',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: DeepOceanTheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        isCheckIn
                            ? 'Morning check-in registered at ${record.zone}.'
                            : 'Work session complete. Total Hours: ${record.workingHoursDisplay}.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: DeepOceanTheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: DeepOceanTheme.errorContainer,
            content: Text(
              e.message,
              style: GoogleFonts.inter(color: DeepOceanTheme.onErrorContainer),
            ),
          ),
        );
      }
    } catch (err) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: DeepOceanTheme.errorContainer,
            content: Text(
              'Network error: $err',
              style: GoogleFonts.inter(color: DeepOceanTheme.onErrorContainer),
            ),
          ),
        );
      }
    }
  }

  String _getSelfieUrl(String? path) {
    if (path == null) return '';
    if (path.startsWith('http')) return path;
    return '${ApiClient.baseUrl}$path';
  }

  @override
  Widget build(BuildContext context) {
    // Determine the status
    final hasCheckedIn = _todayRecord?.isCheckedIn ?? false;
    final hasCheckedOut = _todayRecord?.isCheckedOut ?? false;

    String headerText = 'Geo Tracking Attendance';
    String descriptionText = 'Synchronize your biometric signature with HRMS\'s global mesh network for secure area access.';
    String buttonText = 'TAKE SELFIE FOR CHECK-IN';
    IconData buttonIcon = Icons.camera_front;
    VoidCallback? buttonAction = _takeSelfie;

    if (_isLoadingStatus) {
      buttonText = 'SYNCHRONIZING SECURE SERVER...';
      buttonIcon = Icons.sync;
      buttonAction = null;
    } else if (!hasCheckedIn) {
      if (_selfieFile != null) {
        buttonText = 'CONFIRM CHECK-IN';
        buttonIcon = Icons.verified_user;
        buttonAction = _handleSubmit;
      } else {
        buttonText = 'TAKE SELFIE FOR CHECK-IN';
        buttonIcon = Icons.camera_front;
        buttonAction = _takeSelfie;
      }
    } else if (!hasCheckedOut) {
      headerText = 'Geo Tracking Check-Out';
      descriptionText = 'Register your check-out signature using a second visual selfie verification.';
      if (_selfieFile != null) {
        buttonText = 'CONFIRM CHECK-OUT';
        buttonIcon = Icons.logout;
        buttonAction = _handleSubmit;
      } else {
        buttonText = 'TAKE SELFIE FOR CHECK-OUT';
        buttonIcon = Icons.camera_front;
        buttonAction = _takeSelfie;
      }
    } else {
      headerText = 'Attendance Complete';
      descriptionText = 'You have registered both check-in and check-out signatures for today.';
      buttonText = 'ATTENDANCE COMPLETED TODAY';
      buttonIcon = Icons.check_circle;
      buttonAction = null;
    }

    return Container(
      decoration: const BoxDecoration(
        color: DeepOceanTheme.background,
      ),
      child: Stack(
        children: [
          // Background ambient lights
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DeepOceanTheme.tertiary.withOpacity(0.03),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: widget.onMenuPressed,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            const BitByteLogo(size: 24, showText: false),
                            const SizedBox(width: 8),
                            Text(
                              'HRMS',
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: DeepOceanTheme.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _loadTodayStatus,
                            icon: const Icon(Icons.refresh, color: DeepOceanTheme.onSurfaceVariant),
                          ),
                          IconButton(
                            onPressed: widget.onLogoutPressed,
                            icon: const Icon(Icons.logout, color: DeepOceanTheme.error),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Header Section
                  Row(
                    children: [
                      const Icon(Icons.security, color: DeepOceanTheme.primary, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        'IDENTITY VERIFICATION PROTOCOLS',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: DeepOceanTheme.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    headerText,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    descriptionText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  // Scanning Frame
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ambient outer rings
                        Container(
                          width: 290,
                          height: 290,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: DeepOceanTheme.primary.withOpacity(0.04),
                              width: 1.5,
                            ),
                          ),
                        ),
                        Container(
                          width: 270,
                          height: 270,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: DeepOceanTheme.primary.withOpacity(0.08),
                              width: 1,
                            ),
                          ),
                        ),
                        // Futuristic circular frame
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: DeepOceanTheme.surfaceContainerHighest,
                              width: 6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: DeepOceanTheme.primary.withOpacity(0.12),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Stack(
                              children: [
                                // Camera Portrait/Selfie Display logic
                                Builder(
                                  builder: (context) {
                                    if (_selfieFile != null) {
                                      // Render captured selfie
                                      return Image.file(
                                        _selfieFile!,
                                        fit: BoxFit.cover,
                                        width: 250,
                                        height: 250,
                                      );
                                    } else if (_todayRecord != null) {
                                      // Render saved DB selfie depending on status
                                      final selfiePath = hasCheckedOut 
                                          ? _todayRecord!.checkOutSelfieUrl
                                          : _todayRecord!.checkInSelfieUrl;
                                      
                                      if (selfiePath != null && selfiePath.isNotEmpty) {
                                        return Image.network(
                                          _getSelfieUrl(selfiePath),
                                          fit: BoxFit.cover,
                                          width: 250,
                                          height: 250,
                                          errorBuilder: (context, error, stackTrace) {
                                            return _buildPlaceholderCamera();
                                          },
                                        );
                                      }
                                    }
                                    return _buildPlaceholderCamera();
                                  },
                                ),
                                
                                // Gradient shading
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.transparent,
                                        DeepOceanTheme.background.withOpacity(0.2),
                                      ],
                                      stops: const [0.6, 1.0],
                                    ),
                                  ),
                                ),
                                
                                // Scanning Line Animation (only active if selfie taken or loading)
                                if (_selfieFile != null || _isLoadingStatus || (_todayRecord != null && !hasCheckedOut))
                                  AnimatedBuilder(
                                    animation: _scanController,
                                    builder: (context, child) {
                                      final translationY = _scanController.value * 238;
                                      return Positioned(
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        child: Transform.translate(
                                          offset: Offset(0, translationY),
                                          child: Container(
                                            height: 3,
                                            decoration: const BoxDecoration(
                                              color: DeepOceanTheme.primary,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: DeepOceanTheme.primary,
                                                  blurRadius: 10,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                // LIVE Indicator badge
                                if (_selfieFile != null)
                                  Positioned(
                                    top: 24,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: GlassContainer(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        borderRadius: BorderRadius.circular(12),
                                        backgroundColor: DeepOceanTheme.surfaceContainerLow.withOpacity(0.8),
                                        borderColor: DeepOceanTheme.primary.withOpacity(0.2),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AnimatedBuilder(
                                              animation: _pulseController,
                                              builder: (context, child) {
                                                return Opacity(
                                                  opacity: _pulseController.value,
                                                  child: Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: DeepOceanTheme.error,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'SELFIE CAPTURED',
                                              style: GoogleFonts.inter(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: DeepOceanTheme.onSurface,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        // Corner brackets
                        const Positioned(
                          top: 10, left: 10,
                          child: _CornerBracket(isTop: true, isLeft: true),
                        ),
                        const Positioned(
                          top: 10, right: 10,
                          child: _CornerBracket(isTop: true, isLeft: false),
                        ),
                        const Positioned(
                          bottom: 10, left: 10,
                          child: _CornerBracket(isTop: false, isLeft: true),
                        ),
                        const Positioned(
                          bottom: 10, right: 10,
                          child: _CornerBracket(isTop: false, isLeft: false),
                        ),
                        
                        // Retake Selfie Button Overlay
                        if (_selfieFile != null && !_isSubmitting)
                          Positioned(
                            bottom: 15,
                            right: 15,
                            child: GestureDetector(
                              onTap: _clearSelfie,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF131722),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: const Icon(Icons.undo, color: DeepOceanTheme.primary, size: 18),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Initialize Check-In Button
                  ElevatedButton(
                    onPressed: buttonAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonAction == null ? DeepOceanTheme.surfaceContainerHighest : DeepOceanTheme.primary,
                      foregroundColor: buttonAction == null ? DeepOceanTheme.onSurfaceVariant : DeepOceanTheme.onPrimary,
                      shadowColor: buttonAction == null ? Colors.transparent : DeepOceanTheme.primary.withOpacity(0.3),
                      elevation: buttonAction == null ? 0 : 10,
                      minimumSize: const Size(double.infinity, 64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting 
                      ? const SizedBox(
                          height: 24, 
                          width: 24, 
                          child: CircularProgressIndicator(color: DeepOceanTheme.onPrimary, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(buttonIcon, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              buttonText,
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                  ),

                  const SizedBox(height: 32),

                  // Status Dashboard (Time & Sector)
                  Row(
                    children: [
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Time',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: DeepOceanTheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _timeString,
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: DeepOceanTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'UTC SYNCHRONIZED',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: DeepOceanTheme.outlineVariant,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: DeepOceanTheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Sector 09A',
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: DeepOceanTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'DEEP SUBMERGENCE',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: DeepOceanTheme.outlineVariant,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Biometric Analysis Panel
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selfie Attendance Logs',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: DeepOceanTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Divider(color: DeepOceanTheme.primary.withOpacity(0.1)),
                        const SizedBox(height: 12),
                        
                        // Check In Status Row
                        _buildStatusRow(
                          'Check-In Selfie:',
                          hasCheckedIn ? 'Recorded' : 'Awaiting Capture',
                          hasCheckedIn ? DeepOceanTheme.primary : DeepOceanTheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                        const SizedBox(height: 10),
                        
                        // Check Out Status Row
                        _buildStatusRow(
                          'Check-Out Selfie:',
                          hasCheckedOut ? 'Recorded' : (hasCheckedIn ? 'Pending Check-Out' : 'Awaiting Check-In'),
                          hasCheckedOut ? DeepOceanTheme.primary : DeepOceanTheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Encryption Info Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DeepOceanTheme.surfaceContainerLow.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: DeepOceanTheme.outlineVariant.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline, color: DeepOceanTheme.primary.withOpacity(0.6), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'END-TO-END SECURE',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: DeepOceanTheme.onSurface,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Session secure. All biometric data is hashed and uploaded using SSL. HRMS does not store raw visual signatures without secure AWS S3 cloud storage controls.',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: DeepOceanTheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: DeepOceanTheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderCamera() {
    return Container(
      color: DeepOceanTheme.surfaceContainerLowest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 50,
              color: DeepOceanTheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'Awaiting Selfie Capture',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: DeepOceanTheme.onSurfaceVariant.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _CornerBracket({
    required this.isTop,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    const size = 32.0;
    const thickness = 2.0;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: 0,
            right: 0,
            child: Container(
              height: thickness,
              color: DeepOceanTheme.primary.withOpacity(0.5),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(
              width: thickness,
              color: DeepOceanTheme.primary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
