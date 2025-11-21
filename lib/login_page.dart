import 'package:flutter/material.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLogin;
  const LoginPage({Key? key, required this.onLogin}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    // Simulate a short auth delay.
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _loading = false);
      debugPrint('Login with $_email / $_password');
      widget.onLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF7E57C2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo / header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white.withAlpha(31), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: const [
                        Icon(Icons.dashboard_customize, size: 64, color: Colors.white),
                        SizedBox(height: 8),
                        Text('Welcome to Kanban+', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Card container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)]),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: border,
                              enabledBorder: border,
                              focusedBorder: border,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (v) => _email = v ?? '',
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter email' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: border,
                              enabledBorder: border,
                              focusedBorder: border,
                            ),
                            obscureText: true,
                            onSaved: (v) => _password = v ?? '',
                            validator: (v) => (v == null || v.length < 4) ? 'Password too short' : null,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: const Color(0xFF7E57C2),
                                elevation: 4,
                              ),
                              onPressed: _loading ? null : _submit,
                              child: _loading
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('Login', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () async {
                              final registered = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterPage()));
                              if (registered == true) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful — please login')));
                              }
                            },
                            child: const Text("Don't have an account? Register"),
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
