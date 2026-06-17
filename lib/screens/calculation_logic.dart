import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/deep_ocean_theme.dart';
import '../widgets/glass_container.dart';

class CalculationLogicScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onLogoutPressed;

  const CalculationLogicScreen({
    super.key,
    this.onMenuPressed,
    this.onLogoutPressed,
  });

  @override
  State<CalculationLogicScreen> createState() => _CalculationLogicScreenState();
}

class _CalculationLogicScreenState extends State<CalculationLogicScreen> with SingleTickerProviderStateMixin {
  late AnimationController _sonarController;

  @override
  void initState() {
    super.initState();
    _sonarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _sonarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final surfaceContainerHigh = isDark ? const Color(0xFF1F1F28) : const Color(0xFFF1F5F9);
    final surfaceContainerLow = isDark ? const Color(0xFF1F1F28) : const Color(0xFFF8FAFC);
    final surfaceContainerHighest = isDark ? const Color(0xFF454559) : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
      ),
      child: Stack(
        children: [
          // Background ambient lights
          Positioned(
            top: 200,
            right: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.secondary.withOpacity(0.03),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 90),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: surfaceContainerHigh,
                          content: Text(
                            'Accessing Engine Console API Logs... Connecting secure shell.',
                            style: GoogleFonts.inter(color: colorScheme.primary),
                          ),
                        ),
                      );
                    },
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.terminal),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top App Bar
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
                        Row(
                          children: [
                            IconButton(
                              onPressed: widget.onLogoutPressed,
                              icon: Icon(Icons.logout, color: colorScheme.error),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Shift Sonar Section
                    GlassContainer(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                      child: Column(
                        children: [
                          // Sonar animated circles
                          SizedBox(
                            height: 150,
                            width: 150,
                            child: AnimatedBuilder(
                              animation: _sonarController,
                              builder: (context, child) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    _buildSonarRing(0.0, colorScheme.primary),
                                    _buildSonarRing(0.33, colorScheme.primary),
                                    _buildSonarRing(0.66, colorScheme.primary),
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colorScheme.primary,
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorScheme.primary.withOpacity(0.4),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.hub,
                                        color: colorScheme.onPrimary,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Shift Sonar',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Real-time visualization of node stability and calculation logic integrity across active protocols.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Stability: 99.8%',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.sync, 
                                      size: 14, 
                                      color: colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Last Sync: 42ms ago',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bento Grid: Rule Cards
                    _buildRuleCard(
                      context: context,
                      icon: Icons.play_circle_outline,
                      iconColor: colorScheme.primary,
                      iconBg: colorScheme.primaryContainer.withOpacity(0.6),
                      tagText: 'ACTIVE',
                      tagColor: colorScheme.secondaryContainer.withOpacity(0.8),
                      tagTextColor: colorScheme.onSecondaryContainer,
                      title: 'Shift Initialization',
                      subtitle: 'Defines the primary triggers for clock-in protocols and credential validation logic.',
                      rows: [
                        _RuleRow(label: 'Late Entry Threshold', value: 'After 9:00 AM', valueColor: colorScheme.primary),
                        _RuleRow(label: 'Grace Period', value: '15 Minutes', valueColor: colorScheme.secondary),
                        _RuleRow(label: 'Auth Protocol', value: 'Biometric/NFC', valueColor: colorScheme.tertiary),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildRuleCard(
                      context: context,
                      icon: Icons.timer_outlined,
                      iconColor: colorScheme.tertiary,
                      iconBg: colorScheme.tertiaryContainer.withOpacity(0.6),
                      tagText: 'MANDATORY',
                      tagColor: surfaceContainerHighest,
                      tagTextColor: colorScheme.onSurfaceVariant,
                      title: 'Break Enforcement',
                      subtitle: 'Automated deduction and timing logic for rest periods as per regional labor compliance.',
                      rows: [
                        _RuleRow(label: 'Fixed Deduction', value: '45 Minutes', valueColor: colorScheme.primary),
                        _RuleRow(label: 'Trigger Point', value: '5.0 Hours Work', valueColor: colorScheme.secondary),
                        _RuleRow(label: 'Flexibility Node', value: '±10 Minutes', valueColor: colorScheme.tertiary),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildRuleCard(
                      context: context,
                      icon: Icons.speed_outlined,
                      iconColor: colorScheme.secondary,
                      iconBg: colorScheme.primaryContainer.withOpacity(0.3),
                      tagText: 'SENSITIVE',
                      tagColor: colorScheme.errorContainer.withOpacity(0.6),
                      tagTextColor: colorScheme.onErrorContainer,
                      title: 'Overtime Threshold',
                      subtitle: 'Calculates multi-tier multipliers based on cumulative weekly and daily duration logs.',
                      rows: [
                        _RuleRow(label: 'Expected Duration', value: '8:30 Hours', valueColor: colorScheme.primary),
                        _RuleRow(label: 'Daily Cap (1.5x)', value: '10:00 Hours', valueColor: colorScheme.secondary),
                        _RuleRow(label: 'Critical Alert', value: '12:00+ Hours', valueColor: colorScheme.error),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Technical Reference Section
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 160,
                              width: double.infinity,
                              color: surfaceContainerLow,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAGDEspFpB8XlySCba-le0Pj6dLd_pu-iQXpTQyQ3fYsIaJ9YgudBzE0nfyc7Dot8x5qCOPzzvW54GxPHra45XlVGfTXzvRfvFRUbll8085sGZinhRXMyRrkZKbmLUmXvP5eV5YCJAClg_nFwaIfwDovM0uxYB3L3ADSdmnU2BX8FxxZadkOPc4v8Co1RV0M-ReO45PQjdBGwtnNvWKP5NoqTbXdgpbw8oEqGsLfwO1i4n26XbuhrTjcrafZYXEA3PmlRiUihGRrGw',
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                            Icons.account_tree_outlined,
                                            size: 48,
                                            color: colorScheme.primary.withOpacity(0.3),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    color: Colors.black.withOpacity(0.4),
                                  ),
                                  Center(
                                    child: Icon(
                                      Icons.account_tree,
                                      color: colorScheme.primary.withOpacity(0.8),
                                      size: 48,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(Icons.verified, color: colorScheme.secondary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Architectural Source of Truth',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "This interface visualizes the 'Calculation Logic' and 'Working Hours Rules' derived directly from the Master Protocol Diagram v4.2. All nodes shown above are dynamically synced with the core engine, ensuring that any deviation in shift initialization or overtime thresholds is flagged instantly via the Shift Sonar.",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.description_outlined),
                            label: const Text('View Full Spec Diagram'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.settings_ethernet),
                            label: const Text('Engine API Logs'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.secondary,
                              side: BorderSide(color: colorScheme.secondary),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                          ),
                        ],
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

  Widget _buildSonarRing(double delayFraction, Color primaryColor) {
    final double rawVal = _sonarController.value + delayFraction;
    final double animVal = rawVal >= 1.0 ? rawVal - 1.0 : rawVal;
    
    final double radius = 64 + (150 - 64) * animVal;
    final double opacity = (1.0 - animVal).clamp(0.0, 0.6);

    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: primaryColor.withOpacity(opacity),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String tagText,
    required Color tagColor,
    required Color tagTextColor,
    required String title,
    required String subtitle,
    required List<_RuleRow> rows,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tagText,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: tagTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: rows.map((row) {
              final isLast = rows.last == row;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: isLast 
                      ? null 
                      : Border(
                          bottom: BorderSide(
                            color: colorScheme.outlineVariant.withOpacity(0.2),
                            width: 1.0,
                          ),
                        ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row.label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      row.value,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: row.valueColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RuleRow {
  final String label;
  final String value;
  final Color valueColor;

  _RuleRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });
}
