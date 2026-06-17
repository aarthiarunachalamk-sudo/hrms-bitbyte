import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bitbyte_logo.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    
    // Rotation animation for the loading progress indicator
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1500),
    )..repeat();

    // Start timer to navigate to Onboarding screen
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Background ambient light glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: MediaQuery.of(context).size.width * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.04),
                    blurRadius: 150,
                    spreadRadius: 80,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40), // Spacer

                  // Logo and titles
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Centered Logo
                      const BitByteLogo(
                        size: 110,
                        showText: true,
                        fontSize: 26,
                      ),
                      const SizedBox(height: 24),
                      
                      // HRMS Title
                      Text(
                        'HRMS',
                        style: GoogleFonts.outfit(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 6.0,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Full Title
                      Text(
                        'Human Resources Management System',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Subtitles with small dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSubtitleDotText('Smart HR', theme),
                          _buildSubtitleDotText('Smarter Organization', theme),
                          _buildSubtitleDotText('Smartest Results', theme, isLast: true),
                        ],
                      ),
                    ],
                  ),

                  // Loading area at bottom
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circular Loading indicator
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Inactive track
                            CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 3.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.outline.withOpacity(0.4),
                              ),
                            ),
                            // Active gradient spinner
                            ShaderMask(
                              shaderCallback: (rect) {
                                return SweepGradient(
                                  colors: [
                                    theme.colorScheme.outlineVariant,
                                    theme.colorScheme.primary.withOpacity(0.5),
                                    theme.colorScheme.primary,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ).createShader(rect);
                              },
                              child: RotationTransition(
                                turns: _rotationController,
                                child: CircularProgressIndicator(
                                  value: 0.85,
                                  strokeWidth: 3.5,
                                  strokeCap: StrokeCap.round,
                                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Syncing Data...',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 48), // Bottom safe margin
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitleDotText(String text, ThemeData theme, {bool isLast = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary.withOpacity(0.8),
            letterSpacing: 0.5,
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Icon(
              Icons.circle,
              size: 4,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
      ],
    );
  }
}
