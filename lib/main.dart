import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/kanban_page.dart';
import 'pages/login_page.dart';
import 'styles/styles.dart';
import 'services/firebase_auth_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  runApp(const DemoApp());
}

class DemoApp extends StatefulWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  // firstLaunch flag: when true, registration page will open on first build
  final ValueNotifier<bool> firstLaunch = ValueNotifier<bool>(true);
  // theme mode notifier: system, light, dark
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
  final authService = FirebaseAuthService();
  // Сохраняем индекс выбранной вкладки, чтобы он не сбрасывался при смене темы
  final ValueNotifier<int> selectedTabIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final savedMode = await ThemeService.getThemeMode();
    if (savedMode == 'system') {
      themeMode.value = ThemeMode.system;
    } else if (savedMode == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.light;
    }
  }

  @override
  void dispose() {
    selectedTabIndex.dispose();
    firstLaunch.dispose();
    themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Канбан',
          theme: AppStyles.lightTheme,
          darkTheme: AppStyles.darkTheme,
          themeMode: mode,
          home: StreamBuilder(
            stream: authService.authStateChanges,
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // User logged in
              if (snapshot.hasData && snapshot.data != null) {
                return KanbanPage(
                  key: const ValueKey('kanban_page'),
                  firstLaunch: firstLaunch,
                  themeMode: themeMode,
                  selectedTabIndex: selectedTabIndex,
                );
              }

              // User not logged in
              return LoginPage(
                onLogin: () {
                  // Firebase handles the auth state change automatically
                },
              );
            },
          ),
        );
      },
    );
  }
}
