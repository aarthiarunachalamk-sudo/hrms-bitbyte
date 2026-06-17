import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/deep_ocean_theme.dart';
import '../widgets/glass_container.dart';
import '../models/attendance_record.dart';
import '../models/activity_log.dart';
import '../services/attendance_service.dart';
import '../services/session_manager.dart';
import '../services/api_client.dart';

class AttendanceDashboardScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onLogoutPressed;

  const AttendanceDashboardScreen({
    super.key,
    this.onMenuPressed,
    this.onLogoutPressed,
  });

  @override
  State<AttendanceDashboardScreen> createState() => _AttendanceDashboardScreenState();
}

class _AttendanceDashboardScreenState extends State<AttendanceDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pingController;

  AttendanceRecord? _todayRecord;
  List<ActivityLog> _activityLogs = [];
  bool _loading = true;
  String? _error;

  int get _employeeId => SessionManager.currentUser?.id ?? 1;

  @override
  void initState() {
    super.initState();
    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _loadData();
  }

  @override
  void dispose() {
    _pingController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        AttendanceService.getToday(_employeeId),
        AttendanceService.getActivityLogs(_employeeId, limit: 5),
      ]);
      if (mounted) {
        setState(() {
          _todayRecord  = results[0] as AttendanceRecord?;
          _activityLogs = results[1] as List<ActivityLog>;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Could not load data.'; _loading = false; });
    }
  }

  Widget _buildSelfieThumbnail(BuildContext context, String selfiePath, String label) {
    if (selfiePath.isEmpty) return const SizedBox.shrink();
    final url = selfiePath.startsWith('http') ? selfiePath : '${ApiClient.baseUrl}$selfiePath';
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: Container(
        margin: const EdgeInsets.only(top: 8, right: 8),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.primary.withOpacity(0.5), width: 1.5),
        ),
        child: ClipOval(
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(Icons.person, size: 18, color: colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  String _getCurrentFormattedDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, $monthName ${now.day} ${now.year}';
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m ${dt.hour < 12 ? "AM" : "PM"}';
  }

  IconData _iconForEvent(String eventType) {
    switch (eventType) {
      case 'check_in':       return Icons.login;
      case 'check_out':      return Icons.logout;
      case 'break_start':    return Icons.coffee;
      case 'break_end':      return Icons.coffee_maker;
      case 'session_resume': return Icons.play_arrow;
      default:               return Icons.circle;
    }
  }

  Color _colorForEvent(BuildContext context, String eventType) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (eventType) {
      case 'check_in':
      case 'session_resume': return colorScheme.primary;
      case 'check_out':      return colorScheme.error;
      case 'break_start':
      case 'break_end':      return colorScheme.secondary;
      default:               return colorScheme.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final surfaceContainer = isDark ? const Color(0xFF1F1F28) : const Color(0xFFFFFFFF);
    final surfaceContainerLow = isDark ? const Color(0xFF1F1F28) : const Color(0xFFF8FAFC);
    final surfaceContainerHighest = isDark ? const Color(0xFF454559) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Background ambient light
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.04),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: colorScheme.primary,
              backgroundColor: surfaceContainer,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── App bar row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: widget.onMenuPressed,
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              Icon(Icons.waves, color: colorScheme.primary, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'HRMS',
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onLogoutPressed,
                          icon: Icon(Icons.logout, color: colorScheme.error),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Overview header & status badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attendance Overview',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(_getCurrentFormattedDate(),
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                        _StatusBadge(
                          pingController: _pingController,
                          record: _todayRecord,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Error banner
                    if (_error != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.wifi_off, color: colorScheme.error, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _error!,
                                style: GoogleFonts.inter(
                                    fontSize: 13, color: colorScheme.onErrorContainer),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadData,
                              child: Text('Retry',
                                  style: GoogleFonts.inter(color: colorScheme.primary)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Working hours card
                    Row(
                      children: [
                        Expanded(
                          child: GlassContainer(
                            padding: const EdgeInsets.all(20),
                            child: _loading
                                ? Center(
                                    child: SizedBox(
                                      height: 72,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colorScheme.primary),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.schedule,
                                                  size: 16,
                                                  color: colorScheme.onSurfaceVariant),
                                              const SizedBox(width: 6),
                                              Text('Working Hours',
                                                  style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: colorScheme.onSurfaceVariant)),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            _todayRecord?.workingHoursDisplay ?? '00:00',
                                            style: GoogleFonts.inter(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w800,
                                              color: colorScheme.primary,
                                              letterSpacing: -1,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _todayRecord?.isCheckedIn == true
                                                ? 'Check-in: ${_formatTime(_todayRecord!.checkInTime)}'
                                                : 'Not checked in yet',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: colorScheme.secondary,
                                            ),
                                          ),
                                          if (_todayRecord?.isCheckedIn == true) ...[
                                            Row(
                                              children: [
                                                if (_todayRecord?.checkInSelfieUrl != null)
                                                  _buildSelfieThumbnail(context, _todayRecord!.checkInSelfieUrl!, 'Check-In Selfie'),
                                                if (_todayRecord?.checkOutSelfieUrl != null)
                                                  _buildSelfieThumbnail(context, _todayRecord!.checkOutSelfieUrl!, 'Check-Out Selfie'),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                      // mini progress ring  (working / 510 min = 8h30m)
                                      SizedBox(
                                        width: 72,
                                        height: 72,
                                        child: CustomPaint(
                                          painter: MiniProgressPainter(
                                            progress: _todayRecord?.workingMinutes != null
                                                ? (_todayRecord!.workingMinutes! / 510).clamp(0.0, 1.0)
                                                : 0.0,
                                            color: colorScheme.primary,
                                            backgroundColor: surfaceContainerHighest,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Overtime & Late cards
                    Row(
                      children: [
                        Expanded(
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.more_time, color: colorScheme.secondary),
                                const SizedBox(height: 12),
                                Text('Overtime',
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                Text(
                                  _loading ? '--:--' : (_todayRecord?.overtimeDisplay ?? '00:00'),
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: colorScheme.secondary,
                                      fontWeight: FontWeight.bold),
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
                                Icon(Icons.running_with_errors, color: colorScheme.error),
                                const SizedBox(height: 12),
                                Text('Late Entry',
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                Text(
                                  _loading ? '--:--' : (_todayRecord?.lateDisplay ?? '00:00'),
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Location card
                    GlassContainer(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Container(
                                  height: 160,
                                  width: double.infinity,
                                  color: surfaceContainerLow,
                                  child: Image.network(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAg5UIeUqh_Slop3USMbqztUxJGiWQeYl2RNlhBlV76W01zo4FG6gThqUSaqebBy42q1OJmuouWvwsQ-_8YNMVoLj7vECGYSGI1KnJa4t9diCG5Gd5o7LtgM9L3CUlHhsNZCSDBeEOxJ1rDuM34XXHAjjApzMJVWSG9GHhwhkSE9TBTJVEOOCdNO-hctc9fWYgnHPuN_-3zMwq5jaSbLl14ssrztxTauK6Pe21vIrwWP0ZK2drLeauw3hlDgLtEAV8FIGJ2s511pw8',
                                    fit: BoxFit.cover,
                                    loadingBuilder: (_, child, progress) =>
                                        progress == null ? child : const SizedBox.shrink(),
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Icon(Icons.map_outlined,
                                          size: 48,
                                          color: colorScheme.primary.withOpacity(0.3)),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        surfaceContainer.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Center(
                                  child: AnimatedBuilder(
                                    animation: _pingController,
                                    builder: (_, __) => Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 48 * _pingController.value + 16,
                                          height: 48 * _pingController.value + 16,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: colorScheme.primary.withOpacity(
                                              (1.0 - _pingController.value).clamp(0.0, 0.4),
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.location_on, color: colorScheme.primary, size: 32),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Authenticated Zone',
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: colorScheme.onSurfaceVariant)),
                                    const SizedBox(height: 2),
                                    Text(
                                      _todayRecord?.zone ?? 'Tech Hub South',
                                      style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.primary),
                                    ),
                                  ],
                                ),
                                Icon(Icons.verified_user, color: colorScheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Activity stream
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'ACTIVITY STREAM',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: _loading
                          ? Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: colorScheme.primary),
                              ),
                            )
                          : _activityLogs.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Center(
                                    child: Text(
                                      'No activity yet today',
                                      style: GoogleFonts.inter(
                                          color: colorScheme.onSurfaceVariant),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: _activityLogs.asMap().entries.map((entry) {
                                    final log = entry.value;
                                    final isLast = entry.key == _activityLogs.length - 1;
                                    String? selfieUrl;
                                    if (log.eventType == 'check_in') {
                                      selfieUrl = _todayRecord?.checkInSelfieUrl;
                                    } else if (log.eventType == 'check_out') {
                                      selfieUrl = _todayRecord?.checkOutSelfieUrl;
                                    }
                                    return _buildActivityItem(
                                      context: context,
                                      icon: _iconForEvent(log.eventType),
                                      color: _colorForEvent(context, log.eventType),
                                      title: log.displayLabel,
                                      subtitle: log.zone ?? log.authMethod,
                                      time: _formatTime(log.eventTime),
                                      selfieUrl: selfieUrl,
                                      isLast: isLast,
                                    );
                                  }).toList(),
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
    String? selfieUrl,
    bool isLast = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: colorScheme.primary.withOpacity(0.05),
                  width: 1.0,
                ),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: selfieUrl != null && selfieUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      selfieUrl.startsWith('http') ? selfieUrl : '${ApiClient.baseUrl}$selfieUrl',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(icon, color: color, size: 20),
                    ),
                  )
                : Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Text(time,
              style: GoogleFonts.inter(
                  fontSize: 13, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ── Status badge widget
class _StatusBadge extends StatelessWidget {
  final AnimationController pingController;
  final AttendanceRecord? record;

  const _StatusBadge({required this.pingController, this.record});

  @override
  Widget build(BuildContext context) {
    final isPresent = record?.status == 'present';
    final label = isPresent ? 'Present' : 'Absent';
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: pingController,
            builder: (_, __) => Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(
                  (1.0 - pingController.value).clamp(0.2, 1.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary,
                    blurRadius: 4 * pingController.value + 2,
                    spreadRadius: 2 * pingController.value,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}

// ── Mini arc progress painter (unchanged)
class MiniProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  const MiniProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 4;
    const strokeWidth = 5.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(covariant MiniProgressPainter old) =>
      old.progress != progress || old.color != color || old.backgroundColor != backgroundColor;
}
