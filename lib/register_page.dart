import 'package:flutter/material.dart';
import 'styles.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirm = '';
  bool _loading = false;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    if (_password != _confirm) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }
    setState(() => _loading = true);
    Future.delayed(Duration(milliseconds: 600), () {
      setState(() => _loading = false);
      // Use email in debug output so analyzer recognizes the field usage, then return success to caller
      debugPrint('Registered user: $_email');
      Navigator.of(context).pop(true);
    });
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
                    child: Column(
                      children: const [
                        Icon(Icons.person_add, size: 64, color: Colors.white),
                        SizedBox(height: 8),
                        Text('Create account',
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
                          TextFormField(
                            decoration: AppStyles.inputDecoration(
                                hint: 'Email',
                                prefixIcon: Icons.email_outlined),
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (v) => _email = v ?? '',
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Enter email' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: AppStyles.inputDecoration(
                                hint: 'Password',
                                prefixIcon: Icons.lock_outline),
                            obscureText: true,
                            onSaved: (v) => _password = v ?? '',
                            validator: (v) => (v == null || v.length < 4)
                                ? 'Password too short'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: AppStyles.inputDecoration(
                                hint: 'Confirm Password',
                                prefixIcon: Icons.lock_outline),
                            obscureText: true,
                            onSaved: (v) => _confirm = v ?? '',
                            validator: (v) => (v == null || v.length < 4)
                                ? 'Confirm password'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: const Color(0xFFFFA726), // blue register
                                elevation: 4,
                              ),
                              onPressed: _loading ? null : _submit,
                              child: _loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('Register', style: TextStyle(fontSize: 16)),
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
