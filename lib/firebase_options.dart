import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// ⚠️ ВАЖНО: Заполните эти значения из Firebase Console
/// https://console.firebase.google.com
/// 
/// Получите конфигурацию для каждой платформы:
/// - Web: Project Settings → Your apps → Web
/// - Android: Project Settings → Your apps → Android
/// - iOS: Project Settings → Your apps → iOS
/// - macOS: Project Settings → Your apps → macOS
/// - Windows/Linux: Project Settings → Your apps → Windows/Linux
///
/// Затем запустите: flutterfire configure
/// или заполните значения вручную ниже

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (Platform.isAndroid) {
      return android;
    }
    if (Platform.isIOS) {
      return ios;
    }
    if (Platform.isMacOS) {
      return macos;
    }
    if (Platform.isWindows) {
      return windows;
    }
    if (Platform.isLinux) {
      return linux;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA28Jqva1NQRq451JxsLFZjr7XW7Vn6HVI',
    appId: '1:398893570864:web:186cc1f98d9bb627eec6f5',
    messagingSenderId: '398893570864',
    projectId: 'kanban-flutter-93fff',
    authDomain: 'kanban-flutter-93fff.firebaseapp.com',
    storageBucket: 'kanban-flutter-93fff.firebasestorage.app',
    measurementId: 'G-N43KGCJRH8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCkowIaOAqbcyX5aMUC5gHDViWUUo-waSI',
    appId: '1:398893570864:android:e57d83d71cc54b7feec6f5',
    messagingSenderId: '398893570864',
    projectId: 'kanban-flutter-93fff',
    storageBucket: 'kanban-flutter-93fff.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDYIjQY7NiDYx_s07ZCWTqnPfeelTq7oFA',
    appId: '1:398893570864:ios:798bcde05afe47fbeec6f5',
    messagingSenderId: '398893570864',
    projectId: 'kanban-flutter-93fff',
    storageBucket: 'kanban-flutter-93fff.firebasestorage.app',
    iosBundleId: 'kanbanflutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDYIjQY7NiDYx_s07ZCWTqnPfeelTq7oFA',
    appId: '1:398893570864:ios:798bcde05afe47fbeec6f5',
    messagingSenderId: '398893570864',
    projectId: 'kanban-flutter-93fff',
    storageBucket: 'kanban-flutter-93fff.firebasestorage.app',
    iosBundleId: 'kanbanflutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA28Jqva1NQRq451JxsLFZjr7XW7Vn6HVI',
    appId: '1:398893570864:web:fd83c4e72f799ad3eec6f5',
    messagingSenderId: '398893570864',
    projectId: 'kanban-flutter-93fff',
    authDomain: 'kanban-flutter-93fff.firebaseapp.com',
    storageBucket: 'kanban-flutter-93fff.firebasestorage.app',
    measurementId: 'G-YR65H98LG8',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'YOUR_LINUX_API_KEY',
    appId: 'YOUR_LINUX_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
  );
}