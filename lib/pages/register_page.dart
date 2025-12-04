import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../styles/styles.dart';
import '../services/firebase_auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = FirebaseAuthService();
  String _email = '';
  String _password = '';
  String _confirm = '';
  String _displayName = '';
  bool _loading = false;
  String? _errorMessage;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    if (_password != _confirm) {
      setState(() {
        _errorMessage = 'Пароли не совпадают';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.registerWithEmailAndPassword(
        email: _email,
        password: _password,
        displayName: _displayName,
      );

      if (result != null && mounted) {
        debugPrint('Registered user: $_email');
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Ошибка регистрации. Попробуйте снова.';
          _loading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _authService.getErrorMessage(e);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Неожиданная ошибка: $e';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration:
              const BoxDecoration(gradient: AppStyles.backgroundGradient),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white.withAlpha(31),
                        borderRadius: BorderRadius.circular(16)),
                    child: const Column(
                      children: [
                        Icon(Icons.person_add, size: 64, color: Colors.white),
                        SizedBox(height: 8),
                        Text('Создать аккаунт',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 12)
                        ]),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade300),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          TextFormField(
                            decoration: AppStyles.inputDecoration(
                                hint: 'Полное имя',
                                prefixIcon: Icons.person_outline),
                            onSaved: (v) => _displayName = v ?? '',
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Введите ваше имя'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: AppStyles.inputDecoration(
                                hint: 'Электронная почта',
                                prefixIcon: Icons.email_outlined),
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (v) => _email = v ?? '',
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Введите email' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: AppStyles.inputDecoration(
                                hint: 'Пароль',
                                prefixIcon: Icons.lock_outline),
                            obscureText: true,
                            onSaved: (v) => _password = v ?? '',
                            validator: (v) => (v == null || v.length < 4)
                                ? 'Пароль слишком короткий'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: AppStyles.inputDecoration(
                                hint: 'Подтвердите пароль',
                                prefixIcon: Icons.lock_outline),
                            obscureText: true,
                            onSaved: (v) => _confirm = v ?? '',
                            validator: (v) => (v == null || v.length < 4)
                                ? 'Подтвердите пароль'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                backgroundColor: const Color(0xFFFFA726),
                                foregroundColor: Colors.white,
                                elevation: 4,
                              ),
                              onPressed: _loading ? null : _submit,
                              child: _loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('Зарегистрироваться',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
