import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Smart Workforce\nManagement',
      'description': 'Manage your entire workforce from a single dashboard. Track attendance, leaves, and performance in real time.',
      'centerIcon': Icons.people_outline_rounded,
      'badges': [
        {'icon': Icons.calendar_month_outlined, 'alignment': const Alignment(0.7, -0.7)},
        {'icon': Icons.trending_up_rounded, 'alignment': const Alignment(-0.7, 0.7)},
      ],
      'isLast': false,
    },
    {
      'title': 'GEO Tracking\nAttendance',
      'description': 'Clock in and out using GPS location tracking. Secure, accurate, and location-based attendance verification for the modern fleet.',
      'centerIcon': Icons.location_on_outlined,
      'badges': [
        {'icon': Icons.gps_fixed_rounded, 'alignment': const Alignment(0.7, -0.7)},
        {'icon': Icons.map_outlined, 'alignment': const Alignment(-0.7, 0.7)},
      ],
      'isLast': false,
    },
    {
      'title': 'Payroll & Insights',
      'description': 'Process payroll with one tap and gain deep analytics on team productivity, leave trends, and HR metrics.',
      'centerIcon': Icons.bar_chart_rounded,
      'badges': [
        {'icon': Icons.auto_graph_rounded, 'alignment': const Alignment(0.6, -0.6)},
        {'icon': Icons.show_chart_rounded, 'alignment': const Alignment(-0.6, 0.6)},
      ],
      'isLast': true,
    },
  ];

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Background ambient lights
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withOpacity(0.02),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header (Logo & Skip)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Small Icon (Menu representation or Waves)
                      Icon(
                        Icons.waves,
                        color: theme.colorScheme.primary,
                        size: 30,
                      ),
                      
                      // Skip Button
                      GestureDetector(
                        onTap: _navigateToLogin,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Skip',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sliding Page Content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return _buildPageContent(page, theme, isDark);
                    },
                  ),
                ),

                // Footer section with Indicator and Action Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 48.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (index) {
                          final isSelected = _currentPage == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            height: 6.0,
                            width: isSelected ? 32.0 : 6.0,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 40),

                      // Gradient CTA Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _onNextPressed,
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: _currentPage == _pages.length - 1
                                          ? [
                                              theme.colorScheme.secondary,
                                              theme.colorScheme.primary,
                                            ]
                                          : [
                                              theme.colorScheme.primary,
                                              theme.colorScheme.secondary,
                                            ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _currentPage == _pages.length - 1
                                              ? 'Get Started'
                                              : 'Next',
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          _currentPage == _pages.length - 1
                                              ? Icons.rocket_launch_outlined
                                              : Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 20,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(Map<String, dynamic> page, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Glowing Illustration Structure
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner Ambient Glow Ring
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.08),
                        blurRadius: 40,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),

                // Main Circle Border & Translucent Fill
                Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark 
                        ? theme.colorScheme.surface.withOpacity(0.4) 
                        : theme.colorScheme.surface,
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Icon(
                      page['centerIcon'] as IconData,
                      size: 68,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),

                // Floating Badges
                ... (page['badges'] as List<dynamic>).map((badge) {
                  final alignment = badge['alignment'] as Alignment;
                  final icon = badge['icon'] as IconData;

                  return Align(
                    alignment: alignment,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline,
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            page['title'] as String,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.25,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Description Paragraph
          Text(
            page['description'] as String,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.6,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
