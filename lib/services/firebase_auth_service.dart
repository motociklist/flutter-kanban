import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  late FirebaseAuth _auth;

  factory FirebaseAuthService() {
    return _instance;
  }

  FirebaseAuthService._internal() {
    _auth = FirebaseAuth.instance;
  }

  // Текущий пользователь
  User? get currentUser => _auth.currentUser;

  // Поток аутентификации (для слежения за изменениями)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Регистрация по email и паролю
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Создание пользователя
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Обновление имени пользователя
      await userCredential.user?.updateDisplayName(displayName);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return null;
    } catch (e) {
      throw Exception('Ошибка регистрации: $e');
    }
  }

  // Вход по email и паролю
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return null;
    } catch (e) {
      throw Exception('Ошибка входа: $e');
    }
  }

  // Выход из аккаунта
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Ошибка выхода: $e');
    }
  }

  // Проверка подтверждения email
  Future<void> sendEmailVerification() async {
    try {
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        await _auth.currentUser!.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Ошибка отправки верификации: $e');
    }
  }

  // Обработка ошибок Firebase
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Пароль слишком слабый.';
      case 'email-already-in-use':
        return 'Email уже зарегистрирован.';
      case 'invalid-email':
        return 'Email некорректен.';
      case 'user-not-found':
        return 'Пользователь не найден.';
      case 'wrong-password':
        return 'Неверный пароль.';
      case 'user-disabled':
        return 'Пользователь отключен.';
      case 'operation-not-allowed':
        return 'Операция не разрешена.';
      default:
        return 'Ошибка: ${e.message}';
    }
  }

  // Метод для получения описания ошибки
  String getErrorMessage(FirebaseAuthException e) {
    return _handleAuthException(e);
  }
}
