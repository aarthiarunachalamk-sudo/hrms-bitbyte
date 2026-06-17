import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart'; // To import themeNotifier
import '../widgets/bitbyte_logo.dart';
import '../screens/change_password_screen.dart';
import '../services/session_manager.dart';

class SideMenuDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onLogoutPressed;

  const SideMenuDrawer({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final user = SessionManager.currentUser;
    final fullName = user?.fullName ?? 'John Doe';
    final email = user?.email ?? 'employee@bitbyte.tech';
    final designation = user?.designation ?? 'Employee Node';

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      elevation: 16,
      child: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    width: 1.0,
                  ),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const BitByteLogo(size: 40, showText: false),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF00FF87),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'MESH ACTIVE',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.5),
                            width: 1.5,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primaryContainer,
                              isDark ? const Color(0xFF131722) : Colors.white,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Navigation Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildDrawerItem(
                    index: 0,
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    label: 'Attendance Dashboard',
                    context: context,
                  ),
                  _buildDrawerItem(
                    index: 2,
                    icon: Icons.location_on_outlined,
                    activeIcon: Icons.location_on,
                    label: 'Biometric Check-In',
                    context: context,
                  ),
                  _buildDrawerItem(
                    index: 3,
                    icon: Icons.assessment_outlined,
                    activeIcon: Icons.assessment,
                    label: 'Calculation Rules',
                    context: context,
                  ),
                  _buildDrawerItem(
                    index: 1,
                    icon: Icons.history_outlined,
                    activeIcon: Icons.history,
                    label: 'History Protocol',
                    context: context,
                  ),
                  _buildDrawerItem(
                    index: 4,
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'User Profile',
                    context: context,
                  ),
                  
                  Divider(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    height: 24,
                  ),

                  // Change Password
                  ListTile(
                    leading: Icon(
                      Icons.lock_outline_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      'Change Password',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      Navigator.pop(context); // close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangePasswordScreen(
                            email: SessionManager.currentUser?.email ?? '',
                            tempPassword: '',
                          ),
                        ),
                      );
                    },
                  ),

                  // Dynamic Theme Mode Switcher
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, themeMode, _) {
                      final isCurrentlyDark = themeMode == ThemeMode.dark;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                isCurrentlyDark
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                key: ValueKey(isCurrentlyDark),
                                color: isCurrentlyDark
                                    ? theme.colorScheme.primary
                                    : const Color(0xFFF59E0B),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isCurrentlyDark ? 'Dark Mode' : 'Light Mode',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    isCurrentlyDark ? 'Tap to switch light' : 'Tap to switch dark',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isCurrentlyDark,
                              onChanged: (val) {
                                themeNotifier.value =
                                    val ? ThemeMode.dark : ThemeMode.light;
                              },
                              activeColor: theme.colorScheme.primary,
                              activeTrackColor: theme.colorScheme.primary.withOpacity(0.3),
                              inactiveThumbColor: const Color(0xFFF59E0B),
                              inactiveTrackColor: const Color(0xFFF59E0B).withOpacity(0.25),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Footer / Logout Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    width: 1.0,
                  ),
                ),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.logout_rounded,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'TERMINATE SESSION',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                    letterSpacing: 0.5,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.error.withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
                tileColor: theme.colorScheme.error.withOpacity(0.05),
                onTap: () {
                  Navigator.of(context).pop(); // Close drawer first
                  onLogoutPressed();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final isSelected = currentIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        selected: isSelected,
        selectedTileColor: theme.colorScheme.primary.withOpacity(0.08),
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: theme.colorScheme.primary.withOpacity(0.2), width: 1)
              : BorderSide.none,
        ),
        onTap: () {
          Navigator.of(context).pop(); // Close drawer
          onTabSelected(index);
        },
      ),
    );
  }
}
