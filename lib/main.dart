import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/kanban_page.dart';
import 'login_page.dart';
import 'styles.dart';
import 'services/firebase_auth_service.dart';

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

class DemoApp extends StatelessWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // firstLaunch flag: when true, registration page will open on first build
    final ValueNotifier<bool> firstLaunch = ValueNotifier<bool>(true);
    // theme notifier: false = light, true = dark
    final ValueNotifier<bool> darkMode = ValueNotifier<bool>(false);
    final _authService = FirebaseAuthService();

    return ValueListenableBuilder<bool>(
      valueListenable: darkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Demo Flutter App',
          theme: AppStyles.lightTheme,
          darkTheme: AppStyles.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: StreamBuilder(
            stream: _authService.authStateChanges,
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
                  firstLaunch: firstLaunch,
                  isDark: darkMode,
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
