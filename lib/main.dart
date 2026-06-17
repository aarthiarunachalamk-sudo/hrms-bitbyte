import 'package:flutter/material.dart';
import 'theme/deep_ocean_theme.dart';
import 'screens/splash_screen.dart';

// Global ValueNotifier — dark theme is the default.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'DeepOcean HRMS',
          debugShowCheckedModeBanner: false,
          theme: DeepOceanTheme.lightTheme,
          darkTheme: DeepOceanTheme.darkTheme,
          themeMode: currentMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
