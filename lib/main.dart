import 'package:flutter/material.dart';
import 'pages/kanban_page.dart';
import 'login_page.dart';
import 'styles.dart';

void main() => runApp(DemoApp());

class DemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simple auth state notifier shared with KanbanPage
    final ValueNotifier<bool> auth = ValueNotifier<bool>(false);
    // firstLaunch flag: when true, registration page will open on first build
    final ValueNotifier<bool> firstLaunch = ValueNotifier<bool>(true);
    // theme notifier: false = light, true = dark
    final ValueNotifier<bool> darkMode = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: darkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Demo Flutter App',
          theme: AppStyles.lightTheme,
          darkTheme: AppStyles.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: ValueListenableBuilder<bool>(
            valueListenable: auth,
            builder: (context, loggedIn, _) {
              if (!loggedIn) {
                return LoginPage(onLogin: () => auth.value = true);
              }
              return KanbanPage(
                  auth: auth, firstLaunch: firstLaunch, isDark: darkMode);
            },
          ),
        );
      },
    );
  }
}
