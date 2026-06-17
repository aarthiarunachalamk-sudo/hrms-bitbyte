import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/deep_ocean_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/side_menu_drawer.dart';
import 'attendance_dashboard.dart';
import 'bio_sync_check_in.dart';
import 'calculation_logic.dart';
import 'login_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      AttendanceDashboardScreen(
        onMenuPressed: _openDrawer,
        onLogoutPressed: _handleLogout,
      ),
      _PlaceholderScreen(
        title: 'History Protocol',
        subtitle: 'Historical biometric access records and logs.',
        icon: Icons.history,
        onMenuPressed: _openDrawer,
        onLogoutPressed: _handleLogout,
      ),
      BioSyncCheckInScreen(
        onMenuPressed: _openDrawer,
        onLogoutPressed: _handleLogout,
      ),
      CalculationLogicScreen(
        onMenuPressed: _openDrawer,
        onLogoutPressed: _handleLogout,
      ),
      _PlaceholderScreen(
        title: 'User Profile',
        subtitle: 'Cryptographic credentials and security settings.',
        icon: Icons.person,
        onMenuPressed: _openDrawer,
        onLogoutPressed: _handleLogout,
      ),
    ]);
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Confirm Logout',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to terminate your current HRMS session?',
            style: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // pop dialog
                // Navigate back to login screen and clear history
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
                // Show a brief success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF00FF87),
                    content: Text(
                      'Session terminated. Logged out successfully.',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF0D0D16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              child: Text(
                'Logout',
                style: GoogleFonts.inter(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SideMenuDrawer(
        currentIndex: _currentIndex,
        onTabSelected: _onTabTapped,
        onLogoutPressed: _handleLogout,
      ),
      extendBody: true, // Allow body to expand behind bottom navigation bar
      body: _screens[_currentIndex],
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 80,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_outlined, 'Home'),
                _buildNavItem(1, Icons.history_outlined, 'History'),
                _buildNavItem(2, Icons.location_on_outlined, 'Check-In'),
                _buildNavItem(3, Icons.assessment_outlined, 'Reports'),
                _buildNavItem(4, Icons.person_outline, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onLogoutPressed;

  const _PlaceholderScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onMenuPressed,
    this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Stack(
        children: [
          // Background subtle ambient lights
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.03),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // App Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: onMenuPressed,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Icon(Icons.waves, color: Theme.of(context).colorScheme.primary, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'HRMS',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onLogoutPressed,
                        icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Center(
                    child: GlassContainer(
                      width: 160,
                      height: 160,
                      borderRadius: BorderRadius.circular(80),
                      child: Center(
                        child: Icon(
                          icon,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
